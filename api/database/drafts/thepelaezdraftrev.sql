-- ============================================================
-- pelaez_db v3 — Final Clean Version
-- MariaDB 10.4 / phpMyAdmin 5.2
--
-- Changes from v2:
--   FIX 1: sections.max_capacity — CHECK constraint now inside
--           CREATE TABLE (correct MariaDB 10.2+ syntax)
--   FIX 2: attendance.class_id — changed from nullable to
--           NOT NULL DEFAULT 0 (0 = whole-day/homeroom) so the
--           UNIQUE key works correctly (NULL breaks uniqueness)
--   FIX 3: enrollments — restored curriculum_id FK so the system
--           knows which curriculum a learner follows per SY
--   FIX 4: report_card_grades — new child table that snapshots
--           per-subject grades at card generation time, making
--           reprinting fully self-contained
-- ============================================================

SET SQL_MODE        = "NO_AUTO_VALUE_ON_ZERO";
SET FOREIGN_KEY_CHECKS = 0;
START TRANSACTION;
SET time_zone       = "+00:00";
SET NAMES utf8mb4;

-- ============================================================
-- ROLES
-- ============================================================

CREATE TABLE `roles` (
  `role_id`     int(11)      NOT NULL AUTO_INCREMENT,
  `role_name`   varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_deleted`  tinyint(1)   DEFAULT 0,
  `deleted_at`  datetime     DEFAULT NULL,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `uq_role_name` (`role_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='System user roles — Admin, Teacher, Learner, etc.';

INSERT INTO `roles` VALUES
(8,  'admin',    NULL, 0, NULL),
(9,  'teacher',  NULL, 0, NULL),
(10, 'learners', NULL, 0, NULL);

-- ============================================================
-- USERS
-- ============================================================

CREATE TABLE `users` (
  `user_id`    int(11)      NOT NULL AUTO_INCREMENT,
  `username`   varchar(100) NOT NULL,
  `password`   varchar(255) NOT NULL,
  `role_id`    int(11)      NOT NULL,
  `is_active`  tinyint(1)   DEFAULT 1,
  `last_login` datetime     DEFAULT NULL,
  `created_at` datetime     DEFAULT current_timestamp(),
  `updated_at` datetime     DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_deleted` tinyint(1)   DEFAULT 0,
  `deleted_at` datetime     DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uq_username`  (`username`),
  KEY `idx_user_role` (`role_id`),
  CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='System user accounts — all roles share this table';

INSERT INTO `users` (`user_id`,`username`,`password`,`role_id`,`is_active`,`created_at`,`updated_at`) VALUES
(1,  'admin',          '$2y$10$VKM.qCITU8xZ6vk/zsDctO..2JxgW/4BBp48USk8R6Cp7adFfyI7G', 8,  1, '2026-02-20 09:50:24', '2026-02-20 09:50:24'),
(26, '911',            '$2y$10$AQSa5DbbKrugxc69Gr6VZzOVbuqV4gr.G6Ntmc8HUgXghiK0T6O71G', 8,  1, '2026-02-21 01:12:41', '2026-02-21 13:32:42'),
(27, '12-12-12',       '$2y$10$66FPGWticM8NG/Vg1u.dYObUkMIJScmMDOdrccZJnJL5.fmzi8pNS',  8,  1, '2026-02-21 12:37:24', '2026-02-21 12:37:24'),
(28, '02-2324-06121',  '$2y$10$bC9jkmOMT2GP2KgshYw7Zuh6LJ6tRF3ZAiUJNNbHfpZAxfWPYSHzi', 10, 1, '2026-02-23 13:07:42', '2026-02-23 13:07:42'),
(29, '28-28-28',       '$2y$10$ugJkwO2s9MXWDrVSC277ZOAqcNowWhiCfhvZvPf/jbKJiFBHRhKeC',  9,  1, '2026-02-23 14:16:36', '2026-02-23 14:16:36');

-- ============================================================
-- POSITIONS
-- ============================================================

CREATE TABLE `positions` (
  `position_id`   int(11)      NOT NULL AUTO_INCREMENT,
  `position_name` varchar(150) NOT NULL,
  `description`   varchar(255) DEFAULT NULL,
  `is_deleted`    tinyint(1)   DEFAULT 0,
  `deleted_at`    datetime     DEFAULT NULL,
  PRIMARY KEY (`position_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Employee position lookup';

INSERT INTO `positions` VALUES
(1, 'Principal',            NULL, 0, NULL),
(2, 'Assistant Principal',  NULL, 0, NULL),
(3, 'Registrar',            NULL, 0, NULL),
(4, 'Teacher',              NULL, 0, NULL),
(8, 'ICT Coordinator',      NULL, 0, NULL),
(9, 'Administrative Staff', NULL, 0, NULL);

-- ============================================================
-- EMPLOYEES
-- gender inlined as ENUM; name_extension inlined as VARCHAR
-- ============================================================

CREATE TABLE `employees` (
  `employee_id`     int(11)      NOT NULL AUTO_INCREMENT,
  `user_id`         int(11)      NOT NULL,
  `employee_number` varchar(50)  NOT NULL,
  `first_name`      varchar(100) NOT NULL,
  `middle_name`     varchar(100) DEFAULT NULL,
  `last_name`       varchar(100) NOT NULL,
  `name_extension`  varchar(10)  DEFAULT NULL COMMENT 'Jr., Sr., II, III …',
  `date_of_birth`   date         DEFAULT NULL,
  `gender`          ENUM('Male','Female','Other') DEFAULT NULL,
  `contact_number`  varchar(20)  DEFAULT NULL,
  `email`           varchar(150) DEFAULT NULL,
  `address`         text         DEFAULT NULL,
  `position_id`     int(11)      DEFAULT NULL,
  `date_hired`      date         DEFAULT NULL,
  `is_deleted`      tinyint(1)   DEFAULT 0,
  `deleted_at`      datetime     DEFAULT NULL,
  PRIMARY KEY (`employee_id`),
  UNIQUE KEY `uq_employee_user`   (`user_id`),
  UNIQUE KEY `uq_employee_number` (`employee_number`),
  KEY `idx_emp_position` (`position_id`),
  CONSTRAINT `fk_employee_user`     FOREIGN KEY (`user_id`)     REFERENCES `users`     (`user_id`),
  CONSTRAINT `fk_employee_position` FOREIGN KEY (`position_id`) REFERENCES `positions` (`position_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Employee (teacher/staff) profiles linked to a user account';

INSERT INTO `employees`
  (`employee_id`,`user_id`,`employee_number`,`first_name`,`middle_name`,`last_name`,`name_extension`,`date_of_birth`,`gender`,`contact_number`,`email`,`address`,`position_id`,`date_hired`)
VALUES
(1,  1,  '123',      'Carlo',   NULL,        'Yulo',      NULL,   NULL,         NULL,     '09361470082',  NULL,                        NULL,   NULL, NULL),
(26, 26, '911',      'Shaunu',  'T.',        'Belono-ac', 'test', '2026-02-21', 'Male',   'test',         'belonoacshaun1@gmail.com',  'test', 9,    '2026-02-21'),
(27, 27, '12-12-12', 'jane',    'j',         'tejo',      NULL,   '2026-02-21', 'Female', '097234845845', 'jane@gmail.com',            'test', 4,    '2026-02-21'),
(28, 29, '28-28-28', 'Neilban', 'Colinares', 'Ong',       NULL,   '2026-01-28', 'Other',  '0914314390',   'nico.Ong.coc@phinmaed.com', NULL,   4,    '2026-02-23');

-- ============================================================
-- EDUCATION LEVELS
-- ============================================================

CREATE TABLE `education_levels` (
  `education_level_id` int(11)      NOT NULL AUTO_INCREMENT,
  `level_name`         varchar(100) NOT NULL,
  `is_deleted`         tinyint(1)   DEFAULT 0,
  `deleted_at`         datetime     DEFAULT NULL,
  PRIMARY KEY (`education_level_id`),
  UNIQUE KEY `uq_level_name` (`level_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Education level — Elementary, Junior High School, Senior High School';

INSERT INTO `education_levels` VALUES
(1, 'Elementary',        0, NULL),
(2, 'Junior High School',0, NULL);

-- ============================================================
-- GRADE LEVELS
-- ============================================================

CREATE TABLE `grade_levels` (
  `grade_level_id`     int(11)    NOT NULL AUTO_INCREMENT,
  `grade_name`         varchar(50) NOT NULL,
  `education_level_id` int(11)    NOT NULL,
  `sort_order`         int(11)    DEFAULT NULL,
  `is_deleted`         tinyint(1) DEFAULT 0,
  `deleted_at`         datetime   DEFAULT NULL,
  PRIMARY KEY (`grade_level_id`),
  UNIQUE KEY `uq_grade_name` (`grade_name`),
  KEY `idx_grade_level_education` (`education_level_id`),
  CONSTRAINT `fk_grade_education` FOREIGN KEY (`education_level_id`) REFERENCES `education_levels` (`education_level_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Grade levels — Grade 1 through Grade 10';

INSERT INTO `grade_levels` VALUES
(1,  'Grade 1',  1, 1,  0, NULL),
(2,  'Grade 2',  1, 2,  0, NULL),
(3,  'Grade 3',  1, 3,  0, NULL),
(4,  'Grade 4',  1, 4,  0, NULL),
(5,  'Grade 5',  1, 5,  0, NULL),
(6,  'Grade 6',  1, 6,  0, NULL),
(7,  'Grade 7',  2, 7,  0, NULL),
(8,  'Grade 8',  2, 8,  0, NULL),
(9,  'Grade 9',  2, 9,  0, NULL),
(10, 'Grade 10', 2, 10, 0, NULL);

-- ============================================================
-- SCHOOL YEARS
-- grading_system_type inlined as ENUM (dropped grading_system_types table)
-- ============================================================

CREATE TABLE `school_years` (
  `school_year_id`      int(11)    NOT NULL AUTO_INCREMENT,
  `year_start`          int(4)     DEFAULT NULL,
  `year_end`            int(4)     DEFAULT NULL,
  `year_label`          varchar(20) NOT NULL COMMENT 'e.g. 2025-2026',
  `date_start`          date       DEFAULT NULL,
  `date_end`            date       DEFAULT NULL,
  `is_active`           tinyint(1) DEFAULT 0,
  `grading_system_type` ENUM('Quarterly','Trimester','Semester') NOT NULL DEFAULT 'Quarterly',
  `is_deleted`          tinyint(1) DEFAULT 0,
  `deleted_at`          datetime   DEFAULT NULL,
  PRIMARY KEY (`school_year_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Academic school years';

INSERT INTO `school_years`
  (`school_year_id`,`year_start`,`year_end`,`year_label`,`date_start`,`date_end`,`is_active`,`grading_system_type`,`is_deleted`,`deleted_at`)
VALUES
(2, 2025, 2027, '2025-2027', '2026-02-20', '2027-03-12', 0, 'Trimester', 1, '2026-02-21 03:22:38'),
(5, 2026, 2027, '2026-2027', '2026-02-21', '2026-02-21', 1, 'Quarterly', 0, NULL);

-- ============================================================
-- CURRICULA
-- ============================================================

CREATE TABLE `subjects` (
  `subject_id`   int(11)      NOT NULL AUTO_INCREMENT,
  `subject_name` varchar(150) NOT NULL,
  `subject_code` varchar(50)  NOT NULL COMMENT 'DepEd code e.g. MATH, ENG, FIL',
  `description`  varchar(255) DEFAULT NULL,
  `is_deleted`   tinyint(1)   DEFAULT 0,
  `deleted_at`   datetime     DEFAULT NULL,
  PRIMARY KEY (`subject_id`),
  UNIQUE KEY `uq_subject_code` (`subject_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Subject master list';

INSERT INTO `subjects` VALUES
(1,  'Mother Tongue (MTB-MLE)',                          'MTB-MLE',   'Primary language of instruction — Grades 1 to 3', 0, NULL),
(2,  'Filipino',                                         'FIL',       'Filipino language — all elementary levels',        0, NULL),
(3,  'English',                                          'ENG',       'English language — all elementary levels',         0, NULL),
(4,  'Mathematics',                                      'MATH',      'Mathematics — all levels; spiral progression',     0, NULL),
(5,  'Araling Panlipunan',                               'AP',        'Social Studies — all levels',                      0, NULL),
(6,  'Edukasyon sa Pagpapakatao (EsP)',                  'ESP',       'Values Education — all levels',                    0, NULL),
(7,  'Music, Arts, Physical Education and Health (MAPEH)','MAPEH',    'Clustered learning area — all levels',             0, NULL),
(8,  'Good Manners and Right Conduct (GMRC)',            'GMRC',      'MATATAG Curriculum — Grades 1-6',                  0, NULL),
(9,  'Makabansa',                                        'MAKABANSA', 'MATATAG Curriculum — Grades 1-6; Filipino identity',0, NULL),
(10, 'Science',                                          'SCI',       'Science — introduced Grade 3; spiral progression', 0, NULL),
(11, 'Edukasyong Pantahanan at Pangkabuhayan (EPP)',     'EPP',       'Home Economics and Livelihood — Grades 4-6',       0, NULL),
(12, 'Technology and Livelihood Education (TLE)',        'TLE',       'Exploratory courses — JHS Grades 7-10',            0, NULL);

-- Optional: MAPEH component subjects (keeps existing MAPEH subject)
INSERT IGNORE INTO `subjects` (`subject_name`,`subject_code`,`description`,`is_deleted`,`deleted_at`) VALUES
('Music (MAPEH Component)',  'MUSIC',  'MAPEH component subject', 0, NULL),
('Arts (MAPEH Component)',   'ARTS',   'MAPEH component subject', 0, NULL),
('Physical Education (MAPEH Component)', 'PE', 'MAPEH component subject', 0, NULL),
('Health (MAPEH Component)', 'HEALTH', 'MAPEH component subject', 0, NULL);

-- ============================================================
-- LEARNERS
-- Denormalised: civil_status, religion, mother_tongue,
-- indigenous_group, citizenship, name_extension, learner_status
-- all inlined (dropped 7 small lookup tables)
-- ============================================================

CREATE TABLE `curricula` (
  `curriculum_id`   int(11)      NOT NULL AUTO_INCREMENT,
  `curriculum_code` varchar(30)  NOT NULL COMMENT 'e.g. K12-2013, MATATAG-2023',
  `curriculum_name` varchar(150) NOT NULL,
  `description`     text         DEFAULT NULL,
  `effective_from`  year(4)      NOT NULL,
  `effective_until` year(4)      DEFAULT NULL,
  `is_active`       tinyint(1)   NOT NULL DEFAULT 1,
  `is_deleted`      tinyint(1)   NOT NULL DEFAULT 0,
  `deleted_at`      datetime     DEFAULT NULL,
  `created_at`      datetime     DEFAULT current_timestamp(),
  `created_by`      int(11)      DEFAULT NULL,
  PRIMARY KEY (`curriculum_id`),
  UNIQUE KEY `uq_curriculum_code` (`curriculum_code`),
  KEY `idx_cur_active`    (`is_active`,`is_deleted`),
  KEY `fk_cur_created_by` (`created_by`),
  CONSTRAINT `fk_cur_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Master list of DepEd curriculum editions';

CREATE TABLE `curriculum_grade_levels` (
  `cgl_id`         int(11)    NOT NULL AUTO_INCREMENT,
  `curriculum_id`  int(11)    NOT NULL,
  `grade_level_id` int(11)    NOT NULL,
  `sort_order`     int(11)    DEFAULT NULL,
  `is_deleted`     tinyint(1) NOT NULL DEFAULT 0,
  `deleted_at`     datetime   DEFAULT NULL,
  PRIMARY KEY (`cgl_id`),
  UNIQUE KEY `uq_cgl_cur_grade` (`curriculum_id`,`grade_level_id`),
  KEY `idx_cgl_curriculum` (`curriculum_id`),
  KEY `idx_cgl_grade`      (`grade_level_id`),
  CONSTRAINT `fk_cgl_curriculum`  FOREIGN KEY (`curriculum_id`)  REFERENCES `curricula`    (`curriculum_id`),
  CONSTRAINT `fk_cgl_grade_level` FOREIGN KEY (`grade_level_id`) REFERENCES `grade_levels` (`grade_level_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Which grade levels are covered by a curriculum edition';

CREATE TABLE `curriculum_subjects` (
  `curriculum_subject_id` int(11)      NOT NULL AUTO_INCREMENT,
  `curriculum_id`         int(11)      NOT NULL,
  `grade_level_id`        int(11)      NOT NULL,
  `subject_id`            int(11)      NOT NULL,
  `is_required`           tinyint(1)   NOT NULL DEFAULT 1 COMMENT '0 = elective',
  `weekly_minutes`        int(11)      DEFAULT NULL,
  `sort_order`            int(11)      DEFAULT NULL,
  `notes`                 varchar(255) DEFAULT NULL,
  `is_deleted`            tinyint(1)   NOT NULL DEFAULT 0,
  `deleted_at`            datetime     DEFAULT NULL,
  PRIMARY KEY (`curriculum_subject_id`),
  UNIQUE KEY `uq_cs_cur_grade_subj` (`curriculum_id`,`grade_level_id`,`subject_id`),
  KEY `idx_cs_curriculum` (`curriculum_id`),
  KEY `idx_cs_grade`      (`grade_level_id`),
  KEY `idx_cs_subject`    (`subject_id`),
  CONSTRAINT `fk_cs_curriculum`  FOREIGN KEY (`curriculum_id`)  REFERENCES `curricula`    (`curriculum_id`),
  CONSTRAINT `fk_cs_grade_level` FOREIGN KEY (`grade_level_id`) REFERENCES `grade_levels` (`grade_level_id`),
  CONSTRAINT `fk_cs_subject`     FOREIGN KEY (`subject_id`)     REFERENCES `subjects`     (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Subject-grade level assignments per curriculum edition';

CREATE TABLE `curriculum_grading_components` (
  `component_id`   int(11)      NOT NULL AUTO_INCREMENT,
  `curriculum_id`  int(11)      NOT NULL,
  `grade_level_id` int(11)      DEFAULT NULL COMMENT 'NULL = all grades in this curriculum',
  `component_code` varchar(30)  NOT NULL COMMENT 'WW, PT, QE',
  `component_name` varchar(100) NOT NULL,
  `weight_percent` decimal(5,2) NOT NULL,
  `sort_order`     int(11)      DEFAULT NULL,
  `is_deleted`     tinyint(1)   NOT NULL DEFAULT 0,
  `deleted_at`     datetime     DEFAULT NULL,
  PRIMARY KEY (`component_id`),
  UNIQUE KEY `uq_cgc_cur_grade_code` (`curriculum_id`,`grade_level_id`,`component_code`),
  KEY `idx_cgc_curriculum` (`curriculum_id`),
  KEY `idx_cgc_grade`      (`grade_level_id`),
  CONSTRAINT `fk_cgc_curriculum`  FOREIGN KEY (`curriculum_id`)  REFERENCES `curricula`    (`curriculum_id`),
  CONSTRAINT `fk_cgc_grade_level` FOREIGN KEY (`grade_level_id`) REFERENCES `grade_levels` (`grade_level_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Grading component weights per curriculum (WW, PT, QE)';

CREATE TABLE `curriculum_passing_marks` (
  `passing_mark_id` int(11)      NOT NULL AUTO_INCREMENT,
  `curriculum_id`   int(11)      NOT NULL,
  `grade_level_id`  int(11)      DEFAULT NULL COMMENT 'NULL = all grade levels',
  `subject_id`      int(11)      DEFAULT NULL COMMENT 'NULL = all subjects',
  `passing_mark`    decimal(5,2) NOT NULL DEFAULT 60.00,
  `notes`           varchar(255) DEFAULT NULL,
  `is_deleted`      tinyint(1)   NOT NULL DEFAULT 0,
  `deleted_at`      datetime     DEFAULT NULL,
  PRIMARY KEY (`passing_mark_id`),
  UNIQUE KEY `uq_cpm_cur_grade_subj` (`curriculum_id`,`grade_level_id`,`subject_id`),
  KEY `idx_cpm_curriculum` (`curriculum_id`),
  KEY `fk_cpm_grade_level` (`grade_level_id`),
  KEY `fk_cpm_subject`     (`subject_id`),
  CONSTRAINT `fk_cpm_curriculum`  FOREIGN KEY (`curriculum_id`)  REFERENCES `curricula`    (`curriculum_id`),
  CONSTRAINT `fk_cpm_grade_level` FOREIGN KEY (`grade_level_id`) REFERENCES `grade_levels` (`grade_level_id`),
  CONSTRAINT `fk_cpm_subject`     FOREIGN KEY (`subject_id`)     REFERENCES `subjects`     (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Passing marks per curriculum, optionally per grade level or subject';

CREATE TABLE `curriculum_school_year_map` (
  `map_id`         int(11)    NOT NULL AUTO_INCREMENT,
  `curriculum_id`  int(11)    NOT NULL,
  `school_year_id` int(11)    NOT NULL,
  `is_primary`     tinyint(1) NOT NULL DEFAULT 1 COMMENT '1 = default curriculum for this SY',
  `is_deleted`     tinyint(1) NOT NULL DEFAULT 0,
  `deleted_at`     datetime   DEFAULT NULL,
  PRIMARY KEY (`map_id`),
  UNIQUE KEY `uq_csym_cur_sy` (`curriculum_id`,`school_year_id`),
  KEY `idx_csym_curriculum`  (`curriculum_id`),
  KEY `idx_csym_school_year` (`school_year_id`),
  CONSTRAINT `fk_csym_curriculum`  FOREIGN KEY (`curriculum_id`)  REFERENCES `curricula`    (`curriculum_id`),
  CONSTRAINT `fk_csym_school_year` FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Maps which curriculum is in effect for each school year';

-- ============================================================
-- SECTIONS
-- FIX 1: CHECK constraint inside CREATE TABLE (correct syntax)
-- school_year_id added — sections are per SY
-- ============================================================

CREATE TABLE `sections` (
  `section_id`     int(11)      NOT NULL AUTO_INCREMENT,
  `section_name`   varchar(100) NOT NULL,
  `grade_level_id` int(11)      NOT NULL,
  `school_year_id` int(11)      NOT NULL COMMENT 'Sections are per school year',
  `adviser_id`     int(11)      DEFAULT NULL COMMENT 'Class adviser / homeroom teacher',
  `max_capacity`   int(11)      NOT NULL DEFAULT 45 COMMENT 'Max enrolled learners allowed',
  `is_deleted`     tinyint(1)   DEFAULT 0,
  `deleted_at`     datetime     DEFAULT NULL,
  PRIMARY KEY (`section_id`),
  UNIQUE KEY `uq_section_grade_sy` (`grade_level_id`,`section_name`,`school_year_id`),
  KEY `idx_section_grade_level` (`grade_level_id`),
  KEY `idx_section_sy`          (`school_year_id`),
  KEY `idx_section_adviser`     (`adviser_id`),
  CONSTRAINT `chk_capacity`    CHECK (max_capacity > 0 AND max_capacity <= 60),
  CONSTRAINT `fk_section_grade` FOREIGN KEY (`grade_level_id`) REFERENCES `grade_levels` (`grade_level_id`),
  CONSTRAINT `fk_section_sy`    FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`),
  CONSTRAINT `fk_section_adviser` FOREIGN KEY (`adviser_id`) REFERENCES `employees` (`employee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Class sections per grade level per school year';

INSERT INTO `sections` (`section_id`,`section_name`,`grade_level_id`,`school_year_id`,`max_capacity`) VALUES
(2, 'Section Gemini', 1,  5, 45),
(3, 'Gold',           1,  5, 45),
(4, 'test grade 10',  10, 5, 45),
(5, 'Aquarius',       8,  5, 45);

-- ============================================================
-- SUBJECTS
-- subject_code inlined — DepEd codes are fixed constants
-- (dropped subject_codes table)
-- ============================================================

CREATE TABLE `learners` (
  `learner_id`                   int(11)      NOT NULL AUTO_INCREMENT,
  `user_id`                      int(11)      DEFAULT NULL,
  `lrn`                          varchar(20)  NOT NULL  COMMENT 'Learner Reference Number',
  `first_name`                   varchar(100) NOT NULL,
  `middle_name`                  varchar(100) DEFAULT NULL,
  `last_name`                    varchar(100) NOT NULL,
  `name_extension`               varchar(10)  DEFAULT NULL COMMENT 'Jr., Sr., II, III …',
  `date_of_birth`                date         DEFAULT NULL,
  `gender`                       ENUM('Male','Female','Other') DEFAULT NULL,
  `civil_status`                 ENUM('Single','Married','Widowed','Legally Separated','Annulled') DEFAULT NULL,
  `religion`                     varchar(100) DEFAULT NULL,
  `mother_tongue`                varchar(100) DEFAULT NULL,
  `indigenous_group`             varchar(150) DEFAULT NULL COMMENT 'NULL if not indigenous',
  `citizenship`                  varchar(100) DEFAULT 'Filipino',
  `learner_status`               ENUM(
                                   'Enrolled',
                                   'Temporarily Enrolled',
                                   'Promoted',
                                   'Conditionally Promoted',
                                   'Retained',
                                   'Transferred Out',
                                   'Dropped',
                                   'Graduated'
                                 ) DEFAULT NULL,
  `is_4ps_beneficiary`           tinyint(1)   DEFAULT 0,
  `is_indigenous`                tinyint(1)   DEFAULT 0,
  `completed`                    tinyint(1)   DEFAULT 0,
  `is_permanent_same_as_current` tinyint(1)   NOT NULL DEFAULT 1,
  `address`                      text         DEFAULT NULL COMMENT 'Free-text current address for quick display',
  `contact_number`               varchar(20)  DEFAULT NULL,
  `email`                        varchar(150) DEFAULT NULL,
  `is_deleted`                   tinyint(1)   DEFAULT 0,
  `deleted_at`                   datetime     DEFAULT NULL,
  PRIMARY KEY (`learner_id`),
  UNIQUE KEY `uq_learner_lrn`  (`lrn`),
  UNIQUE KEY `uq_learner_user` (`user_id`),
  CONSTRAINT `fk_learner_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Learner (student) master profiles';

INSERT INTO `learners`
  (`learner_id`,`user_id`,`lrn`,`first_name`,`middle_name`,`last_name`,`date_of_birth`,`gender`,`civil_status`,`religion`,`mother_tongue`,`indigenous_group`,`citizenship`,`is_4ps_beneficiary`,`is_indigenous`,`completed`,`is_deleted`,`deleted_at`,`is_permanent_same_as_current`)
VALUES
(4, NULL, '123123123123', 'Cloudenry',     'Blaan',  'Medina',   '2026-02-20', 'Male',   'Legally Separated', 'Aglipayan (Philippine Independent Church)', 'Bikol',  'Ata (Davao del Norte)', 'Filipino', 1, 1, 0, 0, NULL, 1),
(5, NULL, '123090909090', 'Bhala',         'T',      'Bords',    '2026-02-21', 'Male',   'Single',            'Waray',                                      'Cebuano','Ata (Davao del Norte)', 'Filipino', 1, 1, 1, 0, NULL, 1),
(6, NULL, '127000000810', 'Pitok Batolata','Luz',    'Kulas',    '2026-02-18', 'Male',   'Widowed',           'The Church of Jesus Christ of Latter-day Saints','Bikol', NULL,                 'Filipino', 0, 0, 0, 0, NULL, 1),
(7, NULL, '128000000920', 'Angeli',        'Hiñosa', 'Montalba', '2026-03-29', 'Female', 'Annulled',          'Chavacano',                                  'Tausug', NULL,                 'Filipino', 1, 0, 0, 0, NULL, 1);

-- ============================================================
-- GEO TABLES (province → city → barangay)
-- Kept normalised — genuinely shared across many learners
-- ============================================================

CREATE TABLE `geo_provinces` (
  `province_id`   int(11)      NOT NULL AUTO_INCREMENT,
  `psgc_code`     varchar(20)  DEFAULT NULL,
  `province_name` varchar(150) NOT NULL,
  `is_active`     tinyint(1)   NOT NULL DEFAULT 1,
  `created_at`    datetime     NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`province_id`),
  UNIQUE KEY `uq_geo_provinces_name` (`province_name`),
  UNIQUE KEY `uq_geo_provinces_psgc` (`psgc_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `geo_provinces` VALUES (1, '1004', 'Misamis Oriental', 1, '2026-02-21 05:18:41');

CREATE TABLE `geo_cities_municipalities` (
  `city_municipality_id`   int(11)      NOT NULL AUTO_INCREMENT,
  `province_id`            int(11)      NOT NULL,
  `psgc_code`              varchar(20)  DEFAULT NULL,
  `city_municipality_name` varchar(150) NOT NULL,
  `is_city`                tinyint(1)   NOT NULL DEFAULT 0,
  `is_active`              tinyint(1)   NOT NULL DEFAULT 1,
  `created_at`             datetime     NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`city_municipality_id`),
  UNIQUE KEY `uq_geo_citymun_prov_name` (`province_id`,`city_municipality_name`),
  KEY `idx_geo_citymun_province` (`province_id`),
  CONSTRAINT `fk_geo_citymun_province` FOREIGN KEY (`province_id`) REFERENCES `geo_provinces` (`province_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `geo_cities_municipalities` VALUES (1, 1, '100430', 'Gitagum', 0, 1, '2026-02-21 05:18:41');

CREATE TABLE `geo_barangays` (
  `barangay_id`          int(11)      NOT NULL AUTO_INCREMENT,
  `city_municipality_id` int(11)      NOT NULL,
  `psgc_code`            varchar(20)  DEFAULT NULL,
  `barangay_name`        varchar(150) NOT NULL,
  `is_active`            tinyint(1)   NOT NULL DEFAULT 1,
  `created_at`           datetime     NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`barangay_id`),
  UNIQUE KEY `uq_geo_barangay_city_name` (`city_municipality_id`,`barangay_name`),
  KEY `idx_geo_barangay_citymun` (`city_municipality_id`),
  CONSTRAINT `fk_geo_barangay_citymun` FOREIGN KEY (`city_municipality_id`) REFERENCES `geo_cities_municipalities` (`city_municipality_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `geo_barangays` VALUES
(1,  1, '1004309001', 'Burnay',                    1, '2026-02-21 05:18:41'),
(2,  1, '1004309002', 'Carlos P. Garcia',           1, '2026-02-21 05:18:41'),
(3,  1, '1004309004', 'Cogon',                      1, '2026-02-21 05:18:41'),
(4,  1, '1004309005', 'Gregorio Pelaez (Lagutay)',  1, '2026-02-21 05:18:41'),
(5,  1, '1004309006', 'Kilangit',                   1, '2026-02-21 05:18:41'),
(6,  1, '1004309007', 'Matangad',                   1, '2026-02-21 05:18:41'),
(7,  1, '1004309008', 'Pangayawan',                 1, '2026-02-21 05:18:41'),
(8,  1, '1004309009', 'Poblacion',                  1, '2026-02-21 05:18:41'),
(9,  1, '1004309010', 'Quezon',                     1, '2026-02-21 05:18:41'),
(10, 1, '1004309011', 'Tala-o',                     1, '2026-02-21 05:18:41'),
(11, 1, '1004309012', 'Ulab',                       1, '2026-02-21 05:18:41');

-- ============================================================
-- LEARNER ADDRESSES
-- ============================================================

CREATE TABLE `learner_addresses` (
  `learner_address_id`   int(11)      NOT NULL AUTO_INCREMENT,
  `learner_id`           int(11)      NOT NULL,
  `address_type`         ENUM('CURRENT','PERMANENT') NOT NULL,
  `house_no`             varchar(50)  DEFAULT NULL,
  `street_name`          varchar(150) DEFAULT NULL,
  `subdivision`          varchar(150) DEFAULT NULL,
  `zip_code`             varchar(10)  DEFAULT NULL,
  `province_id`          int(11)      DEFAULT NULL,
  `city_municipality_id` int(11)      DEFAULT NULL,
  `barangay_id`          int(11)      DEFAULT NULL,
  `country_name`         varchar(100) NOT NULL DEFAULT 'Philippines',
  `is_deleted`           tinyint(1)   NOT NULL DEFAULT 0,
  `deleted_at`           datetime     DEFAULT NULL,
  `created_at`           datetime     NOT NULL DEFAULT current_timestamp(),
  `updated_at`           datetime     DEFAULT NULL,
  PRIMARY KEY (`learner_address_id`),
  KEY `idx_la_learner`   (`learner_id`),
  KEY `idx_la_province`  (`province_id`),
  KEY `idx_la_citymun`   (`city_municipality_id`),
  KEY `idx_la_barangay`  (`barangay_id`),
  CONSTRAINT `fk_la_learner`  FOREIGN KEY (`learner_id`)           REFERENCES `learners`                 (`learner_id`),
  CONSTRAINT `fk_la_province` FOREIGN KEY (`province_id`)          REFERENCES `geo_provinces`             (`province_id`),
  CONSTRAINT `fk_la_citymun`  FOREIGN KEY (`city_municipality_id`) REFERENCES `geo_cities_municipalities` (`city_municipality_id`),
  CONSTRAINT `fk_la_barangay` FOREIGN KEY (`barangay_id`)          REFERENCES `geo_barangays`             (`barangay_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `learner_addresses`
  (`learner_address_id`,`learner_id`,`address_type`,`zip_code`,`province_id`,`city_municipality_id`,`barangay_id`,`is_deleted`,`created_at`)
VALUES
(2, 5, 'CURRENT', '123123', 1, 1, 1, 0, '2026-02-21 05:30:36'),
(4, 6, 'CURRENT', '20189',  1, 1, 4, 0, '2026-02-21 08:34:56'),
(6, 7, 'CURRENT', '1209',   1, 1, 7, 0, '2026-02-21 09:18:50');

-- ============================================================
-- FAMILY MEMBERS
-- relationship inlined as VARCHAR (dropped family_relationships table)
-- ============================================================

CREATE TABLE `family_members` (
  `family_member_id` int(11)       NOT NULL AUTO_INCREMENT,
  `learner_id`       int(11)       NOT NULL,
  `full_name`        varchar(200)  NOT NULL,
  `relationship`     varchar(50)   NOT NULL COMMENT 'Father, Mother, Legal Guardian …',
  `date_of_birth`    date          DEFAULT NULL,
  `occupation`       varchar(150)  DEFAULT NULL,
  `contact_number`   varchar(20)   DEFAULT NULL,
  `monthly_income`   decimal(12,2) DEFAULT NULL,
  `is_deleted`       tinyint(1)    DEFAULT 0,
  `deleted_at`       datetime      DEFAULT NULL,
  PRIMARY KEY (`family_member_id`),
  KEY `idx_family_learner` (`learner_id`),
  CONSTRAINT `fk_family_learner` FOREIGN KEY (`learner_id`) REFERENCES `learners` (`learner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Family background per learner';

INSERT INTO `family_members`
  (`family_member_id`,`learner_id`,`full_name`,`relationship`,`occupation`,`contact_number`,`is_deleted`,`deleted_at`)
VALUES
(23, 4, 'sdfsdfs',             'Father',       'dfsdfsd',       '2342343534',   0, NULL),
(24, 4, 'efgdfgdfgh',          'Mother',       'hfhfghfghgfh',  '34546456456',  0, NULL),
(25, 4, 'sgdfgdfgd',           'Step-Father',  'fdfbdfbdfb',    NULL,           0, NULL),
(26, 4, 'sfdfbdfb',            'Legal Guardian', NULL,          'bfgbfgbfgb',   0, NULL),
(29, 6, 'Guko B. Gohan',       'Father',       'Hired Killer',  '091231289329', 0, NULL),
(30, 6, 'Darna X. Batallion',  'Mother',       'Bad Ass Killer','091872318273', 0, NULL),
(34, 7, 'Montalba, Wilfredo',  'Father',       'Teaching',      '09873248234',  0, NULL),
(35, 7, 'Gladys H. Montalba',  'Mother',       'Prostitute',    '09723476237',  0, NULL),
(36, 7, 'Alwin Magallanes',    'Step-Father',  NULL,            NULL,           0, NULL);

-- ============================================================
-- EMERGENCY CONTACTS
-- relationship inlined as VARCHAR
-- ============================================================

CREATE TABLE `emergency_contacts` (
  `emergency_contact_id` int(11)      NOT NULL AUTO_INCREMENT,
  `learner_id`           int(11)      NOT NULL,
  `contact_name`         varchar(200) NOT NULL,
  `relationship`         varchar(50)  NOT NULL,
  `contact_number`       varchar(20)  DEFAULT NULL,
  `address`              text         DEFAULT NULL,
  `is_deleted`           tinyint(1)   DEFAULT 0,
  `deleted_at`           datetime     DEFAULT NULL,
  PRIMARY KEY (`emergency_contact_id`),
  KEY `idx_ec_learner` (`learner_id`),
  CONSTRAINT `fk_ec_learner` FOREIGN KEY (`learner_id`) REFERENCES `learners` (`learner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Emergency contacts per learner';

INSERT INTO `emergency_contacts` VALUES
(3,  3, 'Updated Emergency', 'Father', '09111222333',  NULL,        0, NULL),
(9,  4, 'dfgbfgbfgb',        'Father', '345345345',    'dfdfbdfb',  0, NULL),
(11, 6, 'Guko B. Gohan',     'Father', '091231289329', 'Carmen Cdo',0, NULL),
(13, 7, 'Gael Gatilogo',     'Father', '0981238348',   'Wao',       0, NULL);

-- ============================================================
-- ENROLLMENT TYPES
-- ============================================================

CREATE TABLE `enrollment_types` (
  `enrollment_type_id` int(11)      NOT NULL AUTO_INCREMENT,
  `type_name`          varchar(100) NOT NULL,
  `description`        varchar(255) DEFAULT NULL,
  `is_deleted`         tinyint(1)   DEFAULT 0,
  `deleted_at`         datetime     DEFAULT NULL,
  PRIMARY KEY (`enrollment_type_id`),
  UNIQUE KEY `uq_enrollment_type_name` (`type_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Enrollment type — New, Returning, Transfer-In, Balik-Aral';

INSERT INTO `enrollment_types` VALUES
(1, 'New Enrollee', 'Learner enrolling in a DepEd school for the first time',                            0, NULL),
(2, 'Returning',    'Learner previously enrolled, re-enrolling for a new school year',                   0, NULL),
(3, 'Transfer-In',  'Learner from another school transferring into this school (DO 54, s. 2016)',        0, NULL),
(4, 'Balik-Aral',   'Out-of-school youth returning to formal schooling after having dropped out',        0, NULL);

-- ============================================================
-- ENROLLMENTS
-- FIX 3: curriculum_id restored
-- ============================================================

CREATE TABLE `enrollments` (
  `enrollment_id`      int(11) NOT NULL AUTO_INCREMENT,
  `learner_id`         int(11) NOT NULL,
  `school_year_id`     int(11) NOT NULL,
  `grade_level_id`     int(11) NOT NULL,
  `section_id`         int(11) NOT NULL,
  `curriculum_id`      int(11) DEFAULT NULL COMMENT 'FK to curricula — which curriculum this enrollment follows',
  `enrollment_type_id` int(11) DEFAULT NULL,
  `enrollment_date`    date    DEFAULT NULL,
  `enrollment_status`  ENUM('Enrolled','Dropped','Transferred Out','Completed') NOT NULL DEFAULT 'Enrolled',
  `status_updated_at`  datetime DEFAULT current_timestamp(),
  `is_deleted`         tinyint(1) DEFAULT 0,
  `deleted_at`         datetime   DEFAULT NULL,
  PRIMARY KEY (`enrollment_id`),
  UNIQUE KEY `uq_learner_school_year`   (`learner_id`,`school_year_id`),
  KEY `idx_enroll_learner`     (`learner_id`),
  KEY `idx_enroll_sy`          (`school_year_id`),
  KEY `idx_enroll_grade`       (`grade_level_id`),
  KEY `idx_enroll_section`     (`section_id`),
  KEY `idx_enroll_curriculum`  (`curriculum_id`),
  KEY `idx_dash_composite`     (`school_year_id`,`grade_level_id`,`section_id`),
  KEY `fk_enroll_type_id`      (`enrollment_type_id`),
  CONSTRAINT `fk_enroll_learner`     FOREIGN KEY (`learner_id`)         REFERENCES `learners`          (`learner_id`),
  CONSTRAINT `fk_enroll_sy`          FOREIGN KEY (`school_year_id`)     REFERENCES `school_years`      (`school_year_id`),
  CONSTRAINT `fk_enroll_grade`       FOREIGN KEY (`grade_level_id`)     REFERENCES `grade_levels`      (`grade_level_id`),
  CONSTRAINT `fk_enroll_section`     FOREIGN KEY (`section_id`)         REFERENCES `sections`          (`section_id`),
  CONSTRAINT `fk_enroll_curriculum`  FOREIGN KEY (`curriculum_id`)      REFERENCES `curricula`         (`curriculum_id`),
  CONSTRAINT `fk_enroll_type_id`     FOREIGN KEY (`enrollment_type_id`) REFERENCES `enrollment_types`  (`enrollment_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Learner enrollment records per school year';

INSERT INTO `enrollments`
  (`enrollment_id`,`learner_id`,`school_year_id`,`grade_level_id`,`section_id`,`curriculum_id`,`enrollment_type_id`,`enrollment_date`,`is_deleted`,`deleted_at`)
VALUES
(5, 5, 5, 10, 4, NULL, 1, '2026-02-21', 0, NULL),
(6, 4, 5, 1,  3, NULL, 1, '2026-02-20', 0, NULL),
(8, 6, 5, 1,  2, NULL, 1, '2026-02-21', 0, NULL),
(9, 7, 5, 1,  3, NULL, 4, '2026-02-21', 0, NULL);

-- ============================================================
-- ENROLLMENT REQUIREMENTS
-- ============================================================

CREATE TABLE `document_types` (
  `document_type_id` int(11)      NOT NULL AUTO_INCREMENT,
  `type_name`        varchar(100) NOT NULL,
  `description`      varchar(255) DEFAULT NULL,
  `is_deleted`       tinyint(1)   DEFAULT 0,
  `deleted_at`       datetime     DEFAULT NULL,
  PRIMARY KEY (`document_type_id`),
  UNIQUE KEY `uq_document_type_name` (`type_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Types of documents required — PSA Birth Certificate, Form 137, Form 138, etc.';

INSERT INTO `document_types` VALUES
(1, 'PSA Birth Certificate',       'Primary enrollment document',                      0, NULL),
(2, 'Form 137 (Permanent Record)', 'Official DepEd permanent academic record',          0, NULL),
(3, 'Form 138 (Report Card)',       'Official DepEd report card',                       0, NULL),
(4, 'Certificate of Completion',   'Issued to Grade 6 and Grade 10 completers',        0, NULL),
(5, 'Good Moral Certificate',      'Character reference from previous school',          0, NULL),
(6, 'Diploma',                     'Issued to Grade 6 and Grade 12 graduates',         0, NULL),
(7, 'Barangay Certification',      'Acceptable substitute for PSA Birth Certificate',  0, NULL),
(8, 'LCR Birth Certificate',       'Local Civil Registrar-issued birth certificate',   0, NULL);

-- ============================================================
-- LEARNER DOCUMENTS
-- ============================================================

CREATE TABLE `enrollment_requirements` (
  `requirement_id`   int(11)      NOT NULL AUTO_INCREMENT,
  `school_year_id`   int(11)      NOT NULL,
  `grade_level_id`   int(11)      DEFAULT NULL COMMENT 'NULL = all grade levels',
  `document_type_id` int(11)      NOT NULL,
  `is_mandatory`     tinyint(1)   DEFAULT 1,
  `notes`            varchar(255) DEFAULT NULL,
  `is_deleted`       tinyint(1)   DEFAULT 0,
  `deleted_at`       datetime     DEFAULT NULL,
  PRIMARY KEY (`requirement_id`),
  UNIQUE KEY `uq_er_sy_grade_doc` (`school_year_id`,`grade_level_id`,`document_type_id`),
  KEY `idx_er_school_year`   (`school_year_id`),
  KEY `idx_er_grade_level`   (`grade_level_id`),
  KEY `idx_er_document_type` (`document_type_id`),
  CONSTRAINT `fk_er_school_year`   FOREIGN KEY (`school_year_id`)   REFERENCES `school_years`   (`school_year_id`),
  CONSTRAINT `fk_er_grade_level`   FOREIGN KEY (`grade_level_id`)   REFERENCES `grade_levels`   (`grade_level_id`),
  CONSTRAINT `fk_er_document_type` FOREIGN KEY (`document_type_id`) REFERENCES `document_types` (`document_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Document checklist per school year and grade level for enrollment';

-- ============================================================
-- CLASS OFFERINGS
-- ============================================================

CREATE TABLE `class_offerings` (
  `class_id`       int(11) NOT NULL AUTO_INCREMENT,
  `subject_id`     int(11) NOT NULL,
  `section_id`     int(11) NOT NULL,
  `teacher_id`     int(11) NOT NULL,
  `school_year_id` int(11) NOT NULL,
  `is_deleted`     tinyint(1) DEFAULT 0,
  `deleted_at`     datetime   DEFAULT NULL,
  PRIMARY KEY (`class_id`),
  UNIQUE KEY `uq_class_offering` (`subject_id`,`section_id`,`teacher_id`,`school_year_id`),
  KEY `idx_class_subject` (`subject_id`),
  KEY `idx_class_section` (`section_id`),
  KEY `idx_class_teacher` (`teacher_id`),
  KEY `idx_class_sy`      (`school_year_id`),
  CONSTRAINT `fk_class_subject` FOREIGN KEY (`subject_id`)     REFERENCES `subjects`     (`subject_id`),
  CONSTRAINT `fk_class_section` FOREIGN KEY (`section_id`)     REFERENCES `sections`     (`section_id`),
  CONSTRAINT `fk_class_teacher` FOREIGN KEY (`teacher_id`)     REFERENCES `employees`    (`employee_id`),
  CONSTRAINT `fk_class_sy`      FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Class offerings — subject + section + teacher per school year';

-- ============================================================
-- CLASS SCHEDULES
-- Needed for: teacher timetable, validation, and optional per-class attendance.
-- ============================================================

CREATE TABLE `class_schedules` (
  `schedule_id`  int(11) NOT NULL AUTO_INCREMENT,
  `class_id`     int(11) NOT NULL,
  `day_of_week`  ENUM('Mon','Tue','Wed','Thu','Fri','Sat') NOT NULL,
  `start_time`   time    NOT NULL,
  `end_time`     time    NOT NULL,
  `room`         varchar(50) DEFAULT NULL,
  `notes`        varchar(255) DEFAULT NULL,
  `created_at`   datetime DEFAULT current_timestamp(),
  `updated_at`   datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_deleted`   tinyint(1) DEFAULT 0,
  `deleted_at`   datetime   DEFAULT NULL,
  PRIMARY KEY (`schedule_id`),
  UNIQUE KEY `uq_class_schedule_slot` (`class_id`,`day_of_week`,`start_time`,`end_time`),
  KEY `idx_cs_class` (`class_id`),
  KEY `idx_cs_day` (`day_of_week`),
  CONSTRAINT `chk_cs_time_order` CHECK (end_time > start_time),
  CONSTRAINT `fk_cs_class` FOREIGN KEY (`class_id`) REFERENCES `class_offerings` (`class_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Schedules per class offering; supports timetables and validations';

INSERT INTO `class_offerings` VALUES
(1, 5,  2, 1,  2, 0, NULL),
(2, 3,  2, 1,  2, 0, NULL),
(3, 8,  2, 1,  2, 0, NULL),
(4, 10, 3, 1,  2, 0, NULL),
(5, 2,  3, 26, 5, 0, NULL);

-- ============================================================
-- GRADING PERIODS
-- status inlined as ENUM (dropped grading_period_statuses table)
-- ============================================================

CREATE TABLE `grading_periods` (
  `grading_period_id` int(11)    NOT NULL AUTO_INCREMENT,
  `school_year_id`    int(11)    NOT NULL,
  `period_name`       varchar(50) NOT NULL COMMENT 'e.g. 1st Quarter',
  `status`            ENUM('Open','Submitted','Approved','Locked') NOT NULL DEFAULT 'Open',
  `date_start`        date       DEFAULT NULL,
  `date_end`          date       DEFAULT NULL,
  `locked_by`         int(11)    DEFAULT NULL,
  `locked_at`         datetime   DEFAULT NULL,
  `is_deleted`        tinyint(1) DEFAULT 0,
  `deleted_at`        datetime   DEFAULT NULL,
  PRIMARY KEY (`grading_period_id`),
  UNIQUE KEY `uq_period_school_year` (`school_year_id`,`period_name`),
  KEY `idx_gp_locked_by` (`locked_by`),
  CONSTRAINT `fk_gp_locked_by` FOREIGN KEY (`locked_by`)      REFERENCES `users`        (`user_id`),
  CONSTRAINT `fk_gp_sy`        FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Quarterly grading periods per school year with lock workflow';

INSERT INTO `grading_periods`
  (`grading_period_id`,`school_year_id`,`period_name`,`status`,`date_start`,`date_end`)
VALUES
(5, 2, 'P1',            'Open', '2026-02-20', '2026-04-10'),
(6, 5, 'FIRST GRADING', 'Open', '2026-02-21', '2026-02-28');

-- ============================================================
-- GRADES  (quarterly component scores)
-- ============================================================

CREATE TABLE `grades` (
  `grade_id`          int(11)      NOT NULL AUTO_INCREMENT,
  `enrollment_id`     int(11)      NOT NULL,
  `class_id`          int(11)      NOT NULL,
  `grading_period_id` int(11)      NOT NULL,
  `written_works`     decimal(5,2) DEFAULT NULL,
  `performance_tasks` decimal(5,2) DEFAULT NULL,
  `quarterly_exam`    decimal(5,2) DEFAULT NULL,
  `quarterly_grade`   decimal(5,2) DEFAULT NULL,
  `encoded_by`        int(11)      DEFAULT NULL,
  `encoded_at`        datetime     DEFAULT current_timestamp(),
  `updated_at`        datetime     DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_deleted`        tinyint(1)   DEFAULT 0,
  `deleted_at`        datetime     DEFAULT NULL,
  PRIMARY KEY (`grade_id`),
  UNIQUE KEY `uq_grade_entry` (`enrollment_id`,`class_id`,`grading_period_id`),
  KEY `idx_grade_class`  (`class_id`),
  KEY `idx_grade_period` (`grading_period_id`),
  CONSTRAINT `fk_grade_enroll` FOREIGN KEY (`enrollment_id`)     REFERENCES `enrollments`     (`enrollment_id`),
  CONSTRAINT `fk_grade_class`  FOREIGN KEY (`class_id`)          REFERENCES `class_offerings` (`class_id`),
  CONSTRAINT `fk_grade_period` FOREIGN KEY (`grading_period_id`) REFERENCES `grading_periods` (`grading_period_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Per-subject quarterly grade entries';

-- ============================================================
-- FINAL GRADES
-- remark inlined as ENUM (dropped grade_remarks table)
-- ============================================================

CREATE TABLE `final_grades` (
  `final_grade_id` int(11)      NOT NULL AUTO_INCREMENT,
  `enrollment_id`  int(11)      NOT NULL,
  `class_id`       int(11)      NOT NULL,
  `final_grade`    decimal(5,2) DEFAULT NULL,
  `remark`         ENUM('Passed','Failed') NOT NULL DEFAULT 'Failed',
  `computed_by`    int(11)      DEFAULT NULL,
  `computed_at`    datetime     DEFAULT current_timestamp(),
  `is_deleted`     tinyint(1)   DEFAULT 0,
  `deleted_at`     datetime     DEFAULT NULL,
  PRIMARY KEY (`final_grade_id`),
  UNIQUE KEY `uq_final_grade_enrollment_class` (`enrollment_id`,`class_id`),
  KEY `idx_fg_class`       (`class_id`),
  KEY `idx_fg_computed_by` (`computed_by`),
  CONSTRAINT `fk_fg_enrollment`  FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments`     (`enrollment_id`),
  CONSTRAINT `fk_fg_class`       FOREIGN KEY (`class_id`)      REFERENCES `class_offerings` (`class_id`),
  CONSTRAINT `fk_fg_computed_by` FOREIGN KEY (`computed_by`)   REFERENCES `users`           (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Final computed grade per subject per learner per school year';

-- ============================================================
-- GENERAL AVERAGES
-- ============================================================

CREATE TABLE `general_averages` (
  `general_average_id` int(11)      NOT NULL AUTO_INCREMENT,
  `enrollment_id`      int(11)      NOT NULL,
  `school_year_id`     int(11)      NOT NULL,
  `general_average`    decimal(5,2) DEFAULT NULL,
  `computed_by`        int(11)      DEFAULT NULL,
  `computed_at`        datetime     DEFAULT current_timestamp(),
  `is_deleted`         tinyint(1)   DEFAULT 0,
  `deleted_at`         datetime     DEFAULT NULL,
  PRIMARY KEY (`general_average_id`),
  UNIQUE KEY `uq_ga_enrollment` (`enrollment_id`),
  KEY `idx_ga_school_year`  (`school_year_id`),
  KEY `idx_ga_computed_by`  (`computed_by`),
  CONSTRAINT `fk_ga_enrollment`  FOREIGN KEY (`enrollment_id`)  REFERENCES `enrollments`  (`enrollment_id`),
  CONSTRAINT `fk_ga_school_year` FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`),
  CONSTRAINT `fk_ga_computed_by` FOREIGN KEY (`computed_by`)    REFERENCES `users`        (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Computed general average per learner per school year';

-- ============================================================
-- ATTENDANCE
-- FIX 2: class_id is NOT NULL DEFAULT 0
--   0  = whole-day / homeroom (sentinel value)
--   >0 = specific class_offering
-- This makes the UNIQUE key (enrollment_id, class_id, attendance_date)
-- work correctly — NULL values would bypass uniqueness in MariaDB.
-- ============================================================

CREATE TABLE `attendance` (
  `attendance_id`     int(11)  NOT NULL AUTO_INCREMENT,
  `enrollment_id`     int(11)  NOT NULL,
  `class_id`          int(11)  NOT NULL DEFAULT 0 COMMENT '0 = whole-day homeroom; >0 = specific class',
  `grading_period_id` int(11)  NOT NULL,
  `attendance_date`   date     NOT NULL,
  `status`            ENUM('Present','Absent','Late','Excused') NOT NULL DEFAULT 'Present',
  `remarks`           varchar(255) DEFAULT NULL,
  `recorded_by`       int(11)  DEFAULT NULL,
  `recorded_at`       datetime DEFAULT current_timestamp(),
  `is_deleted`        tinyint(1) DEFAULT 0,
  `deleted_at`        datetime   DEFAULT NULL,
  PRIMARY KEY (`attendance_id`),
  UNIQUE KEY `uq_attendance_entry` (`enrollment_id`,`class_id`,`attendance_date`),
  KEY `idx_att_enrollment` (`enrollment_id`),
  KEY `idx_att_class`      (`class_id`),
  KEY `idx_att_period`     (`grading_period_id`),
  KEY `idx_att_date`       (`attendance_date`),
  KEY `idx_att_status`     (`status`),
  CONSTRAINT `fk_att_enrollment` FOREIGN KEY (`enrollment_id`)     REFERENCES `enrollments`     (`enrollment_id`),
  CONSTRAINT `fk_att_period`     FOREIGN KEY (`grading_period_id`) REFERENCES `grading_periods` (`grading_period_id`),
  CONSTRAINT `fk_att_recorded`   FOREIGN KEY (`recorded_by`)       REFERENCES `users`           (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Daily or per-period attendance. class_id=0 means whole-day homeroom record.';

-- ============================================================
-- SF2: MONTHLY ATTENDANCE SUMMARIES
-- Stored monthly totals per enrollment for SF2 print/export.
-- ============================================================

CREATE TABLE `attendance_monthly_summaries` (
  `summary_id`        int(11) NOT NULL AUTO_INCREMENT,
  `enrollment_id`     int(11) NOT NULL,
  `school_year_id`    int(11) NOT NULL,
  `month_no`          tinyint(3) unsigned NOT NULL COMMENT '1..12',
  `total_school_days` int(11) DEFAULT NULL,
  `days_present`      int(11) DEFAULT 0,
  `days_absent`       int(11) DEFAULT 0,
  `days_late`         int(11) DEFAULT 0,
  `days_excused`      int(11) DEFAULT 0,
  `computed_by`       int(11) DEFAULT NULL,
  `computed_at`       datetime DEFAULT current_timestamp(),
  `updated_at`        datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_deleted`        tinyint(1) DEFAULT 0,
  `deleted_at`        datetime DEFAULT NULL,
  PRIMARY KEY (`summary_id`),
  UNIQUE KEY `uq_att_monthly` (`enrollment_id`,`school_year_id`,`month_no`),
  KEY `idx_att_monthly_sy` (`school_year_id`,`month_no`),
  CONSTRAINT `chk_att_month_no` CHECK (month_no >= 1 AND month_no <= 12),
  CONSTRAINT `fk_att_monthly_enrollment` FOREIGN KEY (`enrollment_id`)  REFERENCES `enrollments` (`enrollment_id`),
  CONSTRAINT `fk_att_monthly_sy`         FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`),
  CONSTRAINT `fk_att_monthly_user`       FOREIGN KEY (`computed_by`)    REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='SF2-ready stored monthly attendance totals per learner enrollment';

-- ============================================================
-- REPORT CARDS  (header snapshot)
-- Snapshot fields make reprint self-contained without re-joining.
-- ============================================================

CREATE TABLE `report_cards` (
  `report_card_id`    int(11)      NOT NULL AUTO_INCREMENT,
  `enrollment_id`     int(11)      NOT NULL,
  `grading_period_id` int(11)      NOT NULL,
  -- Header snapshot at generation time -----------------------
  `learner_name`      varchar(300) DEFAULT NULL COMMENT 'Full name at generation time',
  `lrn`               varchar(20)  DEFAULT NULL,
  `grade_level_name`  varchar(50)  DEFAULT NULL,
  `section_name`      varchar(100) DEFAULT NULL,
  `school_year_label` varchar(20)  DEFAULT NULL,
  `general_average`   decimal(5,2) DEFAULT NULL,
  `days_present`      int(11)      DEFAULT NULL,
  `days_absent`       int(11)      DEFAULT NULL,
  `days_late`         int(11)      DEFAULT NULL,
  -- File & audit ---------------------------------------------
  `file_path`         varchar(255) DEFAULT NULL COMMENT 'Path to generated PDF file',
  `generated_at`      datetime     DEFAULT current_timestamp(),
  `generated_by`      int(11)      DEFAULT NULL,
  `is_deleted`        tinyint(1)   DEFAULT 0,
  `deleted_at`        datetime     DEFAULT NULL,
  PRIMARY KEY (`report_card_id`),
  UNIQUE KEY `uq_rc_enrollment_period` (`enrollment_id`,`grading_period_id`),
  KEY `idx_rc_period`       (`grading_period_id`),
  KEY `idx_rc_generated_by` (`generated_by`),
  CONSTRAINT `fk_rc_enroll`    FOREIGN KEY (`enrollment_id`)     REFERENCES `enrollments`     (`enrollment_id`),
  CONSTRAINT `fk_rc_period`    FOREIGN KEY (`grading_period_id`) REFERENCES `grading_periods` (`grading_period_id`),
  CONSTRAINT `fk_rc_generated` FOREIGN KEY (`generated_by`)      REFERENCES `users`           (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Generated report card header — snapshot allows reprint without live joins';

-- ============================================================
-- REPORT CARD GRADES  (FIX 4 — per-subject snapshot)
-- One row per subject per report card.
-- Populated at generation time so reprinting is fully offline.
-- ============================================================

CREATE TABLE `report_card_grades` (
  `rc_grade_id`     int(11)      NOT NULL AUTO_INCREMENT,
  `report_card_id`  int(11)      NOT NULL,
  `subject_name`    varchar(150) NOT NULL  COMMENT 'Snapshot of subject name at generation time',
  `subject_code`    varchar(50)  DEFAULT NULL,
  `quarterly_grade` decimal(5,2) DEFAULT NULL,
  `final_grade`     decimal(5,2) DEFAULT NULL,
  `remark`          ENUM('Passed','Failed') DEFAULT NULL,
  PRIMARY KEY (`rc_grade_id`),
  UNIQUE KEY `uq_rcg_card_subject` (`report_card_id`,`subject_name`),
  KEY `idx_rcg_report_card` (`report_card_id`),
  CONSTRAINT `fk_rcg_report_card` FOREIGN KEY (`report_card_id`) REFERENCES `report_cards` (`report_card_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Per-subject grade snapshot per report card — enables full offline reprint';

-- ============================================================
-- HONOR LEVELS
-- ============================================================

CREATE TABLE `honor_levels` (
  `honor_level_id` int(11)      NOT NULL AUTO_INCREMENT,
  `honor_name`     varchar(100) NOT NULL,
  `min_average`    decimal(5,2) DEFAULT NULL,
  `max_average`    decimal(5,2) DEFAULT NULL,
  `description`    varchar(255) DEFAULT NULL,
  `is_deleted`     tinyint(1)   DEFAULT 0,
  `deleted_at`     datetime     DEFAULT NULL,
  PRIMARY KEY (`honor_level_id`),
  UNIQUE KEY `uq_honor_name` (`honor_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Honor level classification — With Highest Honors, With High Honors, With Honors';

INSERT INTO `honor_levels` VALUES
(1, 'With Highest Honors', 98.00, 100.00, 'GA of 98–100 (DO 36, s. 2016)', 0, NULL),
(2, 'With High Honors',    95.00, 97.99,  'GA of 95–97 (DO 36, s. 2016)',  0, NULL),
(3, 'With Honors',         90.00, 94.99,  'GA of 90–94 (DO 36, s. 2016)',  0, NULL);

-- ============================================================
-- SECTION RANKINGS
-- ============================================================

CREATE TABLE `section_rankings` (
  `ranking_id`     int(11)  NOT NULL AUTO_INCREMENT,
  `enrollment_id`  int(11)  NOT NULL,
  `section_id`     int(11)  NOT NULL,
  `school_year_id` int(11)  NOT NULL,
  `rank`           int(11)  DEFAULT NULL,
  `honor_level_id` int(11)  DEFAULT NULL,
  `ranked_by`      int(11)  DEFAULT NULL,
  `ranked_at`      datetime DEFAULT current_timestamp(),
  `is_deleted`     tinyint(1) DEFAULT 0,
  `deleted_at`     datetime   DEFAULT NULL,
  PRIMARY KEY (`ranking_id`),
  UNIQUE KEY `uq_ranking_enrollment`  (`enrollment_id`),
  KEY `idx_ranking_section_sy` (`section_id`,`school_year_id`),
  KEY `idx_ranking_honor`      (`honor_level_id`),
  KEY `idx_ranking_ranked_by`  (`ranked_by`),
  CONSTRAINT `fk_sr_enrollment`  FOREIGN KEY (`enrollment_id`)  REFERENCES `enrollments`  (`enrollment_id`),
  CONSTRAINT `fk_sr_section`     FOREIGN KEY (`section_id`)     REFERENCES `sections`     (`section_id`),
  CONSTRAINT `fk_sr_school_year` FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`),
  CONSTRAINT `fk_sr_honor`       FOREIGN KEY (`honor_level_id`) REFERENCES `honor_levels` (`honor_level_id`),
  CONSTRAINT `fk_sr_ranked_by`   FOREIGN KEY (`ranked_by`)      REFERENCES `users`        (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Section honor rankings per learner per school year';

-- ============================================================
-- RISK LEVELS
-- ============================================================

CREATE TABLE `risk_levels` (
  `risk_level_id` int(11)      NOT NULL AUTO_INCREMENT,
  `risk_name`     varchar(50)  NOT NULL,
  `description`   varchar(255) DEFAULT NULL,
  `color_code`    varchar(10)  DEFAULT NULL COMMENT 'Hex color for UI e.g. #FF0000',
  `is_deleted`    tinyint(1)   DEFAULT 0,
  `deleted_at`    datetime     DEFAULT NULL,
  PRIMARY KEY (`risk_level_id`),
  UNIQUE KEY `uq_risk_name` (`risk_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Risk level classification — Low, Moderate, High, Critical';

INSERT INTO `risk_levels` VALUES
(1, 'Low',      'Routine monitoring only',                                             '#28A745', 0, NULL),
(2, 'Moderate', 'Early warning; advisory support required',                            '#FFC107', 0, NULL),
(3, 'High',     'Failing 1-2 subjects or chronic absences; active intervention needed','#FF6B35', 0, NULL),
(4, 'Critical', 'High risk of dropout; urgent escalation to school head',              '#DC3545', 0, NULL);

-- ============================================================
-- RISK ASSESSMENTS
-- ============================================================

CREATE TABLE `risk_assessments` (
  `risk_assessment_id` int(11)  NOT NULL AUTO_INCREMENT,
  `enrollment_id`      int(11)  NOT NULL,
  `grading_period_id`  int(11)  NOT NULL,
  `risk_level_id`      int(11)  NOT NULL,
  `assessed_by`        int(11)  DEFAULT NULL,
  `assessed_at`        datetime DEFAULT current_timestamp(),
  `notes`              text     DEFAULT NULL,
  `is_deleted`         tinyint(1) DEFAULT 0,
  `deleted_at`         datetime   DEFAULT NULL,
  PRIMARY KEY (`risk_assessment_id`),
  UNIQUE KEY `uq_risk_enrollment_period` (`enrollment_id`,`grading_period_id`),
  KEY `idx_risk_period`     (`grading_period_id`),
  KEY `idx_risk_level`      (`risk_level_id`),
  KEY `idx_risk_assessed_by`(`assessed_by`),
  CONSTRAINT `fk_risk_enroll`      FOREIGN KEY (`enrollment_id`)     REFERENCES `enrollments`     (`enrollment_id`),
  CONSTRAINT `fk_risk_period`      FOREIGN KEY (`grading_period_id`) REFERENCES `grading_periods` (`grading_period_id`),
  CONSTRAINT `fk_risk_level`       FOREIGN KEY (`risk_level_id`)     REFERENCES `risk_levels`     (`risk_level_id`),
  CONSTRAINT `fk_risk_assessed_by` FOREIGN KEY (`assessed_by`)       REFERENCES `users`           (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Risk level assessment per learner per grading period';

INSERT INTO `risk_assessments` VALUES
(2, 6, 6, 4, 27, '2026-02-21 12:44:01', '',        0, NULL),
(3, 5, 6, 3, 1,  '2026-02-23 10:42:48', 'Urgent!', 0, NULL);

-- ============================================================
-- RISK INDICATORS
-- ============================================================

CREATE TABLE `risk_indicators` (
  `indicator_id`       int(11)      NOT NULL AUTO_INCREMENT,
  `risk_assessment_id` int(11)      NOT NULL,
  `indicator_type`     varchar(100) DEFAULT NULL COMMENT 'Attendance, Grade Drop, Behavioral …',
  `details`            text         DEFAULT NULL,
  `is_deleted`         tinyint(1)   DEFAULT 0,
  `deleted_at`         datetime     DEFAULT NULL,
  PRIMARY KEY (`indicator_id`),
  KEY `idx_ri_assessment` (`risk_assessment_id`),
  CONSTRAINT `fk_ri_assessment` FOREIGN KEY (`risk_assessment_id`) REFERENCES `risk_assessments` (`risk_assessment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Individual risk indicator flags tied to a risk assessment';

INSERT INTO `risk_indicators` VALUES (1, 2, 'Grade Drop', '', 0, NULL);

-- ============================================================
-- INTERVENTIONS
-- status inlined as ENUM (dropped intervention_statuses table)
-- ============================================================

CREATE TABLE `interventions` (
  `intervention_id`    int(11)      NOT NULL AUTO_INCREMENT,
  `enrollment_id`      int(11)      NOT NULL,
  `risk_assessment_id` int(11)      NOT NULL,
  `intervention_type`  varchar(150) DEFAULT NULL,
  `description`        text         DEFAULT NULL,
  `conducted_by`       int(11)      DEFAULT NULL,
  `conducted_at`       datetime     DEFAULT NULL,
  `follow_up_date`     date         DEFAULT NULL,
  `status`             ENUM('Pending','Ongoing','Resolved','Escalated') NOT NULL DEFAULT 'Pending',
  `notes`              text         DEFAULT NULL,
  `is_deleted`         tinyint(1)   DEFAULT 0,
  `deleted_at`         datetime     DEFAULT NULL,
  PRIMARY KEY (`intervention_id`),
  KEY `idx_iv_enrollment` (`enrollment_id`),
  KEY `idx_iv_risk`       (`risk_assessment_id`),
  KEY `idx_iv_conductor`  (`conducted_by`),
  CONSTRAINT `fk_iv_enrollment` FOREIGN KEY (`enrollment_id`)      REFERENCES `enrollments`      (`enrollment_id`),
  CONSTRAINT `fk_iv_risk`       FOREIGN KEY (`risk_assessment_id`) REFERENCES `risk_assessments` (`risk_assessment_id`),
  CONSTRAINT `fk_iv_conductor`  FOREIGN KEY (`conducted_by`)       REFERENCES `employees`        (`employee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Intervention records for at-risk learners';

INSERT INTO `interventions` VALUES
(2, 6, 2, 'Parent Conference', 's', 27, NULL, '2026-02-21', 'Ongoing', 's', 0, NULL);

-- ============================================================
-- DOCUMENT TYPES
-- ============================================================

CREATE TABLE `learner_documents` (
  `document_id`      int(11)      NOT NULL AUTO_INCREMENT,
  `learner_id`       int(11)      NOT NULL,
  `enrollment_id`    int(11)      DEFAULT NULL,
  `school_year_id`   int(11)      DEFAULT NULL,
  `document_type_id` int(11)      NOT NULL,
  `file_path`        varchar(255) DEFAULT NULL,
  `submitted_at`     datetime     DEFAULT current_timestamp(),
  `submitted_by`     int(11)      DEFAULT NULL,
  `remarks`          varchar(255) DEFAULT NULL,
  `is_deleted`       tinyint(1)   DEFAULT 0,
  `deleted_at`       datetime     DEFAULT NULL,
  PRIMARY KEY (`document_id`),
  KEY `idx_ld_learner`       (`learner_id`),
  KEY `idx_ld_enrollment`    (`enrollment_id`),
  KEY `idx_ld_document_type` (`document_type_id`),
  KEY `idx_ld_submitted_by`  (`submitted_by`),
  KEY `idx_ld_school_year`   (`school_year_id`),
  CONSTRAINT `fk_ld_learner`       FOREIGN KEY (`learner_id`)       REFERENCES `learners`       (`learner_id`),
  CONSTRAINT `fk_ld_enrollment`    FOREIGN KEY (`enrollment_id`)    REFERENCES `enrollments`    (`enrollment_id`),
  CONSTRAINT `fk_ld_document_type` FOREIGN KEY (`document_type_id`) REFERENCES `document_types` (`document_type_id`),
  CONSTRAINT `fk_ld_school_year`   FOREIGN KEY (`school_year_id`)   REFERENCES `school_years`   (`school_year_id`),
  CONSTRAINT `fk_ld_submitted_by`  FOREIGN KEY (`submitted_by`)     REFERENCES `users`          (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Documents submitted per learner — PSA, Form 137, Form 138, etc.';

-- ============================================================
-- LEARNER PREVIOUS SCHOOLS
-- ============================================================

CREATE TABLE `learner_previous_schools` (
  `previous_school_id`         int(11)      NOT NULL AUTO_INCREMENT,
  `learner_id`                 int(11)      NOT NULL,
  `enrollment_id`              int(11)      DEFAULT NULL,
  `last_grade_level_completed` varchar(50)  DEFAULT NULL,
  `last_school_year_completed` varchar(20)  DEFAULT NULL,
  `last_school_attended`       varchar(200) DEFAULT NULL,
  `last_school_id`             varchar(20)  DEFAULT NULL COMMENT 'DepEd School ID of previous school',
  `is_deleted`                 tinyint(1)   DEFAULT 0,
  `deleted_at`                 datetime     DEFAULT NULL,
  PRIMARY KEY (`previous_school_id`),
  KEY `idx_lps_learner`    (`learner_id`),
  KEY `idx_lps_enrollment` (`enrollment_id`),
  CONSTRAINT `fk_lps_learner`    FOREIGN KEY (`learner_id`)    REFERENCES `learners`    (`learner_id`),
  CONSTRAINT `fk_lps_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`enrollment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Previous school records for Balik-Aral and transfer-in learners';

-- ============================================================
-- LEARNING MODALITIES
-- ============================================================

CREATE TABLE `learning_modalities` (
  `modality_id`   int(11)      NOT NULL AUTO_INCREMENT,
  `modality_name` varchar(100) NOT NULL,
  `description`   varchar(255) DEFAULT NULL,
  `is_deleted`    tinyint(1)   DEFAULT 0,
  `deleted_at`    datetime     DEFAULT NULL,
  PRIMARY KEY (`modality_id`),
  UNIQUE KEY `uq_learning_modality_name` (`modality_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Distance learning modalities — Modular, Online, TV/Radio, Blended, etc.';

INSERT INTO `learning_modalities` VALUES
(1, 'Face-to-Face',                     'Traditional in-person classroom instruction',                        0, NULL),
(2, 'Modular Distance Learning (Print)', 'Self-Learning Modules in print',                                    0, NULL),
(3, 'Modular Distance Learning (Digital)','Self-Learning Modules via USB, CD, or digital devices',            0, NULL),
(4, 'Online Distance Learning',          'Synchronous and asynchronous learning via internet platforms',      0, NULL),
(5, 'TV-Based Instruction',              'Learning via DepEd TV broadcasts',                                  0, NULL),
(6, 'Radio-Based Instruction',           'Learning via radio broadcast; for remote areas',                    0, NULL),
(7, 'Blended Learning',                  'Combination of two or more modalities',                             0, NULL),
(8, 'Home Study Program',                'Formally supervised home learning for learners with special needs', 0, NULL);

-- ============================================================
-- LEARNER PREFERRED MODALITIES
-- ============================================================

CREATE TABLE `learner_preferred_modalities` (
  `preference_id` int(11)    NOT NULL AUTO_INCREMENT,
  `enrollment_id` int(11)    NOT NULL COMMENT 'SY-specific',
  `modality_id`   int(11)    NOT NULL,
  `is_deleted`    tinyint(1) DEFAULT 0,
  `deleted_at`    datetime   DEFAULT NULL,
  PRIMARY KEY (`preference_id`),
  UNIQUE KEY `uq_enroll_modality` (`enrollment_id`,`modality_id`),
  KEY `idx_lpm_enrollment` (`enrollment_id`),
  KEY `idx_lpm_modality`   (`modality_id`),
  CONSTRAINT `fk_lpm_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments`        (`enrollment_id`),
  CONSTRAINT `fk_lpm_modality`   FOREIGN KEY (`modality_id`)   REFERENCES `learning_modalities` (`modality_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Learner preferred distance learning modalities per enrollment — multi-select';

-- ============================================================
-- ANNOUNCEMENTS
-- ============================================================

CREATE TABLE `announcements` (
  `announcement_id` int(11)      NOT NULL AUTO_INCREMENT,
  `title`           varchar(200) NOT NULL,
  `body`            text         NOT NULL,
  `posted_by`       int(11)      NOT NULL,
  `target_role_id`  int(11)      DEFAULT NULL COMMENT 'NULL = visible to all roles',
  `published_at`    datetime     DEFAULT current_timestamp(),
  `expires_at`      datetime     DEFAULT NULL,
  `is_pinned`       tinyint(1)   DEFAULT 0,
  `attachment_url`  varchar(500) DEFAULT NULL,
  `is_deleted`      tinyint(1)   DEFAULT 0,
  `deleted_at`      datetime     DEFAULT NULL,
  PRIMARY KEY (`announcement_id`),
  KEY `idx_ann_posted_by`   (`posted_by`),
  KEY `idx_ann_target_role` (`target_role_id`),
  KEY `idx_published_at`    (`published_at`),
  CONSTRAINT `fk_ann_posted_by`   FOREIGN KEY (`posted_by`)      REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_ann_target_role` FOREIGN KEY (`target_role_id`) REFERENCES `roles` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='School-wide announcements — enrollment schedules, events, urgent notices';

INSERT INTO `announcements`
  (`announcement_id`,`title`,`body`,`posted_by`,`target_role_id`,`published_at`,`is_pinned`,`is_deleted`,`deleted_at`)
VALUES
(6,  'Welcome to Academic Year 2025-2026',  'We are excited to welcome all students and faculty to the new academic year! Classes begin on Monday.',                    1, NULL, '2026-02-20 22:37:10', 0, 0, NULL),
(7,  'Parent-Teacher Meeting This Friday',  'All parents are invited. Venue: School Auditorium. Time: 2:00 PM – 5:00 PM.',                                             1, NULL, '2026-02-20 20:37:43', 0, 0, NULL),
(8,  'School Clinic Hours Extended',        'Our school clinic will now be open from 7:00 AM to 6:00 PM daily.',                                                       1, NULL, '2026-02-20 17:37:43', 0, 0, NULL),
(9,  'Upcoming Science Fair',               'The annual Science Fair will be held on March 15, 2026. Registration forms available at the Science Department.',         1, NULL, '2026-02-19 22:37:43', 0, 0, NULL),
(38, 'Deadline Notice',                     'Grade Submission Deadline on October 1, 2027! Stay tuned!',                                                               1, NULL, '2026-02-21 02:19:41', 0, 0, NULL),
(48, 'REPOST',                              'Good morning everyone! DepEd to conduct Early Registration this January 26, 2019.',                                        27, 8, '2026-02-21 13:09:09', 0, 0, NULL),
(50, 'Greetings for students',              'Hello!!',                                                                                                                  1, 10, '2026-02-23 12:47:58', 0, 0, NULL),
(51, 'students can you see this?',          'testing',                                                                                                                  1, 9,  '2026-02-23 13:09:02', 0, 0, NULL),
(52, 'a',                                   'a',                                                                                                                        28, 8, '2026-02-23 13:10:03', 0, 0, NULL),
(53, 'hello teacher only view post',        'test',                                                                                                                     29, 9, '2026-02-23 14:21:00', 0, 0, NULL),
(54, 'this post is specialized for the teachers','test',                                                                                                                1, 9,  '2026-02-23 14:27:35', 0, 0, NULL);

-- ============================================================
-- SCHOOL SETTINGS
-- ============================================================

CREATE TABLE `school_settings` (
  `setting_id`    int(11)      NOT NULL AUTO_INCREMENT,
  `setting_key`   varchar(100) NOT NULL,
  `setting_value` text         DEFAULT NULL,
  `description`   varchar(255) DEFAULT NULL,
  `updated_by`    int(11)      DEFAULT NULL,
  `updated_at`    datetime     DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_deleted`    tinyint(1)   DEFAULT 0,
  `deleted_at`    datetime     DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `uq_setting_key` (`setting_key`),
  KEY `idx_ss_updated_by` (`updated_by`),
  CONSTRAINT `fk_ss_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Global school configuration — used in report headers and form generation';

INSERT INTO `school_settings` (`setting_key`,`setting_value`,`description`) VALUES
('school_name',     NULL, 'Official name of the school'),
('school_id',       NULL, 'DepEd School ID (printed on enrollment form)'),
('school_address',  NULL, 'Complete school address'),
('division',        NULL, 'DepEd Division'),
('district',        NULL, 'DepEd District'),
('region',          NULL, 'DepEd Region'),
('principal_name',  NULL, 'Name of the School Principal'),
('school_year_label',NULL,'Display label e.g. 2025-2026');

-- ============================================================
-- NOTIFICATIONS
-- notification_type inlined as ENUM (dropped notification_types table)
-- ============================================================

CREATE TABLE `notifications` (
  `notification_id`   int(11)      NOT NULL AUTO_INCREMENT,
  `user_id`           int(11)      NOT NULL,
  `notification_type` ENUM('Grade Alert','Risk Flag','Intervention Due','Announcement','Grading Period') NOT NULL,
  `title`             varchar(200) NOT NULL,
  `message`           text         NOT NULL,
  `is_read`           tinyint(1)   DEFAULT 0,
  `read_at`           datetime     DEFAULT NULL,
  `reference_table`   varchar(50)  DEFAULT NULL COMMENT 'e.g. risk_assessments, interventions',
  `reference_id`      int(11)      DEFAULT NULL,
  `created_at`        datetime     DEFAULT current_timestamp(),
  `is_deleted`        tinyint(1)   DEFAULT 0,
  `deleted_at`        datetime     DEFAULT NULL,
  PRIMARY KEY (`notification_id`),
  KEY `idx_notif_user` (`user_id`),
  KEY `idx_notif_read` (`is_read`),
  CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='In-app per-user notifications — grade alerts, risk flags, intervention follow-ups';

-- ============================================================
-- AUDIT LOGS
-- ============================================================

CREATE TABLE `audit_logs` (
  `audit_id`    int(11)      NOT NULL AUTO_INCREMENT,
  `user_id`     int(11)      DEFAULT NULL,
  `table_name`  varchar(100) NOT NULL,
  `record_id`   int(11)      DEFAULT NULL,
  `action`      varchar(50)  NOT NULL COMMENT 'INSERT, UPDATE, DELETE',
  `old_values`  longtext     DEFAULT NULL,
  `new_values`  longtext     DEFAULT NULL,
  `action_time` datetime     DEFAULT current_timestamp(),
  `ip_address`  varchar(45)  DEFAULT NULL,
  PRIMARY KEY (`audit_id`),
  KEY `idx_audit_user`         (`user_id`),
  KEY `idx_audit_table_record` (`table_name`,`record_id`),
  KEY `idx_audit_action_time`  (`action_time`),
  CONSTRAINT `fk_audit_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='Tracks all data changes for accountability';

-- ============================================================
-- DATA INTEGRITY TRIGGERS
-- Enforces:
--   - section capacity (sections.max_capacity)
--   - enrollment consistency with section grade level & school year
--   - attendance references (class_id, grading_period_id)
-- ============================================================

DELIMITER $$

CREATE TRIGGER `trg_enrollments_bi_capacity_consistency`
BEFORE INSERT ON `enrollments`
FOR EACH ROW
BEGIN
  DECLARE current_count INT DEFAULT 0;
  DECLARE max_cap INT DEFAULT NULL;
  DECLARE sec_sy INT DEFAULT NULL;
  DECLARE sec_grade INT DEFAULT NULL;

  SELECT s.max_capacity, s.school_year_id, s.grade_level_id
    INTO max_cap, sec_sy, sec_grade
  FROM sections s
  WHERE s.section_id = NEW.section_id
    AND s.is_deleted = 0
  LIMIT 1;

  IF max_cap IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid section_id';
  END IF;

  IF NEW.school_year_id <> sec_sy THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Enrollment school_year_id does not match section school_year_id';
  END IF;

  IF NEW.grade_level_id <> sec_grade THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Enrollment grade_level_id does not match section grade_level_id';
  END IF;

  SELECT COUNT(*)
    INTO current_count
  FROM enrollments e
  WHERE e.section_id = NEW.section_id
    AND e.school_year_id = NEW.school_year_id
    AND e.is_deleted = 0
    AND (e.enrollment_status = 'Enrolled' OR e.enrollment_status IS NULL);

  IF NEW.is_deleted = 0
     AND (NEW.enrollment_status = 'Enrolled' OR NEW.enrollment_status IS NULL)
     AND current_count >= max_cap THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Section is already at max capacity';
  END IF;
END$$

CREATE TRIGGER `trg_enrollments_bu_capacity_consistency`
BEFORE UPDATE ON `enrollments`
FOR EACH ROW
BEGIN
  DECLARE current_count INT DEFAULT 0;
  DECLARE max_cap INT DEFAULT NULL;
  DECLARE sec_sy INT DEFAULT NULL;
  DECLARE sec_grade INT DEFAULT NULL;

  SELECT s.max_capacity, s.school_year_id, s.grade_level_id
    INTO max_cap, sec_sy, sec_grade
  FROM sections s
  WHERE s.section_id = NEW.section_id
    AND s.is_deleted = 0
  LIMIT 1;

  IF max_cap IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid section_id';
  END IF;

  IF NEW.school_year_id <> sec_sy THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Enrollment school_year_id does not match section school_year_id';
  END IF;

  IF NEW.grade_level_id <> sec_grade THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Enrollment grade_level_id does not match section grade_level_id';
  END IF;

  IF NEW.is_deleted = 0 AND (NEW.enrollment_status = 'Enrolled' OR NEW.enrollment_status IS NULL) THEN
    SELECT COUNT(*)
      INTO current_count
    FROM enrollments e
    WHERE e.section_id = NEW.section_id
      AND e.school_year_id = NEW.school_year_id
      AND e.is_deleted = 0
      AND (e.enrollment_status = 'Enrolled' OR e.enrollment_status IS NULL)
      AND e.enrollment_id <> OLD.enrollment_id;

    IF current_count >= max_cap THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Section is already at max capacity';
    END IF;
  END IF;
END$$

CREATE TRIGGER `trg_attendance_bi_validate_refs`
BEFORE INSERT ON `attendance`
FOR EACH ROW
BEGIN
  DECLARE ok_gp INT DEFAULT 0;
  DECLARE ok_class INT DEFAULT 0;

  -- grading_period must belong to the enrollment's school year
  SELECT COUNT(*)
    INTO ok_gp
  FROM enrollments e
  JOIN grading_periods gp ON gp.grading_period_id = NEW.grading_period_id
  WHERE e.enrollment_id = NEW.enrollment_id
    AND e.is_deleted = 0
    AND gp.school_year_id = e.school_year_id
    AND gp.is_deleted = 0;

  IF ok_gp = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid grading_period_id for this enrollment';
  END IF;

  -- if per-class attendance, class must exist and belong to the enrollment's section & SY
  IF NEW.class_id <> 0 THEN
    SELECT COUNT(*)
      INTO ok_class
    FROM enrollments e
    JOIN class_offerings co ON co.class_id = NEW.class_id
    WHERE e.enrollment_id = NEW.enrollment_id
      AND e.is_deleted = 0
      AND co.is_deleted = 0
      AND co.section_id = e.section_id
      AND co.school_year_id = e.school_year_id;

    IF ok_class = 0 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid class_id for this enrollment';
    END IF;
  END IF;
END$$

CREATE TRIGGER `trg_attendance_bu_validate_refs`
BEFORE UPDATE ON `attendance`
FOR EACH ROW
BEGIN
  DECLARE ok_gp INT DEFAULT 0;
  DECLARE ok_class INT DEFAULT 0;

  SELECT COUNT(*)
    INTO ok_gp
  FROM enrollments e
  JOIN grading_periods gp ON gp.grading_period_id = NEW.grading_period_id
  WHERE e.enrollment_id = NEW.enrollment_id
    AND e.is_deleted = 0
    AND gp.school_year_id = e.school_year_id
    AND gp.is_deleted = 0;

  IF ok_gp = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid grading_period_id for this enrollment';
  END IF;

  IF NEW.class_id <> 0 THEN
    SELECT COUNT(*)
      INTO ok_class
    FROM enrollments e
    JOIN class_offerings co ON co.class_id = NEW.class_id
    WHERE e.enrollment_id = NEW.enrollment_id
      AND e.is_deleted = 0
      AND co.is_deleted = 0
      AND co.section_id = e.section_id
      AND co.school_year_id = e.school_year_id;

    IF ok_class = 0 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid class_id for this enrollment';
    END IF;
  END IF;
END$$

-- Enforce LRN format: exactly 12 digits
CREATE TRIGGER `trg_learners_bi_validate_lrn`
BEFORE INSERT ON `learners`
FOR EACH ROW
BEGIN
  IF NEW.lrn IS NULL OR NEW.lrn NOT REGEXP '^[0-9]{12}$' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'LRN must be exactly 12 digits';
  END IF;
END$$

CREATE TRIGGER `trg_learners_bu_validate_lrn`
BEFORE UPDATE ON `learners`
FOR EACH ROW
BEGIN
  IF NEW.lrn <> OLD.lrn THEN
    IF NEW.lrn IS NULL OR NEW.lrn NOT REGEXP '^[0-9]{12}$' THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'LRN must be exactly 12 digits';
    END IF;
  END IF;
END$$

DELIMITER ;

-- ============================================================
SET FOREIGN_KEY_CHECKS = 1;
COMMIT;
-- ============================================================
-- TABLE SUMMARY (49 tables total)
-- ============================================================
-- roles                        users                   positions
-- employees                    education_levels         grade_levels
-- school_years                 curricula               curriculum_grade_levels
-- curriculum_subjects          curriculum_grading_components
-- curriculum_passing_marks     curriculum_school_year_map
-- sections (+ CHECK capacity)  subjects                learners
-- geo_provinces                geo_cities_municipalities geo_barangays
-- learner_addresses            family_members          emergency_contacts
-- enrollment_types             enrollments (+ curriculum_id)
-- enrollment_requirements      class_offerings         class_schedules
-- grading_periods
-- grades                       final_grades            general_averages
-- attendance (class_id NOT NULL DEFAULT 0)
-- report_cards                 report_card_grades (NEW — subject snapshot)
-- honor_levels                 section_rankings        risk_levels
-- risk_assessments             risk_indicators         interventions
-- document_types               learner_documents       learner_previous_schools
-- learning_modalities          learner_preferred_modalities
-- announcements                school_settings         notifications
-- audit_logs
-- ============================================================
