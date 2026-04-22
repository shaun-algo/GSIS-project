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
        case 'getAllFinalGrades': getAllFinalGrades($conn); break;
        case 'createFinalGrade': createFinalGrade($conn); break;
        case 'updateFinalGrade': updateFinalGrade($conn); break;
        case 'deleteFinalGrade': deleteFinalGrade($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllFinalGrades(PDO $conn): void {
    $sql = "SELECT fg.final_grade_id, fg.enrollment_id, fg.class_id, fg.final_grade,
                   fg.remark AS remark_name,
                   CONCAT(l.last_name, ', ', l.first_name) AS learner_name,
                   s.subject_name
            FROM final_grades fg
            JOIN enrollments e ON fg.enrollment_id = e.enrollment_id
            JOIN learners l ON e.learner_id = l.learner_id
            JOIN class_offerings c ON fg.class_id = c.class_id
            JOIN subjects s ON c.subject_id = s.subject_id
                        WHERE fg.is_deleted = 0
                            AND c.is_deleted = 0
            ORDER BY fg.final_grade_id DESC";
    $stmt = $conn->prepare($sql);
    $stmt->execute();

    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($rows as &$row) {
        // Backward compatibility for older clients expecting grade_remark_id
        $row['grade_remark_id'] = match ($row['remark_name']) {
            'Passed' => 1,
            'Failed' => 2,
            default => null,
        };
    }
    unset($row);
    respond($rows);
}

function createFinalGrade(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['enrollment_id']) || empty($data['class_id'])) {
        respond(['success' => false, 'message' => 'Enrollment and class are required'], 422);
    }

    $remark = trim((string)($data['remark'] ?? ''));
    $remarkId = isset($data['grade_remark_id']) ? (int)$data['grade_remark_id'] : 0;
    if ($remark === '' && $remarkId > 0) {
        $idMap = [1 => 'Passed', 2 => 'Failed'];
        $remark = $idMap[$remarkId] ?? '';
    }
    if ($remark === '') {
        $remark = 'Failed';
    }
    $allowed = ['Passed','Failed'];
    if (!in_array($remark, $allowed, true)) {
        respond(['success' => false, 'message' => 'Invalid remark'], 422);
    }

    $stmt = $conn->prepare('INSERT INTO final_grades (enrollment_id, class_id, final_grade, remark) VALUES (:enrollment_id, :class_id, :final_grade, :remark)');
    $stmt->bindValue(':enrollment_id', $data['enrollment_id'], PDO::PARAM_INT);
    $stmt->bindValue(':class_id', $data['class_id'], PDO::PARAM_INT);
    $stmt->bindValue(':final_grade', $data['final_grade'] ?? null);
    $stmt->bindValue(':remark', $remark);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Final grade created', 'final_grade_id' => $conn->lastInsertId()]);
}

function updateFinalGrade(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['final_grade_id']) || empty($data['enrollment_id']) || empty($data['class_id'])) {
        respond(['success' => false, 'message' => 'Final grade ID, enrollment, and class are required'], 422);
    }

    $remark = trim((string)($data['remark'] ?? ''));
    $remarkId = isset($data['grade_remark_id']) ? (int)$data['grade_remark_id'] : 0;
    if ($remark === '' && $remarkId > 0) {
        $idMap = [1 => 'Passed', 2 => 'Failed'];
        $remark = $idMap[$remarkId] ?? '';
    }
    if ($remark === '') {
        $remark = 'Failed';
    }
    $allowed = ['Passed','Failed'];
    if (!in_array($remark, $allowed, true)) {
        respond(['success' => false, 'message' => 'Invalid remark'], 422);
    }

    $stmt = $conn->prepare('UPDATE final_grades SET enrollment_id = :enrollment_id, class_id = :class_id, final_grade = :final_grade, remark = :remark WHERE final_grade_id = :final_grade_id');
    $stmt->bindValue(':enrollment_id', $data['enrollment_id'], PDO::PARAM_INT);
    $stmt->bindValue(':class_id', $data['class_id'], PDO::PARAM_INT);
    $stmt->bindValue(':final_grade', $data['final_grade'] ?? null);
    $stmt->bindValue(':remark', $remark);
    $stmt->bindValue(':final_grade_id', $data['final_grade_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Final grade updated']);
}

function deleteFinalGrade(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['final_grade_id'])) {
        respond(['success' => false, 'message' => 'Final grade ID is required'], 422);
    }
    $stmt = $conn->prepare('UPDATE final_grades SET is_deleted = 1, deleted_at = NOW() WHERE final_grade_id = :final_grade_id');
    $stmt->bindValue(':final_grade_id', $data['final_grade_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Final grade deleted']);
}
?>
