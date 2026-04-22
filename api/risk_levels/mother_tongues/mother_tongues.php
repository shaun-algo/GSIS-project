<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

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
        case 'getAllMotherTongues':  getAllMotherTongues($conn); break;
        case 'createMotherTongue':  createMotherTongue($conn); break;
        case 'updateMotherTongue':  updateMotherTongue($conn); break;
        case 'deleteMotherTongue':  deleteMotherTongue($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllMotherTongues(PDO $conn): void {
    $stmt = $conn->prepare('SELECT mother_tongue_id, tongue_name FROM mother_tongues WHERE is_deleted = 0 ORDER BY tongue_name');
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}
function createMotherTongue(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['tongue_name'])) respond(['success' => false, 'message' => 'Tongue name is required'], 422);
    $stmt = $conn->prepare('INSERT INTO mother_tongues (tongue_name) VALUES (:tongue_name)');
    $stmt->bindValue(':tongue_name', $data['tongue_name']);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Mother tongue created', 'mother_tongue_id' => $conn->lastInsertId()]);
}
function updateMotherTongue(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['mother_tongue_id']) || empty($data['tongue_name'])) respond(['success' => false, 'message' => 'ID and tongue name are required'], 422);
    $stmt = $conn->prepare('UPDATE mother_tongues SET tongue_name = :tongue_name WHERE mother_tongue_id = :mother_tongue_id');
    $stmt->bindValue(':tongue_name', $data['tongue_name']);
    $stmt->bindValue(':mother_tongue_id', $data['mother_tongue_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Mother tongue updated']);
}
function deleteMotherTongue(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['mother_tongue_id'])) respond(['success' => false, 'message' => 'ID is required'], 422);
    $stmt = $conn->prepare('UPDATE mother_tongues SET is_deleted = 1, deleted_at = NOW() WHERE mother_tongue_id = :mother_tongue_id');
    $stmt->bindValue(':mother_tongue_id', $data['mother_tongue_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Mother tongue deleted']);
}
?>
