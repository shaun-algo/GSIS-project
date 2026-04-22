-- Migration: Add learner progression and safe school-year rollover support
-- Purpose:
--   Complements the current SIAS schema used by the capstone paper without
--   duplicating existing grading, analytics, risk, or notification tables.
--
-- Reuses existing tables:
--   grades
--   final_grades
--   general_averages
--   risk_assessments
--   notifications
--
-- Notes:
-- 1) Do not paste this into dep_ed.sql. Run it as a separate additive migration.
-- 2) Before running sp_auto_reenroll, create sections for the target school year.
-- 3) If your MariaDB server reports mysql.proc metadata errors, repair/upgrade the
--    server first before running the procedure section.

CREATE TABLE IF NOT EXISTS grade_level_progression (
    grade_level_id INT(11) NOT NULL,
    next_grade_level_id INT(11) DEFAULT NULL,
    is_terminal TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (grade_level_id),
    KEY idx_glp_next_grade (next_grade_level_id),
    CONSTRAINT fk_glp_grade
        FOREIGN KEY (grade_level_id) REFERENCES grade_levels(grade_level_id),
    CONSTRAINT fk_glp_next_grade
        FOREIGN KEY (next_grade_level_id) REFERENCES grade_levels(grade_level_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='DepEd grade flow mapping used for promotion and re-enrollment';

INSERT INTO grade_level_progression (grade_level_id, next_grade_level_id, is_terminal)
VALUES
    (1, 2, 0),
    (2, 3, 0),
    (3, 4, 0),
    (4, 5, 0),
    (5, 6, 0),
    (6, 7, 0),
    (7, 8, 0),
    (8, 9, 0),
    (9, 10, 0),
    (10, NULL, 1)
ON DUPLICATE KEY UPDATE
    next_grade_level_id = VALUES(next_grade_level_id),
    is_terminal = VALUES(is_terminal),
    updated_at = CURRENT_TIMESTAMP;

CREATE TABLE IF NOT EXISTS learner_progression (
    progression_id INT(11) NOT NULL AUTO_INCREMENT,
    enrollment_id INT(11) NOT NULL,
    learner_id INT(11) NOT NULL,
    school_year_id INT(11) NOT NULL,
    current_grade_level_id INT(11) NOT NULL,
    general_average DECIMAL(5,2) DEFAULT NULL,
    final_status ENUM('Promoted','Retained','Completed') NOT NULL,
    next_grade_level_id INT(11) DEFAULT NULL,
    remarks VARCHAR(255) DEFAULT NULL,
    decided_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_processed TINYINT(1) NOT NULL DEFAULT 0,
    processed_at DATETIME DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (progression_id),
    UNIQUE KEY uq_lp_enrollment (enrollment_id),
    KEY idx_lp_learner_sy (learner_id, school_year_id),
    KEY idx_lp_sy_processed (school_year_id, is_processed),
    KEY idx_lp_next_grade (next_grade_level_id),
    CONSTRAINT fk_lp_enrollment
        FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id),
    CONSTRAINT fk_lp_learner
        FOREIGN KEY (learner_id) REFERENCES learners(learner_id),
    CONSTRAINT fk_lp_school_year
        FOREIGN KEY (school_year_id) REFERENCES school_years(school_year_id),
    CONSTRAINT fk_lp_current_grade
        FOREIGN KEY (current_grade_level_id) REFERENCES grade_levels(grade_level_id),
    CONSTRAINT fk_lp_next_grade
        FOREIGN KEY (next_grade_level_id) REFERENCES grade_levels(grade_level_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Promotion and rollover decision per learner enrollment';

CREATE OR REPLACE VIEW vw_learner_progression_candidates AS
SELECT
    lp.progression_id,
    lp.enrollment_id,
    lp.learner_id,
    lp.school_year_id AS source_school_year_id,
    lp.current_grade_level_id,
    lp.next_grade_level_id,
    lp.general_average,
    lp.final_status,
    lp.remarks,
    lp.is_processed,
    e.section_id AS source_section_id,
    sec.section_name AS source_section_name,
    e.curriculum_id AS source_curriculum_id
FROM learner_progression lp
JOIN enrollments e
    ON e.enrollment_id = lp.enrollment_id
   AND e.is_deleted = 0
LEFT JOIN sections sec
    ON sec.section_id = e.section_id
WHERE lp.final_status IN ('Promoted','Retained');

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_compute_promotion $$
CREATE PROCEDURE sp_compute_promotion(IN p_school_year_id INT)
BEGIN
    INSERT INTO learner_progression (
        enrollment_id,
        learner_id,
        school_year_id,
        current_grade_level_id,
        general_average,
        final_status,
        next_grade_level_id,
        remarks,
        decided_at,
        is_processed,
        processed_at
    )
    SELECT
        e.enrollment_id,
        e.learner_id,
        e.school_year_id,
        e.grade_level_id,
        ga.general_average,
        CASE
            WHEN ga.general_average >= 75 THEN
                CASE
                    WHEN glp.is_terminal = 1 OR glp.next_grade_level_id IS NULL THEN 'Completed'
                    ELSE 'Promoted'
                END
            ELSE 'Retained'
        END AS final_status,
        CASE
            WHEN ga.general_average >= 75 THEN glp.next_grade_level_id
            ELSE e.grade_level_id
        END AS next_grade_level_id,
        CASE
            WHEN ga.general_average >= 75 AND (glp.is_terminal = 1 OR glp.next_grade_level_id IS NULL)
                THEN CONCAT('Completed terminal grade level with general average ', FORMAT(ga.general_average, 2), '.')
            WHEN ga.general_average >= 75
                THEN CONCAT('Promoted with general average ', FORMAT(ga.general_average, 2), '.')
            ELSE CONCAT('Retained with general average ', FORMAT(ga.general_average, 2), '.')
        END AS remarks,
        NOW() AS decided_at,
        0 AS is_processed,
        NULL AS processed_at
    FROM enrollments e
    JOIN general_averages ga
        ON ga.enrollment_id = e.enrollment_id
       AND ga.school_year_id = e.school_year_id
       AND ga.is_deleted = 0
    JOIN grade_level_progression glp
        ON glp.grade_level_id = e.grade_level_id
    WHERE e.school_year_id = p_school_year_id
      AND e.is_deleted = 0
      AND e.enrollment_status IN ('Enrolled','Completed')
    ON DUPLICATE KEY UPDATE
        learner_id = VALUES(learner_id),
        school_year_id = VALUES(school_year_id),
        current_grade_level_id = VALUES(current_grade_level_id),
        general_average = VALUES(general_average),
        final_status = VALUES(final_status),
        next_grade_level_id = VALUES(next_grade_level_id),
        remarks = VALUES(remarks),
        decided_at = VALUES(decided_at),
        is_processed = 0,
        processed_at = NULL,
        updated_at = CURRENT_TIMESTAMP;
END $$

DROP PROCEDURE IF EXISTS sp_auto_reenroll $$
CREATE PROCEDURE sp_auto_reenroll(IN p_old_sy INT, IN p_new_sy INT)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_progression_id INT;
    DECLARE v_enrollment_id INT;
    DECLARE v_learner_id INT;
    DECLARE v_current_grade_level_id INT;
    DECLARE v_next_grade_level_id INT;
    DECLARE v_final_status VARCHAR(20);
    DECLARE v_source_section_name VARCHAR(100);
    DECLARE v_source_curriculum_id INT;
    DECLARE v_target_grade_level_id INT;
    DECLARE v_target_section_id INT;
    DECLARE v_target_curriculum_id INT;
    DECLARE v_returning_type_id INT DEFAULT 2;

    DECLARE cur CURSOR FOR
        SELECT
            lp.progression_id,
            lp.enrollment_id,
            lp.learner_id,
            lp.current_grade_level_id,
            lp.next_grade_level_id,
            lp.final_status,
            sec.section_name,
            e.curriculum_id
        FROM learner_progression lp
        JOIN enrollments e
            ON e.enrollment_id = lp.enrollment_id
           AND e.is_deleted = 0
        LEFT JOIN sections sec
            ON sec.section_id = e.section_id
        WHERE lp.school_year_id = p_old_sy
          AND lp.is_processed = 0
          AND lp.final_status IN ('Promoted','Retained')
        ORDER BY lp.progression_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    SELECT enrollment_type_id
      INTO v_returning_type_id
    FROM enrollment_types
    WHERE is_deleted = 0
      AND type_name = 'Returning'
    ORDER BY enrollment_type_id
    LIMIT 1;

    IF v_returning_type_id IS NULL THEN
        SET v_returning_type_id = 2;
    END IF;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO
            v_progression_id,
            v_enrollment_id,
            v_learner_id,
            v_current_grade_level_id,
            v_next_grade_level_id,
            v_final_status,
            v_source_section_name,
            v_source_curriculum_id;

        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        SET v_target_grade_level_id = CASE
            WHEN v_final_status = 'Promoted' THEN v_next_grade_level_id
            ELSE v_current_grade_level_id
        END;

        IF v_target_grade_level_id IS NULL THEN
            UPDATE learner_progression
               SET remarks = 'Skipped: no target grade level could be resolved.',
                   updated_at = CURRENT_TIMESTAMP
             WHERE progression_id = v_progression_id;
            ITERATE read_loop;
        END IF;

        IF EXISTS (
            SELECT 1
            FROM enrollments ex
            WHERE ex.learner_id = v_learner_id
              AND ex.school_year_id = p_new_sy
              AND ex.is_deleted = 0
            LIMIT 1
        ) THEN
            UPDATE learner_progression
               SET is_processed = 1,
                   processed_at = CURRENT_TIMESTAMP,
                   remarks = CONCAT(
                       'Skipped: learner already has an enrollment record for school year ',
                       p_new_sy,
                       '.'
                   ),
                   updated_at = CURRENT_TIMESTAMP
             WHERE progression_id = v_progression_id;
            ITERATE read_loop;
        END IF;

        SET v_target_section_id = (
            SELECT s.section_id
            FROM sections s
            WHERE s.is_deleted = 0
              AND s.school_year_id = p_new_sy
              AND s.grade_level_id = v_target_grade_level_id
              AND (
                    SELECT COUNT(*)
                    FROM enrollments e2
                    WHERE e2.section_id = s.section_id
                      AND e2.school_year_id = p_new_sy
                      AND e2.is_deleted = 0
                      AND (e2.enrollment_status = 'Enrolled' OR e2.enrollment_status IS NULL)
                ) < s.max_capacity
            ORDER BY
                CASE
                    WHEN v_source_section_name IS NOT NULL AND s.section_name = v_source_section_name THEN 0
                    ELSE 1
                END,
                s.section_id
            LIMIT 1
        );

        IF v_target_section_id IS NULL THEN
            UPDATE learner_progression
               SET remarks = CONCAT(
                       'Pending manual section assignment for school year ',
                       p_new_sy,
                       '. Create an available section for the target grade level first.'
                   ),
                   updated_at = CURRENT_TIMESTAMP
             WHERE progression_id = v_progression_id;
            ITERATE read_loop;
        END IF;

        SET v_target_curriculum_id = COALESCE(
            (
                SELECT m.curriculum_id
                FROM curriculum_school_year_map m
                WHERE m.curriculum_id = v_source_curriculum_id
                  AND m.school_year_id = p_new_sy
                  AND m.is_deleted = 0
                  AND (
                        NOT EXISTS (
                            SELECT 1
                            FROM curriculum_grade_levels cgl
                            WHERE cgl.curriculum_id = m.curriculum_id
                              AND cgl.is_deleted = 0
                        )
                        OR EXISTS (
                            SELECT 1
                            FROM curriculum_grade_levels cgl
                            WHERE cgl.curriculum_id = m.curriculum_id
                              AND cgl.grade_level_id = v_target_grade_level_id
                              AND cgl.is_deleted = 0
                        )
                  )
                ORDER BY m.map_id DESC
                LIMIT 1
            ),
            (
                SELECT m.curriculum_id
                FROM curriculum_school_year_map m
                WHERE m.school_year_id = p_new_sy
                  AND m.is_primary = 1
                  AND m.is_deleted = 0
                  AND (
                        NOT EXISTS (
                            SELECT 1
                            FROM curriculum_grade_levels cgl
                            WHERE cgl.curriculum_id = m.curriculum_id
                              AND cgl.is_deleted = 0
                        )
                        OR EXISTS (
                            SELECT 1
                            FROM curriculum_grade_levels cgl
                            WHERE cgl.curriculum_id = m.curriculum_id
                              AND cgl.grade_level_id = v_target_grade_level_id
                              AND cgl.is_deleted = 0
                        )
                  )
                ORDER BY m.map_id DESC
                LIMIT 1
            ),
            (
                SELECT m.curriculum_id
                FROM curriculum_school_year_map m
                WHERE m.school_year_id = p_new_sy
                  AND m.is_deleted = 0
                  AND (
                        NOT EXISTS (
                            SELECT 1
                            FROM curriculum_grade_levels cgl
                            WHERE cgl.curriculum_id = m.curriculum_id
                              AND cgl.is_deleted = 0
                        )
                        OR EXISTS (
                            SELECT 1
                            FROM curriculum_grade_levels cgl
                            WHERE cgl.curriculum_id = m.curriculum_id
                              AND cgl.grade_level_id = v_target_grade_level_id
                              AND cgl.is_deleted = 0
                        )
                  )
                ORDER BY m.is_primary DESC, m.map_id DESC
                LIMIT 1
            )
        );

        BEGIN
            DECLARE v_insert_failed TINYINT DEFAULT 0;
            DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_insert_failed = 1;

            INSERT INTO enrollments (
                learner_id,
                school_year_id,
                grade_level_id,
                section_id,
                curriculum_id,
                enrollment_type_id,
                enrollment_date,
                enrollment_status
            )
            VALUES (
                v_learner_id,
                p_new_sy,
                v_target_grade_level_id,
                v_target_section_id,
                v_target_curriculum_id,
                v_returning_type_id,
                CURDATE(),
                'Enrolled'
            );

            IF v_insert_failed = 0 THEN
                UPDATE learner_progression
                   SET is_processed = 1,
                       processed_at = CURRENT_TIMESTAMP,
                       remarks = CONCAT(
                           'Re-enrolled for school year ',
                           p_new_sy,
                           ' using section ',
                           v_target_section_id,
                           '.'
                       ),
                       updated_at = CURRENT_TIMESTAMP
                 WHERE progression_id = v_progression_id;
            ELSE
                UPDATE learner_progression
                   SET remarks = CONCAT(
                           'Auto re-enrollment failed for school year ',
                           p_new_sy,
                           '. Verify section capacity, curriculum mapping, and uniqueness constraints.'
                       ),
                       updated_at = CURRENT_TIMESTAMP
                 WHERE progression_id = v_progression_id;
            END IF;
        END;
    END LOOP;

    CLOSE cur;
END $$

DELIMITER ;
