<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/../utils/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { exit(0); }

require_once __DIR__ . '/../database/connection.php';

require_once __DIR__ . '/../utils/auth.php';

function respond($payload, int $code = 200): void {
    if (!headers_sent()) {
        header('Content-Type: application/json; charset=utf-8');
    }
    http_response_code($code);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function getJsonInput(): array {
    $raw = file_get_contents('php://input');
    return $raw ? (json_decode($raw, true) ?: []) : [];
}

$operation = $_GET['operation'] ?? '';
$session = auth_enforce_roles($operation, ['admin', 'registrar'], ['admin']);
try {
    switch ($operation) {
        case 'getAllReportCards': getAllReportCards($conn); break;
        case 'getSF9Data': getSF9Data($conn); break;
        case 'getSF9DataByEnrollment': getSF9DataByEnrollment($conn); break;
        case 'getSF9Roster': getSF9Roster($conn); break;
        case 'createReportCard': createReportCard($conn); break;
        case 'updateReportCard': updateReportCard($conn); break;
        case 'deleteReportCard': deleteReportCard($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function formatPersonName(?string $first, ?string $middle, ?string $last, ?string $ext = null): string {
    $first = trim((string)($first ?? ''));
    $middle = trim((string)($middle ?? ''));
    $last = trim((string)($last ?? ''));
    $ext = trim((string)($ext ?? ''));

    $parts = [];
    if ($last !== '') $parts[] = $last . ',';
    if ($first !== '') $parts[] = $first;
    if ($middle !== '') $parts[] = $middle;
    if ($ext !== '') $parts[] = $ext;
    return trim(implode(' ', $parts));
}

function computeAge(?string $dob, ?string $asOfDate = null): ?int {
    $dob = trim((string)($dob ?? ''));
    if ($dob === '') return null;
    if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $dob)) return null;
    try {
        $birth = new DateTime($dob);
        $ref = $asOfDate ? new DateTime($asOfDate) : new DateTime();
        $diff = $birth->diff($ref);
        $age = (int)($diff->y ?? 0);
        return $age > 0 ? $age : 0;
    } catch (Throwable $_) {
        return null;
    }
}

function sf9_normalize_curriculum_level(?string $value): ?string {
    $v = strtolower(trim((string)($value ?? '')));
    if ($v === '') return null;
    if (in_array($v, ['elementary', 'elem', 'grade school'], true)) return 'elementary';
    if (in_array($v, ['jhs', 'junior high school', 'junior high'], true)) return 'jhs';
    if (in_array($v, ['shs', 'senior high school', 'senior high'], true)) return 'shs';
    if (str_contains($v, 'elementary')) return 'elementary';
    if (str_contains($v, 'junior')) return 'jhs';
    if (str_contains($v, 'senior')) return 'shs';
    return null;
}

function sf9_infer_curriculum_level(?string $configured, ?string $educationLevelName, ?string $gradeName): string {
    $fromConfigured = sf9_normalize_curriculum_level($configured);
    if ($fromConfigured !== null) return $fromConfigured;

    $fromEducation = sf9_normalize_curriculum_level($educationLevelName);
    if ($fromEducation !== null) return $fromEducation;

    if (preg_match('/(\d+)/', (string)($gradeName ?? ''), $m)) {
        $gradeNo = (int)$m[1];
        if ($gradeNo >= 11) return 'shs';
        if ($gradeNo >= 7) return 'jhs';
    }

    return 'elementary';
}

function sf9_compute_average(array $values): ?float {
    $numeric = [];
    foreach ($values as $value) {
        if ($value === null || $value === '' || $value === '--') continue;
        if (!is_numeric($value)) continue;
        $numeric[] = (float)$value;
    }
    if (!$numeric) return null;
    return round(array_sum($numeric) / count($numeric), 2);
}

function sf9_has_any_grade(array $row): bool {
    $keys = ['q1', 'q2', 'q3', 'q4', 'final_grade', 'final_rating'];
    foreach ($keys as $k) {
        if (!array_key_exists($k, $row)) continue;
        $v = $row[$k];
        if ($v === null) continue;
        if (is_string($v) && trim($v) === '') continue;
        if ($v === '--') continue;
        if (is_numeric($v)) return true;
        if (is_string($v)) return true;
    }
    return false;
}

function sf9_infer_subject_category(string $subjectName, ?string $subjectCode, string $curriculumLevel): string {
    $name = strtolower(trim($subjectName));
    $code = strtoupper(trim((string)($subjectCode ?? '')));

    if ($curriculumLevel === 'shs') {
        foreach ([
            'work immersion',
            'entrepreneurship',
            'inquiries',
            'investigation',
            'research',
            'specialized',
            'applied'
        ] as $needle) {
            if (str_contains($name, $needle)) {
                return 'Applied and Specialized Subjects';
            }
        }
        return 'Core Subjects';
    }

    if ($curriculumLevel === 'jhs') {
        if (in_array($code, ['MAPEH', 'MUSIC', 'ARTS', 'PE', 'HEALTH'], true)) return 'MAPEH';
        if ($code === 'TLE' || str_contains($name, 'technology and livelihood')) return 'TLE';
        if ($code === 'ESP' || str_contains($name, 'pagpapakatao')) return 'Edukasyon sa Pagpapakatao';
        if ($code === 'AP' || str_contains($name, 'araling panlipunan')) return 'Araling Panlipunan';
        return 'Core Subjects';
    }

    return 'Learning Areas';
}

function sf9_subject_key(?string $subjectCode, ?string $subjectName): string {
    $code = strtoupper(trim((string)($subjectCode ?? '')));
    if ($code !== '') return 'CODE:' . $code;
    $name = strtolower(trim((string)($subjectName ?? '')));
    $name = preg_replace('/\s+/', ' ', $name);
    return 'NAME:' . ($name ?? '');
}

function sf9_pick_best_subject_row(array $candidates, array $gradesByClass, array $finalByClass, array $quarters): array {
    // Prefer the class offering that actually has any quarterly grade or final grade saved.
    $best = $candidates[0];
    $bestScore = -1;
    $bestClassId = (int)($best['class_id'] ?? 0);
    foreach ($candidates as $c) {
        $cid = (int)($c['class_id'] ?? 0);
        $score = 0;
        if ($cid > 0) {
            foreach ($quarters as $q) {
                $gpId = (int)($q['grading_period_id'] ?? 0);
                if ($gpId > 0 && isset($gradesByClass[$cid]) && array_key_exists($gpId, $gradesByClass[$cid])) {
                    $val = $gradesByClass[$cid][$gpId];
                    if ($val !== null && $val !== '') $score += 1;
                }
            }
            if (isset($finalByClass[$cid])) {
                $fg = $finalByClass[$cid]['final_grade'] ?? null;
                if ($fg !== null && $fg !== '') $score += 2;
            }
        }
        // Tie-breaker: when scores are equal, prefer newer class offering (higher class_id).
        // This helps SF9 follow reassigned/latest offerings after updates.
        if ($score > $bestScore || ($score === $bestScore && $cid > $bestClassId)) {
            $bestScore = $score;
            $best = $c;
            $bestClassId = $cid;
        }
    }
    return $best;
}

function sf9_pick_latest_quarter_value(array $candidateClassIds, array $gradesByClass, int $gradingPeriodId) {
    if ($gradingPeriodId <= 0) return null;
    $ids = array_values(array_unique(array_map('intval', $candidateClassIds)));
    $bestRowId = -1;
    $bestValue = null;
    foreach ($ids as $cid) {
        if ($cid <= 0) continue;
        if (!isset($gradesByClass[$cid])) continue;
        if (!array_key_exists($gradingPeriodId, $gradesByClass[$cid])) continue;
        $entry = $gradesByClass[$cid][$gradingPeriodId];
        $rowId = (int)($entry['grade_id'] ?? 0);
        $val = $entry['quarterly_grade'] ?? null;
        if ($val === null || $val === '') continue;
        if ($rowId > $bestRowId) {
            $bestRowId = $rowId;
            $bestValue = $val;
        }
    }
    return $bestValue;
}

function sf9_pick_latest_final_value(array $candidateClassIds, array $finalByClass): array {
    $ids = array_values(array_unique(array_map('intval', $candidateClassIds)));
    $bestRowId = -1;
    $best = ['final_grade' => null, 'remark' => null];
    foreach ($ids as $cid) {
        if ($cid <= 0) continue;
        if (!isset($finalByClass[$cid])) continue;
        $entry = $finalByClass[$cid];
        $fg = $entry['final_grade'] ?? null;
        if ($fg === null || $fg === '') continue;
        $rowId = (int)($entry['final_grade_id'] ?? 0);
        if ($rowId > $bestRowId) {
            $bestRowId = $rowId;
            $best = [
                'final_grade' => $fg,
                'remark' => $entry['remark'] ?? null,
            ];
        }
    }
    return $best;
}

function sf9_observed_values_template(): array {
    return [
        'maka_diyos_1' => [
            'core_value' => 'Maka-Diyos',
            'behavior_statement' => "Expresses one's spiritual beliefs while respecting the spiritual beliefs of others",
            'q1' => '', 'q2' => '', 'q3' => '', 'q4' => ''
        ],
        'maka_diyos_2' => [
            'core_value' => 'Maka-Diyos',
            'behavior_statement' => 'Shows adherence to ethical principles by upholding truth in all undertakings',
            'q1' => '', 'q2' => '', 'q3' => '', 'q4' => ''
        ],
        'makatao_1' => [
            'core_value' => 'Makatao',
            'behavior_statement' => 'Is sensitive to individual, social and cultural differences; resists stereotyping people',
            'q1' => '', 'q2' => '', 'q3' => '', 'q4' => ''
        ],
        'makatao_2' => [
            'core_value' => 'Makatao',
            'behavior_statement' => 'Demonstrates contributions toward solidarity',
            'q1' => '', 'q2' => '', 'q3' => '', 'q4' => ''
        ],
        'makakalikasan_1' => [
            'core_value' => 'Makakalikasan',
            'behavior_statement' => 'Cares for the environment and utilizes resources wisely, judiciously and economically',
            'q1' => '', 'q2' => '', 'q3' => '', 'q4' => ''
        ],
        'makabansa_1' => [
            'core_value' => 'Makabansa',
            'behavior_statement' => 'Demonstrates pride in being a Filipino; exercises the rights and responsibilities of a Filipino citizen',
            'q1' => '', 'q2' => '', 'q3' => '', 'q4' => ''
        ],
        'makabansa_2' => [
            'core_value' => 'Makabansa',
            'behavior_statement' => 'Demonstrates appropriate behavior in carrying out activities in the school, community and country',
            'q1' => '', 'q2' => '', 'q3' => '', 'q4' => ''
        ],
    ];
}

function sf9_months(?int $yearStart, ?int $yearEnd): array {
    $ys = (int)($yearStart ?? 0);
    $ye = (int)($yearEnd ?? 0);
    if ($ys <= 0 || $ye <= 0) {
        $y = (int)date('Y');
        $ys = $y;
        $ye = $y + 1;
    }

    // Matches the common SF9 month header (Jun..Apr + Total)
    return [
        ['label' => 'Jun', 'year' => $ys, 'month' => 6],
        ['label' => 'Jul', 'year' => $ys, 'month' => 7],
        ['label' => 'Aug', 'year' => $ys, 'month' => 8],
        ['label' => 'Sep', 'year' => $ys, 'month' => 9],
        ['label' => 'Oct', 'year' => $ys, 'month' => 10],
        ['label' => 'Nov', 'year' => $ys, 'month' => 11],
        ['label' => 'Dec', 'year' => $ys, 'month' => 12],
        ['label' => 'Jan', 'year' => $ye, 'month' => 1],
        ['label' => 'Feb', 'year' => $ye, 'month' => 2],
        ['label' => 'Mar', 'year' => $ye, 'month' => 3],
        ['label' => 'Apr', 'year' => $ye, 'month' => 4],
    ];
}

function sf9_month_bounds(int $year, int $month): array {
    $start = sprintf('%04d-%02d-01', $year, $month);
    $end = date('Y-m-t', strtotime($start));
    return [$start, $end];
}

function getSchoolSettingsMap(PDO $conn): array {
    $stmt = $conn->prepare('SELECT setting_key, setting_value FROM school_settings WHERE is_deleted = 0');
    $stmt->execute();
    $map = [];
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $r) {
        $k = (string)($r['setting_key'] ?? '');
        if ($k === '') continue;
        $map[$k] = $r['setting_value'] ?? null;
    }
    return $map;
}

function getQuarterGradingPeriods(PDO $conn, int $schoolYearId): array {
    $stmt = $conn->prepare(
        'SELECT grading_period_id, period_name, date_start, date_end
         FROM grading_periods
         WHERE school_year_id = :sy AND is_deleted = 0'
    );
    $stmt->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Prefer date ordering; fall back to a quarter-name heuristic.
    usort($rows, function ($a, $b) {
        $da = (string)($a['date_start'] ?? '');
        $db = (string)($b['date_start'] ?? '');
        if ($da !== '' && $db !== '') {
            if ($da === $db) return ((int)$a['grading_period_id']) <=> ((int)$b['grading_period_id']);
            return strcmp($da, $db);
        }
        $na = strtolower((string)($a['period_name'] ?? ''));
        $nb = strtolower((string)($b['period_name'] ?? ''));
        $qa = preg_match('/\b1st\b|\bfirst\b|q1|quarter\s*1/', $na) ? 1
            : (preg_match('/\b2nd\b|\bsecond\b|q2|quarter\s*2/', $na) ? 2
                : (preg_match('/\b3rd\b|\bthird\b|q3|quarter\s*3/', $na) ? 3
                    : (preg_match('/\b4th\b|\bfourth\b|q4|quarter\s*4/', $na) ? 4 : 99)));
        $qb = preg_match('/\b1st\b|\bfirst\b|q1|quarter\s*1/', $nb) ? 1
            : (preg_match('/\b2nd\b|\bsecond\b|q2|quarter\s*2/', $nb) ? 2
                : (preg_match('/\b3rd\b|\bthird\b|q3|quarter\s*3/', $nb) ? 3
                    : (preg_match('/\b4th\b|\bfourth\b|q4|quarter\s*4/', $nb) ? 4 : 99)));
        if ($qa === $qb) return ((int)$a['grading_period_id']) <=> ((int)$b['grading_period_id']);
        return $qa <=> $qb;
    });

    $out = [];
    $q = 1;
    foreach ($rows as $r) {
        if ($q > 4) break;
        $out[] = [
            'quarter' => $q,
            'grading_period_id' => (int)($r['grading_period_id'] ?? 0),
            'period_name' => (string)($r['period_name'] ?? ''),
            'date_start' => $r['date_start'] ?? null,
            'date_end' => $r['date_end'] ?? null,
        ];
        $q++;
    }
    while (count($out) < 4) {
        $out[] = [
            'quarter' => count($out) + 1,
            'grading_period_id' => 0,
            'period_name' => '',
            'date_start' => null,
            'date_end' => null,
        ];
    }
    return $out;
}

function populateReportCardSnapshot(PDO $conn, int $reportCardId): void {
    $stmt = $conn->prepare(
        "SELECT rc.report_card_id, rc.enrollment_id, rc.grading_period_id,
                e.school_year_id, e.section_id,
                l.lrn,
                CONCAT(l.last_name, ', ', l.first_name,
                    CASE WHEN l.middle_name IS NULL OR l.middle_name = '' THEN '' ELSE CONCAT(' ', l.middle_name) END,
                    CASE WHEN l.name_extension IS NULL OR l.name_extension = '' THEN '' ELSE CONCAT(' ', l.name_extension) END
                ) AS learner_full_name,
                gl.grade_name,
                sec.section_name,
                sy.year_label
         FROM report_cards rc
         JOIN enrollments e ON e.enrollment_id = rc.enrollment_id
         JOIN learners l ON l.learner_id = e.learner_id
         LEFT JOIN grade_levels gl ON gl.grade_level_id = e.grade_level_id
         LEFT JOIN sections sec ON sec.section_id = e.section_id
         LEFT JOIN school_years sy ON sy.school_year_id = e.school_year_id
         WHERE rc.report_card_id = :report_card_id AND rc.is_deleted = 0
         LIMIT 1"
    );
    $stmt->bindValue(':report_card_id', $reportCardId, PDO::PARAM_INT);
    $stmt->execute();
    $header = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$header) {
        throw new Exception('Report card not found');
    }

    $gaStmt = $conn->prepare('SELECT general_average FROM general_averages WHERE enrollment_id = :enrollment_id AND is_deleted = 0 LIMIT 1');
    $gaStmt->bindValue(':enrollment_id', (int)$header['enrollment_id'], PDO::PARAM_INT);
    $gaStmt->execute();
    $generalAverage = $gaStmt->fetchColumn();

    $attStmt = $conn->prepare(
        "SELECT status, COUNT(*) AS cnt
         FROM attendance
         WHERE enrollment_id = :enrollment_id
           AND grading_period_id = :grading_period_id
           AND class_id = 0
           AND is_deleted = 0
         GROUP BY status"
    );
    $attStmt->bindValue(':enrollment_id', (int)$header['enrollment_id'], PDO::PARAM_INT);
    $attStmt->bindValue(':grading_period_id', (int)$header['grading_period_id'], PDO::PARAM_INT);
    $attStmt->execute();
    $attCounts = ['Present' => 0, 'Absent' => 0, 'Late' => 0];
    foreach ($attStmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $status = (string)$row['status'];
        if (array_key_exists($status, $attCounts)) {
            $attCounts[$status] = (int)$row['cnt'];
        }
    }

    $upd = $conn->prepare(
        'UPDATE report_cards
         SET learner_name = :learner_name,
             lrn = :lrn,
             grade_level_name = :grade_level_name,
             section_name = :section_name,
             school_year_label = :school_year_label,
             general_average = :general_average,
             days_present = :days_present,
             days_absent = :days_absent,
             days_late = :days_late
         WHERE report_card_id = :report_card_id'
    );
    $upd->bindValue(':report_card_id', $reportCardId, PDO::PARAM_INT);
    $upd->bindValue(':learner_name', $header['learner_full_name']);
    $upd->bindValue(':lrn', $header['lrn']);
    $upd->bindValue(':grade_level_name', $header['grade_name']);
    $upd->bindValue(':section_name', $header['section_name']);
    $upd->bindValue(':school_year_label', $header['year_label']);
    if ($generalAverage === false || $generalAverage === null || $generalAverage === '') {
        $upd->bindValue(':general_average', null, PDO::PARAM_NULL);
    } else {
        $upd->bindValue(':general_average', $generalAverage);
    }
    $upd->bindValue(':days_present', $attCounts['Present'], PDO::PARAM_INT);
    $upd->bindValue(':days_absent', $attCounts['Absent'], PDO::PARAM_INT);
    $upd->bindValue(':days_late', $attCounts['Late'], PDO::PARAM_INT);
    $upd->execute();

    // Rebuild per-subject snapshot rows
    $del = $conn->prepare('DELETE FROM report_card_grades WHERE report_card_id = :report_card_id');
    $del->bindValue(':report_card_id', $reportCardId, PDO::PARAM_INT);
    $del->execute();

    $gradesStmt = $conn->prepare(
        "SELECT s.subject_name, s.subject_code,
                g.quarterly_grade,
                fg.final_grade,
                fg.remark
         FROM class_offerings co
         JOIN subjects s ON s.subject_id = co.subject_id
         LEFT JOIN grades g
                ON g.enrollment_id = :enrollment_id
               AND g.class_id = co.class_id
               AND g.grading_period_id = :grading_period_id
               AND g.is_deleted = 0
         LEFT JOIN final_grades fg
                ON fg.enrollment_id = :enrollment_id
               AND fg.class_id = co.class_id
               AND fg.is_deleted = 0
         WHERE co.is_deleted = 0
           AND co.section_id = :section_id
           AND co.school_year_id = :school_year_id
           AND s.is_deleted = 0
         ORDER BY s.subject_name"
    );
    $gradesStmt->bindValue(':enrollment_id', (int)$header['enrollment_id'], PDO::PARAM_INT);
    $gradesStmt->bindValue(':grading_period_id', (int)$header['grading_period_id'], PDO::PARAM_INT);
    $gradesStmt->bindValue(':section_id', (int)$header['section_id'], PDO::PARAM_INT);
    $gradesStmt->bindValue(':school_year_id', (int)$header['school_year_id'], PDO::PARAM_INT);
    $gradesStmt->execute();
    $rows = $gradesStmt->fetchAll(PDO::FETCH_ASSOC);

    if ($rows) {
        $ins = $conn->prepare(
            'INSERT INTO report_card_grades (report_card_id, subject_name, subject_code, quarterly_grade, final_grade, remark)
             VALUES (:report_card_id, :subject_name, :subject_code, :quarterly_grade, :final_grade, :remark)'
        );
        foreach ($rows as $r) {
            $ins->bindValue(':report_card_id', $reportCardId, PDO::PARAM_INT);
            $ins->bindValue(':subject_name', $r['subject_name']);
            $ins->bindValue(':subject_code', $r['subject_code']);

            if ($r['quarterly_grade'] === null || $r['quarterly_grade'] === '') {
                $ins->bindValue(':quarterly_grade', null, PDO::PARAM_NULL);
            } else {
                $ins->bindValue(':quarterly_grade', $r['quarterly_grade']);
            }
            if ($r['final_grade'] === null || $r['final_grade'] === '') {
                $ins->bindValue(':final_grade', null, PDO::PARAM_NULL);
            } else {
                $ins->bindValue(':final_grade', $r['final_grade']);
            }
            if ($r['remark'] === null || $r['remark'] === '') {
                $ins->bindValue(':remark', null, PDO::PARAM_NULL);
            } else {
                $ins->bindValue(':remark', $r['remark']);
            }

            $ins->execute();
        }
    }
}

function getAllReportCards(PDO $conn): void {
    $sql = "SELECT rc.report_card_id, rc.enrollment_id, rc.grading_period_id, rc.generated_at, rc.generated_by, rc.file_path,
                   CONCAT(l.last_name, ', ', l.first_name) AS learner_name,
                   gp.period_name,
                   u.username AS generated_by_name
            FROM report_cards rc
            JOIN enrollments e ON rc.enrollment_id = e.enrollment_id
            JOIN learners l ON e.learner_id = l.learner_id
            JOIN grading_periods gp ON rc.grading_period_id = gp.grading_period_id
            LEFT JOIN users u ON rc.generated_by = u.user_id
            WHERE rc.is_deleted = 0
            ORDER BY rc.report_card_id DESC";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function getSF9Data(PDO $conn): void {
    $reportCardId = (int)($_GET['report_card_id'] ?? 0);
    if ($reportCardId <= 0) {
        respond(['success' => false, 'message' => 'report_card_id is required'], 422);
    }

    $stmt = $conn->prepare(
        "SELECT rc.report_card_id,
                rc.enrollment_id,
                e.school_year_id,
                e.section_id,
                e.grade_level_id,
                l.lrn,
                l.first_name,
                l.middle_name,
                l.last_name,
                l.name_extension,
                l.gender,
                l.date_of_birth,
                gl.grade_name,
                sec.section_name,
                sec.adviser_id,
                sy.year_label,
                sy.year_start,
                sy.year_end
         FROM report_cards rc
         JOIN enrollments e ON e.enrollment_id = rc.enrollment_id
         JOIN learners l ON l.learner_id = e.learner_id
         LEFT JOIN grade_levels gl ON gl.grade_level_id = e.grade_level_id
         LEFT JOIN sections sec ON sec.section_id = e.section_id
         LEFT JOIN school_years sy ON sy.school_year_id = e.school_year_id
         WHERE rc.report_card_id = :rid AND rc.is_deleted = 0
         LIMIT 1"
    );
    $stmt->bindValue(':rid', $reportCardId, PDO::PARAM_INT);
    $stmt->execute();
    $h = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$h) {
        respond(['success' => false, 'message' => 'Report card not found'], 404);
    }
    // Keep persisted snapshot in sync whenever SF9 is opened.
    try {
        populateReportCardSnapshot($conn, $reportCardId);
    } catch (Throwable $_) {
        // Non-fatal: SF9 should still render from live tables.
    }

    $schoolYearId = (int)($h['school_year_id'] ?? 0);
    $sectionId = (int)($h['section_id'] ?? 0);
    $enrollmentId = (int)($h['enrollment_id'] ?? 0);

    $learnerName = formatPersonName($h['first_name'] ?? null, $h['middle_name'] ?? null, $h['last_name'] ?? null, $h['name_extension'] ?? null);
    $age = computeAge($h['date_of_birth'] ?? null, null);

    $adviserName = '';
    $adviserId = (int)($h['adviser_id'] ?? 0);
    if ($adviserId > 0) {
        $a = $conn->prepare('SELECT first_name, middle_name, last_name, name_extension FROM employees WHERE employee_id = :eid AND is_deleted = 0 LIMIT 1');
        $a->bindValue(':eid', $adviserId, PDO::PARAM_INT);
        $a->execute();
        $ar = $a->fetch(PDO::FETCH_ASSOC);
        if ($ar) {
            $adviserName = formatPersonName($ar['first_name'] ?? null, $ar['middle_name'] ?? null, $ar['last_name'] ?? null, $ar['name_extension'] ?? null);
        }
    }

    $settings = getSchoolSettingsMap($conn);
    // Default logo for SF9 header (frontend may override if needed)
    $defaultLogoUrl = '/deped_capstone2/assets/img/logo/logo.jpg';

    $quarters = $schoolYearId > 0 ? getQuarterGradingPeriods($conn, $schoolYearId) : [
        ['quarter' => 1, 'grading_period_id' => 0, 'period_name' => ''],
        ['quarter' => 2, 'grading_period_id' => 0, 'period_name' => ''],
        ['quarter' => 3, 'grading_period_id' => 0, 'period_name' => ''],
        ['quarter' => 4, 'grading_period_id' => 0, 'period_name' => ''],
    ];
    $quarterIds = array_values(array_filter(array_map(fn($q) => (int)($q['grading_period_id'] ?? 0), $quarters), fn($id) => $id > 0));

    // Subject/class offerings for the enrollment's section + school year
    $sub = $conn->prepare(
        'SELECT co.class_id, s.subject_name, s.subject_code
         FROM class_offerings co
         JOIN subjects s ON s.subject_id = co.subject_id
         WHERE s.is_deleted = 0
           AND co.section_id = :sid
           AND co.school_year_id = :sy
         ORDER BY s.subject_name'
    );
    $sub->bindValue(':sid', $sectionId, PDO::PARAM_INT);
    $sub->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
    $sub->execute();
    $subjects = $sub->fetchAll(PDO::FETCH_ASSOC) ?: [];
    $classIds = array_values(array_filter(array_map(fn($r) => (int)($r['class_id'] ?? 0), $subjects), fn($id) => $id > 0));

    $gradesByClass = []; // [class_id][grading_period_id] = ['grade_id'=>..,'quarterly_grade'=>..]
    if ($enrollmentId > 0 && $classIds && $quarterIds) {
        $inClass = implode(',', array_fill(0, count($classIds), '?'));
        $inQ = implode(',', array_fill(0, count($quarterIds), '?'));
        $sql = "SELECT g.grade_id, g.class_id, g.grading_period_id, g.quarterly_grade
                FROM grades g
                JOIN (
                    SELECT class_id, grading_period_id, MAX(grade_id) AS latest_grade_id
                    FROM grades
                    WHERE enrollment_id = ?
                      AND is_deleted = 0
                      AND class_id IN ({$inClass})
                      AND grading_period_id IN ({$inQ})
                    GROUP BY class_id, grading_period_id
                ) pick ON pick.latest_grade_id = g.grade_id";
        $g = $conn->prepare($sql);
        $i = 1;
        $g->bindValue($i++, $enrollmentId, PDO::PARAM_INT);
        foreach ($classIds as $cid) $g->bindValue($i++, $cid, PDO::PARAM_INT);
        foreach ($quarterIds as $qid) $g->bindValue($i++, $qid, PDO::PARAM_INT);
        $g->execute();
        foreach ($g->fetchAll(PDO::FETCH_ASSOC) as $r) {
            $cid = (int)($r['class_id'] ?? 0);
            $qid = (int)($r['grading_period_id'] ?? 0);
            if ($cid <= 0 || $qid <= 0) continue;
            if (!isset($gradesByClass[$cid])) $gradesByClass[$cid] = [];
            $gradesByClass[$cid][$qid] = [
                'grade_id' => (int)($r['grade_id'] ?? 0),
                'quarterly_grade' => $r['quarterly_grade'],
            ];
        }
    }

    $finalByClass = []; // [class_id] = ['final_grade_id'=>..,'final_grade'=>...,'remark'=>...]
    if ($enrollmentId > 0 && $classIds) {
        $inClass = implode(',', array_fill(0, count($classIds), '?'));
        $sql = "SELECT fg.final_grade_id, fg.class_id, fg.final_grade, fg.remark
                FROM final_grades fg
                JOIN (
                    SELECT class_id, MAX(final_grade_id) AS latest_final_grade_id
                    FROM final_grades
                    WHERE enrollment_id = ?
                      AND is_deleted = 0
                      AND class_id IN ({$inClass})
                    GROUP BY class_id
                ) pick ON pick.latest_final_grade_id = fg.final_grade_id";
        $fg = $conn->prepare($sql);
        $i = 1;
        $fg->bindValue($i++, $enrollmentId, PDO::PARAM_INT);
        foreach ($classIds as $cid) $fg->bindValue($i++, $cid, PDO::PARAM_INT);
        $fg->execute();
        foreach ($fg->fetchAll(PDO::FETCH_ASSOC) as $r) {
            $cid = (int)($r['class_id'] ?? 0);
            if ($cid <= 0) continue;
            $finalByClass[$cid] = [
                'final_grade_id' => (int)($r['final_grade_id'] ?? 0),
                'final_grade' => $r['final_grade'],
                'remark' => $r['remark'],
            ];
        }
    }

    // Deduplicate learning areas so one subject appears once.
    if ($subjects) {
        $bucketed = [];
        foreach ($subjects as $s) {
            $key = sf9_subject_key($s['subject_code'] ?? null, $s['subject_name'] ?? null);
            if (!isset($bucketed[$key])) $bucketed[$key] = [];
            $bucketed[$key][] = $s;
        }
        $deduped = [];
        foreach ($bucketed as $candidates) {
            $best = sf9_pick_best_subject_row($candidates, $gradesByClass, $finalByClass, $quarters);
            $best['_candidate_class_ids'] = array_values(array_filter(array_map(
                fn($x) => (int)($x['class_id'] ?? 0),
                $candidates
            ), fn($id) => $id > 0));
            $deduped[] = $best;
        }
        usort($deduped, fn($a, $b) => strcmp((string)($a['subject_name'] ?? ''), (string)($b['subject_name'] ?? '')));
        $subjects = $deduped;
    }

    $gradeRows = [];
    foreach ($subjects as $s) {
        $cid = (int)($s['class_id'] ?? 0);
        $row = [
            'class_id' => $cid,
            'subject_name' => (string)($s['subject_name'] ?? ''),
            'subject_code' => $s['subject_code'] ?? null,
            'q1' => null,
            'q2' => null,
            'q3' => null,
            'q4' => null,
            'final_grade' => null,
            'remark' => null,
        ];
        if ($cid > 0) {
            $candidateClassIds = $s['_candidate_class_ids'] ?? [$cid];
            if (!is_array($candidateClassIds) || !$candidateClassIds) {
                $candidateClassIds = [$cid];
            }
            foreach ($quarters as $q) {
                $qNo = (int)($q['quarter'] ?? 0);
                $gpId = (int)($q['grading_period_id'] ?? 0);
                if ($qNo >= 1 && $qNo <= 4 && $gpId > 0) {
                    $row['q' . $qNo] = sf9_pick_latest_quarter_value($candidateClassIds, $gradesByClass, $gpId);
                }
            }
            $latestFinal = sf9_pick_latest_final_value($candidateClassIds, $finalByClass);
            $row['final_grade'] = $latestFinal['final_grade'];
            $row['remark'] = $latestFinal['remark'];
        }
        $computedFinal = $row['final_grade'];
        if ($computedFinal === null || $computedFinal === '') {
            $computedFinal = sf9_compute_average([$row['q1'], $row['q2'], $row['q3'], $row['q4']]);
        } elseif (is_numeric($computedFinal)) {
            $computedFinal = round((float)$computedFinal, 2);
        }
        $row['final_grade'] = $computedFinal;
        if ($computedFinal !== null) {
            $row['remark'] = $computedFinal >= 75 ? 'Passed' : 'Failed';
        }
        $gradeRows[] = $row;
    }

    // Remove rows that are completely empty (all quarters + final are blank).
    // This avoids showing stale/legacy offerings with no encoded grades.
    $gradeRows = array_values(array_filter($gradeRows, 'sf9_has_any_grade'));

    $gaStmt = $conn->prepare('SELECT general_average FROM general_averages WHERE enrollment_id = :eid AND is_deleted = 0 LIMIT 1');
    $gaStmt->bindValue(':eid', $enrollmentId, PDO::PARAM_INT);
    $gaStmt->execute();
    $generalAverage = $gaStmt->fetchColumn();
    if ($generalAverage === false || $generalAverage === null || $generalAverage === '') {
        $generalAverage = null;
    }

    // Attendance record (monthly): prefer stored summaries, fallback to computed from raw attendance.
    $yearStart = isset($h['year_start']) ? (int)$h['year_start'] : null;
    $yearEnd = isset($h['year_end']) ? (int)$h['year_end'] : null;

    $stored = [];
    if ($enrollmentId > 0 && $schoolYearId > 0) {
        $as = $conn->prepare(
            'SELECT month_no, total_school_days, days_present, days_absent, days_late, days_excused
             FROM attendance_monthly_summaries
             WHERE enrollment_id = :eid AND school_year_id = :sy AND is_deleted = 0'
        );
        $as->bindValue(':eid', $enrollmentId, PDO::PARAM_INT);
        $as->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
        $as->execute();
        foreach ($as->fetchAll(PDO::FETCH_ASSOC) as $r) {
            $m = (int)($r['month_no'] ?? 0);
            if ($m < 1 || $m > 12) continue;
            $stored[$m] = $r;
        }
    }

    $months = sf9_months($yearStart, $yearEnd);
    $attendanceMonths = [];
    $totSchool = 0;
    $totPresent = 0;
    $totAbsent = 0;
    $totLate = 0;

    foreach ($months as $m) {
        $monthNo = (int)$m['month'];
        $schoolDays = null;
        $present = null;
        $absent = null;
        $late = null;

        if (isset($stored[$monthNo])) {
            $row = $stored[$monthNo];
            $schoolDays = (int)($row['total_school_days'] ?? 0);
            $present = (int)($row['days_present'] ?? 0) + (int)($row['days_excused'] ?? 0);
            $absent = (int)($row['days_absent'] ?? 0);
            $late = (int)($row['days_late'] ?? 0);
        } else if ($enrollmentId > 0) {
            [$start, $end] = sf9_month_bounds((int)$m['year'], $monthNo);
            $att = $conn->prepare(
                "SELECT
                    SUM(a.status = 'Present') AS days_present,
                    SUM(a.status = 'Absent') AS days_absent,
                    SUM(a.status = 'Late') AS days_late,
                    SUM(a.status = 'Excused') AS days_excused
                 FROM attendance a
                 WHERE a.enrollment_id = :eid
                   AND a.is_deleted = 0
                   AND a.class_id = 0
                   AND a.attendance_date BETWEEN :start_date AND :end_date"
            );
            $att->bindValue(':eid', $enrollmentId, PDO::PARAM_INT);
            $att->bindValue(':start_date', $start);
            $att->bindValue(':end_date', $end);
            $att->execute();
            $ar = $att->fetch(PDO::FETCH_ASSOC) ?: [];
            $present = (int)($ar['days_present'] ?? 0) + (int)($ar['days_excused'] ?? 0);
            $absent = (int)($ar['days_absent'] ?? 0);
            $late = (int)($ar['days_late'] ?? 0);
        }

        if ($schoolDays === null) {
            // Weekday count as safe default.
            $schoolDays = 0;
            try {
                $start = new DateTime(sprintf('%04d-%02d-01', (int)$m['year'], $monthNo));
                $end = new DateTime($start->format('Y-m-t'));
                $end = $end->modify('+1 day');
                $count = 0;
                for ($d = clone $start; $d < $end; $d->modify('+1 day')) {
                    $dow = (int)$d->format('N');
                    if ($dow >= 1 && $dow <= 5) $count++;
                }
                $schoolDays = $count;
            } catch (Throwable $_) {
                $schoolDays = 0;
            }
        }

        $attendanceMonths[] = [
            'label' => $m['label'],
            'month_no' => $monthNo,
            'year' => (int)$m['year'],
            'total_school_days' => $schoolDays,
            'days_present' => $present,
            'days_absent' => $absent,
            'times_tardy' => $late,
        ];

        $totSchool += (int)$schoolDays;
        $totPresent += (int)($present ?? 0);
        $totAbsent += (int)($absent ?? 0);
        $totLate += (int)($late ?? 0);
    }

    $payload = [
        'success' => true,
        'report_card_id' => $reportCardId,
        'enrollment_id' => $enrollmentId,
        'learner' => [
            'name' => $learnerName,
            'lrn' => $h['lrn'] ?? null,
            'sex' => $h['gender'] ?? null,
            'date_of_birth' => $h['date_of_birth'] ?? null,
            'age' => $age,
        ],
        'enrollment' => [
            'grade_level' => $h['grade_name'] ?? null,
            'section' => $h['section_name'] ?? null,
            'school_year' => $h['year_label'] ?? null,
            'school_year_id' => $schoolYearId,
            'section_id' => $sectionId,
        ],
        'school' => [
            'school_id' => $settings['school_id'] ?? ($settings['schoolId'] ?? null),
            'school_name' => $settings['school_name'] ?? ($settings['schoolName'] ?? null),
            'region' => $settings['region'] ?? ($settings['school_region'] ?? null),
            'division' => $settings['division'] ?? ($settings['school_division'] ?? null),
            'district' => $settings['district'] ?? ($settings['school_district'] ?? null),
            'school_head' => $settings['school_head'] ?? ($settings['school_head_name'] ?? ($settings['principal_name'] ?? null)),
            'logo_url' => $settings['logo_url'] ?? ($settings['school_logo_url'] ?? $defaultLogoUrl),
            'deped_logo_url' => $settings['deped_logo_url'] ?? '/deped_capstone2/assets/img/logo/pngegg.png',
        ],
        'adviser' => [
            'name' => $adviserName,
        ],
        'quarters' => $quarters,
        'grades' => $gradeRows,
        'general_average' => $generalAverage,
        'core_values' => sf9_observed_values_template(),
        'attendance' => [
            'months' => $attendanceMonths,
            'totals' => [
                'total_school_days' => $totSchool,
                'days_present' => $totPresent,
                'days_absent' => $totAbsent,
                'times_tardy' => $totLate,
            ]
        ],
    ];

    respond($payload);
}

function getSF9DataByEnrollment(PDO $conn): void {
    $enrollmentId = (int)($_GET['enrollment_id'] ?? 0);
    if ($enrollmentId <= 0) {
        respond(['success' => false, 'message' => 'enrollment_id is required'], 422);
    }

    $stmt = $conn->prepare(
        "SELECT e.enrollment_id,
                e.school_year_id,
                e.section_id,
                e.grade_level_id,
                l.lrn,
                l.first_name,
                l.middle_name,
                l.last_name,
                l.name_extension,
                l.gender,
                l.date_of_birth,
                gl.grade_name,
                l.mother_tongue,
                el.level_name AS education_level_name,
                sec.section_name,
                sec.adviser_id,
                sy.year_label,
                sy.year_start,
                sy.year_end
         FROM enrollments e
         JOIN learners l ON l.learner_id = e.learner_id
         LEFT JOIN grade_levels gl ON gl.grade_level_id = e.grade_level_id
         LEFT JOIN education_levels el ON el.education_level_id = gl.education_level_id
         LEFT JOIN sections sec ON sec.section_id = e.section_id
         LEFT JOIN school_years sy ON sy.school_year_id = e.school_year_id
         WHERE e.enrollment_id = :eid AND e.is_deleted = 0
         LIMIT 1"
    );
    $stmt->bindValue(':eid', $enrollmentId, PDO::PARAM_INT);
    $stmt->execute();
    $h = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$h) {
        respond(['success' => false, 'message' => 'Enrollment not found'], 404);
    }

    $schoolYearId = (int)($h['school_year_id'] ?? 0);
    $sectionId = (int)($h['section_id'] ?? 0);

    $learnerName = formatPersonName($h['first_name'] ?? null, $h['middle_name'] ?? null, $h['last_name'] ?? null, $h['name_extension'] ?? null);
    $age = computeAge($h['date_of_birth'] ?? null, null);

    $adviserName = '';
    $adviserId = (int)($h['adviser_id'] ?? 0);
    if ($adviserId > 0) {
        $a = $conn->prepare('SELECT first_name, middle_name, last_name, name_extension FROM employees WHERE employee_id = :eid AND is_deleted = 0 LIMIT 1');
        $a->bindValue(':eid', $adviserId, PDO::PARAM_INT);
        $a->execute();
        $ar = $a->fetch(PDO::FETCH_ASSOC);
        if ($ar) {
            $adviserName = formatPersonName($ar['first_name'] ?? null, $ar['middle_name'] ?? null, $ar['last_name'] ?? null, $ar['name_extension'] ?? null);
        }
    }

    $settings = getSchoolSettingsMap($conn);
    $defaultLogoUrl = '/deped_capstone2/assets/img/logo/logo.jpg';
    $curriculumLevel = sf9_infer_curriculum_level(
        $settings['curriculum_level'] ?? null,
        $h['education_level_name'] ?? null,
        $h['grade_name'] ?? null
    );
    $quarters = $schoolYearId > 0 ? getQuarterGradingPeriods($conn, $schoolYearId) : [
        ['quarter' => 1, 'grading_period_id' => 0, 'period_name' => ''],
        ['quarter' => 2, 'grading_period_id' => 0, 'period_name' => ''],
        ['quarter' => 3, 'grading_period_id' => 0, 'period_name' => ''],
        ['quarter' => 4, 'grading_period_id' => 0, 'period_name' => ''],
    ];
    $quarterIds = array_values(array_filter(array_map(fn($q) => (int)($q['grading_period_id'] ?? 0), $quarters), fn($id) => $id > 0));

    $sub = $conn->prepare(
        'SELECT co.class_id, s.subject_name, s.subject_code
         FROM class_offerings co
         JOIN subjects s ON s.subject_id = co.subject_id
         WHERE s.is_deleted = 0
           AND co.section_id = :sid
           AND co.school_year_id = :sy
         ORDER BY s.subject_name'
    );
    $sub->bindValue(':sid', $sectionId, PDO::PARAM_INT);
    $sub->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
    $sub->execute();
    $subjects = $sub->fetchAll(PDO::FETCH_ASSOC) ?: [];
    $classIds = array_values(array_filter(array_map(fn($r) => (int)($r['class_id'] ?? 0), $subjects), fn($id) => $id > 0));

    $gradesByClass = []; // [class_id][grading_period_id] = ['grade_id'=>..,'quarterly_grade'=>..]
    if ($enrollmentId > 0 && $classIds && $quarterIds) {
        $inClass = implode(',', array_fill(0, count($classIds), '?'));
        $inQ = implode(',', array_fill(0, count($quarterIds), '?'));
        $sql = "SELECT g.grade_id, g.class_id, g.grading_period_id, g.quarterly_grade
                FROM grades g
                JOIN (
                    SELECT class_id, grading_period_id, MAX(grade_id) AS latest_grade_id
                    FROM grades
                    WHERE enrollment_id = ?
                      AND is_deleted = 0
                      AND class_id IN ({$inClass})
                      AND grading_period_id IN ({$inQ})
                    GROUP BY class_id, grading_period_id
                ) pick ON pick.latest_grade_id = g.grade_id";
        $g = $conn->prepare($sql);
        $i = 1;
        $g->bindValue($i++, $enrollmentId, PDO::PARAM_INT);
        foreach ($classIds as $cid) $g->bindValue($i++, $cid, PDO::PARAM_INT);
        foreach ($quarterIds as $qid) $g->bindValue($i++, $qid, PDO::PARAM_INT);
        $g->execute();
        foreach ($g->fetchAll(PDO::FETCH_ASSOC) as $r) {
            $cid = (int)($r['class_id'] ?? 0);
            $qid = (int)($r['grading_period_id'] ?? 0);
            if ($cid <= 0 || $qid <= 0) continue;
            if (!isset($gradesByClass[$cid])) $gradesByClass[$cid] = [];
            $gradesByClass[$cid][$qid] = [
                'grade_id' => (int)($r['grade_id'] ?? 0),
                'quarterly_grade' => $r['quarterly_grade'],
            ];
        }
    }

    $finalByClass = []; // [class_id] = ['final_grade_id'=>..,'final_grade'=>...,'remark'=>...]
    if ($enrollmentId > 0 && $classIds) {
        $inClass = implode(',', array_fill(0, count($classIds), '?'));
        $sql = "SELECT fg.final_grade_id, fg.class_id, fg.final_grade, fg.remark
                FROM final_grades fg
                JOIN (
                    SELECT class_id, MAX(final_grade_id) AS latest_final_grade_id
                    FROM final_grades
                    WHERE enrollment_id = ?
                      AND is_deleted = 0
                      AND class_id IN ({$inClass})
                    GROUP BY class_id
                ) pick ON pick.latest_final_grade_id = fg.final_grade_id";
        $fg = $conn->prepare($sql);
        $i = 1;
        $fg->bindValue($i++, $enrollmentId, PDO::PARAM_INT);
        foreach ($classIds as $cid) $fg->bindValue($i++, $cid, PDO::PARAM_INT);
        $fg->execute();
        foreach ($fg->fetchAll(PDO::FETCH_ASSOC) as $r) {
            $cid = (int)($r['class_id'] ?? 0);
            if ($cid <= 0) continue;
            $finalByClass[$cid] = [
                'final_grade_id' => (int)($r['final_grade_id'] ?? 0),
                'final_grade' => $r['final_grade'],
                'remark' => $r['remark'],
            ];
        }
    }

    // Deduplicate learning areas (some sections may have multiple class offerings per subject)
    if ($subjects) {
        $bucketed = [];
        foreach ($subjects as $s) {
            $key = sf9_subject_key($s['subject_code'] ?? null, $s['subject_name'] ?? null);
            if (!isset($bucketed[$key])) $bucketed[$key] = [];
            $bucketed[$key][] = $s;
        }
        $deduped = [];
        foreach ($bucketed as $candidates) {
            $best = sf9_pick_best_subject_row($candidates, $gradesByClass, $finalByClass, $quarters);
            $best['_candidate_class_ids'] = array_values(array_filter(array_map(
                fn($x) => (int)($x['class_id'] ?? 0),
                $candidates
            ), fn($id) => $id > 0));
            $deduped[] = $best;
        }
        // Stable ordering by subject name after dedupe
        usort($deduped, fn($a, $b) => strcmp((string)($a['subject_name'] ?? ''), (string)($b['subject_name'] ?? '')));
        $subjects = $deduped;
    }

    $gradeRows = [];
    foreach ($subjects as $s) {
        $cid = (int)($s['class_id'] ?? 0);
        $row = [
            'class_id' => $cid,
            'subject_name' => (string)($s['subject_name'] ?? ''),
            'subject_code' => $s['subject_code'] ?? null,
            'category' => sf9_infer_subject_category((string)($s['subject_name'] ?? ''), $s['subject_code'] ?? null, $curriculumLevel),
            'q1' => null,
            'q2' => null,
            'q3' => null,
            'q4' => null,
            'final_grade' => null,
            'final_rating' => null,
            'remark' => null,
            'remarks' => null,
        ];
        if ($cid > 0) {
            $candidateClassIds = $s['_candidate_class_ids'] ?? [$cid];
            if (!is_array($candidateClassIds) || !$candidateClassIds) {
                $candidateClassIds = [$cid];
            }
            foreach ($quarters as $q) {
                $qNo = (int)($q['quarter'] ?? 0);
                $gpId = (int)($q['grading_period_id'] ?? 0);
                if ($qNo >= 1 && $qNo <= 4 && $gpId > 0) {
                    $row['q' . $qNo] = sf9_pick_latest_quarter_value($candidateClassIds, $gradesByClass, $gpId);
                }
            }
            $latestFinal = sf9_pick_latest_final_value($candidateClassIds, $finalByClass);
            $row['final_grade'] = $latestFinal['final_grade'];
            $row['remark'] = $latestFinal['remark'];
        }
        $computedFinal = $row['final_grade'];
        if ($computedFinal === null || $computedFinal === '') {
            $computedFinal = sf9_compute_average([$row['q1'], $row['q2'], $row['q3'], $row['q4']]);
        } elseif (is_numeric($computedFinal)) {
            $computedFinal = round((float)$computedFinal, 2);
        }
        $row['final_grade'] = $computedFinal;
        $row['final_rating'] = $computedFinal;
        if ($computedFinal !== null) {
            $row['remark'] = $computedFinal >= 75 ? 'Passed' : 'Failed';
            $row['remarks'] = $row['remark'];
        }
        $gradeRows[] = $row;
    }

    // Remove rows that are completely empty (all quarters + final are blank).
    // This avoids showing stale/legacy offerings with no encoded grades.
    $gradeRows = array_values(array_filter($gradeRows, 'sf9_has_any_grade'));

    $gaStmt = $conn->prepare('SELECT general_average FROM general_averages WHERE enrollment_id = :eid AND is_deleted = 0 LIMIT 1');
    $gaStmt->bindValue(':eid', $enrollmentId, PDO::PARAM_INT);
    $gaStmt->execute();
    $generalAverage = $gaStmt->fetchColumn();
    if ($generalAverage === false || $generalAverage === null || $generalAverage === '') {
        $generalAverage = null;
    }

    $yearStart = isset($h['year_start']) ? (int)$h['year_start'] : null;
    $yearEnd = isset($h['year_end']) ? (int)$h['year_end'] : null;

    $stored = [];
    if ($enrollmentId > 0 && $schoolYearId > 0) {
        $as = $conn->prepare(
            'SELECT month_no, total_school_days, days_present, days_absent, days_late, days_excused
             FROM attendance_monthly_summaries
             WHERE enrollment_id = :eid AND school_year_id = :sy AND is_deleted = 0'
        );
        $as->bindValue(':eid', $enrollmentId, PDO::PARAM_INT);
        $as->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
        $as->execute();
        foreach ($as->fetchAll(PDO::FETCH_ASSOC) as $r) {
            $m = (int)($r['month_no'] ?? 0);
            if ($m < 1 || $m > 12) continue;
            $stored[$m] = $r;
        }
    }

    $months = sf9_months($yearStart, $yearEnd);
    $attendanceMonths = [];
    $totSchool = 0;
    $totPresent = 0;
    $totAbsent = 0;
    $totLate = 0;

    foreach ($months as $m) {
        $monthNo = (int)$m['month'];
        $schoolDays = null;
        $present = null;
        $absent = null;
        $late = null;

        if (isset($stored[$monthNo])) {
            $row = $stored[$monthNo];
            $schoolDays = (int)($row['total_school_days'] ?? 0);
            $present = (int)($row['days_present'] ?? 0) + (int)($row['days_excused'] ?? 0);
            $absent = (int)($row['days_absent'] ?? 0);
            $late = (int)($row['days_late'] ?? 0);
        } else if ($enrollmentId > 0) {
            [$start, $end] = sf9_month_bounds((int)$m['year'], $monthNo);
            $att = $conn->prepare(
                "SELECT
                    SUM(a.status = 'Present') AS days_present,
                    SUM(a.status = 'Absent') AS days_absent,
                    SUM(a.status = 'Late') AS days_late,
                    SUM(a.status = 'Excused') AS days_excused
                 FROM attendance a
                 WHERE a.enrollment_id = :eid
                   AND a.is_deleted = 0
                   AND a.class_id = 0
                   AND a.attendance_date BETWEEN :start_date AND :end_date"
            );
            $att->bindValue(':eid', $enrollmentId, PDO::PARAM_INT);
            $att->bindValue(':start_date', $start);
            $att->bindValue(':end_date', $end);
            $att->execute();
            $ar = $att->fetch(PDO::FETCH_ASSOC) ?: [];
            $present = (int)($ar['days_present'] ?? 0) + (int)($ar['days_excused'] ?? 0);
            $absent = (int)($ar['days_absent'] ?? 0);
            $late = (int)($ar['days_late'] ?? 0);
        }

        if ($schoolDays === null) {
            $schoolDays = 0;
            try {
                $start = new DateTime(sprintf('%04d-%02d-01', (int)$m['year'], $monthNo));
                $end = new DateTime($start->format('Y-m-t'));
                $end = $end->modify('+1 day');
                $count = 0;
                for ($d = clone $start; $d < $end; $d->modify('+1 day')) {
                    $dow = (int)$d->format('N');
                    if ($dow >= 1 && $dow <= 5) $count++;
                }
                $schoolDays = $count;
            } catch (Throwable $_) {
                $schoolDays = 0;
            }
        }

        $attendanceMonths[] = [
            'label' => $m['label'],
            'month_no' => $monthNo,
            'year' => (int)$m['year'],
            'total_school_days' => $schoolDays,
            'days_present' => $present,
            'days_absent' => $absent,
            'times_tardy' => $late,
        ];

        $totSchool += (int)$schoolDays;
        $totPresent += (int)($present ?? 0);
        $totAbsent += (int)($absent ?? 0);
        $totLate += (int)($late ?? 0);
    }

    $payload = [
        'success' => true,
        'report_card_id' => null,
        'enrollment_id' => $enrollmentId,
        'learner' => [
            'name' => $learnerName,
            'lrn' => $h['lrn'] ?? null,
            'sex' => $h['gender'] ?? null,
            'date_of_birth' => $h['date_of_birth'] ?? null,
            'age' => $age,
            'mother_tongue' => $h['mother_tongue'] ?? null,
        ],
        'enrollment' => [
            'grade_level' => $h['grade_name'] ?? null,
            'education_level' => $h['education_level_name'] ?? null,
            'section' => $h['section_name'] ?? null,
            'school_year' => $h['year_label'] ?? null,
            'school_year_id' => $schoolYearId,
            'section_id' => $sectionId,
        ],
        'school' => [
            'school_id' => $settings['school_id'] ?? ($settings['schoolId'] ?? null),
            'school_name' => $settings['school_name'] ?? ($settings['schoolName'] ?? null),
            'name' => $settings['school_name'] ?? ($settings['schoolName'] ?? null),
            'region' => $settings['region'] ?? ($settings['school_region'] ?? null),
            'division' => $settings['division'] ?? ($settings['school_division'] ?? null),
            'district' => $settings['district'] ?? ($settings['school_district'] ?? null),
            'school_head' => $settings['school_head'] ?? ($settings['school_head_name'] ?? ($settings['principal_name'] ?? null)),
            'principal_name' => $settings['principal_name'] ?? ($settings['school_head'] ?? ($settings['school_head_name'] ?? null)),
            'principal_title' => $settings['principal_title'] ?? ($settings['school_head_title'] ?? 'Principal'),
            // Fall back to project logo if none configured
            'logo_url' => ($settings['logo_url'] ?? ($settings['school_logo_url'] ?? ($settings['deped_logo_url'] ?? null))) ?: $defaultLogoUrl,
            'deped_logo_url' => $settings['deped_logo_url'] ?? '/deped_capstone2/assets/img/logo/pngegg.png',
            'curriculum_level' => $curriculumLevel,
            'track_strand' => $settings['track_strand'] ?? ($settings['school_track_strand'] ?? null),
        ],
        'adviser' => [
            'name' => $adviserName,
        ],
        'quarters' => $quarters,
        'grades' => $gradeRows,
        'general_average' => $generalAverage,
        'core_values' => sf9_observed_values_template(),
        'attendance' => [
            'months' => $attendanceMonths,
            'totals' => [
                'total_school_days' => $totSchool,
                'days_present' => $totPresent,
                'days_absent' => $totAbsent,
                'times_tardy' => $totLate,
            ]
        ],
    ];

    respond($payload);
}

function getSF9Roster(PDO $conn): void {
    $sectionId = (int)($_GET['section_id'] ?? 0);
    $schoolYearId = (int)($_GET['school_year_id'] ?? 0);
    if ($sectionId <= 0) {
        respond(['success' => false, 'message' => 'section_id is required'], 422);
    }

    if ($schoolYearId <= 0) {
        // Prefer the section's configured school year; else fallback to active.
        $sy = $conn->prepare('SELECT school_year_id FROM sections WHERE section_id = :sid AND is_deleted = 0 LIMIT 1');
        $sy->bindValue(':sid', $sectionId, PDO::PARAM_INT);
        $sy->execute();
        $schoolYearId = (int)($sy->fetchColumn() ?? 0);
    }
    if ($schoolYearId <= 0) {
        $schoolYearId = (int)($conn->query("SELECT school_year_id FROM school_years WHERE is_active = 1 AND is_deleted = 0 ORDER BY year_start DESC LIMIT 1")->fetchColumn() ?? 0);
    }
    if ($schoolYearId <= 0) {
        respond(['success' => false, 'message' => 'Active school year not found'], 404);
    }

    $sql = "SELECT e.enrollment_id,
                   e.learner_id,
                   e.school_year_id,
                   e.section_id,
                   e.grade_level_id,
                   l.lrn,
                   CONCAT(l.last_name, ', ', l.first_name,
                       CASE WHEN l.middle_name IS NULL OR l.middle_name = '' THEN '' ELSE CONCAT(' ', l.middle_name) END,
                       CASE WHEN l.name_extension IS NULL OR l.name_extension = '' THEN '' ELSE CONCAT(' ', l.name_extension) END
                   ) AS learner_name,
                   l.gender,
                   gl.grade_name,
                   sec.section_name,
                   sy.year_label,
                   ga.general_average
            FROM enrollments e
            JOIN learners l ON e.learner_id = l.learner_id
            LEFT JOIN grade_levels gl ON gl.grade_level_id = e.grade_level_id
            LEFT JOIN sections sec ON sec.section_id = e.section_id
            LEFT JOIN school_years sy ON sy.school_year_id = e.school_year_id
            LEFT JOIN general_averages ga ON ga.enrollment_id = e.enrollment_id AND ga.is_deleted = 0
            WHERE e.is_deleted = 0
              AND (e.enrollment_status = 'Enrolled' OR e.enrollment_status IS NULL)
              AND e.section_id = :sid
              AND e.school_year_id = :sy
            ORDER BY l.last_name, l.first_name";

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':sid', $sectionId, PDO::PARAM_INT);
    $stmt->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function createReportCard(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['enrollment_id']) || empty($data['grading_period_id'])) {
        respond(['success' => false, 'message' => 'Enrollment and grading period are required'], 422);
    }

    try {
        $conn->beginTransaction();
        $stmt = $conn->prepare('INSERT INTO report_cards (enrollment_id, grading_period_id, generated_by, file_path) VALUES (:enrollment_id, :grading_period_id, :generated_by, :file_path)');
        $stmt->bindValue(':enrollment_id', $data['enrollment_id'], PDO::PARAM_INT);
        $stmt->bindValue(':grading_period_id', $data['grading_period_id'], PDO::PARAM_INT);
        $stmt->bindValue(':generated_by', $data['generated_by'] ?? null, ($data['generated_by'] ?? null) === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
        $stmt->bindValue(':file_path', $data['file_path'] ?? null);
        $stmt->execute();

        $reportCardId = (int)$conn->lastInsertId();
        populateReportCardSnapshot($conn, $reportCardId);

        $conn->commit();
        respond(['success' => true, 'message' => 'Report card created', 'report_card_id' => $reportCardId]);
    } catch (Exception $e) {
        if ($conn->inTransaction()) $conn->rollBack();
        respond(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
    }
}

function updateReportCard(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['report_card_id']) || empty($data['enrollment_id']) || empty($data['grading_period_id'])) {
        respond(['success' => false, 'message' => 'Report card ID, enrollment, and grading period are required'], 422);
    }
    try {
        $conn->beginTransaction();
        $stmt = $conn->prepare('UPDATE report_cards SET enrollment_id = :enrollment_id, grading_period_id = :grading_period_id, generated_by = :generated_by, file_path = :file_path WHERE report_card_id = :report_card_id');
        $stmt->bindValue(':enrollment_id', $data['enrollment_id'], PDO::PARAM_INT);
        $stmt->bindValue(':grading_period_id', $data['grading_period_id'], PDO::PARAM_INT);
        $stmt->bindValue(':generated_by', $data['generated_by'] ?? null, ($data['generated_by'] ?? null) === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
        $stmt->bindValue(':file_path', $data['file_path'] ?? null);
        $stmt->bindValue(':report_card_id', $data['report_card_id'], PDO::PARAM_INT);
        $stmt->execute();

        populateReportCardSnapshot($conn, (int)$data['report_card_id']);
        $conn->commit();
        respond(['success' => true, 'message' => 'Report card updated']);
    } catch (Exception $e) {
        if ($conn->inTransaction()) $conn->rollBack();
        respond(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
    }
}

function deleteReportCard(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['report_card_id'])) {
        respond(['success' => false, 'message' => 'Report card ID is required'], 422);
    }
    $stmt = $conn->prepare('UPDATE report_cards SET is_deleted = 1, deleted_at = NOW() WHERE report_card_id = :report_card_id');
    $stmt->bindValue(':report_card_id', $data['report_card_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Report card deleted']);
}
?>
