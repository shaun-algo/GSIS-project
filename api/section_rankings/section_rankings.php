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
        case 'getAllSectionRankings': getAllSectionRankings($conn); break;
        case 'createSectionRanking': createSectionRanking($conn); break;
        case 'updateSectionRanking': updateSectionRanking($conn); break;
        case 'deleteSectionRanking': deleteSectionRanking($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllSectionRankings(PDO $conn): void {
    $sql = "SELECT sr.ranking_id, sr.enrollment_id, sr.section_id, sr.school_year_id, sr.rank, sr.honor_level_id,
                   CONCAT(l.last_name, ', ', l.first_name) AS learner_name,
                   sec.section_name, sy.year_label, sy.year_start, sy.year_end,
                   hl.honor_name
            FROM section_rankings sr
            JOIN enrollments e ON sr.enrollment_id = e.enrollment_id
            JOIN learners l ON e.learner_id = l.learner_id
            LEFT JOIN sections sec ON sr.section_id = sec.section_id
            LEFT JOIN school_years sy ON sr.school_year_id = sy.school_year_id
            LEFT JOIN honor_levels hl ON sr.honor_level_id = hl.honor_level_id
            WHERE sr.is_deleted = 0
            ORDER BY sr.ranking_id DESC";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function createSectionRanking(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['enrollment_id']) || empty($data['section_id']) || empty($data['school_year_id'])) {
        respond(['success' => false, 'message' => 'Enrollment, section, and school year are required'], 422);
    }
    $stmt = $conn->prepare('INSERT INTO section_rankings (enrollment_id, section_id, school_year_id, rank, honor_level_id) VALUES (:enrollment_id, :section_id, :school_year_id, :rank, :honor_level_id)');
    $stmt->bindValue(':enrollment_id', $data['enrollment_id'], PDO::PARAM_INT);
    $stmt->bindValue(':section_id', $data['section_id'], PDO::PARAM_INT);
    $stmt->bindValue(':school_year_id', $data['school_year_id'], PDO::PARAM_INT);
    $stmt->bindValue(':rank', $data['rank'] ?? null);
    $stmt->bindValue(':honor_level_id', $data['honor_level_id'] ?? null, $data['honor_level_id'] === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Section ranking created', 'ranking_id' => $conn->lastInsertId()]);
}

function updateSectionRanking(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['ranking_id']) || empty($data['enrollment_id']) || empty($data['section_id']) || empty($data['school_year_id'])) {
        respond(['success' => false, 'message' => 'Ranking ID, enrollment, section, and school year are required'], 422);
    }
    $stmt = $conn->prepare('UPDATE section_rankings SET enrollment_id = :enrollment_id, section_id = :section_id, school_year_id = :school_year_id, rank = :rank, honor_level_id = :honor_level_id WHERE ranking_id = :ranking_id');
    $stmt->bindValue(':enrollment_id', $data['enrollment_id'], PDO::PARAM_INT);
    $stmt->bindValue(':section_id', $data['section_id'], PDO::PARAM_INT);
    $stmt->bindValue(':school_year_id', $data['school_year_id'], PDO::PARAM_INT);
    $stmt->bindValue(':rank', $data['rank'] ?? null);
    $stmt->bindValue(':honor_level_id', $data['honor_level_id'] ?? null, $data['honor_level_id'] === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
    $stmt->bindValue(':ranking_id', $data['ranking_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Section ranking updated']);
}

function deleteSectionRanking(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['ranking_id'])) {
        respond(['success' => false, 'message' => 'Ranking ID is required'], 422);
    }
    $stmt = $conn->prepare('UPDATE section_rankings SET is_deleted = 1, deleted_at = NOW() WHERE ranking_id = :ranking_id');
    $stmt->bindValue(':ranking_id', $data['ranking_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Section ranking deleted']);
}
?>
