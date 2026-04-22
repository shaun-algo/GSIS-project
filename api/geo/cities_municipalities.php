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
        case 'getCitiesMunicipalitiesByProvince':
            getCitiesMunicipalitiesByProvince($conn);
            break;
        default:
            respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getCitiesMunicipalitiesByProvince(PDO $conn): void {
    $provinceId = (int)($_GET['province_id'] ?? 0);
    if ($provinceId <= 0) {
        respond(['success' => false, 'message' => 'province_id is required'], 422);
    }

    $stmt = $conn->prepare(
        'SELECT city_municipality_id, province_id, psgc_code, city_municipality_name, is_city
         FROM geo_cities_municipalities
         WHERE is_active = 1 AND province_id = :province_id
         ORDER BY city_municipality_name'
    );
    $stmt->bindValue(':province_id', $provinceId, PDO::PARAM_INT);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}
?>
