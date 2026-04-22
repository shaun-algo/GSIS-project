<?php
header('Content-Type: application/json');

require_once __DIR__ . '/../utils/cors.php';


require_once __DIR__ . '/../database/connection.php';

require_once __DIR__ . '/../utils/auth.php';
require_once __DIR__ . '/../utils/notifications.php';

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

function ensureLearnerUserAccount(PDO $conn, int $learnerId): array {
    $stmt = $conn->prepare('SELECT learner_id, user_id, lrn FROM learners WHERE learner_id = :id AND is_deleted = 0 LIMIT 1');
    $stmt->bindValue(':id', $learnerId, PDO::PARAM_INT);
    $stmt->execute();
    $learner = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$learner) {
        if ($conn->inTransaction()) {
            $conn->rollBack();
        }
        respond(['success' => false, 'message' => 'Learner not found'], 404);
    }

    $existingUserId = isset($learner['user_id']) ? (int)($learner['user_id'] ?? 0) : 0;
    if ($existingUserId > 0) {
        return ['created' => false, 'linked' => true, 'user_id' => $existingUserId, 'username' => (string)($learner['lrn'] ?? '')];
    }

    $lrn = trim((string)($learner['lrn'] ?? ''));
    if ($lrn === '') {
        if ($conn->inTransaction()) {
            $conn->rollBack();
        }
        respond(['success' => false, 'message' => 'Learner LRN is missing; cannot create account'], 422);
    }

    $username = $lrn;

    // If a user already exists with this username (even if soft-deleted), link/restore it.
    $u = $conn->prepare('SELECT user_id, is_deleted FROM users WHERE username = :u LIMIT 1');
    $u->bindValue(':u', $username);
    $u->execute();
    $urow = $u->fetch(PDO::FETCH_ASSOC);
    $uid = $urow ? (int)($urow['user_id'] ?? 0) : 0;
    if ($uid > 0) {
        if (!empty($urow['is_deleted'])) {
            $roleId = getLearnerRoleId($conn);
            $restore = $conn->prepare('UPDATE users SET is_deleted = 0, deleted_at = NULL, is_active = 1, role_id = :role_id, password = :password WHERE user_id = :uid');
            $restore->bindValue(':role_id', $roleId, PDO::PARAM_INT);
            $restore->bindValue(':password', password_hash($lrn, PASSWORD_BCRYPT));
            $restore->bindValue(':uid', $uid, PDO::PARAM_INT);
            $restore->execute();
        }

        $chk = $conn->prepare('SELECT learner_id FROM learners WHERE user_id = :uid AND is_deleted = 0 LIMIT 1');
        $chk->bindValue(':uid', $uid, PDO::PARAM_INT);
        $chk->execute();
        $linkedLearnerId = (int)($chk->fetchColumn() ?: 0);
        if ($linkedLearnerId > 0 && $linkedLearnerId !== $learnerId) {
            if ($conn->inTransaction()) {
                $conn->rollBack();
            }
            respond(['success' => false, 'message' => 'An existing user with this LRN is already linked to another learner.'], 409);
        }

        $link = $conn->prepare('UPDATE learners SET user_id = :uid WHERE learner_id = :lid AND is_deleted = 0');
        $link->bindValue(':uid', $uid, PDO::PARAM_INT);
        $link->bindValue(':lid', $learnerId, PDO::PARAM_INT);
        $link->execute();
        return ['created' => false, 'linked' => true, 'user_id' => $uid, 'username' => $username];
    }

    // Create a new learner account.
    $roleId = getLearnerRoleId($conn);
    try {
        $ins = $conn->prepare('INSERT INTO users (username, password, role_id, is_active) VALUES (:username, :password, :role_id, 1)');
        $ins->bindValue(':username', $username);
        $ins->bindValue(':password', password_hash($lrn, PASSWORD_BCRYPT));
        $ins->bindValue(':role_id', $roleId, PDO::PARAM_INT);
        $ins->execute();
        $newUserId = (int)$conn->lastInsertId();
    } catch (PDOException $e) {
        // If username is taken (e.g., soft-deleted row exists), recover by selecting and restoring.
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
                $newUserId = $existingId;
            } else {
                throw $e;
            }
        } else {
            throw $e;
        }
    }

    $link = $conn->prepare('UPDATE learners SET user_id = :uid WHERE learner_id = :lid AND is_deleted = 0');
    $link->bindValue(':uid', $newUserId, PDO::PARAM_INT);
    $link->bindValue(':lid', $learnerId, PDO::PARAM_INT);
    $link->execute();

    return ['created' => true, 'linked' => true, 'user_id' => $newUserId, 'username' => $username];
}

function respond($payload, int $code = 200): void {
    http_response_code($code);
    echo json_encode($payload);
    exit;
}

function getJsonInput(): array {
    $raw = file_get_contents('php://input');
    return $raw ? (json_decode($raw, true) ?: []) : [];
}

function getPrimaryCurriculumIdForSchoolYear(PDO $conn, int $schoolYearId): ?int {
    if ($schoolYearId <= 0) return null;
    $stmt = $conn->prepare(
        'SELECT curriculum_id
         FROM curriculum_school_year_map
         WHERE school_year_id = :sid
           AND is_deleted = 0
           AND is_primary = 1
         ORDER BY map_id DESC
         LIMIT 1'
    );
    $stmt->bindValue(':sid', $schoolYearId, PDO::PARAM_INT);
    $stmt->execute();
    $val = $stmt->fetchColumn();
    return $val ? (int)$val : null;
}

function getAnyMappedCurriculumIdForSchoolYear(PDO $conn, int $schoolYearId): ?int {
        if ($schoolYearId <= 0) return null;
        $stmt = $conn->prepare(
                'SELECT c.curriculum_id
                 FROM curriculum_school_year_map m
                 JOIN curricula c ON c.curriculum_id = m.curriculum_id
                 WHERE m.school_year_id = :sid
                     AND m.is_deleted = 0
                     AND c.is_deleted = 0
                 ORDER BY c.is_active DESC, c.effective_from DESC, c.curriculum_id DESC
                 LIMIT 1'
        );
        $stmt->bindValue(':sid', $schoolYearId, PDO::PARAM_INT);
        $stmt->execute();
        $val = $stmt->fetchColumn();
        return $val ? (int)$val : null;
}

function isCurriculumMappedToSchoolYear(PDO $conn, int $curriculumId, int $schoolYearId): bool {
    $stmt = $conn->prepare(
        'SELECT 1
         FROM curriculum_school_year_map
         WHERE curriculum_id = :cid
           AND school_year_id = :sid
           AND is_deleted = 0
         LIMIT 1'
    );
    $stmt->bindValue(':cid', $curriculumId, PDO::PARAM_INT);
    $stmt->bindValue(':sid', $schoolYearId, PDO::PARAM_INT);
    $stmt->execute();
    return (bool)$stmt->fetchColumn();
}

function curriculumHasGradeLevelsConfigured(PDO $conn, int $curriculumId): bool {
    $stmt = $conn->prepare('SELECT COUNT(*) FROM curriculum_grade_levels WHERE curriculum_id = :cid AND is_deleted = 0');
    $stmt->bindValue(':cid', $curriculumId, PDO::PARAM_INT);
    $stmt->execute();
    return ((int)$stmt->fetchColumn()) > 0;
}

function curriculumCoversGradeLevel(PDO $conn, int $curriculumId, int $gradeLevelId): bool {
    $stmt = $conn->prepare(
        'SELECT 1
         FROM curriculum_grade_levels
         WHERE curriculum_id = :cid
           AND grade_level_id = :gid
           AND is_deleted = 0
         LIMIT 1'
    );
    $stmt->bindValue(':cid', $curriculumId, PDO::PARAM_INT);
    $stmt->bindValue(':gid', $gradeLevelId, PDO::PARAM_INT);
    $stmt->execute();
    return (bool)$stmt->fetchColumn();
}

function resolveAndValidateCurriculum(PDO $conn, ?int $curriculumId, int $schoolYearId, int $gradeLevelId): ?int {
    if ($curriculumId === null) {
        $curriculumId = getPrimaryCurriculumIdForSchoolYear($conn, $schoolYearId)
            ?? getAnyMappedCurriculumIdForSchoolYear($conn, $schoolYearId);
    }
    if ($curriculumId === null) {
        return null;
    }

    if (!isCurriculumMappedToSchoolYear($conn, $curriculumId, $schoolYearId)) {
        respond([
            'success' => false,
            'message' => 'Selected curriculum is not mapped to the selected school year. Configure mapping in Curriculum Components.'
        ], 422);
    }

    if ($gradeLevelId > 0 && curriculumHasGradeLevelsConfigured($conn, $curriculumId)) {
        if (!curriculumCoversGradeLevel($conn, $curriculumId, $gradeLevelId)) {
            respond([
                'success' => false,
                'message' => 'Selected curriculum does not cover the selected grade level.'
            ], 422);
        }
    }

    return $curriculumId;
}

function validateSectionConsistency(PDO $conn, int $sectionId, int $schoolYearId, int $gradeLevelId): void {
    $stmt = $conn->prepare('SELECT section_id, school_year_id, grade_level_id FROM sections WHERE section_id = :section_id AND is_deleted = 0 LIMIT 1');
    $stmt->bindValue(':section_id', $sectionId, PDO::PARAM_INT);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$row) {
        respond(['success' => false, 'message' => 'Selected section not found'], 422);
    }
    if ((int)$row['school_year_id'] !== (int)$schoolYearId) {
        respond(['success' => false, 'message' => 'Selected section does not belong to the selected school year'], 422);
    }
    if ((int)$row['grade_level_id'] !== (int)$gradeLevelId) {
        respond(['success' => false, 'message' => 'Selected section does not match the selected grade level'], 422);
    }
}

$operation = $_GET['operation'] ?? '';
$readRoles = ['admin'];
$writeRoles = ['admin'];

if ($operation === 'getAllEnrollments' || $operation === 'createEnrollment') {
    $readRoles[] = 'registrar';
}
if ($operation === 'createEnrollment') {
    $writeRoles[] = 'registrar';
}

$session = auth_enforce_roles($operation, $readRoles, $writeRoles);
try {
    switch ($operation) {
        case 'getAllEnrollments': getAllEnrollments($conn); break;
        case 'createEnrollment': createEnrollment($conn); break;
        case 'updateEnrollment': updateEnrollment($conn); break;
        case 'deleteEnrollment': deleteEnrollment($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllEnrollments(PDO $conn): void {
    $sql = "SELECT e.enrollment_id, e.enrollment_date, e.enrollment_type_id, et.type_name,
                   e.enrollment_status, e.status_updated_at,
                   e.grade_level_id, gl.grade_name, e.section_id, sec.section_name,
                   e.school_year_id, sy.year_label, sy.year_start, sy.year_end,
                   e.curriculum_id, cur.curriculum_name, cur.curriculum_code,
                   e.learner_id, CONCAT(l.last_name, ', ', l.first_name) AS learner_name
            FROM enrollments e
            JOIN learners l ON e.learner_id = l.learner_id
            LEFT JOIN enrollment_types et ON e.enrollment_type_id = et.enrollment_type_id
            LEFT JOIN grade_levels gl ON e.grade_level_id = gl.grade_level_id
            LEFT JOIN sections sec ON e.section_id = sec.section_id
            LEFT JOIN school_years sy ON e.school_year_id = sy.school_year_id
            LEFT JOIN curricula cur ON e.curriculum_id = cur.curriculum_id
            WHERE e.is_deleted = 0
            ORDER BY e.enrollment_id DESC";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function createEnrollment(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['learner_id']) || empty($data['school_year_id']) || empty($data['grade_level_id']) || empty($data['section_id'])) {
        respond(['success' => false, 'message' => 'Learner, school year, grade level, and section are required'], 422);
    }

    $schoolYearId = (int)$data['school_year_id'];
    $gradeLevelId = (int)$data['grade_level_id'];
    $sectionId = (int)$data['section_id'];

    validateSectionConsistency($conn, $sectionId, $schoolYearId, $gradeLevelId);

    $resolvedCurriculumId = resolveAndValidateCurriculum(
        $conn,
        isset($data['curriculum_id']) && $data['curriculum_id'] !== '' ? (int)$data['curriculum_id'] : null,
        $schoolYearId,
        $gradeLevelId
    );

    // Default to today's date (server time) when not provided.
    $enrollmentDate = !empty($data['enrollment_date']) ? $data['enrollment_date'] : date('Y-m-d');

    $enrollmentStatus = !empty($data['enrollment_status']) ? $data['enrollment_status'] : 'Enrolled';

    $enrollmentId = 0;
    $account = null;

    try {
        $conn->beginTransaction();

        // promotion_status was removed from the schema; tolerate legacy payloads by ignoring it.
        $stmt = $conn->prepare('INSERT INTO enrollments (learner_id, school_year_id, grade_level_id, section_id, enrollment_type_id, curriculum_id, enrollment_date, enrollment_status) VALUES (:learner_id, :school_year_id, :grade_level_id, :section_id, :enrollment_type_id, :curriculum_id, :enrollment_date, :enrollment_status)');
        $stmt->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
        $stmt->bindValue(':school_year_id', $schoolYearId, PDO::PARAM_INT);
        $stmt->bindValue(':grade_level_id', $gradeLevelId, PDO::PARAM_INT);
        $stmt->bindValue(':section_id', $sectionId, PDO::PARAM_INT);
        $stmt->bindValue(
            ':enrollment_type_id',
            $data['enrollment_type_id'] ?? null,
            empty($data['enrollment_type_id']) ? PDO::PARAM_NULL : PDO::PARAM_INT
        );
        $stmt->bindValue(':curriculum_id', $resolvedCurriculumId, $resolvedCurriculumId === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
        $stmt->bindValue(':enrollment_date', $enrollmentDate);
        $stmt->bindValue(':enrollment_status', $enrollmentStatus);
        $stmt->execute();
        $enrollmentId = (int)$conn->lastInsertId();

        // Auto-create/link learner login account.
        $account = ensureLearnerUserAccount($conn, (int)$data['learner_id']);

        $conn->commit();
    } catch (PDOException $e) {
        if ($conn && $conn->inTransaction()) {
            $conn->rollBack();
        }
        if ((string)$e->getCode() === '23000') {
            respond(['success' => false, 'message' => 'Duplicate record (username/LRN conflict).'], 409);
        }
        // Triggers use SIGNAL SQLSTATE '45000'
        if ((string)$e->getCode() === '45000') {
            respond(['success' => false, 'message' => $e->getMessage()], 409);
        }
        throw $e;
    } catch (Exception $e) {
        if ($conn && $conn->inTransaction()) {
            $conn->rollBack();
        }
        throw $e;
    }

    // Create in-app notifications for admin + teacher.
    try {
        $infoStmt = $conn->prepare(
            "SELECT CONCAT(l.last_name, ', ', l.first_name) AS learner_name,
                    sy.year_label,
                    gl.grade_name,
                    sec.section_name
             FROM enrollments e
             JOIN learners l ON e.learner_id = l.learner_id
             LEFT JOIN school_years sy ON e.school_year_id = sy.school_year_id
             LEFT JOIN grade_levels gl ON e.grade_level_id = gl.grade_level_id
             LEFT JOIN sections sec ON e.section_id = sec.section_id
             WHERE e.enrollment_id = :id"
        );
        $infoStmt->bindValue(':id', $enrollmentId, PDO::PARAM_INT);
        $infoStmt->execute();
        $info = $infoStmt->fetch(PDO::FETCH_ASSOC) ?: [];

        $learnerName = (string)($info['learner_name'] ?? '');
        $yearLabel = (string)($info['year_label'] ?? '');
        $gradeName = (string)($info['grade_name'] ?? '');
        $sectionName = (string)($info['section_name'] ?? '');

        $title = 'New Enrollment';
        $parts = array_values(array_filter([
            $learnerName !== '' ? "Learner: {$learnerName}" : null,
            $yearLabel !== '' ? "S.Y.: {$yearLabel}" : null,
            $gradeName !== '' ? "Grade: {$gradeName}" : null,
            $sectionName !== '' ? "Section: {$sectionName}" : null,
        ]));
        $message = count($parts) ? implode(' • ', $parts) : 'A new enrollment was created.';

        // If we created an account, append a short note for staff.
        if (is_array($account) && !empty($account['created']) && !empty($account['username'])) {
            $message .= ' • Learner login created (username: ' . (string)$account['username'] . ')';
        }

        $adminRoleId = notifications_get_role_id($conn, 'admin');
        $teacherRoleId = notifications_get_role_id($conn, 'teacher');
        if ($adminRoleId !== null) {
            notifications_create_for_role($conn, (int)$adminRoleId, 'Announcement', $title, $message, 'enrollments', $enrollmentId);
        }
        if ($teacherRoleId !== null) {
            notifications_create_for_role($conn, (int)$teacherRoleId, 'Announcement', $title, $message, 'enrollments', $enrollmentId);
        }
    } catch (Exception $e) {
        // Never block enrollment creation if notifications fail.
    }

    respond([
        'success' => true,
        'message' => 'Enrollment created',
        'enrollment_id' => $enrollmentId,
        'learner_account' => [
            'created' => (bool)($account['created'] ?? false),
            'linked' => (bool)($account['linked'] ?? false),
            'username' => (string)($account['username'] ?? ''),
        ]
    ]);
}

function updateEnrollment(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['enrollment_id']) || empty($data['learner_id']) || empty($data['school_year_id']) || empty($data['grade_level_id']) || empty($data['section_id'])) {
        respond(['success' => false, 'message' => 'Enrollment ID, learner, school year, grade level, and section are required'], 422);
    }

    $schoolYearId = (int)$data['school_year_id'];
    $gradeLevelId = (int)$data['grade_level_id'];
    $sectionId = (int)$data['section_id'];

    validateSectionConsistency($conn, $sectionId, $schoolYearId, $gradeLevelId);

    $resolvedCurriculumId = resolveAndValidateCurriculum(
        $conn,
        isset($data['curriculum_id']) && $data['curriculum_id'] !== '' ? (int)$data['curriculum_id'] : null,
        $schoolYearId,
        $gradeLevelId
    );

    // If enrollment_date is omitted/blank, keep existing enrollment_date.
    $enrollmentStatusIsSet = array_key_exists('enrollment_status', $data) ? 1 : 0;

    $enrollmentStatus = $enrollmentStatusIsSet === 1 ? ($data['enrollment_status'] ?? '') : '';
    // promotion_status was removed from the schema; tolerate legacy payloads by ignoring it.

    $setParts = [
        'learner_id = :learner_id',
        'school_year_id = :school_year_id',
        'grade_level_id = :grade_level_id',
        'section_id = :section_id',
        'enrollment_type_id = :enrollment_type_id',
        'curriculum_id = :curriculum_id',
        'enrollment_date = COALESCE(NULLIF(:enrollment_date, ""), enrollment_date)'
    ];

    if ($enrollmentStatusIsSet === 1) {
        $setParts[] = 'enrollment_status = COALESCE(NULLIF(:enrollment_status, ""), enrollment_status)';
        $setParts[] = 'status_updated_at = CURRENT_TIMESTAMP()';
    }

    $sql = 'UPDATE enrollments SET ' . implode(', ', $setParts) . ' WHERE enrollment_id = :enrollment_id';

    $stmt = $conn->prepare($sql);
    try {
        $stmt->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
        $stmt->bindValue(':school_year_id', $schoolYearId, PDO::PARAM_INT);
        $stmt->bindValue(':grade_level_id', $gradeLevelId, PDO::PARAM_INT);
        $stmt->bindValue(':section_id', $sectionId, PDO::PARAM_INT);
        $stmt->bindValue(
            ':enrollment_type_id',
            $data['enrollment_type_id'] ?? null,
            empty($data['enrollment_type_id']) ? PDO::PARAM_NULL : PDO::PARAM_INT
        );
        $stmt->bindValue(':curriculum_id', $resolvedCurriculumId, $resolvedCurriculumId === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
        $stmt->bindValue(':enrollment_date', !empty($data['enrollment_date']) ? $data['enrollment_date'] : '');
        if ($enrollmentStatusIsSet === 1) {
            $stmt->bindValue(':enrollment_status', $enrollmentStatus);
        }
        $stmt->bindValue(':enrollment_id', $data['enrollment_id'], PDO::PARAM_INT);
        $stmt->execute();
        respond(['success' => true, 'message' => 'Enrollment updated']);
    } catch (PDOException $e) {
        if ((string)$e->getCode() === '45000') {
            respond(['success' => false, 'message' => $e->getMessage()], 409);
        }
        throw $e;
    }
}

function deleteEnrollment(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['enrollment_id'])) {
        respond(['success' => false, 'message' => 'Enrollment ID is required'], 422);
    }
    $stmt = $conn->prepare('UPDATE enrollments SET is_deleted = 1, deleted_at = NOW() WHERE enrollment_id = :enrollment_id');
    $stmt->bindValue(':enrollment_id', $data['enrollment_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Enrollment deleted']);
}
?>
