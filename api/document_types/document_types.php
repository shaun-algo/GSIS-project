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
        case 'getAllDocumentTypes':  getAllDocumentTypes($conn); break;
        case 'createDocumentType':  createDocumentType($conn); break;
        case 'updateDocumentType':  updateDocumentType($conn); break;
        case 'deleteDocumentType':  deleteDocumentType($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllDocumentTypes(PDO $conn): void {
    $stmt = $conn->prepare('SELECT document_type_id, type_name, description FROM document_types WHERE is_deleted = 0 ORDER BY type_name');
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}
function createDocumentType(PDO $conn): void {
    $data = getJsonInput();
    $typeName = trim((string) ($data['type_name'] ?? ''));
    if ($typeName === '') respond(['success' => false, 'message' => 'Document type name is required'], 422);
    $check = $conn->prepare('SELECT document_type_id, is_deleted FROM document_types WHERE type_name = :type_name LIMIT 1');
    $check->bindValue(':type_name', $typeName);
    $check->execute();
    $existing = $check->fetch(PDO::FETCH_ASSOC);
    if ($existing && (int) $existing['is_deleted'] === 0) {
        respond(['success' => false, 'message' => 'Document type already exists'], 409);
    }
    if ($existing && (int) $existing['is_deleted'] === 1) {
        respond(['success' => false, 'message' => 'Document type exists but is deleted. Restore it instead.'], 409);
    }
    $stmt = $conn->prepare('INSERT INTO document_types (type_name, description) VALUES (:type_name, :description)');
    $stmt->bindValue(':type_name', $typeName);
    $stmt->bindValue(':description', $data['description'] ?? null);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Document type created', 'document_type_id' => $conn->lastInsertId()]);
}
function updateDocumentType(PDO $conn): void {
    $data = getJsonInput();
    $typeName = trim((string) ($data['type_name'] ?? ''));
    if (empty($data['document_type_id']) || $typeName === '') respond(['success' => false, 'message' => 'ID and type name are required'], 422);
    $check = $conn->prepare('SELECT document_type_id, is_deleted FROM document_types WHERE type_name = :type_name AND document_type_id <> :document_type_id LIMIT 1');
    $check->bindValue(':type_name', $typeName);
    $check->bindValue(':document_type_id', $data['document_type_id'], PDO::PARAM_INT);
    $check->execute();
    $existing = $check->fetch(PDO::FETCH_ASSOC);
    if ($existing && (int) $existing['is_deleted'] === 0) {
        respond(['success' => false, 'message' => 'Document type already exists'], 409);
    }
    if ($existing && (int) $existing['is_deleted'] === 1) {
        respond(['success' => false, 'message' => 'Document type exists but is deleted. Restore it instead.'], 409);
    }
    $stmt = $conn->prepare('UPDATE document_types SET type_name = :type_name, description = :description WHERE document_type_id = :document_type_id');
    $stmt->bindValue(':type_name', $typeName);
    $stmt->bindValue(':description', $data['description'] ?? null);
    $stmt->bindValue(':document_type_id', $data['document_type_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Document type updated']);
}
function deleteDocumentType(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['document_type_id'])) respond(['success' => false, 'message' => 'ID is required'], 422);
    $stmt = $conn->prepare('UPDATE document_types SET is_deleted = 1, deleted_at = NOW() WHERE document_type_id = :document_type_id');
    $stmt->bindValue(':document_type_id', $data['document_type_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Document type deleted']);
}
?>
