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
        case 'getAllCivilStatuses':  getAllCivilStatuses($conn); break;
        case 'getAllStatuses':  getAllCivilStatuses($conn); break; // Alias for compatibility
        case 'createCivilStatus':   createCivilStatus($conn); break;
        case 'updateCivilStatus':   updateCivilStatus($conn); break;
        case 'deleteCivilStatus':   deleteCivilStatus($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllCivilStatuses(PDO $conn): void {
    $rows = [
        ['civil_status_id' => 'Single',            'status_name' => 'Single'],
        ['civil_status_id' => 'Married',           'status_name' => 'Married'],
        ['civil_status_id' => 'Widowed',           'status_name' => 'Widowed'],
        ['civil_status_id' => 'Legally Separated', 'status_name' => 'Legally Separated'],
        ['civil_status_id' => 'Annulled',          'status_name' => 'Annulled'],
    ];
    respond($rows);
}
function createCivilStatus(PDO $conn): void {
    respond(['success' => false, 'message' => 'Civil statuses are fixed in the current schema'], 501);
}
function updateCivilStatus(PDO $conn): void {
    respond(['success' => false, 'message' => 'Civil statuses are fixed in the current schema'], 501);
}
function deleteCivilStatus(PDO $conn): void {
    respond(['success' => false, 'message' => 'Civil statuses are fixed in the current schema'], 501);
}
?>
