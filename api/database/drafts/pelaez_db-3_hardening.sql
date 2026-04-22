-- Pelaez DB v3 hardening: add stronger uniqueness constraints.
-- Run on database: pelaez_db

START TRANSACTION;

-- Lookup tables: prevent duplicate names.
ALTER TABLE `document_types`
  ADD UNIQUE KEY `uq_document_type_name` (`type_name`);

ALTER TABLE `enrollment_types`
  ADD UNIQUE KEY `uq_enrollment_type_name` (`type_name`);

ALTER TABLE `learning_modalities`
  ADD UNIQUE KEY `uq_learning_modality_name` (`modality_name`);

ALTER TABLE `notification_types`
  ADD UNIQUE KEY `uq_notification_type_name` (`type_name`);

-- Class offerings: prevent duplicate subject/section/teacher per school year.
ALTER TABLE `class_offerings`
  ADD UNIQUE KEY `uq_class_offering` (`subject_id`, `section_id`, `teacher_id`, `school_year_id`);

-- Enrollment requirements: avoid duplicate checklist rows per year/grade/document.
ALTER TABLE `enrollment_requirements`
  ADD UNIQUE KEY `uq_er_sy_grade_doc` (`school_year_id`, `grade_level_id`, `document_type_id`);

COMMIT;
