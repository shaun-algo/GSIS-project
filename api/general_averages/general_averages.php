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
        case 'getAllGeneralAverages': getAllGeneralAverages($conn); break;
        case 'createGeneralAverage': createGeneralAverage($conn); break;
        case 'updateGeneralAverage': updateGeneralAverage($conn); break;
        case 'deleteGeneralAverage': deleteGeneralAverage($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllGeneralAverages(PDO $conn): void {
    $sql = "SELECT ga.general_average_id, ga.enrollment_id, ga.school_year_id, ga.general_average,
                   CONCAT(l.last_name, ', ', l.first_name) AS learner_name,
                   sy.year_label, sy.year_start, sy.year_end
            FROM general_averages ga
            JOIN enrollments e ON ga.enrollment_id = e.enrollment_id
            JOIN learners l ON e.learner_id = l.learner_id
            JOIN school_years sy ON ga.school_year_id = sy.school_year_id
            WHERE ga.is_deleted = 0
            ORDER BY ga.general_average_id DESC";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function createGeneralAverage(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['enrollment_id']) || empty($data['school_year_id'])) {
        respond(['success' => false, 'message' => 'Enrollment and school year are required'], 422);
    }
    $stmt = $conn->prepare('INSERT INTO general_averages (enrollment_id, school_year_id, general_average) VALUES (:enrollment_id, :school_year_id, :general_average)');
    $stmt->bindValue(':enrollment_id', $data['enrollment_id'], PDO::PARAM_INT);
    $stmt->bindValue(':school_year_id', $data['school_year_id'], PDO::PARAM_INT);
    $stmt->bindValue(':general_average', $data['general_average'] ?? null);
    $stmt->execute();
    respond(['success' => true, 'message' => 'General average created', 'general_average_id' => $conn->lastInsertId()]);
}

function updateGeneralAverage(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['general_average_id']) || empty($data['enrollment_id']) || empty($data['school_year_id'])) {
        respond(['success' => false, 'message' => 'General average ID, enrollment, and school year are required'], 422);
    }
    $stmt = $conn->prepare('UPDATE general_averages SET enrollment_id = :enrollment_id, school_year_id = :school_year_id, general_average = :general_average WHERE general_average_id = :general_average_id');
    $stmt->bindValue(':enrollment_id', $data['enrollment_id'], PDO::PARAM_INT);
    $stmt->bindValue(':school_year_id', $data['school_year_id'], PDO::PARAM_INT);
    $stmt->bindValue(':general_average', $data['general_average'] ?? null);
    $stmt->bindValue(':general_average_id', $data['general_average_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'General average updated']);
}

function deleteGeneralAverage(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['general_average_id'])) {
        respond(['success' => false, 'message' => 'General average ID is required'], 422);
    }
    $stmt = $conn->prepare('UPDATE general_averages SET is_deleted = 1, deleted_at = NOW() WHERE general_average_id = :general_average_id');
    $stmt->bindValue(':general_average_id', $data['general_average_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'General average deleted']);
}
?>
