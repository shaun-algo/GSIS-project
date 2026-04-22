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
$session = auth_enforce_roles($operation, ['admin'], ['admin']);
try {
    switch ($operation) {
        case 'getAllRequirements':    getAllRequirements($conn); break;
        case 'getRequirementById':   getRequirementById($conn); break;
        case 'createRequirement':    createRequirement($conn); break;
        case 'updateRequirement':    updateRequirement($conn); break;
        case 'deleteRequirement':    deleteRequirement($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllRequirements(PDO $conn): void {
    $sql = "SELECT er.requirement_id, er.school_year_id, er.grade_level_id, er.document_type_id,
                   er.is_mandatory, er.notes,
                   sy.year_label AS school_year_label,
                   gl.grade_name,
                   dt.type_name
            FROM enrollment_requirements er
            LEFT JOIN school_years sy ON er.school_year_id = sy.school_year_id
            LEFT JOIN grade_levels gl ON er.grade_level_id  = gl.grade_level_id
            LEFT JOIN document_types dt ON er.document_type_id = dt.document_type_id
            WHERE er.is_deleted = 0
            ORDER BY sy.year_label DESC, gl.grade_name, dt.type_name";
    $stmt = $conn->query($sql);
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function getRequirementById(PDO $conn): void {
    $id = (int)($_GET['requirement_id'] ?? 0);
    if (!$id) { respond(['success' => false, 'message' => 'requirement_id required'], 422); }

    $stmt = $conn->prepare(
        "SELECT er.*, sy.year_label AS school_year_label, gl.grade_name, dt.type_name
         FROM enrollment_requirements er
         LEFT JOIN school_years sy ON er.school_year_id = sy.school_year_id
         LEFT JOIN grade_levels gl ON er.grade_level_id  = gl.grade_level_id
         LEFT JOIN document_types dt ON er.document_type_id = dt.document_type_id
         WHERE er.requirement_id = :id AND er.is_deleted = 0"
    );
    $stmt->execute([':id' => $id]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$row) { respond(['success' => false, 'message' => 'Not found'], 404); }
    respond($row);
}

function createRequirement(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['school_year_id']) || empty($data['document_type_id'])) {
        respond(['success' => false, 'message' => 'school_year_id and document_type_id are required'], 422);
    }
    $stmt = $conn->prepare(
        'INSERT INTO enrollment_requirements (school_year_id, grade_level_id, document_type_id, is_mandatory, notes)
         VALUES (:sy, :gl, :dt, :mandatory, :notes)'
    );
    $stmt->bindValue(':sy',       $data['school_year_id'],  PDO::PARAM_INT);
    $stmt->bindValue(':gl',       $data['grade_level_id'] ?? null, empty($data['grade_level_id']) ? PDO::PARAM_NULL : PDO::PARAM_INT);
    $stmt->bindValue(':dt',       $data['document_type_id'], PDO::PARAM_INT);
    $stmt->bindValue(':mandatory', isset($data['is_mandatory']) ? (int)$data['is_mandatory'] : 1, PDO::PARAM_INT);
    $stmt->bindValue(':notes',    $data['notes'] ?? null);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Requirement created', 'requirement_id' => $conn->lastInsertId()]);
}

function updateRequirement(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['requirement_id'])) {
        respond(['success' => false, 'message' => 'requirement_id required'], 422);
    }
    $stmt = $conn->prepare(
        'UPDATE enrollment_requirements
         SET school_year_id = :sy, grade_level_id = :gl, document_type_id = :dt,
             is_mandatory = :mandatory, notes = :notes
         WHERE requirement_id = :id AND is_deleted = 0'
    );
    $stmt->bindValue(':id',       $data['requirement_id'],  PDO::PARAM_INT);
    $stmt->bindValue(':sy',       $data['school_year_id'],  PDO::PARAM_INT);
    $stmt->bindValue(':gl',       $data['grade_level_id'] ?? null, empty($data['grade_level_id']) ? PDO::PARAM_NULL : PDO::PARAM_INT);
    $stmt->bindValue(':dt',       $data['document_type_id'], PDO::PARAM_INT);
    $stmt->bindValue(':mandatory', isset($data['is_mandatory']) ? (int)$data['is_mandatory'] : 1, PDO::PARAM_INT);
    $stmt->bindValue(':notes',    $data['notes'] ?? null);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Requirement updated']);
}

function deleteRequirement(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['requirement_id'])) {
        respond(['success' => false, 'message' => 'requirement_id required'], 422);
    }
    $stmt = $conn->prepare('UPDATE enrollment_requirements SET is_deleted = 1, deleted_at = NOW() WHERE requirement_id = :id');
    $stmt->bindValue(':id', $data['requirement_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Requirement deleted']);
}
?>
