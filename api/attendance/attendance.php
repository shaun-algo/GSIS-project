<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/../utils/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { exit(0); }

require_once __DIR__ . '/../database/connection.php';
require_once __DIR__ . '/../utils/auth.php';

function debug_attendance($msg, $data = null): void {
    if (getenv('ATTENDANCE_DEBUG') !== '1') return;
    $log = date('Y-m-d H:i:s ') . "[attendance.php {$msg}]";
    if ($data !== null) $log .= ' ' . json_encode($data);
    $log .= "\n";
    @file_put_contents('/tmp/attendance_debug.log', $log, FILE_APPEND | LOCK_EX);
}

function respond($payload, int $code = 200): void {
    http_response_code($code);
    echo json_encode($payload);
    exit;
}

function getJsonInput(): array {
    $raw = file_get_contents('php://input');
    return $raw ? (json_decode($raw, true) ?: []) : [];
}

function getEmployeeIdForUser(PDO $conn, int $userId): int {
    if ($userId <= 0) {
        respond(['success' => false, 'message' => 'Invalid session user'], 401);
    }
    $stmt = $conn->prepare('SELECT employee_id FROM employees WHERE user_id = :user_id AND is_deleted = 0 LIMIT 1');
    $stmt->bindValue(':user_id', $userId, PDO::PARAM_INT);
    $stmt->execute();
    $eid = (int)($stmt->fetchColumn() ?: 0);
    if ($eid <= 0) {
        respond(['success' => false, 'message' => 'Teacher profile not found for this account'], 403);
    }
    return $eid;
}

function requireTeacherCanAccessSection(PDO $conn, int $employeeId, int $sectionId, int $schoolYearId): void {
    $stmt = $conn->prepare(
        'SELECT 1 FROM DUAL
         WHERE EXISTS (
             SELECT 1 FROM sections s
             WHERE s.section_id = :sid1 AND s.school_year_id = :sy1 AND s.is_deleted = 0
               AND s.adviser_id = :eid1
         )
         OR EXISTS (
             SELECT 1 FROM class_offerings co
             WHERE co.section_id = :sid2 AND co.school_year_id = :sy2 AND co.is_deleted = 0
               AND co.teacher_id = :eid2
         )
         LIMIT 1'
    );
    $stmt->bindValue(':sid1', $sectionId, PDO::PARAM_INT);
    $stmt->bindValue(':sy1', $schoolYearId, PDO::PARAM_INT);
    $stmt->bindValue(':eid1', $employeeId, PDO::PARAM_INT);
    $stmt->bindValue(':sid2', $sectionId, PDO::PARAM_INT);
    $stmt->bindValue(':sy2', $schoolYearId, PDO::PARAM_INT);
    $stmt->bindValue(':eid2', $employeeId, PDO::PARAM_INT);
    $stmt->execute();
    if (!$stmt->fetchColumn()) {
        respond(['success' => false, 'message' => 'Not authorized for this section. Assign this teacher as adviser or add a class offering for this section.'], 403);
    }
}

function requireTeacherOwnsClassOffering(PDO $conn, int $employeeId, int $classId, int $sectionId, int $schoolYearId): void {
    // `class_id = 0` is used by the UI for section-level (non-subject) attendance.
    // In that case, allow access if the teacher is assigned to the section
    // (either adviser or has any class offering within the section).
    if ($classId <= 0) {
        requireTeacherCanAccessSection($conn, $employeeId, $sectionId, $schoolYearId);
        return;
    }

    $stmt = $conn->prepare(
        'SELECT class_id
         FROM class_offerings
        WHERE class_id = :class_id
           AND is_deleted = 0
           AND teacher_id = :eid
           AND section_id = :sid
           AND school_year_id = :sy
         LIMIT 1'
    );
    $stmt->bindValue(':class_id', $classId, PDO::PARAM_INT);
    $stmt->bindValue(':eid', $employeeId, PDO::PARAM_INT);
    $stmt->bindValue(':sid', $sectionId, PDO::PARAM_INT);
    $stmt->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
    $stmt->execute();
    if (!$stmt->fetchColumn()) {
        respond(['success' => false, 'message' => 'Not authorized for this class offering'], 403);
    }
}

function monthBounds(string $ym): array {
    // ym format: YYYY-MM
    if (!preg_match('/^\d{4}-\d{2}$/', $ym)) {
        respond(['success' => false, 'message' => 'Invalid month format. Expected YYYY-MM.'], 422);
    }
    [$y, $m] = array_map('intval', explode('-', $ym));
    if ($y < 2000 || $y > 2100 || $m < 1 || $m > 12) {
        respond(['success' => false, 'message' => 'Invalid month value.'], 422);
    }
    $start = sprintf('%04d-%02d-01', $y, $m);
    $end = date('Y-m-t', strtotime($start));
    return [$y, $m, $start, $end];
}

function countWeekdaysInMonth(int $year, int $month): int {
    $start = new DateTime(sprintf('%04d-%02d-01', $year, $month));
    $end = new DateTime($start->format('Y-m-t'));
    $end = $end->modify('+1 day');

    $count = 0;
    for ($d = clone $start; $d < $end; $d->modify('+1 day')) {
        $dow = (int)$d->format('N'); // 1=Mon..7=Sun
        if ($dow >= 1 && $dow <= 5) $count++;
    }
    return $count;
}

$operation = $_GET['operation'] ?? '';
$session = auth_enforce_roles($operation, ['admin', 'teacher'], ['admin', 'teacher']);

try {
    switch ($operation) {
        case 'getSectionRoster': getSectionRoster($conn, $session); break;
        case 'getDayAttendance': getDayAttendance($conn, $session); break;
        case 'saveDayAttendance': saveDayAttendance($conn, $session); break;
        case 'getMonthAttendance': getMonthAttendance($conn, $session); break;
        case 'saveMonthAttendance': saveMonthAttendance($conn, $session); break;
        case 'computeMonthlySummary': computeMonthlySummary($conn, $session); break;
        case 'getMonthlySummary': getMonthlySummary($conn, $session); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Throwable $e) {
    error_log('[attendance.php] op=' . $operation . ' method=' . ($_SERVER['REQUEST_METHOD'] ?? '') . ' err=' . $e->getMessage());
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function attendanceColumnInfo(PDO $conn): array {
    static $cache = null;
    if (is_array($cache)) return $cache;

    $cols = [];
    $allowedStatuses = [];

    $stmt = $conn->query("SHOW COLUMNS FROM attendance");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($rows as $r) {
        $name = $r['Field'] ?? '';
        if ($name) $cols[$name] = true;
        if ($name === 'status') {
            $type = (string)($r['Type'] ?? '');
            if (preg_match("/^enum\((.*)\)$/i", $type, $m)) {
                // $m[1] contains comma-separated quoted values.
                preg_match_all("/'([^']*)'/", $m[1], $vals);
                $allowedStatuses = $vals[1] ?? [];
            }
        }
    }

    $cache = [
        'cols' => $cols,
        'has_session' => isset($cols['session']),
        'has_nls_reason' => isset($cols['nls_reason']),
        'has_transfer_note' => isset($cols['transfer_note']),
        'allowed_statuses' => $allowedStatuses,
    ];
    return $cache;
}

function normalizeStatusForDb(PDO $conn, string $requestedStatus, ?string $remarks): array {
    $info = attendanceColumnInfo($conn);
    $allowed = $info['allowed_statuses'] ?? [];

    $status = trim($requestedStatus);
    $remarksOut = $remarks;
    if ($remarksOut !== null) {
        $remarksOut = trim((string)$remarksOut);
        if ($remarksOut === '') $remarksOut = null;
    }

    if (in_array($status, $allowed, true)) {
        return [$status, $remarksOut];
    }

    // Back-compat mapping for dep_ed-2 enum.
    if ($status === 'Cutting') {
        $remarksOut = $remarksOut ? ("Cutting; " . $remarksOut) : 'Cutting';
        $fallback = in_array('Absent', $allowed, true) ? 'Absent' : (in_array('Present', $allowed, true) ? 'Present' : 'Absent');
        return [$fallback, $remarksOut];
    }
    if ($status === 'Official Business') {
        $remarksOut = $remarksOut ? ("Official Business; " . $remarksOut) : 'Official Business';
        $fallback = in_array('Excused', $allowed, true) ? 'Excused' : (in_array('Present', $allowed, true) ? 'Present' : 'Excused');
        return [$fallback, $remarksOut];
    }

    respond(['success' => false, 'message' => 'Unsupported attendance status for current database schema.'], 422);
}

function getSectionRoster(PDO $conn, array $session): void {
    $sectionId = (int)($_GET['section_id'] ?? 0);
    $schoolYearId = (int)($_GET['school_year_id'] ?? 0);
    if ($sectionId <= 0 || $schoolYearId <= 0) {
        respond(['success' => false, 'message' => 'section_id and school_year_id are required'], 422);
    }

    if (($session['role_key'] ?? '') === 'teacher') {
        $employeeId = getEmployeeIdForUser($conn, (int)($session['user_id'] ?? 0));
        requireTeacherCanAccessSection($conn, $employeeId, $sectionId, $schoolYearId);
    }

    $stmt = $conn->prepare(
        "SELECT e.enrollment_id,
                e.learner_id,
                l.lrn,
              l.gender,
                l.last_name,
                l.first_name,
                l.middle_name,
                l.name_extension,
                CONCAT(l.last_name, ', ', l.first_name,
                       CASE WHEN l.middle_name IS NULL OR l.middle_name = '' THEN '' ELSE CONCAT(' ', l.middle_name) END,
                       CASE WHEN l.name_extension IS NULL OR l.name_extension = '' THEN '' ELSE CONCAT(' ', l.name_extension) END
                ) AS learner_name
         FROM enrollments e
         JOIN learners l ON l.learner_id = e.learner_id
         WHERE e.is_deleted = 0
           AND l.is_deleted = 0
           AND e.section_id = :section_id
           AND e.school_year_id = :school_year_id
         ORDER BY l.last_name ASC, l.first_name ASC, l.middle_name ASC, e.enrollment_id ASC"
    );
    $stmt->bindValue(':section_id', $sectionId, PDO::PARAM_INT);
    $stmt->bindValue(':school_year_id', $schoolYearId, PDO::PARAM_INT);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function getDayAttendance(PDO $conn, array $sessionInfo): void {
    $sectionId = (int)($_GET['section_id'] ?? 0);
    $schoolYearId = (int)($_GET['school_year_id'] ?? 0);
    $gradingPeriodId = (int)($_GET['grading_period_id'] ?? 0);
    $date = (string)($_GET['date'] ?? '');
    $session = (string)($_GET['session'] ?? 'AM');
    $classId = (int)($_GET['class_id'] ?? 0);

    if ($sectionId <= 0 || $schoolYearId <= 0 || $gradingPeriodId <= 0 || $date === '') {
        respond(['success' => false, 'message' => 'section_id, school_year_id, grading_period_id, and date are required'], 422);
    }
    if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)) {
        respond(['success' => false, 'message' => 'Invalid date format. Expected YYYY-MM-DD.'], 422);
    }
    $session = strtoupper(trim($session));
    if (!in_array($session, ['AM', 'PM'], true)) {
        respond(['success' => false, 'message' => 'Invalid session. Expected AM or PM.'], 422);
    }

    $info = attendanceColumnInfo($conn);
    if (!$info['has_session'] && $session === 'PM') {
        respond(['success' => false, 'message' => 'Current database schema does not support AM/PM sessions. Use dep_ed-3.sql attendance schema.'], 422);
    }

    if (($sessionInfo['role_key'] ?? '') === 'teacher') {
        $employeeId = getEmployeeIdForUser($conn, (int)($sessionInfo['user_id'] ?? 0));
        requireTeacherOwnsClassOffering($conn, $employeeId, $classId, $sectionId, $schoolYearId);
    }

    $whereSession = $info['has_session'] ? 'AND a.session = :session' : '';

    $selectSession = $info['has_session'] ? ', a.session' : '';
    $sql = "SELECT a.attendance_id, a.enrollment_id, a.attendance_date, a.status, a.remarks" . $selectSession . "
         FROM attendance a
         JOIN enrollments e ON e.enrollment_id = a.enrollment_id
         WHERE a.is_deleted = 0
           AND e.is_deleted = 0
           AND e.section_id = :section_id
           AND e.school_year_id = :school_year_id
           AND a.grading_period_id = :grading_period_id
           AND a.class_id = :class_id
           AND a.attendance_date = :attendance_date
           $whereSession";
    debug_attendance('getDayAttendance SQL', ['sql' => $sql, 'whereSession' => $whereSession, 'selectSession' => $selectSession, 'has_session' => $info['has_session']]);
    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':section_id', $sectionId, PDO::PARAM_INT);
    $stmt->bindValue(':school_year_id', $schoolYearId, PDO::PARAM_INT);
    $stmt->bindValue(':grading_period_id', $gradingPeriodId, PDO::PARAM_INT);
    $stmt->bindValue(':class_id', $classId, PDO::PARAM_INT);
    $stmt->bindValue(':attendance_date', $date);
    if ($info['has_session']) {
        $stmt->bindValue(':session', $session);
    }
    debug_attendance('getDayAttendance binds', ['binds_done' => true]);
    $stmt->execute();
    debug_attendance('getDayAttendance execute success');

    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function saveDayAttendance(PDO $conn, array $sessionInfo): void {
    $data = getJsonInput();
    $sectionId = (int)($data['section_id'] ?? 0);
    $schoolYearId = (int)($data['school_year_id'] ?? 0);
    $gradingPeriodId = (int)($data['grading_period_id'] ?? 0);
    $classId = (int)($data['class_id'] ?? 0);
    $date = (string)($data['date'] ?? '');
    $session = (string)($data['session'] ?? 'AM');
    $entries = $data['entries'] ?? null;

    if ($sectionId <= 0 || $schoolYearId <= 0 || $gradingPeriodId <= 0 || $date === '' || !is_array($entries)) {
        respond(['success' => false, 'message' => 'section_id, school_year_id, grading_period_id, date, and entries[] are required'], 422);
    }
    if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)) {
        respond(['success' => false, 'message' => 'Invalid date format. Expected YYYY-MM-DD.'], 422);
    }
    $session = strtoupper(trim($session));
    if (!in_array($session, ['AM', 'PM'], true)) {
        respond(['success' => false, 'message' => 'Invalid session. Expected AM or PM.'], 422);
    }

    $info = attendanceColumnInfo($conn);
    if (!$info['has_session'] && $session === 'PM') {
        respond(['success' => false, 'message' => 'Current database schema does not support AM/PM sessions. Use dep_ed-3.sql attendance schema.'], 422);
    }

    if (($sessionInfo['role_key'] ?? '') === 'teacher') {
        $employeeId = getEmployeeIdForUser($conn, (int)($sessionInfo['user_id'] ?? 0));
        requireTeacherOwnsClassOffering($conn, $employeeId, $classId, $sectionId, $schoolYearId);
    }

    $userId = (int)($sessionInfo['user_id'] ?? 0);

    $cols = ['enrollment_id', 'class_id', 'grading_period_id', 'attendance_date'];
    if ($info['has_session']) $cols[] = 'session';
    $cols = array_merge($cols, ['status', 'remarks', 'recorded_by']);

    $placeholders = array_map(fn($c) => ':' . $c, $cols);
    $sql = "INSERT INTO attendance (" . implode(',', $cols) . ")\n" .
           "VALUES (" . implode(',', $placeholders) . ")\n" .
           "ON DUPLICATE KEY UPDATE\n" .
           "  grading_period_id = VALUES(grading_period_id),\n" .
           ($info['has_session'] ? "  session = VALUES(session),\n" : "") .
           "  status = VALUES(status),\n" .
           "  remarks = VALUES(remarks),\n" .
           "  recorded_by = VALUES(recorded_by),\n" .
           "  recorded_at = CURRENT_TIMESTAMP,\n" .
           "  is_deleted = 0,\n" .
           "  deleted_at = NULL";

    $stmt = $conn->prepare($sql);

    $saved = 0;
    $conn->beginTransaction();
    try {
        foreach ($entries as $row) {
            $enrollmentId = (int)($row['enrollment_id'] ?? 0);
            $statusReq = (string)($row['status'] ?? '');
            $remarks = $row['remarks'] ?? null;
            if ($enrollmentId <= 0) continue;
            $statusReq = trim($statusReq);
            if ($statusReq === '') continue;

            [$status, $remarksOut] = normalizeStatusForDb($conn, $statusReq, $remarks);

            if ($remarksOut !== null && strlen($remarksOut) > 255) {
                $remarksOut = substr($remarksOut, 0, 255);
            }

            $stmt->bindValue(':enrollment_id', $enrollmentId, PDO::PARAM_INT);
            $stmt->bindValue(':class_id', $classId, PDO::PARAM_INT);
            $stmt->bindValue(':grading_period_id', $gradingPeriodId, PDO::PARAM_INT);
            $stmt->bindValue(':attendance_date', $date);
            if ($info['has_session']) {
                $stmt->bindValue(':session', $session);
            }
            $stmt->bindValue(':status', $status);
            $stmt->bindValue(':remarks', $remarksOut, $remarksOut === null ? PDO::PARAM_NULL : PDO::PARAM_STR);
            $stmt->bindValue(':recorded_by', $userId > 0 ? $userId : null, $userId > 0 ? PDO::PARAM_INT : PDO::PARAM_NULL);
            debug_attendance('saveDayAttendance before execute', ['cols_count' => count($cols), 'ph_count' => count($placeholders), 'has_session' => $info['has_session']]);
            $stmt->execute();
            debug_attendance('saveDayAttendance execute success');
            $saved++;
        }
        $conn->commit();
        respond(['success' => true, 'message' => 'Attendance saved', 'saved' => $saved]);
    } catch (PDOException $e) {
        $conn->rollBack();
        $msg = $e->getMessage();
        if (str_contains($msg, 'Invalid grading_period_id')) {
            respond(['success' => false, 'message' => 'Invalid grading period for this enrollment/school year.'], 422);
        }
        if (str_contains($msg, 'Invalid class_id')) {
            respond(['success' => false, 'message' => 'Invalid class offering (class_id) for this enrollment.'], 422);
        }
        throw $e;
    }
}

function getMonthAttendance(PDO $conn, array $sessionInfo): void {
    $sectionId = (int)($_GET['section_id'] ?? 0);
    $schoolYearId = (int)($_GET['school_year_id'] ?? 0);
    $gradingPeriodId = (int)($_GET['grading_period_id'] ?? 0);
    $ym = (string)($_GET['month'] ?? '');
    $classId = (int)($_GET['class_id'] ?? 0);
    $session = strtoupper((string)($_GET['session'] ?? ''));

    if ($sectionId <= 0 || $schoolYearId <= 0 || $gradingPeriodId <= 0 || $ym === '') {
        respond(['success' => false, 'message' => 'section_id, school_year_id, grading_period_id, and month are required'], 422);
    }

    [, , $start, $end] = monthBounds($ym);

    if (($sessionInfo['role_key'] ?? '') === 'teacher') {
        $employeeId = getEmployeeIdForUser($conn, (int)($sessionInfo['user_id'] ?? 0));
        requireTeacherOwnsClassOffering($conn, $employeeId, $classId, $sectionId, $schoolYearId);
    }

    $col = attendanceColumnInfo($conn);
    $hasSession = (bool)($col['has_session'] ?? false);
    $selectSession = $hasSession ? ', a.session' : '';
    $whereSession = ($hasSession && in_array($session, ['AM', 'PM'], true)) ? ' AND a.session = :session' : '';

    $stmt = $conn->prepare(
        "SELECT a.attendance_id, a.enrollment_id, a.attendance_date, a.status, a.remarks{$selectSession}
         FROM attendance a
         JOIN enrollments e ON e.enrollment_id = a.enrollment_id
         WHERE a.is_deleted = 0
           AND e.is_deleted = 0
           AND e.section_id = :section_id
           AND e.school_year_id = :school_year_id
           AND a.grading_period_id = :grading_period_id
           AND a.class_id = :class_id
           AND a.attendance_date BETWEEN :start_date AND :end_date{$whereSession}"
    );
    $stmt->bindValue(':section_id', $sectionId, PDO::PARAM_INT);
    $stmt->bindValue(':school_year_id', $schoolYearId, PDO::PARAM_INT);
    $stmt->bindValue(':grading_period_id', $gradingPeriodId, PDO::PARAM_INT);
    $stmt->bindValue(':class_id', $classId, PDO::PARAM_INT);
    $stmt->bindValue(':start_date', $start);
    $stmt->bindValue(':end_date', $end);
    if ($hasSession && in_array($session, ['AM', 'PM'], true)) {
        $stmt->bindValue(':session', $session);
    }
    $stmt->execute();

    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function saveMonthAttendance(PDO $conn, array $session): void {
    $data = getJsonInput();
    $sectionId = (int)($data['section_id'] ?? 0);
    $schoolYearId = (int)($data['school_year_id'] ?? 0);
    $gradingPeriodId = (int)($data['grading_period_id'] ?? 0);
    $classId = (int)($data['class_id'] ?? 0);
    $entries = $data['entries'] ?? null;

    if ($sectionId <= 0 || $schoolYearId <= 0 || $gradingPeriodId <= 0 || !is_array($entries)) {
        respond(['success' => false, 'message' => 'section_id, school_year_id, grading_period_id, and entries[] are required'], 422);
    }

    if (($session['role_key'] ?? '') === 'teacher') {
        $employeeId = getEmployeeIdForUser($conn, (int)($session['user_id'] ?? 0));
        requireTeacherOwnsClassOffering($conn, $employeeId, $classId, $sectionId, $schoolYearId);
    }

    $userId = (int)($session['user_id'] ?? 0);

    $sql = "INSERT INTO attendance (enrollment_id, class_id, grading_period_id, attendance_date, status, remarks, recorded_by)
            VALUES (:enrollment_id, :class_id, :grading_period_id, :attendance_date, :status, :remarks, :recorded_by)
            ON DUPLICATE KEY UPDATE
                grading_period_id = VALUES(grading_period_id),
                status = VALUES(status),
                remarks = VALUES(remarks),
                recorded_by = VALUES(recorded_by),
                recorded_at = CURRENT_TIMESTAMP,
                is_deleted = 0,
                deleted_at = NULL";

    $stmt = $conn->prepare($sql);

    $saved = 0;
    $conn->beginTransaction();
    try {
        foreach ($entries as $row) {
            $enrollmentId = (int)($row['enrollment_id'] ?? 0);
            $date = (string)($row['attendance_date'] ?? '');
            $status = (string)($row['status'] ?? '');
            $remarks = $row['remarks'] ?? null;

            if ($enrollmentId <= 0 || !preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)) {
                continue;
            }

            // allow blank to mean "no record" (skip)
            $status = trim($status);
            if ($status === '') {
                continue;
            }

            if (!in_array($status, ['Present', 'Absent', 'Late', 'Excused'], true)) {
                continue;
            }

            if ($remarks !== null) {
                $remarks = trim((string)$remarks);
                if ($remarks === '') $remarks = null;
                if ($remarks !== null && strlen($remarks) > 255) {
                    $remarks = substr($remarks, 0, 255);
                }
            }

            $stmt->bindValue(':enrollment_id', $enrollmentId, PDO::PARAM_INT);
            $stmt->bindValue(':class_id', $classId, PDO::PARAM_INT);
            $stmt->bindValue(':grading_period_id', $gradingPeriodId, PDO::PARAM_INT);
            $stmt->bindValue(':attendance_date', $date);
            $stmt->bindValue(':status', $status);
            $stmt->bindValue(':remarks', $remarks, $remarks === null ? PDO::PARAM_NULL : PDO::PARAM_STR);
            $stmt->bindValue(':recorded_by', $userId > 0 ? $userId : null, $userId > 0 ? PDO::PARAM_INT : PDO::PARAM_NULL);
            $stmt->execute();
            $saved++;
        }

        $conn->commit();
        respond(['success' => true, 'message' => 'Attendance saved', 'saved' => $saved]);
    } catch (PDOException $e) {
        $conn->rollBack();
        // Surface validation trigger errors cleanly.
        $msg = $e->getMessage();
        if (str_contains($msg, 'Invalid grading_period_id')) {
            respond(['success' => false, 'message' => 'Invalid grading period for this enrollment/school year.'], 422);
        }
        if (str_contains($msg, 'Invalid class_id')) {
            respond(['success' => false, 'message' => 'Invalid class offering (class_id) for this enrollment.'], 422);
        }
        throw $e;
    }
}

function computeMonthlySummary(PDO $conn, array $session): void {
    $data = getJsonInput();
    $sectionId = (int)($data['section_id'] ?? 0);
    $schoolYearId = (int)($data['school_year_id'] ?? 0);
    $gradingPeriodId = (int)($data['grading_period_id'] ?? 0);
    $ym = (string)($data['month'] ?? '');
    $classId = (int)($data['class_id'] ?? 0);

    if ($sectionId <= 0 || $schoolYearId <= 0 || $gradingPeriodId <= 0 || $ym === '') {
        respond(['success' => false, 'message' => 'section_id, school_year_id, grading_period_id, and month are required'], 422);
    }

    if (($session['role_key'] ?? '') === 'teacher') {
        $employeeId = getEmployeeIdForUser($conn, (int)($session['user_id'] ?? 0));
        requireTeacherOwnsClassOffering($conn, $employeeId, $classId, $sectionId, $schoolYearId);
    }

    [$year, $month, $start, $end] = monthBounds($ym);
    $monthNo = (int)$month;

    // Compute per-enrollment totals from attendance records.
    $stmt = $conn->prepare(
        "SELECT e.enrollment_id,
                SUM(a.status = 'Present') AS days_present,
                SUM(a.status = 'Absent') AS days_absent,
                SUM(a.status = 'Late') AS days_late,
                SUM(a.status = 'Excused') AS days_excused
         FROM enrollments e
         LEFT JOIN attendance a
           ON a.enrollment_id = e.enrollment_id
          AND a.is_deleted = 0
          AND a.class_id = :class_id
          AND a.grading_period_id = :grading_period_id
          AND a.attendance_date BETWEEN :start_date AND :end_date
         WHERE e.is_deleted = 0
           AND e.section_id = :section_id
           AND e.school_year_id = :school_year_id
         GROUP BY e.enrollment_id"
    );
    $stmt->bindValue(':class_id', $classId, PDO::PARAM_INT);
    $stmt->bindValue(':grading_period_id', $gradingPeriodId, PDO::PARAM_INT);
    $stmt->bindValue(':start_date', $start);
    $stmt->bindValue(':end_date', $end);
    $stmt->bindValue(':section_id', $sectionId, PDO::PARAM_INT);
    $stmt->bindValue(':school_year_id', $schoolYearId, PDO::PARAM_INT);
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $totalSchoolDays = countWeekdaysInMonth($year, $month);
    $computedBy = (int)($session['user_id'] ?? 0);

    $up = $conn->prepare(
        "INSERT INTO attendance_monthly_summaries
            (enrollment_id, school_year_id, month_no, total_school_days, days_present, days_absent, days_late, days_excused, computed_by)
         VALUES
            (:enrollment_id, :school_year_id, :month_no, :total_school_days, :days_present, :days_absent, :days_late, :days_excused, :computed_by)
         ON DUPLICATE KEY UPDATE
            total_school_days = VALUES(total_school_days),
            days_present = VALUES(days_present),
            days_absent = VALUES(days_absent),
            days_late = VALUES(days_late),
            days_excused = VALUES(days_excused),
            computed_by = VALUES(computed_by),
            computed_at = CURRENT_TIMESTAMP,
            updated_at = CURRENT_TIMESTAMP,
            is_deleted = 0,
            deleted_at = NULL"
    );

    $saved = 0;
    $conn->beginTransaction();
    try {
        foreach ($rows as $r) {
            $enrollmentId = (int)($r['enrollment_id'] ?? 0);
            if ($enrollmentId <= 0) continue;

            $present = (int)($r['days_present'] ?? 0);
            $absent = (int)($r['days_absent'] ?? 0);
            $late = (int)($r['days_late'] ?? 0);
            $excused = (int)($r['days_excused'] ?? 0);

            $up->bindValue(':enrollment_id', $enrollmentId, PDO::PARAM_INT);
            $up->bindValue(':school_year_id', $schoolYearId, PDO::PARAM_INT);
            $up->bindValue(':month_no', $monthNo, PDO::PARAM_INT);
            $up->bindValue(':total_school_days', $totalSchoolDays, PDO::PARAM_INT);
            $up->bindValue(':days_present', $present, PDO::PARAM_INT);
            $up->bindValue(':days_absent', $absent, PDO::PARAM_INT);
            $up->bindValue(':days_late', $late, PDO::PARAM_INT);
            $up->bindValue(':days_excused', $excused, PDO::PARAM_INT);
            $up->bindValue(':computed_by', $computedBy > 0 ? $computedBy : null, $computedBy > 0 ? PDO::PARAM_INT : PDO::PARAM_NULL);
            $up->execute();
            $saved++;
        }

        $conn->commit();
        respond(['success' => true, 'message' => 'Monthly summary computed', 'saved' => $saved, 'total_school_days' => $totalSchoolDays]);
    } catch (PDOException $e) {
        $conn->rollBack();
        throw $e;
    }
}

function getMonthlySummary(PDO $conn, array $session): void {
    $sectionId = (int)($_GET['section_id'] ?? 0);
    $schoolYearId = (int)($_GET['school_year_id'] ?? 0);
    $ym = (string)($_GET['month'] ?? '');
    if ($sectionId <= 0 || $schoolYearId <= 0 || $ym === '') {
        respond(['success' => false, 'message' => 'section_id, school_year_id, and month are required'], 422);
    }

    if (($session['role_key'] ?? '') === 'teacher') {
        $employeeId = getEmployeeIdForUser($conn, (int)($session['user_id'] ?? 0));
        requireTeacherCanAccessSection($conn, $employeeId, $sectionId, $schoolYearId);
    }

    [, $month, , ] = monthBounds($ym);
    $monthNo = (int)$month;

    $stmt = $conn->prepare(
        "SELECT s.enrollment_id,
                s.total_school_days,
                s.days_present,
                s.days_absent,
                s.days_late,
                s.days_excused
         FROM attendance_monthly_summaries s
         JOIN enrollments e ON e.enrollment_id = s.enrollment_id
         WHERE s.is_deleted = 0
           AND e.is_deleted = 0
           AND e.section_id = :section_id
           AND s.school_year_id = :school_year_id
           AND s.month_no = :month_no"
    );
    $stmt->bindValue(':section_id', $sectionId, PDO::PARAM_INT);
    $stmt->bindValue(':school_year_id', $schoolYearId, PDO::PARAM_INT);
    $stmt->bindValue(':month_no', $monthNo, PDO::PARAM_INT);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}
