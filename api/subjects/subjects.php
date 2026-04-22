<?php
header('Content-Type: application/json');

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
        case 'getAllSubjects':
            getAllSubjects($conn);
            break;
        case 'createSubject':
            createSubject($conn);
            break;
        case 'updateSubject':
            updateSubject($conn);
            break;
        case 'deleteSubject':
            deleteSubject($conn);
            break;
        default:
            respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllSubjects(PDO $conn): void {
    $sql = 'SELECT s.subject_id, s.subject_code, s.subject_name, s.description
            FROM subjects s
            WHERE s.is_deleted = 0
            ORDER BY s.subject_code, s.subject_name';
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function createSubject(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['subject_code']) || empty($data['subject_name'])) {
        respond(['success' => false, 'message' => 'subject_code and subject_name are required'], 422);
    }

    $stmt = $conn->prepare('INSERT INTO subjects (subject_code, subject_name, description) VALUES (:subject_code, :subject_name, :description)');
    $stmt->bindValue(':subject_code', $data['subject_code']);
    $stmt->bindValue(':subject_name', $data['subject_name']);
    $stmt->bindValue(':description', $data['description'] ?? null);
    $stmt->execute();

    respond(['success' => true, 'message' => 'Subject created', 'subject_id' => $conn->lastInsertId()]);
}

function updateSubject(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['subject_id']) || empty($data['subject_code']) || empty($data['subject_name'])) {
        respond(['success' => false, 'message' => 'subject_id, subject_code, and subject_name are required'], 422);
    }

    $stmt = $conn->prepare('UPDATE subjects SET subject_code = :subject_code, subject_name = :subject_name, description = :description WHERE subject_id = :subject_id');
    $stmt->bindValue(':subject_code', $data['subject_code']);
    $stmt->bindValue(':subject_name', $data['subject_name']);
    $stmt->bindValue(':description', $data['description'] ?? null);
    $stmt->bindValue(':subject_id', $data['subject_id'], PDO::PARAM_INT);
    $stmt->execute();

    respond(['success' => true, 'message' => 'Subject updated']);
}

function deleteSubject(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['subject_id'])) {
        respond(['success' => false, 'message' => 'Subject ID is required'], 422);
    }

    $stmt = $conn->prepare('UPDATE subjects SET is_deleted = 1, deleted_at = NOW() WHERE subject_id = :subject_id');
    $stmt->bindValue(':subject_id', $data['subject_id'], PDO::PARAM_INT);
    $stmt->execute();

    respond(['success' => true, 'message' => 'Subject deleted']);
}
?>
