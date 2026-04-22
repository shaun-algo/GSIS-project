<?php
require_once __DIR__ . '/auth.php';

// Matches the baseline schema in api/database/thepelaezdraftrev.sql
function notifications_ensure_tables(PDO $conn): void {
    $conn->exec(
        "CREATE TABLE IF NOT EXISTS notifications (
            notification_id INT(11) NOT NULL AUTO_INCREMENT,
            user_id INT(11) NOT NULL,
            notification_type ENUM('Grade Alert','Risk Flag','Intervention Due','Announcement','Grading Period') NOT NULL,
            title VARCHAR(200) NOT NULL,
            message TEXT NOT NULL,
            is_read TINYINT(1) DEFAULT 0,
            read_at DATETIME DEFAULT NULL,
            reference_table VARCHAR(50) DEFAULT NULL,
            reference_id INT(11) DEFAULT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            is_deleted TINYINT(1) DEFAULT 0,
            deleted_at DATETIME DEFAULT NULL,
            PRIMARY KEY (notification_id),
            KEY idx_notif_user (user_id),
            KEY idx_notif_read (is_read)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci"
    );
}

function notifications_get_role_id(PDO $conn, string $roleKey): ?int {
    static $cache = null;
    if ($cache === null) {
        $cache = [];
        try {
            $stmt = $conn->query("SELECT role_id, role_name FROM roles WHERE is_deleted = 0");
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            foreach ($rows as $r) {
                $key = auth_normalize_role((string)($r['role_name'] ?? ''));
                if ($key === '') continue;
                $cache[$key] = (int)$r['role_id'];
            }
        } catch (Exception $e) {
            $cache = [];
        }
    }

    $normalized = auth_normalize_role($roleKey);
    if ($normalized === '') return null;
    return $cache[$normalized] ?? null;
}

function notifications_normalize_type(string $type): string {
    $type = trim($type);
    $allowed = ['Grade Alert','Risk Flag','Intervention Due','Announcement','Grading Period'];
    return in_array($type, $allowed, true) ? $type : 'Announcement';
}

function notifications_create_for_user(PDO $conn, int $userId, string $type, string $title, string $message, ?string $referenceTable = null, ?int $referenceId = null, int $isRead = 0): void {
    notifications_ensure_tables($conn);
    if ($userId <= 0) return;

    $type = notifications_normalize_type($type);
    $title = trim($title);
    $message = trim($message);
    if ($title === '' || $message === '') return;

    $isRead = ((int)$isRead) === 1 ? 1 : 0;
    $readAt = $isRead ? date('Y-m-d H:i:s') : null;

    $stmt = $conn->prepare(
        "INSERT INTO notifications (user_id, notification_type, title, message, is_read, read_at, reference_table, reference_id)
         VALUES (:uid, :type, :title, :msg, :is_read, :read_at, :rt, :rid)"
    );

    $stmt->bindValue(':uid', $userId, PDO::PARAM_INT);
    $stmt->bindValue(':type', $type);
    $stmt->bindValue(':title', $title);
    $stmt->bindValue(':msg', $message);
    $stmt->bindValue(':is_read', $isRead, PDO::PARAM_INT);
    if ($readAt === null) {
        $stmt->bindValue(':read_at', null, PDO::PARAM_NULL);
    } else {
        $stmt->bindValue(':read_at', $readAt);
    }

    if ($referenceTable === null || trim($referenceTable) === '') {
        $stmt->bindValue(':rt', null, PDO::PARAM_NULL);
    } else {
        $stmt->bindValue(':rt', $referenceTable);
    }
    if ($referenceId === null || $referenceId <= 0) {
        $stmt->bindValue(':rid', null, PDO::PARAM_NULL);
    } else {
        $stmt->bindValue(':rid', $referenceId, PDO::PARAM_INT);
    }

    try {
        $stmt->execute();
    } catch (Exception $e) {
        // Don't break calling endpoints.
    }
}

function notifications_exists_today_for_user(PDO $conn, int $userId, string $type, string $title, string $message): bool {
    try {
        $stmt = $conn->prepare(
            "SELECT 1
             FROM notifications
             WHERE user_id = :uid
               AND notification_type = :type
               AND title = :title
               AND message = :msg
               AND is_deleted = 0
               AND created_at >= CURDATE()
             LIMIT 1"
        );
        $stmt->bindValue(':uid', $userId, PDO::PARAM_INT);
        $stmt->bindValue(':type', notifications_normalize_type($type));
        $stmt->bindValue(':title', trim($title));
        $stmt->bindValue(':msg', trim($message));
        $stmt->execute();
        return (bool)$stmt->fetchColumn();
    } catch (Exception $e) {
        return false;
    }
}

function notifications_create_for_role(PDO $conn, int $roleId, string $type, string $title, string $message, ?string $referenceTable = null, ?int $referenceId = null, ?int $excludeUserId = null, ?int $markReadUserId = null): void {
    if ($roleId <= 0) return;
    notifications_ensure_tables($conn);

    $exclude = $excludeUserId !== null ? (int)$excludeUserId : null;
    $markRead = $markReadUserId !== null ? (int)$markReadUserId : null;

    try {
        $stmt = $conn->prepare("SELECT user_id FROM users WHERE role_id = :rid AND is_active = 1 AND is_deleted = 0");
        $stmt->bindValue(':rid', $roleId, PDO::PARAM_INT);
        $stmt->execute();
        $userIds = $stmt->fetchAll(PDO::FETCH_COLUMN);
        foreach ($userIds as $uid) {
            $id = (int)$uid;
            if ($exclude !== null && $id === $exclude) continue;
            $isRead = ($markRead !== null && $id === $markRead) ? 1 : 0;
            notifications_create_for_user($conn, $id, $type, $title, $message, $referenceTable, $referenceId, $isRead);
        }
    } catch (Exception $e) {
        // ignore
    }
}

function notifications_create_broadcast(PDO $conn, string $type, string $title, string $message, ?string $referenceTable = null, ?int $referenceId = null, ?int $excludeUserId = null, ?int $markReadUserId = null): void {
    notifications_ensure_tables($conn);

    $exclude = $excludeUserId !== null ? (int)$excludeUserId : null;
    $markRead = $markReadUserId !== null ? (int)$markReadUserId : null;

    try {
        $stmt = $conn->query("SELECT user_id FROM users WHERE is_active = 1 AND is_deleted = 0");
        $userIds = $stmt->fetchAll(PDO::FETCH_COLUMN);
        foreach ($userIds as $uid) {
            $id = (int)$uid;
            if ($exclude !== null && $id === $exclude) continue;
            $isRead = ($markRead !== null && $id === $markRead) ? 1 : 0;
            notifications_create_for_user($conn, $id, $type, $title, $message, $referenceTable, $referenceId, $isRead);
        }
    } catch (Exception $e) {
        // ignore
    }
}
?>
