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
    $operation = 'getAllUsers';
}

// User management is admin-only (read + write).
$session = auth_enforce_roles($operation, ['admin'], ['admin']);

if ($method === 'GET' && $operation === 'getAllUsers') {
    getAllUsers($conn);
}

try {
    switch ($operation) {
        case 'getAllUsers':
            getAllUsers($conn);
            break;
        case 'createUser':
            createUser($conn);
            break;
        case 'updateUser':
            updateUser($conn);
            break;
        case 'deleteUser':
            deleteUser($conn);
            break;
        default:
            respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllUsers(PDO $conn): void {
    $stmt = $conn->prepare('SELECT u.user_id, u.username, u.role_id, r.role_name, u.is_active, u.created_at FROM users u LEFT JOIN roles r ON u.role_id = r.role_id WHERE u.is_deleted = 0 ORDER BY u.username');
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function createUser(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['username']) || empty($data['password']) || empty($data['role_id'])) {
        respond(['success' => false, 'message' => 'Username, password, and role are required'], 422);
    }

    // Check for duplicate username
    $check = $conn->prepare('SELECT COUNT(*) FROM users WHERE username = :username AND is_deleted = 0');
    $check->bindValue(':username', $data['username']);
    $check->execute();
    if ($check->fetchColumn() > 0) {
        respond(['success' => false, 'message' => 'Username already exists'], 409);
    }

    $isActive = isset($data['is_active']) ? (int)!!$data['is_active'] : 1;
    $passwordHash = password_hash($data['password'], PASSWORD_BCRYPT);

    $stmt = $conn->prepare('INSERT INTO users (username, password, role_id, is_active) VALUES (:username, :password, :role_id, :is_active)');
    $stmt->bindValue(':username', $data['username']);
    $stmt->bindValue(':password', $passwordHash);
    $stmt->bindValue(':role_id', $data['role_id'], PDO::PARAM_INT);
    $stmt->bindValue(':is_active', $isActive, PDO::PARAM_INT);
    $stmt->execute();

    respond(['success' => true, 'message' => 'User created', 'user_id' => $conn->lastInsertId()]);
}

function updateUser(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['user_id']) || empty($data['username']) || empty($data['role_id'])) {
        respond(['success' => false, 'message' => 'User ID, username, and role are required'], 422);
    }

    $isActive = isset($data['is_active']) ? (int)!!$data['is_active'] : 1;

    $sql = 'UPDATE users SET username = :username, role_id = :role_id, is_active = :is_active';
    $params = [
        ':username' => $data['username'],
        ':role_id' => $data['role_id'],
        ':is_active' => $isActive,
        ':user_id' => $data['user_id']
    ];

    if (!empty($data['password'])) {
        $sql .= ', password = :password';
        $params[':password'] = password_hash($data['password'], PASSWORD_BCRYPT);
    }

    $sql .= ' WHERE user_id = :user_id';

    $stmt = $conn->prepare($sql);
    foreach ($params as $key => $value) {
        $stmt->bindValue($key, $value);
    }
    $stmt->execute();

    respond(['success' => true, 'message' => 'User updated']);
}

function deleteUser(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['user_id'])) {
        respond(['success' => false, 'message' => 'User ID is required'], 422);
    }

    $stmt = $conn->prepare('UPDATE users SET is_deleted = 1, deleted_at = NOW() WHERE user_id = :user_id');
    $stmt->bindValue(':user_id', $data['user_id'], PDO::PARAM_INT);
    $stmt->execute();

    respond(['success' => true, 'message' => 'User deleted']);
}
?>
