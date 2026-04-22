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
        case 'getAllStatuses':  getAllStatuses($conn); break;
        case 'createStatus':  createStatus($conn); break;
        case 'updateStatus':  updateStatus($conn); break;
        case 'deleteStatus':  deleteStatus($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllStatuses(PDO $conn): void {
    // learners.learner_status is an ENUM in the revised schema; expose a stable option list.
    $rows = [
        ['learner_status_id' => 'Enrolled',               'status_name' => 'Enrolled',               'description' => null],
        ['learner_status_id' => 'Temporarily Enrolled',   'status_name' => 'Temporarily Enrolled',   'description' => null],
        ['learner_status_id' => 'Promoted',               'status_name' => 'Promoted',               'description' => null],
        ['learner_status_id' => 'Conditionally Promoted', 'status_name' => 'Conditionally Promoted', 'description' => null],
        ['learner_status_id' => 'Retained',               'status_name' => 'Retained',               'description' => null],
        ['learner_status_id' => 'Transferred Out',        'status_name' => 'Transferred Out',        'description' => null],
        ['learner_status_id' => 'Dropped',                'status_name' => 'Dropped',                'description' => null],
        ['learner_status_id' => 'Graduated',              'status_name' => 'Graduated',              'description' => null],
    ];
    respond($rows);
}
function createStatus(PDO $conn): void {
    respond(['success' => false, 'message' => 'Learner statuses are fixed in the current schema'], 501);
}
function updateStatus(PDO $conn): void {
    respond(['success' => false, 'message' => 'Learner statuses are fixed in the current schema'], 501);
}
function deleteStatus(PDO $conn): void {
    respond(['success' => false, 'message' => 'Learner statuses are fixed in the current schema'], 501);
}
?>
