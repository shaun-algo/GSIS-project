<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/../utils/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once __DIR__ . '/../database/connection.php';

require_once __DIR__ . '/../utils/auth.php';
require_once __DIR__ . '/../utils/audit.php';

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
$method = $_SERVER['REQUEST_METHOD'] ?? '';
if ($operation === '' && $method === 'GET') {
    $operation = 'getAllRoles';
}

// Roles can be listed by staff; role management is admin-only.
$session = auth_enforce_roles($operation, ['admin', 'teacher', 'registrar'], ['admin']);

if ($method === 'GET' && $operation === 'getAllRoles') {
    getAllRoles($conn);
}

try {
    switch ($operation) {
        case 'getAllRoles':
            getAllRoles($conn);
            break;
        case 'createRole':
            createRole($conn);
            break;
        case 'updateRole':
            updateRole($conn);
            break;
        case 'deleteRole':
            deleteRole($conn);
            break;
        default:
            respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllRoles(PDO $conn): void {
    $stmt = $conn->prepare('SELECT role_id, role_name FROM roles WHERE is_deleted = 0 ORDER BY role_name');
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function createRole(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['role_name'])) {
        respond(['success' => false, 'message' => 'Role name is required'], 422);
    }

    $stmt = $conn->prepare('INSERT INTO roles (role_name) VALUES (:role_name)');
    $stmt->bindValue(':role_name', $data['role_name']);
    $stmt->execute();

    $roleId = (int)$conn->lastInsertId();
    audit_log($conn, 'roles', $roleId, 'INSERT', null, ['role_id' => $roleId, 'role_name' => $data['role_name']]);

    respond(['success' => true, 'message' => 'Role created', 'role_id' => $conn->lastInsertId()]);
}

function updateRole(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['role_id']) || empty($data['role_name'])) {
        respond(['success' => false, 'message' => 'Role ID and name are required'], 422);
    }

    $stmt = $conn->prepare('UPDATE roles SET role_name = :role_name WHERE role_id = :role_id');
    $stmt->bindValue(':role_name', $data['role_name']);
    $stmt->bindValue(':role_id', $data['role_id'], PDO::PARAM_INT);
    $stmt->execute();

    $oldRow = audit_fetch_old($conn, 'roles', 'role_id', (int)$data['role_id']);
    audit_log($conn, 'roles', (int)$data['role_id'], 'UPDATE', $oldRow, ['role_id' => (int)$data['role_id'], 'role_name' => $data['role_name']]);

    respond(['success' => true, 'message' => 'Role updated']);
}

function deleteRole(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['role_id'])) {
        respond(['success' => false, 'message' => 'Role ID is required'], 422);
    }

    $stmt = $conn->prepare('UPDATE roles SET is_deleted = 1, deleted_at = NOW() WHERE role_id = :role_id');
    $stmt->bindValue(':role_id', $data['role_id'], PDO::PARAM_INT);
    $stmt->execute();

    $oldRow = audit_fetch_old($conn, 'roles', 'role_id', (int)$data['role_id']);
    audit_log($conn, 'roles', (int)$data['role_id'], 'DELETE', $oldRow, null);

    respond(['success' => true, 'message' => 'Role deleted']);
}
?>
