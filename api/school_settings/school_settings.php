<?php
header('Content-Type: application/json');

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
        case 'getAllSettings':  getAllSettings($conn); break;
        case 'getSetting':     getSetting($conn); break;
        case 'updateSetting':  updateSetting($conn); break;
        case 'updateSettings': updateSettings($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllSettings(PDO $conn): void {
    $stmt = $conn->prepare("SELECT setting_id, setting_key, setting_value, description, updated_at FROM school_settings WHERE is_deleted = 0 ORDER BY setting_id");
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    // Also return as key-value map for convenience
    $map = [];
    foreach ($rows as $r) { $map[$r['setting_key']] = $r['setting_value']; }
    respond(['rows' => $rows, 'map' => $map]);
}

function getSetting(PDO $conn): void {
    $key = $_GET['setting_key'] ?? '';
    if (!$key) { respond(['success' => false, 'message' => 'setting_key required'], 422); }
    $stmt = $conn->prepare("SELECT setting_id, setting_key, setting_value, description FROM school_settings WHERE setting_key = :key AND is_deleted = 0 LIMIT 1");
    $stmt->bindValue(':key', $key);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    respond($row ?: ['setting_key' => $key, 'setting_value' => null]);
}

function updateSetting(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['setting_key'])) {
        respond(['success' => false, 'message' => 'setting_key is required'], 422);
    }
    $userId = $data['updated_by'] ?? null;
    $stmt = $conn->prepare(
        'INSERT INTO school_settings (setting_key, setting_value, description, updated_by)
         VALUES (:key, :value, :desc, :uid)
         ON DUPLICATE KEY UPDATE
             setting_value = VALUES(setting_value),
             description = COALESCE(VALUES(description), description),
             updated_by = VALUES(updated_by)'
    );
    $stmt->bindValue(':key',   $data['setting_key']);
    $stmt->bindValue(':value', $data['setting_value'] ?? null);
    $stmt->bindValue(':desc',  $data['description'] ?? null);
    $stmt->bindValue(':uid',   $userId, $userId === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Setting saved']);
}

function updateSettings(PDO $conn): void {
    // Bulk save: accepts { settings: { school_name: "", school_id: "", ... }, updated_by: 1 }
    $data = getJsonInput();
    if (empty($data['settings']) || !is_array($data['settings'])) {
        respond(['success' => false, 'message' => 'settings object is required'], 422);
    }
    $userId = $data['updated_by'] ?? null;
    $stmt = $conn->prepare(
        'UPDATE school_settings SET setting_value = :value, updated_by = :uid WHERE setting_key = :key AND is_deleted = 0'
    );
    foreach ($data['settings'] as $key => $value) {
        $stmt->bindValue(':key',   $key);
        $stmt->bindValue(':value', $value);
        $stmt->bindValue(':uid',   $userId, $userId === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
        $stmt->execute();
    }
    respond(['success' => true, 'message' => 'Settings updated']);
}
?>
