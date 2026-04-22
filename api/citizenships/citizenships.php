<?php
header('Content-Type: application/json');
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

function ensureCitizenshipsTable(PDO $conn): void {
    try {
        $conn->query('SELECT 1 FROM citizenships LIMIT 1');
        return;
    } catch (PDOException $e) {
        $sqlState = (string)($e->getCode() ?? '');
        $msg = (string)$e->getMessage();
        $missing = ($sqlState === '42S02') || str_contains(strtolower($msg), 'citizenships') && str_contains(strtolower($msg), 'not found');
        if (!$missing) {
            throw $e;
        }
    }

    // Create lookup table compatible with existing masterfile UI.
    $conn->exec('CREATE TABLE IF NOT EXISTS `citizenships` (
        `citizenship_id` int(11) NOT NULL AUTO_INCREMENT,
        `country_name` varchar(100) NOT NULL,
        `is_deleted` tinyint(1) DEFAULT 0,
        `deleted_at` datetime DEFAULT NULL,
        PRIMARY KEY (`citizenship_id`),
        UNIQUE KEY `uq_country_name` (`country_name`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci');

    // Optional seed from learners table if the clean schema is used.
    try {
        $conn->exec("INSERT IGNORE INTO citizenships (country_name)
            SELECT DISTINCT TRIM(citizenship) AS country_name
            FROM learners
            WHERE is_deleted = 0 AND citizenship IS NOT NULL AND TRIM(citizenship) <> ''");
    } catch (Throwable $_) {
        // If learners table/column doesn't exist in this schema, skip seeding.
    }
}
function getJsonInput(): array {
    $raw = file_get_contents('php://input');
    return $raw ? (json_decode($raw, true) ?: []) : [];
}

$operation = $_GET['operation'] ?? '';
$session = auth_enforce_roles($operation, ['admin', 'teacher'], ['admin']);
try {
    switch ($operation) {
        case 'getAllCitizenships':    getAllCitizenships($conn); break;
        case 'createCitizenship':    createCitizenship($conn); break;
        case 'updateCitizenship':    updateCitizenship($conn); break;
        case 'deleteCitizenship':    deleteCitizenship($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllCitizenships(PDO $conn): void {
    ensureCitizenshipsTable($conn);
    $stmt = $conn->prepare('SELECT citizenship_id, country_name FROM citizenships WHERE is_deleted = 0 ORDER BY country_name');
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}
function createCitizenship(PDO $conn): void {
    ensureCitizenshipsTable($conn);
    $data = getJsonInput();
    if (empty($data['country_name'])) respond(['success' => false, 'message' => 'Country name is required'], 422);
    $stmt = $conn->prepare('INSERT INTO citizenships (country_name) VALUES (:country_name)');
    $stmt->bindValue(':country_name', $data['country_name']);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Citizenship created', 'citizenship_id' => $conn->lastInsertId()]);
}
function updateCitizenship(PDO $conn): void {
    ensureCitizenshipsTable($conn);
    $data = getJsonInput();
    if (empty($data['citizenship_id']) || empty($data['country_name'])) respond(['success' => false, 'message' => 'ID and country name are required'], 422);
    $stmt = $conn->prepare('UPDATE citizenships SET country_name = :country_name WHERE citizenship_id = :citizenship_id');
    $stmt->bindValue(':country_name', $data['country_name']);
    $stmt->bindValue(':citizenship_id', $data['citizenship_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Citizenship updated']);
}
function deleteCitizenship(PDO $conn): void {
    ensureCitizenshipsTable($conn);
    $data = getJsonInput();
    if (empty($data['citizenship_id'])) respond(['success' => false, 'message' => 'ID is required'], 422);
    $stmt = $conn->prepare('UPDATE citizenships SET is_deleted = 1, deleted_at = NOW() WHERE citizenship_id = :citizenship_id');
    $stmt->bindValue(':citizenship_id', $data['citizenship_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Citizenship deleted']);
}
?>
