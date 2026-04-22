<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
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

$operation = $_GET['operation'] ?? '';
$session = auth_enforce_roles($operation, ['admin', 'teacher', 'registrar'], ['admin', 'teacher']);

try {
    switch ($operation) {
        case 'getAllProvinces':
            getAllProvinces($conn);
            break;
        default:
            respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllProvinces(PDO $conn): void {
    $q = trim((string)($_GET['q'] ?? ''));

    if ($q !== '') {
        $stmt = $conn->prepare(
            'SELECT province_id, psgc_code, province_name
             FROM geo_provinces
             WHERE is_active = 1 AND province_name LIKE :q
             ORDER BY province_name'
        );
        $stmt->bindValue(':q', '%' . $q . '%');
        $stmt->execute();
        respond($stmt->fetchAll(PDO::FETCH_ASSOC));
    }

    $stmt = $conn->prepare(
        'SELECT province_id, psgc_code, province_name
         FROM geo_provinces
         WHERE is_active = 1
         ORDER BY province_name'
    );
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}
?>
