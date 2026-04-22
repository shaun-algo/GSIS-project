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
        case 'getAllInterventionStatuses':  getAllInterventionStatuses($conn); break;
        case 'createInterventionStatus':  createInterventionStatus($conn); break;
        case 'updateInterventionStatus':  updateInterventionStatus($conn); break;
        case 'deleteInterventionStatus':  deleteInterventionStatus($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllInterventionStatuses(PDO $conn): void {
    $stmt = $conn->prepare('SELECT intervention_status_id, status_name, description FROM intervention_statuses WHERE is_deleted = 0 ORDER BY status_name');
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}
function createInterventionStatus(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['status_name'])) respond(['success' => false, 'message' => 'Status name is required'], 422);
    $stmt = $conn->prepare('INSERT INTO intervention_statuses (status_name, description) VALUES (:status_name, :description)');
    $stmt->bindValue(':status_name', $data['status_name']);
    $stmt->bindValue(':description', $data['description'] ?? null);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Intervention status created', 'intervention_status_id' => $conn->lastInsertId()]);
}
function updateInterventionStatus(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['intervention_status_id']) || empty($data['status_name'])) respond(['success' => false, 'message' => 'ID and status name are required'], 422);
    $stmt = $conn->prepare('UPDATE intervention_statuses SET status_name = :status_name, description = :description WHERE intervention_status_id = :intervention_status_id');
    $stmt->bindValue(':status_name', $data['status_name']);
    $stmt->bindValue(':description', $data['description'] ?? null);
    $stmt->bindValue(':intervention_status_id', $data['intervention_status_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Intervention status updated']);
}
function deleteInterventionStatus(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['intervention_status_id'])) respond(['success' => false, 'message' => 'ID is required'], 422);
    $stmt = $conn->prepare('UPDATE intervention_statuses SET is_deleted = 1, deleted_at = NOW() WHERE intervention_status_id = :intervention_status_id');
    $stmt->bindValue(':intervention_status_id', $data['intervention_status_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Intervention status deleted']);
}
?>
