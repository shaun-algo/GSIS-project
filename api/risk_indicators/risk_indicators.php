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
        case 'getAllRiskIndicators': getAllRiskIndicators($conn); break;
        case 'createRiskIndicator': createRiskIndicator($conn); break;
        case 'updateRiskIndicator': updateRiskIndicator($conn); break;
        case 'deleteRiskIndicator': deleteRiskIndicator($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllRiskIndicators(PDO $conn): void {
    $sql = "SELECT ri.indicator_id, ri.risk_assessment_id, ri.indicator_type, ri.details,
                   CONCAT(l.last_name, ', ', l.first_name) AS learner_name
            FROM risk_indicators ri
            JOIN risk_assessments ra ON ri.risk_assessment_id = ra.risk_assessment_id
            JOIN enrollments e ON ra.enrollment_id = e.enrollment_id
            JOIN learners l ON e.learner_id = l.learner_id
            WHERE ri.is_deleted = 0
            ORDER BY ri.indicator_id DESC";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function createRiskIndicator(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['risk_assessment_id'])) {
        respond(['success' => false, 'message' => 'Risk assessment is required'], 422);
    }
    $stmt = $conn->prepare('INSERT INTO risk_indicators (risk_assessment_id, indicator_type, details) VALUES (:risk_assessment_id, :indicator_type, :details)');
    $stmt->bindValue(':risk_assessment_id', $data['risk_assessment_id'], PDO::PARAM_INT);
    $stmt->bindValue(':indicator_type', $data['indicator_type'] ?? null);
    $stmt->bindValue(':details', $data['details'] ?? null);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Risk indicator created', 'indicator_id' => $conn->lastInsertId()]);
}

function updateRiskIndicator(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['indicator_id']) || empty($data['risk_assessment_id'])) {
        respond(['success' => false, 'message' => 'Indicator ID and risk assessment are required'], 422);
    }
    $stmt = $conn->prepare('UPDATE risk_indicators SET risk_assessment_id = :risk_assessment_id, indicator_type = :indicator_type, details = :details WHERE indicator_id = :indicator_id');
    $stmt->bindValue(':risk_assessment_id', $data['risk_assessment_id'], PDO::PARAM_INT);
    $stmt->bindValue(':indicator_type', $data['indicator_type'] ?? null);
    $stmt->bindValue(':details', $data['details'] ?? null);
    $stmt->bindValue(':indicator_id', $data['indicator_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Risk indicator updated']);
}

function deleteRiskIndicator(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['indicator_id'])) {
        respond(['success' => false, 'message' => 'Indicator ID is required'], 422);
    }
    $stmt = $conn->prepare('UPDATE risk_indicators SET is_deleted = 1, deleted_at = NOW() WHERE indicator_id = :indicator_id');
    $stmt->bindValue(':indicator_id', $data['indicator_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Risk indicator deleted']);
}
?>
