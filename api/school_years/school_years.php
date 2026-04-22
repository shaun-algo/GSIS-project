<?php
header('Content-Type: application/json');

require_once __DIR__ . '/../utils/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

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

$operation = $_GET['operation'] ?? '';
$session = auth_enforce_roles($operation, ['admin', 'teacher', 'registrar'], ['admin']);

try {
    switch ($operation) {
        case 'getAllSchoolYears':
            getAllSchoolYears($conn);
            break;
        case 'createSchoolYear':
            createSchoolYear($conn);
            break;
        case 'updateSchoolYear':
            updateSchoolYear($conn);
            break;
        case 'deleteSchoolYear':
            deleteSchoolYear($conn);
            break;
        default:
            respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllSchoolYears(PDO $conn): void {
    $sql = 'SELECT sy.school_year_id, sy.year_start, sy.year_end, sy.year_label, sy.date_start, sy.date_end,
                   sy.grading_system_type, sy.is_active
            FROM school_years sy
            WHERE sy.is_deleted = 0
            ORDER BY sy.year_start DESC, sy.year_end DESC';
    $stmt = $conn->prepare($sql);
    $stmt->execute();

    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($rows as &$row) {
        $row['system_name'] = $row['grading_system_type'];
        $row['grading_system_type_id'] = match ($row['grading_system_type']) {
            'Quarterly' => 1,
            'Trimester' => 2,
            'Semester' => 3,
            default => null,
        };
    }
    unset($row);
    respond($rows);
}

function createSchoolYear(PDO $conn): void {
    $data = getJsonInput();

    $gradingSystemType = trim((string)($data['grading_system_type'] ?? ''));
    $gradingSystemTypeId = isset($data['grading_system_type_id']) ? (int)$data['grading_system_type_id'] : 0;
    if ($gradingSystemType === '' && $gradingSystemTypeId > 0) {
        $idMap = [1 => 'Quarterly', 2 => 'Trimester', 3 => 'Semester'];
        $gradingSystemType = $idMap[$gradingSystemTypeId] ?? '';
    }
    if (empty($data['year_start']) || empty($data['year_end']) || $gradingSystemType === '') {
        respond(['success' => false, 'message' => 'Year start, year end, and grading_system_type (or grading_system_type_id) are required'], 422);
    }
    $allowed = ['Quarterly','Trimester','Semester'];
    if (!in_array($gradingSystemType, $allowed, true)) {
        respond(['success' => false, 'message' => 'Invalid grading_system_type'], 422);
    }

    $yearLabel = trim((string)($data['year_label'] ?? ''));
    if ($yearLabel === '') {
        $yearLabel = $data['year_start'] . '-' . $data['year_end'];
    }

    $isActive = isset($data['is_active']) ? (int)!!$data['is_active'] : 0;

    if ($isActive === 1) {
        $conn->exec('UPDATE school_years SET is_active = 0 WHERE is_deleted = 0');
    }

    $stmt = $conn->prepare('INSERT INTO school_years (year_start, year_end, year_label, date_start, date_end, grading_system_type, is_active) VALUES (:year_start, :year_end, :year_label, :date_start, :date_end, :grading_system_type, :is_active)');
    $stmt->bindValue(':year_start', $data['year_start']);
    $stmt->bindValue(':year_end', $data['year_end']);
    $stmt->bindValue(':year_label', $yearLabel);
    $stmt->bindValue(':date_start', $data['date_start'] ?? null);
    $stmt->bindValue(':date_end', $data['date_end'] ?? null);
    $stmt->bindValue(':grading_system_type', $gradingSystemType);
    $stmt->bindValue(':is_active', $isActive, PDO::PARAM_INT);
    $stmt->execute();

    respond(['success' => true, 'message' => 'School year created', 'school_year_id' => $conn->lastInsertId()]);
}

function updateSchoolYear(PDO $conn): void {
    $data = getJsonInput();

    $gradingSystemType = trim((string)($data['grading_system_type'] ?? ''));
    $gradingSystemTypeId = isset($data['grading_system_type_id']) ? (int)$data['grading_system_type_id'] : 0;
    if ($gradingSystemType === '' && $gradingSystemTypeId > 0) {
        $idMap = [1 => 'Quarterly', 2 => 'Trimester', 3 => 'Semester'];
        $gradingSystemType = $idMap[$gradingSystemTypeId] ?? '';
    }
    if (empty($data['school_year_id']) || empty($data['year_start']) || empty($data['year_end']) || $gradingSystemType === '') {
        respond(['success' => false, 'message' => 'School year ID, years, and grading_system_type (or grading_system_type_id) are required'], 422);
    }
    $allowed = ['Quarterly','Trimester','Semester'];
    if (!in_array($gradingSystemType, $allowed, true)) {
        respond(['success' => false, 'message' => 'Invalid grading_system_type'], 422);
    }

    $yearLabel = trim((string)($data['year_label'] ?? ''));
    if ($yearLabel === '') {
        $yearLabel = $data['year_start'] . '-' . $data['year_end'];
    }

    $isActive = isset($data['is_active']) ? (int)!!$data['is_active'] : 0;
    if ($isActive === 1) {
        $reset = $conn->prepare('UPDATE school_years SET is_active = 0 WHERE is_deleted = 0 AND school_year_id <> :id');
        $reset->bindValue(':id', $data['school_year_id'], PDO::PARAM_INT);
        $reset->execute();
    }

    $stmt = $conn->prepare('UPDATE school_years SET year_start = :year_start, year_end = :year_end, year_label = :year_label, date_start = :date_start, date_end = :date_end, grading_system_type = :grading_system_type, is_active = :is_active WHERE school_year_id = :school_year_id');
    $stmt->bindValue(':year_start', $data['year_start']);
    $stmt->bindValue(':year_end', $data['year_end']);
    $stmt->bindValue(':year_label', $yearLabel);
    $stmt->bindValue(':date_start', $data['date_start'] ?? null);
    $stmt->bindValue(':date_end', $data['date_end'] ?? null);
    $stmt->bindValue(':grading_system_type', $gradingSystemType);
    $stmt->bindValue(':is_active', $isActive, PDO::PARAM_INT);
    $stmt->bindValue(':school_year_id', $data['school_year_id'], PDO::PARAM_INT);
    $stmt->execute();

    respond(['success' => true, 'message' => 'School year updated']);
}

function deleteSchoolYear(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['school_year_id'])) {
        respond(['success' => false, 'message' => 'School year ID is required'], 422);
    }

    $stmt = $conn->prepare('UPDATE school_years SET is_deleted = 1, deleted_at = NOW() WHERE school_year_id = :school_year_id');
    $stmt->bindValue(':school_year_id', $data['school_year_id'], PDO::PARAM_INT);
    $stmt->execute();

    respond(['success' => true, 'message' => 'School year deleted']);
}
?>
