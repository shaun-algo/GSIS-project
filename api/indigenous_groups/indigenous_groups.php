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
        case 'getAllIndigenousGroups':  getAllIndigenousGroups($conn); break;
        case 'createIndigenousGroup':  createIndigenousGroup($conn); break;
        case 'updateIndigenousGroup':  updateIndigenousGroup($conn); break;
        case 'deleteIndigenousGroup':  deleteIndigenousGroup($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllIndigenousGroups(PDO $conn): void {
    $sql = "SELECT DISTINCT indigenous_group
            FROM learners
            WHERE is_deleted = 0 AND indigenous_group IS NOT NULL AND TRIM(indigenous_group) <> ''
            ORDER BY indigenous_group";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    $rows = [];
    foreach ($stmt->fetchAll(PDO::FETCH_COLUMN) as $val) {
        $rows[] = ['indigenous_group_id' => $val, 'group_name' => $val];
    }
    respond($rows);
}
function createIndigenousGroup(PDO $conn): void {
    respond(['success' => false, 'message' => 'Indigenous groups are stored inline in learners in the current schema'], 501);
}
function updateIndigenousGroup(PDO $conn): void {
    respond(['success' => false, 'message' => 'Indigenous groups are stored inline in learners in the current schema'], 501);
}
function deleteIndigenousGroup(PDO $conn): void {
    respond(['success' => false, 'message' => 'Indigenous groups are stored inline in learners in the current schema'], 501);
}
?>
