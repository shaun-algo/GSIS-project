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
        case 'getAllReligions':  getAllReligions($conn); break;
        case 'createReligion':  createReligion($conn); break;
        case 'updateReligion':  updateReligion($conn); break;
        case 'deleteReligion':  deleteReligion($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllReligions(PDO $conn): void {
    $sql = "SELECT DISTINCT religion
            FROM learners
            WHERE is_deleted = 0 AND religion IS NOT NULL AND TRIM(religion) <> ''
            ORDER BY religion";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    $rows = [];
    foreach ($stmt->fetchAll(PDO::FETCH_COLUMN) as $val) {
        $rows[] = ['religion_id' => $val, 'religion_name' => $val];
    }
    respond($rows);
}
function createReligion(PDO $conn): void {
    respond(['success' => false, 'message' => 'Religions are stored inline in learners in the current schema'], 501);
}
function updateReligion(PDO $conn): void {
    respond(['success' => false, 'message' => 'Religions are stored inline in learners in the current schema'], 501);
}
function deleteReligion(PDO $conn): void {
    respond(['success' => false, 'message' => 'Religions are stored inline in learners in the current schema'], 501);
}
?>
