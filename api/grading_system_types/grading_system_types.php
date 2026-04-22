<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/../utils/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

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
        case 'getAllGradingSystems':
            getAllGradingSystems($conn);
            break;
        case 'createGradingSystem':
            createGradingSystem($conn);
            break;
        case 'updateGradingSystem':
            updateGradingSystem($conn);
            break;
        case 'deleteGradingSystem':
            deleteGradingSystem($conn);
            break;
        default:
            respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllGradingSystems(PDO $conn): void {
    // school_years.grading_system_type is an ENUM in this schema (no grading_system_types table)
    respond([
        ['grading_system_type_id' => 1, 'system_name' => 'Quarterly', 'description' => '4 grading periods', 'period_num' => 4],
        ['grading_system_type_id' => 2, 'system_name' => 'Trimester', 'description' => '3 grading periods', 'period_num' => 3],
        ['grading_system_type_id' => 3, 'system_name' => 'Semester', 'description' => '2 grading periods', 'period_num' => 2],
    ]);
}

function createGradingSystem(PDO $conn): void {
    respond(['success' => false, 'message' => 'Unsupported: grading systems are defined by ENUM in school_years.grading_system_type'], 400);
}

function updateGradingSystem(PDO $conn): void {
    respond(['success' => false, 'message' => 'Unsupported: grading systems are defined by ENUM in school_years.grading_system_type'], 400);
}

function deleteGradingSystem(PDO $conn): void {
    respond(['success' => false, 'message' => 'Unsupported: grading systems are defined by ENUM in school_years.grading_system_type'], 400);
}
?>
