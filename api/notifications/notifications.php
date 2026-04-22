<?php
header('Content-Type: application/json');

require_once __DIR__ . '/../utils/cors.php';
require_once __DIR__ . '/../database/connection.php';
require_once __DIR__ . '/../utils/auth.php';
require_once __DIR__ . '/../utils/notifications.php';

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
if ($operation === '') {
    $operation = 'getNotifications';
}

$session = auth_require();
$userId = (int)($session['user_id'] ?? 0);
notifications_ensure_tables($conn);

try {
    switch ($operation) {
        case 'getNotifications':
            getNotifications($conn, $userId);
            break;
        case 'getUnreadCount':
            getUnreadCount($conn, $userId);
            break;
        case 'markRead':
            markRead($conn, $userId);
            break;
        case 'markAllRead':
            markAllRead($conn, $userId);
            break;
        default:
            respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error'], 500);
}

function getNotifications(PDO $conn, int $userId): void {
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 12;
    if ($limit <= 0) $limit = 12;
    if ($limit > 50) $limit = 50;

    $stmt = $conn->prepare(
        "SELECT n.notification_id, n.notification_type, n.title, n.message, n.is_read, n.read_at, n.reference_table, n.reference_id, n.created_at,
                a.posted_by AS actor_user_id,
                au.username AS actor_username,
                ae.first_name AS actor_first_name,
                ae.last_name AS actor_last_name
         FROM notifications n
         LEFT JOIN announcements a
           ON (n.reference_table = 'announcements' AND n.reference_id = a.announcement_id AND a.is_deleted = 0)
         LEFT JOIN users au
           ON a.posted_by = au.user_id
         LEFT JOIN employees ae
           ON ae.user_id = au.user_id AND ae.is_deleted = 0
         WHERE n.user_id = :uid AND n.is_deleted = 0
         ORDER BY n.created_at DESC, n.notification_id DESC
         LIMIT :lim"
    );
    $stmt->bindValue(':uid', $userId, PDO::PARAM_INT);
    $stmt->bindValue(':lim', $limit, PDO::PARAM_INT);
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $c = $conn->prepare("SELECT COUNT(*) FROM notifications WHERE user_id = :uid AND is_read = 0 AND is_deleted = 0");
    $c->bindValue(':uid', $userId, PDO::PARAM_INT);
    $c->execute();
    $unread = (int)$c->fetchColumn();

    respond([
        'success' => true,
        'data' => [
            'unread_count' => $unread,
            'notifications' => $rows
        ]
    ]);
}

function getUnreadCount(PDO $conn, int $userId): void {
    $stmt = $conn->prepare("SELECT COUNT(*) FROM notifications WHERE user_id = :uid AND is_read = 0 AND is_deleted = 0");
    $stmt->bindValue(':uid', $userId, PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'data' => ['count' => (int)$stmt->fetchColumn()]]);
}

function markRead(PDO $conn, int $userId): void {
    $data = getJsonInput();
    $notificationId = (int)($data['notification_id'] ?? 0);
    if ($notificationId <= 0) {
        respond(['success' => false, 'message' => 'notification_id required'], 422);
    }

    $stmt = $conn->prepare(
        'UPDATE notifications
         SET is_read = 1, read_at = NOW()
         WHERE notification_id = :id AND user_id = :uid AND is_deleted = 0'
    );
    $stmt->bindValue(':id', $notificationId, PDO::PARAM_INT);
    $stmt->bindValue(':uid', $userId, PDO::PARAM_INT);
    $stmt->execute();

    respond(['success' => true]);
}

function markAllRead(PDO $conn, int $userId): void {
    $stmt = $conn->prepare(
        'UPDATE notifications
         SET is_read = 1, read_at = NOW()
         WHERE user_id = :uid AND is_read = 0 AND is_deleted = 0'
    );
    $stmt->bindValue(':uid', $userId, PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true]);
}
?>
