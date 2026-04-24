<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/../utils/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once __DIR__ . '/../database/connection.php';

require_once __DIR__ . '/../utils/auth.php';
require_once __DIR__ . '/../utils/audit.php';

function respond($payload, int $code = 200): void {
    http_response_code($code);
    echo json_encode($payload);
    exit;
}

function getJsonInput(): array {
    $raw = file_get_contents('php://input');
    return $raw ? (json_decode($raw, true) ?: []) : [];
}

function getLearnerRoleId(PDO $conn): int {
    // Prefer lookup by name to avoid hard-coding, but keep a safe fallback.
    try {
        $stmt = $conn->prepare("SELECT role_id FROM roles WHERE role_name = 'learners' AND is_deleted = 0 LIMIT 1");
        $stmt->execute();
        $rid = $stmt->fetchColumn();
        if ($rid) {
            return (int)$rid;
        }
    } catch (Exception $e) {
        // ignore and fall back
    }
    return 10;
}

function resolveOrCreateLearnerAccount(PDO $conn, string $lrn, ?int $providedUserId = null): array {
    $lrn = trim($lrn);
    if ($lrn === '') {
        if ($conn->inTransaction()) {
            $conn->rollBack();
        }
        respond(['success' => false, 'message' => 'LRN is required to create learner account'], 422);
    }

    if ($providedUserId !== null && $providedUserId > 0) {
        return ['user_id' => $providedUserId, 'created' => false, 'username' => $lrn];
    }

    $username = $lrn;
    $u = $conn->prepare('SELECT user_id, is_deleted FROM users WHERE username = :u LIMIT 1');
    $u->bindValue(':u', $username);
    $u->execute();
    $urow = $u->fetch(PDO::FETCH_ASSOC);
    $uid = $urow ? (int)($urow['user_id'] ?? 0) : 0;
    if ($uid > 0) {
        // Prevent a single user account from being linked to multiple learners.
        $chk = $conn->prepare('SELECT learner_id FROM learners WHERE user_id = :uid AND is_deleted = 0 LIMIT 1');
        $chk->bindValue(':uid', $uid, PDO::PARAM_INT);
        $chk->execute();
        if ($chk->fetchColumn()) {
            if ($conn->inTransaction()) {
                $conn->rollBack();
            }
            respond(['success' => false, 'message' => 'An existing user with this LRN is already linked to another learner.'], 409);
        }

        if (!empty($urow['is_deleted'])) {
            $roleId = getLearnerRoleId($conn);
            $restore = $conn->prepare('UPDATE users SET is_deleted = 0, deleted_at = NULL, is_active = 1, role_id = :role_id, password = :password WHERE user_id = :uid');
            $restore->bindValue(':role_id', $roleId, PDO::PARAM_INT);
            $restore->bindValue(':password', password_hash($lrn, PASSWORD_BCRYPT));
            $restore->bindValue(':uid', $uid, PDO::PARAM_INT);
            $restore->execute();
        }

        return ['user_id' => $uid, 'created' => false, 'username' => $username];
    }

    $roleId = getLearnerRoleId($conn);
    try {
        $ins = $conn->prepare('INSERT INTO users (username, password, role_id, is_active) VALUES (:username, :password, :role_id, 1)');
        $ins->bindValue(':username', $username);
        $ins->bindValue(':password', password_hash($lrn, PASSWORD_BCRYPT));
        $ins->bindValue(':role_id', $roleId, PDO::PARAM_INT);
        $ins->execute();
        return ['user_id' => (int)$conn->lastInsertId(), 'created' => true, 'username' => $username];
    } catch (PDOException $e) {
        if ((string)$e->getCode() === '23000') {
            $u2 = $conn->prepare('SELECT user_id, is_deleted FROM users WHERE username = :u LIMIT 1');
            $u2->bindValue(':u', $username);
            $u2->execute();
            $row2 = $u2->fetch(PDO::FETCH_ASSOC);
            $existingId = $row2 ? (int)($row2['user_id'] ?? 0) : 0;
            if ($existingId > 0) {
                if (!empty($row2['is_deleted'])) {
                    $restore = $conn->prepare('UPDATE users SET is_deleted = 0, deleted_at = NULL, is_active = 1, role_id = :role_id, password = :password WHERE user_id = :uid');
                    $restore->bindValue(':role_id', $roleId, PDO::PARAM_INT);
                    $restore->bindValue(':password', password_hash($lrn, PASSWORD_BCRYPT));
                    $restore->bindValue(':uid', $existingId, PDO::PARAM_INT);
                    $restore->execute();
                }
                return ['user_id' => $existingId, 'created' => false, 'username' => $username];
            }
        }
        throw $e;
    }
}

$operation = $_GET['operation'] ?? '';

// Define role permissions per operation
$operationRoles = [
    'getAllLearners'  => ['admin', 'teacher', 'registrar'],
    'createLearner'   => ['admin'],
    'updateLearner'   => ['admin', 'registrar'],  // Registrar can edit learner profiles
    'deleteLearner'   => ['admin']
];

// Get allowed roles for this operation (default to admin-only for security)
$allowedRoles = $operationRoles[$operation] ?? ['admin'];
$session = auth_require_roles($allowedRoles);

try {
    switch ($operation) {
        case 'getAllLearners':
            getAllLearners($conn);
            break;
        case 'createLearner':
            createLearner($conn);
            break;
        case 'updateLearner':
            updateLearner($conn);
            break;
        case 'deleteLearner':
            deleteLearner($conn);
            break;
        default:
            respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    if ($conn && $conn->inTransaction()) {
        $conn->rollBack();
    }
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllLearners(PDO $conn): void {
    $sql = "SELECT l.learner_id, l.lrn, l.first_name, l.middle_name, l.last_name, l.date_of_birth, l.gender,
                   l.learner_status AS learner_status_id,
                   l.learner_status AS status_name,
                   e.enrollment_id, e.grade_level_id, gl.grade_name, e.section_id, sec.section_name,
                   e.school_year_id
            FROM learners l
            LEFT JOIN (
                SELECT e1.*
                FROM enrollments e1
                INNER JOIN (
                    SELECT learner_id, MAX(enrollment_id) AS latest_id
                    FROM enrollments
                    WHERE is_deleted = 0
                    GROUP BY learner_id
                ) latest ON latest.latest_id = e1.enrollment_id
            ) e ON e.learner_id = l.learner_id
            LEFT JOIN grade_levels gl ON gl.grade_level_id = e.grade_level_id
            LEFT JOIN sections sec ON sec.section_id = e.section_id
            WHERE l.is_deleted = 0
            ORDER BY l.last_name, l.first_name";

    $stmt = $conn->prepare($sql);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function createLearner(PDO $conn): void {
    $data = getJsonInput();
    $lrn = trim((string)($data['lrn'] ?? ''));
    if ($lrn === '' || empty($data['first_name']) || empty($data['last_name']) || empty($data['grade_level_id']) || empty($data['section_id'])) {
        respond(['success' => false, 'message' => 'LRN, name, grade level, and section are required'], 422);
    }

    if (!preg_match('/^\d{12}$/', $lrn)) {
        respond(['success' => false, 'message' => 'LRN must be exactly 12 digits'], 422);
    }

    $schoolYearId = getActiveSchoolYearId($conn);
    if (!$schoolYearId) {
        respond(['success' => false, 'message' => 'No active school year found'], 409);
    }

    $userId = !empty($data['user_id']) ? (int)$data['user_id'] : null;
    $learnerStatus = !empty($data['learner_status_id']) ? (string)$data['learner_status_id'] : ($data['learner_status'] ?? null);

    $conn->beginTransaction();

    try {
        $account = resolveOrCreateLearnerAccount($conn, $lrn, $userId);

        $stmt = $conn->prepare('INSERT INTO learners (user_id, lrn, first_name, middle_name, last_name, name_extension, date_of_birth, gender, civil_status, religion, mother_tongue, indigenous_group, citizenship, learner_status, is_4ps_beneficiary, is_indigenous, completed, address, contact_number, email)
                                VALUES (:user_id, :lrn, :first_name, :middle_name, :last_name, :name_extension, :date_of_birth, :gender, :civil_status, :religion, :mother_tongue, :indigenous_group, :citizenship, :learner_status, :is_4ps_beneficiary, :is_indigenous, :completed, :address, :contact_number, :email)');
        $stmt->bindValue(':user_id', (int)$account['user_id'], PDO::PARAM_INT);
        $stmt->bindValue(':lrn', $lrn);
        $stmt->bindValue(':first_name', $data['first_name']);
        $stmt->bindValue(':middle_name', $data['middle_name'] ?? null);
        $stmt->bindValue(':last_name', $data['last_name']);
        $stmt->bindValue(':name_extension', $data['name_extension'] ?? ($data['name_extension_id'] ?? null));
        $stmt->bindValue(':date_of_birth', $data['date_of_birth'] ?? null);
        $stmt->bindValue(':gender', $data['gender'] ?? null);
        $stmt->bindValue(':civil_status', $data['civil_status'] ?? ($data['civil_status_id'] ?? null));
        $stmt->bindValue(':religion', $data['religion'] ?? ($data['religion_id'] ?? null));
        $stmt->bindValue(':mother_tongue', $data['mother_tongue'] ?? ($data['mother_tongue_id'] ?? null));
        $stmt->bindValue(':indigenous_group', $data['indigenous_group'] ?? ($data['indigenous_group_id'] ?? null));
        $stmt->bindValue(':citizenship', $data['citizenship'] ?? ($data['citizenship_id'] ?? null));
        $stmt->bindValue(':learner_status', $learnerStatus);
        $stmt->bindValue(':is_4ps_beneficiary', (int)($data['is_4ps_beneficiary'] ?? 0), PDO::PARAM_INT);
        $stmt->bindValue(':is_indigenous', (int)($data['is_indigenous'] ?? 0), PDO::PARAM_INT);
        $stmt->bindValue(':completed', (int)($data['completed'] ?? 0), PDO::PARAM_INT);
        $stmt->bindValue(':address', $data['address'] ?? null);
        $stmt->bindValue(':contact_number', $data['contact_number'] ?? null);
        $stmt->bindValue(':email', $data['email'] ?? null);
        $stmt->execute();

        $learnerId = (int)$conn->lastInsertId();

        $enroll = $conn->prepare('INSERT INTO enrollments (learner_id, school_year_id, grade_level_id, section_id, enrollment_date) VALUES (:learner_id, :school_year_id, :grade_level_id, :section_id, CURDATE())');
        $enroll->bindValue(':learner_id', $learnerId, PDO::PARAM_INT);
        $enroll->bindValue(':school_year_id', $schoolYearId, PDO::PARAM_INT);
        $enroll->bindValue(':grade_level_id', $data['grade_level_id'], PDO::PARAM_INT);
        $enroll->bindValue(':section_id', $data['section_id'], PDO::PARAM_INT);
        $enroll->execute();

        $conn->commit();

        audit_log($conn, 'learners', $learnerId, 'INSERT', null, [
            'learner_id' => $learnerId,
            'lrn' => $lrn,
            'first_name' => $data['first_name'],
            'last_name' => $data['last_name'],
        ]);

        respond([
            'success' => true,
            'message' => 'Learner created',
            'learner_id' => $learnerId,
            'learner_account' => [
                'created' => (bool)($account['created'] ?? false),
                'linked' => true,
                'username' => (string)($account['username'] ?? $lrn),
            ]
        ]);
    } catch (PDOException $e) {
        if ($conn && $conn->inTransaction()) {
            $conn->rollBack();
        }
        if ((string)$e->getCode() === '23000') {
            respond(['success' => false, 'message' => 'Duplicate record (LRN or username already exists).'], 409);
        }
        throw $e;
    }
}

function updateLearner(PDO $conn): void {
    $data = getJsonInput();
    $lrn = trim((string)($data['lrn'] ?? ''));
    if (empty($data['learner_id']) || $lrn === '' || empty($data['first_name']) || empty($data['last_name']) || empty($data['grade_level_id']) || empty($data['section_id'])) {
        respond(['success' => false, 'message' => 'Learner ID, LRN, name, grade level, and section are required'], 422);
    }

    // Allow updates on legacy records with non-12-digit LRNs as long as the LRN is not being changed.
    $currentStmt = $conn->prepare('SELECT lrn FROM learners WHERE learner_id = :learner_id AND is_deleted = 0 LIMIT 1');
    $currentStmt->bindValue(':learner_id', (int)$data['learner_id'], PDO::PARAM_INT);
    $currentStmt->execute();
    $currentLrn = $currentStmt->fetchColumn();
    if ($currentLrn === false || $currentLrn === null) {
        respond(['success' => false, 'message' => 'Learner not found'], 404);
    }
    $currentLrn = trim((string)$currentLrn);

    if ($lrn !== $currentLrn) {
        if (!preg_match('/^\d{12}$/', $lrn)) {
            respond(['success' => false, 'message' => 'LRN must be exactly 12 digits'], 422);
        }
        $dup = $conn->prepare('SELECT learner_id FROM learners WHERE lrn = :lrn AND is_deleted = 0 AND learner_id <> :learner_id LIMIT 1');
        $dup->bindValue(':lrn', $lrn);
        $dup->bindValue(':learner_id', (int)$data['learner_id'], PDO::PARAM_INT);
        $dup->execute();
        if ($dup->fetchColumn()) {
            respond(['success' => false, 'message' => 'LRN already exists.'], 409);
        }
    }

    $learnerStatus = !empty($data['learner_status_id']) ? (string)$data['learner_status_id'] : ($data['learner_status'] ?? null);
    $conn->beginTransaction();

    $stmt = $conn->prepare('UPDATE learners
                            SET lrn = :lrn,
                                first_name = :first_name,
                                middle_name = :middle_name,
                                last_name = :last_name,
                                name_extension = :name_extension,
                                date_of_birth = :date_of_birth,
                                gender = :gender,
                                civil_status = :civil_status,
                                religion = :religion,
                                mother_tongue = :mother_tongue,
                                indigenous_group = :indigenous_group,
                                citizenship = :citizenship,
                                learner_status = :learner_status,
                                is_4ps_beneficiary = :is_4ps_beneficiary,
                                is_indigenous = :is_indigenous,
                                completed = :completed,
                                address = :address,
                                contact_number = :contact_number,
                                email = :email
                            WHERE learner_id = :learner_id');
    $stmt->bindValue(':lrn', $lrn);
    $stmt->bindValue(':first_name', $data['first_name']);
    $stmt->bindValue(':middle_name', $data['middle_name'] ?? null);
    $stmt->bindValue(':last_name', $data['last_name']);
    $stmt->bindValue(':name_extension', $data['name_extension'] ?? ($data['name_extension_id'] ?? null));
    $stmt->bindValue(':date_of_birth', $data['date_of_birth'] ?? null);
    $stmt->bindValue(':gender', $data['gender'] ?? null);
    $stmt->bindValue(':civil_status', $data['civil_status'] ?? ($data['civil_status_id'] ?? null));
    $stmt->bindValue(':religion', $data['religion'] ?? ($data['religion_id'] ?? null));
    $stmt->bindValue(':mother_tongue', $data['mother_tongue'] ?? ($data['mother_tongue_id'] ?? null));
    $stmt->bindValue(':indigenous_group', $data['indigenous_group'] ?? ($data['indigenous_group_id'] ?? null));
    $stmt->bindValue(':citizenship', $data['citizenship'] ?? ($data['citizenship_id'] ?? null));
    $stmt->bindValue(':learner_status', $learnerStatus);
    $stmt->bindValue(':is_4ps_beneficiary', (int)($data['is_4ps_beneficiary'] ?? 0), PDO::PARAM_INT);
    $stmt->bindValue(':is_indigenous', (int)($data['is_indigenous'] ?? 0), PDO::PARAM_INT);
    $stmt->bindValue(':completed', (int)($data['completed'] ?? 0), PDO::PARAM_INT);
    $stmt->bindValue(':address', $data['address'] ?? null);
    $stmt->bindValue(':contact_number', $data['contact_number'] ?? null);
    $stmt->bindValue(':email', $data['email'] ?? null);
    $stmt->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
    $stmt->execute();

    $latest = getLatestEnrollment($conn, (int)$data['learner_id']);

    if ($latest) {
        $enroll = $conn->prepare('UPDATE enrollments SET grade_level_id = :grade_level_id, section_id = :section_id WHERE enrollment_id = :enrollment_id');
        $enroll->bindValue(':grade_level_id', $data['grade_level_id'], PDO::PARAM_INT);
        $enroll->bindValue(':section_id', $data['section_id'], PDO::PARAM_INT);
        $enroll->bindValue(':enrollment_id', $latest['enrollment_id'], PDO::PARAM_INT);
        $enroll->execute();
    } else {
        $schoolYearId = getActiveSchoolYearId($conn);
        if (!$schoolYearId) {
            $conn->rollBack();
            respond(['success' => false, 'message' => 'No active school year found'], 409);
        }
        $enroll = $conn->prepare('INSERT INTO enrollments (learner_id, school_year_id, grade_level_id, section_id, enrollment_date) VALUES (:learner_id, :school_year_id, :grade_level_id, :section_id, CURDATE())');
        $enroll->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
        $enroll->bindValue(':school_year_id', $schoolYearId, PDO::PARAM_INT);
        $enroll->bindValue(':grade_level_id', $data['grade_level_id'], PDO::PARAM_INT);
        $enroll->bindValue(':section_id', $data['section_id'], PDO::PARAM_INT);
        $enroll->execute();
    }

    $conn->commit();

    $oldRow = audit_fetch_old($conn, 'learners', 'learner_id', (int)$data['learner_id']);
    audit_log($conn, 'learners', (int)$data['learner_id'], 'UPDATE', $oldRow, [
        'learner_id' => (int)$data['learner_id'],
        'lrn' => $lrn,
        'first_name' => $data['first_name'],
        'last_name' => $data['last_name'],
    ]);

    respond(['success' => true, 'message' => 'Learner updated']);
}

function deleteLearner(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['learner_id'])) {
        respond(['success' => false, 'message' => 'Learner ID is required'], 422);
    }

    $conn->beginTransaction();

    $stmt = $conn->prepare('UPDATE learners SET is_deleted = 1, deleted_at = NOW() WHERE learner_id = :learner_id');
    $stmt->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
    $stmt->execute();

    $enroll = $conn->prepare('UPDATE enrollments SET is_deleted = 1, deleted_at = NOW() WHERE learner_id = :learner_id');
    $enroll->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
    $enroll->execute();

    $conn->commit();

    $oldRow = audit_fetch_old($conn, 'learners', 'learner_id', (int)$data['learner_id']);
    audit_log($conn, 'learners', (int)$data['learner_id'], 'DELETE', $oldRow, null);

    respond(['success' => true, 'message' => 'Learner deleted']);
}

function getActiveSchoolYearId(PDO $conn): ?int {
    $stmt = $conn->prepare('SELECT school_year_id FROM school_years WHERE is_active = 1 AND is_deleted = 0 ORDER BY year_start DESC LIMIT 1');
    $stmt->execute();
    $id = $stmt->fetchColumn();
    return $id ? (int)$id : null;
}

function getLatestEnrollment(PDO $conn, int $learnerId): ?array {
    $stmt = $conn->prepare('SELECT * FROM enrollments WHERE learner_id = :learner_id AND is_deleted = 0 ORDER BY enrollment_id DESC LIMIT 1');
    $stmt->bindValue(':learner_id', $learnerId, PDO::PARAM_INT);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}
?>
