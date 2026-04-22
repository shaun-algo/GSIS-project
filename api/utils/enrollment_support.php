<?php

function enrollment_support_get_active_school_year_id(PDO $conn): ?int {
    $stmt = $conn->prepare(
        'SELECT school_year_id
         FROM school_years
         WHERE is_active = 1
           AND is_deleted = 0
         ORDER BY year_start DESC, school_year_id DESC
         LIMIT 1'
    );
    $stmt->execute();
    $id = $stmt->fetchColumn();
    return $id ? (int)$id : null;
}

function enrollment_support_get_primary_curriculum_id_for_school_year(PDO $conn, int $schoolYearId): ?int {
    if ($schoolYearId <= 0) {
        return null;
    }

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

function enrollment_support_get_any_mapped_curriculum_id_for_school_year(PDO $conn, int $schoolYearId): ?int {
    if ($schoolYearId <= 0) {
        return null;
    }

    $stmt = $conn->prepare(
        'SELECT c.curriculum_id
         FROM curriculum_school_year_map m
         JOIN curricula c
           ON c.curriculum_id = m.curriculum_id
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

function enrollment_support_is_curriculum_mapped_to_school_year(PDO $conn, int $curriculumId, int $schoolYearId): bool {
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

function enrollment_support_curriculum_has_grade_levels_configured(PDO $conn, int $curriculumId): bool {
    $stmt = $conn->prepare(
        'SELECT COUNT(*)
         FROM curriculum_grade_levels
         WHERE curriculum_id = :cid
           AND is_deleted = 0'
    );
    $stmt->bindValue(':cid', $curriculumId, PDO::PARAM_INT);
    $stmt->execute();
    return ((int)$stmt->fetchColumn()) > 0;
}

function enrollment_support_curriculum_covers_grade_level(PDO $conn, int $curriculumId, int $gradeLevelId): bool {
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

function enrollment_support_curriculum_is_eligible_for_grade(PDO $conn, int $curriculumId, int $gradeLevelId): bool {
    if ($gradeLevelId <= 0) {
        return true;
    }
    if (!enrollment_support_curriculum_has_grade_levels_configured($conn, $curriculumId)) {
        return true;
    }
    return enrollment_support_curriculum_covers_grade_level($conn, $curriculumId, $gradeLevelId);
}

function enrollment_support_resolve_curriculum(PDO $conn, ?int $curriculumId, int $schoolYearId, int $gradeLevelId): ?int {
    if ($curriculumId === null) {
        $curriculumId = enrollment_support_get_primary_curriculum_id_for_school_year($conn, $schoolYearId)
            ?? enrollment_support_get_any_mapped_curriculum_id_for_school_year($conn, $schoolYearId);
    }

    if ($curriculumId === null) {
        return null;
    }

    if (!enrollment_support_is_curriculum_mapped_to_school_year($conn, $curriculumId, $schoolYearId)) {
        throw new InvalidArgumentException(
            'Selected curriculum is not mapped to the selected school year. Configure mapping in Curriculum Components.'
        );
    }

    if (!enrollment_support_curriculum_is_eligible_for_grade($conn, $curriculumId, $gradeLevelId)) {
        throw new InvalidArgumentException('Selected curriculum does not cover the selected grade level.');
    }

    return $curriculumId;
}

function enrollment_support_get_section(PDO $conn, int $sectionId): ?array {
    $stmt = $conn->prepare(
        'SELECT section_id, section_name, school_year_id, grade_level_id, max_capacity
         FROM sections
         WHERE section_id = :section_id
           AND is_deleted = 0
         LIMIT 1'
    );
    $stmt->bindValue(':section_id', $sectionId, PDO::PARAM_INT);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

function enrollment_support_validate_section(PDO $conn, int $sectionId, int $schoolYearId, int $gradeLevelId): array {
    $row = enrollment_support_get_section($conn, $sectionId);
    if (!$row) {
        throw new InvalidArgumentException('Selected section not found');
    }
    if ((int)$row['school_year_id'] !== $schoolYearId) {
        throw new InvalidArgumentException('Selected section does not belong to the selected school year');
    }
    if ((int)$row['grade_level_id'] !== $gradeLevelId) {
        throw new InvalidArgumentException('Selected section does not match the selected grade level');
    }
    return $row;
}

function enrollment_support_get_enrollment_for_school_year(PDO $conn, int $learnerId, int $schoolYearId): ?array {
    $stmt = $conn->prepare(
        'SELECT *
         FROM enrollments
         WHERE learner_id = :learner_id
           AND school_year_id = :school_year_id
           AND is_deleted = 0
         ORDER BY enrollment_id DESC
         LIMIT 1'
    );
    $stmt->bindValue(':learner_id', $learnerId, PDO::PARAM_INT);
    $stmt->bindValue(':school_year_id', $schoolYearId, PDO::PARAM_INT);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

function enrollment_support_get_active_or_latest_enrollment(PDO $conn, int $learnerId): ?array {
    $activeSchoolYearId = enrollment_support_get_active_school_year_id($conn);
    if ($activeSchoolYearId) {
        $active = enrollment_support_get_enrollment_for_school_year($conn, $learnerId, $activeSchoolYearId);
        if ($active) {
            return $active;
        }
    }

    $stmt = $conn->prepare(
        'SELECT *
         FROM enrollments
         WHERE learner_id = :learner_id
           AND is_deleted = 0
         ORDER BY school_year_id DESC, enrollment_id DESC
         LIMIT 1'
    );
    $stmt->bindValue(':learner_id', $learnerId, PDO::PARAM_INT);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

