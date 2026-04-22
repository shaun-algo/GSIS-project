<?php
header('Content-Type: application/json');
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
        case 'getAllMotherTongues':  getAllMotherTongues($conn); break;
        case 'createMotherTongue':  createMotherTongue($conn); break;
        case 'updateMotherTongue':  updateMotherTongue($conn); break;
        case 'deleteMotherTongue':  deleteMotherTongue($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllMotherTongues(PDO $conn): void {
    $sql = "SELECT DISTINCT mother_tongue
            FROM learners
            WHERE is_deleted = 0 AND mother_tongue IS NOT NULL AND TRIM(mother_tongue) <> ''
            ORDER BY mother_tongue";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    $rows = [];
    foreach ($stmt->fetchAll(PDO::FETCH_COLUMN) as $val) {
        $rows[] = ['mother_tongue_id' => $val, 'tongue_name' => $val];
    }
    respond($rows);
}
function createMotherTongue(PDO $conn): void {
    respond(['success' => false, 'message' => 'Mother tongues are stored inline in learners in the current schema'], 501);
}
function updateMotherTongue(PDO $conn): void {
    respond(['success' => false, 'message' => 'Mother tongues are stored inline in learners in the current schema'], 501);
}
function deleteMotherTongue(PDO $conn): void {
    respond(['success' => false, 'message' => 'Mother tongues are stored inline in learners in the current schema'], 501);
}
?>
