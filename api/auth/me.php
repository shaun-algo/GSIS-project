<?php
require_once __DIR__ . '/../utils/cors.php';
header('Content-Type: application/json');

require_once __DIR__ . '/../database/connection.php';
require_once __DIR__ . '/../utils/auth.php';

function respond($payload, int $code = 200): void {
    http_response_code($code);
    echo json_encode($payload);
    exit;
}

$session = auth_require();
$userId = (int)$session['user_id'];
$firstName = '';
$lastName = '';
$employeeId = null;
$positionId = null;
$positionName = '';
$isAdviser = false;

try {
    $stmt = $conn->prepare(
        'SELECT emp.employee_id,
                emp.first_name,
                emp.last_name,
                emp.position_id,
                p.position_name
         FROM employees emp
         LEFT JOIN positions p
                ON p.position_id = emp.position_id
               AND p.is_deleted = 0
         WHERE emp.user_id = :user_id
           AND emp.is_deleted = 0
         LIMIT 1'
    );
    $stmt->bindValue(':user_id', $userId, PDO::PARAM_INT);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($row) {
        $employeeId = isset($row['employee_id']) ? (int)$row['employee_id'] : null;
        $firstName = $row['first_name'] ?? '';
        $lastName = $row['last_name'] ?? '';
        $positionId = isset($row['position_id']) && $row['position_id'] !== null ? (int)$row['position_id'] : null;
        $positionName = $row['position_name'] ?? '';
    }
} catch (Exception $e) {
    $firstName = '';
    $lastName = '';
    $employeeId = null;
    $positionId = null;
    $positionName = '';
}

$fullName = trim($firstName . ' ' . $lastName);

// Derived privileges
$roleKey = (string)($session['role_key'] ?? '');
$rk = strtolower(trim($roleKey));
$isRegistrar = ($rk === 'registrar');
$isAdviser = ($rk === 'adviser' || $rk === 'advisor');

$canMonitorReports = in_array($rk, ['admin', 'registrar'], true);
$canExportHonorsYearLevel = in_array($rk, ['admin', 'registrar', 'adviser', 'advisor'], true);

respond([
    'success' => true,
    'data' => [
        'user_id' => $userId,
        'username' => $_SESSION['username'] ?? '',
        'role_id' => (int)($_SESSION['role_id'] ?? 0),
        'role_name' => $_SESSION['role_name'] ?? '',
        'role_key' => $roleKey,
        'first_name' => $firstName,
        'last_name' => $lastName,
        'full_name' => $fullName,
        'employee_id' => $employeeId,
        'position_id' => $positionId,
        'position_name' => $positionName,
        'is_adviser' => $isAdviser,
        'is_registrar' => $isRegistrar,
        'privileges' => [
            'can_monitor_reports' => $canMonitorReports,
            'can_export_honors_year_level' => $canExportHonorsYearLevel
        ]
    ]
]);
?>
