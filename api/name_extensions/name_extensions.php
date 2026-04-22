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
$session = auth_enforce_roles($operation, ['admin', 'teacher', 'registrar'], ['admin']);
try {
    switch ($operation) {
        case 'getAllNameExtensions':  getAllNameExtensions($conn); break;
        case 'createNameExtension':  createNameExtension($conn); break;
        case 'updateNameExtension':  updateNameExtension($conn); break;
        case 'deleteNameExtension':  deleteNameExtension($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllNameExtensions(PDO $conn): void {
    $rows = [
        ['extension_id' => '',    'extension_name' => ''],
        ['extension_id' => 'Jr.', 'extension_name' => 'Jr.'],
        ['extension_id' => 'Sr.', 'extension_name' => 'Sr.'],
        ['extension_id' => 'II',  'extension_name' => 'II'],
        ['extension_id' => 'III', 'extension_name' => 'III'],
        ['extension_id' => 'IV',  'extension_name' => 'IV'],
    ];
    respond($rows);
}
function createNameExtension(PDO $conn): void {
    respond(['success' => false, 'message' => 'Name extensions are fixed in the current schema'], 501);
}
function updateNameExtension(PDO $conn): void {
    respond(['success' => false, 'message' => 'Name extensions are fixed in the current schema'], 501);
}
function deleteNameExtension(PDO $conn): void {
    respond(['success' => false, 'message' => 'Name extensions are fixed in the current schema'], 501);
}
?>
