-- DepEd compliance upgrades (additive)
-- Adds: section adviser, enrollment status/promotion outcome, and SF2-style monthly attendance summaries.
-- Tested for MariaDB/MySQL syntax.

START TRANSACTION;

-- 1) Sections: adviser / homeroom teacher
ALTER TABLE sections
  ADD COLUMN adviser_id int(11) DEFAULT NULL COMMENT 'Class adviser / homeroom teacher' AFTER school_year_id,
  ADD KEY idx_section_adviser (adviser_id);

ALTER TABLE sections
  ADD CONSTRAINT fk_section_adviser
    FOREIGN KEY (adviser_id) REFERENCES employees(employee_id);

-- 2) Enrollments: per-SY status flow + promotion outcome
ALTER TABLE enrollments
  ADD COLUMN enrollment_status ENUM('Enrolled','Dropped','Transferred Out','Completed') NOT NULL DEFAULT 'Enrolled' AFTER enrollment_date,
  ADD COLUMN promotion_status  ENUM('Promoted','Retained','Conditionally Promoted') DEFAULT NULL AFTER enrollment_status,
  ADD COLUMN status_updated_at datetime DEFAULT current_timestamp() AFTER promotion_status;

-- 3) SF2: monthly attendance summary (stored totals)
CREATE TABLE attendance_monthly_summaries (
  summary_id        int(11) NOT NULL AUTO_INCREMENT,
  enrollment_id     int(11) NOT NULL,
  school_year_id    int(11) NOT NULL,
  month_no          tinyint(3) unsigned NOT NULL COMMENT '1..12',
  total_school_days int(11) DEFAULT NULL,
  days_present      int(11) DEFAULT 0,
  days_absent       int(11) DEFAULT 0,
  days_late         int(11) DEFAULT 0,
  days_excused      int(11) DEFAULT 0,
  computed_by       int(11) DEFAULT NULL,
  computed_at       datetime DEFAULT current_timestamp(),
  updated_at        datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  is_deleted        tinyint(1) DEFAULT 0,
  deleted_at        datetime DEFAULT NULL,
  PRIMARY KEY (summary_id),
  UNIQUE KEY uq_att_monthly (enrollment_id, school_year_id, month_no),
  KEY idx_att_monthly_sy (school_year_id, month_no),
  CONSTRAINT chk_att_month_no CHECK (month_no >= 1 AND month_no <= 12),
  CONSTRAINT fk_att_monthly_enrollment FOREIGN KEY (enrollment_id)  REFERENCES enrollments(enrollment_id),
  CONSTRAINT fk_att_monthly_sy         FOREIGN KEY (school_year_id) REFERENCES school_years(school_year_id),
  CONSTRAINT fk_att_monthly_user       FOREIGN KEY (computed_by)    REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
  COMMENT='SF2-ready stored monthly attendance totals per learner enrollment';

-- 4) Optional: MAPEH component subjects (does not remove existing MAPEH subject)
INSERT IGNORE INTO subjects (subject_name, subject_code, description, is_deleted, deleted_at)
VALUES
  ('Music (MAPEH Component)',  'MUSIC',  'MAPEH component subject', 0, NULL),
  ('Arts (MAPEH Component)',   'ARTS',   'MAPEH component subject', 0, NULL),
  ('Physical Education (MAPEH Component)', 'PE', 'MAPEH component subject', 0, NULL),
  ('Health (MAPEH Component)', 'HEALTH', 'MAPEH component subject', 0, NULL);

COMMIT;
