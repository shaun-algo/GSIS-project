<?php
require_once __DIR__ . '/../utils/cors.php';
header('Content-Type: application/json');

require_once __DIR__ . '/../database/connection.php';

require_once __DIR__ . '/../utils/auth.php';

auth_start_session();

function respond($payload, int $code = 200): void {
    http_response_code($code);
    echo json_encode($payload);
    exit;
}

function getJsonInput(): array {
    $raw = file_get_contents('php://input');
    return $raw ? (json_decode($raw, true) ?: []) : [];
}

$data = getJsonInput();
$username = trim((string)($data['username'] ?? ''));
$password = (string)($data['password'] ?? '');

if ($username === '' || $password === '') {
    respond(['success' => false, 'message' => 'Username and password are required.'], 422);
}

$stmt = $conn->prepare('SELECT u.user_id, u.username, u.password, u.role_id, u.is_active, r.role_name
    FROM users u
    LEFT JOIN roles r ON u.role_id = r.role_id
    WHERE u.username = :username AND u.is_deleted = 0
    LIMIT 1');
$stmt->bindValue(':username', $username);
$stmt->execute();
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$user || !password_verify($password, $user['password'])) {
    respond(['success' => false, 'message' => 'Invalid username or password.'], 401);
}

if ((int)$user['is_active'] !== 1) {
    respond(['success' => false, 'message' => 'Account is inactive.'], 403);
}

// Record last login (best-effort; don't block login if it fails).
try {
    $upd = $conn->prepare('UPDATE users SET last_login = NOW() WHERE user_id = :user_id');
    $upd->bindValue(':user_id', (int)$user['user_id'], PDO::PARAM_INT);
    $upd->execute();
} catch (Throwable $e) {
    // ignore
}

session_regenerate_id(true);
$_SESSION['user_id'] = (int)$user['user_id'];
$_SESSION['username'] = $user['username'];
$_SESSION['role_id'] = (int)$user['role_id'];
$_SESSION['role_name'] = $user['role_name'];

// Activity tracking / idle timeout support.
$_SESSION['last_activity'] = time();
$_SESSION['user_agent'] = (string)($_SERVER['HTTP_USER_AGENT'] ?? '');

respond([
    'success' => true,
    'message' => 'Login successful',
    'data' => [
        'user_id' => (int)$user['user_id'],
        'username' => $user['username'],
        'role_id' => (int)$user['role_id'],
        'role_name' => $user['role_name']
    ]
]);
?>
