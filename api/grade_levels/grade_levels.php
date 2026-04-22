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
        case 'getAllGradeLevels':
            getAllGradeLevels($conn);
            break;
        case 'createGradeLevel':
            createGradeLevel($conn);
            break;
        case 'updateGradeLevel':
            updateGradeLevel($conn);
            break;
        case 'deleteGradeLevel':
            deleteGradeLevel($conn);
            break;
        default:
            respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllGradeLevels(PDO $conn): void {
    $sql = 'SELECT gl.grade_level_id, gl.grade_name, gl.education_level_id, el.level_name
            FROM grade_levels gl
            LEFT JOIN education_levels el ON gl.education_level_id = el.education_level_id
            WHERE gl.is_deleted = 0
            ORDER BY gl.grade_level_id';
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function createGradeLevel(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['grade_name']) || empty($data['education_level_id'])) {
        respond(['success' => false, 'message' => 'Grade name and education level are required'], 422);
    }

    $stmt = $conn->prepare('INSERT INTO grade_levels (grade_name, education_level_id) VALUES (:grade_name, :education_level_id)');
    $stmt->bindValue(':grade_name', $data['grade_name']);
    $stmt->bindValue(':education_level_id', $data['education_level_id'], PDO::PARAM_INT);
    $stmt->execute();

    respond(['success' => true, 'message' => 'Grade level created', 'grade_level_id' => $conn->lastInsertId()]);
}

function updateGradeLevel(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['grade_level_id']) || empty($data['grade_name']) || empty($data['education_level_id'])) {
        respond(['success' => false, 'message' => 'Grade level ID, name, and education level are required'], 422);
    }

    $stmt = $conn->prepare('UPDATE grade_levels SET grade_name = :grade_name, education_level_id = :education_level_id WHERE grade_level_id = :grade_level_id');
    $stmt->bindValue(':grade_name', $data['grade_name']);
    $stmt->bindValue(':education_level_id', $data['education_level_id'], PDO::PARAM_INT);
    $stmt->bindValue(':grade_level_id', $data['grade_level_id'], PDO::PARAM_INT);
    $stmt->execute();

    respond(['success' => true, 'message' => 'Grade level updated']);
}

function deleteGradeLevel(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['grade_level_id'])) {
        respond(['success' => false, 'message' => 'Grade level ID is required'], 422);
    }

    $stmt = $conn->prepare('UPDATE grade_levels SET is_deleted = 1, deleted_at = NOW() WHERE grade_level_id = :grade_level_id');
    $stmt->bindValue(':grade_level_id', $data['grade_level_id'], PDO::PARAM_INT);
    $stmt->execute();

    respond(['success' => true, 'message' => 'Grade level deleted']);
}
?>
