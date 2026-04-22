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
        case 'getAllSubjectCodes':
            getAllSubjectCodes($conn);
            break;
        case 'createSubjectCode':
            respond(['success' => false, 'message' => 'Subject codes are stored directly in subjects; create/update/delete is not supported in this schema'], 400);
            break;
        case 'updateSubjectCode':
            respond(['success' => false, 'message' => 'Subject codes are stored directly in subjects; create/update/delete is not supported in this schema'], 400);
            break;
        case 'deleteSubjectCode':
            respond(['success' => false, 'message' => 'Subject codes are stored directly in subjects; create/update/delete is not supported in this schema'], 400);
            break;
        default:
            respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllSubjectCodes(PDO $conn): void {
    $stmt = $conn->prepare('SELECT DISTINCT subject_code AS subject_code_id, subject_code FROM subjects WHERE is_deleted = 0 AND subject_code IS NOT NULL AND subject_code <> "" ORDER BY subject_code');
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}
?>
