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

function getJsonInput(): array {
    $raw = file_get_contents('php://input');
    return $raw ? (json_decode($raw, true) ?: []) : [];
}

function getEmployeeIdForUser(PDO $conn, int $userId): int {
    if ($userId <= 0) {
        respond(['success' => false, 'message' => 'Invalid session user'], 401);
    }
    $stmt = $conn->prepare('SELECT employee_id FROM employees WHERE user_id = :user_id AND is_deleted = 0 LIMIT 1');
    $stmt->bindValue(':user_id', $userId, PDO::PARAM_INT);
    $stmt->execute();
    $eid = (int)($stmt->fetchColumn() ?: 0);
    if ($eid <= 0) {
        respond(['success' => false, 'message' => 'Teacher profile not found for this account'], 403);
    }
    return $eid;
}

$operation = $_GET['operation'] ?? '';
$session = auth_enforce_roles($operation, ['admin', 'teacher'], ['admin']);
try {
    switch ($operation) {
        case 'getAllClassOfferings': getAllClassOfferings($conn, $session); break;
        case 'getClassOfferingsByContext': getClassOfferingsByContext($conn, $session); break;
        case 'getClassOfferingRoster': getClassOfferingRoster($conn, $session); break;
        case 'createClassOffering': createClassOffering($conn); break;
        case 'updateClassOffering': updateClassOffering($conn); break;
        case 'deleteClassOffering': deleteClassOffering($conn); break;
        // Deprecated: request/approval workflow removed (direct encoding only)
        case 'submitAssignmentRequest':
        case 'getAssignmentRequests':
        case 'getAssignmentRequestItems':
        case 'updateAssignmentRequestItem':
        case 'deleteAssignmentRequestItem':
        case 'deleteAssignmentRequest':
        case 'setAssignmentRequestStatus':
            respond([
                'success' => false,
                'message' => 'Assignment request/approval workflow was removed. Encode directly using createClassOffering.',
            ], 410);
            break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function getAllClassOfferings(PDO $conn, array $session): void {
    $includeDeleted = (int)($_GET['include_deleted'] ?? 0) === 1;

    $isTeacher = (($session['role_key'] ?? '') === 'teacher');
    $employeeId = $isTeacher ? getEmployeeIdForUser($conn, (int)($session['user_id'] ?? 0)) : 0;

    // Teachers can only see their own class offerings.
    if ($isTeacher) {
        $includeDeleted = false;
    }

        $sql = "SELECT c.class_id, c.subject_id, s.subject_code, s.subject_name, c.section_id, sec.section_name,
                   c.teacher_id, CONCAT(e.last_name, ', ', e.first_name) AS teacher_name,
                   c.school_year_id, sy.year_label, sy.year_start, sy.year_end,
                     c.is_deleted, c.deleted_at
            FROM class_offerings c
            LEFT JOIN subjects s ON c.subject_id = s.subject_id
            LEFT JOIN sections sec ON c.section_id = sec.section_id
            LEFT JOIN employees e ON c.teacher_id = e.employee_id
            LEFT JOIN school_years sy ON c.school_year_id = sy.school_year_id
            WHERE " . ($includeDeleted ? '1=1' : 'c.is_deleted = 0') .
            ($isTeacher ? " AND c.teacher_id = :teacher_id" : "") .
            "
            ORDER BY c.class_id DESC";
    $stmt = $conn->prepare($sql);
    if ($isTeacher) {
        $stmt->bindValue(':teacher_id', $employeeId, PDO::PARAM_INT);
    }
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function getClassOfferingsByContext(PDO $conn, array $session): void {
    $sectionId = (int)($_GET['section_id'] ?? 0);
    $teacherId = (int)($_GET['teacher_id'] ?? 0);
    $schoolYearId = (int)($_GET['school_year_id'] ?? 0);
    if ($sectionId <= 0 || $teacherId <= 0 || $schoolYearId <= 0) {
        respond(['success' => false, 'message' => 'section_id, teacher_id, and school_year_id are required'], 422);
    }

    if (($session['role_key'] ?? '') === 'teacher') {
        $employeeId = getEmployeeIdForUser($conn, (int)($session['user_id'] ?? 0));
        if ($teacherId !== $employeeId) {
            respond(['success' => false, 'message' => 'Not authorized to view other teachers\' class offerings'], 403);
        }
    }

    $sql = "SELECT c.class_id, c.subject_id, s.subject_code, s.subject_name,
                   c.section_id, sec.section_name,
                   c.teacher_id, CONCAT(e.last_name, ', ', e.first_name) AS teacher_name,
                                     c.school_year_id, sy.year_label
            FROM class_offerings c
            JOIN subjects s ON c.subject_id = s.subject_id
            JOIN sections sec ON c.section_id = sec.section_id
            JOIN employees e ON c.teacher_id = e.employee_id
            JOIN school_years sy ON c.school_year_id = sy.school_year_id
            WHERE c.is_deleted = 0
              AND c.section_id = :section_id
              AND c.teacher_id = :teacher_id
                            AND c.school_year_id = :school_year_id
                        ORDER BY s.subject_name ASC, c.class_id DESC";

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':section_id', $sectionId, PDO::PARAM_INT);
    $stmt->bindValue(':teacher_id', $teacherId, PDO::PARAM_INT);
    $stmt->bindValue(':school_year_id', $schoolYearId, PDO::PARAM_INT);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function getClassOfferingRoster(PDO $conn, array $session): void {
    $classId = (int)($_GET['class_id'] ?? 0);
    if ($classId <= 0) {
        respond(['success' => false, 'message' => 'class_id is required'], 422);
    }

    $stmt = $conn->prepare(
        "SELECT c.class_id, c.subject_id, s.subject_code, s.subject_name,
                c.section_id, sec.section_name,
                c.teacher_id, CONCAT(e.last_name, ', ', e.first_name) AS teacher_name,
                c.school_year_id, sy.year_label,
                c.is_deleted
         FROM class_offerings c
         LEFT JOIN subjects s ON c.subject_id = s.subject_id
         LEFT JOIN sections sec ON c.section_id = sec.section_id
         LEFT JOIN employees e ON c.teacher_id = e.employee_id
         LEFT JOIN school_years sy ON c.school_year_id = sy.school_year_id
         WHERE c.class_id = :class_id
         LIMIT 1"
    );
    $stmt->bindValue(':class_id', $classId, PDO::PARAM_INT);
    $stmt->execute();
    $offering = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$offering) {
        respond(['success' => false, 'message' => 'Class offering not found'], 404);
    }

    // Teachers can only view rosters for their own offerings.
    if (($session['role_key'] ?? '') === 'teacher') {
        $employeeId = getEmployeeIdForUser($conn, (int)($session['user_id'] ?? 0));
        if ((int)($offering['teacher_id'] ?? 0) !== $employeeId) {
            respond(['success' => false, 'message' => 'Not authorized to view this class offering roster'], 403);
        }
    }

    $sectionId = (int)($offering['section_id'] ?? 0);
    $schoolYearId = (int)($offering['school_year_id'] ?? 0);
    if ($sectionId <= 0 || $schoolYearId <= 0) {
        respond(['success' => true, 'offering' => $offering, 'roster' => []]);
    }

    $rosterStmt = $conn->prepare(
        "SELECT e.enrollment_id,
                e.learner_id,
                l.lrn,
                CONCAT(l.last_name, ', ', l.first_name) AS learner_name,
                e.enrollment_status
         FROM enrollments e
         JOIN learners l ON e.learner_id = l.learner_id
         WHERE e.is_deleted = 0
           AND e.section_id = :section_id
           AND e.school_year_id = :school_year_id
           AND (e.enrollment_status = 'Enrolled' OR e.enrollment_status IS NULL)
         ORDER BY l.last_name, l.first_name, e.enrollment_id DESC"
    );
    $rosterStmt->bindValue(':section_id', $sectionId, PDO::PARAM_INT);
    $rosterStmt->bindValue(':school_year_id', $schoolYearId, PDO::PARAM_INT);
    $rosterStmt->execute();
    $roster = $rosterStmt->fetchAll(PDO::FETCH_ASSOC);

    respond([
        'success' => true,
        'offering' => $offering,
        'roster' => $roster,
    ]);
}

function classOfferingHasDependencies(PDO $conn, int $classId): bool {
    $checks = [
        ['table' => 'grades', 'where' => 'class_id = :class_id AND is_deleted = 0'],
        ['table' => 'final_grades', 'where' => 'class_id = :class_id AND is_deleted = 0'],
        ['table' => 'class_schedules', 'where' => 'class_id = :class_id AND is_deleted = 0'],
    ];

    foreach ($checks as $c) {
        $stmt = $conn->prepare('SELECT COUNT(*) FROM ' . $c['table'] . ' WHERE ' . $c['where'] . ' LIMIT 1');
        $stmt->bindValue(':class_id', $classId, PDO::PARAM_INT);
        $stmt->execute();
        if ((int)$stmt->fetchColumn() > 0) {
            return true;
        }
    }
    return false;
}

function createClassOffering(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['subject_id']) || empty($data['section_id']) || empty($data['teacher_id']) || empty($data['school_year_id'])) {
        respond(['success' => false, 'message' => 'Subject, section, teacher, and school year are required'], 422);
    }

    // Validate: section must belong to the same school year as the class offering.
    $check = $conn->prepare('SELECT school_year_id FROM sections WHERE section_id = :section_id AND is_deleted = 0');
    $check->bindValue(':section_id', (int)$data['section_id'], PDO::PARAM_INT);
    $check->execute();
    $secSy = $check->fetchColumn();
    if (!$secSy) {
        respond(['success' => false, 'message' => 'Invalid section_id'], 422);
    }
    if ((int)$secSy !== (int)$data['school_year_id']) {
        respond(['success' => false, 'message' => 'school_year_id must match the section\'s school_year_id'], 422);
    }

    // Prevent duplicates (same subject + section + school year)
    // IMPORTANT: class_offerings has a UNIQUE KEY across these columns, so if a record exists but is soft-deleted,
    // we must restore it instead of trying to insert (which would fail with 23000).
    $dup = $conn->prepare(
                                'SELECT class_id, teacher_id, is_deleted
         FROM class_offerings
         WHERE subject_id = :subject_id
           AND section_id = :section_id
           AND school_year_id = :school_year_id
         LIMIT 1'
    );
    $dup->bindValue(':subject_id', (int)$data['subject_id'], PDO::PARAM_INT);
    $dup->bindValue(':section_id', (int)$data['section_id'], PDO::PARAM_INT);
    $dup->bindValue(':school_year_id', (int)$data['school_year_id'], PDO::PARAM_INT);
    $dup->execute();
    $existing = $dup->fetch(PDO::FETCH_ASSOC);
    if ($existing) {
        $existingId = (int)($existing['class_id'] ?? 0);
        $existingTeacherId = (int)($existing['teacher_id'] ?? 0);
        $isDeleted = (int)($existing['is_deleted'] ?? 0) === 1;

        if (!$isDeleted) {
            if ($existingTeacherId !== (int)$data['teacher_id']) {
                respond(['success' => false, 'message' => 'Subject is already assigned to another teacher for this section and school year'], 409);
            }
            respond(['success' => true, 'message' => 'Class offering already exists', 'class_id' => $existingId]);
        }

        // Restore soft-deleted record (required because of UNIQUE KEY).
        $restore = $conn->prepare('UPDATE class_offerings
                                  SET is_deleted = 0,
                                      deleted_at = NULL,
                                      teacher_id = :teacher_id
                                  WHERE class_id = :class_id');
        $restore->bindValue(':class_id', $existingId, PDO::PARAM_INT);
        $restore->bindValue(':teacher_id', (int)$data['teacher_id'], PDO::PARAM_INT);
        $restore->execute();

        respond([
            'success' => true,
            'message' => 'Class offering restored (was removed)',
            'class_id' => $existingId
        ]);
    }

    $stmt = $conn->prepare('INSERT INTO class_offerings (subject_id, section_id, teacher_id, school_year_id) VALUES (:subject_id, :section_id, :teacher_id, :school_year_id)');
    $stmt->bindValue(':subject_id', $data['subject_id'], PDO::PARAM_INT);
    $stmt->bindValue(':section_id', $data['section_id'], PDO::PARAM_INT);
    $stmt->bindValue(':teacher_id', $data['teacher_id'], PDO::PARAM_INT);
    $stmt->bindValue(':school_year_id', $data['school_year_id'], PDO::PARAM_INT);
    try {
        $stmt->execute();
        respond(['success' => true, 'message' => 'Class offering created', 'class_id' => $conn->lastInsertId()]);
    } catch (PDOException $e) {
        // Race condition fallback if UNIQUE KEY uq_class_offering is hit.
        if ($e->getCode() === '23000') {
            $dup = $conn->prepare(
                                                                'SELECT class_id, teacher_id, is_deleted
                 FROM class_offerings
                 WHERE subject_id = :subject_id
                   AND section_id = :section_id
                   AND school_year_id = :school_year_id
                 LIMIT 1'
            );
            $dup->bindValue(':subject_id', (int)$data['subject_id'], PDO::PARAM_INT);
            $dup->bindValue(':section_id', (int)$data['section_id'], PDO::PARAM_INT);
            $dup->bindValue(':school_year_id', (int)$data['school_year_id'], PDO::PARAM_INT);
            $dup->execute();
            $existing = $dup->fetch(PDO::FETCH_ASSOC);
            if ($existing) {
                $existingId = (int)($existing['class_id'] ?? 0);
                                $existingTeacherId = (int)($existing['teacher_id'] ?? 0);
                $isDeleted = (int)($existing['is_deleted'] ?? 0) === 1;

                if ($isDeleted) {
                    $restore = $conn->prepare('UPDATE class_offerings
                                              SET is_deleted = 0,
                                                  deleted_at = NULL,
                                                  teacher_id = :teacher_id
                                              WHERE class_id = :class_id');
                    $restore->bindValue(':class_id', $existingId, PDO::PARAM_INT);
                    $restore->bindValue(':teacher_id', (int)$data['teacher_id'], PDO::PARAM_INT);
                    $restore->execute();
                    respond([
                        'success' => true,
                        'message' => 'Class offering restored (was removed)',
                        'class_id' => $existingId
                    ]);
                }

                if ($existingTeacherId !== (int)$data['teacher_id']) {
                    respond(['success' => false, 'message' => 'Subject is already assigned to another teacher for this section and school year'], 409);
                }
                respond(['success' => true, 'message' => 'Class offering already exists', 'class_id' => $existingId]);
            }
        }
        throw $e;
    }
}

function updateClassOffering(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['class_id']) || empty($data['subject_id']) || empty($data['section_id']) || empty($data['teacher_id']) || empty($data['school_year_id'])) {
        respond(['success' => false, 'message' => 'Class ID, subject, section, teacher, and school year are required'], 422);
    }

    $check = $conn->prepare('SELECT school_year_id FROM sections WHERE section_id = :section_id AND is_deleted = 0');
    $check->bindValue(':section_id', (int)$data['section_id'], PDO::PARAM_INT);
    $check->execute();
    $secSy = $check->fetchColumn();
    if (!$secSy) {
        respond(['success' => false, 'message' => 'Invalid section_id'], 422);
    }
    if ((int)$secSy !== (int)$data['school_year_id']) {
        respond(['success' => false, 'message' => 'school_year_id must match the section\'s school_year_id'], 422);
    }

        // Prevent duplicates when updating (same subject + section + school year)
    $dup = $conn->prepare(
        'SELECT class_id
         FROM class_offerings
         WHERE subject_id = :subject_id
           AND section_id = :section_id
           AND school_year_id = :school_year_id
           AND is_deleted = 0
           AND class_id <> :class_id
         LIMIT 1'
    );
    $dup->bindValue(':subject_id', (int)$data['subject_id'], PDO::PARAM_INT);
    $dup->bindValue(':section_id', (int)$data['section_id'], PDO::PARAM_INT);
    $dup->bindValue(':school_year_id', (int)$data['school_year_id'], PDO::PARAM_INT);
    $dup->bindValue(':class_id', (int)$data['class_id'], PDO::PARAM_INT);
    $dup->execute();
    $existingId = $dup->fetchColumn();
    if ($existingId) {
        respond(['success' => false, 'message' => 'Another identical class offering already exists'], 409);
    }

    $stmt = $conn->prepare('UPDATE class_offerings SET subject_id = :subject_id, section_id = :section_id, teacher_id = :teacher_id, school_year_id = :school_year_id WHERE class_id = :class_id');
    $stmt->bindValue(':subject_id', $data['subject_id'], PDO::PARAM_INT);
    $stmt->bindValue(':section_id', $data['section_id'], PDO::PARAM_INT);
    $stmt->bindValue(':teacher_id', $data['teacher_id'], PDO::PARAM_INT);
    $stmt->bindValue(':school_year_id', $data['school_year_id'], PDO::PARAM_INT);
    $stmt->bindValue(':class_id', $data['class_id'], PDO::PARAM_INT);
    try {
        $stmt->execute();
    } catch (PDOException $e) {
        if ($e->getCode() === '23000') {
            respond(['success' => false, 'message' => 'Another identical class offering already exists'], 409);
        }
        throw $e;
    }
    respond(['success' => true, 'message' => 'Class offering updated']);
}

function deleteClassOffering(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['class_id'])) {
        respond(['success' => false, 'message' => 'Class ID is required'], 422);
    }
    $classId = (int)$data['class_id'];

    if (classOfferingHasDependencies($conn, $classId)) {
        respond(['success' => false, 'message' => 'Cannot remove this class offering because it already has related records (grades/final grades/schedules).'], 409);
    }

    $stmt = $conn->prepare('UPDATE class_offerings SET is_deleted = 1, deleted_at = NOW() WHERE class_id = :class_id');
    $stmt->bindValue(':class_id', $classId, PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Class offering deleted']);
}

function ensureAssignmentRequestTables(PDO $conn): void {
    $conn->exec(
        'CREATE TABLE IF NOT EXISTS class_offering_assignment_requests (
            request_id INT AUTO_INCREMENT PRIMARY KEY,
            section_id INT NOT NULL,
            school_year_id INT NOT NULL,
            requested_by_user_id INT NOT NULL,
            status ENUM("Pending","Approved","Rejected") NOT NULL DEFAULT "Pending",
            note VARCHAR(255) NULL,
            reviewed_by_user_id INT NULL,
            reviewed_at DATETIME NULL,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_coar_section_sy (section_id, school_year_id),
            INDEX idx_coar_status (status)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci'
    );

    $conn->exec(
        'CREATE TABLE IF NOT EXISTS class_offering_assignment_request_items (
            request_item_id INT AUTO_INCREMENT PRIMARY KEY,
            request_id INT NOT NULL,
            subject_id INT NOT NULL,
            teacher_id INT NOT NULL,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY uq_coari_request_subject (request_id, subject_id),
            INDEX idx_coari_request (request_id),
            INDEX idx_coari_subject_teacher (subject_id, teacher_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci'
    );
}

function submitAssignmentRequest(PDO $conn, array $session): void {
    $data = getJsonInput();
    $sectionId = (int)($data['section_id'] ?? 0);
    $schoolYearId = (int)($data['school_year_id'] ?? 0);
    $items = $data['items'] ?? [];

    if ($sectionId <= 0 || $schoolYearId <= 0 || !is_array($items) || count($items) === 0) {
        respond(['success' => false, 'message' => 'section_id, school_year_id, and at least one item are required'], 422);
    }

    $secStmt = $conn->prepare('SELECT school_year_id FROM sections WHERE section_id = :sid AND is_deleted = 0 LIMIT 1');
    $secStmt->bindValue(':sid', $sectionId, PDO::PARAM_INT);
    $secStmt->execute();
    $secSy = (int)($secStmt->fetchColumn() ?: 0);
    if ($secSy <= 0) {
        respond(['success' => false, 'message' => 'Invalid section'], 422);
    }
    if ($secSy !== $schoolYearId) {
        respond(['success' => false, 'message' => 'school_year_id must match selected section school year'], 422);
    }

    $seenSubjects = [];
    foreach ($items as $it) {
        $subjectId = (int)($it['subject_id'] ?? 0);
        $teacherId = (int)($it['teacher_id'] ?? 0);
        if ($subjectId <= 0 || $teacherId <= 0) {
            respond(['success' => false, 'message' => 'Each item must include valid subject_id and teacher_id'], 422);
        }
        if (isset($seenSubjects[$subjectId])) {
            respond(['success' => false, 'message' => 'Duplicate subject in pending queue is not allowed'], 422);
        }
        $seenSubjects[$subjectId] = true;
    }

    ensureAssignmentRequestTables($conn);

    $conn->beginTransaction();
    try {
        $reqStmt = $conn->prepare(
            'INSERT INTO class_offering_assignment_requests (section_id, school_year_id, requested_by_user_id, status)
             VALUES (:section_id, :school_year_id, :requested_by_user_id, "Pending")'
        );
        $reqStmt->bindValue(':section_id', $sectionId, PDO::PARAM_INT);
        $reqStmt->bindValue(':school_year_id', $schoolYearId, PDO::PARAM_INT);
        $reqStmt->bindValue(':requested_by_user_id', (int)($session['user_id'] ?? 0), PDO::PARAM_INT);
        $reqStmt->execute();
        $requestId = (int)$conn->lastInsertId();

        $itemStmt = $conn->prepare(
            'INSERT INTO class_offering_assignment_request_items (request_id, subject_id, teacher_id)
             VALUES (:request_id, :subject_id, :teacher_id)'
        );

        foreach ($items as $it) {
            $itemStmt->bindValue(':request_id', $requestId, PDO::PARAM_INT);
            $itemStmt->bindValue(':subject_id', (int)$it['subject_id'], PDO::PARAM_INT);
            $itemStmt->bindValue(':teacher_id', (int)$it['teacher_id'], PDO::PARAM_INT);
            $itemStmt->execute();
        }

        $conn->commit();
        respond([
            'success' => true,
            'message' => 'Assignment request submitted and marked as Pending approval',
            'request_id' => $requestId,
            'status' => 'Pending'
        ]);
    } catch (Throwable $e) {
        if ($conn->inTransaction()) $conn->rollBack();
        throw $e;
    }
}

function getAssignmentRequestById(PDO $conn, int $requestId): ?array {
    $stmt = $conn->prepare('SELECT request_id, section_id, school_year_id, requested_by_user_id, status FROM class_offering_assignment_requests WHERE request_id = :rid LIMIT 1');
    $stmt->bindValue(':rid', $requestId, PDO::PARAM_INT);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

function canManageAssignmentRequest(array $session, array $request): bool {
    if (auth_is_admin($session)) return true;
    return (int)($request['requested_by_user_id'] ?? 0) === (int)($session['user_id'] ?? 0);
}

function getAssignmentRequests(PDO $conn, array $session): void {
    ensureAssignmentRequestTables($conn);

    $schoolYearId = (int)($_GET['school_year_id'] ?? 0);
    $sectionId = (int)($_GET['section_id'] ?? 0);
    $status = trim((string)($_GET['status'] ?? ''));

    $where = ['1=1'];
    $params = [];
    if ($schoolYearId > 0) {
        $where[] = 'r.school_year_id = :school_year_id';
        $params[':school_year_id'] = [$schoolYearId, PDO::PARAM_INT];
    }
    if ($sectionId > 0) {
        $where[] = 'r.section_id = :section_id';
        $params[':section_id'] = [$sectionId, PDO::PARAM_INT];
    }
    if ($status !== '') {
        $where[] = 'r.status = :status';
        $params[':status'] = [$status, PDO::PARAM_STR];
    }
    if (!auth_is_admin($session)) {
        $where[] = 'r.requested_by_user_id = :uid';
        $params[':uid'] = [(int)$session['user_id'], PDO::PARAM_INT];
    }

    $sql = 'SELECT r.request_id, r.section_id, sec.section_name, r.school_year_id, sy.year_label,
                   r.requested_by_user_id,
                   COALESCE(NULLIF(CONCAT(emp.last_name, ", ", emp.first_name), ", "), u.username, CONCAT("User #", r.requested_by_user_id)) AS requested_by,
                   r.status, r.created_at,
                   (SELECT COUNT(*) FROM class_offering_assignment_request_items i WHERE i.request_id = r.request_id) AS items_count
            FROM class_offering_assignment_requests r
            LEFT JOIN sections sec ON sec.section_id = r.section_id
            LEFT JOIN school_years sy ON sy.school_year_id = r.school_year_id
            LEFT JOIN users u ON u.user_id = r.requested_by_user_id
            LEFT JOIN employees emp ON emp.user_id = r.requested_by_user_id AND emp.is_deleted = 0
            WHERE ' . implode(' AND ', $where) . '
            ORDER BY r.request_id DESC';

    $stmt = $conn->prepare($sql);
    foreach ($params as $k => $meta) {
        $stmt->bindValue($k, $meta[0], $meta[1]);
    }
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    respond(['success' => true, 'data' => $rows]);
}

function getAssignmentRequestItems(PDO $conn, array $session): void {
    ensureAssignmentRequestTables($conn);

    $requestId = (int)($_GET['request_id'] ?? 0);
    if ($requestId <= 0) respond(['success' => false, 'message' => 'request_id is required'], 422);

    $request = getAssignmentRequestById($conn, $requestId);
    if (!$request) respond(['success' => false, 'message' => 'Request not found'], 404);
    if (!canManageAssignmentRequest($session, $request)) auth_abort(403, 'Not authorized for this request');

    $sql = 'SELECT i.request_item_id, i.request_id, i.subject_id, s.subject_name, s.subject_code,
                   i.teacher_id, CONCAT(e.last_name, ", ", e.first_name) AS teacher_name
            FROM class_offering_assignment_request_items i
            LEFT JOIN subjects s ON s.subject_id = i.subject_id
            LEFT JOIN employees e ON e.employee_id = i.teacher_id
            WHERE i.request_id = :request_id
            ORDER BY s.subject_name ASC, i.request_item_id ASC';
    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':request_id', $requestId, PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'data' => $stmt->fetchAll(PDO::FETCH_ASSOC), 'request' => $request]);
}

function updateAssignmentRequestItem(PDO $conn, array $session): void {
    ensureAssignmentRequestTables($conn);
    $data = getJsonInput();
    $requestItemId = (int)($data['request_item_id'] ?? 0);
    $subjectId = (int)($data['subject_id'] ?? 0);
    $teacherId = (int)($data['teacher_id'] ?? 0);
    if ($requestItemId <= 0 || $subjectId <= 0 || $teacherId <= 0) {
        respond(['success' => false, 'message' => 'request_item_id, subject_id, and teacher_id are required'], 422);
    }

    $itemStmt = $conn->prepare('SELECT request_id FROM class_offering_assignment_request_items WHERE request_item_id = :id LIMIT 1');
    $itemStmt->bindValue(':id', $requestItemId, PDO::PARAM_INT);
    $itemStmt->execute();
    $requestId = (int)($itemStmt->fetchColumn() ?: 0);
    if ($requestId <= 0) respond(['success' => false, 'message' => 'Request item not found'], 404);

    $request = getAssignmentRequestById($conn, $requestId);
    if (!$request) respond(['success' => false, 'message' => 'Request not found'], 404);
    if (!canManageAssignmentRequest($session, $request)) auth_abort(403, 'Not authorized for this request');
    if (strtolower((string)$request['status']) !== 'pending') {
        respond(['success' => false, 'message' => 'Only pending requests can be edited'], 409);
    }

    $dup = $conn->prepare('SELECT request_item_id FROM class_offering_assignment_request_items WHERE request_id = :rid AND subject_id = :sid AND request_item_id <> :iid LIMIT 1');
    $dup->bindValue(':rid', $requestId, PDO::PARAM_INT);
    $dup->bindValue(':sid', $subjectId, PDO::PARAM_INT);
    $dup->bindValue(':iid', $requestItemId, PDO::PARAM_INT);
    $dup->execute();
    if ($dup->fetchColumn()) {
        respond(['success' => false, 'message' => 'Duplicate subject in this request is not allowed'], 409);
    }

    $stmt = $conn->prepare('UPDATE class_offering_assignment_request_items SET subject_id = :subject_id, teacher_id = :teacher_id WHERE request_item_id = :request_item_id');
    $stmt->bindValue(':subject_id', $subjectId, PDO::PARAM_INT);
    $stmt->bindValue(':teacher_id', $teacherId, PDO::PARAM_INT);
    $stmt->bindValue(':request_item_id', $requestItemId, PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Request item updated']);
}

function deleteAssignmentRequestItem(PDO $conn, array $session): void {
    ensureAssignmentRequestTables($conn);
    $data = getJsonInput();
    $requestItemId = (int)($data['request_item_id'] ?? 0);
    if ($requestItemId <= 0) respond(['success' => false, 'message' => 'request_item_id is required'], 422);

    $itemStmt = $conn->prepare('SELECT request_id FROM class_offering_assignment_request_items WHERE request_item_id = :id LIMIT 1');
    $itemStmt->bindValue(':id', $requestItemId, PDO::PARAM_INT);
    $itemStmt->execute();
    $requestId = (int)($itemStmt->fetchColumn() ?: 0);
    if ($requestId <= 0) respond(['success' => false, 'message' => 'Request item not found'], 404);

    $request = getAssignmentRequestById($conn, $requestId);
    if (!$request) respond(['success' => false, 'message' => 'Request not found'], 404);
    if (!canManageAssignmentRequest($session, $request)) auth_abort(403, 'Not authorized for this request');
    if (strtolower((string)$request['status']) !== 'pending') {
        respond(['success' => false, 'message' => 'Only pending requests can be edited'], 409);
    }

    $stmt = $conn->prepare('DELETE FROM class_offering_assignment_request_items WHERE request_item_id = :id');
    $stmt->bindValue(':id', $requestItemId, PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Request item deleted']);
}

function deleteAssignmentRequest(PDO $conn, array $session): void {
    ensureAssignmentRequestTables($conn);
    $data = getJsonInput();
    $requestId = (int)($data['request_id'] ?? 0);
    if ($requestId <= 0) respond(['success' => false, 'message' => 'request_id is required'], 422);

    $request = getAssignmentRequestById($conn, $requestId);
    if (!$request) respond(['success' => false, 'message' => 'Request not found'], 404);
    if (!canManageAssignmentRequest($session, $request)) auth_abort(403, 'Not authorized for this request');
    if (strtolower((string)$request['status']) !== 'pending') {
        respond(['success' => false, 'message' => 'Only pending requests can be deleted'], 409);
    }

    $conn->beginTransaction();
    try {
        $stmtItems = $conn->prepare('DELETE FROM class_offering_assignment_request_items WHERE request_id = :rid');
        $stmtItems->bindValue(':rid', $requestId, PDO::PARAM_INT);
        $stmtItems->execute();

        $stmtReq = $conn->prepare('DELETE FROM class_offering_assignment_requests WHERE request_id = :rid');
        $stmtReq->bindValue(':rid', $requestId, PDO::PARAM_INT);
        $stmtReq->execute();

        $conn->commit();
        respond(['success' => true, 'message' => 'Request deleted']);
    } catch (Throwable $e) {
        if ($conn->inTransaction()) $conn->rollBack();
        throw $e;
    }
}

function setAssignmentRequestStatus(PDO $conn, array $session): void {
    ensureAssignmentRequestTables($conn);
    if (!auth_is_admin($session)) {
        auth_abort(403, 'Only admin can update request status');
    }

    $data = getJsonInput();
    $requestId = (int)($data['request_id'] ?? 0);
    $status = trim((string)($data['status'] ?? ''));
    $allowed = ['Pending', 'Approved', 'Rejected'];
    if ($requestId <= 0 || !in_array($status, $allowed, true)) {
        respond(['success' => false, 'message' => 'request_id and valid status are required'], 422);
    }

    $request = getAssignmentRequestById($conn, $requestId);
    if (!$request) respond(['success' => false, 'message' => 'Request not found'], 404);

    $stmt = $conn->prepare('UPDATE class_offering_assignment_requests SET status = :status, reviewed_by_user_id = :uid, reviewed_at = NOW() WHERE request_id = :rid');
    $stmt->bindValue(':status', $status, PDO::PARAM_STR);
    $stmt->bindValue(':uid', (int)$session['user_id'], PDO::PARAM_INT);
    $stmt->bindValue(':rid', $requestId, PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Request status updated']);
}
?>
