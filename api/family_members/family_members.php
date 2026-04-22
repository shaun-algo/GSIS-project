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
        case 'getAllFamilyMembers': getAllFamilyMembers($conn); break;
        case 'createFamilyMember': createFamilyMember($conn); break;
        case 'updateFamilyMember': updateFamilyMember($conn); break;
        case 'deleteFamilyMember': deleteFamilyMember($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllFamilyMembers(PDO $conn): void {
    $sql = "SELECT fm.family_member_id, fm.learner_id, fm.full_name,
                   fm.relationship,
                   fm.date_of_birth, fm.occupation, fm.contact_number, fm.monthly_income,
                   CONCAT(l.last_name, ', ', l.first_name) AS learner_name
            FROM family_members fm
            JOIN learners l ON fm.learner_id = l.learner_id
            WHERE fm.is_deleted = 0
            ORDER BY fm.family_member_id DESC";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($rows as &$row) {
        $row['family_relationship_id'] = $row['relationship'];
        $row['relationship_name'] = $row['relationship'];
    }
    respond($rows);
}

function createFamilyMember(PDO $conn): void {
    $data = getJsonInput();
    $relationship = trim((string)($data['relationship'] ?? ($data['relationship_name'] ?? '')));
    if (empty($data['learner_id']) || empty($data['full_name']) || $relationship === '') {
        respond(['success' => false, 'message' => 'Learner, full name, and relationship are required'], 422);
    }
    $stmt = $conn->prepare('INSERT INTO family_members (learner_id, full_name, relationship, date_of_birth, occupation, contact_number, monthly_income) VALUES (:learner_id, :full_name, :relationship, :date_of_birth, :occupation, :contact_number, :monthly_income)');
    $stmt->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
    $stmt->bindValue(':full_name', $data['full_name']);
    $stmt->bindValue(':relationship', $relationship);
    $stmt->bindValue(':date_of_birth', $data['date_of_birth'] ?? null);
    $stmt->bindValue(':occupation', $data['occupation'] ?? null);
    $stmt->bindValue(':contact_number', $data['contact_number'] ?? null);
    $stmt->bindValue(':monthly_income', $data['monthly_income'] ?? null);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Family member created', 'family_member_id' => $conn->lastInsertId()]);
}

function updateFamilyMember(PDO $conn): void {
    $data = getJsonInput();
    $relationship = trim((string)($data['relationship'] ?? ($data['relationship_name'] ?? '')));
    if (empty($data['family_member_id']) || empty($data['learner_id']) || empty($data['full_name']) || $relationship === '') {
        respond(['success' => false, 'message' => 'Family member ID, learner, full name, and relationship are required'], 422);
    }
    $stmt = $conn->prepare('UPDATE family_members SET learner_id = :learner_id, full_name = :full_name, relationship = :relationship, date_of_birth = :date_of_birth, occupation = :occupation, contact_number = :contact_number, monthly_income = :monthly_income WHERE family_member_id = :family_member_id');
    $stmt->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
    $stmt->bindValue(':full_name', $data['full_name']);
    $stmt->bindValue(':relationship', $relationship);
    $stmt->bindValue(':date_of_birth', $data['date_of_birth'] ?? null);
    $stmt->bindValue(':occupation', $data['occupation'] ?? null);
    $stmt->bindValue(':contact_number', $data['contact_number'] ?? null);
    $stmt->bindValue(':monthly_income', $data['monthly_income'] ?? null);
    $stmt->bindValue(':family_member_id', $data['family_member_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Family member updated']);
}

function deleteFamilyMember(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['family_member_id'])) {
        respond(['success' => false, 'message' => 'Family member ID is required'], 422);
    }
    $stmt = $conn->prepare('UPDATE family_members SET is_deleted = 1, deleted_at = NOW() WHERE family_member_id = :family_member_id');
    $stmt->bindValue(':family_member_id', $data['family_member_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Family member deleted']);
}
?>
