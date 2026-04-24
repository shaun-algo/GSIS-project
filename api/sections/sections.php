<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/../utils/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once __DIR__ . '/../database/connection.php';

require_once __DIR__ . '/../utils/auth.php';
require_once __DIR__ . '/../utils/audit.php';

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

$operation = $_GET['operation'] ?? '';
$session = auth_enforce_roles($operation, ['admin', 'teacher', 'registrar'], ['admin']);

try {
    switch ($operation) {
        case 'getAllSections':
            getAllSections($conn, $session);
            break;
        case 'getSectionsByGradeLevel':
            getSectionsByGradeLevel($conn, $session);
            break;
        case 'createSection':
            createSection($conn);
            break;
        case 'updateSection':
            updateSection($conn);
            break;
        case 'deleteSection':
            deleteSection($conn);
            break;
        default:
            respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllSections(PDO $conn, array $session): void {
    $schoolYearId = (int)($_GET['school_year_id'] ?? 0);
    $includeAll = (int)($_GET['include_all'] ?? 0);

    if ($schoolYearId <= 0 && $includeAll !== 1) {
        $schoolYearId = (int)($conn->query("SELECT school_year_id FROM school_years WHERE is_active = 1 AND is_deleted = 0 ORDER BY year_start DESC LIMIT 1")->fetchColumn() ?? 0);
    }

    $sql = "SELECT s.section_id, s.section_name, s.grade_level_id, gl.grade_name,
                                     s.school_year_id, sy.year_label,
                                     s.adviser_id,
                                     CONCAT(COALESCE(emp.last_name, ''), CASE WHEN emp.last_name IS NOT NULL THEN ', ' ELSE '' END, COALESCE(emp.first_name, '')) AS adviser_name,
                                     s.max_capacity,
                                     COALESCE(ec.enrolled_count, 0) AS enrolled_count,
                                     GREATEST(s.max_capacity - COALESCE(ec.enrolled_count, 0), 0) AS available_slots,
                                     CASE WHEN COALESCE(ec.enrolled_count, 0) >= s.max_capacity THEN 1 ELSE 0 END AS is_full
                        FROM sections s
                        LEFT JOIN grade_levels gl ON s.grade_level_id = gl.grade_level_id
                        LEFT JOIN school_years sy ON s.school_year_id = sy.school_year_id
                        LEFT JOIN employees emp ON s.adviser_id = emp.employee_id
                        LEFT JOIN (
                                SELECT e.section_id, e.school_year_id, COUNT(*) AS enrolled_count
                                FROM enrollments e
                                WHERE e.is_deleted = 0
                                    AND (e.enrollment_status = 'Enrolled' OR e.enrollment_status IS NULL)
                                GROUP BY e.section_id, e.school_year_id
                        ) ec ON ec.section_id = s.section_id AND ec.school_year_id = s.school_year_id
                        WHERE s.is_deleted = 0";

    $roleKey = (string)($session['role_key'] ?? '');
    $employeeId = 0;
    if ($roleKey === 'teacher') {
        $employeeId = getEmployeeIdForUser($conn, (int)($session['user_id'] ?? 0));
        $sql .= ' AND (
                    s.adviser_id = :adviser_eid
                    OR EXISTS (
                        SELECT 1
                        FROM class_offerings co2
                        WHERE co2.is_deleted = 0
                          AND co2.section_id = s.section_id
                          AND co2.school_year_id = s.school_year_id
                          AND co2.teacher_id = :co_eid
                    )
                  )';
    }

    $sql .= ($schoolYearId > 0 ? ' AND s.school_year_id = :school_year_id' : '') .
                     ' ORDER BY sy.year_label DESC, gl.grade_name, s.section_name';
    $stmt = $conn->prepare($sql);
    if ($roleKey === 'teacher') {
        $stmt->bindValue(':adviser_eid', $employeeId, PDO::PARAM_INT);
        $stmt->bindValue(':co_eid', $employeeId, PDO::PARAM_INT);
    }
    if ($schoolYearId > 0) {
        $stmt->bindValue(':school_year_id', $schoolYearId, PDO::PARAM_INT);
    }
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function getSectionsByGradeLevel(PDO $conn, array $session): void {
    $gradeLevelId = (int)($_GET['grade_level_id'] ?? 0);
    $schoolYearId = (int)($_GET['school_year_id'] ?? 0);
    $onlyWithSlots = (int)($_GET['only_with_slots'] ?? 0);
    if ($gradeLevelId <= 0) {
        respond(['success' => false, 'message' => 'grade_level_id is required'], 422);
    }

    if ($schoolYearId <= 0) {
        $schoolYearId = (int)($conn->query("SELECT school_year_id FROM school_years WHERE is_active = 1 AND is_deleted = 0 ORDER BY year_start DESC LIMIT 1")->fetchColumn() ?? 0);
    }

    $sql = "SELECT s.section_id, s.section_name, s.grade_level_id,
                                     s.school_year_id, s.adviser_id, s.max_capacity,
                                     COALESCE(ec.enrolled_count, 0) AS enrolled_count,
                                     GREATEST(s.max_capacity - COALESCE(ec.enrolled_count, 0), 0) AS available_slots,
                                     CASE WHEN COALESCE(ec.enrolled_count, 0) >= s.max_capacity THEN 1 ELSE 0 END AS is_full
                        FROM sections s
                        LEFT JOIN (
                                SELECT e.section_id, e.school_year_id, COUNT(*) AS enrolled_count
                                FROM enrollments e
                                WHERE e.is_deleted = 0
                                    AND (e.enrollment_status = 'Enrolled' OR e.enrollment_status IS NULL)
                                GROUP BY e.section_id, e.school_year_id
                        ) ec ON ec.section_id = s.section_id AND ec.school_year_id = s.school_year_id
                        WHERE s.is_deleted = 0
                            AND s.grade_level_id = :grade_level_id";

    $roleKey = (string)($session['role_key'] ?? '');
    $employeeId = 0;
    if ($roleKey === 'teacher') {
        $employeeId = getEmployeeIdForUser($conn, (int)($session['user_id'] ?? 0));
        $sql .= ' AND (
                    s.adviser_id = :adviser_eid
                    OR EXISTS (
                        SELECT 1
                        FROM class_offerings co2
                        WHERE co2.is_deleted = 0
                          AND co2.section_id = s.section_id
                          AND co2.school_year_id = s.school_year_id
                          AND co2.teacher_id = :co_eid
                    )
                  )';
    }

    $sql .= ($schoolYearId > 0 ? ' AND s.school_year_id = :school_year_id' : '')
         . ($onlyWithSlots === 1 ? ' AND COALESCE(ec.enrolled_count, 0) < s.max_capacity' : '')
         . ' ORDER BY s.section_name';
    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':grade_level_id', $gradeLevelId, PDO::PARAM_INT);
    if ($roleKey === 'teacher') {
        $stmt->bindValue(':adviser_eid', $employeeId, PDO::PARAM_INT);
        $stmt->bindValue(':co_eid', $employeeId, PDO::PARAM_INT);
    }
    if ($schoolYearId > 0) {
        $stmt->bindValue(':school_year_id', $schoolYearId, PDO::PARAM_INT);
    }
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function createSection(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['section_name']) || empty($data['grade_level_id']) || empty($data['school_year_id'])) {
        respond(['success' => false, 'message' => 'Section name, grade level, and school year are required'], 422);
    }

    $adviserId = null;
    if (isset($data['adviser_id']) && $data['adviser_id'] !== '') {
        $adviserId = (int)$data['adviser_id'];
        if ($adviserId <= 0) {
            $adviserId = null;
        }
    }

    $maxCapacity = isset($data['max_capacity']) && $data['max_capacity'] !== '' ? (int)$data['max_capacity'] : 45;
    if ($maxCapacity <= 0 || $maxCapacity > 60) {
        respond(['success' => false, 'message' => 'max_capacity must be between 1 and 60'], 422);
    }

    $stmt = $conn->prepare('INSERT INTO sections (grade_level_id, section_name, school_year_id, adviser_id, max_capacity) VALUES (:grade_level_id, :section_name, :school_year_id, :adviser_id, :max_capacity)');
    $stmt->bindValue(':grade_level_id', $data['grade_level_id'], PDO::PARAM_INT);
    $stmt->bindValue(':section_name', $data['section_name']);
    $stmt->bindValue(':school_year_id', (int)$data['school_year_id'], PDO::PARAM_INT);
    $stmt->bindValue(':adviser_id', $adviserId, $adviserId === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
    $stmt->bindValue(':max_capacity', $maxCapacity, PDO::PARAM_INT);
    $stmt->execute();

    $sectionId = (int)$conn->lastInsertId();
    audit_log($conn, 'sections', $sectionId, 'INSERT', null, [
        'section_id' => $sectionId,
        'section_name' => $data['section_name'],
        'grade_level_id' => (int)$data['grade_level_id'],
        'school_year_id' => (int)$data['school_year_id'],
    ]);

    respond(['success' => true, 'message' => 'Section created', 'section_id' => $sectionId]);
}

function updateSection(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['section_id']) || empty($data['section_name']) || empty($data['grade_level_id']) || empty($data['school_year_id'])) {
        respond(['success' => false, 'message' => 'Section ID, name, grade level, and school year are required'], 422);
    }

    $adviserIsSet = array_key_exists('adviser_id', $data) ? 1 : 0;
    $adviserId = null;
    if ($adviserIsSet === 1) {
        $adviserId = isset($data['adviser_id']) && $data['adviser_id'] !== '' ? (int)$data['adviser_id'] : null;
        if ($adviserId !== null && $adviserId <= 0) {
            $adviserId = null;
        }
    }

    $maxCapacity = isset($data['max_capacity']) && $data['max_capacity'] !== '' ? (int)$data['max_capacity'] : null;
    if ($maxCapacity !== null && ($maxCapacity <= 0 || $maxCapacity > 60)) {
        respond(['success' => false, 'message' => 'max_capacity must be between 1 and 60'], 422);
    }

    $stmt = $conn->prepare('UPDATE sections
                            SET section_name = :section_name,
                                grade_level_id = :grade_level_id,
                                school_year_id = :school_year_id,
                                adviser_id = CASE WHEN :adviser_is_set = 1 THEN :adviser_id ELSE adviser_id END,
                                max_capacity = COALESCE(:max_capacity, max_capacity)
                            WHERE section_id = :section_id');
    $stmt->bindValue(':section_name', $data['section_name']);
    $stmt->bindValue(':grade_level_id', $data['grade_level_id'], PDO::PARAM_INT);
    $stmt->bindValue(':school_year_id', (int)$data['school_year_id'], PDO::PARAM_INT);
    $stmt->bindValue(':adviser_is_set', $adviserIsSet, PDO::PARAM_INT);
    $stmt->bindValue(':adviser_id', $adviserId, $adviserId === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
    $stmt->bindValue(':max_capacity', $maxCapacity, $maxCapacity === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
    $stmt->bindValue(':section_id', $data['section_id'], PDO::PARAM_INT);
    $stmt->execute();

    $oldRow = audit_fetch_old($conn, 'sections', 'section_id', (int)$data['section_id']);
    audit_log($conn, 'sections', (int)$data['section_id'], 'UPDATE', $oldRow, [
        'section_id' => (int)$data['section_id'],
        'section_name' => $data['section_name'],
        'grade_level_id' => (int)$data['grade_level_id'],
    ]);

    respond(['success' => true, 'message' => 'Section updated']);
}

function deleteSection(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['section_id'])) {
        respond(['success' => false, 'message' => 'Section ID is required'], 422);
    }

    $stmt = $conn->prepare('UPDATE sections SET is_deleted = 1, deleted_at = NOW() WHERE section_id = :section_id');
    $stmt->bindValue(':section_id', $data['section_id'], PDO::PARAM_INT);
    $stmt->execute();

    $oldRow = audit_fetch_old($conn, 'sections', 'section_id', (int)$data['section_id']);
    audit_log($conn, 'sections', (int)$data['section_id'], 'DELETE', $oldRow, null);

    respond(['success' => true, 'message' => 'Section deleted']);
}
?>
