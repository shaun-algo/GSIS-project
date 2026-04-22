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
$session = auth_enforce_roles($operation, ['admin', 'teacher'], ['admin']);

try {
    switch ($operation) {
        case 'getAllEducationLevels':
            getAllEducationLevels($conn);
            break;
        case 'createEducationLevel':
            createEducationLevel($conn);
            break;
        case 'updateEducationLevel':
            updateEducationLevel($conn);
            break;
        case 'deleteEducationLevel':
            deleteEducationLevel($conn);
            break;
        default:
            respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllEducationLevels(PDO $conn): void {
    $stmt = $conn->prepare('SELECT education_level_id, level_name FROM education_levels WHERE is_deleted = 0 ORDER BY education_level_id');
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function createEducationLevel(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['level_name'])) {
        respond(['success' => false, 'message' => 'Level name is required'], 422);
    }

    $stmt = $conn->prepare('INSERT INTO education_levels (level_name) VALUES (:level_name)');
    $stmt->bindValue(':level_name', $data['level_name']);
    $stmt->execute();

    respond(['success' => true, 'message' => 'Education level created', 'education_level_id' => $conn->lastInsertId()]);
}

function updateEducationLevel(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['education_level_id']) || empty($data['level_name'])) {
        respond(['success' => false, 'message' => 'Education level ID and name are required'], 422);
    }

    $stmt = $conn->prepare('UPDATE education_levels SET level_name = :level_name WHERE education_level_id = :education_level_id');
    $stmt->bindValue(':level_name', $data['level_name']);
    $stmt->bindValue(':education_level_id', $data['education_level_id'], PDO::PARAM_INT);
    $stmt->execute();

    respond(['success' => true, 'message' => 'Education level updated']);
}

function deleteEducationLevel(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['education_level_id'])) {
        respond(['success' => false, 'message' => 'Education level ID is required'], 422);
    }

    $stmt = $conn->prepare('UPDATE education_levels SET is_deleted = 1, deleted_at = NOW() WHERE education_level_id = :education_level_id');
    $stmt->bindValue(':education_level_id', $data['education_level_id'], PDO::PARAM_INT);
    $stmt->execute();

    respond(['success' => true, 'message' => 'Education level deleted']);
}
?>
