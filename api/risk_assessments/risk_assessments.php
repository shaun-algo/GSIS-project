<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/../utils/cors.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { exit(0); }

require_once __DIR__ . '/../database/connection.php';
require_once __DIR__ . '/../utils/auth.php';
require_once __DIR__ . '/../utils/notifications.php';

function respond($payload, int $code = 200): void {
    http_response_code($code);
    echo json_encode($payload);
    exit;
}

function getJsonInput(): array {
    $raw = file_get_contents('php://input');
    return $raw ? (json_decode($raw, true) ?: []) : [];
}

function getIntParam(string $name): ?int {
    $value = $_GET[$name] ?? null;
    if ($value === null || $value === '') return null;
    if (!is_numeric($value)) return null;
    return (int)$value;
}

$operation = $_GET['operation'] ?? '';
$session = auth_enforce_roles($operation, ['admin', 'teacher'], ['admin']);

try {
    switch ($operation) {
        case 'getAllRiskAssessments':
            getAllRiskAssessments($conn);
            break;
        case 'getAtRiskLearners':
            getAtRiskLearners($conn);
            break;
        case 'createRiskAssessment':
            createRiskAssessment($conn);
            break;
        case 'updateRiskAssessment':
            updateRiskAssessment($conn);
            break;
        case 'deleteRiskAssessment':
            deleteRiskAssessment($conn);
            break;
        case 'computeAutomatedAssessments':
            computeAutomatedAssessments($conn, $session);
            break;
        default:
            respond(['success' => false, 'message' => 'Invalid operation'], 400);
    }
} catch (Exception $e) {
    respond(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
}

function canonicalClassOfferingsSql(): string {
    return 'SELECT co_latest.class_id, co_latest.section_id, co_latest.school_year_id, co_latest.subject_id
            FROM class_offerings co_latest
            JOIN (
                SELECT section_id, school_year_id, subject_id, MAX(class_id) AS class_id
                FROM class_offerings
                WHERE is_deleted = 0
                GROUP BY section_id, school_year_id, subject_id
            ) pick ON pick.class_id = co_latest.class_id
            WHERE co_latest.is_deleted = 0';
}

function getAllRiskAssessments(PDO $conn): void {
    $sql = "SELECT ra.risk_assessment_id, ra.enrollment_id, ra.grading_period_id, ra.risk_level_id,
                   ra.assessed_by, ra.assessed_at, ra.notes,
                   l.lrn,
                   CONCAT(l.last_name, ', ', l.first_name,
                       CASE WHEN l.middle_name IS NULL OR l.middle_name = '' THEN '' ELSE CONCAT(' ', l.middle_name) END,
                       CASE WHEN l.name_extension IS NULL OR l.name_extension = '' THEN '' ELSE CONCAT(' ', l.name_extension) END
                   ) AS learner_name,
                   sec.section_name,
                   gl.grade_name,
                   sy.year_label,
                   gp.period_name,
                   rl.risk_name,
                   rl.color_code,
                   u.username AS assessed_by_name
            FROM risk_assessments ra
            JOIN enrollments e ON ra.enrollment_id = e.enrollment_id AND e.is_deleted = 0
            JOIN learners l ON e.learner_id = l.learner_id AND l.is_deleted = 0
            LEFT JOIN sections sec ON sec.section_id = e.section_id AND sec.is_deleted = 0
            LEFT JOIN grade_levels gl ON gl.grade_level_id = e.grade_level_id
            LEFT JOIN school_years sy ON sy.school_year_id = e.school_year_id
            JOIN grading_periods gp ON ra.grading_period_id = gp.grading_period_id AND gp.is_deleted = 0
            JOIN risk_levels rl ON ra.risk_level_id = rl.risk_level_id AND rl.is_deleted = 0
            LEFT JOIN users u ON ra.assessed_by = u.user_id
            WHERE ra.is_deleted = 0
            ORDER BY ra.assessed_at DESC, ra.risk_assessment_id DESC";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    respond($stmt->fetchAll(PDO::FETCH_ASSOC));
}

function getAtRiskLearners(PDO $conn): void {
    $schoolYearId = getIntParam('school_year_id');
    if (!$schoolYearId || $schoolYearId <= 0) {
        $schoolYearId = getActiveSchoolYearId($conn);
    }

    if (!$schoolYearId) {
        respond([
            'success' => true,
            'data' => [
                'records' => [],
                'summary' => ['total_records' => 0, 'critical' => 0, 'high' => 0, 'moderate' => 0, 'low' => 0],
                'school_year_id' => null,
                'period_mode' => 'latest'
            ]
        ]);
    }

    $gradingPeriodId = getIntParam('grading_period_id');
    $riskAssessmentId = getIntParam('risk_assessment_id');
    $gradeLevelId = getIntParam('grade_level_id');
    $sectionId = getIntParam('section_id');
    $includeLow = ((string)($_GET['include_low'] ?? '0') === '1');

    $canonicalSql = canonicalClassOfferingsSql();
    $subjectCountSql =
        'SELECT co.section_id, COUNT(*) AS expected_subject_count
         FROM (' . $canonicalSql . ') co
         WHERE co.school_year_id = :sy_subject
         GROUP BY co.section_id';

    $periodGradesSql =
        'SELECT e.enrollment_id,
                g.grading_period_id,
                ROUND(AVG(g.quarterly_grade), 2) AS period_average,
                MIN(g.quarterly_grade) AS min_quarterly_grade,
                COUNT(g.grade_id) AS encoded_subject_count
         FROM enrollments e
         JOIN (' . $canonicalSql . ') co ON co.section_id = e.section_id
                                       AND co.school_year_id = e.school_year_id
         LEFT JOIN grades g ON g.enrollment_id = e.enrollment_id
                           AND g.class_id = co.class_id
                           AND g.is_deleted = 0
                           AND g.quarterly_grade IS NOT NULL
         WHERE e.is_deleted = 0
           AND e.school_year_id = :sy_period_grades
           AND e.enrollment_status = "Enrolled"
         GROUP BY e.enrollment_id, g.grading_period_id';

    $attendanceSql =
        'SELECT a.enrollment_id,
                a.grading_period_id,
                COUNT(*) AS attendance_records,
                SUM(CASE WHEN a.status = "Absent" THEN 1 ELSE 0 END) AS absent_count
         FROM attendance a
         WHERE a.is_deleted = 0
         GROUP BY a.enrollment_id, a.grading_period_id';

    $indicatorSql =
        'SELECT ri.risk_assessment_id,
                GROUP_CONCAT(
                    CONCAT(
                        ri.indicator_type,
                        CASE
                            WHEN ri.details IS NULL OR ri.details = "" THEN ""
                            ELSE CONCAT(": ", ri.details)
                        END
                    )
                    ORDER BY ri.indicator_id ASC
                    SEPARATOR " | "
                ) AS indicators
         FROM risk_indicators ri
         WHERE ri.is_deleted = 0
         GROUP BY ri.risk_assessment_id';

    $latestJoin = '';
    $where = [
        'ra.is_deleted = 0',
        'e.is_deleted = 0',
        'e.enrollment_status = "Enrolled"',
        'e.school_year_id = :sy_main'
    ];

    if ($riskAssessmentId && $riskAssessmentId > 0) {
        $where[] = 'ra.risk_assessment_id = :risk_assessment_id';
    } elseif ($gradingPeriodId && $gradingPeriodId > 0) {
        $where[] = 'ra.grading_period_id = :gp_filter';
    } else {
        $latestJoin =
            'JOIN (
                SELECT ra2.enrollment_id, MAX(ra2.grading_period_id) AS latest_period_id
                FROM risk_assessments ra2
                JOIN enrollments e2 ON e2.enrollment_id = ra2.enrollment_id
                                   AND e2.is_deleted = 0
                                   AND e2.school_year_id = :sy_latest_enroll
                JOIN grading_periods gp2 ON gp2.grading_period_id = ra2.grading_period_id
                                        AND gp2.is_deleted = 0
                                        AND gp2.school_year_id = :sy_latest_period
                WHERE ra2.is_deleted = 0
                GROUP BY ra2.enrollment_id
             ) latest ON latest.enrollment_id = ra.enrollment_id
                     AND latest.latest_period_id = ra.grading_period_id';
    }

    if ($gradeLevelId && $gradeLevelId > 0) {
        $where[] = 'e.grade_level_id = :grade_level_id';
    }
    if ($sectionId && $sectionId > 0) {
        $where[] = 'e.section_id = :section_id';
    }
    if (!$includeLow) {
        $where[] = 'LOWER(rl.risk_name) <> "low"';
    }

    $sql =
        'SELECT ra.risk_assessment_id,
                ra.enrollment_id,
                ra.grading_period_id,
                ra.risk_level_id,
                ra.assessed_at,
                ra.notes,
                l.lrn,
                CONCAT(l.last_name, ", ", l.first_name,
                    CASE WHEN l.middle_name IS NULL OR l.middle_name = "" THEN "" ELSE CONCAT(" ", l.middle_name) END,
                    CASE WHEN l.name_extension IS NULL OR l.name_extension = "" THEN "" ELSE CONCAT(" ", l.name_extension) END
                ) AS learner_name,
                sec.section_name,
                gl.grade_name,
                sy.year_label,
                gp.period_name,
                rl.risk_name,
                rl.color_code,
                ga.general_average,
                pg.period_average,
                pg.min_quarterly_grade,
                pg.encoded_subject_count,
                sc.expected_subject_count,
                att.attendance_records,
                att.absent_count,
                CASE
                    WHEN att.attendance_records IS NULL OR att.attendance_records = 0 THEN NULL
                    ELSE ROUND((att.absent_count / att.attendance_records) * 100, 2)
                END AS attendance_rate,
                COALESCE(ri.indicators, "") AS indicators
         FROM risk_assessments ra
         JOIN enrollments e ON e.enrollment_id = ra.enrollment_id
         JOIN learners l ON l.learner_id = e.learner_id AND l.is_deleted = 0
         LEFT JOIN sections sec ON sec.section_id = e.section_id AND sec.is_deleted = 0
         LEFT JOIN grade_levels gl ON gl.grade_level_id = e.grade_level_id
         LEFT JOIN school_years sy ON sy.school_year_id = e.school_year_id
         JOIN grading_periods gp ON gp.grading_period_id = ra.grading_period_id AND gp.is_deleted = 0
         JOIN risk_levels rl ON rl.risk_level_id = ra.risk_level_id AND rl.is_deleted = 0
         LEFT JOIN general_averages ga ON ga.enrollment_id = e.enrollment_id
                                      AND ga.school_year_id = e.school_year_id
                                      AND ga.is_deleted = 0
         LEFT JOIN (' . $periodGradesSql . ') pg ON pg.enrollment_id = e.enrollment_id
                                                AND pg.grading_period_id = ra.grading_period_id
         LEFT JOIN (' . $subjectCountSql . ') sc ON sc.section_id = e.section_id
         LEFT JOIN (' . $attendanceSql . ') att ON att.enrollment_id = e.enrollment_id
                                              AND att.grading_period_id = ra.grading_period_id
         LEFT JOIN (' . $indicatorSql . ') ri ON ri.risk_assessment_id = ra.risk_assessment_id
         ' . $latestJoin . '
         WHERE ' . implode(' AND ', $where) . '
         ORDER BY ra.risk_level_id DESC, ra.assessed_at DESC, learner_name ASC';

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':sy_main', $schoolYearId, PDO::PARAM_INT);
    $stmt->bindValue(':sy_period_grades', $schoolYearId, PDO::PARAM_INT);
    $stmt->bindValue(':sy_subject', $schoolYearId, PDO::PARAM_INT);

    if ($riskAssessmentId && $riskAssessmentId > 0) {
        $stmt->bindValue(':risk_assessment_id', $riskAssessmentId, PDO::PARAM_INT);
    } elseif (!$gradingPeriodId || $gradingPeriodId <= 0) {
        $stmt->bindValue(':sy_latest_enroll', $schoolYearId, PDO::PARAM_INT);
        $stmt->bindValue(':sy_latest_period', $schoolYearId, PDO::PARAM_INT);
    } else {
        $stmt->bindValue(':gp_filter', $gradingPeriodId, PDO::PARAM_INT);
    }

    if ($gradeLevelId && $gradeLevelId > 0) {
        $stmt->bindValue(':grade_level_id', $gradeLevelId, PDO::PARAM_INT);
    }
    if ($sectionId && $sectionId > 0) {
        $stmt->bindValue(':section_id', $sectionId, PDO::PARAM_INT);
    }

    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $summary = ['total_records' => 0, 'critical' => 0, 'high' => 0, 'moderate' => 0, 'low' => 0];
    foreach ($rows as $row) {
        $summary['total_records'] += 1;
        $name = strtolower((string)($row['risk_name'] ?? ''));
        if (str_contains($name, 'critical')) $summary['critical'] += 1;
        else if (str_contains($name, 'high')) $summary['high'] += 1;
        else if (str_contains($name, 'moderate')) $summary['moderate'] += 1;
        else $summary['low'] += 1;
    }

    respond([
        'success' => true,
        'data' => [
            'records' => $rows,
            'summary' => $summary,
            'school_year_id' => $schoolYearId,
            'period_mode' => ($gradingPeriodId && $gradingPeriodId > 0) ? 'selected' : 'latest'
        ]
    ]);
}

function createRiskAssessment(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['enrollment_id']) || empty($data['grading_period_id']) || empty($data['risk_level_id'])) {
        respond(['success' => false, 'message' => 'Enrollment, grading period, and risk level are required'], 422);
    }
    $stmt = $conn->prepare('INSERT INTO risk_assessments (enrollment_id, grading_period_id, risk_level_id, assessed_by, notes) VALUES (:enrollment_id, :grading_period_id, :risk_level_id, :assessed_by, :notes)');
    $stmt->bindValue(':enrollment_id', $data['enrollment_id'], PDO::PARAM_INT);
    $stmt->bindValue(':grading_period_id', $data['grading_period_id'], PDO::PARAM_INT);
    $stmt->bindValue(':risk_level_id', $data['risk_level_id'], PDO::PARAM_INT);
    $stmt->bindValue(':assessed_by', $data['assessed_by'] ?? null, $data['assessed_by'] === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
    $stmt->bindValue(':notes', $data['notes'] ?? null);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Risk assessment created', 'risk_assessment_id' => $conn->lastInsertId()]);
}

function updateRiskAssessment(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['risk_assessment_id']) || empty($data['enrollment_id']) || empty($data['grading_period_id']) || empty($data['risk_level_id'])) {
        respond(['success' => false, 'message' => 'Risk assessment ID, enrollment, grading period, and risk level are required'], 422);
    }
    $stmt = $conn->prepare('UPDATE risk_assessments SET enrollment_id = :enrollment_id, grading_period_id = :grading_period_id, risk_level_id = :risk_level_id, assessed_by = :assessed_by, notes = :notes WHERE risk_assessment_id = :risk_assessment_id');
    $stmt->bindValue(':enrollment_id', $data['enrollment_id'], PDO::PARAM_INT);
    $stmt->bindValue(':grading_period_id', $data['grading_period_id'], PDO::PARAM_INT);
    $stmt->bindValue(':risk_level_id', $data['risk_level_id'], PDO::PARAM_INT);
    $stmt->bindValue(':assessed_by', $data['assessed_by'] ?? null, $data['assessed_by'] === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
    $stmt->bindValue(':notes', $data['notes'] ?? null);
    $stmt->bindValue(':risk_assessment_id', $data['risk_assessment_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Risk assessment updated']);
}

function deleteRiskAssessment(PDO $conn): void {
    $data = getJsonInput();
    if (empty($data['risk_assessment_id'])) {
        respond(['success' => false, 'message' => 'Risk assessment ID is required'], 422);
    }
    $stmt = $conn->prepare('UPDATE risk_assessments SET is_deleted = 1, deleted_at = NOW() WHERE risk_assessment_id = :risk_assessment_id');
    $stmt->bindValue(':risk_assessment_id', $data['risk_assessment_id'], PDO::PARAM_INT);
    $stmt->execute();
    respond(['success' => true, 'message' => 'Risk assessment deleted']);
}

function computeAutomatedAssessments(PDO $conn, array $session): void {
    $requestedSchoolYearId = getIntParam('school_year_id');
    $schoolYearId = ($requestedSchoolYearId && $requestedSchoolYearId > 0)
        ? $requestedSchoolYearId
        : getActiveSchoolYearId($conn);

    if (!$schoolYearId) {
        respond(['success' => false, 'message' => 'No target school year found'], 422);
    }

    $userId = (int)($session['user_id'] ?? 0);
    $counts = [
        'quarterly_updated' => 0,
        'final_grades_upserted' => 0,
        'general_averages_upserted' => 0,
        'risk_assessments_upserted' => 0,
        'risk_indicators_upserted' => 0,
        'school_year_id' => $schoolYearId
    ];

    $conn->beginTransaction();
    try {
        $gradeRows = fetchGradesForSchoolYear($conn, $schoolYearId);
        $weightCache = [];

        $hasInitial = gradesHasInitialGrade($conn);
        $updateQuarterlyStmt = $hasInitial
            ? $conn->prepare('UPDATE grades SET initial_grade = :initial_grade, quarterly_grade = :quarterly_grade WHERE grade_id = :grade_id')
            : $conn->prepare('UPDATE grades SET quarterly_grade = :quarterly_grade WHERE grade_id = :grade_id');

        foreach ($gradeRows as $row) {
            $initial = computeInitialGrade($conn, $row, $weightCache);
            $quarterly = transmuteGrade($initial);
            if ($quarterly === null) {
                continue;
            }

            $current = $row['quarterly_grade'];
            $current = is_numeric($current) ? (float)$current : null;
            if ($current === null || abs($current - $quarterly) > 0.01) {
                $params = [
                    ':quarterly_grade' => $quarterly,
                    ':grade_id' => (int)$row['grade_id']
                ];
                if ($hasInitial) {
                    $params[':initial_grade'] = $initial;
                }

                $updateQuarterlyStmt->execute($params);
                $counts['quarterly_updated'] += 1;
            }
        }

        $expectedPeriods = getExpectedPeriodsForSchoolYear($conn, $schoolYearId);
        $finalGrades = computeFinalGrades($conn, $schoolYearId, $expectedPeriods);
        $counts['final_grades_upserted'] = upsertFinalGrades($conn, $finalGrades, $userId);

        $generalAverages = computeGeneralAveragesFromFinalGrades($finalGrades);
        $counts['general_averages_upserted'] = upsertGeneralAverages($conn, $schoolYearId, $generalAverages, $userId);

        $riskResult = computeRiskAssessments($conn, $schoolYearId, $userId, $generalAverages, $finalGrades);
        $counts['risk_assessments_upserted'] = (int)$riskResult['assessments'];
        $counts['risk_indicators_upserted'] = (int)$riskResult['indicators'];

        $conn->commit();
    } catch (Exception $e) {
        if ($conn->inTransaction()) {
            $conn->rollBack();
        }
        throw $e;
    }

    notifyAtRiskLearners($conn, $schoolYearId);

    respond([
        'success' => true,
        'message' => 'Automation completed',
        'data' => $counts
    ]);
}

function getActiveSchoolYearId(PDO $conn): ?int {
    $stmt = $conn->query('SELECT school_year_id FROM school_years WHERE is_deleted = 0 AND is_active = 1 ORDER BY school_year_id DESC LIMIT 1');
    $id = $stmt->fetchColumn();
    return $id ? (int)$id : null;
}

function getExpectedPeriodsForSchoolYear(PDO $conn, int $schoolYearId): int {
    $stmt = $conn->prepare('SELECT COUNT(*) FROM grading_periods WHERE is_deleted = 0 AND school_year_id = :sy');
    $stmt->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
    $stmt->execute();
    $count = (int)$stmt->fetchColumn();
    return max(1, $count);
}

function fetchGradesForSchoolYear(PDO $conn, int $schoolYearId): array {
    $stmt = $conn->prepare(
        "SELECT g.grade_id,
                g.enrollment_id,
                g.class_id,
                g.grading_period_id,
                g.written_works,
                g.performance_tasks,
                g.quarterly_exam,
                g.quarterly_grade,
                e.grade_level_id,
                COALESCE(e.curriculum_id, csm.curriculum_id) AS curriculum_id
         FROM grades g
         JOIN enrollments e ON g.enrollment_id = e.enrollment_id
         LEFT JOIN curriculum_school_year_map csm ON csm.school_year_id = e.school_year_id
                                                 AND csm.is_primary = 1
                                                 AND csm.is_deleted = 0
         WHERE g.is_deleted = 0
           AND e.is_deleted = 0
           AND e.school_year_id = :school_year_id"
    );
    $stmt->execute([':school_year_id' => $schoolYearId]);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

function getWeightsForGradeLevel(PDO $conn, int $curriculumId, int $gradeLevelId, array &$cache): array {
    $cacheKey = $curriculumId . ':' . $gradeLevelId;
    if (isset($cache[$cacheKey])) {
        return $cache[$cacheKey];
    }

    $stmt = $conn->prepare(
        'SELECT component_code, weight_percent
         FROM curriculum_grading_components
         WHERE curriculum_id = :cid
           AND is_deleted = 0
           AND (grade_level_id = :glid OR grade_level_id IS NULL)
         ORDER BY (grade_level_id IS NULL) ASC, sort_order ASC'
    );
    $stmt->bindValue(':cid', $curriculumId, PDO::PARAM_INT);
    $stmt->bindValue(':glid', $gradeLevelId, PDO::PARAM_INT);
    $stmt->execute();

    $weights = ['WW' => null, 'PT' => null, 'QE' => null];
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $code = strtoupper((string)$row['component_code']);
        if (!array_key_exists($code, $weights)) continue;
        if ($weights[$code] === null) {
            $weights[$code] = (float)$row['weight_percent'];
        }
    }

    foreach ($weights as $code => $value) {
        if ($value === null) {
            $weights[$code] = 0.0;
        }
    }

    if (($weights['WW'] + $weights['PT'] + $weights['QE']) <= 0.01) {
        $weights = ['WW' => 30.0, 'PT' => 50.0, 'QE' => 20.0];
    }

    $cache[$cacheKey] = $weights;
    return $weights;
}

function gradesHasInitialGrade(PDO $conn): bool {
    static $cached = null;
    if ($cached !== null) return (bool)$cached;

    try {
        $stmt = $conn->prepare(
            "SELECT 1
             FROM INFORMATION_SCHEMA.COLUMNS
             WHERE TABLE_SCHEMA = DATABASE()
               AND TABLE_NAME = 'grades'
               AND COLUMN_NAME = 'initial_grade'
             LIMIT 1"
        );
        $stmt->execute();
        $cached = (bool)$stmt->fetchColumn();
    } catch (Exception $e) {
        $cached = false;
    }

    return (bool)$cached;
}

function computeInitialGrade(PDO $conn, array $row, array &$weightCache): ?float {
    $ww = $row['written_works'];
    $pt = $row['performance_tasks'];
    $qe = $row['quarterly_exam'];

    if (!is_numeric($ww) || !is_numeric($pt) || !is_numeric($qe)) {
        return null;
    }

    $curriculumId = is_numeric($row['curriculum_id'] ?? null) ? (int)$row['curriculum_id'] : 0;
    $gradeLevelId = is_numeric($row['grade_level_id'] ?? null) ? (int)$row['grade_level_id'] : 0;

    $weights = ['WW' => 30.0, 'PT' => 50.0, 'QE' => 20.0];
    if ($curriculumId > 0 && $gradeLevelId > 0) {
        $weights = getWeightsForGradeLevel($conn, $curriculumId, $gradeLevelId, $weightCache);
    }

    $weighted =
        ((float)$ww * ((float)$weights['WW'] / 100.0)) +
        ((float)$pt * ((float)$weights['PT'] / 100.0)) +
        ((float)$qe * ((float)$weights['QE'] / 100.0));

    return round($weighted, 2);
}

function transmuteGrade(?float $initial): ?float {
    if ($initial === null) return null;
    $g = max(0.0, min(100.0, (float)$initial));

    if ($g <= 60.0) {
        $trans = 60.0 + ($g / 60.0) * 15.0;
    } else {
        $trans = 75.0 + (($g - 60.0) / 40.0) * 25.0;
    }

    return round(max(60.0, min(100.0, $trans)), 2);
}

function computeQuarterlyGrade(PDO $conn, array $row, array &$weightCache): ?float {
    $initial = computeInitialGrade($conn, $row, $weightCache);
    return transmuteGrade($initial);
}

function computeFinalGrades(PDO $conn, int $schoolYearId, int $expectedPeriods): array {
    $canonicalSql = canonicalClassOfferingsSql();

    $stmt = $conn->prepare(
        'SELECT g.enrollment_id,
                g.class_id,
                ROUND(AVG(g.quarterly_grade), 2) AS final_grade,
                COUNT(*) AS graded_periods
         FROM grades g
         JOIN enrollments e ON e.enrollment_id = g.enrollment_id
                           AND e.is_deleted = 0
                           AND e.school_year_id = :sy_enroll
                           AND e.enrollment_status = "Enrolled"
         JOIN (' . $canonicalSql . ') co ON co.class_id = g.class_id
                                        AND co.section_id = e.section_id
                                        AND co.school_year_id = e.school_year_id
         JOIN grading_periods gp ON gp.grading_period_id = g.grading_period_id
                                AND gp.is_deleted = 0
                                AND gp.school_year_id = :sy_period
         WHERE g.is_deleted = 0
           AND g.quarterly_grade IS NOT NULL
         GROUP BY g.enrollment_id, g.class_id
         HAVING graded_periods = :expected_periods'
    );
    $stmt->bindValue(':sy_enroll', $schoolYearId, PDO::PARAM_INT);
    $stmt->bindValue(':sy_period', $schoolYearId, PDO::PARAM_INT);
    $stmt->bindValue(':expected_periods', $expectedPeriods, PDO::PARAM_INT);
    $stmt->execute();

    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    return array_map(static function ($row) {
        return [
            'enrollment_id' => (int)$row['enrollment_id'],
            'class_id' => (int)$row['class_id'],
            'final_grade' => round((float)$row['final_grade'], 2)
        ];
    }, $rows);
}

function upsertFinalGrades(PDO $conn, array $finalGrades, int $userId): int {
    $findStmt = $conn->prepare('SELECT final_grade_id FROM final_grades WHERE enrollment_id = :enrollment_id AND class_id = :class_id LIMIT 1');
    $updateStmt = $conn->prepare('UPDATE final_grades SET final_grade = :final_grade, remark = :remark, computed_by = :computed_by, computed_at = NOW(), is_deleted = 0, deleted_at = NULL WHERE final_grade_id = :final_grade_id');
    $insertStmt = $conn->prepare('INSERT INTO final_grades (enrollment_id, class_id, final_grade, remark, computed_by, is_deleted, deleted_at) VALUES (:enrollment_id, :class_id, :final_grade, :remark, :computed_by, 0, NULL)');

    $upserted = 0;

    foreach ($finalGrades as $row) {
        $finalGrade = (float)$row['final_grade'];
        $remark = $finalGrade < 75 ? 'Failed' : 'Passed';

        $findStmt->execute([
            ':enrollment_id' => (int)$row['enrollment_id'],
            ':class_id' => (int)$row['class_id']
        ]);
        $existingId = $findStmt->fetchColumn();

        if ($existingId) {
            $updateStmt->execute([
                ':final_grade' => $finalGrade,
                ':remark' => $remark,
                ':computed_by' => $userId ?: null,
                ':final_grade_id' => (int)$existingId
            ]);
        } else {
            $insertStmt->execute([
                ':enrollment_id' => (int)$row['enrollment_id'],
                ':class_id' => (int)$row['class_id'],
                ':final_grade' => $finalGrade,
                ':remark' => $remark,
                ':computed_by' => $userId ?: null
            ]);
        }

        $upserted += 1;
    }

    return $upserted;
}

function computeGeneralAveragesFromFinalGrades(array $finalGrades): array {
    $accum = [];
    foreach ($finalGrades as $row) {
        $enrollmentId = (int)$row['enrollment_id'];
        if (!isset($accum[$enrollmentId])) {
            $accum[$enrollmentId] = ['sum' => 0.0, 'count' => 0];
        }
        $accum[$enrollmentId]['sum'] += (float)$row['final_grade'];
        $accum[$enrollmentId]['count'] += 1;
    }

    $out = [];
    foreach ($accum as $enrollmentId => $aggr) {
        if ($aggr['count'] <= 0) continue;
        $out[] = [
            'enrollment_id' => (int)$enrollmentId,
            'general_average' => round($aggr['sum'] / $aggr['count'], 2)
        ];
    }

    return $out;
}

function upsertGeneralAverages(PDO $conn, int $schoolYearId, array $generalAverages, int $userId): int {
    $findStmt = $conn->prepare('SELECT general_average_id FROM general_averages WHERE enrollment_id = :enrollment_id LIMIT 1');
    $updateStmt = $conn->prepare('UPDATE general_averages SET school_year_id = :school_year_id, general_average = :general_average, computed_by = :computed_by, computed_at = NOW(), is_deleted = 0, deleted_at = NULL WHERE general_average_id = :general_average_id');
    $insertStmt = $conn->prepare('INSERT INTO general_averages (enrollment_id, school_year_id, general_average, computed_by, is_deleted, deleted_at) VALUES (:enrollment_id, :school_year_id, :general_average, :computed_by, 0, NULL)');

    $upserted = 0;

    foreach ($generalAverages as $row) {
        $findStmt->execute([
            ':enrollment_id' => (int)$row['enrollment_id']
        ]);
        $existingId = $findStmt->fetchColumn();

        if ($existingId) {
            $updateStmt->execute([
                ':school_year_id' => $schoolYearId,
                ':general_average' => (float)$row['general_average'],
                ':computed_by' => $userId ?: null,
                ':general_average_id' => (int)$existingId
            ]);
        } else {
            $insertStmt->execute([
                ':enrollment_id' => (int)$row['enrollment_id'],
                ':school_year_id' => $schoolYearId,
                ':general_average' => (float)$row['general_average'],
                ':computed_by' => $userId ?: null
            ]);
        }

        $upserted += 1;
    }

    return $upserted;
}

function resolveRiskLevelIds(PDO $conn): array {
    $map = ['low' => 1, 'moderate' => 2, 'high' => 3, 'critical' => 4];

    $stmt = $conn->query('SELECT risk_level_id, risk_name FROM risk_levels WHERE is_deleted = 0');
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $id = (int)($row['risk_level_id'] ?? 0);
        if ($id <= 0) {
            continue;
        }

        $name = strtolower(trim((string)($row['risk_name'] ?? '')));
        if (str_contains($name, 'critical')) {
            $map['critical'] = $id;
        } elseif (str_contains($name, 'high')) {
            $map['high'] = $id;
        } elseif (str_contains($name, 'moderate')) {
            $map['moderate'] = $id;
        } elseif (str_contains($name, 'low')) {
            $map['low'] = $id;
        }
    }

    return $map;
}

function fetchPeriodsForSchoolYear(PDO $conn, int $schoolYearId): array {
    $stmt = $conn->prepare(
        'SELECT grading_period_id, period_name
         FROM grading_periods
         WHERE is_deleted = 0 AND school_year_id = :sy
         ORDER BY COALESCE(date_start, "9999-12-31") ASC, grading_period_id ASC'
    );
    $stmt->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

function fetchEnrolledForSchoolYear(PDO $conn, int $schoolYearId): array {
    $stmt = $conn->prepare(
        'SELECT enrollment_id, section_id
         FROM enrollments
         WHERE is_deleted = 0
           AND enrollment_status = "Enrolled"
           AND school_year_id = :sy'
    );
    $stmt->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

function fetchSectionSubjectCounts(PDO $conn, int $schoolYearId): array {
    $canonicalSql = canonicalClassOfferingsSql();
    $stmt = $conn->prepare(
        'SELECT co.section_id, COUNT(*) AS subject_count
         FROM (' . $canonicalSql . ') co
         WHERE co.school_year_id = :sy
         GROUP BY co.section_id'
    );
    $stmt->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
    $stmt->execute();

    $map = [];
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $map[(int)$row['section_id']] = (int)$row['subject_count'];
    }
    return $map;
}

function fetchPeriodGradeStats(PDO $conn, int $schoolYearId, int $gradingPeriodId): array {
    $canonicalSql = canonicalClassOfferingsSql();

    $stmt = $conn->prepare(
        'SELECT e.enrollment_id,
                ROUND(AVG(g.quarterly_grade), 2) AS period_avg,
                MIN(g.quarterly_grade) AS min_grade,
                COUNT(g.grade_id) AS grade_count
         FROM enrollments e
         JOIN (' . $canonicalSql . ') co ON co.section_id = e.section_id
                                       AND co.school_year_id = e.school_year_id
         LEFT JOIN grades g ON g.enrollment_id = e.enrollment_id
                           AND g.class_id = co.class_id
                           AND g.grading_period_id = :gp
                           AND g.is_deleted = 0
                           AND g.quarterly_grade IS NOT NULL
         WHERE e.is_deleted = 0
           AND e.enrollment_status = "Enrolled"
           AND e.school_year_id = :sy
         GROUP BY e.enrollment_id'
    );
    $stmt->bindValue(':gp', $gradingPeriodId, PDO::PARAM_INT);
    $stmt->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
    $stmt->execute();

    $map = [];
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $map[(int)$row['enrollment_id']] = [
            'period_avg' => ($row['period_avg'] === null || $row['period_avg'] === '') ? null : (float)$row['period_avg'],
            'min_grade' => ($row['min_grade'] === null || $row['min_grade'] === '') ? null : (float)$row['min_grade'],
            'grade_count' => (int)$row['grade_count']
        ];
    }
    return $map;
}

function fetchAttendanceStats(PDO $conn, int $schoolYearId, int $gradingPeriodId): array {
    $stmt = $conn->prepare(
        'SELECT a.enrollment_id,
                COUNT(*) AS attendance_records,
                SUM(CASE WHEN a.status = "Absent" THEN 1 ELSE 0 END) AS absent_count
         FROM attendance a
         JOIN enrollments e ON e.enrollment_id = a.enrollment_id
                           AND e.is_deleted = 0
                           AND e.school_year_id = :sy
                           AND e.enrollment_status = "Enrolled"
         WHERE a.is_deleted = 0
           AND a.grading_period_id = :gp
         GROUP BY a.enrollment_id'
    );
    $stmt->bindValue(':sy', $schoolYearId, PDO::PARAM_INT);
    $stmt->bindValue(':gp', $gradingPeriodId, PDO::PARAM_INT);
    $stmt->execute();

    $map = [];
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $records = (int)$row['attendance_records'];
        $absent = (int)$row['absent_count'];
        $map[(int)$row['enrollment_id']] = [
            'attendance_records' => $records,
            'absent_count' => $absent,
            'absence_rate' => $records > 0 ? round(($absent / $records) * 100, 2) : null
        ];
    }
    return $map;
}

function evaluateRiskLevel(array $metrics, array $riskLevelMap): array {
    $indicators = [];

    $subjectCount = (int)($metrics['subject_count'] ?? 0);
    $gradeCount = (int)($metrics['grade_count'] ?? 0);
    $periodAvg = $metrics['period_avg'];
    $minGrade = $metrics['min_grade'];
    $declineStreak = (int)($metrics['decline_streak'] ?? 0);
    $latestDrop = $metrics['latest_drop'];
    $absenceRate = $metrics['absence_rate'];
    $finalMin = $metrics['final_min'];
    $generalAverage = $metrics['general_average'];

    if ($subjectCount > 0) {
        if ($gradeCount <= 0) {
            $indicators[] = [
                'indicator_type' => 'No Encoded Grades',
                'details' => 'No quarterly grades encoded for this period'
            ];
        } elseif ($gradeCount < $subjectCount) {
            $indicators[] = [
                'indicator_type' => 'Incomplete Grades',
                'details' => "Encoded {$gradeCount}/{$subjectCount} subjects"
            ];
        }
    }

    if ($minGrade !== null && $minGrade < 75) {
        $indicators[] = [
            'indicator_type' => 'Failing Quarterly Grade',
            'details' => 'Lowest quarterly grade: ' . number_format((float)$minGrade, 2)
        ];
    }

    if ($declineStreak >= 2) {
        $dropText = is_numeric($latestDrop)
            ? (' Latest drop: ' . number_format((float)$latestDrop, 2) . ' points.')
            : '';

        $indicators[] = [
            'indicator_type' => 'Continuous Grade Decline',
            'details' => 'Declining performance for ' . $declineStreak . ' consecutive quarter(s).' . $dropText
        ];
    }

    if ($absenceRate !== null) {
        if ($absenceRate >= 20) {
            $indicators[] = [
                'indicator_type' => 'Chronic Absence',
                'details' => 'Absence rate: ' . number_format((float)$absenceRate, 2) . '%'
            ];
        } elseif ($absenceRate >= 10) {
            $indicators[] = [
                'indicator_type' => 'Frequent Absence',
                'details' => 'Absence rate: ' . number_format((float)$absenceRate, 2) . '%'
            ];
        }
    }

    if ($finalMin !== null && $finalMin < 75) {
        $indicators[] = [
            'indicator_type' => 'Failed Subject Final Grade',
            'details' => 'Lowest final grade: ' . number_format((float)$finalMin, 2)
        ];
    }

    if ($generalAverage !== null && $generalAverage < 75) {
        $indicators[] = [
            'indicator_type' => 'Low General Average',
            'details' => 'General average: ' . number_format((float)$generalAverage, 2)
        ];
    }

    $types = array_map(static fn($i) => (string)$i['indicator_type'], $indicators);
    $has = static fn(string $t) => in_array($t, $types, true);

    $riskLevelId = (int)($riskLevelMap['low'] ?? 1);
    if (
        $has('Low General Average') ||
        $has('Failed Subject Final Grade') ||
        ($has('Failing Quarterly Grade') && $has('Chronic Absence'))
    ) {
        $riskLevelId = (int)($riskLevelMap['critical'] ?? 4);
    } elseif (
        $has('Failing Quarterly Grade') ||
        $has('Continuous Grade Decline') ||
        $has('Chronic Absence') ||
        $has('No Encoded Grades') ||
        $has('Incomplete Grades')
    ) {
        $riskLevelId = (int)($riskLevelMap['high'] ?? 3);
    } elseif (!empty($indicators)) {
        $riskLevelId = (int)($riskLevelMap['moderate'] ?? 2);
    }

    if (empty($indicators)) {
        $notes = 'Auto-assessed: No risk indicators detected.';
    } else {
        $summary = array_map(static function ($item) {
            $details = trim((string)($item['details'] ?? ''));
            return $details === ''
                ? (string)$item['indicator_type']
                : ((string)$item['indicator_type'] . ' (' . $details . ')');
        }, $indicators);
        $notes = 'Auto-assessed: ' . implode('; ', $summary) . '.';
    }

    return [$riskLevelId, $indicators, $notes];
}

function computeRiskAssessments(PDO $conn, int $schoolYearId, int $userId, array $generalAverages, array $finalGrades): array {
    $generalAverageMap = [];
    foreach ($generalAverages as $row) {
        $generalAverageMap[(int)$row['enrollment_id']] = (float)$row['general_average'];
    }

    $finalMinMap = [];
    foreach ($finalGrades as $row) {
        $enrollmentId = (int)$row['enrollment_id'];
        $grade = (float)$row['final_grade'];
        if (!isset($finalMinMap[$enrollmentId]) || $grade < $finalMinMap[$enrollmentId]) {
            $finalMinMap[$enrollmentId] = $grade;
        }
    }

    $periods = fetchPeriodsForSchoolYear($conn, $schoolYearId);
    $enrollments = fetchEnrolledForSchoolYear($conn, $schoolYearId);
    $subjectCountMap = fetchSectionSubjectCounts($conn, $schoolYearId);

    if (!$periods || !$enrollments) {
        return ['assessments' => 0, 'indicators' => 0];
    }

    $riskLevelMap = resolveRiskLevelIds($conn);

    $riskFindStmt = $conn->prepare('SELECT risk_assessment_id FROM risk_assessments WHERE enrollment_id = :enrollment_id AND grading_period_id = :grading_period_id LIMIT 1');
    $riskUpdateStmt = $conn->prepare('UPDATE risk_assessments SET risk_level_id = :risk_level_id, assessed_by = :assessed_by, assessed_at = NOW(), notes = :notes, is_deleted = 0, deleted_at = NULL WHERE risk_assessment_id = :risk_assessment_id');
    $riskInsertStmt = $conn->prepare('INSERT INTO risk_assessments (enrollment_id, grading_period_id, risk_level_id, assessed_by, notes, is_deleted, deleted_at) VALUES (:enrollment_id, :grading_period_id, :risk_level_id, :assessed_by, :notes, 0, NULL)');

    $indicatorDeleteStmt = $conn->prepare('UPDATE risk_indicators SET is_deleted = 1, deleted_at = NOW() WHERE risk_assessment_id = :risk_assessment_id AND is_deleted = 0');
    $indicatorInsertStmt = $conn->prepare('INSERT INTO risk_indicators (risk_assessment_id, indicator_type, details, is_deleted, deleted_at) VALUES (:risk_assessment_id, :indicator_type, :details, 0, NULL)');

    $assessmentsUpserted = 0;
    $indicatorsUpserted = 0;
    $previousPeriodAvg = [];
    $declineStreakMap = [];

    foreach ($periods as $period) {
        $periodId = (int)$period['grading_period_id'];
        $periodGradeMap = fetchPeriodGradeStats($conn, $schoolYearId, $periodId);
        $attendanceMap = fetchAttendanceStats($conn, $schoolYearId, $periodId);

        foreach ($enrollments as $enrollment) {
            $enrollmentId = (int)$enrollment['enrollment_id'];
            $sectionId = (int)$enrollment['section_id'];

            $gradeStats = $periodGradeMap[$enrollmentId] ?? [
                'period_avg' => null,
                'min_grade' => null,
                'grade_count' => 0
            ];
            $attendanceStats = $attendanceMap[$enrollmentId] ?? [
                'attendance_records' => 0,
                'absent_count' => 0,
                'absence_rate' => null
            ];

            $periodAvg = $gradeStats['period_avg'];
            $previousAvg = $previousPeriodAvg[$enrollmentId] ?? null;

            $declineStreak = (int)($declineStreakMap[$enrollmentId] ?? 0);
            $latestDrop = null;

            if ($previousAvg !== null && $periodAvg !== null) {
                if ($periodAvg < $previousAvg) {
                    $latestDrop = round($previousAvg - $periodAvg, 2);
                    $declineStreak += 1;
                } else {
                    $declineStreak = 0;
                }
                $declineStreakMap[$enrollmentId] = $declineStreak;
            }

            if ($periodAvg !== null) {
                $previousPeriodAvg[$enrollmentId] = $periodAvg;
            }

            [$riskLevelId, $indicators, $notes] = evaluateRiskLevel([
                'subject_count' => (int)($subjectCountMap[$sectionId] ?? 0),
                'grade_count' => (int)($gradeStats['grade_count'] ?? 0),
                'period_avg' => $periodAvg,
                'min_grade' => $gradeStats['min_grade'],
                'decline_streak' => $declineStreak,
                'latest_drop' => $latestDrop,
                'absence_rate' => $attendanceStats['absence_rate'],
                'final_min' => $finalMinMap[$enrollmentId] ?? null,
                'general_average' => $generalAverageMap[$enrollmentId] ?? null
            ], $riskLevelMap);

            $riskFindStmt->execute([
                ':enrollment_id' => $enrollmentId,
                ':grading_period_id' => $periodId
            ]);
            $existingId = $riskFindStmt->fetchColumn();

            if ($existingId) {
                $riskAssessmentId = (int)$existingId;
                $riskUpdateStmt->execute([
                    ':risk_level_id' => $riskLevelId,
                    ':assessed_by' => $userId ?: null,
                    ':notes' => $notes,
                    ':risk_assessment_id' => $riskAssessmentId
                ]);
            } else {
                $riskInsertStmt->execute([
                    ':enrollment_id' => $enrollmentId,
                    ':grading_period_id' => $periodId,
                    ':risk_level_id' => $riskLevelId,
                    ':assessed_by' => $userId ?: null,
                    ':notes' => $notes
                ]);
                $riskAssessmentId = (int)$conn->lastInsertId();
            }

            $indicatorDeleteStmt->execute([
                ':risk_assessment_id' => $riskAssessmentId
            ]);

            foreach ($indicators as $indicator) {
                $indicatorInsertStmt->execute([
                    ':risk_assessment_id' => $riskAssessmentId,
                    ':indicator_type' => $indicator['indicator_type'],
                    ':details' => $indicator['details']
                ]);
                $indicatorsUpserted += 1;
            }

            $assessmentsUpserted += 1;
        }
    }

    return ['assessments' => $assessmentsUpserted, 'indicators' => $indicatorsUpserted];
}

function notifyAtRiskLearners(PDO $conn, int $schoolYearId): void {
    if ($schoolYearId <= 0) return;
    notifications_ensure_tables($conn);

    try {
        $gpStmt = $conn->prepare(
            "SELECT grading_period_id, period_name
             FROM grading_periods
             WHERE is_deleted = 0 AND school_year_id = :sy
             ORDER BY COALESCE(date_end, '9999-12-31') DESC, grading_period_id DESC
             LIMIT 1"
        );
        $gpStmt->execute([':sy' => $schoolYearId]);
        $gpRow = $gpStmt->fetch(PDO::FETCH_ASSOC) ?: null;
        $latestGpId = $gpRow ? (int)$gpRow['grading_period_id'] : 0;
        $latestGpName = $gpRow ? (string)($gpRow['period_name'] ?? '') : '';
        if ($latestGpId <= 0) return;

        $indicatorSql =
            'SELECT ri.risk_assessment_id,
                    GROUP_CONCAT(
                        CONCAT(
                            ri.indicator_type,
                            CASE
                                WHEN ri.details IS NULL OR ri.details = "" THEN ""
                                ELSE CONCAT(": ", ri.details)
                            END
                        )
                        ORDER BY ri.indicator_id ASC
                        SEPARATOR " | "
                    ) AS indicators
             FROM risk_indicators ri
             WHERE ri.is_deleted = 0
             GROUP BY ri.risk_assessment_id';

        $stmt = $conn->prepare(
            'SELECT ra.risk_assessment_id,
                    ra.enrollment_id,
                    rl.risk_name,
                    rl.color_code,
                    COALESCE(ri.indicators, "") AS indicators,
                    CONCAT(l.last_name, ", ", l.first_name,
                        CASE WHEN l.middle_name IS NULL OR l.middle_name = "" THEN "" ELSE CONCAT(" ", l.middle_name) END,
                        CASE WHEN l.name_extension IS NULL OR l.name_extension = "" THEN "" ELSE CONCAT(" ", l.name_extension) END
                    ) AS learner_name,
                    gl.grade_name,
                    sec.section_name,
                    sec.adviser_id,
                    adv.user_id AS adviser_user_id
             FROM risk_assessments ra
             JOIN grading_periods gp ON gp.grading_period_id = ra.grading_period_id
                                   AND gp.is_deleted = 0
                                   AND gp.school_year_id = :sy
             JOIN risk_levels rl ON rl.risk_level_id = ra.risk_level_id
                                AND rl.is_deleted = 0
             JOIN enrollments e ON e.enrollment_id = ra.enrollment_id
                               AND e.is_deleted = 0
                               AND e.enrollment_status = "Enrolled"
                               AND e.school_year_id = :sy2
             JOIN learners l ON l.learner_id = e.learner_id
                            AND l.is_deleted = 0
             LEFT JOIN sections sec ON sec.section_id = e.section_id
                                   AND sec.is_deleted = 0
             LEFT JOIN grade_levels gl ON gl.grade_level_id = e.grade_level_id
             LEFT JOIN employees advEmp ON advEmp.employee_id = sec.adviser_id
                                       AND advEmp.is_deleted = 0
             LEFT JOIN users adv ON adv.user_id = advEmp.user_id
             LEFT JOIN (' . $indicatorSql . ') ri ON ri.risk_assessment_id = ra.risk_assessment_id
             WHERE ra.is_deleted = 0
               AND ra.grading_period_id = :gp
               AND LOWER(TRIM(rl.risk_name)) <> "low"'
        );

        $stmt->execute([
            ':sy' => $schoolYearId,
            ':sy2' => $schoolYearId,
            ':gp' => $latestGpId
        ]);

        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if (!$rows) return;

        $adminRoleId = notifications_get_role_id($conn, 'admin');
        $adminUserIds = [];
        if ($adminRoleId) {
            $u = $conn->prepare('SELECT user_id FROM users WHERE role_id = :rid AND is_active = 1 AND is_deleted = 0');
            $u->execute([':rid' => $adminRoleId]);
            $adminUserIds = array_map('intval', $u->fetchAll(PDO::FETCH_COLUMN));
        }

        foreach ($rows as $r) {
            $riskAssessmentId = (int)($r['risk_assessment_id'] ?? 0);
            $learnerName = trim((string)($r['learner_name'] ?? ''));
            $gradeName = trim((string)($r['grade_name'] ?? ''));
            $sectionName = trim((string)($r['section_name'] ?? ''));
            $riskName = trim((string)($r['risk_name'] ?? 'At Risk'));
            $indicators = trim((string)($r['indicators'] ?? ''));

            $title = 'At-Risk Learner';
            $context = trim(implode(' ', array_filter([
                $gradeName !== '' ? $gradeName : null,
                $sectionName !== '' ? ('(' . $sectionName . ')') : null
            ])));

            $msg = trim($learnerName . ($context !== '' ? (' ' . $context) : '') .
                ' flagged as ' . ($riskName !== '' ? $riskName : 'At Risk') .
                ($latestGpName !== '' ? (' for ' . $latestGpName) : '') .
                ($indicators !== '' ? ('. ' . $indicators) : '.')
            );

            if (strlen($msg) > 900) {
                $msg = substr($msg, 0, 900) . '…';
            }

            $adviserUserId = (int)($r['adviser_user_id'] ?? 0);
            if ($adviserUserId > 0) {
                if (!notifications_exists_today_for_user($conn, $adviserUserId, 'Risk Flag', $title, $msg)) {
                    notifications_create_for_user($conn, $adviserUserId, 'Risk Flag', $title, $msg, 'risk_assessments', $riskAssessmentId);
                }
            } else {
                foreach ($adminUserIds as $adminUid) {
                    if ($adminUid <= 0) continue;
                    if (!notifications_exists_today_for_user($conn, $adminUid, 'Risk Flag', $title, $msg)) {
                        notifications_create_for_user($conn, $adminUid, 'Risk Flag', $title, $msg, 'risk_assessments', $riskAssessmentId);
                    }
                }
            }
        }
    } catch (Exception $e) {
        // Ignore notification failures.
    }
}
?>
