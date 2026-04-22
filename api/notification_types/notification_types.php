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
        case 'getAllNotificationTypes':  getAllNotificationTypes($conn); break;
        case 'createNotificationType':  createNotificationType($conn); break;
        case 'updateNotificationType':  updateNotificationType($conn); break;
        case 'deleteNotificationType':  deleteNotificationType($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllNotificationTypes(PDO $conn): void {
    // notifications.notification_type is an ENUM in this schema (no notification_types table)
    respond([
        ['notification_type_id' => 1, 'type_name' => 'Grade Alert', 'description' => 'Alerts related to grade thresholds'],
        ['notification_type_id' => 2, 'type_name' => 'Risk Flag', 'description' => 'Risk assessment flags/indicators'],
        ['notification_type_id' => 3, 'type_name' => 'Intervention Due', 'description' => 'Intervention follow-ups or due items'],
        ['notification_type_id' => 4, 'type_name' => 'Announcement', 'description' => 'General announcements'],
        ['notification_type_id' => 5, 'type_name' => 'Grading Period', 'description' => 'Grading period status/workflow notifications'],
    ]);
}
function createNotificationType(PDO $conn): void {
    respond(['success' => false, 'message' => 'Unsupported: notification types are defined by ENUM in notifications.notification_type'], 400);
}
function updateNotificationType(PDO $conn): void {
    respond(['success' => false, 'message' => 'Unsupported: notification types are defined by ENUM in notifications.notification_type'], 400);
}
function deleteNotificationType(PDO $conn): void {
    respond(['success' => false, 'message' => 'Unsupported: notification types are defined by ENUM in notifications.notification_type'], 400);
}
?>
