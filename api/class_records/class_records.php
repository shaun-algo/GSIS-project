<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/../utils/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { exit(0); }

require_once __DIR__ . '/../database/connection.php';
require_once __DIR__ . '/../utils/auth.php';

function respond($payload, int $code = 200): void {
    http_response_code($code);
    echo json_encode($payload);
    exit;
}

function getJsonInput(): array {
    $raw = file_get_contents('php://input');
    return $raw ? (json_decode($raw, true) ?: []) : [];
}

function requireInt($value, string $name): int {
    if ($value === null || $value === '' || !is_numeric($value)) {
        throw new InvalidArgumentException("Missing or invalid {$name}");
    }
    return (int)$value;
}

function getTeacherEmployeeId(PDO $conn, int $userId): ?int {
    $stmt = $conn->prepare('SELECT employee_id FROM employees WHERE user_id = :user_id AND is_deleted = 0 LIMIT 1');
    $stmt->bindValue(':user_id', $userId, PDO::PARAM_INT);
    $stmt->execute();
    $val = $stmt->fetchColumn();
    if ($val === false || $val === null) return null;
    return (int)$val;
}

function fetchClassOffering(PDO $conn, int $classId): ?array {
    $sql = "SELECT co.class_id, co.subject_id, s.subject_code, s.subject_name,
                   co.section_id, sec.section_name, sec.grade_level_id, gl.grade_name,
                   co.teacher_id, co.school_year_id, sy.year_label
            FROM class_offerings co
            JOIN subjects s ON s.subject_id = co.subject_id AND s.is_deleted = 0
            JOIN sections sec ON sec.section_id = co.section_id AND sec.is_deleted = 0
            LEFT JOIN grade_levels gl ON gl.grade_level_id = sec.grade_level_id
            LEFT JOIN school_years sy ON sy.school_year_id = co.school_year_id
                        WHERE co.class_id = :class_id
                            AND co.is_deleted = 0
            LIMIT 1";
    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':class_id', $classId, PDO::PARAM_INT);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

function enforceClassAccess(PDO $conn, array $session, int $classId): array {
    $class = fetchClassOffering($conn, $classId);
    if (!$class) {
        auth_abort(404, 'Class offering not found');
    }

    if (auth_is_admin($session)) {
        return $class;
    }

    $employeeId = getTeacherEmployeeId($conn, (int)$session['user_id']);
    if (!$employeeId) {
        auth_abort(403, 'Teacher profile not found');
    }

    if ((int)$class['teacher_id'] !== (int)$employeeId) {
        auth_abort(403, 'Not authorized for this class');
    }

    return $class;
}

function fetchGradingPeriod(PDO $conn, int $gradingPeriodId): ?array {
    $stmt = $conn->prepare('SELECT grading_period_id, school_year_id, period_name, status, date_start, date_end FROM grading_periods WHERE grading_period_id = :id AND is_deleted = 0 LIMIT 1');
    $stmt->bindValue(':id', $gradingPeriodId, PDO::PARAM_INT);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

function fetchPrimaryCurriculumId(PDO $conn, int $schoolYearId): ?int {
    $stmt = $conn->prepare('SELECT curriculum_id FROM curriculum_school_year_map WHERE school_year_id = :sy AND is_primary = 1 AND is_deleted = 0 LIMIT 1');
    $stmt->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
    $stmt->execute();
    $val = $stmt->fetchColumn();
    if ($val === false || $val === null) return null;
    return (int)$val;
}

function fetchGradingWeights(PDO $conn, int $curriculumId, int $gradeLevelId): array {
    $stmt = $conn->prepare(
        'SELECT grade_level_id, component_code, weight_percent
         FROM curriculum_grading_components
         WHERE curriculum_id = :cid
           AND is_deleted = 0
           AND (grade_level_id = :glid OR grade_level_id IS NULL)
         ORDER BY (grade_level_id IS NULL) ASC, sort_order ASC'
    );
    $stmt->bindValue(':cid', $curriculumId, PDO::PARAM_INT);
    $stmt->bindValue(':glid', $gradeLevelId, PDO::PARAM_INT);
    $stmt->execute();

    $weights = ['WW' => null, 'PT' => null, 'QE' => null];
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $code = strtoupper((string)$row['component_code']);
        if (!array_key_exists($code, $weights)) continue;
        if ($weights[$code] === null) {
            $weights[$code] = (float)$row['weight_percent'];
        }
    }

    foreach ($weights as $k => $v) {
        if ($v === null) $weights[$k] = 0.0;
    }

    return $weights;
}

function fetchPassingMark(PDO $conn, int $curriculumId, int $gradeLevelId, int $subjectId): float {
    $stmt = $conn->prepare(
        'SELECT passing_mark
         FROM curriculum_passing_marks
         WHERE curriculum_id = :cid
           AND is_deleted = 0
           AND (grade_level_id = :glid OR grade_level_id IS NULL)
           AND (subject_id = :sid OR subject_id IS NULL)
         ORDER BY (subject_id IS NULL) ASC, (grade_level_id IS NULL) ASC
         LIMIT 1'
    );
    $stmt->bindValue(':cid', $curriculumId, PDO::PARAM_INT);
    $stmt->bindValue(':glid', $gradeLevelId, PDO::PARAM_INT);
    $stmt->bindValue(':sid', $subjectId, PDO::PARAM_INT);
    $stmt->execute();
    $val = $stmt->fetchColumn();
    if ($val === false || $val === null || $val === '') {
        return 75.0;
    }
    return (float)$val;
}

function computeInitialGrade(?float $ww, ?float $pt, ?float $qe, array $weights): ?float {
    if ($ww === null || $pt === null || $qe === null) return null;
    $initial = ($ww * ((float)$weights['WW'] / 100.0))
        + ($pt * ((float)$weights['PT'] / 100.0))
        + ($qe * ((float)$weights['QE'] / 100.0));
    return round($initial, 2);
}

// DepEd-style transmutation so that an initial grade of 60 maps to 75.
function transmuteGrade(?float $initial): ?float {
    if ($initial === null) return null;
    $g = max(0.0, min(100.0, (float)$initial));

    if ($g <= 60.0) {
        $trans = 60.0 + ($g / 60.0) * 15.0; // 0..60 -> 60..75
    } else {
        $trans = 75.0 + (($g - 60.0) / 40.0) * 25.0; // 60..100 -> 75..100
    }

    return round(max(60.0, min(100.0, $trans)), 2);
}

function computeQuarterlyGrade(?float $ww, ?float $pt, ?float $qe, array $weights): ?float {
    $initial = computeInitialGrade($ww, $pt, $qe, $weights);
    return transmuteGrade($initial);
}

function gradesHasInitialGrade(PDO $conn): bool {
    static $cached = null;
    if ($cached !== null) return (bool)$cached;

    try {
        $stmt = $conn->prepare(
            "SELECT 1
             FROM INFORMATION_SCHEMA.COLUMNS
             WHERE TABLE_SCHEMA = DATABASE()
               AND TABLE_NAME = 'grades'
               AND COLUMN_NAME = 'initial_grade'
             LIMIT 1"
        );
        $stmt->execute();
        $cached = (bool)$stmt->fetchColumn();
    } catch (Exception $e) {
        $cached = false;
    }

    return (bool)$cached;
}

function canonicalClassOfferingsSql(): string {
    return 'SELECT co_latest.class_id, co_latest.section_id, co_latest.school_year_id, co_latest.subject_id, co_latest.teacher_id
            FROM class_offerings co_latest
            JOIN (
                SELECT section_id, school_year_id, subject_id, MAX(class_id) AS class_id
                FROM class_offerings
                                WHERE is_deleted = 0
                GROUP BY section_id, school_year_id, subject_id
            ) pick ON pick.class_id = co_latest.class_id
                        WHERE co_latest.is_deleted = 0';
}

function countActiveEnrolledInSection(PDO $conn, int $sectionId, int $schoolYearId): int {
    $stmt = $conn->prepare(
        'SELECT COUNT(*)
         FROM enrollments
         WHERE is_deleted = 0
           AND enrollment_status = "Enrolled"
           AND section_id = :sid
           AND school_year_id = :sy'
    );
    $stmt->bindValue(':sid', $sectionId, PDO::PARAM_INT);
    $stmt->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
    $stmt->execute();
    return (int)$stmt->fetchColumn();
}

function countActiveEnrolledInGradeLevel(PDO $conn, int $schoolYearId, int $gradeLevelId): int {
    $stmt = $conn->prepare(
        'SELECT COUNT(*)
         FROM enrollments e
         JOIN sections sec ON sec.section_id = e.section_id
                          AND sec.is_deleted = 0
                          AND sec.school_year_id = e.school_year_id
                          AND sec.grade_level_id = :gl
         WHERE e.is_deleted = 0
           AND e.enrollment_status = "Enrolled"
           AND e.school_year_id = :sy
           AND e.grade_level_id = :gl_enroll'
    );
    $stmt->bindValue(':gl', $gradeLevelId, PDO::PARAM_INT);
    $stmt->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
    $stmt->bindValue(':gl_enroll', $gradeLevelId, PDO::PARAM_INT);
    $stmt->execute();
    return (int)$stmt->fetchColumn();
}

$operation = $_GET['operation'] ?? '';
$session = auth_enforce_roles($operation, ['admin', 'teacher'], ['admin', 'teacher']);

try {
    switch ($operation) {
        case 'getMyClassOfferings':
            getMyClassOfferings($conn, $session);
            break;
        case 'getRosterGrades':
            getRosterGrades($conn, $session);
            break;
        case 'saveRosterGrades':
            saveRosterGrades($conn, $session);
            break;
        case 'getHonorsList':
            getHonorsList($conn, $session);
            break;
        case 'getHonorsListByGradeLevel':
            getHonorsListByGradeLevel($conn, $session);
            break;
        default:
            respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (InvalidArgumentException $e) {
    respond(['success' => false, 'message' => $e->getMessage()], 422);
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getMyClassOfferings(PDO $conn, array $session): void {
    $canonicalOfferingsSql = canonicalClassOfferingsSql();

    if (auth_is_admin($session)) {
        $sql = "SELECT co.class_id, co.subject_id, s.subject_code, s.subject_name,
                       co.section_id, sec.section_name, sec.grade_level_id, gl.grade_name,
                       sec.adviser_id,
                       co.school_year_id, sy.year_label, sy.is_active AS school_year_is_active,
                       co.teacher_id
                FROM (" . $canonicalOfferingsSql . ") co
                JOIN subjects s ON s.subject_id = co.subject_id AND s.is_deleted = 0
                JOIN sections sec ON sec.section_id = co.section_id AND sec.is_deleted = 0
                LEFT JOIN grade_levels gl ON gl.grade_level_id = sec.grade_level_id
                LEFT JOIN school_years sy ON sy.school_year_id = co.school_year_id
                ORDER BY sy.school_year_id DESC, sec.section_name ASC, s.subject_name ASC";
        $stmt = $conn->prepare($sql);
        $stmt->execute();
        respond(['success' => true, 'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
    }

    $employeeId = getTeacherEmployeeId($conn, (int)$session['user_id']);
    if (!$employeeId) {
        auth_abort(403, 'Teacher profile not found');
    }

        $sql = "SELECT co.class_id, co.subject_id, s.subject_code, s.subject_name,
                 co.section_id, sec.section_name, sec.grade_level_id, gl.grade_name,
                 sec.adviser_id,
                 co.school_year_id, sy.year_label, sy.is_active AS school_year_is_active,
                 co.teacher_id
             FROM (" . $canonicalOfferingsSql . ") co
            JOIN subjects s ON s.subject_id = co.subject_id AND s.is_deleted = 0
            JOIN sections sec ON sec.section_id = co.section_id AND sec.is_deleted = 0
            LEFT JOIN grade_levels gl ON gl.grade_level_id = sec.grade_level_id
            LEFT JOIN school_years sy ON sy.school_year_id = co.school_year_id
             WHERE co.teacher_id = :teacher_id
            ORDER BY sy.school_year_id DESC, sec.section_name ASC, s.subject_name ASC";
    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':teacher_id', $employeeId, PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
}

function getRosterGrades(PDO $conn, array $session): void {
    $classId = requireInt($_GET['class_id'] ?? null, 'class_id');
    $gradingPeriodId = requireInt($_GET['grading_period_id'] ?? null, 'grading_period_id');

    $class = enforceClassAccess($conn, $session, $classId);
    $gp = fetchGradingPeriod($conn, $gradingPeriodId);
    if (!$gp) {
        respond(['success' => false, 'message' => 'Grading period not found'], 404);
    }
    if ((int)$gp['school_year_id'] !== (int)$class['school_year_id']) {
        respond(['success' => false, 'message' => 'Grading period does not belong to this school year'], 422);
    }

    $curriculumId = fetchPrimaryCurriculumId($conn, (int)$class['school_year_id']);
    if (!$curriculumId) {
        // Graceful fallback: allow roster view even if mapping is missing
        $curriculumId = 0;
    }

    $weights = ['WW' => 0.0, 'PT' => 0.0, 'QE' => 0.0];
    $passingMark = 75.0;
    if ($curriculumId > 0) {
        $weights = fetchGradingWeights($conn, (int)$curriculumId, (int)$class['grade_level_id']);
        $passingMark = fetchPassingMark($conn, (int)$curriculumId, (int)$class['grade_level_id'], (int)$class['subject_id']);
    }

    $sql = "SELECT e.enrollment_id,
                   l.learner_id,
                   l.lrn,
                   CONCAT(l.last_name, ', ', l.first_name,
                        CASE WHEN l.middle_name IS NULL OR l.middle_name = '' THEN '' ELSE CONCAT(' ', l.middle_name) END,
                        CASE WHEN l.name_extension IS NULL OR l.name_extension = '' THEN '' ELSE CONCAT(' ', l.name_extension) END
                   ) AS learner_name,
                   l.gender,
                   g.grade_id,
                   g.written_works,
                   g.performance_tasks,
                   g.quarterly_exam,
                   g.quarterly_grade
            FROM enrollments e
            JOIN learners l ON l.learner_id = e.learner_id AND l.is_deleted = 0
            LEFT JOIN grades g
                   ON g.enrollment_id = e.enrollment_id
                  AND g.class_id = :class_id
                  AND g.grading_period_id = :gp_id
                  AND g.is_deleted = 0
            WHERE e.is_deleted = 0
              AND e.enrollment_status = 'Enrolled'
              AND e.section_id = :section_id
              AND e.school_year_id = :school_year_id
            ORDER BY l.last_name ASC, l.first_name ASC";

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':class_id', $classId, PDO::PARAM_INT);
    $stmt->bindValue(':gp_id', $gradingPeriodId, PDO::PARAM_INT);
    $stmt->bindValue(':section_id', (int)$class['section_id'], PDO::PARAM_INT);
    $stmt->bindValue(':school_year_id', (int)$class['school_year_id'], PDO::PARAM_INT);
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Ensure quarterly_grade is present when components are present.
    foreach ($rows as &$r) {
        $ww = $r['written_works'] === null ? null : (float)$r['written_works'];
        $pt = $r['performance_tasks'] === null ? null : (float)$r['performance_tasks'];
        $qe = $r['quarterly_exam'] === null ? null : (float)$r['quarterly_exam'];
        $qg = $r['quarterly_grade'] === null ? null : (float)$r['quarterly_grade'];
        if ($qg === null) {
            $computed = computeQuarterlyGrade($ww, $pt, $qe, $weights);
            $r['quarterly_grade'] = $computed;
        }
    }
    unset($r);

    respond([
        'success' => true,
        'data' => [
            'class' => [
                'class_id' => (int)$class['class_id'],
                'subject_id' => (int)$class['subject_id'],
                'subject_code' => $class['subject_code'],
                'subject_name' => $class['subject_name'],
                'section_id' => (int)$class['section_id'],
                'section_name' => $class['section_name'],
                'grade_level_id' => (int)$class['grade_level_id'],
                'grade_name' => $class['grade_name'],
                'school_year_id' => (int)$class['school_year_id'],
                'year_label' => $class['year_label'],
                'weights' => $weights,
                'passing_mark' => $passingMark
            ],
            'grading_period' => [
                'grading_period_id' => (int)$gp['grading_period_id'],
                'period_name' => $gp['period_name'],
                'status' => $gp['status'],
                'date_start' => $gp['date_start'],
                'date_end' => $gp['date_end']
            ],
            'learners' => $rows
        ]
    ]);
}

function saveRosterGrades(PDO $conn, array $session): void {
    $data = getJsonInput();
    $classId = requireInt($data['class_id'] ?? null, 'class_id');
    $gradingPeriodId = requireInt($data['grading_period_id'] ?? null, 'grading_period_id');
    $grades = $data['grades'] ?? null;

    if (!is_array($grades)) {
        respond(['success' => false, 'message' => 'grades must be an array'], 422);
    }

    $class = enforceClassAccess($conn, $session, $classId);
    $gp = fetchGradingPeriod($conn, $gradingPeriodId);
    if (!$gp) {
        respond(['success' => false, 'message' => 'Grading period not found'], 404);
    }
    if ((int)$gp['school_year_id'] !== (int)$class['school_year_id']) {
        respond(['success' => false, 'message' => 'Grading period does not belong to this school year'], 422);
    }

    if (strtoupper((string)$gp['status']) !== 'OPEN') {
        respond(['success' => false, 'message' => 'Grading period is not open for encoding'], 403);
    }

    $curriculumId = fetchPrimaryCurriculumId($conn, (int)$class['school_year_id']);
    if (!$curriculumId) {
        respond(['success' => false, 'message' => 'No primary curriculum mapped for this school year'], 422);
    }

    $weights = fetchGradingWeights($conn, (int)$curriculumId, (int)$class['grade_level_id']);

    $enrollmentIds = [];
    foreach ($grades as $g) {
        if (!is_array($g)) continue;
        if (!isset($g['enrollment_id'])) continue;
        $enrollmentIds[] = (int)$g['enrollment_id'];
    }
    $enrollmentIds = array_values(array_unique(array_filter($enrollmentIds, fn($v) => $v > 0)));

    if (!$enrollmentIds) {
        respond(['success' => false, 'message' => 'No enrollment_id provided'], 422);
    }

    // Validate enrollment_ids belong to this section & SY
    $placeholders = implode(',', array_fill(0, count($enrollmentIds), '?'));
    $valSql = "SELECT enrollment_id
              FROM enrollments
              WHERE enrollment_id IN ($placeholders)
                AND is_deleted = 0
                AND enrollment_status = 'Enrolled'
                AND section_id = ?
                AND school_year_id = ?";
    $valStmt = $conn->prepare($valSql);
    $i = 1;
    foreach ($enrollmentIds as $id) {
        $valStmt->bindValue($i++, $id, PDO::PARAM_INT);
    }
    $valStmt->bindValue($i++, (int)$class['section_id'], PDO::PARAM_INT);
    $valStmt->bindValue($i++, (int)$class['school_year_id'], PDO::PARAM_INT);
    $valStmt->execute();
    $validIds = array_map('intval', $valStmt->fetchAll(PDO::FETCH_COLUMN));
    $validMap = array_fill_keys($validIds, true);

    $userId = (int)($session['user_id'] ?? 0);

    $hasInitialGrade = gradesHasInitialGrade($conn);

    $sql = $hasInitialGrade
        ? 'INSERT INTO grades (
            enrollment_id, class_id, grading_period_id,
            written_works, performance_tasks, quarterly_exam, initial_grade, quarterly_grade,
            encoded_by, is_deleted, deleted_at
        ) VALUES (
            :enrollment_id, :class_id, :grading_period_id,
            :written_works, :performance_tasks, :quarterly_exam, :initial_grade, :quarterly_grade,
            :encoded_by, 0, NULL
        )
        ON DUPLICATE KEY UPDATE
            written_works = VALUES(written_works),
            performance_tasks = VALUES(performance_tasks),
            quarterly_exam = VALUES(quarterly_exam),
            initial_grade = VALUES(initial_grade),
            quarterly_grade = VALUES(quarterly_grade),
            encoded_by = VALUES(encoded_by),
            is_deleted = 0,
            deleted_at = NULL'
        : 'INSERT INTO grades (
            enrollment_id, class_id, grading_period_id,
            written_works, performance_tasks, quarterly_exam, quarterly_grade,
            encoded_by, is_deleted, deleted_at
        ) VALUES (
            :enrollment_id, :class_id, :grading_period_id,
            :written_works, :performance_tasks, :quarterly_exam, :quarterly_grade,
            :encoded_by, 0, NULL
        )
        ON DUPLICATE KEY UPDATE
            written_works = VALUES(written_works),
            performance_tasks = VALUES(performance_tasks),
            quarterly_exam = VALUES(quarterly_exam),
            quarterly_grade = VALUES(quarterly_grade),
            encoded_by = VALUES(encoded_by),
            is_deleted = 0,
            deleted_at = NULL';

    $ins = $conn->prepare($sql);

    $saved = 0;
    $skipped = 0;

    try {
        $conn->beginTransaction();

        foreach ($grades as $g) {
            if (!is_array($g)) { $skipped++; continue; }
            $enrollmentId = (int)($g['enrollment_id'] ?? 0);
            if ($enrollmentId <= 0 || empty($validMap[$enrollmentId])) {
                $skipped++;
                continue;
            }

            $ww = array_key_exists('written_works', $g) ? $g['written_works'] : null;
            $pt = array_key_exists('performance_tasks', $g) ? $g['performance_tasks'] : null;
            $qe = array_key_exists('quarterly_exam', $g) ? $g['quarterly_exam'] : null;

            $ww = ($ww === '' || $ww === null) ? null : (float)$ww;
            $pt = ($pt === '' || $pt === null) ? null : (float)$pt;
            $qe = ($qe === '' || $qe === null) ? null : (float)$qe;

            foreach ([['written_works', $ww], ['performance_tasks', $pt], ['quarterly_exam', $qe]] as $pair) {
                [$label, $val] = $pair;
                if ($val === null) continue;
                if ($val < 0 || $val > 100) {
                    throw new InvalidArgumentException("{$label} must be between 0 and 100");
                }
            }

            $initial = computeInitialGrade($ww, $pt, $qe, $weights);
            $qg = transmuteGrade($initial);

            $ins->bindValue(':enrollment_id', $enrollmentId, PDO::PARAM_INT);
            $ins->bindValue(':class_id', $classId, PDO::PARAM_INT);
            $ins->bindValue(':grading_period_id', $gradingPeriodId, PDO::PARAM_INT);
            $ins->bindValue(':encoded_by', $userId, PDO::PARAM_INT);

            if ($ww === null) $ins->bindValue(':written_works', null, PDO::PARAM_NULL);
            else $ins->bindValue(':written_works', $ww);

            if ($pt === null) $ins->bindValue(':performance_tasks', null, PDO::PARAM_NULL);
            else $ins->bindValue(':performance_tasks', $pt);

            if ($qe === null) $ins->bindValue(':quarterly_exam', null, PDO::PARAM_NULL);
            else $ins->bindValue(':quarterly_exam', $qe);

            if ($hasInitialGrade) {
                if ($initial === null) $ins->bindValue(':initial_grade', null, PDO::PARAM_NULL);
                else $ins->bindValue(':initial_grade', $initial);
            }

            if ($qg === null) $ins->bindValue(':quarterly_grade', null, PDO::PARAM_NULL);
            else $ins->bindValue(':quarterly_grade', $qg);

            $ins->execute();
            $saved++;
        }

        $conn->commit();
    } catch (Exception $e) {
        if ($conn->inTransaction()) $conn->rollBack();
        throw $e;
    }

    respond([
        'success' => true,
        'message' => 'Grades saved',
        'data' => [
            'saved' => $saved,
            'skipped' => $skipped
        ]
    ]);
}

function getHonorsList(PDO $conn, array $session): void {
    $sectionId = requireInt($_GET['section_id'] ?? null, 'section_id');
    $mode = strtolower(trim((string)($_GET['mode'] ?? 'quarter')));
    if (!in_array($mode, ['quarter', 'final'], true)) {
        respond(['success' => false, 'message' => 'Invalid mode'], 422);
    }

    $gradingPeriodId = null;
    if ($mode === 'quarter') {
        $gradingPeriodId = requireInt($_GET['grading_period_id'] ?? null, 'grading_period_id');
    }

    $secStmt = $conn->prepare(
        'SELECT sec.section_id, sec.section_name, sec.grade_level_id, gl.grade_name, sec.school_year_id, sy.year_label
         FROM sections sec
         LEFT JOIN grade_levels gl ON gl.grade_level_id = sec.grade_level_id
         LEFT JOIN school_years sy ON sy.school_year_id = sec.school_year_id
         WHERE sec.section_id = :sid AND sec.is_deleted = 0
         LIMIT 1'
    );
    $secStmt->bindValue(':sid', $sectionId, PDO::PARAM_INT);
    $secStmt->execute();
    $section = $secStmt->fetch(PDO::FETCH_ASSOC);
    if (!$section) {
        respond(['success' => false, 'message' => 'Section not found'], 404);
    }

    $schoolYearId = (int)$section['school_year_id'];

    if (!auth_is_admin($session)) {
        $employeeId = getTeacherEmployeeId($conn, (int)$session['user_id']);
        if (!$employeeId) {
            auth_abort(403, 'Teacher profile not found');
        }
        $chk = $conn->prepare('SELECT COUNT(*) FROM class_offerings WHERE section_id = :sid AND school_year_id = :sy AND teacher_id = :tid AND is_deleted = 0');
        $chk->bindValue(':sid', $sectionId, PDO::PARAM_INT);
        $chk->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
        $chk->bindValue(':tid', $employeeId, PDO::PARAM_INT);
        $chk->execute();
        if ((int)$chk->fetchColumn() <= 0) {
            auth_abort(403, 'Not authorized for this section');
        }
    }

    if ($mode === 'quarter') {
        $gp = fetchGradingPeriod($conn, (int)$gradingPeriodId);
        if (!$gp) {
            respond(['success' => false, 'message' => 'Grading period not found'], 404);
        }
        if ((int)$gp['school_year_id'] !== $schoolYearId) {
            respond(['success' => false, 'message' => 'Grading period does not belong to this school year'], 422);
        }
    }

    $totalEnrolled = countActiveEnrolledInSection($conn, $sectionId, $schoolYearId);
    $canonicalOfferingsSql = canonicalClassOfferingsSql();

    $offerStmt = $conn->prepare(
        'SELECT co.class_id, co.subject_id, s.subject_code, s.subject_name
         FROM (' . $canonicalOfferingsSql . ') co
         JOIN subjects s ON s.subject_id = co.subject_id AND s.is_deleted = 0
         WHERE co.section_id = :sid AND co.school_year_id = :sy
         ORDER BY s.subject_name ASC'
    );
    $offerStmt->bindValue(':sid', $sectionId, PDO::PARAM_INT);
    $offerStmt->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
    $offerStmt->execute();
    $subjects = $offerStmt->fetchAll(PDO::FETCH_ASSOC);
    $subjectCount = count($subjects);

    if ($subjectCount === 0) {
        respond(['success' => true, 'data' => ['section' => $section, 'subjects' => [], 'honorees' => [], 'counts' => ['total_enrolled' => $totalEnrolled, 'highest' => 0, 'high' => 0, 'honors' => 0]]] );
    }

    $honorStmt = $conn->prepare('SELECT honor_level_id, honor_name, min_average, max_average FROM honor_levels WHERE is_deleted = 0 ORDER BY min_average DESC');
    $honorStmt->execute();
    $honorLevels = $honorStmt->fetchAll(PDO::FETCH_ASSOC);

    $rows = [];

    if ($mode === 'quarter') {
        $sql = "SELECT e.enrollment_id,
                       l.learner_id,
                       l.lrn,
                       CONCAT(l.last_name, ', ', l.first_name,
                            CASE WHEN l.middle_name IS NULL OR l.middle_name = '' THEN '' ELSE CONCAT(' ', l.middle_name) END,
                            CASE WHEN l.name_extension IS NULL OR l.name_extension = '' THEN '' ELSE CONCAT(' ', l.name_extension) END
                       ) AS learner_name,
                       l.gender,
                       co.class_id,
                       s.subject_code,
                       s.subject_name,
                       g.quarterly_grade AS grade_value
                FROM enrollments e
                JOIN learners l ON l.learner_id = e.learner_id AND l.is_deleted = 0
                JOIN (" . $canonicalOfferingsSql . ") co ON co.section_id = e.section_id AND co.school_year_id = e.school_year_id
                JOIN subjects s ON s.subject_id = co.subject_id AND s.is_deleted = 0
                LEFT JOIN grades g
                       ON g.enrollment_id = e.enrollment_id
                      AND g.class_id = co.class_id
                      AND g.grading_period_id = :gp_id
                      AND g.is_deleted = 0
                WHERE e.section_id = :sid
                  AND e.school_year_id = :sy
                  AND e.is_deleted = 0
                  AND e.enrollment_status = 'Enrolled'
                ORDER BY l.last_name ASC, l.first_name ASC, s.subject_name ASC";
        $stmt = $conn->prepare($sql);
        $stmt->bindValue(':gp_id', (int)$gradingPeriodId, PDO::PARAM_INT);
        $stmt->bindValue(':sid', $sectionId, PDO::PARAM_INT);
        $stmt->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } else {
        $expectedPeriodsStmt = $conn->prepare('SELECT COUNT(*) FROM grading_periods WHERE school_year_id = :sy AND is_deleted = 0');
        $expectedPeriodsStmt->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
        $expectedPeriodsStmt->execute();
        $expectedPeriods = max(1, (int)$expectedPeriodsStmt->fetchColumn());

        $sql = "SELECT e.enrollment_id,
                       l.learner_id,
                       l.lrn,
                       CONCAT(l.last_name, ', ', l.first_name,
                            CASE WHEN l.middle_name IS NULL OR l.middle_name = '' THEN '' ELSE CONCAT(' ', l.middle_name) END,
                            CASE WHEN l.name_extension IS NULL OR l.name_extension = '' THEN '' ELSE CONCAT(' ', l.name_extension) END
                       ) AS learner_name,
                       l.gender,
                       co.class_id,
                       s.subject_code,
                       s.subject_name,
                       COALESCE(fg.final_grade,
                                CASE WHEN gf.cnt = :expected_periods THEN gf.computed_final ELSE NULL END
                       ) AS grade_value
                FROM enrollments e
                JOIN learners l ON l.learner_id = e.learner_id AND l.is_deleted = 0
                JOIN (" . $canonicalOfferingsSql . ") co ON co.section_id = e.section_id AND co.school_year_id = e.school_year_id
                JOIN subjects s ON s.subject_id = co.subject_id AND s.is_deleted = 0
                LEFT JOIN final_grades fg
                       ON fg.enrollment_id = e.enrollment_id
                      AND fg.class_id = co.class_id
                      AND fg.is_deleted = 0
                LEFT JOIN (
                    SELECT g.enrollment_id, g.class_id,
                           ROUND(AVG(g.quarterly_grade), 2) AS computed_final,
                           COUNT(*) AS cnt
                    FROM grades g
                    JOIN grading_periods gp ON gp.grading_period_id = g.grading_period_id AND gp.school_year_id = :sy_gp
                    WHERE g.is_deleted = 0 AND g.quarterly_grade IS NOT NULL
                    GROUP BY g.enrollment_id, g.class_id
                ) gf ON gf.enrollment_id = e.enrollment_id AND gf.class_id = co.class_id
                WHERE e.section_id = :sid
                  AND e.school_year_id = :sy_main
                  AND e.is_deleted = 0
                  AND e.enrollment_status = 'Enrolled'
                ORDER BY l.last_name ASC, l.first_name ASC, s.subject_name ASC";

        $stmt = $conn->prepare($sql);
        $stmt->bindValue(':expected_periods', $expectedPeriods, PDO::PARAM_INT);
        $stmt->bindValue(':sid', $sectionId, PDO::PARAM_INT);
        $stmt->bindValue(':sy_gp', $schoolYearId, PDO::PARAM_INT);
        $stmt->bindValue(':sy_main', $schoolYearId, PDO::PARAM_INT);
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    $byEnrollment = [];
    foreach ($rows as $r) {
        $eid = (int)$r['enrollment_id'];
        if (!isset($byEnrollment[$eid])) {
            $byEnrollment[$eid] = [
                'enrollment_id' => $eid,
                'learner_id' => (int)$r['learner_id'],
                'lrn' => $r['lrn'],
                'learner_name' => $r['learner_name'],
                'gender' => $r['gender'],
                'subjects' => [],
                'general_average' => null,
                'honor' => null
            ];
        }
        $byEnrollment[$eid]['subjects'][] = [
            'class_id' => (int)$r['class_id'],
            'subject_code' => $r['subject_code'],
            'subject_name' => $r['subject_name'],
            'grade' => ($r['grade_value'] === null || $r['grade_value'] === '') ? null : (float)$r['grade_value']
        ];
    }

    $honorees = [];

    foreach ($byEnrollment as $eid => $entry) {
        $vals = [];
        $filled = 0;
        foreach ($entry['subjects'] as $sg) {
            if ($sg['grade'] !== null) {
                $vals[] = (float)$sg['grade'];
                $filled++;
            }
        }
        if ($filled !== $subjectCount || !$vals) {
            continue;
        }

        $avg = round(array_sum($vals) / count($vals), 2);
        $entry['general_average'] = $avg;

        $matched = null;
        foreach ($honorLevels as $hl) {
            $min = $hl['min_average'] === null ? null : (float)$hl['min_average'];
            $max = $hl['max_average'] === null ? null : (float)$hl['max_average'];
            if ($min !== null && $avg < $min) continue;
            if ($max !== null && $avg > $max) continue;
            $matched = [
                'honor_level_id' => (int)$hl['honor_level_id'],
                'honor_name' => $hl['honor_name'],
                'min_average' => $min,
                'max_average' => $max
            ];
            break;
        }

        if ($matched) {
            $entry['honor'] = $matched;
            $honorees[] = $entry;
        }
    }

    usort($honorees, fn($a, $b) => ($b['general_average'] ?? 0) <=> ($a['general_average'] ?? 0));

    $counts = ['total_enrolled' => $totalEnrolled, 'highest' => 0, 'high' => 0, 'honors' => 0];
    foreach ($honorees as $h) {
        $name = strtolower((string)($h['honor']['honor_name'] ?? ''));
        if (str_contains($name, 'highest')) $counts['highest']++;
        else if (str_contains($name, 'high')) $counts['high']++;
        else $counts['honors']++;
    }

    respond([
        'success' => true,
        'data' => [
            'mode' => $mode,
            'section' => $section,
            'subjects' => $subjects,
            'honorees' => $honorees,
            'counts' => $counts
        ]
    ]);
}

function getHonorsListByGradeLevel(PDO $conn, array $session): void {
    $schoolYearId = requireInt($_GET['school_year_id'] ?? null, 'school_year_id');
    $gradeLevelId = requireInt($_GET['grade_level_id'] ?? null, 'grade_level_id');
    $mode = strtolower(trim((string)($_GET['mode'] ?? 'quarter')));
    if (!in_array($mode, ['quarter', 'final'], true)) {
        respond(['success' => false, 'message' => 'Invalid mode'], 422);
    }

    $gradingPeriodId = null;
    if ($mode === 'quarter') {
        $gradingPeriodId = requireInt($_GET['grading_period_id'] ?? null, 'grading_period_id');
        $gp = fetchGradingPeriod($conn, (int)$gradingPeriodId);
        if (!$gp) {
            respond(['success' => false, 'message' => 'Grading period not found'], 404);
        }
        if ((int)$gp['school_year_id'] !== (int)$schoolYearId) {
            respond(['success' => false, 'message' => 'Grading period does not belong to this school year'], 422);
        }
    }

    // Authorization: admin can access all; teacher must have at least one offering in this grade level & SY.
    if (!auth_is_admin($session)) {
        $employeeId = getTeacherEmployeeId($conn, (int)$session['user_id']);
        if (!$employeeId) {
            auth_abort(403, 'Teacher profile not found');
        }
        $chk = $conn->prepare(
            'SELECT COUNT(*)
             FROM class_offerings co
             JOIN sections sec ON sec.section_id = co.section_id AND sec.is_deleted = 0
                         WHERE co.is_deleted = 0
               AND co.teacher_id = :tid
               AND co.school_year_id = :sy
               AND sec.grade_level_id = :gl'
        );
        $chk->bindValue(':tid', $employeeId, PDO::PARAM_INT);
        $chk->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
        $chk->bindValue(':gl', $gradeLevelId, PDO::PARAM_INT);
        $chk->execute();
        if ((int)$chk->fetchColumn() <= 0) {
            auth_abort(403, 'Not authorized for this year level');
        }
    }

    $secStmt = $conn->prepare(
        'SELECT sec.section_id, sec.section_name, sec.grade_level_id, gl.grade_name, sec.school_year_id, sy.year_label
         FROM sections sec
         LEFT JOIN grade_levels gl ON gl.grade_level_id = sec.grade_level_id
         LEFT JOIN school_years sy ON sy.school_year_id = sec.school_year_id
         WHERE sec.is_deleted = 0
           AND sec.school_year_id = :sy
           AND sec.grade_level_id = :gl
         ORDER BY sec.section_name ASC'
    );
    $secStmt->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
    $secStmt->bindValue(':gl', $gradeLevelId, PDO::PARAM_INT);
    $secStmt->execute();
    $sections = $secStmt->fetchAll(PDO::FETCH_ASSOC);
    if (!$sections) {
        respond([
            'success' => true,
            'data' => [
                'mode' => $mode,
                'section' => [
                    'section_id' => 0,
                    'section_name' => 'All Sections',
                    'grade_level_id' => $gradeLevelId,
                    'grade_name' => '',
                    'school_year_id' => $schoolYearId,
                    'year_label' => ''
                ],
                'subjects' => [],
                'honorees' => [],
                'counts' => ['total_enrolled' => 0, 'highest' => 0, 'high' => 0, 'honors' => 0]
            ]
        ]);
    }

    $honorStmt = $conn->prepare('SELECT honor_level_id, honor_name, min_average, max_average FROM honor_levels WHERE is_deleted = 0 ORDER BY min_average DESC');
    $honorStmt->execute();
    $honorLevels = $honorStmt->fetchAll(PDO::FETCH_ASSOC);

    $totalEnrolled = countActiveEnrolledInGradeLevel($conn, $schoolYearId, $gradeLevelId);
    $canonicalOfferingsSql = canonicalClassOfferingsSql();
    $secCountSql =
        'SELECT co.section_id, co.school_year_id, COUNT(*) AS subject_count
         FROM (' . $canonicalOfferingsSql . ') co
         WHERE co.school_year_id = :sy_count
         GROUP BY co.section_id, co.school_year_id';

    // Grade values per enrollment per subject (latest active offering per subject).
    if ($mode === 'quarter') {
        $sql =
            'SELECT e.enrollment_id,
                    e.section_id,
                    sec.section_name,
                    l.learner_id,
                    l.lrn,
                    CONCAT(l.last_name, ", ", l.first_name,
                        CASE WHEN l.middle_name IS NULL OR l.middle_name = "" THEN "" ELSE CONCAT(" ", l.middle_name) END,
                        CASE WHEN l.name_extension IS NULL OR l.name_extension = "" THEN "" ELSE CONCAT(" ", l.name_extension) END
                    ) AS learner_name,
                    AVG(g.quarterly_grade) AS avg_grade,
                    SUM(CASE WHEN g.quarterly_grade IS NULL THEN 0 ELSE 1 END) AS filled,
                    sc.subject_count AS subject_count
             FROM enrollments e
             JOIN sections sec ON sec.section_id = e.section_id
                              AND sec.is_deleted = 0
                              AND sec.school_year_id = e.school_year_id
                              AND sec.grade_level_id = :gl_sec
             JOIN learners l ON l.learner_id = e.learner_id AND l.is_deleted = 0
             JOIN (' . $canonicalOfferingsSql . ') co ON co.section_id = e.section_id
                                                      AND co.school_year_id = e.school_year_id
             LEFT JOIN grades g ON g.enrollment_id = e.enrollment_id
                               AND g.class_id = co.class_id
                               AND g.grading_period_id = :gp
                               AND g.is_deleted = 0
             JOIN (' . $secCountSql . ') sc ON sc.section_id = e.section_id
                                           AND sc.school_year_id = e.school_year_id
             WHERE e.is_deleted = 0
               AND e.enrollment_status = "Enrolled"
               AND e.school_year_id = :sy_main
               AND e.grade_level_id = :gl_enroll
             GROUP BY e.enrollment_id, e.section_id, sec.section_name, l.learner_id, l.lrn, learner_name, sc.subject_count';

        $stmt = $conn->prepare($sql);
        $stmt->bindValue(':gp', (int)$gradingPeriodId, PDO::PARAM_INT);
        $stmt->bindValue(':gl_sec', $gradeLevelId, PDO::PARAM_INT);
        $stmt->bindValue(':sy_count', $schoolYearId, PDO::PARAM_INT);
        $stmt->bindValue(':sy_main', $schoolYearId, PDO::PARAM_INT);
        $stmt->bindValue(':gl_enroll', $gradeLevelId, PDO::PARAM_INT);
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } else {
        $expectedPeriodsStmt = $conn->prepare('SELECT COUNT(*) FROM grading_periods WHERE school_year_id = :sy AND is_deleted = 0');
        $expectedPeriodsStmt->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
        $expectedPeriodsStmt->execute();
        $expectedPeriods = max(1, (int)$expectedPeriodsStmt->fetchColumn());

        $sql =
            'SELECT e.enrollment_id,
                    e.section_id,
                    sec.section_name,
                    l.learner_id,
                    l.lrn,
                    CONCAT(l.last_name, ", ", l.first_name,
                        CASE WHEN l.middle_name IS NULL OR l.middle_name = "" THEN "" ELSE CONCAT(" ", l.middle_name) END,
                        CASE WHEN l.name_extension IS NULL OR l.name_extension = "" THEN "" ELSE CONCAT(" ", l.name_extension) END
                    ) AS learner_name,
                    AVG(
                        COALESCE(fg.final_grade,
                            CASE WHEN gf.cnt = :expected_periods_avg THEN gf.computed_final ELSE NULL END
                        )
                    ) AS avg_grade,
                    SUM(CASE WHEN (COALESCE(fg.final_grade, CASE WHEN gf.cnt = :expected_periods_fill THEN gf.computed_final ELSE NULL END)) IS NULL THEN 0 ELSE 1 END) AS filled,
                    sc.subject_count AS subject_count
             FROM enrollments e
             JOIN sections sec ON sec.section_id = e.section_id
                              AND sec.is_deleted = 0
                              AND sec.school_year_id = e.school_year_id
                              AND sec.grade_level_id = :gl_sec
             JOIN learners l ON l.learner_id = e.learner_id AND l.is_deleted = 0
             JOIN (' . $canonicalOfferingsSql . ') co ON co.section_id = e.section_id
                                                      AND co.school_year_id = e.school_year_id
             LEFT JOIN final_grades fg ON fg.enrollment_id = e.enrollment_id
                                      AND fg.class_id = co.class_id
                                      AND fg.is_deleted = 0
             LEFT JOIN (
                 SELECT g.enrollment_id, g.class_id,
                        ROUND(AVG(g.quarterly_grade), 2) AS computed_final,
                        COUNT(*) AS cnt
                 FROM grades g
                 JOIN grading_periods gp ON gp.grading_period_id = g.grading_period_id AND gp.school_year_id = :sy_gp
                 WHERE g.is_deleted = 0 AND g.quarterly_grade IS NOT NULL
                 GROUP BY g.enrollment_id, g.class_id
             ) gf ON gf.enrollment_id = e.enrollment_id AND gf.class_id = co.class_id
             JOIN (' . $secCountSql . ') sc ON sc.section_id = e.section_id
                                           AND sc.school_year_id = e.school_year_id
             WHERE e.is_deleted = 0
               AND e.enrollment_status = "Enrolled"
               AND e.school_year_id = :sy_main
               AND e.grade_level_id = :gl_enroll
             GROUP BY e.enrollment_id, e.section_id, sec.section_name, l.learner_id, l.lrn, learner_name, sc.subject_count';

        $stmt = $conn->prepare($sql);
        $stmt->bindValue(':expected_periods_avg', $expectedPeriods, PDO::PARAM_INT);
        $stmt->bindValue(':expected_periods_fill', $expectedPeriods, PDO::PARAM_INT);
        $stmt->bindValue(':gl_sec', $gradeLevelId, PDO::PARAM_INT);
        $stmt->bindValue(':sy_gp', $schoolYearId, PDO::PARAM_INT);
        $stmt->bindValue(':sy_count', $schoolYearId, PDO::PARAM_INT);
        $stmt->bindValue(':sy_main', $schoolYearId, PDO::PARAM_INT);
        $stmt->bindValue(':gl_enroll', $gradeLevelId, PDO::PARAM_INT);
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    $honorees = [];
    foreach ($rows as $r) {
        $filled = (int)($r['filled'] ?? 0);
        $subjectCount = (int)($r['subject_count'] ?? 0);
        if ($subjectCount <= 0 || $filled !== $subjectCount) {
            continue;
        }

        $avg = ($r['avg_grade'] === null || $r['avg_grade'] === '') ? null : round((float)$r['avg_grade'], 2);
        if ($avg === null) continue;

        $matched = null;
        foreach ($honorLevels as $hl) {
            $min = $hl['min_average'] === null ? null : (float)$hl['min_average'];
            $max = $hl['max_average'] === null ? null : (float)$hl['max_average'];
            if ($min !== null && $avg < $min) continue;
            if ($max !== null && $avg > $max) continue;
            $matched = [
                'honor_level_id' => (int)$hl['honor_level_id'],
                'honor_name' => $hl['honor_name'],
                'min_average' => $min,
                'max_average' => $max
            ];
            break;
        }

        if (!$matched) continue;

        $honorees[] = [
            'enrollment_id' => (int)$r['enrollment_id'],
            'learner_id' => (int)$r['learner_id'],
            'section_id' => (int)$r['section_id'],
            'section_name' => $r['section_name'] ?? '',
            'lrn' => $r['lrn'],
            'learner_name' => $r['learner_name'],
            'general_average' => $avg,
            'honor' => $matched
        ];
    }

    usort($honorees, fn($a, $b) => ($b['general_average'] ?? 0) <=> ($a['general_average'] ?? 0));

    $counts = ['total_enrolled' => $totalEnrolled, 'highest' => 0, 'high' => 0, 'honors' => 0];
    foreach ($honorees as $h) {
        $name = strtolower((string)($h['honor']['honor_name'] ?? ''));
        if (str_contains($name, 'highest')) $counts['highest']++;
        else if (str_contains($name, 'high')) $counts['high']++;
        else $counts['honors']++;
    }

    // Use the grade name and SY label from any section row.
    $any = $sections[0];
    $sectionMeta = [
        'section_id' => 0,
        'section_name' => 'All Sections',
        'grade_level_id' => (int)$any['grade_level_id'],
        'grade_name' => $any['grade_name'],
        'school_year_id' => (int)$any['school_year_id'],
        'year_label' => $any['year_label']
    ];

    respond([
        'success' => true,
        'data' => [
            'mode' => $mode,
            'section' => $sectionMeta,
            'subjects' => [],
            'honorees' => $honorees,
            'counts' => $counts
        ]
    ]);
}
?>
