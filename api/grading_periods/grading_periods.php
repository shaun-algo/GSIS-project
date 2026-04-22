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
// Teachers need read access for grade encoding workflows; keep writes admin-only.
$session = auth_enforce_roles($operation, ['admin', 'teacher'], ['admin']);
try {
    switch ($operation) {
        case 'getAllGradingPeriods': getAllGradingPeriods($conn); break;
        case 'createGradingPeriod': createGradingPeriod($conn); break;
        case 'updateGradingPeriod': updateGradingPeriod($conn); break;
        case 'deleteGradingPeriod': deleteGradingPeriod($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllGradingPeriods(PDO $conn): void {
    $sql = "SELECT gp.grading_period_id, gp.period_name, gp.date_start, gp.date_end,
                   gp.school_year_id, sy.year_label, sy.year_start, sy.year_end,
                   gp.status AS status_name
            FROM grading_periods gp
            LEFT JOIN school_years sy ON gp.school_year_id = sy.school_year_id
            WHERE gp.is_deleted = 0
            ORDER BY gp.grading_period_id DESC";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function createGradingPeriod(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['school_year_id']) || empty($data['period_name'])) {
        respond(['success' => false, 'message' => 'School year and period name are required'], 422);
    }

    $status = trim((string)($data['status'] ?? ''));
    $statusId = isset($data['grading_period_status_id']) ? (int)$data['grading_period_status_id'] : 0;
    if ($status === '' && $statusId > 0) {
        $idMap = [1 => 'Open', 2 => 'Submitted', 3 => 'Approved', 4 => 'Locked'];
        $status = $idMap[$statusId] ?? '';
    }
    if ($status === '') {
        $status = 'Open';
    }
    $allowed = ['Open','Submitted','Approved','Locked'];
    if (!in_array($status, $allowed, true)) {
        respond(['success' => false, 'message' => 'Invalid status'], 422);
    }

    $stmt = $conn->prepare('INSERT INTO grading_periods (school_year_id, period_name, status, date_start, date_end) VALUES (:school_year_id, :period_name, :status, :date_start, :date_end)');
    $stmt->bindValue(':school_year_id', $data['school_year_id'], PDO::PARAM_INT);
    $stmt->bindValue(':period_name', $data['period_name']);
    $stmt->bindValue(':status', $status);
    $stmt->bindValue(':date_start', $data['date_start'] ?? null);
    $stmt->bindValue(':date_end', $data['date_end'] ?? null);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Grading period created', 'grading_period_id' => $conn->lastInsertId()]);
}

function updateGradingPeriod(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['grading_period_id']) || empty($data['school_year_id']) || empty($data['period_name'])) {
        respond(['success' => false, 'message' => 'ID, school year, and period name are required'], 422);
    }

    $status = trim((string)($data['status'] ?? ''));
    $statusId = isset($data['grading_period_status_id']) ? (int)$data['grading_period_status_id'] : 0;
    if ($status === '' && $statusId > 0) {
        $idMap = [1 => 'Open', 2 => 'Submitted', 3 => 'Approved', 4 => 'Locked'];
        $status = $idMap[$statusId] ?? '';
    }
    if ($status === '') {
        $status = 'Open';
    }
    $allowed = ['Open','Submitted','Approved','Locked'];
    if (!in_array($status, $allowed, true)) {
        respond(['success' => false, 'message' => 'Invalid status'], 422);
    }

    $stmt = $conn->prepare('UPDATE grading_periods SET school_year_id = :school_year_id, period_name = :period_name, status = :status, date_start = :date_start, date_end = :date_end WHERE grading_period_id = :grading_period_id');
    $stmt->bindValue(':school_year_id', $data['school_year_id'], PDO::PARAM_INT);
    $stmt->bindValue(':period_name', $data['period_name']);
    $stmt->bindValue(':status', $status);
    $stmt->bindValue(':date_start', $data['date_start'] ?? null);
    $stmt->bindValue(':date_end', $data['date_end'] ?? null);
    $stmt->bindValue(':grading_period_id', $data['grading_period_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Grading period updated']);
}

function deleteGradingPeriod(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['grading_period_id'])) {
        respond(['success' => false, 'message' => 'Grading period ID is required'], 422);
    }
    $stmt = $conn->prepare('UPDATE grading_periods SET is_deleted = 1, deleted_at = NOW() WHERE grading_period_id = :grading_period_id');
    $stmt->bindValue(':grading_period_id', $data['grading_period_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Grading period deleted']);
}
?>
