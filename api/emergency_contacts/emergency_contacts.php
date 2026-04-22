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
$session = auth_enforce_roles($operation, ['admin', 'registrar'], ['admin', 'registrar']);
try {
    switch ($operation) {
        case 'getAllEmergencyContacts': getAllEmergencyContacts($conn); break;
        case 'createEmergencyContact': createEmergencyContact($conn); break;
        case 'updateEmergencyContact': updateEmergencyContact($conn); break;
        case 'deleteEmergencyContact': deleteEmergencyContact($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllEmergencyContacts(PDO $conn): void {
    $sql = "SELECT ec.emergency_contact_id, ec.learner_id, ec.contact_name,
                   ec.relationship,
                   ec.contact_number, ec.address,
                   CONCAT(l.last_name, ', ', l.first_name) AS learner_name
            FROM emergency_contacts ec
            JOIN learners l ON ec.learner_id = l.learner_id
            WHERE ec.is_deleted = 0
            ORDER BY ec.emergency_contact_id DESC";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($rows as &$row) {
        $row['family_relationship_id'] = $row['relationship'];
        $row['relationship_name'] = $row['relationship'];
    }
    respond($rows);
}

function createEmergencyContact(PDO $conn): void {
    $data = getJsonInput();
    $relationship = trim((string)($data['relationship'] ?? ($data['relationship_name'] ?? '')));
    if (empty($data['learner_id']) || empty($data['contact_name']) || $relationship === '') {
        respond(['success' => false, 'message' => 'Learner, contact name, and relationship are required'], 422);
    }
    $stmt = $conn->prepare('INSERT INTO emergency_contacts (learner_id, contact_name, relationship, contact_number, address) VALUES (:learner_id, :contact_name, :relationship, :contact_number, :address)');
    $stmt->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
    $stmt->bindValue(':contact_name', $data['contact_name']);
    $stmt->bindValue(':relationship', $relationship);
    $stmt->bindValue(':contact_number', $data['contact_number'] ?? null);
    $stmt->bindValue(':address', $data['address'] ?? null);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Emergency contact created', 'emergency_contact_id' => $conn->lastInsertId()]);
}

function updateEmergencyContact(PDO $conn): void {
    $data = getJsonInput();
    $relationship = trim((string)($data['relationship'] ?? ($data['relationship_name'] ?? '')));
    if (empty($data['emergency_contact_id']) || empty($data['learner_id']) || empty($data['contact_name']) || $relationship === '') {
        respond(['success' => false, 'message' => 'Emergency contact ID, learner, contact name, and relationship are required'], 422);
    }
    $stmt = $conn->prepare('UPDATE emergency_contacts SET learner_id = :learner_id, contact_name = :contact_name, relationship = :relationship, contact_number = :contact_number, address = :address WHERE emergency_contact_id = :emergency_contact_id');
    $stmt->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
    $stmt->bindValue(':contact_name', $data['contact_name']);
    $stmt->bindValue(':relationship', $relationship);
    $stmt->bindValue(':contact_number', $data['contact_number'] ?? null);
    $stmt->bindValue(':address', $data['address'] ?? null);
    $stmt->bindValue(':emergency_contact_id', $data['emergency_contact_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Emergency contact updated']);
}

function deleteEmergencyContact(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['emergency_contact_id'])) {
        respond(['success' => false, 'message' => 'Emergency contact ID is required'], 422);
    }
    $stmt = $conn->prepare('UPDATE emergency_contacts SET is_deleted = 1, deleted_at = NOW() WHERE emergency_contact_id = :emergency_contact_id');
    $stmt->bindValue(':emergency_contact_id', $data['emergency_contact_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Emergency contact deleted']);
}
?>
