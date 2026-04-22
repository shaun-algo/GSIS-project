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
        case 'getAllGradeRemarks':  getAllGradeRemarks($conn); break;
        case 'createGradeRemark':  createGradeRemark($conn); break;
        case 'updateGradeRemark':  updateGradeRemark($conn); break;
        case 'deleteGradeRemark':  deleteGradeRemark($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllGradeRemarks(PDO $conn): void {
    // final_grades.remark is an ENUM in this schema (no grade_remarks table)
    respond([
        ['grade_remark_id' => 1, 'remark_name' => 'Passed', 'description' => 'Learner passed the subject'],
        ['grade_remark_id' => 2, 'remark_name' => 'Failed', 'description' => 'Learner failed the subject'],
    ]);
}

function createGradeRemark(PDO $conn): void {
    respond(['success' => false, 'message' => 'Unsupported: grade remarks are defined by ENUM in final_grades.remark'], 400);
}

function updateGradeRemark(PDO $conn): void {
    respond(['success' => false, 'message' => 'Unsupported: grade remarks are defined by ENUM in final_grades.remark'], 400);
}

function deleteGradeRemark(PDO $conn): void {
    respond(['success' => false, 'message' => 'Unsupported: grade remarks are defined by ENUM in final_grades.remark'], 400);
}
?>
