<?php
header('Content-Type: application/json');
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

function requireTeacherOwnsClassOffering(PDO $conn, int $employeeId, int $classId): void {
    $stmt = $conn->prepare(
        'SELECT 1 FROM class_offerings
         WHERE class_id = :class_id
           AND is_deleted = 0
           AND teacher_id = :eid
         LIMIT 1'
    );
    $stmt->bindValue(':class_id', $classId, PDO::PARAM_INT);
    $stmt->bindValue(':eid', $employeeId, PDO::PARAM_INT);
    $stmt->execute();
    if (!$stmt->fetchColumn()) {
        respond(['success' => false, 'message' => 'Not authorized for this class offering'], 403);
    }
}

function requireEnrollmentMatchesClassOffering(PDO $conn, int $enrollmentId, int $classId): void {
    $stmt = $conn->prepare(
        'SELECT 1
         FROM enrollments e
         JOIN class_offerings c ON c.class_id = :class_id AND c.is_deleted = 0
         WHERE e.enrollment_id = :enrollment_id
           AND e.is_deleted = 0
           AND e.section_id = c.section_id
           AND e.school_year_id = c.school_year_id
         LIMIT 1'
    );
    $stmt->bindValue(':class_id', $classId, PDO::PARAM_INT);
    $stmt->bindValue(':enrollment_id', $enrollmentId, PDO::PARAM_INT);
    $stmt->execute();
    if (!$stmt->fetchColumn()) {
        respond(['success' => false, 'message' => 'Enrollment does not match the class offering context'], 422);
    }
}

function requireTeacherOwnsGrade(PDO $conn, int $employeeId, int $gradeId): void {
    $stmt = $conn->prepare(
        'SELECT 1
         FROM grades g
         JOIN class_offerings c ON c.class_id = g.class_id
         WHERE g.grade_id = :grade_id
           AND g.is_deleted = 0
           AND c.is_deleted = 0
           AND c.teacher_id = :eid
         LIMIT 1'
    );
    $stmt->bindValue(':grade_id', $gradeId, PDO::PARAM_INT);
    $stmt->bindValue(':eid', $employeeId, PDO::PARAM_INT);
    $stmt->execute();
    if (!$stmt->fetchColumn()) {
        respond(['success' => false, 'message' => 'Not authorized for this grade record'], 403);
    }
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

function transmuteGrade(?float $initial): ?float {
    if ($initial === null) return null;
    $g = max(0.0, min(100.0, (float)$initial));

    if ($g <= 60.0) {
        $trans = 60.0 + ($g / 60.0) * 15.0;
    } else {
        $trans = 75.0 + (($g - 60.0) / 40.0) * 25.0;
    }

    return round(max(60.0, min(100.0, $trans)), 2);
}

function fetchEnrollmentContext(PDO $conn, int $enrollmentId): ?array {
    $stmt = $conn->prepare(
        'SELECT e.enrollment_id, e.school_year_id, e.grade_level_id,
                COALESCE(e.curriculum_id, csm.curriculum_id) AS curriculum_id
         FROM enrollments e
         LEFT JOIN curriculum_school_year_map csm ON csm.school_year_id = e.school_year_id
                                                 AND csm.is_primary = 1
                                                 AND csm.is_deleted = 0
         WHERE e.enrollment_id = :eid
           AND e.is_deleted = 0
         LIMIT 1'
    );
    $stmt->bindValue(':eid', $enrollmentId, PDO::PARAM_INT);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

function fetchGradingWeights(PDO $conn, int $curriculumId, int $gradeLevelId): array {
    $stmt = $conn->prepare(
        'SELECT component_code, weight_percent
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

    if (($weights['WW'] + $weights['PT'] + $weights['QE']) <= 0.01) {
        $weights = ['WW' => 30.0, 'PT' => 50.0, 'QE' => 20.0];
    }

    return $weights;
}

function computeInitialGrade(?float $ww, ?float $pt, ?float $qe, array $weights): ?float {
    if ($ww === null || $pt === null || $qe === null) return null;
    $initial = ($ww * ((float)$weights['WW'] / 100.0))
        + ($pt * ((float)$weights['PT'] / 100.0))
        + ($qe * ((float)$weights['QE'] / 100.0));
    return round($initial, 2);
}

function computeGradeValues(PDO $conn, int $enrollmentId, ?float $ww, ?float $pt, ?float $qe): array {
    if ($ww === null || $pt === null || $qe === null) {
        return ['initial' => null, 'quarterly' => null];
    }

    $ctx = fetchEnrollmentContext($conn, $enrollmentId);
    $curriculumId = (is_array($ctx) && is_numeric($ctx['curriculum_id'] ?? null)) ? (int)$ctx['curriculum_id'] : 0;
    $gradeLevelId = (is_array($ctx) && is_numeric($ctx['grade_level_id'] ?? null)) ? (int)$ctx['grade_level_id'] : 0;

    $weights = ['WW' => 30.0, 'PT' => 50.0, 'QE' => 20.0];
    if ($curriculumId > 0 && $gradeLevelId > 0) {
        $weights = fetchGradingWeights($conn, $curriculumId, $gradeLevelId);
    }

    $initial = computeInitialGrade($ww, $pt, $qe, $weights);
    $quarterly = transmuteGrade($initial);

    return ['initial' => $initial, 'quarterly' => $quarterly];
}

$operation = $_GET['operation'] ?? '';
$session = auth_enforce_roles($operation, ['admin', 'teacher'], ['admin', 'teacher']);
try {
    switch ($operation) {
        case 'getAllGrades': getAllGrades($conn, $session); break;
        case 'createGrade': createGrade($conn, $session); break;
        case 'updateGrade': updateGrade($conn, $session); break;
        case 'deleteGrade': deleteGrade($conn, $session); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllGrades(PDO $conn, array $session): void {
    $isTeacher = (($session['role_key'] ?? '') === 'teacher');
    $employeeId = $isTeacher ? getEmployeeIdForUser($conn, (int)($session['user_id'] ?? 0)) : 0;

    $sql = "SELECT g.grade_id, g.enrollment_id, g.class_id, g.grading_period_id,
                   g.written_works, g.performance_tasks, g.quarterly_exam, g.quarterly_grade,
                   CONCAT(l.last_name, ', ', l.first_name) AS learner_name,
                   s.subject_name, gp.period_name
            FROM grades g
            JOIN enrollments e ON g.enrollment_id = e.enrollment_id
            JOIN learners l ON e.learner_id = l.learner_id
            JOIN class_offerings c ON g.class_id = c.class_id
            JOIN subjects s ON c.subject_id = s.subject_id
            JOIN grading_periods gp ON g.grading_period_id = gp.grading_period_id
                        WHERE g.is_deleted = 0
                            AND c.is_deleted = 0";

    if ($isTeacher) {
        $sql .= " AND c.teacher_id = :teacher_id";
    }

    $sql .= " ORDER BY g.grade_id DESC";
    $stmt = $conn->prepare($sql);
    if ($isTeacher) {
        $stmt->bindValue(':teacher_id', $employeeId, PDO::PARAM_INT);
    }
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function createGrade(PDO $conn, array $session): void {
    $data = getJsonInput();
    if (empty($data['enrollment_id']) || empty($data['class_id']) || empty($data['grading_period_id'])) {
        respond(['success' => false, 'message' => 'Enrollment, class, and grading period are required'], 422);
    }

    $enrollmentId = (int)$data['enrollment_id'];
    $classId = (int)$data['class_id'];
    $gradingPeriodId = (int)$data['grading_period_id'];

    if (($session['role_key'] ?? '') === 'teacher') {
        $employeeId = getEmployeeIdForUser($conn, (int)($session['user_id'] ?? 0));
        requireTeacherOwnsClassOffering($conn, $employeeId, $classId);
    }

    requireEnrollmentMatchesClassOffering($conn, $enrollmentId, $classId);

    $ww = array_key_exists('written_works', $data) ? $data['written_works'] : null;
    $pt = array_key_exists('performance_tasks', $data) ? $data['performance_tasks'] : null;
    $qe = array_key_exists('quarterly_exam', $data) ? $data['quarterly_exam'] : null;

    $ww = ($ww === '' || $ww === null) ? null : (float)$ww;
    $pt = ($pt === '' || $pt === null) ? null : (float)$pt;
    $qe = ($qe === '' || $qe === null) ? null : (float)$qe;

    foreach ([['written_works', $ww], ['performance_tasks', $pt], ['quarterly_exam', $qe]] as $pair) {
        [$label, $val] = $pair;
        if ($val === null) continue;
        if ($val < 0 || $val > 100) {
            respond(['success' => false, 'message' => "{$label} must be between 0 and 100"], 422);
        }
    }

    $computed = computeGradeValues($conn, $enrollmentId, $ww, $pt, $qe);
    $hasInitial = gradesHasInitialGrade($conn);

    $sql = $hasInitial
        ? 'INSERT INTO grades (enrollment_id, class_id, grading_period_id, written_works, performance_tasks, quarterly_exam, initial_grade, quarterly_grade)
           VALUES (:enrollment_id, :class_id, :grading_period_id, :written_works, :performance_tasks, :quarterly_exam, :initial_grade, :quarterly_grade)'
        : 'INSERT INTO grades (enrollment_id, class_id, grading_period_id, written_works, performance_tasks, quarterly_exam, quarterly_grade)
           VALUES (:enrollment_id, :class_id, :grading_period_id, :written_works, :performance_tasks, :quarterly_exam, :quarterly_grade)';

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':enrollment_id', $enrollmentId, PDO::PARAM_INT);
    $stmt->bindValue(':class_id', $classId, PDO::PARAM_INT);
    $stmt->bindValue(':grading_period_id', $gradingPeriodId, PDO::PARAM_INT);

    if ($ww === null) $stmt->bindValue(':written_works', null, PDO::PARAM_NULL);
    else $stmt->bindValue(':written_works', $ww);

    if ($pt === null) $stmt->bindValue(':performance_tasks', null, PDO::PARAM_NULL);
    else $stmt->bindValue(':performance_tasks', $pt);

    if ($qe === null) $stmt->bindValue(':quarterly_exam', null, PDO::PARAM_NULL);
    else $stmt->bindValue(':quarterly_exam', $qe);

    if ($hasInitial) {
        if ($computed['initial'] === null) $stmt->bindValue(':initial_grade', null, PDO::PARAM_NULL);
        else $stmt->bindValue(':initial_grade', (float)$computed['initial']);
    }

    if ($computed['quarterly'] === null) $stmt->bindValue(':quarterly_grade', null, PDO::PARAM_NULL);
    else $stmt->bindValue(':quarterly_grade', (float)$computed['quarterly']);

    $stmt->execute();
    respond(['success' => true, 'message' => 'Grade created', 'grade_id' => $conn->lastInsertId()]);
}

function updateGrade(PDO $conn, array $session): void {
    $data = getJsonInput();
    if (empty($data['grade_id']) || empty($data['enrollment_id']) || empty($data['class_id']) || empty($data['grading_period_id'])) {
        respond(['success' => false, 'message' => 'Grade ID, enrollment, class, and grading period are required'], 422);
    }

    $gradeId = (int)$data['grade_id'];
    $enrollmentId = (int)$data['enrollment_id'];
    $classId = (int)$data['class_id'];
    $gradingPeriodId = (int)$data['grading_period_id'];

    if (($session['role_key'] ?? '') === 'teacher') {
        $employeeId = getEmployeeIdForUser($conn, (int)($session['user_id'] ?? 0));
        requireTeacherOwnsClassOffering($conn, $employeeId, $classId);
    }

    requireEnrollmentMatchesClassOffering($conn, $enrollmentId, $classId);

    $ww = array_key_exists('written_works', $data) ? $data['written_works'] : null;
    $pt = array_key_exists('performance_tasks', $data) ? $data['performance_tasks'] : null;
    $qe = array_key_exists('quarterly_exam', $data) ? $data['quarterly_exam'] : null;

    $ww = ($ww === '' || $ww === null) ? null : (float)$ww;
    $pt = ($pt === '' || $pt === null) ? null : (float)$pt;
    $qe = ($qe === '' || $qe === null) ? null : (float)$qe;

    foreach ([['written_works', $ww], ['performance_tasks', $pt], ['quarterly_exam', $qe]] as $pair) {
        [$label, $val] = $pair;
        if ($val === null) continue;
        if ($val < 0 || $val > 100) {
            respond(['success' => false, 'message' => "{$label} must be between 0 and 100"], 422);
        }
    }

    $computed = computeGradeValues($conn, $enrollmentId, $ww, $pt, $qe);
    $hasInitial = gradesHasInitialGrade($conn);

    $sql = $hasInitial
        ? 'UPDATE grades
           SET enrollment_id = :enrollment_id,
               class_id = :class_id,
               grading_period_id = :grading_period_id,
               written_works = :written_works,
               performance_tasks = :performance_tasks,
               quarterly_exam = :quarterly_exam,
               initial_grade = :initial_grade,
               quarterly_grade = :quarterly_grade
           WHERE grade_id = :grade_id'
        : 'UPDATE grades
           SET enrollment_id = :enrollment_id,
               class_id = :class_id,
               grading_period_id = :grading_period_id,
               written_works = :written_works,
               performance_tasks = :performance_tasks,
               quarterly_exam = :quarterly_exam,
               quarterly_grade = :quarterly_grade
           WHERE grade_id = :grade_id';

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':enrollment_id', $enrollmentId, PDO::PARAM_INT);
    $stmt->bindValue(':class_id', $classId, PDO::PARAM_INT);
    $stmt->bindValue(':grading_period_id', $gradingPeriodId, PDO::PARAM_INT);

    if ($ww === null) $stmt->bindValue(':written_works', null, PDO::PARAM_NULL);
    else $stmt->bindValue(':written_works', $ww);

    if ($pt === null) $stmt->bindValue(':performance_tasks', null, PDO::PARAM_NULL);
    else $stmt->bindValue(':performance_tasks', $pt);

    if ($qe === null) $stmt->bindValue(':quarterly_exam', null, PDO::PARAM_NULL);
    else $stmt->bindValue(':quarterly_exam', $qe);

    if ($hasInitial) {
        if ($computed['initial'] === null) $stmt->bindValue(':initial_grade', null, PDO::PARAM_NULL);
        else $stmt->bindValue(':initial_grade', (float)$computed['initial']);
    }

    if ($computed['quarterly'] === null) $stmt->bindValue(':quarterly_grade', null, PDO::PARAM_NULL);
    else $stmt->bindValue(':quarterly_grade', (float)$computed['quarterly']);

    $stmt->bindValue(':grade_id', $gradeId, PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Grade updated']);
}

function deleteGrade(PDO $conn, array $session): void {
    $data = getJsonInput();
    if (empty($data['grade_id'])) {
        respond(['success' => false, 'message' => 'Grade ID is required'], 422);
    }

    if (($session['role_key'] ?? '') === 'teacher') {
        $employeeId = getEmployeeIdForUser($conn, (int)($session['user_id'] ?? 0));
        requireTeacherOwnsGrade($conn, $employeeId, (int)$data['grade_id']);
    }

    $stmt = $conn->prepare('UPDATE grades SET is_deleted = 1, deleted_at = NOW() WHERE grade_id = :grade_id');
    $stmt->bindValue(':grade_id', $data['grade_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Grade deleted']);
}
?>
