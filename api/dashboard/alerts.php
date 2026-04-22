<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/../utils/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once __DIR__ . '/../database/connection.php';

require_once __DIR__ . '/../utils/auth.php';
require_once __DIR__ . '/../utils/notifications.php';

function respond($payload, int $code = 200): void {
    http_response_code($code);
    echo json_encode($payload);
    exit;
}


$session = auth_require_roles(['admin', 'teacher', 'registrar']);

try {
    $alerts = [];

    // Get current active school year
    $syStmt = $conn->query(
        "SELECT school_year_id FROM school_years
         WHERE is_deleted = 0 AND is_active = 1
         LIMIT 1"
    );
    $currentSY = $syStmt->fetchColumn();

    if ($currentSY) {
        // Alert 1: At-risk students count
        try {
            $atRiskStmt = $conn->prepare(
                "SELECT COUNT(*) AS at_risk_count
                 FROM risk_assessments ra
                 JOIN grading_periods gp ON gp.grading_period_id = ra.grading_period_id
                                       AND gp.is_deleted = 0
                                       AND gp.school_year_id = :sy
                 JOIN risk_levels rl ON rl.risk_level_id = ra.risk_level_id
                                    AND rl.is_deleted = 0
                 JOIN (
                     SELECT ra2.enrollment_id, MAX(ra2.grading_period_id) AS latest_period_id
                     FROM risk_assessments ra2
                     JOIN grading_periods gp2 ON gp2.grading_period_id = ra2.grading_period_id
                                             AND gp2.is_deleted = 0
                                             AND gp2.school_year_id = :sy2
                     WHERE ra2.is_deleted = 0
                     GROUP BY ra2.enrollment_id
                 ) latest ON latest.enrollment_id = ra.enrollment_id
                         AND latest.latest_period_id = ra.grading_period_id
                 WHERE ra.is_deleted = 0
                   AND LOWER(TRIM(rl.risk_name)) <> 'low'"
            );
            $atRiskStmt->execute([':sy' => (int)$currentSY, ':sy2' => (int)$currentSY]);
            $atRiskCount = (int)$atRiskStmt->fetchColumn();

            if ($atRiskCount > 0) {
                $severity = $atRiskCount > 20 ? 'high' : ($atRiskCount > 10 ? 'medium' : 'low');
                $alerts[] = [
                    'id' => count($alerts) + 1,
                    'message' => "$atRiskCount students identified as at-risk",
                    'severity' => $severity,
                    'icon' => 'fa-exclamation-triangle'
                ];
            }
        } catch (Exception $e) {
            // Skip if table doesn't exist
        }

        // Alert 2: Students without submitted documents (DISABLED - table doesn't exist)
        // Uncomment when student_documents table is created
        /*
        try {
            $docStmt = $conn->prepare(
                "SELECT COUNT(DISTINCT e.student_id) AS incomplete_count
                 FROM enrollments e
                 LEFT JOIN student_documents sd ON sd.student_id = e.student_id
                    AND e.school_year_id = sd.school_year_id
                 WHERE e.is_deleted = 0 AND e.school_year_id = ?
                 GROUP BY e.school_year_id
                 HAVING COUNT(sd.document_id) < 3"
            );
            $docStmt->execute([$currentSY]);
            $incompleteCount = (int)($docStmt->fetchColumn() ?? 0);

            if ($incompleteCount > 0) {
                $alerts[] = [
                    'id' => count($alerts) + 1,
                    'message' => "$incompleteCount students have incomplete enrollment documents",
                    'severity' => 'medium',
                    'icon' => 'fa-file-alt'
                ];
            }
        } catch (Exception $e) {
            // Skip if table doesn't exist
        }
        */

        // Alert 3: Upcoming grading period deadlines
        try {
            $gpStmt = $conn->prepare(
                "SELECT gp.period_name, gp.date_end,
                        DATEDIFF(gp.date_end, CURDATE()) AS days_remaining
                 FROM grading_periods gp
                 WHERE gp.is_deleted = 0 AND gp.school_year_id = ?
                  AND gp.status = 'Open'
                 AND gp.date_end BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
                 ORDER BY gp.date_end ASC"
            );
            $gpStmt->execute([$currentSY]);
            $upcomingGP = $gpStmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($upcomingGP as $gp) {
                $daysLeft = (int)$gp['days_remaining'];
                if ($daysLeft >= 0) {
                    $alerts[] = [
                        'id' => count($alerts) + 1,
                        'message' => "{$gp['period_name']} deadline in {$daysLeft} days",
                        'severity' => $daysLeft <= 3 ? 'high' : 'medium',
                        'icon' => 'fa-calendar-alt'
                    ];
                }
            }
        } catch (Exception $e) {
            // Skip if table doesn't exist
        }

        // Alert 4: Low attendance count
        try {
            $attendanceStmt = $conn->prepare(
                "SELECT COUNT(DISTINCT e.learner_id) AS low_attendance_count
                 FROM enrollments e
                 LEFT JOIN risk_assessments ra ON ra.enrollment_id = e.enrollment_id
                 WHERE e.is_deleted = 0 AND e.school_year_id = ?
                 AND ra.risk_level_id = 3"  // Assuming risk level 3 is attendance-related
            );
            $attendanceStmt->execute([$currentSY]);
            $lowAttendanceCount = (int)($attendanceStmt->fetchColumn() ?? 0);

            if ($lowAttendanceCount > 0) {
                $alerts[] = [
                    'id' => count($alerts) + 1,
                    'message' => "$lowAttendanceCount students have low attendance",
                    'severity' => 'medium',
                    'icon' => 'fa-clock'
                ];
            }
        } catch (Exception $e) {
            // Skip if table doesn't exist
        }
    }

    // If no specific alerts were generated, add a general status alert
    if (empty($alerts)) {
        $alerts[] = [
            'id' => 1,
            'message' => 'All systems operating normally',
            'severity' => 'info',
            'icon' => 'fa-check-circle'
        ];
    }

    // Persist actionable alerts into the notifications table for this user.
    try {
        $userId = (int)($session['user_id'] ?? 0);
        foreach ($alerts as $a) {
            $severity = (string)($a['severity'] ?? '');
            $message = trim((string)($a['message'] ?? ''));
            if ($userId <= 0 || $message === '') continue;
            if ($severity === 'info') continue;
            if ($message === 'All systems operating normally') continue;

            $title = 'Dashboard Alert';
            $type = 'Risk Flag';

            if (!notifications_exists_today_for_user($conn, $userId, $type, $title, $message)) {
                notifications_create_for_user($conn, $userId, $type, $title, $message, 'dashboard_alerts', null);
            }
        }
    } catch (Exception $e) {
        // Ignore persistence failures.
    }

    respond([
        'success' => true,
        'data' => $alerts,
    ]);

} catch (Exception $e) {
    respond([
        'success' => false,
        'message' => 'Error generating alerts: ' . $e->getMessage(),
    ], 500);
}
?>
