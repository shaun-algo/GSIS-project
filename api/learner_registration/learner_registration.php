<?php
header('Content-Type: application/json');

// Align with other endpoints for smoother browser/XHR behavior.
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/../utils/cors.php';

if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
    exit(0);
}


require_once __DIR__ . '/../database/connection.php';

require_once __DIR__ . '/../utils/auth.php';

function log_validation_failure(int $code, $payload): void {
    if ($code !== 422) {
        return;
    }

    try {
        $method = $_SERVER['REQUEST_METHOD'] ?? '';
        $operation = $_GET['operation'] ?? '';
        $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
        $uri = $_SERVER['REQUEST_URI'] ?? '';

        // NOTE: php://input can be consumed; rely on captured JSON input.
        $body = $GLOBALS['LR_LAST_JSON_INPUT'] ?? null;

        // Avoid logging PII-heavy payloads: keep only keys + a few known IDs.
        $bodySummary = null;
        if (is_array($body)) {
            $bodySummary = [
                'keys' => array_values(array_slice(array_keys($body), 0, 40)),
                'learner_id' => $body['learner_id'] ?? null,
                'school_year_id' => $body['school_year_id'] ?? null,
                'grade_level_id' => $body['grade_level_id'] ?? null,
                'section_id' => $body['section_id'] ?? null,
                'curriculum_id' => $body['curriculum_id'] ?? null,
                'user_id' => $body['user_id'] ?? null,
            ];
        }

        $msg = is_array($payload) ? ($payload['message'] ?? '') : '';
        $fieldErrors = is_array($payload) ? ($payload['field_errors'] ?? null) : null;

        error_log('[learner_registration] 422 validation failed: ' . json_encode([
            'method' => $method,
            'operation' => $operation,
            'uri' => $uri,
            'origin' => $origin,
            'query' => $_GET,
            'message' => $msg,
            'field_errors' => $fieldErrors,
            'body' => $bodySummary,
        ]));
    } catch (Throwable $e) {
        // Never break responses due to logging.
    }
}

function respond($payload, int $code = 200): void {
    http_response_code($code);
    if (is_array($payload) && $code === 422) {
        if (!isset($payload['operation'])) {
            $payload['operation'] = $_GET['operation'] ?? '';
        }
        if (!isset($payload['success'])) {
            $payload['success'] = false;
        }

        if (!isset($payload['debug'])) {
            $body = $GLOBALS['LR_LAST_JSON_INPUT'] ?? [];
            $body = is_array($body) ? $body : [];
            $payload['debug'] = [
                'method' => $_SERVER['REQUEST_METHOD'] ?? '',
                'uri' => $_SERVER['REQUEST_URI'] ?? '',
                'origin' => $_SERVER['HTTP_ORIGIN'] ?? '',
                'received' => [
                    'keys' => array_values(array_slice(array_keys($body), 0, 60)),
                    'learner_id' => $body['learner_id'] ?? null,
                    'school_year_id' => $body['school_year_id'] ?? null,
                    'grade_level_id' => $body['grade_level_id'] ?? null,
                    'section_id' => $body['section_id'] ?? null,
                    'curriculum_id' => $body['curriculum_id'] ?? null,
                    'user_id' => $body['user_id'] ?? null,
                ]
            ];
        }
    }

    log_validation_failure($code, $payload);
    echo json_encode($payload);
    exit;
}

function getJsonInput(): array {
    $raw = file_get_contents('php://input');
    $data = $raw ? (json_decode($raw, true) ?: []) : [];
    $GLOBALS['LR_LAST_JSON_INPUT'] = is_array($data) ? $data : [];
    return $GLOBALS['LR_LAST_JSON_INPUT'];
}

function nullIfEmpty($value) {
    if ($value === null) {
        return null;
    }
    if (is_string($value)) {
        $trimmed = trim($value);
        return $trimmed === '' ? null : $trimmed;
    }
    return $value;
}

function intOrNull($value): ?int {
    if ($value === null || $value === '') {
        return null;
    }
    $num = (int)$value;
    return $num > 0 ? $num : null;
}

function bindNullable(PDOStatement $stmt, string $param, $value, int $type = PDO::PARAM_STR): void {
    if ($value === null) {
        $stmt->bindValue($param, null, PDO::PARAM_NULL);
        return;
    }
    $stmt->bindValue($param, $value, $type);
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
        respond(['success' => false, 'message' => 'LRN is required'], 422);
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
    // Default to primary curriculum if curriculum was not provided.
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

    // If grade levels are configured for this curriculum, enforce that the selected grade level is included.
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

$operation = $_GET['operation'] ?? '';

// If a browser hits this endpoint directly via GET without an operation,
// default to the list operation (prevents confusing client-side failures).
if ($operation === '' && (($_SERVER['REQUEST_METHOD'] ?? '') === 'GET')) {
    $operation = 'getAllRegistrations';
}

$teacherReadOps = [
    'getAllRegistrations',
    'getRegistrationList',
    'getRegistrationById'
];

// Teachers and registrar may view learner records; admin required for any write operation.
$allowedRoles = in_array($operation, $teacherReadOps, true) ? ['admin', 'teacher', 'registrar'] : ['admin'];
$session = auth_enforce_roles($operation, $allowedRoles, $allowedRoles);

try {
    switch ($operation) {
        case 'getAllRegistrations': getAllRegistrations($conn); break;
        case 'getRegistrationList': getRegistrationList($conn); break;
        case 'getRegistrationById': getRegistrationById($conn); break;
        case 'createRegistration': createRegistration($conn); break;
        case 'updateRegistration': updateRegistration($conn); break;
        case 'markEntryCompleted': markEntryCompleted($conn); break;
        case 'deleteRegistration': deleteRegistration($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getRegistrationList(PDO $conn): void {
    // Fast list used for dropdowns/tables (avoids expensive per-row subqueries)
    $sql = "SELECT l.learner_id, l.lrn, l.first_name, l.middle_name, l.last_name,
                   l.gender, l.date_of_birth, l.contact_number, l.completed,
                   l.learner_status AS status_name,
                   e.enrollment_id, e.enrollment_date,
                   e.curriculum_id, cur.curriculum_name, cur.curriculum_code,
                   e.grade_level_id, gl.grade_name,
                   e.section_id, sec.section_name,
                   e.school_year_id, sy.year_label,
                   CASE
                       WHEN EXISTS (
                           SELECT 1 FROM learner_documents
                           WHERE learner_id = l.learner_id AND document_type_id = 1 AND is_deleted = 0
                       ) THEN 'Completed'
                       ELSE 'Pending'
                   END AS entry_completion_status
            FROM learners l
            LEFT JOIN enrollments e ON e.enrollment_id = (
                SELECT e2.enrollment_id
                FROM enrollments e2
                WHERE e2.learner_id = l.learner_id AND e2.is_deleted = 0
                ORDER BY e2.enrollment_date DESC, e2.enrollment_id DESC
                LIMIT 1
            )
            LEFT JOIN grade_levels gl ON gl.grade_level_id = e.grade_level_id
            LEFT JOIN sections sec ON sec.section_id = e.section_id
            LEFT JOIN school_years sy ON sy.school_year_id = e.school_year_id
            LEFT JOIN curricula cur ON cur.curriculum_id = e.curriculum_id
            WHERE l.is_deleted = 0
            ORDER BY l.last_name, l.first_name";

    $stmt = $conn->prepare($sql);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function getRegistrationById(PDO $conn): void {
    $learnerId = (int)($_GET['learner_id'] ?? 0);
    if ($learnerId <= 0) {
        respond(['success' => false, 'message' => 'learner_id is required'], 422);
    }

    $sql = "SELECT l.learner_id, l.user_id, l.lrn, l.first_name, l.middle_name, l.last_name,
                   l.name_extension AS name_extension_id, l.date_of_birth, l.gender, l.address, l.contact_number,
                   l.email,
                   l.learner_status AS learner_status_id,
                   l.religion AS religion_id,
                   l.civil_status AS civil_status_id,
                   l.mother_tongue AS mother_tongue_id,
                   l.indigenous_group AS indigenous_group_id,
                   l.citizenship,
                   l.is_4ps_beneficiary, l.is_indigenous,
                   l.completed, l.is_permanent_same_as_current, l.is_deleted, l.deleted_at,
                   l.learner_status AS status_name,
                   e.enrollment_id, e.enrollment_date, e.enrollment_type_id,
                   e.curriculum_id, cur.curriculum_name, cur.curriculum_code,
                   e.grade_level_id, gl.grade_name,
                   e.section_id, sec.section_name,
                   e.school_year_id, sy.year_label,
                   et.type_name,
                   CASE
                       WHEN l.learner_id IN (SELECT learner_id FROM learner_documents WHERE document_type_id = 1 AND is_deleted = 0)
                       THEN 'Completed'
                       ELSE 'Pending'
                   END AS entry_completion_status,
                   (SELECT COUNT(*) FROM learner_documents WHERE learner_id = l.learner_id AND is_deleted = 0) AS documents_submitted,
                   (SELECT COUNT(*) FROM enrollment_requirements WHERE school_year_id = e.school_year_id AND is_mandatory = 1) AS required_documents,
                   (SELECT full_name FROM family_members WHERE learner_id = l.learner_id AND relationship = 'Father' AND is_deleted = 0 LIMIT 1) AS father_name,
                   (SELECT occupation FROM family_members WHERE learner_id = l.learner_id AND relationship = 'Father' AND is_deleted = 0 LIMIT 1) AS father_occupation,
                   (SELECT contact_number FROM family_members WHERE learner_id = l.learner_id AND relationship = 'Father' AND is_deleted = 0 LIMIT 1) AS father_contact,
                   (SELECT full_name FROM family_members WHERE learner_id = l.learner_id AND relationship = 'Mother' AND is_deleted = 0 LIMIT 1) AS mother_name,
                   (SELECT occupation FROM family_members WHERE learner_id = l.learner_id AND relationship = 'Mother' AND is_deleted = 0 LIMIT 1) AS mother_occupation,
                   (SELECT contact_number FROM family_members WHERE learner_id = l.learner_id AND relationship = 'Mother' AND is_deleted = 0 LIMIT 1) AS mother_contact,
                   (SELECT full_name FROM family_members WHERE learner_id = l.learner_id AND relationship = 'Spouse' AND is_deleted = 0 LIMIT 1) AS spouse_name,
                   (SELECT occupation FROM family_members WHERE learner_id = l.learner_id AND relationship = 'Spouse' AND is_deleted = 0 LIMIT 1) AS spouse_occupation,
                   (SELECT full_name FROM family_members WHERE learner_id = l.learner_id AND relationship = 'Legal Guardian' AND is_deleted = 0 LIMIT 1) AS guardian_name,
                   (SELECT contact_number FROM family_members WHERE learner_id = l.learner_id AND relationship = 'Legal Guardian' AND is_deleted = 0 LIMIT 1) AS guardian_contact,
                   (SELECT contact_name FROM emergency_contacts WHERE learner_id = l.learner_id AND is_deleted = 0 LIMIT 1) AS emergency_person_name,
                   (SELECT contact_number FROM emergency_contacts WHERE learner_id = l.learner_id AND is_deleted = 0 LIMIT 1) AS emergency_mobile,
                   (SELECT address FROM emergency_contacts WHERE learner_id = l.learner_id AND is_deleted = 0 LIMIT 1) AS emergency_address,
                   (SELECT last_grade_level_completed FROM learner_previous_schools WHERE enrollment_id = e.enrollment_id AND is_deleted = 0 ORDER BY previous_school_id DESC LIMIT 1) AS last_grade_level_completed,
                   (SELECT last_school_year_completed FROM learner_previous_schools WHERE enrollment_id = e.enrollment_id AND is_deleted = 0 ORDER BY previous_school_id DESC LIMIT 1) AS last_school_year_completed,
                   (SELECT last_school_attended FROM learner_previous_schools WHERE enrollment_id = e.enrollment_id AND is_deleted = 0 ORDER BY previous_school_id DESC LIMIT 1) AS last_school_attended,
                   (SELECT last_school_id FROM learner_previous_schools WHERE enrollment_id = e.enrollment_id AND is_deleted = 0 ORDER BY previous_school_id DESC LIMIT 1) AS last_school_id,

                   lac.house_no AS current_house_no,
                   lac.street_name AS current_street,
                   lac.street_name AS current_street_name,
                   lac.subdivision AS current_subdivision,
                   lac.zip_code AS current_zip_code,
                   lac.province_id AS current_province_id,
                   lac.city_municipality_id AS current_city_municipality_id,
                   lac.barangay_id AS current_barangay_id,
                   lac.country_name AS current_country_name,

                     lap.house_no AS permanent_house_no,
                     lap.street_name AS permanent_street,
                     lap.street_name AS permanent_street_name,
                   lap.subdivision AS permanent_subdivision,
                   lap.zip_code AS permanent_zip_code,
                   lap.province_id AS permanent_province_id,
                   lap.city_municipality_id AS permanent_city_municipality_id,
                   lap.barangay_id AS permanent_barangay_id,
                   lap.country_name AS permanent_country_name
            FROM learners l
            LEFT JOIN learner_addresses lac ON lac.learner_address_id = (
                SELECT la2.learner_address_id
                FROM learner_addresses la2
                WHERE la2.learner_id = l.learner_id AND la2.address_type = 'CURRENT' AND la2.is_deleted = 0
                ORDER BY la2.learner_address_id DESC
                LIMIT 1
            )
            LEFT JOIN learner_addresses lap ON lap.learner_address_id = (
                SELECT la3.learner_address_id
                FROM learner_addresses la3
                WHERE la3.learner_id = l.learner_id AND la3.address_type = 'PERMANENT' AND la3.is_deleted = 0
                ORDER BY la3.learner_address_id DESC
                LIMIT 1
            )
            LEFT JOIN enrollments e ON e.enrollment_id = (
                SELECT e2.enrollment_id
                FROM enrollments e2
                WHERE e2.learner_id = l.learner_id AND e2.is_deleted = 0
                ORDER BY e2.enrollment_date DESC, e2.enrollment_id DESC
                LIMIT 1
            )
            LEFT JOIN enrollment_types et ON et.enrollment_type_id = e.enrollment_type_id
            LEFT JOIN grade_levels gl ON gl.grade_level_id = e.grade_level_id
            LEFT JOIN sections sec ON sec.section_id = e.section_id
            LEFT JOIN school_years sy ON sy.school_year_id = e.school_year_id
            LEFT JOIN curricula cur ON cur.curriculum_id = e.curriculum_id
            WHERE l.is_deleted = 0 AND l.learner_id = :learner_id
            LIMIT 1";

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':learner_id', $learnerId, PDO::PARAM_INT);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$row) {
        respond(['success' => false, 'message' => 'Learner not found'], 404);
    }
    respond($row);
}

function getAllRegistrations(PDO $conn): void {
    $sql = "SELECT l.learner_id, l.user_id, l.lrn, l.first_name, l.middle_name, l.last_name,
                   l.name_extension AS name_extension_id, l.date_of_birth, l.gender, l.address, l.contact_number,
                   l.email,
                   l.learner_status AS learner_status_id,
                   l.religion AS religion_id,
                   l.civil_status AS civil_status_id,
                   l.mother_tongue AS mother_tongue_id,
                   l.indigenous_group AS indigenous_group_id,
                   l.citizenship,
                   l.is_4ps_beneficiary, l.is_indigenous,
                   l.completed, l.is_permanent_same_as_current, l.is_deleted, l.deleted_at,
                   l.learner_status AS status_name,
                   e.enrollment_id, e.enrollment_date, e.enrollment_type_id,
                   e.curriculum_id, cur.curriculum_name, cur.curriculum_code,
                   e.grade_level_id, gl.grade_name,
                   e.section_id, sec.section_name,
                   e.school_year_id, sy.year_label,
                   et.type_name,
                   CASE
                       WHEN l.learner_id IN (SELECT learner_id FROM learner_documents WHERE document_type_id = 1 AND is_deleted = 0)
                       THEN 'Completed'
                       ELSE 'Pending'
                   END AS entry_completion_status,
                   (SELECT COUNT(*) FROM learner_documents WHERE learner_id = l.learner_id AND is_deleted = 0) AS documents_submitted,
                   (SELECT COUNT(*) FROM enrollment_requirements WHERE school_year_id = e.school_year_id AND is_mandatory = 1) AS required_documents,
                   (SELECT full_name FROM family_members WHERE learner_id = l.learner_id AND relationship = 'Father' AND is_deleted = 0 LIMIT 1) AS father_name,
                   (SELECT occupation FROM family_members WHERE learner_id = l.learner_id AND relationship = 'Father' AND is_deleted = 0 LIMIT 1) AS father_occupation,
                   (SELECT contact_number FROM family_members WHERE learner_id = l.learner_id AND relationship = 'Father' AND is_deleted = 0 LIMIT 1) AS father_contact,
                   (SELECT full_name FROM family_members WHERE learner_id = l.learner_id AND relationship = 'Mother' AND is_deleted = 0 LIMIT 1) AS mother_name,
                   (SELECT occupation FROM family_members WHERE learner_id = l.learner_id AND relationship = 'Mother' AND is_deleted = 0 LIMIT 1) AS mother_occupation,
                   (SELECT contact_number FROM family_members WHERE learner_id = l.learner_id AND relationship = 'Mother' AND is_deleted = 0 LIMIT 1) AS mother_contact,
                   (SELECT full_name FROM family_members WHERE learner_id = l.learner_id AND relationship = 'Spouse' AND is_deleted = 0 LIMIT 1) AS spouse_name,
                   (SELECT occupation FROM family_members WHERE learner_id = l.learner_id AND relationship = 'Spouse' AND is_deleted = 0 LIMIT 1) AS spouse_occupation,
                   (SELECT full_name FROM family_members WHERE learner_id = l.learner_id AND relationship = 'Legal Guardian' AND is_deleted = 0 LIMIT 1) AS guardian_name,
                   (SELECT contact_number FROM family_members WHERE learner_id = l.learner_id AND relationship = 'Legal Guardian' AND is_deleted = 0 LIMIT 1) AS guardian_contact,
                   (SELECT contact_name FROM emergency_contacts WHERE learner_id = l.learner_id AND is_deleted = 0 LIMIT 1) AS emergency_person_name,
                   (SELECT contact_number FROM emergency_contacts WHERE learner_id = l.learner_id AND is_deleted = 0 LIMIT 1) AS emergency_mobile,
                   (SELECT address FROM emergency_contacts WHERE learner_id = l.learner_id AND is_deleted = 0 LIMIT 1) AS emergency_address,
                   (SELECT last_grade_level_completed FROM learner_previous_schools WHERE enrollment_id = e.enrollment_id AND is_deleted = 0 ORDER BY previous_school_id DESC LIMIT 1) AS last_grade_level_completed,
                   (SELECT last_school_year_completed FROM learner_previous_schools WHERE enrollment_id = e.enrollment_id AND is_deleted = 0 ORDER BY previous_school_id DESC LIMIT 1) AS last_school_year_completed,
                   (SELECT last_school_attended FROM learner_previous_schools WHERE enrollment_id = e.enrollment_id AND is_deleted = 0 ORDER BY previous_school_id DESC LIMIT 1) AS last_school_attended,
                   (SELECT last_school_id FROM learner_previous_schools WHERE enrollment_id = e.enrollment_id AND is_deleted = 0 ORDER BY previous_school_id DESC LIMIT 1) AS last_school_id,

                   lac.house_no AS current_house_no,
                   lac.street_name AS current_street,
                   lac.street_name AS current_street_name,
                   lac.subdivision AS current_subdivision,
                   lac.zip_code AS current_zip_code,
                   lac.province_id AS current_province_id,
                   lac.city_municipality_id AS current_city_municipality_id,
                   lac.barangay_id AS current_barangay_id,
                   lac.country_name AS current_country_name,

                     lap.house_no AS permanent_house_no,
                     lap.street_name AS permanent_street,
                     lap.street_name AS permanent_street_name,
                   lap.subdivision AS permanent_subdivision,
                   lap.zip_code AS permanent_zip_code,
                   lap.province_id AS permanent_province_id,
                   lap.city_municipality_id AS permanent_city_municipality_id,
                   lap.barangay_id AS permanent_barangay_id,
                   lap.country_name AS permanent_country_name
            FROM learners l
            LEFT JOIN learner_addresses lac ON lac.learner_address_id = (
                SELECT la2.learner_address_id
                FROM learner_addresses la2
                WHERE la2.learner_id = l.learner_id AND la2.address_type = 'CURRENT' AND la2.is_deleted = 0
                ORDER BY la2.learner_address_id DESC
                LIMIT 1
            )
            LEFT JOIN learner_addresses lap ON lap.learner_address_id = (
                SELECT la3.learner_address_id
                FROM learner_addresses la3
                WHERE la3.learner_id = l.learner_id AND la3.address_type = 'PERMANENT' AND la3.is_deleted = 0
                ORDER BY la3.learner_address_id DESC
                LIMIT 1
            )
            LEFT JOIN enrollments e ON e.enrollment_id = (
                SELECT e2.enrollment_id
                FROM enrollments e2
                WHERE e2.learner_id = l.learner_id AND e2.is_deleted = 0
                ORDER BY e2.enrollment_date DESC, e2.enrollment_id DESC
                LIMIT 1
            )
            LEFT JOIN enrollment_types et ON et.enrollment_type_id = e.enrollment_type_id
            LEFT JOIN grade_levels gl ON gl.grade_level_id = e.grade_level_id
            LEFT JOIN sections sec ON sec.section_id = e.section_id
            LEFT JOIN school_years sy ON sy.school_year_id = e.school_year_id
            LEFT JOIN curricula cur ON cur.curriculum_id = e.curriculum_id
            WHERE l.is_deleted = 0
            ORDER BY l.last_name, l.first_name";

    $stmt = $conn->prepare($sql);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function createRegistration(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['lrn']) || empty($data['first_name']) || empty($data['last_name'])) {
        respond(['success' => false, 'message' => 'LRN, first name, and last name are required'], 422);
    }

    $gradeLevelId = intOrNull($data['grade_level_id'] ?? null);
    $sectionId = intOrNull($data['section_id'] ?? null);
    if ($gradeLevelId === null || $sectionId === null) {
        respond(['success' => false, 'message' => 'Grade level and section are required'], 422);
    }

    if (empty($data['lrn']) || trim((string)$data['lrn']) === '') {
        respond(['success' => false, 'message' => 'LRN is required'], 422);
    }

    if (empty($data['first_name']) || empty($data['last_name'])) {
        respond(['success' => false, 'message' => 'First name and last name are required'], 422);
    }

    $lrn = trim((string)$data['lrn']);
    if ($lrn === '') {
        respond(['success' => false, 'message' => 'LRN is required'], 422);
    }

    if (!preg_match('/^\d{12}$/', $lrn)) {
        respond(['success' => false, 'message' => 'LRN must be exactly 12 digits'], 422);
    }

    // Friendly duplicate check (DB also enforces this if unique index exists)
    $stmt = $conn->prepare('SELECT learner_id FROM learners WHERE lrn = :lrn AND is_deleted = 0 LIMIT 1');
    $stmt->bindValue(':lrn', $lrn);
    $stmt->execute();
    if ($stmt->fetchColumn()) {
        respond(['success' => false, 'message' => 'LRN already exists.'], 409);
    }

    try {
        $conn->beginTransaction();

        // Auto-create/link user account for learner (username=LRN, password=LRN).
        $account = resolveOrCreateLearnerAccount($conn, $lrn, intOrNull($data['user_id'] ?? null));

        // Insert learner
        $stmt = $conn->prepare('INSERT INTO learners (
            user_id, lrn, first_name, middle_name, last_name,
            name_extension, date_of_birth, gender,
            civil_status, religion, mother_tongue, indigenous_group, citizenship,
            learner_status,
            contact_number, email, address,
            is_4ps_beneficiary, is_indigenous, completed
        ) VALUES (
            :user_id, :lrn, :first_name, :middle_name, :last_name,
            :name_extension, :date_of_birth, :gender,
            :civil_status, :religion, :mother_tongue, :indigenous_group, :citizenship,
            :learner_status,
            :contact_number, :email, :address,
            :is_4ps_beneficiary, :is_indigenous, :completed
        )');

        $userId = (int)($account['user_id'] ?? 0);
        $middleName = nullIfEmpty($data['middle_name'] ?? null);
        $nameExtension = nullIfEmpty($data['name_extension_id'] ?? null);
        $dateOfBirth = nullIfEmpty($data['date_of_birth'] ?? null);
        $gender = nullIfEmpty($data['gender'] ?? null);
        $civilStatus = nullIfEmpty($data['civil_status_id'] ?? null);
        $religion = nullIfEmpty($data['religion_id'] ?? null);
        $motherTongue = nullIfEmpty($data['mother_tongue_id'] ?? null);
        $indigenousGroup = nullIfEmpty($data['indigenous_group_id'] ?? null);
        $citizenship = nullIfEmpty($data['citizenship'] ?? null) ?? 'Filipino';
        $learnerStatus = nullIfEmpty($data['learner_status_id'] ?? null) ?? 'Enrolled';
        $contactNumber = nullIfEmpty($data['contact_number'] ?? null);
        $email = nullIfEmpty($data['email'] ?? null);
        $address = nullIfEmpty($data['address'] ?? null);

        $stmt->bindValue(':user_id', $userId, PDO::PARAM_INT);
        $stmt->bindValue(':lrn', $lrn);
        $stmt->bindValue(':first_name', $data['first_name']);
        bindNullable($stmt, ':middle_name', $middleName);
        $stmt->bindValue(':last_name', $data['last_name']);
        bindNullable($stmt, ':name_extension', $nameExtension);
        bindNullable($stmt, ':date_of_birth', $dateOfBirth);
        bindNullable($stmt, ':gender', $gender);
        bindNullable($stmt, ':civil_status', $civilStatus);
        bindNullable($stmt, ':religion', $religion);
        bindNullable($stmt, ':mother_tongue', $motherTongue);
        bindNullable($stmt, ':indigenous_group', $indigenousGroup);
        $stmt->bindValue(':citizenship', $citizenship);
        bindNullable($stmt, ':learner_status', $learnerStatus);
        bindNullable($stmt, ':contact_number', $contactNumber);
        bindNullable($stmt, ':email', $email);
        bindNullable($stmt, ':address', $address);
        $stmt->bindValue(':is_4ps_beneficiary', $data['is_4ps_beneficiary'] ?? 0, PDO::PARAM_INT);
        $stmt->bindValue(':is_indigenous', $data['is_indigenous'] ?? 0, PDO::PARAM_INT);
        $stmt->bindValue(':completed', 1, PDO::PARAM_INT);
        $stmt->execute();

        $learner_id = $conn->lastInsertId();

        $isSameAsCurrent = isset($data['is_permanent_same_as_current']) ? (int)$data['is_permanent_same_as_current'] : 1;
        // Best-effort: some deployments may not have this column yet.
        try {
            $stmt = $conn->prepare('UPDATE learners SET is_permanent_same_as_current = :flag WHERE learner_id = :learner_id');
            $stmt->bindValue(':flag', $isSameAsCurrent, PDO::PARAM_INT);
            $stmt->bindValue(':learner_id', (int)$learner_id, PDO::PARAM_INT);
            $stmt->execute();
        } catch (PDOException $e) {
            if (!str_contains($e->getMessage(), 'Unknown column')) {
                throw $e;
            }
        }

        // Insert enrollment for the active (or selected) school year
        $schoolYearId = !empty($data['school_year_id']) ? (int)$data['school_year_id'] : getActiveSchoolYearId($conn);
        if (!$schoolYearId) {
            $conn->rollBack();
            respond(['success' => false, 'message' => 'No active school year found'], 409);
        }

        // Validate section consistency before triggers run
        $sectionId = (int)$sectionId;
        $gradeLevelId = (int)$gradeLevelId;
        $stmt = $conn->prepare('SELECT section_id, school_year_id, grade_level_id FROM sections WHERE section_id = :section_id AND is_deleted = 0 LIMIT 1');
        $stmt->bindValue(':section_id', $sectionId, PDO::PARAM_INT);
        $stmt->execute();
        $sectionRow = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$sectionRow) {
            $conn->rollBack();
            respond(['success' => false, 'message' => 'Selected section not found'], 422);
        }
        if ((int)$sectionRow['school_year_id'] !== (int)$schoolYearId) {
            $conn->rollBack();
            respond(['success' => false, 'message' => 'Selected section does not belong to the selected school year'], 422);
        }
        if ((int)$sectionRow['grade_level_id'] !== (int)$gradeLevelId) {
            $conn->rollBack();
            respond(['success' => false, 'message' => 'Selected section does not match the selected grade level'], 422);
        }

        // Enrollment date should reflect the actual registration/save date.
        // Always set it server-side during registration to avoid manual input.
        $enrollmentDate = date('Y-m-d');

        $resolvedCurriculumId = resolveAndValidateCurriculum(
            $conn,
            intOrNull($data['curriculum_id'] ?? null),
            (int)$schoolYearId,
            (int)$gradeLevelId
        );

        $stmt = $conn->prepare('INSERT INTO enrollments (learner_id, school_year_id, grade_level_id, section_id, curriculum_id, enrollment_type_id, enrollment_date)
                                VALUES (:learner_id, :school_year_id, :grade_level_id, :section_id, :curriculum_id, :enrollment_type_id, :enrollment_date)');
        $stmt->bindValue(':learner_id', (int)$learner_id, PDO::PARAM_INT);
        $stmt->bindValue(':school_year_id', $schoolYearId, PDO::PARAM_INT);
        $stmt->bindValue(':grade_level_id', $gradeLevelId, PDO::PARAM_INT);
        $stmt->bindValue(':section_id', $sectionId, PDO::PARAM_INT);
        $stmt->bindValue(':curriculum_id', $resolvedCurriculumId, $resolvedCurriculumId === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
        $stmt->bindValue(':enrollment_type_id', $data['enrollment_type_id'] ?? null, empty($data['enrollment_type_id']) ? PDO::PARAM_NULL : PDO::PARAM_INT);
        $stmt->bindValue(':enrollment_date', $enrollmentDate);
        $stmt->execute();

        $enrollmentId = (int)$conn->lastInsertId();

        // Save addresses (CURRENT + PERMANENT)
        saveLearnerAddresses($conn, (int)$learner_id, $data);

        // Insert family members (Father)
        if (!empty($data['father_name'])) {
            $stmt = $conn->prepare('INSERT INTO family_members (learner_id, full_name, relationship, occupation, contact_number) VALUES (:learner_id, :full_name, :relationship, :occupation, :contact_number)');
            $stmt->bindValue(':learner_id', $learner_id, PDO::PARAM_INT);
            $stmt->bindValue(':full_name', $data['father_name']);
            $stmt->bindValue(':relationship', 'Father');
            $stmt->bindValue(':occupation', $data['father_occupation'] ?? null);
            $stmt->bindValue(':contact_number', $data['father_contact'] ?? null);
            $stmt->execute();
        }

        // Insert family members (Mother)
        if (!empty($data['mother_name'])) {
            $stmt = $conn->prepare('INSERT INTO family_members (learner_id, full_name, relationship, occupation, contact_number) VALUES (:learner_id, :full_name, :relationship, :occupation, :contact_number)');
            $stmt->bindValue(':learner_id', $learner_id, PDO::PARAM_INT);
            $stmt->bindValue(':full_name', $data['mother_name']);
            $stmt->bindValue(':relationship', 'Mother');
            $stmt->bindValue(':occupation', $data['mother_occupation'] ?? null);
            $stmt->bindValue(':contact_number', $data['mother_contact'] ?? null);
            $stmt->execute();
        }

        // Insert family members (Spouse)
        if (!empty($data['spouse_name'])) {
            $stmt = $conn->prepare('INSERT INTO family_members (learner_id, full_name, relationship, occupation) VALUES (:learner_id, :full_name, :relationship, :occupation)');
            $stmt->bindValue(':learner_id', $learner_id, PDO::PARAM_INT);
            $stmt->bindValue(':full_name', $data['spouse_name']);
            $stmt->bindValue(':relationship', 'Spouse');
            $stmt->bindValue(':occupation', $data['spouse_occupation'] ?? null);
            $stmt->execute();
        }

        // Insert family members (Guardian)
        if (!empty($data['guardian_name'])) {
            $stmt = $conn->prepare('INSERT INTO family_members (learner_id, full_name, relationship, contact_number) VALUES (:learner_id, :full_name, :relationship, :contact_number)');
            $stmt->bindValue(':learner_id', $learner_id, PDO::PARAM_INT);
            $stmt->bindValue(':full_name', $data['guardian_name']);
            $stmt->bindValue(':relationship', 'Legal Guardian');
            $stmt->bindValue(':contact_number', $data['guardian_contact'] ?? null);
            $stmt->execute();
        }

        // Insert emergency contact
        if (!empty($data['emergency_person_name'])) {
            $stmt = $conn->prepare('INSERT INTO emergency_contacts (learner_id, contact_name, relationship, contact_number, address) VALUES (:learner_id, :contact_name, :relationship, :contact_number, :address)');
            $stmt->bindValue(':learner_id', $learner_id, PDO::PARAM_INT);
            $stmt->bindValue(':contact_name', $data['emergency_person_name']);
            $stmt->bindValue(':relationship', 'Emergency Contact');
            $stmt->bindValue(':contact_number', $data['emergency_mobile'] ?? null);
            $stmt->bindValue(':address', $data['emergency_address'] ?? null);
            $stmt->execute();
        }

        // Insert previous school information
        if (!empty($data['last_school_attended']) || !empty($data['last_grade_level_completed'])) {
            $stmt = $conn->prepare('INSERT INTO learner_previous_schools (learner_id, enrollment_id, last_grade_level_completed, last_school_year_completed, last_school_attended, last_school_id)
                                    VALUES (:learner_id, :enrollment_id, :last_grade_level_completed, :last_school_year_completed, :last_school_attended, :last_school_id)');
            $stmt->bindValue(':learner_id', $learner_id, PDO::PARAM_INT);
            $stmt->bindValue(':enrollment_id', $enrollmentId, PDO::PARAM_INT);
            $stmt->bindValue(':last_grade_level_completed', $data['last_grade_level_completed'] ?? null);
            $stmt->bindValue(':last_school_year_completed', $data['last_school_year_completed'] ?? null);
            $stmt->bindValue(':last_school_attended', $data['last_school_attended'] ?? null);
            $stmt->bindValue(':last_school_id', $data['last_school_id'] ?? null);
            $stmt->execute();
        }

        $conn->commit();
        respond([
            'success' => true,
            'message' => 'Registration submitted.',
            'learner_id' => (int)$learner_id,
            'enrollment_id' => $enrollmentId,
            'learner_account' => [
                'created' => (bool)($account['created'] ?? false),
                'linked' => true,
                'username' => (string)($account['username'] ?? $lrn),
            ]
        ]);
    } catch (PDOException $e) {
        if ($conn->inTransaction()) {
            $conn->rollBack();
        }

        // Triggers use SIGNAL SQLSTATE '45000' for capacity/consistency checks.
        if ((string)$e->getCode() === '45000') {
            respond(['success' => false, 'message' => $e->getMessage()], 409);
        }

        respond(['success' => false, 'message' => 'Database error: ' . $e->getMessage()], 500);
    } catch (Exception $e) {
        if ($conn->inTransaction()) {
            $conn->rollBack();
        }
        respond(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
    }
}

function updateRegistration(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['learner_id'])) {
        respond([
            'success' => false,
            'message' => 'Learner ID is required',
            'field_errors' => ['learner_id' => 'Learner ID is required']
        ], 422);
    }

    $learnerId = (int)$data['learner_id'];

    // Determine target school year early (used for enrollment fallback).
    $schoolYearId = !empty($data['school_year_id']) ? (int)$data['school_year_id'] : getActiveSchoolYearId($conn);
    if (!$schoolYearId) {
        respond(['success' => false, 'message' => 'No active school year found'], 409);
    }

    // Be tolerant of missing grade/section in payload by falling back to existing enrollment.
    $gradeLevelId = intOrNull($data['grade_level_id'] ?? null);
    $sectionId = intOrNull($data['section_id'] ?? null);
    $skipEnrollmentUpdate = false;
    if ($gradeLevelId === null || $sectionId === null) {
        $fallbackEnrollment = getEnrollmentForSchoolYear($conn, $learnerId, (int)$schoolYearId) ?? getLatestEnrollment($conn, $learnerId);
        if ($fallbackEnrollment) {
            $gradeLevelId = $gradeLevelId ?? (intOrNull($fallbackEnrollment['grade_level_id'] ?? null));
            $sectionId = $sectionId ?? (intOrNull($fallbackEnrollment['section_id'] ?? null));
        } else {
            // Allow updating personal details even if enrollment data is missing.
            $skipEnrollmentUpdate = true;
        }
    }
    if (!$skipEnrollmentUpdate && ($gradeLevelId === null || $sectionId === null)) {
        respond([
            'success' => false,
            'message' => 'Grade level and section are required',
            'field_errors' => [
                'grade_level_id' => 'Grade level is required',
                'section_id' => 'Section is required'
            ]
        ], 422);
    }

    // Normalize for downstream logic.
    if (!$skipEnrollmentUpdate) {
        $data['grade_level_id'] = (int)$gradeLevelId;
        $data['section_id'] = (int)$sectionId;
    }
    $data['school_year_id'] = (int)$schoolYearId;

    $lrn = trim((string)($data['lrn'] ?? ''));
    if ($lrn === '') {
        respond([
            'success' => false,
            'message' => 'LRN is required',
            'field_errors' => ['lrn' => 'LRN is required']
        ], 422);
    }

    // Allow updates on legacy records with non-12-digit LRNs as long as the LRN is not being changed.
    $curStmt = $conn->prepare('SELECT lrn FROM learners WHERE learner_id = :learner_id AND is_deleted = 0 LIMIT 1');
    $curStmt->bindValue(':learner_id', (int)$data['learner_id'], PDO::PARAM_INT);
    $curStmt->execute();
    $currentLrn = $curStmt->fetchColumn();
    if ($currentLrn === false || $currentLrn === null) {
        respond(['success' => false, 'message' => 'Learner not found'], 404);
    }
    $currentLrn = trim((string)$currentLrn);

    if ($lrn !== $currentLrn) {
        if (!preg_match('/^\d{12}$/', $lrn)) {
            respond([
                'success' => false,
                'message' => 'LRN must be exactly 12 digits',
                'field_errors' => ['lrn' => 'LRN must be exactly 12 digits']
            ], 422);
        }
        $stmt = $conn->prepare('SELECT learner_id FROM learners WHERE lrn = :lrn AND is_deleted = 0 AND learner_id <> :learner_id LIMIT 1');
        $stmt->bindValue(':lrn', $lrn);
        $stmt->bindValue(':learner_id', (int)$data['learner_id'], PDO::PARAM_INT);
        $stmt->execute();
        if ($stmt->fetchColumn()) {
            respond(['success' => false, 'message' => 'LRN already exists.'], 409);
        }
    }

    $data['lrn'] = $lrn;

    try {
        $conn->beginTransaction();

        // Update learner
        $stmt = $conn->prepare('UPDATE learners SET
            user_id = :user_id,
            lrn = :lrn,
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
            contact_number = :contact_number,
            email = :email,
            address = :address,
            is_4ps_beneficiary = :is_4ps_beneficiary,
            is_indigenous = :is_indigenous,
            completed = :completed
        WHERE learner_id = :learner_id');

        $stmt->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
        $userId = intOrNull($data['user_id'] ?? null);
        $lrnValue = nullIfEmpty($data['lrn'] ?? null);
        $firstName = nullIfEmpty($data['first_name'] ?? null);
        $middleName = nullIfEmpty($data['middle_name'] ?? null);
        $lastName = nullIfEmpty($data['last_name'] ?? null);
        $nameExtension = nullIfEmpty($data['name_extension_id'] ?? null);
        $dateOfBirth = nullIfEmpty($data['date_of_birth'] ?? null);
        $gender = nullIfEmpty($data['gender'] ?? null);
        $contactNumber = nullIfEmpty($data['contact_number'] ?? null);
        $email = nullIfEmpty($data['email'] ?? null);
        $address = nullIfEmpty($data['address'] ?? null);
        $civilStatus = nullIfEmpty($data['civil_status_id'] ?? null);
        $religion = nullIfEmpty($data['religion_id'] ?? null);
        $motherTongue = nullIfEmpty($data['mother_tongue_id'] ?? null);
        $indigenousGroup = nullIfEmpty($data['indigenous_group_id'] ?? null);
        $citizenship = nullIfEmpty($data['citizenship'] ?? null) ?? 'Filipino';
        $learnerStatus = nullIfEmpty($data['learner_status_id'] ?? null);

        bindNullable($stmt, ':user_id', $userId, PDO::PARAM_INT);
        bindNullable($stmt, ':lrn', $lrnValue);
        bindNullable($stmt, ':first_name', $firstName);
        bindNullable($stmt, ':middle_name', $middleName);
        bindNullable($stmt, ':last_name', $lastName);
        bindNullable($stmt, ':name_extension', $nameExtension);
        bindNullable($stmt, ':date_of_birth', $dateOfBirth);
        bindNullable($stmt, ':gender', $gender);
        bindNullable($stmt, ':civil_status', $civilStatus);
        bindNullable($stmt, ':religion', $religion);
        bindNullable($stmt, ':mother_tongue', $motherTongue);
        bindNullable($stmt, ':indigenous_group', $indigenousGroup);
        $stmt->bindValue(':citizenship', $citizenship);
        bindNullable($stmt, ':learner_status', $learnerStatus);
        bindNullable($stmt, ':contact_number', $contactNumber);
        bindNullable($stmt, ':email', $email);
        bindNullable($stmt, ':address', $address);
        $stmt->bindValue(':is_4ps_beneficiary', (int)($data['is_4ps_beneficiary'] ?? 0), PDO::PARAM_INT);
        $stmt->bindValue(':is_indigenous', (int)($data['is_indigenous'] ?? 0), PDO::PARAM_INT);
        $stmt->bindValue(':completed', (int)($data['completed'] ?? 0), PDO::PARAM_INT);
        $stmt->execute();

        // Save addresses (CURRENT + PERMANENT)
        saveLearnerAddresses($conn, (int)$data['learner_id'], $data);

        // Soft-delete existing related rows before re-inserting
        $stmt = $conn->prepare('UPDATE family_members SET is_deleted = 1, deleted_at = NOW() WHERE learner_id = :learner_id AND is_deleted = 0');
        $stmt->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
        $stmt->execute();

        $stmt = $conn->prepare('UPDATE emergency_contacts SET is_deleted = 1, deleted_at = NOW() WHERE learner_id = :learner_id AND is_deleted = 0');
        $stmt->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
        $stmt->execute();

        $stmt = $conn->prepare('UPDATE learner_previous_schools SET is_deleted = 1, deleted_at = NOW() WHERE learner_id = :learner_id AND is_deleted = 0');
        $stmt->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
        $stmt->execute();

        $enrollmentId = 0;

        if (!$skipEnrollmentUpdate) {
            // Update (or create) enrollment for selected/active school year
            $schoolYearId = (int)$data['school_year_id'];

            // Validate section consistency before triggers run
            $sectionId = (int)$data['section_id'];
            $gradeLevelId = (int)$data['grade_level_id'];
            $stmt = $conn->prepare('SELECT section_id, school_year_id, grade_level_id FROM sections WHERE section_id = :section_id AND is_deleted = 0 LIMIT 1');
            $stmt->bindValue(':section_id', $sectionId, PDO::PARAM_INT);
            $stmt->execute();
            $sectionRow = $stmt->fetch(PDO::FETCH_ASSOC);
            if (!$sectionRow) {
                $conn->rollBack();
                respond([
                    'success' => false,
                    'message' => 'Selected section not found',
                    'field_errors' => ['section_id' => 'Selected section not found']
                ], 422);
            }
            if ((int)$sectionRow['school_year_id'] !== (int)$schoolYearId) {
                $conn->rollBack();
                respond([
                    'success' => false,
                    'message' => 'Selected section does not belong to the selected school year',
                    'field_errors' => [
                        'section_id' => 'Section does not belong to the selected school year',
                        'school_year_id' => 'School year does not match the selected section'
                    ]
                ], 422);
            }
            if ((int)$sectionRow['grade_level_id'] !== (int)$gradeLevelId) {
                $conn->rollBack();
                respond([
                    'success' => false,
                    'message' => 'Selected section does not match the selected grade level',
                    'field_errors' => [
                        'section_id' => 'Section does not match the selected grade level',
                        'grade_level_id' => 'Grade level does not match the selected section'
                    ]
                ], 422);
            }

            // If enrollment_date is omitted/blank, keep existing enrollment_date for updates.
            $enrollmentDate = !empty($data['enrollment_date']) ? $data['enrollment_date'] : '';

            $resolvedCurriculumId = resolveAndValidateCurriculum(
                $conn,
                intOrNull($data['curriculum_id'] ?? null),
                (int)$schoolYearId,
                (int)$gradeLevelId
            );

            $targetEnrollment = getEnrollmentForSchoolYear($conn, (int)$data['learner_id'], $schoolYearId);

            if ($targetEnrollment) {
                $stmt = $conn->prepare('UPDATE enrollments
                                        SET school_year_id = :school_year_id,
                                            grade_level_id = :grade_level_id,
                                            section_id = :section_id,
                                            curriculum_id = :curriculum_id,
                                            enrollment_type_id = :enrollment_type_id,
                                            enrollment_date = COALESCE(NULLIF(:enrollment_date, ""), enrollment_date)
                                        WHERE enrollment_id = :enrollment_id');
                $stmt->bindValue(':school_year_id', $schoolYearId, PDO::PARAM_INT);
                $stmt->bindValue(':grade_level_id', $gradeLevelId, PDO::PARAM_INT);
                $stmt->bindValue(':section_id', $sectionId, PDO::PARAM_INT);
                $stmt->bindValue(':curriculum_id', $resolvedCurriculumId, $resolvedCurriculumId === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
                $stmt->bindValue(':enrollment_type_id', $data['enrollment_type_id'] ?? null, empty($data['enrollment_type_id']) ? PDO::PARAM_NULL : PDO::PARAM_INT);
                $stmt->bindValue(':enrollment_date', $enrollmentDate);
                $stmt->bindValue(':enrollment_id', (int)$targetEnrollment['enrollment_id'], PDO::PARAM_INT);
                $stmt->execute();
                $enrollmentId = (int)$targetEnrollment['enrollment_id'];
            } else {
                // Creating a new enrollment row (e.g., for a new school year): default to today's date
                if ($enrollmentDate === '') {
                    $enrollmentDate = date('Y-m-d');
                }
                $stmt = $conn->prepare('INSERT INTO enrollments (learner_id, school_year_id, grade_level_id, section_id, curriculum_id, enrollment_type_id, enrollment_date)
                                        VALUES (:learner_id, :school_year_id, :grade_level_id, :section_id, :curriculum_id, :enrollment_type_id, :enrollment_date)');
                $stmt->bindValue(':learner_id', (int)$data['learner_id'], PDO::PARAM_INT);
                $stmt->bindValue(':school_year_id', $schoolYearId, PDO::PARAM_INT);
                $stmt->bindValue(':grade_level_id', $gradeLevelId, PDO::PARAM_INT);
                $stmt->bindValue(':section_id', $sectionId, PDO::PARAM_INT);
                $stmt->bindValue(':curriculum_id', $resolvedCurriculumId, $resolvedCurriculumId === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
                $stmt->bindValue(':enrollment_type_id', $data['enrollment_type_id'] ?? null, empty($data['enrollment_type_id']) ? PDO::PARAM_NULL : PDO::PARAM_INT);
                $stmt->bindValue(':enrollment_date', $enrollmentDate);
                $stmt->execute();
                $enrollmentId = (int)$conn->lastInsertId();
            }
        }

        // Re-insert family members (Father)
        if (!empty($data['father_name'])) {
            $stmt = $conn->prepare('INSERT INTO family_members (learner_id, full_name, relationship, occupation, contact_number) VALUES (:learner_id, :full_name, :relationship, :occupation, :contact_number)');
            $stmt->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
            $stmt->bindValue(':full_name', $data['father_name']);
            $stmt->bindValue(':relationship', 'Father');
            $stmt->bindValue(':occupation', $data['father_occupation'] ?? null);
            $stmt->bindValue(':contact_number', $data['father_contact'] ?? null);
            $stmt->execute();
        }

        // Re-insert family members (Mother)
        if (!empty($data['mother_name'])) {
            $stmt = $conn->prepare('INSERT INTO family_members (learner_id, full_name, relationship, occupation, contact_number) VALUES (:learner_id, :full_name, :relationship, :occupation, :contact_number)');
            $stmt->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
            $stmt->bindValue(':full_name', $data['mother_name']);
            $stmt->bindValue(':relationship', 'Mother');
            $stmt->bindValue(':occupation', $data['mother_occupation'] ?? null);
            $stmt->bindValue(':contact_number', $data['mother_contact'] ?? null);
            $stmt->execute();
        }

        // Re-insert family members (Spouse)
        if (!empty($data['spouse_name'])) {
            $stmt = $conn->prepare('INSERT INTO family_members (learner_id, full_name, relationship, occupation) VALUES (:learner_id, :full_name, :relationship, :occupation)');
            $stmt->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
            $stmt->bindValue(':full_name', $data['spouse_name']);
            $stmt->bindValue(':relationship', 'Spouse');
            $stmt->bindValue(':occupation', $data['spouse_occupation'] ?? null);
            $stmt->execute();
        }

        // Re-insert family members (Guardian)
        if (!empty($data['guardian_name'])) {
            $stmt = $conn->prepare('INSERT INTO family_members (learner_id, full_name, relationship, contact_number) VALUES (:learner_id, :full_name, :relationship, :contact_number)');
            $stmt->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
            $stmt->bindValue(':full_name', $data['guardian_name']);
            $stmt->bindValue(':relationship', 'Legal Guardian');
            $stmt->bindValue(':contact_number', $data['guardian_contact'] ?? null);
            $stmt->execute();
        }

        // Re-insert emergency contact
        if (!empty($data['emergency_person_name'])) {
            $stmt = $conn->prepare('INSERT INTO emergency_contacts (learner_id, contact_name, relationship, contact_number, address) VALUES (:learner_id, :contact_name, :relationship, :contact_number, :address)');
            $stmt->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
            $stmt->bindValue(':contact_name', $data['emergency_person_name']);
            $stmt->bindValue(':relationship', 'Emergency Contact');
            $stmt->bindValue(':contact_number', $data['emergency_mobile'] ?? null);
            $stmt->bindValue(':address', $data['emergency_address'] ?? null);
            $stmt->execute();
        }

        // Re-insert previous school information
        if ($enrollmentId > 0 && (!empty($data['last_school_attended']) || !empty($data['last_grade_level_completed']))) {
            // Ensure only one active record per enrollment
            $stmt = $conn->prepare('UPDATE learner_previous_schools SET is_deleted = 1, deleted_at = NOW() WHERE learner_id = :learner_id AND enrollment_id = :enrollment_id AND is_deleted = 0');
            $stmt->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
            $stmt->bindValue(':enrollment_id', $enrollmentId, PDO::PARAM_INT);
            $stmt->execute();

            $stmt = $conn->prepare('INSERT INTO learner_previous_schools (learner_id, enrollment_id, last_grade_level_completed, last_school_year_completed, last_school_attended, last_school_id)
                                    VALUES (:learner_id, :enrollment_id, :last_grade_level_completed, :last_school_year_completed, :last_school_attended, :last_school_id)');
            $stmt->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
            $stmt->bindValue(':enrollment_id', $enrollmentId, PDO::PARAM_INT);
            $stmt->bindValue(':last_grade_level_completed', $data['last_grade_level_completed'] ?? null);
            $stmt->bindValue(':last_school_year_completed', $data['last_school_year_completed'] ?? null);
            $stmt->bindValue(':last_school_attended', $data['last_school_attended'] ?? null);
            $stmt->bindValue(':last_school_id', $data['last_school_id'] ?? null);
            $stmt->execute();
        }

        $conn->commit();
        respond(['success' => true, 'message' => 'Registration updated.', 'learner_id' => (int)$data['learner_id'], 'enrollment_id' => $enrollmentId]);
    } catch (PDOException $e) {
        if ($conn->inTransaction()) {
            $conn->rollBack();
        }

        if ((string)$e->getCode() === '45000') {
            respond(['success' => false, 'message' => $e->getMessage()], 409);
        }

        respond(['success' => false, 'message' => 'Database error: ' . $e->getMessage()], 500);
    } catch (Exception $e) {
        if ($conn->inTransaction()) {
            $conn->rollBack();
        }
        respond(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
    }
}

function getActiveSchoolYearId(PDO $conn): ?int {
    $stmt = $conn->prepare('SELECT school_year_id FROM school_years WHERE is_active = 1 AND is_deleted = 0 ORDER BY year_start DESC LIMIT 1');
    $stmt->execute();
    $id = $stmt->fetchColumn();
    return $id ? (int)$id : null;
}

function getLatestEnrollment(PDO $conn, int $learnerId): ?array {
    $stmt = $conn->prepare('SELECT * FROM enrollments WHERE learner_id = :learner_id AND is_deleted = 0 ORDER BY enrollment_date DESC, enrollment_id DESC LIMIT 1');
    $stmt->bindValue(':learner_id', $learnerId, PDO::PARAM_INT);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

function getEnrollmentForSchoolYear(PDO $conn, int $learnerId, int $schoolYearId): ?array {
    $stmt = $conn->prepare('SELECT * FROM enrollments WHERE learner_id = :learner_id AND school_year_id = :school_year_id AND is_deleted = 0 ORDER BY enrollment_id DESC LIMIT 1');
    $stmt->bindValue(':learner_id', $learnerId, PDO::PARAM_INT);
    $stmt->bindValue(':school_year_id', $schoolYearId, PDO::PARAM_INT);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

function markEntryCompleted(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['learner_id'])) {
        respond(['success' => false, 'message' => 'Learner ID is required'], 422);
    }

    // Record entry completion by creating a document entry
    $stmt = $conn->prepare('INSERT INTO learner_documents (learner_id, document_type_id, submitted_at) VALUES (:learner_id, 1, NOW())');
    $stmt->bindValue(':learner_id', $data['learner_id'], PDO::PARAM_INT);
    $stmt->execute();

    respond(['success' => true, 'message' => 'Entry marked as completed']);
}

function deleteRegistration(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['learner_id'])) {
        respond(['success' => false, 'message' => 'Learner ID is required'], 422);
    }

    try {
        $conn->beginTransaction();

        $learnerId = (int)$data['learner_id'];

        $stmt = $conn->prepare('UPDATE enrollments SET is_deleted = 1, deleted_at = NOW() WHERE learner_id = :learner_id AND is_deleted = 0');
        $stmt->bindValue(':learner_id', $learnerId, PDO::PARAM_INT);
        $stmt->execute();

        $stmt = $conn->prepare('UPDATE family_members SET is_deleted = 1, deleted_at = NOW() WHERE learner_id = :learner_id AND is_deleted = 0');
        $stmt->bindValue(':learner_id', $learnerId, PDO::PARAM_INT);
        $stmt->execute();

        $stmt = $conn->prepare('UPDATE emergency_contacts SET is_deleted = 1, deleted_at = NOW() WHERE learner_id = :learner_id AND is_deleted = 0');
        $stmt->bindValue(':learner_id', $learnerId, PDO::PARAM_INT);
        $stmt->execute();

        $stmt = $conn->prepare('UPDATE learner_previous_schools SET is_deleted = 1, deleted_at = NOW() WHERE learner_id = :learner_id AND is_deleted = 0');
        $stmt->bindValue(':learner_id', $learnerId, PDO::PARAM_INT);
        $stmt->execute();

        $stmt = $conn->prepare('UPDATE learner_documents SET is_deleted = 1, deleted_at = NOW() WHERE learner_id = :learner_id AND is_deleted = 0');
        $stmt->bindValue(':learner_id', $learnerId, PDO::PARAM_INT);
        $stmt->execute();

        // Addresses
        $stmt = $conn->prepare('UPDATE learner_addresses SET is_deleted = 1, deleted_at = NOW() WHERE learner_id = :learner_id AND is_deleted = 0');
        $stmt->bindValue(':learner_id', $learnerId, PDO::PARAM_INT);
        $stmt->execute();

        $stmt = $conn->prepare('UPDATE learners SET is_deleted = 1, deleted_at = NOW() WHERE learner_id = :learner_id');
        $stmt->bindValue(':learner_id', $learnerId, PDO::PARAM_INT);
        $stmt->execute();

        $conn->commit();
        respond(['success' => true, 'message' => 'Registration deleted.']);
    } catch (Exception $e) {
        $conn->rollBack();
        respond(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
    }
}

function saveLearnerAddresses(PDO $conn, int $learnerId, array $data): void {
    $isSame = isset($data['is_permanent_same_as_current']) ? (int)$data['is_permanent_same_as_current'] : 1;

    // Keep the flag on learners for UI convenience
    try {
        $stmt = $conn->prepare('UPDATE learners SET is_permanent_same_as_current = :flag WHERE learner_id = :learner_id');
        $stmt->bindValue(':flag', $isSame, PDO::PARAM_INT);
        $stmt->bindValue(':learner_id', $learnerId, PDO::PARAM_INT);
        $stmt->execute();
    } catch (PDOException $e) {
        if (!str_contains($e->getMessage(), 'Unknown column')) {
            throw $e;
        }
    }

    upsertLearnerAddress($conn, $learnerId, 'CURRENT', $data, 'current_');

    if ($isSame === 1) {
        softDeleteLearnerAddressType($conn, $learnerId, 'PERMANENT');
        return;
    }

    upsertLearnerAddress($conn, $learnerId, 'PERMANENT', $data, 'permanent_');
}

function softDeleteLearnerAddressType(PDO $conn, int $learnerId, string $addressType): void {
    // Ensure unique constraint stays valid by removing older deleted rows first.
    $stmt = $conn->prepare('DELETE FROM learner_addresses WHERE learner_id = :learner_id AND address_type = :address_type AND is_deleted = 1');
    $stmt->bindValue(':learner_id', $learnerId, PDO::PARAM_INT);
    $stmt->bindValue(':address_type', $addressType);
    $stmt->execute();

    $stmt = $conn->prepare('UPDATE learner_addresses SET is_deleted = 1, deleted_at = NOW() WHERE learner_id = :learner_id AND address_type = :address_type AND is_deleted = 0');
    $stmt->bindValue(':learner_id', $learnerId, PDO::PARAM_INT);
    $stmt->bindValue(':address_type', $addressType);
    $stmt->execute();
}

function upsertLearnerAddress(PDO $conn, int $learnerId, string $addressType, array $data, string $prefix): void {
    // Always soft-delete previous active record for this type
    softDeleteLearnerAddressType($conn, $learnerId, $addressType);

    $address = extractAddressPayload($data, $prefix);
    if (!addressHasAnyValue($address)) {
        return;
    }

    $stmt = $conn->prepare(
        'INSERT INTO learner_addresses (
            learner_id, address_type,
            house_no, street_name, subdivision, zip_code,
            province_id, city_municipality_id, barangay_id,
            country_name
        ) VALUES (
            :learner_id, :address_type,
            :house_no, :street_name, :subdivision, :zip_code,
            :province_id, :city_municipality_id, :barangay_id,
            :country_name
        )'
    );

    $stmt->bindValue(':learner_id', $learnerId, PDO::PARAM_INT);
    $stmt->bindValue(':address_type', $addressType);
    $stmt->bindValue(':house_no', $address['house_no']);
    $stmt->bindValue(':street_name', $address['street_name']);
    $stmt->bindValue(':subdivision', $address['subdivision']);
    $stmt->bindValue(':zip_code', $address['zip_code']);
    $stmt->bindValue(':province_id', $address['province_id'], $address['province_id'] === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
    $stmt->bindValue(':city_municipality_id', $address['city_municipality_id'], $address['city_municipality_id'] === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
    $stmt->bindValue(':barangay_id', $address['barangay_id'], $address['barangay_id'] === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
    $stmt->bindValue(':country_name', $address['country_name'] ?? 'Philippines');
    $stmt->execute();
}

function extractAddressPayload(array $data, string $prefix): array {
    $read = function (string $key) use ($data, $prefix) {
        $k = $prefix . $key;
        if (!array_key_exists($k, $data)) return null;
        $v = $data[$k];
        if ($v === '') return null;
        if (is_string($v)) {
            $t = trim($v);
            return $t === '' ? null : $t;
        }
        return $v;
    };

    $toInt = function ($v): ?int {
        if ($v === null || $v === '') return null;
        $n = (int)$v;
        return $n > 0 ? $n : null;
    };

    return [
        'house_no' => $read('house_no'),
        'street_name' => ($read('street_name') ?? $read('street')),
        'subdivision' => $read('subdivision'),
        'zip_code' => $read('zip_code'),
        'province_id' => $toInt($read('province_id')),
        'city_municipality_id' => $toInt($read('city_municipality_id')),
        'barangay_id' => $toInt($read('barangay_id')),
        'country_name' => $read('country_name') ?? 'Philippines'
    ];
}

function addressHasAnyValue(array $address): bool {
    foreach ($address as $k => $v) {
        if ($k === 'country_name') continue;
        if ($v !== null && $v !== '') return true;
    }
    return false;
}
?>
