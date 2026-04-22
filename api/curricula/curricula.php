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

$operation = $_GET['operation'] ?? '';
$session = auth_enforce_roles($operation, ['admin', 'teacher', 'registrar'], ['admin']);
try {
    switch ($operation) {
        case 'getAllCurricula':           getAllCurricula($conn); break;
        case 'getCurriculumById':         getCurriculumById($conn); break;
        case 'getCurriculaForSchoolYear': getCurriculaForSchoolYear($conn); break;
        case 'getPrimaryCurriculumForSchoolYear': getPrimaryCurriculumForSchoolYear($conn); break;
        case 'createCurriculum':          createCurriculum($conn); break;
        case 'updateCurriculum':          updateCurriculum($conn); break;
        case 'deleteCurriculum':          deleteCurriculum($conn); break;
        // Sub-table: curriculum_subjects
        case 'getCurriculumSubjects':     getCurriculumSubjects($conn); break;
        case 'saveCurriculumSubjects':    saveCurriculumSubjects($conn); break;
        // Sub-table: curriculum_grade_levels
        case 'getCurriculumGradeLevels':  getCurriculumGradeLevels($conn); break;
        case 'saveCurriculumGradeLevels': saveCurriculumGradeLevels($conn); break;
        // Sub-table: curriculum_grading_components
        case 'getGradingComponents':      getGradingComponents($conn); break;
        case 'saveGradingComponents':     saveGradingComponents($conn); break;
        // Sub-table: curriculum_passing_marks
        case 'getPassingMarks':           getPassingMarks($conn); break;
        case 'savePassingMarks':          savePassingMarks($conn); break;
        // Sub-table: curriculum_school_year_map
        case 'getSchoolYearMap':          getSchoolYearMap($conn); break;
        case 'saveSchoolYearMap':         saveSchoolYearMap($conn); break;
        default: respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

// ─── Curricula CRUD ───────────────────────────────────────────────

function getAllCurricula(PDO $conn): void {
    $sql = "SELECT curriculum_id, curriculum_code, curriculum_name, description,
                   effective_from, effective_until, is_active, created_at
            FROM curricula
            WHERE is_deleted = 0
            ORDER BY effective_from DESC, curriculum_id DESC";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function getCurriculumById(PDO $conn): void {
    $id = (int)($_GET['curriculum_id'] ?? 0);
    if (!$id) { respond(['success' => false, 'message' => 'curriculum_id required'], 422); }

    $stmt = $conn->prepare("SELECT * FROM curricula WHERE curriculum_id = :id AND is_deleted = 0 LIMIT 1");
    $stmt->bindValue(':id', $id, PDO::PARAM_INT);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$row) { respond(['success' => false, 'message' => 'Curriculum not found'], 404); }
    respond(['success' => true, 'data' => $row]);
}

function getPrimaryCurriculumForSchoolYear(PDO $conn): void {
        $schoolYearId = (int)($_GET['school_year_id'] ?? 0);
        if (!$schoolYearId) { respond(['success' => false, 'message' => 'school_year_id required'], 422); }

        $stmt = $conn->prepare(
                "SELECT c.curriculum_id, c.curriculum_code, c.curriculum_name, c.effective_from, c.effective_until, c.is_active
                 FROM curriculum_school_year_map m
                 JOIN curricula c ON c.curriculum_id = m.curriculum_id
                 WHERE m.school_year_id = :sid
                     AND m.is_deleted = 0
                     AND m.is_primary = 1
                     AND c.is_deleted = 0
                 ORDER BY c.is_active DESC, c.effective_from DESC, c.curriculum_id DESC
                 LIMIT 1"
        );
        $stmt->bindValue(':sid', $schoolYearId, PDO::PARAM_INT);
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        respond(['success' => true, 'data' => $row ?: null]);
}

function getCurriculaForSchoolYear(PDO $conn): void {
    $schoolYearId = (int)($_GET['school_year_id'] ?? 0);
    if (!$schoolYearId) {
        respond(['success' => false, 'message' => 'school_year_id required'], 422);
    }

    $gradeLevelId = (int)($_GET['grade_level_id'] ?? 0);

    $sql =
        "SELECT c.curriculum_id, c.curriculum_code, c.curriculum_name, c.effective_from, c.effective_until, c.is_active,
                m.is_primary
         FROM curriculum_school_year_map m
         JOIN curricula c ON c.curriculum_id = m.curriculum_id
         " . ($gradeLevelId > 0
            ? "JOIN curriculum_grade_levels cgl ON cgl.curriculum_id = c.curriculum_id AND cgl.is_deleted = 0 AND cgl.grade_level_id = :gid\n"
            : "") .
        "WHERE m.school_year_id = :sid
            AND m.is_deleted = 0
            AND c.is_deleted = 0
         ORDER BY m.is_primary DESC, c.is_active DESC, c.effective_from DESC, c.curriculum_id DESC";

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':sid', $schoolYearId, PDO::PARAM_INT);
    if ($gradeLevelId > 0) {
        $stmt->bindValue(':gid', $gradeLevelId, PDO::PARAM_INT);
    }
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function createCurriculum(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['curriculum_code']) || empty($data['curriculum_name']) || empty($data['effective_from'])) {
        respond(['success' => false, 'message' => 'Curriculum code, name, and effective year are required'], 422);
    }

    $stmt = $conn->prepare(
        'INSERT INTO curricula (curriculum_code, curriculum_name, description, effective_from, effective_until, is_active, created_by)
         VALUES (:code, :name, :description, :from, :until, :active, :created_by)'
    );
    $stmt->bindValue(':code',        trim($data['curriculum_code']));
    $stmt->bindValue(':name',        trim($data['curriculum_name']));
    $stmt->bindValue(':description', $data['description'] ?? null);
    $stmt->bindValue(':from',        $data['effective_from']);
    $stmt->bindValue(':until',       $data['effective_until'] ?? null);
    $stmt->bindValue(':active',      isset($data['is_active']) ? (int)$data['is_active'] : 1, PDO::PARAM_INT);
    $stmt->bindValue(':created_by',  $data['created_by'] ?? null, empty($data['created_by']) ? PDO::PARAM_NULL : PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Curriculum created', 'curriculum_id' => $conn->lastInsertId()]);
}

function updateCurriculum(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['curriculum_id']) || empty($data['curriculum_code']) || empty($data['curriculum_name']) || empty($data['effective_from'])) {
        respond(['success' => false, 'message' => 'Curriculum ID, code, name, and effective year are required'], 422);
    }

    $stmt = $conn->prepare(
        'UPDATE curricula
         SET curriculum_code = :code, curriculum_name = :name, description = :description,
             effective_from = :from, effective_until = :until, is_active = :active
         WHERE curriculum_id = :id AND is_deleted = 0'
    );
    $stmt->bindValue(':code',        trim($data['curriculum_code']));
    $stmt->bindValue(':name',        trim($data['curriculum_name']));
    $stmt->bindValue(':description', $data['description'] ?? null);
    $stmt->bindValue(':from',        $data['effective_from']);
    $stmt->bindValue(':until',       $data['effective_until'] ?? null);
    $stmt->bindValue(':active',      isset($data['is_active']) ? (int)$data['is_active'] : 1, PDO::PARAM_INT);
    $stmt->bindValue(':id',          $data['curriculum_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Curriculum updated']);
}

function deleteCurriculum(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['curriculum_id'])) {
        respond(['success' => false, 'message' => 'Curriculum ID is required'], 422);
    }
    $stmt = $conn->prepare('UPDATE curricula SET is_deleted = 1, deleted_at = NOW() WHERE curriculum_id = :id');
    $stmt->bindValue(':id', $data['curriculum_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Curriculum deleted']);
}

// ─── Curriculum Subjects ──────────────────────────────────────────

function getCurriculumSubjects(PDO $conn): void {
    $id = (int)($_GET['curriculum_id'] ?? 0);
    if (!$id) { respond(['success' => false, 'message' => 'curriculum_id required'], 422); }

    $stmt = $conn->prepare(
        "SELECT cs.curriculum_subject_id, cs.curriculum_id, cs.grade_level_id, gl.grade_name,
                cs.subject_id, s.subject_name, cs.is_required, cs.weekly_minutes, cs.sort_order, cs.notes
         FROM curriculum_subjects cs
         LEFT JOIN grade_levels gl ON cs.grade_level_id = gl.grade_level_id
         LEFT JOIN subjects s ON cs.subject_id = s.subject_id
         WHERE cs.curriculum_id = :id AND cs.is_deleted = 0
         ORDER BY cs.grade_level_id, cs.sort_order, cs.curriculum_subject_id"
    );
    $stmt->bindValue(':id', $id, PDO::PARAM_INT);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function saveCurriculumSubjects(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['curriculum_id']) || !isset($data['subjects'])) {
        respond(['success' => false, 'message' => 'curriculum_id and subjects array are required'], 422);
    }
    $curriculumId = (int)$data['curriculum_id'];

    $conn->beginTransaction();
    try {
        $conn->prepare('UPDATE curriculum_subjects SET is_deleted = 1, deleted_at = NOW() WHERE curriculum_id = :id AND is_deleted = 0')
             ->execute([':id' => $curriculumId]);

        $stmt = $conn->prepare(
            'INSERT INTO curriculum_subjects (curriculum_id, grade_level_id, subject_id, is_required, weekly_minutes, sort_order, notes)
             VALUES (:cid, :gl, :sid, :required, :minutes, :sort, :notes)'
        );
        foreach ($data['subjects'] as $row) {
            $stmt->execute([
                ':cid'     => $curriculumId,
                ':gl'      => $row['grade_level_id'],
                ':sid'     => $row['subject_id'],
                ':required' => isset($row['is_required']) ? (int)$row['is_required'] : 1,
                ':minutes' => $row['weekly_minutes'] ?? null,
                ':sort'    => $row['sort_order'] ?? null,
                ':notes'   => $row['notes'] ?? null,
            ]);
        }
        $conn->commit();
        respond(['success' => true, 'message' => 'Curriculum subjects saved']);
    } catch (Exception $e) {
        $conn->rollBack();
        throw $e;
    }
}

// ─── Curriculum Grade Levels ──────────────────────────────────────

function getCurriculumGradeLevels(PDO $conn): void {
    $id = (int)($_GET['curriculum_id'] ?? 0);
    if (!$id) { respond(['success' => false, 'message' => 'curriculum_id required'], 422); }

    $stmt = $conn->prepare(
        "SELECT cgl.cgl_id, cgl.curriculum_id, cgl.grade_level_id, gl.grade_name, cgl.sort_order
         FROM curriculum_grade_levels cgl
         LEFT JOIN grade_levels gl ON cgl.grade_level_id = gl.grade_level_id
         WHERE cgl.curriculum_id = :id AND cgl.is_deleted = 0
         ORDER BY cgl.sort_order, cgl.cgl_id"
    );
    $stmt->bindValue(':id', $id, PDO::PARAM_INT);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function saveCurriculumGradeLevels(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['curriculum_id']) || !isset($data['grade_level_ids'])) {
        respond(['success' => false, 'message' => 'curriculum_id and grade_level_ids are required'], 422);
    }
    $curriculumId = (int)$data['curriculum_id'];

    $conn->beginTransaction();
    try {
        $conn->prepare('UPDATE curriculum_grade_levels SET is_deleted = 1, deleted_at = NOW() WHERE curriculum_id = :id AND is_deleted = 0')
             ->execute([':id' => $curriculumId]);

        $stmt = $conn->prepare('INSERT INTO curriculum_grade_levels (curriculum_id, grade_level_id, sort_order) VALUES (:cid, :gl, :sort)');
        foreach ($data['grade_level_ids'] as $i => $glId) {
            $stmt->execute([':cid' => $curriculumId, ':gl' => (int)$glId, ':sort' => $i + 1]);
        }
        $conn->commit();
        respond(['success' => true, 'message' => 'Grade levels saved']);
    } catch (Exception $e) {
        $conn->rollBack();
        throw $e;
    }
}

// ─── Curriculum Grading Components ───────────────────────────────

function getGradingComponents(PDO $conn): void {
    $id = (int)($_GET['curriculum_id'] ?? 0);
    if (!$id) { respond(['success' => false, 'message' => 'curriculum_id required'], 422); }

    $stmt = $conn->prepare(
        "SELECT cgc.component_id, cgc.curriculum_id, cgc.grade_level_id, gl.grade_name,
                cgc.component_code, cgc.component_name, cgc.weight_percent, cgc.sort_order
         FROM curriculum_grading_components cgc
         LEFT JOIN grade_levels gl ON cgc.grade_level_id = gl.grade_level_id
         WHERE cgc.curriculum_id = :id AND cgc.is_deleted = 0
         ORDER BY cgc.grade_level_id, cgc.sort_order"
    );
    $stmt->bindValue(':id', $id, PDO::PARAM_INT);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function saveGradingComponents(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['curriculum_id']) || !isset($data['components'])) {
        respond(['success' => false, 'message' => 'curriculum_id and components are required'], 422);
    }
    $curriculumId = (int)$data['curriculum_id'];

    $conn->beginTransaction();
    try {
        $conn->prepare('UPDATE curriculum_grading_components SET is_deleted = 1, deleted_at = NOW() WHERE curriculum_id = :id AND is_deleted = 0')
             ->execute([':id' => $curriculumId]);

        $stmt = $conn->prepare(
            'INSERT INTO curriculum_grading_components (curriculum_id, grade_level_id, component_code, component_name, weight_percent, sort_order)
             VALUES (:cid, :gl, :code, :name, :weight, :sort)'
        );
        foreach ($data['components'] as $row) {
            $stmt->execute([
                ':cid'    => $curriculumId,
                ':gl'     => $row['grade_level_id'] ?? null,
                ':code'   => $row['component_code'],
                ':name'   => $row['component_name'],
                ':weight' => $row['weight_percent'],
                ':sort'   => $row['sort_order'] ?? null,
            ]);
        }
        $conn->commit();
        respond(['success' => true, 'message' => 'Grading components saved']);
    } catch (Exception $e) {
        $conn->rollBack();
        throw $e;
    }
}

// ─── Curriculum Passing Marks ─────────────────────────────────────

function getPassingMarks(PDO $conn): void {
    $id = (int)($_GET['curriculum_id'] ?? 0);
    if (!$id) { respond(['success' => false, 'message' => 'curriculum_id required'], 422); }

    $stmt = $conn->prepare(
        "SELECT cpm.passing_mark_id, cpm.curriculum_id, cpm.grade_level_id, gl.grade_name,
                cpm.subject_id, s.subject_name, cpm.passing_mark, cpm.notes
         FROM curriculum_passing_marks cpm
         LEFT JOIN grade_levels gl ON cpm.grade_level_id = gl.grade_level_id
         LEFT JOIN subjects s ON cpm.subject_id = s.subject_id
         WHERE cpm.curriculum_id = :id AND cpm.is_deleted = 0
         ORDER BY cpm.grade_level_id, cpm.subject_id"
    );
    $stmt->bindValue(':id', $id, PDO::PARAM_INT);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function savePassingMarks(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['curriculum_id']) || !isset($data['marks'])) {
        respond(['success' => false, 'message' => 'curriculum_id and marks are required'], 422);
    }
    $curriculumId = (int)$data['curriculum_id'];

    $conn->beginTransaction();
    try {
        $conn->prepare('UPDATE curriculum_passing_marks SET is_deleted = 1, deleted_at = NOW() WHERE curriculum_id = :id AND is_deleted = 0')
             ->execute([':id' => $curriculumId]);

        $stmt = $conn->prepare(
            'INSERT INTO curriculum_passing_marks (curriculum_id, grade_level_id, subject_id, passing_mark, notes)
             VALUES (:cid, :gl, :sid, :mark, :notes)'
        );
        foreach ($data['marks'] as $row) {
            $stmt->execute([
                ':cid'   => $curriculumId,
                ':gl'    => $row['grade_level_id'] ?? null,
                ':sid'   => $row['subject_id'] ?? null,
                ':mark'  => $row['passing_mark'] ?? 60.00,
                ':notes' => $row['notes'] ?? null,
            ]);
        }
        $conn->commit();
        respond(['success' => true, 'message' => 'Passing marks saved']);
    } catch (Exception $e) {
        $conn->rollBack();
        throw $e;
    }
}

// ─── Curriculum School Year Map ───────────────────────────────────

function getSchoolYearMap(PDO $conn): void {
    $id = (int)($_GET['curriculum_id'] ?? 0);
    if (!$id) { respond(['success' => false, 'message' => 'curriculum_id required'], 422); }

    $stmt = $conn->prepare(
        "SELECT csym.map_id, csym.curriculum_id, csym.school_year_id, sy.year_label, csym.is_primary
         FROM curriculum_school_year_map csym
         LEFT JOIN school_years sy ON csym.school_year_id = sy.school_year_id
         WHERE csym.curriculum_id = :id AND csym.is_deleted = 0
         ORDER BY sy.year_start DESC"
    );
    $stmt->bindValue(':id', $id, PDO::PARAM_INT);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function saveSchoolYearMap(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['curriculum_id']) || empty($data['school_year_id'])) {
        respond(['success' => false, 'message' => 'curriculum_id and school_year_id are required'], 422);
    }
    $curriculumId  = (int)$data['curriculum_id'];
    $schoolYearId  = (int)$data['school_year_id'];
    $isPrimary     = isset($data['is_primary']) ? (int)$data['is_primary'] : 1;

    // Upsert: check if mapping already exists
    $check = $conn->prepare('SELECT map_id FROM curriculum_school_year_map WHERE curriculum_id = :cid AND school_year_id = :sid LIMIT 1');
    $check->execute([':cid' => $curriculumId, ':sid' => $schoolYearId]);
    $existing = $check->fetchColumn();

    if ($existing) {
        $conn->prepare('UPDATE curriculum_school_year_map SET is_primary = :p, is_deleted = 0, deleted_at = NULL WHERE map_id = :mid')
             ->execute([':p' => $isPrimary, ':mid' => $existing]);
    } else {
        $conn->prepare('INSERT INTO curriculum_school_year_map (curriculum_id, school_year_id, is_primary) VALUES (:cid, :sid, :p)')
             ->execute([':cid' => $curriculumId, ':sid' => $schoolYearId, ':p' => $isPrimary]);
    }
    respond(['success' => true, 'message' => 'School year map saved']);
}
?>
