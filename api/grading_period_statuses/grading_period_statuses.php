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
        case 'getAllGradingPeriodStatuses':  getAllGradingPeriodStatuses($conn); break;
        case 'createGradingPeriodStatus':  createGradingPeriodStatus($conn); break;
        case 'updateGradingPeriodStatus':  updateGradingPeriodStatus($conn); break;
        case 'deleteGradingPeriodStatus':  deleteGradingPeriodStatus($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllGradingPeriodStatuses(PDO $conn): void {
    // grading_periods.status is an ENUM in this schema (no grading_period_statuses table)
    respond([
        ['grading_period_status_id' => 1, 'status_name' => 'Open', 'description' => 'Grades can be encoded/edited'],
        ['grading_period_status_id' => 2, 'status_name' => 'Submitted', 'description' => 'Submitted for review'],
        ['grading_period_status_id' => 3, 'status_name' => 'Approved', 'description' => 'Reviewed/approved'],
        ['grading_period_status_id' => 4, 'status_name' => 'Locked', 'description' => 'Locked from further edits'],
    ]);
}
function createGradingPeriodStatus(PDO $conn): void {
    respond(['success' => false, 'message' => 'Unsupported: grading period statuses are defined by ENUM in grading_periods.status'], 400);
}
function updateGradingPeriodStatus(PDO $conn): void {
    respond(['success' => false, 'message' => 'Unsupported: grading period statuses are defined by ENUM in grading_periods.status'], 400);
}
function deleteGradingPeriodStatus(PDO $conn): void {
    respond(['success' => false, 'message' => 'Unsupported: grading period statuses are defined by ENUM in grading_periods.status'], 400);
}
?>
