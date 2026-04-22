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
$session = auth_enforce_roles($operation, ['admin'], ['admin']);
try {
    switch ($operation) {
        case 'getAllInterventions': getAllInterventions($conn); break;
        case 'createIntervention': createIntervention($conn); break;
        case 'updateIntervention': updateIntervention($conn); break;
        case 'deleteIntervention': deleteIntervention($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllInterventions(PDO $conn): void {
    $sql = "SELECT i.intervention_id, i.enrollment_id, i.risk_assessment_id, i.intervention_type,
                   i.description, i.conducted_by, i.conducted_at, i.follow_up_date,
                   i.intervention_status_id, isx.status_name,
                   CONCAT(l.last_name, ', ', l.first_name) AS learner_name,
                   CONCAT(e.last_name, ', ', e.first_name) AS conducted_by_name
            FROM interventions i
            JOIN enrollments en ON i.enrollment_id = en.enrollment_id
            JOIN learners l ON en.learner_id = l.learner_id
            LEFT JOIN employees e ON i.conducted_by = e.employee_id
            LEFT JOIN intervention_statuses isx ON i.intervention_status_id = isx.intervention_status_id
            WHERE i.is_deleted = 0
            ORDER BY i.intervention_id DESC";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function createIntervention(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['enrollment_id']) || empty($data['risk_assessment_id'])) {
        respond(['success' => false, 'message' => 'Enrollment and risk assessment are required'], 422);
    }
    $stmt = $conn->prepare('INSERT INTO interventions (enrollment_id, risk_assessment_id, intervention_type, description, conducted_by, conducted_at, follow_up_date, intervention_status_id, notes) VALUES (:enrollment_id, :risk_assessment_id, :intervention_type, :description, :conducted_by, :conducted_at, :follow_up_date, :intervention_status_id, :notes)');
    $stmt->bindValue(':enrollment_id', $data['enrollment_id'], PDO::PARAM_INT);
    $stmt->bindValue(':risk_assessment_id', $data['risk_assessment_id'], PDO::PARAM_INT);
    $stmt->bindValue(':intervention_type', $data['intervention_type'] ?? null);
    $stmt->bindValue(':description', $data['description'] ?? null);
    $stmt->bindValue(':conducted_by', $data['conducted_by'] ?? null, $data['conducted_by'] === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
    $stmt->bindValue(':conducted_at', $data['conducted_at'] ?? null);
    $stmt->bindValue(':follow_up_date', $data['follow_up_date'] ?? null);
    $stmt->bindValue(':intervention_status_id', $data['intervention_status_id'] ?? 1, PDO::PARAM_INT);
    $stmt->bindValue(':notes', $data['notes'] ?? null);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Intervention created', 'intervention_id' => $conn->lastInsertId()]);
}

function updateIntervention(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['intervention_id']) || empty($data['enrollment_id']) || empty($data['risk_assessment_id'])) {
        respond(['success' => false, 'message' => 'Intervention ID, enrollment, and risk assessment are required'], 422);
    }
    $stmt = $conn->prepare('UPDATE interventions SET enrollment_id = :enrollment_id, risk_assessment_id = :risk_assessment_id, intervention_type = :intervention_type, description = :description, conducted_by = :conducted_by, conducted_at = :conducted_at, follow_up_date = :follow_up_date, intervention_status_id = :intervention_status_id, notes = :notes WHERE intervention_id = :intervention_id');
    $stmt->bindValue(':enrollment_id', $data['enrollment_id'], PDO::PARAM_INT);
    $stmt->bindValue(':risk_assessment_id', $data['risk_assessment_id'], PDO::PARAM_INT);
    $stmt->bindValue(':intervention_type', $data['intervention_type'] ?? null);
    $stmt->bindValue(':description', $data['description'] ?? null);
    $stmt->bindValue(':conducted_by', $data['conducted_by'] ?? null, $data['conducted_by'] === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
    $stmt->bindValue(':conducted_at', $data['conducted_at'] ?? null);
    $stmt->bindValue(':follow_up_date', $data['follow_up_date'] ?? null);
    $stmt->bindValue(':intervention_status_id', $data['intervention_status_id'] ?? 1, PDO::PARAM_INT);
    $stmt->bindValue(':notes', $data['notes'] ?? null);
    $stmt->bindValue(':intervention_id', $data['intervention_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Intervention updated']);
}

function deleteIntervention(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['intervention_id'])) {
        respond(['success' => false, 'message' => 'Intervention ID is required'], 422);
    }
    $stmt = $conn->prepare('UPDATE interventions SET is_deleted = 1, deleted_at = NOW() WHERE intervention_id = :intervention_id');
    $stmt->bindValue(':intervention_id', $data['intervention_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Intervention deleted']);
}
?>
