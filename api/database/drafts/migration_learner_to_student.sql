-- ========================================
-- Migration: Learner => Student Terminology
-- Renames all learner-related tables and columns to student
-- ========================================

-- 1. Rename tables
RENAME TABLE `learners` TO `students`;
RENAME TABLE `learner_citizenships` TO `student_citizenships`;
RENAME TABLE `learner_documents` TO `student_documents`;
RENAME TABLE `learner_preferred_modalities` TO `student_preferred_modalities`;
RENAME TABLE `learner_previous_schools` TO `student_previous_schools`;
RENAME TABLE `learner_statuses` TO `student_statuses`;

-- 2. Update emergency_contacts table
ALTER TABLE `emergency_contacts`
CHANGE COLUMN `learner_id` `student_id` INT(11) NOT NULL;

ALTER TABLE `emergency_contacts`
DROP FOREIGN KEY `fk_emergency_contacts_learner_id`;

ALTER TABLE `emergency_contacts`
ADD CONSTRAINT `fk_emergency_contacts_student_id`
FOREIGN KEY (`student_id`) REFERENCES `students`(`student_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 3. Update enrollments table
ALTER TABLE `enrollments`
CHANGE COLUMN `learner_id` `student_id` INT(11) NOT NULL;

ALTER TABLE `enrollments`
DROP FOREIGN KEY `fk_enroll_learner_id`;

ALTER TABLE `enrollments`
ADD CONSTRAINT `fk_enroll_student_id`
FOREIGN KEY (`student_id`) REFERENCES `students`(`student_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 4. Update family_members table
ALTER TABLE `family_members`
CHANGE COLUMN `learner_id` `student_id` INT(11) NOT NULL;

ALTER TABLE `family_members`
DROP FOREIGN KEY `fk_family_learner_id`;

ALTER TABLE `family_members`
ADD CONSTRAINT `fk_family_student_id`
FOREIGN KEY (`student_id`) REFERENCES `students`(`student_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 5. Rename learners table columns
ALTER TABLE `students`
CHANGE COLUMN `learner_id` `student_id` INT(11) NOT NULL,
CHANGE COLUMN `learner_status_id` `student_status_id` INT(11) DEFAULT NULL;

ALTER TABLE `students`
DROP FOREIGN KEY `fk_learner_status_id`;

ALTER TABLE `students`
ADD CONSTRAINT `fk_student_status_id`
FOREIGN KEY (`student_status_id`) REFERENCES `student_statuses`(`student_status_id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- 6. Update student_citizenships table
ALTER TABLE `student_citizenships`
CHANGE COLUMN `learner_id` `student_id` INT(11) NOT NULL;

ALTER TABLE `student_citizenships`
DROP FOREIGN KEY `fk_learner_citizenship_id`;

ALTER TABLE `student_citizenships`
ADD CONSTRAINT `fk_student_citizenship_id`
FOREIGN KEY (`student_id`) REFERENCES `students`(`student_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 7. Update student_documents table
ALTER TABLE `student_documents`
CHANGE COLUMN `learner_id` `student_id` INT(11) NOT NULL;

ALTER TABLE `student_documents`
DROP FOREIGN KEY `fk_learner_document_id`;

ALTER TABLE `student_documents`
ADD CONSTRAINT `fk_student_document_id`
FOREIGN KEY (`student_id`) REFERENCES `students`(`student_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 8. Update student_preferred_modalities table
ALTER TABLE `student_preferred_modalities`
CHANGE COLUMN `learner_id` `student_id` INT(11) NOT NULL;

ALTER TABLE `student_preferred_modalities`
DROP FOREIGN KEY `fk_learner_modality_id`;

ALTER TABLE `student_preferred_modalities`
ADD CONSTRAINT `fk_student_modality_id`
FOREIGN KEY (`student_id`) REFERENCES `students`(`student_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 9. Update student_previous_schools table
ALTER TABLE `student_previous_schools`
CHANGE COLUMN `learner_id` `student_id` INT(11) NOT NULL;

ALTER TABLE `student_previous_schools`
DROP FOREIGN KEY `fk_learner_prev_school_id`;

ALTER TABLE `student_previous_schools`
ADD CONSTRAINT `fk_student_prev_school_id`
FOREIGN KEY (`student_id`) REFERENCES `students`(`student_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 10. Update student_statuses table PKs if needed
ALTER TABLE `student_statuses`
CHANGE COLUMN `learner_status_id` `student_status_id` INT(11) NOT NULL;

-- 11. Update risk_assessments table if it references learners
ALTER TABLE `risk_assessments`
CHANGE COLUMN `learner_id` `student_id` INT(11) NOT NULL;

ALTER TABLE `risk_assessments`
DROP FOREIGN KEY `fk_risk_learner_id`;

ALTER TABLE `risk_assessments`
ADD CONSTRAINT `fk_risk_student_id`
FOREIGN KEY (`student_id`) REFERENCES `students`(`student_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- 12. Update interventions table enrollment foreign key reference (it may join through enrollments which now uses student_id)
-- This table references enrollments indirectly, no direct change needed unless it had learner_id

-- 13. Update audit_log entries if they reference learner tables
-- UPDATE audit_log SET table_name = REPLACE(table_name, 'learner', 'student') WHERE table_name LIKE '%learner%';

-- 14. Update comments/descriptions in table metadata
ALTER TABLE `students` COMMENT='Student (learner) master profiles';
ALTER TABLE `student_statuses` COMMENT='Student status lookup — Regular, At-Risk, Transferred, Graduated, etc.';
ALTER TABLE `student_citizenships` COMMENT='Student citizenship records';
ALTER TABLE `student_documents` COMMENT='Student documents uploaded per enrollment';
ALTER TABLE `student_preferred_modalities` COMMENT='Student preferred learning modality per school year';
ALTER TABLE `student_previous_schools` COMMENT='Student academic history from previous schools';
ALTER TABLE `emergency_contacts` COMMENT='Emergency contacts per student';
ALTER TABLE `family_members` COMMENT='Family background per student';
ALTER TABLE `enrollments` COMMENT='Student enrollment records per school year';
ALTER TABLE `final_grades` COMMENT='Final computed grade per subject per student per school year';
ALTER TABLE `general_averages` COMMENT='Computed general average per student per school year';
ALTER TABLE `risk_assessments` COMMENT='Risk assessment records for at-risk students';
ALTER TABLE `interventions` COMMENT='Intervention records for at-risk students';
ALTER TABLE `grade_remarks` COMMENT='Lookup for final grade remarks — Passed or Failed';

-- Done! All learner references are now student references
