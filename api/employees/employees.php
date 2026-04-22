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

function requireAuth(): int {
    $session = auth_require();
    return (int)($session['user_id'] ?? 0);
}

function respond($payload, int $code = 200): void {
    http_response_code($code);
    echo json_encode($payload);
    exit;
}

function normalizeInput($value) {
    if ($value === null) {
        return null;
    }
    if (is_string($value)) {
        $trimmed = trim($value);
        return $trimmed === '' ? null : $trimmed;
    }
    return $value;
}

function getJsonInput(): array {
    $raw = file_get_contents('php://input');
    return $raw ? (json_decode($raw, true) ?: []) : [];
}

$operation = $_GET['operation'] ?? '';

// Employee self-service: allow teachers/admin to view/update their own record.
if ($operation === 'getMyEmployee' || $operation === 'updateMyEmployee') {
    // Self-service profile updates should be available to any authenticated employee account.
    // Learner accounts do not have an employee record.
    $session = auth_require();
    if (($session['role_key'] ?? '') === 'learners') {
        respond(['success' => false, 'message' => 'Not authorized'], 403);
    }
} else {
    $readRoles = ['admin', 'teacher'];
    $writeRoles = ['admin'];

    if ($operation === 'getAllEmployees' || $operation === 'createEmployee') {
        $readRoles[] = 'registrar';
    }
    if ($operation === 'createEmployee') {
        $writeRoles[] = 'registrar';
    }

    $session = auth_enforce_roles($operation, $readRoles, $writeRoles);
}

try {
    switch ($operation) {
        case 'getAllEmployees':
            getAllEmployees($conn);
            break;
        case 'getMyEmployee':
            getMyEmployee($conn);
            break;
        case 'createEmployee':
            createEmployee($conn);
            break;
        case 'updateEmployee':
            updateEmployee($conn);
            break;
        case 'updateMyEmployee':
            updateMyEmployee($conn);
            break;
        case 'deleteEmployee':
            deleteEmployee($conn);
            break;
        default:
            respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllEmployees(PDO $conn): void {
    $sql = 'SELECT e.employee_id, e.user_id, e.employee_number, e.first_name, e.middle_name, e.last_name, e.name_extension,
                   e.date_of_birth, e.gender, e.contact_number, e.email, e.address, e.position_id, e.date_hired,
                   p.position_name, u.username, u.role_id, r.role_name
            FROM employees e
            LEFT JOIN positions p ON e.position_id = p.position_id
            LEFT JOIN users u ON e.user_id = u.user_id
            LEFT JOIN roles r ON u.role_id = r.role_id
            WHERE e.is_deleted = 0
            ORDER BY e.employee_number';
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function getMyEmployee(PDO $conn): void {
    $userId = requireAuth();

    $sql = 'SELECT e.employee_id, e.user_id, e.employee_number, e.first_name, e.middle_name, e.last_name, e.name_extension,
                   e.date_of_birth, e.gender, e.contact_number, e.email, e.address, e.position_id, e.date_hired,
                   p.position_name, u.username, u.role_id, r.role_name
            FROM employees e
            LEFT JOIN positions p ON e.position_id = p.position_id
            LEFT JOIN users u ON e.user_id = u.user_id
            LEFT JOIN roles r ON u.role_id = r.role_id
            WHERE e.is_deleted = 0 AND e.user_id = :user_id
            LIMIT 1';

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':user_id', $userId, PDO::PARAM_INT);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$row) {
        // Check if user exists and get basic user info for admins without employee records
        $userSql = 'SELECT u.user_id, u.username, u.role_id, r.role_name
                   FROM users u
                   LEFT JOIN roles r ON u.role_id = r.role_id
                   WHERE u.user_id = :user_id AND u.is_deleted = 0
                   LIMIT 1';

        $userStmt = $conn->prepare($userSql);
        $userStmt->bindValue(':user_id', $userId, PDO::PARAM_INT);
        $userStmt->execute();
        $userInfo = $userStmt->fetch(PDO::FETCH_ASSOC);

        if ($userInfo && ($userInfo['role_name'] === 'admin' || $userInfo['role_name'] === 'Administrator')) {
            // Admin user without employee record - return basic user info
            respond(['success' => true, 'data' => [
                'employee_id' => null,
                'user_id' => $userInfo['user_id'],
                'employee_number' => $userInfo['username'],
                'first_name' => 'System',
                'last_name' => 'Administrator',
                'middle_name' => '',
                'name_extension' => '',
                'date_of_birth' => null,
                'gender' => '',
                'contact_number' => '',
                'email' => '',
                'address' => '',
                'position_id' => null,
                'date_hired' => null,
                'position_name' => 'System Administrator',
                'username' => $userInfo['username'],
                'role_id' => $userInfo['role_id'],
                'role_name' => $userInfo['role_name']
            ], 'message' => 'Admin user without employee record']);
        }

        // Return success with null data for other users without employee records
        respond(['success' => true, 'data' => null, 'message' => 'No employee record found for this user']);
    }

    respond(['success' => true, 'data' => $row]);
}

function createEmployee(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['employee_number']) || empty($data['first_name']) || empty($data['last_name']) || empty($data['role_id'])) {
        respond(['success' => false, 'message' => 'Employee number, first name, last name, and role are required'], 422);
    }

    $employeeNumber = normalizeInput($data['employee_number'] ?? null);

    $check = $conn->prepare('SELECT COUNT(*) FROM users WHERE username = :username AND is_deleted = 0');
    $check->bindValue(':username', $employeeNumber);
    $check->execute();
    if ($check->fetchColumn() > 0) {
        respond(['success' => false, 'message' => 'Username already exists'], 409);
    }

    $conn->beginTransaction();

    try {
        $stmt = $conn->prepare('INSERT INTO employees (user_id, employee_number, first_name, middle_name, last_name, name_extension, date_of_birth, gender, contact_number, email, address, position_id, date_hired)
            VALUES (:user_id, :employee_number, :first_name, :middle_name, :last_name, :name_extension, :date_of_birth, :gender, :contact_number, :email, :address, :position_id, :date_hired)');
        $stmtUser = $conn->prepare('INSERT INTO users (username, password, role_id, is_active) VALUES (:username, :password, :role_id, 1)');
        $stmtUser->bindValue(':username', $employeeNumber);
        $stmtUser->bindValue(':password', password_hash((string)$employeeNumber, PASSWORD_BCRYPT));
        $stmtUser->bindValue(':role_id', $data['role_id'], PDO::PARAM_INT);
        $stmtUser->execute();

        $userId = (int)$conn->lastInsertId();

        $stmt->bindValue(':user_id', $userId, PDO::PARAM_INT);
        $stmt->bindValue(':employee_number', $employeeNumber);
        $stmt->bindValue(':first_name', normalizeInput($data['first_name'] ?? null));
        $stmt->bindValue(':middle_name', normalizeInput($data['middle_name'] ?? null));
        $stmt->bindValue(':last_name', normalizeInput($data['last_name'] ?? null));
        $stmt->bindValue(':name_extension', normalizeInput($data['name_extension'] ?? null));
        $stmt->bindValue(':date_of_birth', normalizeInput($data['date_of_birth'] ?? null));
        $stmt->bindValue(':gender', normalizeInput($data['gender'] ?? null));
        $stmt->bindValue(':contact_number', normalizeInput($data['contact_number'] ?? null));
        $stmt->bindValue(':email', normalizeInput($data['email'] ?? null));
        $stmt->bindValue(':address', normalizeInput($data['address'] ?? null));
        $stmt->bindValue(':position_id', normalizeInput($data['position_id'] ?? null));
        $stmt->bindValue(':date_hired', normalizeInput($data['date_hired'] ?? null));
        $stmt->execute();

        $employeeId = $conn->lastInsertId();
        $conn->commit();

        respond(['success' => true, 'message' => 'Employee created', 'employee_id' => $employeeId, 'user_id' => $userId]);
    } catch (Throwable $e) {
        if ($conn->inTransaction()) {
            $conn->rollBack();
        }
        throw $e;
    }
}

function updateEmployee(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['employee_id']) || empty($data['employee_number']) || empty($data['first_name']) || empty($data['last_name'])) {
        respond(['success' => false, 'message' => 'Employee ID, number, first name, and last name are required'], 422);
    }

    $employeeNumber = normalizeInput($data['employee_number'] ?? null);

    $stmtUserId = $conn->prepare('SELECT user_id FROM employees WHERE employee_id = :employee_id');
    $stmtUserId->bindValue(':employee_id', $data['employee_id'], PDO::PARAM_INT);
    $stmtUserId->execute();
    $userId = $stmtUserId->fetchColumn();

    if ($userId) {
        $check = $conn->prepare('SELECT COUNT(*) FROM users WHERE username = :username AND is_deleted = 0 AND user_id != :user_id');
        $check->bindValue(':username', $employeeNumber);
        $check->bindValue(':user_id', $userId, PDO::PARAM_INT);
        $check->execute();
        if ($check->fetchColumn() > 0) {
            respond(['success' => false, 'message' => 'Username already exists'], 409);
        }
    }

    $stmt = $conn->prepare('UPDATE employees SET user_id = :user_id, employee_number = :employee_number, first_name = :first_name, middle_name = :middle_name, last_name = :last_name,
        name_extension = :name_extension, date_of_birth = :date_of_birth, gender = :gender, contact_number = :contact_number, email = :email, address = :address,
        position_id = :position_id, date_hired = :date_hired
        WHERE employee_id = :employee_id');
    $stmt->bindValue(':user_id', $userId, PDO::PARAM_INT);
    $stmt->bindValue(':employee_number', $employeeNumber);
    $stmt->bindValue(':first_name', normalizeInput($data['first_name'] ?? null));
    $stmt->bindValue(':middle_name', normalizeInput($data['middle_name'] ?? null));
    $stmt->bindValue(':last_name', normalizeInput($data['last_name'] ?? null));
    $stmt->bindValue(':name_extension', normalizeInput($data['name_extension'] ?? null));
    $stmt->bindValue(':date_of_birth', normalizeInput($data['date_of_birth'] ?? null));
    $stmt->bindValue(':gender', normalizeInput($data['gender'] ?? null));
    $stmt->bindValue(':contact_number', normalizeInput($data['contact_number'] ?? null));
    $stmt->bindValue(':email', normalizeInput($data['email'] ?? null));
    $stmt->bindValue(':address', normalizeInput($data['address'] ?? null));
    $stmt->bindValue(':position_id', normalizeInput($data['position_id'] ?? null));
    $stmt->bindValue(':date_hired', normalizeInput($data['date_hired'] ?? null));
    $stmt->bindValue(':employee_id', $data['employee_id'], PDO::PARAM_INT);
    $stmt->execute();

    if ($userId) {
        $stmtUser = $conn->prepare('UPDATE users SET username = :username, role_id = COALESCE(:role_id, role_id) WHERE user_id = :user_id');
        $stmtUser->bindValue(':username', $employeeNumber);
        $stmtUser->bindValue(':role_id', normalizeInput($data['role_id'] ?? null));
        $stmtUser->bindValue(':user_id', $userId, PDO::PARAM_INT);
        $stmtUser->execute();
    }

    respond(['success' => true, 'message' => 'Employee updated']);
}

function updateMyEmployee(PDO $conn): void {
    $userId = requireAuth();
    $data = getJsonInput();

    $employeeId = $data['employee_id'] ?? null;
    $employeeIdInt = $employeeId ? (int)$employeeId : 0;

    if ($employeeIdInt <= 0) {
        respond(['success' => false, 'message' => 'No employee profile record found for update'], 422);
    }

    $stmtCheck = $conn->prepare('SELECT employee_id FROM employees WHERE employee_id = :employee_id AND user_id = :user_id AND is_deleted = 0');
    $stmtCheck->bindValue(':employee_id', $employeeIdInt, PDO::PARAM_INT);
    $stmtCheck->bindValue(':user_id', $userId, PDO::PARAM_INT);
    $stmtCheck->execute();
    if (!$stmtCheck->fetch()) {
        respond(['success' => false, 'message' => 'Employee record not found or not owned by you'], 403);
    }

    $updateFields = [];
    $params = [':user_id' => $userId];

    if (isset($data['first_name'])) { $updateFields[] = 'first_name = :first_name'; $params[':first_name'] = normalizeInput($data['first_name']); }
    if (isset($data['middle_name'])) { $updateFields[] = 'middle_name = :middle_name'; $params[':middle_name'] = normalizeInput($data['middle_name']); }
    if (isset($data['last_name'])) { $updateFields[] = 'last_name = :last_name'; $params[':last_name'] = normalizeInput($data['last_name']); }
    if (isset($data['name_extension'])) { $updateFields[] = 'name_extension = :name_extension'; $params[':name_extension'] = normalizeInput($data['name_extension']); }
    if (isset($data['date_of_birth'])) { $updateFields[] = 'date_of_birth = :date_of_birth'; $params[':date_of_birth'] = normalizeInput($data['date_of_birth']); }
    if (isset($data['gender'])) { $updateFields[] = 'gender = :gender'; $params[':gender'] = normalizeInput($data['gender']); }
    if (isset($data['contact_number'])) { $updateFields[] = 'contact_number = :contact_number'; $params[':contact_number'] = normalizeInput($data['contact_number']); }
    if (isset($data['email'])) { $updateFields[] = 'email = :email'; $params[':email'] = normalizeInput($data['email']); }
    if (isset($data['address'])) { $updateFields[] = 'address = :address'; $params[':address'] = normalizeInput($data['address']); }
    if (isset($data['position_id'])) { $updateFields[] = 'position_id = :position_id'; $params[':position_id'] = normalizeInput($data['position_id']); }
    if (isset($data['date_hired'])) { $updateFields[] = 'date_hired = :date_hired'; $params[':date_hired'] = normalizeInput($data['date_hired']); }

    if (empty($updateFields)) {
        respond(['success' => true, 'message' => 'No changes made']);
    }

    $sql = 'UPDATE employees SET ' . implode(', ', $updateFields) . ' WHERE employee_id = :employee_id AND user_id = :user_id';
    $params[':employee_id'] = $employeeIdInt;

    $stmt = $conn->prepare($sql);
    $stmt->execute($params);

    respond(['success' => true, 'message' => 'Profile updated successfully']);
}

function deleteEmployee(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['employee_id'])) {
        respond(['success' => false, 'message' => 'Employee ID is required'], 422);
    }

    $stmt = $conn->prepare('UPDATE employees SET is_deleted = 1, deleted_at = NOW() WHERE employee_id = :employee_id');
    $stmt->bindValue(':employee_id', $data['employee_id'], PDO::PARAM_INT);
    $stmt->execute();

    respond(['success' => true, 'message' => 'Employee deleted']);
}
?>
