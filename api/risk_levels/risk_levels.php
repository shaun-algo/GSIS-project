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
        case 'getAllRiskLevels':  getAllRiskLevels($conn); break;
        case 'createRiskLevel':  createRiskLevel($conn); break;
        case 'updateRiskLevel':  updateRiskLevel($conn); break;
        case 'deleteRiskLevel':  deleteRiskLevel($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllRiskLevels(PDO $conn): void {
    $stmt = $conn->prepare('SELECT risk_level_id, risk_name FROM risk_levels WHERE is_deleted = 0 ORDER BY risk_level_id');
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}
function createRiskLevel(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['risk_name'])) respond(['success' => false, 'message' => 'Risk name is required'], 422);
    $stmt = $conn->prepare('INSERT INTO risk_levels (risk_name) VALUES (:risk_name)');
    $stmt->bindValue(':risk_name', $data['risk_name']);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Risk level created', 'risk_level_id' => $conn->lastInsertId()]);
}
function updateRiskLevel(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['risk_level_id']) || empty($data['risk_name'])) respond(['success' => false, 'message' => 'ID and risk name are required'], 422);
    $stmt = $conn->prepare('UPDATE risk_levels SET risk_name = :risk_name WHERE risk_level_id = :risk_level_id');
    $stmt->bindValue(':risk_name', $data['risk_name']);
    $stmt->bindValue(':risk_level_id', $data['risk_level_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Risk level updated']);
}
function deleteRiskLevel(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['risk_level_id'])) respond(['success' => false, 'message' => 'ID is required'], 422);
    $stmt = $conn->prepare('UPDATE risk_levels SET is_deleted = 1, deleted_at = NOW() WHERE risk_level_id = :risk_level_id');
    $stmt->bindValue(':risk_level_id', $data['risk_level_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Risk level deleted']);
}
?>
