<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

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

$operation = $_GET['operation'] ?? '';
$method = $_SERVER['REQUEST_METHOD'] ?? '';

if ($operation === '' && $method === 'GET') {
    $operation = 'getAuditLogs';
}

// Audit logs are admin-only
$session = auth_require_roles(['admin']);

try {
    switch ($operation) {
        case 'getAuditLogs':
            getAuditLogs($conn);
            break;
        case 'getAuditLogById':
            getAuditLogById($conn);
            break;
        case 'getAuditLogFilters':
            getAuditLogFilters($conn);
            break;
        default:
            respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAuditLogs(PDO $conn): void {
    $page = max(1, (int)($_GET['page'] ?? 1));
    $perPage = max(1, min(100, (int)($_GET['perPage'] ?? 20)));
    $offset = ($page - 1) * $perPage;

    $where = ['1=1'];
    $params = [];

    // Filter by table_name
    if (!empty($_GET['table_name'])) {
        $where[] = 'a.table_name = :table_name';
        $params[':table_name'] = $_GET['table_name'];
    }

    // Filter by action
    if (!empty($_GET['action'])) {
        $where[] = 'a.action = :action';
        $params[':action'] = $_GET['action'];
    }

    // Filter by user_id
    if (!empty($_GET['user_id'])) {
        $where[] = 'a.user_id = :user_id';
        $params[':user_id'] = (int)$_GET['user_id'];
    }

    // Filter by date range
    if (!empty($_GET['date_from'])) {
        $where[] = 'a.action_time >= :date_from';
        $params[':date_from'] = $_GET['date_from'] . ' 00:00:00';
    }
    if (!empty($_GET['date_to'])) {
        $where[] = 'a.action_time <= :date_to';
        $params[':date_to'] = $_GET['date_to'] . ' 23:59:59';
    }

    // Search
    if (!empty($_GET['search'])) {
        $where[] = '(u.username LIKE :search OR a.table_name LIKE :search OR a.action LIKE :search)';
        $params[':search'] = '%' . $_GET['search'] . '%';
    }

    $whereClause = implode(' AND ', $where);

    // Get total count
    $countSql = "SELECT COUNT(*) FROM audit_logs a LEFT JOIN users u ON a.user_id = u.user_id WHERE {$whereClause}";
    $stmt = $conn->prepare($countSql);
    foreach ($params as $key => $val) {
        $stmt->bindValue($key, $val);
    }
    $stmt->execute();
    $totalRecords = (int)$stmt->fetchColumn();

    // Get paginated results
    $sql = "SELECT a.audit_id, a.user_id, u.username, a.table_name, a.record_id,
                   a.action, a.old_values, a.new_values, a.action_time, a.ip_address
            FROM audit_logs a
            LEFT JOIN users u ON a.user_id = u.user_id
            WHERE {$whereClause}
            ORDER BY a.action_time DESC
            LIMIT :limit OFFSET :offset";
    $stmt = $conn->prepare($sql);
    foreach ($params as $key => $val) {
        $stmt->bindValue($key, $val);
    }
    $stmt->bindValue(':limit', $perPage, PDO::PARAM_INT);
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute();
    $records = $stmt->fetchAll(PDO::FETCH_ASSOC);

    respond([
        'success' => true,
        'data' => $records,
        'pagination' => [
            'page' => $page,
            'perPage' => $perPage,
            'totalRecords' => $totalRecords,
            'totalPages' => max(1, (int)ceil($totalRecords / $perPage))
        ]
    ]);
}

function getAuditLogById(PDO $conn): void {
    $id = (int)($_GET['audit_id'] ?? 0);
    if (!$id) {
        respond(['success' => false, 'message' => 'audit_id is required'], 422);
    }

    $stmt = $conn->prepare(
        'SELECT a.audit_id, a.user_id, u.username, a.table_name, a.record_id,
                a.action, a.old_values, a.new_values, a.action_time, a.ip_address
         FROM audit_logs a
         LEFT JOIN users u ON a.user_id = u.user_id
         WHERE a.audit_id = :audit_id'
    );
    $stmt->bindValue(':audit_id', $id, PDO::PARAM_INT);
    $stmt->execute();
    $record = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$record) {
        respond(['success' => false, 'message' => 'Audit log not found'], 404);
    }

    respond(['success' => true, 'data' => $record]);
}

function getAuditLogFilters(PDO $conn): void {
    // Get distinct table names
    $stmt = $conn->query('SELECT DISTINCT table_name FROM audit_logs ORDER BY table_name');
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);

    // Get distinct actions
    $stmt = $conn->query('SELECT DISTINCT action FROM audit_logs ORDER BY action');
    $actions = $stmt->fetchAll(PDO::FETCH_COLUMN);

    // Get distinct users
    $stmt = $conn->query(
        'SELECT DISTINCT a.user_id, u.username
         FROM audit_logs a
         LEFT JOIN users u ON a.user_id = u.user_id
         WHERE a.user_id IS NOT NULL
         ORDER BY u.username'
    );
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);

    respond([
        'success' => true,
        'tables' => $tables,
        'actions' => $actions,
        'users' => $users
    ]);
}
?>
