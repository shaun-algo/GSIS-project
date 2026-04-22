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

$operation = $_GET['operation'] ?? '';
$session = auth_enforce_roles($operation, ['admin', 'teacher'], ['admin']);
try {
    switch ($operation) {
        case 'getAllHonorLevels':  getAllHonorLevels($conn); break;
        case 'createHonorLevel':  createHonorLevel($conn); break;
        case 'updateHonorLevel':  updateHonorLevel($conn); break;
        case 'deleteHonorLevel':  deleteHonorLevel($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllHonorLevels(PDO $conn): void {
    $stmt = $conn->prepare('SELECT honor_level_id, honor_name, min_average, max_average, description FROM honor_levels WHERE is_deleted = 0 ORDER BY min_average DESC');
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}
function createHonorLevel(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['honor_name']) || !isset($data['min_average']) || !isset($data['max_average'])) {
        respond(['success' => false, 'message' => 'Honor name and min/max average are required'], 422);
    }
    $stmt = $conn->prepare('INSERT INTO honor_levels (honor_name, min_average, max_average, description) VALUES (:honor_name, :min_average, :max_average, :description)');
    $stmt->bindValue(':honor_name', $data['honor_name']);
    $stmt->bindValue(':min_average', $data['min_average']);
    $stmt->bindValue(':max_average', $data['max_average']);
    $stmt->bindValue(':description', $data['description'] ?? null);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Honor level created', 'honor_level_id' => $conn->lastInsertId()]);
}
function updateHonorLevel(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['honor_level_id']) || empty($data['honor_name']) || !isset($data['min_average']) || !isset($data['max_average'])) {
        respond(['success' => false, 'message' => 'Honor name and min/max average are required'], 422);
    }
    $stmt = $conn->prepare('UPDATE honor_levels SET honor_name = :honor_name, min_average = :min_average, max_average = :max_average, description = :description WHERE honor_level_id = :honor_level_id');
    $stmt->bindValue(':honor_name', $data['honor_name']);
    $stmt->bindValue(':min_average', $data['min_average']);
    $stmt->bindValue(':max_average', $data['max_average']);
    $stmt->bindValue(':description', $data['description'] ?? null);
    $stmt->bindValue(':honor_level_id', $data['honor_level_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Honor level updated']);
}
function deleteHonorLevel(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['honor_level_id'])) respond(['success' => false, 'message' => 'ID is required'], 422);
    $stmt = $conn->prepare('UPDATE honor_levels SET is_deleted = 1, deleted_at = NOW() WHERE honor_level_id = :honor_level_id');
    $stmt->bindValue(':honor_level_id', $data['honor_level_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Honor level deleted']);
}
?>
