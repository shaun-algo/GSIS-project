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
$session = auth_enforce_roles($operation, ['admin', 'teacher'], ['admin']);
try {
    switch ($operation) {
        case 'getAllFamilyRelationships':  getAllFamilyRelationships($conn); break;
        case 'createFamilyRelationship':
        case 'updateFamilyRelationship':
        case 'deleteFamilyRelationship':
            respond(['success' => false, 'message' => 'Family relationships are stored as free-text in family_members/emergency_contacts (no family_relationships table in this schema)'], 400);
            break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllFamilyRelationships(PDO $conn): void {
    $rows = [
        ['family_relationship_id' => 'Father',         'relationship_name' => 'Father'],
        ['family_relationship_id' => 'Mother',         'relationship_name' => 'Mother'],
        ['family_relationship_id' => 'Step-Father',    'relationship_name' => 'Step-Father'],
        ['family_relationship_id' => 'Step-Mother',    'relationship_name' => 'Step-Mother'],
        ['family_relationship_id' => 'Guardian',       'relationship_name' => 'Guardian'],
        ['family_relationship_id' => 'Legal Guardian', 'relationship_name' => 'Legal Guardian'],
        ['family_relationship_id' => 'Sibling',        'relationship_name' => 'Sibling'],
        ['family_relationship_id' => 'Other',          'relationship_name' => 'Other'],
    ];
    respond($rows);
}
?>
