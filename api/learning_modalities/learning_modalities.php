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

$operation = $_GET['operation'] ?? '';
$session = auth_enforce_roles($operation, ['admin', 'teacher'], ['admin']);
try {
    switch ($operation) {
        case 'getAllLearningModalities':  getAllLearningModalities($conn); break;
        case 'createLearningModality':  createLearningModality($conn); break;
        case 'updateLearningModality':  updateLearningModality($conn); break;
        case 'deleteLearningModality':  deleteLearningModality($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllLearningModalities(PDO $conn): void {
    $stmt = $conn->prepare('SELECT modality_id, modality_name, description FROM learning_modalities WHERE is_deleted = 0 ORDER BY modality_name');
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}
function createLearningModality(PDO $conn): void {
    $data = getJsonInput();
    $modalityName = trim((string) ($data['modality_name'] ?? ''));
    if ($modalityName === '') respond(['success' => false, 'message' => 'Modality name is required'], 422);
    $check = $conn->prepare('SELECT modality_id, is_deleted FROM learning_modalities WHERE modality_name = :modality_name LIMIT 1');
    $check->bindValue(':modality_name', $modalityName);
    $check->execute();
    $existing = $check->fetch(PDO::FETCH_ASSOC);
    if ($existing && (int) $existing['is_deleted'] === 0) {
        respond(['success' => false, 'message' => 'Learning modality already exists'], 409);
    }
    if ($existing && (int) $existing['is_deleted'] === 1) {
        respond(['success' => false, 'message' => 'Learning modality exists but is deleted. Restore it instead.'], 409);
    }
    $stmt = $conn->prepare('INSERT INTO learning_modalities (modality_name, description) VALUES (:modality_name, :description)');
    $stmt->bindValue(':modality_name', $modalityName);
    $stmt->bindValue(':description', $data['description'] ?? null);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Learning modality created', 'modality_id' => $conn->lastInsertId()]);
}
function updateLearningModality(PDO $conn): void {
    $data = getJsonInput();
    $modalityName = trim((string) ($data['modality_name'] ?? ''));
    if (empty($data['modality_id']) || $modalityName === '') respond(['success' => false, 'message' => 'ID and modality name are required'], 422);
    $check = $conn->prepare('SELECT modality_id, is_deleted FROM learning_modalities WHERE modality_name = :modality_name AND modality_id <> :modality_id LIMIT 1');
    $check->bindValue(':modality_name', $modalityName);
    $check->bindValue(':modality_id', $data['modality_id'], PDO::PARAM_INT);
    $check->execute();
    $existing = $check->fetch(PDO::FETCH_ASSOC);
    if ($existing && (int) $existing['is_deleted'] === 0) {
        respond(['success' => false, 'message' => 'Learning modality already exists'], 409);
    }
    if ($existing && (int) $existing['is_deleted'] === 1) {
        respond(['success' => false, 'message' => 'Learning modality exists but is deleted. Restore it instead.'], 409);
    }
    $stmt = $conn->prepare('UPDATE learning_modalities SET modality_name = :modality_name, description = :description WHERE modality_id = :modality_id');
    $stmt->bindValue(':modality_name', $modalityName);
    $stmt->bindValue(':description', $data['description'] ?? null);
    $stmt->bindValue(':modality_id', $data['modality_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Learning modality updated']);
}
function deleteLearningModality(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['modality_id'])) respond(['success' => false, 'message' => 'ID is required'], 422);
    $stmt = $conn->prepare('UPDATE learning_modalities SET is_deleted = 1, deleted_at = NOW() WHERE modality_id = :modality_id');
    $stmt->bindValue(':modality_id', $data['modality_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Learning modality deleted']);
}
?>
