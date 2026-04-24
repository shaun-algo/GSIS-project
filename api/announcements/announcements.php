<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/../utils/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { exit(0); }

require_once __DIR__ . '/../database/connection.php';
require_once __DIR__ . '/../utils/auth.php';
require_once __DIR__ . '/../utils/notifications.php';
require_once __DIR__ . '/../utils/audit.php';

function respond($payload, int $code = 200): void {
    http_response_code($code);
    echo json_encode($payload);
    exit;
}

function requireAnnouncementOwner(PDO $conn, int $announcementId, int $userId, array $session): void {
    // Admins can manage any announcement.
    if (auth_is_admin($session)) {
        return;
    }

    $stmt = $conn->prepare('SELECT posted_by FROM announcements WHERE announcement_id = :announcement_id AND is_deleted = 0');
    $stmt->bindValue(':announcement_id', $announcementId, PDO::PARAM_INT);
    $stmt->execute();
    $postedBy = $stmt->fetchColumn();

    if (!$postedBy) {
        respond(['success' => false, 'message' => 'Announcement not found'], 404);
    }

    if ((int)$postedBy !== $userId) {
        respond(['success' => false, 'message' => 'Not authorized to modify this announcement'], 403);
    }
}

function getJsonInput(): array {
    $raw = file_get_contents('php://input');
    return $raw ? (json_decode($raw, true) ?: []) : [];
}

function normalize_nullable_datetime($value): ?string {
    if ($value === null) {
        return null;
    }
    $raw = trim((string)$value);
    if ($raw === '') {
        return null;
    }

    // HTML datetime-local: YYYY-MM-DDTHH:MM or YYYY-MM-DDTHH:MM:SS
    if (preg_match('/^(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2})(?::(\d{2}))?$/', $raw, $m)) {
        $seconds = isset($m[3]) && $m[3] !== '' ? $m[3] : '00';
        return $m[1] . ' ' . $m[2] . ':' . $seconds;
    }

    // SQL datetime without seconds: YYYY-MM-DD HH:MM
    if (preg_match('/^(\d{4}-\d{2}-\d{2})[ T](\d{2}:\d{2})$/', $raw, $m)) {
        return $m[1] . ' ' . $m[2] . ':00';
    }

    return $raw;
}

$operation = $_GET['operation'] ?? '';
$session = auth_enforce_roles($operation, ['admin', 'teacher', 'registrar', 'learners'], ['admin', 'teacher']);
try {
    switch ($operation) {
        case 'getAllAnnouncements': getAllAnnouncements($conn); break;
        case 'getAnnouncement': getAnnouncement($conn); break;
        case 'createAnnouncement': createAnnouncement($conn); break;
        case 'updateAnnouncement': updateAnnouncement($conn); break;
        case 'deleteAnnouncement': deleteAnnouncement($conn); break;
        case 'pinAnnouncement': pinAnnouncement($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllAnnouncements(PDO $conn): void {
    $viewerRoleId = isset($_SESSION['role_id']) ? (int)$_SESSION['role_id'] : 0;
    $viewerRoleName = (string)($_SESSION['role_name'] ?? '');
    $isAdmin = auth_normalize_role($viewerRoleName) === 'admin';
    $viewerUserId = isset($_SESSION['user_id']) ? (int)$_SESSION['user_id'] : 0;

        $sql = "SELECT a.announcement_id, a.title, a.body, a.posted_by, a.target_role_id,
                 a.published_at, a.expires_at, a.is_pinned,
             u.username AS posted_by_name,
             e.first_name, e.last_name,
                 r.role_name AS target_role_name,
                 CASE WHEN :viewer_user_id > 0 AND a.posted_by = :viewer_user_id_owner THEN 1 ELSE 0 END AS is_owner,
                 TIMESTAMPDIFF(SECOND, a.published_at, NOW()) as seconds_ago
            FROM announcements a
            LEFT JOIN users u ON a.posted_by = u.user_id
         LEFT JOIN employees e ON e.user_id = u.user_id AND e.is_deleted = 0
            LEFT JOIN roles r ON a.target_role_id = r.role_id
            WHERE a.is_deleted = 0";

    // Visibility filter:
    // - Not logged in: only show announcements for all roles (NULL/0).
    // - Admin: show everything.
    // - Otherwise: show announcements for all roles (NULL/0) + targeted to viewer role_id.
    // Note: PDO (with emulation disabled) does not allow reusing the same named placeholder twice.
    $params = [
        ':viewer_user_id' => $viewerUserId,
        ':viewer_user_id_owner' => $viewerUserId
    ];
    if (empty($_SESSION['user_id'])) {
        $sql .= " AND (a.target_role_id IS NULL OR a.target_role_id = 0)";
    } elseif (!$isAdmin) {
        $sql .= " AND (a.target_role_id IS NULL OR a.target_role_id = 0 OR a.target_role_id = :viewer_role_id)";
        $params[':viewer_role_id'] = $viewerRoleId;
    }

    $sql .= "
            ORDER BY a.is_pinned DESC, a.announcement_id DESC";
    $stmt = $conn->prepare($sql);
    foreach ($params as $key => $value) {
        $stmt->bindValue($key, $value, PDO::PARAM_INT);
    }
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function getAnnouncement(PDO $conn): void {
    $id = $_GET['id'] ?? null;
    if (!$id) {
        respond(['success' => false, 'message' => 'Announcement ID required'], 422);
    }

    $viewerRoleId = isset($_SESSION['role_id']) ? (int)$_SESSION['role_id'] : 0;
    $viewerRoleName = (string)($_SESSION['role_name'] ?? '');
    $isAdmin = auth_normalize_role($viewerRoleName) === 'admin';
    $viewerUserId = isset($_SESSION['user_id']) ? (int)$_SESSION['user_id'] : 0;

		$sql = "SELECT a.*, u.username AS posted_by_name, e.first_name, e.last_name,
                   r.role_name AS target_role_name,
                                     CASE WHEN :viewer_user_id > 0 AND a.posted_by = :viewer_user_id_owner THEN 1 ELSE 0 END AS is_owner
            FROM announcements a
            LEFT JOIN users u ON a.posted_by = u.user_id
            LEFT JOIN employees e ON e.user_id = u.user_id AND e.is_deleted = 0
            LEFT JOIN roles r ON a.target_role_id = r.role_id
            WHERE a.announcement_id = :id AND a.is_deleted = 0";

        $params = [
                ':id' => (int)$id,
                ':viewer_user_id' => $viewerUserId,
                ':viewer_user_id_owner' => $viewerUserId
        ];
    if (empty($_SESSION['user_id'])) {
        $sql .= " AND (a.target_role_id IS NULL OR a.target_role_id = 0)";
    } elseif (!$isAdmin) {
        $sql .= " AND (a.target_role_id IS NULL OR a.target_role_id = 0 OR a.target_role_id = :viewer_role_id)";
        $params[':viewer_role_id'] = $viewerRoleId;
    }
    $stmt = $conn->prepare($sql);
    foreach ($params as $key => $value) {
        $stmt->bindValue($key, $value, PDO::PARAM_INT);
    }
    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        respond(['success' => true, 'data' => $result]);
    } else {
        respond(['success' => false, 'message' => 'Announcement not found'], 404);
    }
}

function createAnnouncement(PDO $conn): void {
    $data = getJsonInput();
    $userId = (int)($_SESSION['user_id'] ?? 0);
    if (empty($data['title']) || empty($data['body'])) {
        respond(['success' => false, 'message' => 'Title and body are required'], 422);
    }

    $targetRoleId = null;
    if (array_key_exists('target_role_id', $data)) {
        $rawTargetRoleId = $data['target_role_id'];
        if ($rawTargetRoleId === '' || $rawTargetRoleId === 0 || $rawTargetRoleId === '0') {
            $targetRoleId = null;
        } elseif ($rawTargetRoleId === null) {
            $targetRoleId = null;
        } else {
            $targetRoleId = (int)$rawTargetRoleId;
        }
    }

        $sql = 'INSERT INTO announcements (title, body, posted_by, target_role_id, published_at, expires_at, is_pinned)
            VALUES (:title, :body, :posted_by, :target_role_id, COALESCE(:published_at, NOW()), :expires_at, :is_pinned)';
    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':title', $data['title']);
    $stmt->bindValue(':body', $data['body']);
    $stmt->bindValue(':posted_by', $userId, PDO::PARAM_INT);
    if ($targetRoleId === null) {
        $stmt->bindValue(':target_role_id', null, PDO::PARAM_NULL);
    } else {
        $stmt->bindValue(':target_role_id', $targetRoleId, PDO::PARAM_INT);
    }
    $publishedAt = normalize_nullable_datetime($data['published_at'] ?? null);
    if ($publishedAt === null) {
        $stmt->bindValue(':published_at', null, PDO::PARAM_NULL);
    } else {
        $stmt->bindValue(':published_at', $publishedAt);
    }

    $expiresAt = normalize_nullable_datetime($data['expires_at'] ?? null);
    if ($expiresAt === null) {
        $stmt->bindValue(':expires_at', null, PDO::PARAM_NULL);
    } else {
        $stmt->bindValue(':expires_at', $expiresAt);
    }
    $stmt->bindValue(':is_pinned', $data['is_pinned'] ?? 0, PDO::PARAM_INT);
    $stmt->execute();

    $announcementId = $conn->lastInsertId();

    // Audit log
    audit_log($conn, 'announcements', (int)$announcementId, 'INSERT', null, [
        'announcement_id' => (int)$announcementId,
        'title' => $data['title'],
        'target_role_id' => $targetRoleId,
        'is_pinned' => $data['is_pinned'] ?? 0,
    ]);

    // Create in-app notifications for recipients.
    try {
        $title = (string)$data['title'];
        $message = (string)$data['body'];
        if ($targetRoleId === null) {
            // Include the poster in the list but mark as read so they don't get an "unread" bell badge for their own post.
            notifications_create_broadcast($conn, 'Announcement', $title, $message, 'announcements', (int)$announcementId, null, $userId);
        } else {
            notifications_create_for_role($conn, (int)$targetRoleId, 'Announcement', $title, $message, 'announcements', (int)$announcementId, null, $userId);
        }
    } catch (Exception $e) {
        // Never block announcement creation if notifications fail.
    }

    // Fetch the newly created announcement with seconds_ago for accurate timestamp
    $fetchSql = "SELECT a.*, u.username AS posted_by_name, e.first_name, e.last_name,
                        r.role_name AS target_role_name,
                        TIMESTAMPDIFF(SECOND, a.published_at, NOW()) as seconds_ago
                 FROM announcements a
                 LEFT JOIN users u ON a.posted_by = u.user_id
                 LEFT JOIN employees e ON e.user_id = u.user_id AND e.is_deleted = 0
                 LEFT JOIN roles r ON a.target_role_id = r.role_id
                 WHERE a.announcement_id = :id";
    $fetchStmt = $conn->prepare($fetchSql);
    $fetchStmt->bindValue(':id', $announcementId, PDO::PARAM_INT);
    $fetchStmt->execute();
    $newAnnouncement = $fetchStmt->fetch(PDO::FETCH_ASSOC);

    respond(['success' => true, 'message' => 'Announcement created.', 'announcement' => $newAnnouncement]);
}

function updateAnnouncement(PDO $conn): void {
    $userId = (int)($_SESSION['user_id'] ?? 0);
    $data = getJsonInput();
    if (empty($data['announcement_id']) || empty($data['title']) || empty($data['body'])) {
        respond(['success' => false, 'message' => 'Announcement ID, title, and body are required'], 422);
    }

    $targetRoleId = null;
    if (array_key_exists('target_role_id', $data)) {
        $rawTargetRoleId = $data['target_role_id'];
        if ($rawTargetRoleId === '' || $rawTargetRoleId === 0 || $rawTargetRoleId === '0') {
            $targetRoleId = null;
        } elseif ($rawTargetRoleId === null) {
            $targetRoleId = null;
        } else {
            $targetRoleId = (int)$rawTargetRoleId;
        }
    }

    requireAnnouncementOwner($conn, (int)$data['announcement_id'], $userId, auth_require());

    $setClauses = [
        'title = :title',
        'body = :body',
        'target_role_id = :target_role_id',
        'expires_at = :expires_at',
    ];

    // Only update attachment_url if the client explicitly sends it.
    if (array_key_exists('attachment_url', $data)) {
        $setClauses[] = 'attachment_url = :attachment_url';
    }

    // Allow editing pinned state from the same edit flow.
    if (array_key_exists('is_pinned', $data)) {
        $setClauses[] = 'is_pinned = :is_pinned';
    }

    $sql = 'UPDATE announcements SET ' . implode(', ', $setClauses) . ' WHERE announcement_id = :announcement_id';
    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':title', $data['title']);
    $stmt->bindValue(':body', $data['body']);
    if ($targetRoleId === null) {
        $stmt->bindValue(':target_role_id', null, PDO::PARAM_NULL);
    } else {
        $stmt->bindValue(':target_role_id', $targetRoleId, PDO::PARAM_INT);
    }
    $expiresAt = normalize_nullable_datetime($data['expires_at'] ?? null);
    if ($expiresAt === null) {
        $stmt->bindValue(':expires_at', null, PDO::PARAM_NULL);
    } else {
        $stmt->bindValue(':expires_at', $expiresAt);
    }

    if (array_key_exists('attachment_url', $data)) {
        $attachmentUrl = $data['attachment_url'];
        if ($attachmentUrl === '') {
            $attachmentUrl = null;
        }
        $stmt->bindValue(':attachment_url', $attachmentUrl);
    }

    if (array_key_exists('is_pinned', $data)) {
        $stmt->bindValue(':is_pinned', (int)$data['is_pinned'], PDO::PARAM_INT);
    }

    $stmt->bindValue(':announcement_id', $data['announcement_id'], PDO::PARAM_INT);
    $stmt->execute();

    // Audit log
    $oldRow = audit_fetch_old($conn, 'announcements', 'announcement_id', (int)$data['announcement_id']);
    audit_log($conn, 'announcements', (int)$data['announcement_id'], 'UPDATE', $oldRow, [
        'title' => $data['title'],
        'target_role_id' => $targetRoleId,
        'is_pinned' => $data['is_pinned'] ?? 0,
    ]);

    respond(['success' => true, 'message' => 'Announcement updated.']);
}

function deleteAnnouncement(PDO $conn): void {
    $userId = (int)($_SESSION['user_id'] ?? 0);
    $data = getJsonInput();
    if (empty($data['announcement_id'])) {
        respond(['success' => false, 'message' => 'Announcement ID is required'], 422);
    }

    requireAnnouncementOwner($conn, (int)$data['announcement_id'], $userId, auth_require());
    $stmt = $conn->prepare('UPDATE announcements SET is_deleted = 1, deleted_at = NOW() WHERE announcement_id = :announcement_id');
    $stmt->bindValue(':announcement_id', $data['announcement_id'], PDO::PARAM_INT);
    $stmt->execute();

    // Audit log
    audit_log($conn, 'announcements', (int)$data['announcement_id'], 'DELETE',
        audit_fetch_old($conn, 'announcements', 'announcement_id', (int)$data['announcement_id']), null);

    respond(['success' => true, 'message' => 'Announcement deleted.']);
}

function pinAnnouncement(PDO $conn): void {
    $userId = (int)($_SESSION['user_id'] ?? 0);
    $data = getJsonInput();
    if (empty($data['announcement_id'])) {
        respond(['success' => false, 'message' => 'Announcement ID is required'], 422);
    }

    requireAnnouncementOwner($conn, (int)$data['announcement_id'], $userId, auth_require());

    $isPinned = $data['is_pinned'] ?? 1;
    $stmt = $conn->prepare('UPDATE announcements SET is_pinned = :is_pinned WHERE announcement_id = :announcement_id');
    $stmt->bindValue(':is_pinned', $isPinned, PDO::PARAM_INT);
    $stmt->bindValue(':announcement_id', $data['announcement_id'], PDO::PARAM_INT);
    $stmt->execute();

    $message = $isPinned ? 'Announcement pinned.' : 'Announcement unpinned.';
    respond(['success' => true, 'message' => $message]);
}
?>
