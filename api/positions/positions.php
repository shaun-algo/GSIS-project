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

function normalizeInput($value) {
    if ($value === null) {
        return null;
    }
    if (is_string($value)) {
        $trimmed = trim($value);
        return $trimmed === '' ? null : $trimmed;
    }
    return $value;
}

$operation = $_GET['operation'] ?? '';
$session = auth_enforce_roles($operation, ['admin', 'teacher', 'registrar'], ['admin']);

try {
    switch ($operation) {
        case 'getAllPositions':
            getAllPositions($conn);
            break;
        case 'createPosition':
            createPosition($conn);
            break;
        case 'updatePosition':
            updatePosition($conn);
            break;
        case 'deletePosition':
            deletePosition($conn);
            break;
        default:
            respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllPositions(PDO $conn): void {
    $stmt = $conn->prepare('SELECT position_id, position_name, description FROM positions WHERE is_deleted = 0 ORDER BY position_name');
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function createPosition(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['position_name'])) {
        respond(['success' => false, 'message' => 'Position name is required'], 422);
    }

    $stmt = $conn->prepare('INSERT INTO positions (position_name, description) VALUES (:position_name, :description)');
    $stmt->bindValue(':position_name', normalizeInput($data['position_name'] ?? null));
    $stmt->bindValue(':description', normalizeInput($data['description'] ?? null));
    $stmt->execute();

    respond(['success' => true, 'message' => 'Position created', 'position_id' => $conn->lastInsertId()]);
}

function updatePosition(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['position_id']) || empty($data['position_name'])) {
        respond(['success' => false, 'message' => 'Position ID and name are required'], 422);
    }

    $stmt = $conn->prepare('UPDATE positions SET position_name = :position_name, description = :description WHERE position_id = :position_id');
    $stmt->bindValue(':position_name', normalizeInput($data['position_name'] ?? null));
    $stmt->bindValue(':description', normalizeInput($data['description'] ?? null));
    $stmt->bindValue(':position_id', $data['position_id'], PDO::PARAM_INT);
    $stmt->execute();

    respond(['success' => true, 'message' => 'Position updated']);
}

function deletePosition(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['position_id'])) {
        respond(['success' => false, 'message' => 'Position ID is required'], 422);
    }

    $stmt = $conn->prepare('UPDATE positions SET is_deleted = 1, deleted_at = NOW() WHERE position_id = :position_id');
    $stmt->bindValue(':position_id', $data['position_id'], PDO::PARAM_INT);
    $stmt->execute();

    respond(['success' => true, 'message' => 'Position deleted']);
}
?>
