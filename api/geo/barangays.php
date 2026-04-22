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
        case 'getBarangaysByCityMunicipality':
            getBarangaysByCityMunicipality($conn);
            break;
        default:
            respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getBarangaysByCityMunicipality(PDO $conn): void {
    $cityMunicipalityId = (int)($_GET['city_municipality_id'] ?? 0);
    if ($cityMunicipalityId <= 0) {
        respond(['success' => false, 'message' => 'city_municipality_id is required'], 422);
    }

    $stmt = $conn->prepare(
        'SELECT barangay_id, city_municipality_id, psgc_code, barangay_name
         FROM geo_barangays
         WHERE is_active = 1 AND city_municipality_id = :city_municipality_id
         ORDER BY barangay_name'
    );
    $stmt->bindValue(':city_municipality_id', $cityMunicipalityId, PDO::PARAM_INT);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}
?>
