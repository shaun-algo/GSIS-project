-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Feb 19, 2026 at 05:48 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.0.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pelaez_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `announcements`
--

CREATE TABLE `announcements` (
  `announcement_id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `body` text NOT NULL,
  `posted_by` int(11) NOT NULL,
  `target_role_id` int(11) DEFAULT NULL COMMENT 'NULL = visible to all roles',
  `published_at` datetime DEFAULT current_timestamp(),
  `expires_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='School-wide announcements — enrollment schedules, events, urgent notices';

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `audit_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `table_name` varchar(100) NOT NULL,
  `record_id` int(11) DEFAULT NULL,
  `action` varchar(50) NOT NULL COMMENT 'e.g., INSERT, UPDATE, DELETE',
  `old_values` longtext DEFAULT NULL,
  `new_values` longtext DEFAULT NULL,
  `action_time` datetime DEFAULT current_timestamp(),
  `ip_address` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Tracks all data changes for accountability and rollback';

-- --------------------------------------------------------

--
-- Table structure for table `citizenships`
--

CREATE TABLE `citizenships` (
  `citizenship_id` int(11) NOT NULL,
  `country_name` varchar(100) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Citizenship/nationality lookup';

--
-- Dumping data for table `citizenships`
--

INSERT INTO `citizenships` (`citizenship_id`, `country_name`, `is_deleted`, `deleted_at`) VALUES
(1, 'Filipino', 0, NULL),
(2, 'American', 0, NULL),
(3, 'Chinese', 0, NULL),
(4, 'Japanese', 0, NULL),
(5, 'Korean', 0, NULL),
(6, 'Other', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `civil_statuses`
--

CREATE TABLE `civil_statuses` (
  `civil_status_id` int(11) NOT NULL,
  `status_name` varchar(50) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Civil status lookup — Single, Married, etc.';

--
-- Dumping data for table `civil_statuses`
--

INSERT INTO `civil_statuses` (`civil_status_id`, `status_name`, `is_deleted`, `deleted_at`) VALUES
(1, 'Single', 0, NULL),
(2, 'Married', 0, NULL),
(3, 'Widowed', 0, NULL),
(4, 'Legally Separated', 0, NULL),
(5, 'Annulled', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `class_offerings`
--

CREATE TABLE `class_offerings` (
  `class_id` int(11) NOT NULL,
  `subject_id` int(11) NOT NULL,
  `section_id` int(11) NOT NULL,
  `teacher_id` int(11) NOT NULL,
  `school_year_id` int(11) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Class offerings — subject + section + teacher per school year';

-- --------------------------------------------------------

--
-- Table structure for table `document_types`
--

CREATE TABLE `document_types` (
  `document_type_id` int(11) NOT NULL,
  `type_name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Types of documents required — PSA Birth Certificate, Form 137, Form 138, etc.';

--
-- Dumping data for table `document_types`
--

INSERT INTO `document_types` (`document_type_id`, `type_name`, `description`, `is_deleted`, `deleted_at`) VALUES
(1, 'PSA Birth Certificate', 'Philippine Statistics Authority-issued birth certificate — primary enrollment document (DO 3, s. 2018)', 0, NULL),
(2, 'Form 137 (Permanent Record)', 'Official DepEd permanent academic record — required for transfer-in and progression', 0, NULL),
(3, 'Form 138 (Report Card)', 'Official DepEd report card — required for enrollment to the next grade level', 0, NULL),
(4, 'Certificate of Completion', 'Issued to Grade 6 and Grade 10 completers; required for SHS enrollment', 0, NULL),
(5, 'Good Moral Certificate', 'Character reference from previous school; required for transfer-in learners', 0, NULL),
(6, 'Diploma', 'Issued to Grade 6 and Grade 12 graduates upon completion', 0, NULL),
(7, 'Barangay Certification', 'Acceptable substitute for PSA Birth Certificate when unavailable (DO 3, s. 2018)', 0, NULL),
(8, 'LCR Birth Certificate', 'Local Civil Registrar-issued birth certificate — acceptable substitute for PSA BC', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `education_levels`
--

CREATE TABLE `education_levels` (
  `education_level_id` int(11) NOT NULL,
  `level_name` varchar(100) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Education level — Elementary, Junior High School, Senior High School';

--
-- Dumping data for table `education_levels`
--

INSERT INTO `education_levels` (`education_level_id`, `level_name`, `is_deleted`, `deleted_at`) VALUES
(1, 'Elementary', 0, NULL),
(2, 'Junior High School', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `emergency_contacts`
--

CREATE TABLE `emergency_contacts` (
  `emergency_contact_id` int(11) NOT NULL,
  `learner_id` int(11) NOT NULL,
  `contact_name` varchar(200) NOT NULL,
  `family_relationship_id` int(11) NOT NULL,
  `contact_number` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Emergency contacts per learner';

-- --------------------------------------------------------

--
-- Table structure for table `employees`
--

CREATE TABLE `employees` (
  `employee_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `employee_number` varchar(50) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `middle_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) NOT NULL,
  `name_extension` varchar(10) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` varchar(20) DEFAULT NULL,
  `contact_number` varchar(20) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `position` varchar(150) DEFAULT NULL,
  `department` varchar(150) DEFAULT NULL,
  `date_hired` date DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Employee (teacher/staff) profiles linked to a user account';

-- --------------------------------------------------------

--
-- Table structure for table `enrollments`
--

CREATE TABLE `enrollments` (
  `enrollment_id` int(11) NOT NULL,
  `learner_id` int(11) NOT NULL,
  `school_year_id` int(11) NOT NULL,
  `grade_level_id` int(11) NOT NULL,
  `section_id` int(11) NOT NULL,
  `enrollment_type_id` int(11) DEFAULT NULL,
  `enrollment_date` date DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Learner enrollment records per school year';

-- --------------------------------------------------------

--
-- Table structure for table `enrollment_requirements`
--

CREATE TABLE `enrollment_requirements` (
  `requirement_id` int(11) NOT NULL,
  `school_year_id` int(11) NOT NULL,
  `grade_level_id` int(11) DEFAULT NULL COMMENT 'NULL = applies to all grade levels',
  `document_type_id` int(11) NOT NULL,
  `is_mandatory` tinyint(1) DEFAULT 1,
  `notes` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Document checklist per school year and grade level for enrollment';

-- --------------------------------------------------------

--
-- Table structure for table `enrollment_types`
--

CREATE TABLE `enrollment_types` (
  `enrollment_type_id` int(11) NOT NULL,
  `type_name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Enrollment type — New, Returning, Transfer-in, Balik-Aral';

--
-- Dumping data for table `enrollment_types`
--

INSERT INTO `enrollment_types` (`enrollment_type_id`, `type_name`, `description`, `is_deleted`, `deleted_at`) VALUES
(1, 'New Enrollee', 'Learner enrolling in a DepEd school for the first time', 0, NULL),
(2, 'Returning', 'Learner previously enrolled, re-enrolling in the same school for a new school year', 0, NULL),
(3, 'Transfer-In', 'Learner from another school transferring into this school (DO 54, s. 2016)', 0, NULL),
(4, 'Balik-Aral', 'Out-of-school youth returning to formal schooling after having dropped out', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `family_members`
--

CREATE TABLE `family_members` (
  `family_member_id` int(11) NOT NULL,
  `learner_id` int(11) NOT NULL,
  `full_name` varchar(200) NOT NULL,
  `family_relationship_id` int(11) NOT NULL,
  `date_of_birth` date DEFAULT NULL,
  `occupation` varchar(150) DEFAULT NULL,
  `contact_number` varchar(20) DEFAULT NULL,
  `monthly_income` decimal(12,2) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Family background per learner';

-- --------------------------------------------------------

--
-- Table structure for table `family_relationships`
--

CREATE TABLE `family_relationships` (
  `family_relationship_id` int(11) NOT NULL,
  `relationship_name` varchar(100) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Family relationship types — Father, Mother, Guardian, Sibling, etc.';

--
-- Dumping data for table `family_relationships`
--

INSERT INTO `family_relationships` (`family_relationship_id`, `relationship_name`, `is_deleted`, `deleted_at`) VALUES
(1, 'Father', 0, NULL),
(2, 'Mother', 0, NULL),
(3, 'Legal Guardian', 0, NULL),
(4, 'Grandfather', 0, NULL),
(5, 'Grandmother', 0, NULL),
(6, 'Older Brother', 0, NULL),
(7, 'Older Sister', 0, NULL),
(8, 'Uncle', 0, NULL),
(9, 'Aunt', 0, NULL),
(10, 'Step-Father', 0, NULL),
(11, 'Step-Mother', 0, NULL),
(12, 'Other Relative', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `final_grades`
--

CREATE TABLE `final_grades` (
  `final_grade_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `class_id` int(11) NOT NULL,
  `final_grade` decimal(5,2) DEFAULT NULL,
  `grade_remark_id` int(11) NOT NULL DEFAULT 1 COMMENT 'FK to grade_remarks — Passed or Failed',
  `computed_by` int(11) DEFAULT NULL,
  `computed_at` datetime DEFAULT current_timestamp(),
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Final computed grade per subject per learner per school year';

-- --------------------------------------------------------

--
-- Table structure for table `general_averages`
--

CREATE TABLE `general_averages` (
  `general_average_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `school_year_id` int(11) NOT NULL,
  `general_average` decimal(5,2) DEFAULT NULL,
  `computed_by` int(11) DEFAULT NULL,
  `computed_at` datetime DEFAULT current_timestamp(),
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Computed general average per learner per school year';

-- --------------------------------------------------------

--
-- Table structure for table `grades`
--

CREATE TABLE `grades` (
  `grade_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `class_id` int(11) NOT NULL,
  `grading_period_id` int(11) NOT NULL,
  `written_works` decimal(5,2) DEFAULT NULL,
  `performance_tasks` decimal(5,2) DEFAULT NULL,
  `quarterly_exam` decimal(5,2) DEFAULT NULL,
  `quarterly_grade` decimal(5,2) DEFAULT NULL,
  `encoded_by` int(11) DEFAULT NULL,
  `encoded_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Per-subject quarterly grade entries';

-- --------------------------------------------------------

--
-- Table structure for table `grade_levels`
--

CREATE TABLE `grade_levels` (
  `grade_level_id` int(11) NOT NULL,
  `grade_name` varchar(50) NOT NULL,
  `education_level_id` int(11) NOT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Grade levels — Grade 1 through Grade 10 / Grade 11 / Grade 12';

--
-- Dumping data for table `grade_levels`
--

INSERT INTO `grade_levels` (`grade_level_id`, `grade_name`, `education_level_id`, `sort_order`, `is_deleted`, `deleted_at`) VALUES
(1, 'Grade 1', 1, 1, 0, NULL),
(2, 'Grade 2', 1, 2, 0, NULL),
(3, 'Grade 3', 1, 3, 0, NULL),
(4, 'Grade 4', 1, 4, 0, NULL),
(5, 'Grade 5', 1, 5, 0, NULL),
(6, 'Grade 6', 1, 6, 0, NULL),
(7, 'Grade 7', 2, 7, 0, NULL),
(8, 'Grade 8', 2, 8, 0, NULL),
(9, 'Grade 9', 2, 9, 0, NULL),
(10, 'Grade 10', 2, 10, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `grade_remarks`
--

CREATE TABLE `grade_remarks` (
  `grade_remark_id` int(11) NOT NULL,
  `remark_name` varchar(50) NOT NULL COMMENT 'e.g., Passed, Failed',
  `description` varchar(150) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Lookup for final grade remarks — Passed or Failed';

--
-- Dumping data for table `grade_remarks`
--

INSERT INTO `grade_remarks` (`grade_remark_id`, `remark_name`, `description`, `is_deleted`, `deleted_at`) VALUES
(1, 'Passed', 'Learner met the minimum passing grade', 0, NULL),
(2, 'Failed', 'Learner did not meet the minimum passing grade', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `grading_periods`
--

CREATE TABLE `grading_periods` (
  `grading_period_id` int(11) NOT NULL,
  `school_year_id` int(11) NOT NULL,
  `period_name` varchar(50) NOT NULL COMMENT 'e.g., 1st Quarter, 2nd Quarter',
  `grading_period_status_id` int(11) NOT NULL DEFAULT 1,
  `date_start` date DEFAULT NULL,
  `date_end` date DEFAULT NULL,
  `locked_by` int(11) DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Quarterly grading periods per school year with lock workflow';

-- --------------------------------------------------------

--
-- Table structure for table `grading_period_statuses`
--

CREATE TABLE `grading_period_statuses` (
  `grading_period_status_id` int(11) NOT NULL,
  `status_name` varchar(50) NOT NULL,
  `description` varchar(150) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Lookup for grading period lock workflow statuses';

--
-- Dumping data for table `grading_period_statuses`
--

INSERT INTO `grading_period_statuses` (`grading_period_status_id`, `status_name`, `description`, `is_deleted`, `deleted_at`) VALUES
(1, 'Open', 'Grades are open for encoding by teachers', 0, NULL),
(2, 'Submitted', 'Teacher has submitted grades for review', 0, NULL),
(3, 'Approved', 'Grades approved by department head or admin', 0, NULL),
(4, 'Locked', 'Grades are locked — no further edits allowed', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `grading_system_types`
--

CREATE TABLE `grading_system_types` (
  `grading_system_type_id` int(11) NOT NULL,
  `system_name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Grading system type — e.g., DepEd K-12 Grading System';

-- --------------------------------------------------------

--
-- Table structure for table `honor_levels`
--

CREATE TABLE `honor_levels` (
  `honor_level_id` int(11) NOT NULL,
  `honor_name` varchar(100) NOT NULL,
  `min_average` decimal(5,2) DEFAULT NULL,
  `max_average` decimal(5,2) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Honor level classification — With Highest Honors, With High Honors, With Honors';

--
-- Dumping data for table `honor_levels`
--

INSERT INTO `honor_levels` (`honor_level_id`, `honor_name`, `min_average`, `max_average`, `description`, `is_deleted`, `deleted_at`) VALUES
(1, 'With Highest Honors', 98.00, 100.00, 'May Pinakamataas na Karangalan — General Average of 98 to 100 (DO 36, s. 2016)', 0, NULL),
(2, 'With High Honors', 95.00, 97.99, 'May Mataas na Karangalan — General Average of 95 to 97 (DO 36, s. 2016)', 0, NULL),
(3, 'With Honors', 90.00, 94.99, 'May Karangalan — General Average of 90 to 94 (DO 36, s. 2016)', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `indigenous_groups`
--

CREATE TABLE `indigenous_groups` (
  `indigenous_group_id` int(11) NOT NULL,
  `group_name` varchar(150) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Indigenous peoples/cultural communities group lookup';

--
-- Dumping data for table `indigenous_groups`
--

INSERT INTO `indigenous_groups` (`indigenous_group_id`, `group_name`, `is_deleted`, `deleted_at`) VALUES
(1, 'Higaonon', 0, NULL),
(2, 'Bukidnon', 0, NULL),
(3, 'Manobo (Agusan)', 0, NULL),
(4, 'Talaandig', 0, NULL),
(5, 'Matigsalog', 0, NULL),
(6, 'Maranao', 0, NULL),
(7, 'Maguindanaon', 0, NULL),
(8, 'Tboli', 0, NULL),
(9, 'Blaan', 0, NULL),
(10, 'Bagobo-Obo', 0, NULL),
(11, 'Mandaya', 0, NULL),
(12, 'Mansaka', 0, NULL),
(13, 'Subanen', 0, NULL),
(14, 'Yakan', 0, NULL),
(15, 'Tausug', 0, NULL),
(16, 'Sama / Badjao', 0, NULL),
(17, 'Teduray', 0, NULL),
(18, 'Dibabawon', 0, NULL),
(19, 'Ata (Davao del Norte)', 0, NULL),
(20, 'Igorot (General)', 0, NULL),
(21, 'Ifugao', 0, NULL),
(22, 'Bontoc', 0, NULL),
(23, 'Kalinga', 0, NULL),
(24, 'Ibaloi', 0, NULL),
(25, 'Kankanaey', 0, NULL),
(26, 'Isnag (Apayao)', 0, NULL),
(27, 'Gaddang', 0, NULL),
(28, 'Ibanag', 0, NULL),
(29, 'Ivatan', 0, NULL),
(30, 'Agta / Negrito (Luzon)', 0, NULL),
(31, 'Ati (Panay Negrito)', 0, NULL),
(32, 'Sulod-Bukidnon', 0, NULL),
(33, 'Other Indigenous Group', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `interventions`
--

CREATE TABLE `interventions` (
  `intervention_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `risk_assessment_id` int(11) NOT NULL,
  `intervention_type` varchar(150) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `conducted_by` int(11) DEFAULT NULL,
  `conducted_at` datetime DEFAULT NULL,
  `follow_up_date` date DEFAULT NULL,
  `intervention_status_id` int(11) NOT NULL DEFAULT 1 COMMENT 'FK to intervention_statuses',
  `notes` text DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Intervention records for at-risk learners';

-- --------------------------------------------------------

--
-- Table structure for table `intervention_statuses`
--

CREATE TABLE `intervention_statuses` (
  `intervention_status_id` int(11) NOT NULL,
  `status_name` varchar(50) NOT NULL,
  `description` varchar(150) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Lookup for intervention workflow statuses';

--
-- Dumping data for table `intervention_statuses`
--

INSERT INTO `intervention_statuses` (`intervention_status_id`, `status_name`, `description`, `is_deleted`, `deleted_at`) VALUES
(1, 'Pending', 'Intervention scheduled but not yet started', 0, NULL),
(2, 'Ongoing', 'Intervention is currently active', 0, NULL),
(3, 'Resolved', 'Issue addressed and intervention closed', 0, NULL),
(4, 'Escalated', 'Referred to higher authority for further action', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `learners`
--

CREATE TABLE `learners` (
  `learner_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `lrn` varchar(20) NOT NULL COMMENT 'Learner Reference Number',
  `first_name` varchar(100) NOT NULL,
  `middle_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) NOT NULL,
  `name_extension_id` int(11) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `contact_number` varchar(20) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `learner_status_id` int(11) DEFAULT NULL,
  `religion_id` int(11) DEFAULT NULL,
  `civil_status_id` int(11) DEFAULT NULL,
  `mother_tongue_id` int(11) DEFAULT NULL,
  `indigenous_group_id` int(11) DEFAULT NULL,
  `is_4ps_beneficiary` tinyint(1) DEFAULT 0,
  `is_indigenous` tinyint(1) DEFAULT 0,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Learner (student) master profiles';

-- --------------------------------------------------------

--
-- Table structure for table `learner_citizenships`
--

CREATE TABLE `learner_citizenships` (
  `learner_citizenship_id` int(11) NOT NULL,
  `learner_id` int(11) NOT NULL,
  `citizenship_id` int(11) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Learner citizenship — multi-value (some hold dual citizenship)';

-- --------------------------------------------------------

--
-- Table structure for table `learner_documents`
--

CREATE TABLE `learner_documents` (
  `document_id` int(11) NOT NULL,
  `learner_id` int(11) NOT NULL,
  `enrollment_id` int(11) DEFAULT NULL,
  `school_year_id` int(11) DEFAULT NULL,
  `document_type_id` int(11) NOT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `submitted_at` datetime DEFAULT current_timestamp(),
  `submitted_by` int(11) DEFAULT NULL,
  `remarks` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Documents submitted per learner — PSA, Form 137, Form 138, etc.';

-- --------------------------------------------------------

--
-- Table structure for table `learner_preferred_modalities`
--

CREATE TABLE `learner_preferred_modalities` (
  `preference_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL COMMENT 'Tied to a specific enrollment (SY-specific)',
  `modality_id` int(11) NOT NULL COMMENT 'FK to learning_modalities',
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Learner preferred distance learning modalities per enrollment — multi-select from form';

-- --------------------------------------------------------

--
-- Table structure for table `learner_previous_schools`
--

CREATE TABLE `learner_previous_schools` (
  `previous_school_id` int(11) NOT NULL,
  `learner_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `last_grade_level_completed` varchar(50) DEFAULT NULL,
  `last_school_year_completed` varchar(20) DEFAULT NULL,
  `last_school_attended` varchar(200) DEFAULT NULL,
  `last_school_id` varchar(20) DEFAULT NULL COMMENT 'DepEd School ID of previous school',
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Previous school records for Balik-Aral and transfer-in learners';

-- --------------------------------------------------------

--
-- Table structure for table `learner_statuses`
--

CREATE TABLE `learner_statuses` (
  `learner_status_id` int(11) NOT NULL,
  `status_name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Learner enrollment status — Active, Dropped, Transferred Out, Graduated, etc.';

--
-- Dumping data for table `learner_statuses`
--

INSERT INTO `learner_statuses` (`learner_status_id`, `status_name`, `description`, `is_deleted`, `deleted_at`) VALUES
(1, 'Enrolled', 'Officially enrolled for the current school year in LIS (DO 3, s. 2018)', 0, NULL),
(2, 'Temporarily Enrolled', 'Enrolled but with incomplete documentary requirements; cannot be promoted until fully compliant (DO 3, s. 2018)', 0, NULL),
(3, 'Promoted', 'Achieved Final Grade of 75 or higher in all learning areas; moves to next grade level (DO 14, s. 2016)', 0, NULL),
(4, 'Conditionally Promoted', 'Failed at most 2 learning areas; must pass remedial classes to be officially promoted (DO 14, s. 2016)', 0, NULL),
(5, 'Retained', 'Failed 3 or more learning areas; remains in the same grade level for the next school year (DO 14, s. 2016)', 0, NULL),
(6, 'Transferred Out', 'Learner transferred to another school within the school year; receiving school tags as transferred-in (DO 54, s. 2016)', 0, NULL),
(7, 'Dropped', 'Learner stopped attending and is tagged as No Longer in School in LIS', 0, NULL),
(8, 'Graduated', 'Grade 6 or Grade 12 learner who completed all requirements and received a diploma', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `learning_modalities`
--

CREATE TABLE `learning_modalities` (
  `modality_id` int(11) NOT NULL,
  `modality_name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Distance learning modalities — Modular Print, Online, TV/Radio, Blended, etc.';

--
-- Dumping data for table `learning_modalities`
--

INSERT INTO `learning_modalities` (`modality_id`, `modality_name`, `description`, `is_deleted`, `deleted_at`) VALUES
(1, 'Face-to-Face', 'Traditional in-person classroom instruction', 0, NULL),
(2, 'Modular Distance Learning (Print)', 'Self-Learning Modules (SLMs) in print; used in areas with limited internet access', 0, NULL),
(3, 'Modular Distance Learning (Digital)', 'Self-Learning Modules via USB, CD, or digital devices', 0, NULL),
(4, 'Online Distance Learning', 'Synchronous and asynchronous learning via internet-connected platforms', 0, NULL),
(5, 'TV-Based Instruction', 'Learning via DepEd TV broadcasts (Channels 143 and 144 on SKYcable)', 0, NULL),
(6, 'Radio-Based Instruction', 'Learning via radio broadcast; for remote areas without electricity or internet', 0, NULL),
(7, 'Blended Learning', 'Combination of two or more modalities; school determines the mix', 0, NULL),
(8, 'Home Study Program', 'Formally supervised home learning for learners with health or special circumstances', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `mother_tongues`
--

CREATE TABLE `mother_tongues` (
  `mother_tongue_id` int(11) NOT NULL,
  `tongue_name` varchar(100) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Mother tongue / first language lookup';

--
-- Dumping data for table `mother_tongues`
--

INSERT INTO `mother_tongues` (`mother_tongue_id`, `tongue_name`, `is_deleted`, `deleted_at`) VALUES
(1, 'Tagalog', 0, NULL),
(2, 'Cebuano', 0, NULL),
(3, 'Ilocano', 0, NULL),
(4, 'Hiligaynon (Ilonggo)', 0, NULL),
(5, 'Waray', 0, NULL),
(6, 'Kapampangan', 0, NULL),
(7, 'Bikol', 0, NULL),
(8, 'Pangasinense', 0, NULL),
(9, 'Maranao', 0, NULL),
(10, 'Maguindanaon', 0, NULL),
(11, 'Tausug', 0, NULL),
(12, 'Chavacano', 0, NULL),
(13, 'Yakan', 0, NULL),
(14, 'Ibanag', 0, NULL),
(15, 'Ivatan', 0, NULL),
(16, 'Kankanaey', 0, NULL),
(17, 'Ifugao', 0, NULL),
(18, 'Bontoc', 0, NULL),
(19, 'Kalinga', 0, NULL),
(20, 'Isnag', 0, NULL),
(21, 'Tboli', 0, NULL),
(22, 'Manobo', 0, NULL),
(23, 'Blaan', 0, NULL),
(24, 'English', 0, NULL),
(25, 'Other', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `name_extensions`
--

CREATE TABLE `name_extensions` (
  `extension_id` int(11) NOT NULL,
  `extension_name` varchar(20) NOT NULL COMMENT 'e.g., Jr., Sr., II, III, IV',
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Name extension suffix lookup — Jr., Sr., II, III, IV';

--
-- Dumping data for table `name_extensions`
--

INSERT INTO `name_extensions` (`extension_id`, `extension_name`, `is_deleted`, `deleted_at`) VALUES
(1, 'Jr.', 0, NULL),
(2, 'Sr.', 0, NULL),
(3, 'II', 0, NULL),
(4, 'III', 0, NULL),
(5, 'IV', 0, NULL),
(6, 'V', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `notification_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `notification_type_id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `read_at` datetime DEFAULT NULL,
  `reference_table` varchar(50) DEFAULT NULL COMMENT 'e.g., risk_assessments, interventions',
  `reference_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='In-app per-user notifications — grade alerts, risk flags, intervention follow-ups';

-- --------------------------------------------------------

--
-- Table structure for table `notification_types`
--

CREATE TABLE `notification_types` (
  `notification_type_id` int(11) NOT NULL,
  `type_name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Notification type categories — Grade Alert, Risk Flag, Intervention, Announcement';

--
-- Dumping data for table `notification_types`
--

INSERT INTO `notification_types` (`notification_type_id`, `type_name`, `description`, `is_deleted`, `deleted_at`) VALUES
(1, 'Grade Alert', 'Notification for failing or near-failing quarterly grades requiring teacher action', 0, NULL),
(2, 'Risk Flag', 'Notification for a learner tagged at Moderate, High, or Critical risk level', 0, NULL),
(3, 'Intervention Due', 'Reminder that a scheduled intervention follow-up is approaching or overdue', 0, NULL),
(4, 'Announcement', 'General school-wide announcement — enrollment schedule, DepEd memoranda, events', 0, NULL),
(5, 'Grading Period', 'Notification about grading period status change — submission, approval, or lock', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `religions`
--

CREATE TABLE `religions` (
  `religion_id` int(11) NOT NULL,
  `religion_name` varchar(100) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Religion lookup';

--
-- Dumping data for table `religions`
--

INSERT INTO `religions` (`religion_id`, `religion_name`, `is_deleted`, `deleted_at`) VALUES
(1, 'Roman Catholic', 0, NULL),
(2, 'Islam', 0, NULL),
(3, 'Iglesia ni Cristo', 0, NULL),
(4, 'Seventh-day Adventist', 0, NULL),
(5, 'Bible Baptist Church', 0, NULL),
(6, 'United Church of Christ in the Philippines (UCCP)', 0, NULL),
(7, 'Jehovah\'s Witnesses', 0, NULL),
(8, 'Aglipayan (Philippine Independent Church)', 0, NULL),
(9, 'Born Again Christian', 0, NULL),
(10, 'The Church of Jesus Christ of Latter-day Saints', 0, NULL),
(11, 'Members Church of God International (MCGI / Ang Dating Daan)', 0, NULL),
(12, 'Indigenous / Tribal Religion', 0, NULL),
(13, 'None / No Religious Affiliation', 0, NULL),
(14, 'Other', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `report_cards`
--

CREATE TABLE `report_cards` (
  `report_card_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `grading_period_id` int(11) NOT NULL,
  `generated_at` datetime DEFAULT current_timestamp(),
  `generated_by` int(11) DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Generated report card records per learner per grading period';

-- --------------------------------------------------------

--
-- Table structure for table `risk_assessments`
--

CREATE TABLE `risk_assessments` (
  `risk_assessment_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `grading_period_id` int(11) NOT NULL,
  `risk_level_id` int(11) NOT NULL,
  `assessed_by` int(11) DEFAULT NULL,
  `assessed_at` datetime DEFAULT current_timestamp(),
  `notes` text DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Risk level assessment per learner per grading period';

-- --------------------------------------------------------

--
-- Table structure for table `risk_indicators`
--

CREATE TABLE `risk_indicators` (
  `indicator_id` int(11) NOT NULL,
  `risk_assessment_id` int(11) NOT NULL,
  `indicator_type` varchar(100) DEFAULT NULL COMMENT 'e.g., Attendance, Grade Drop, Behavioral',
  `details` text DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Individual risk indicator flags tied to a risk assessment';

-- --------------------------------------------------------

--
-- Table structure for table `risk_levels`
--

CREATE TABLE `risk_levels` (
  `risk_level_id` int(11) NOT NULL,
  `risk_name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `color_code` varchar(10) DEFAULT NULL COMMENT 'For UI display e.g. #FF0000',
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Risk level classification — Low, Moderate, High, Critical';

--
-- Dumping data for table `risk_levels`
--

INSERT INTO `risk_levels` (`risk_level_id`, `risk_name`, `description`, `color_code`, `is_deleted`, `deleted_at`) VALUES
(1, 'Low', 'Learner is performing satisfactorily; routine monitoring only', '#28A745', 0, NULL),
(2, 'Moderate', 'Learner shows early warning signs; advisory support and monitoring required', '#FFC107', 0, NULL),
(3, 'High', 'Learner is failing 1-2 subjects or has chronic absences; active intervention required', '#FF6B35', 0, NULL),
(4, 'Critical', 'Learner is at high risk of dropping out; urgent intervention and escalation to school head', '#DC3545', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `role_id` int(11) NOT NULL,
  `role_name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='System user roles — Admin, Teacher, Registrar, Principal, Guidance, etc.';

-- --------------------------------------------------------

--
-- Table structure for table `school_settings`
--

CREATE TABLE `school_settings` (
  `setting_id` int(11) NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Global school configuration — used in report headers and form generation';

--
-- Dumping data for table `school_settings`
--

INSERT INTO `school_settings` (`setting_id`, `setting_key`, `setting_value`, `description`, `updated_by`, `updated_at`, `is_deleted`, `deleted_at`) VALUES
(1, 'school_name', NULL, 'Official name of the school', NULL, '2026-02-19 15:43:16', 0, NULL),
(2, 'school_id', NULL, 'DepEd School ID (printed on enrollment form)', NULL, '2026-02-19 15:43:16', 0, NULL),
(3, 'school_address', NULL, 'Complete school address', NULL, '2026-02-19 15:43:16', 0, NULL),
(4, 'division', NULL, 'DepEd Division', NULL, '2026-02-19 15:43:16', 0, NULL),
(5, 'district', NULL, 'DepEd District', NULL, '2026-02-19 15:43:16', 0, NULL),
(6, 'region', NULL, 'DepEd Region', NULL, '2026-02-19 15:43:16', 0, NULL),
(7, 'principal_name', NULL, 'Name of the School Principal', NULL, '2026-02-19 15:43:16', 0, NULL),
(8, 'school_year_label', NULL, 'Display label e.g. 2025-2026', NULL, '2026-02-19 15:43:16', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `school_years`
--

CREATE TABLE `school_years` (
  `school_year_id` int(11) NOT NULL,
  `year_start` int(4) DEFAULT NULL,
  `year_end` int(4) DEFAULT NULL,
  `year_label` varchar(20) NOT NULL COMMENT 'e.g., 2024-2025',
  `date_start` date DEFAULT NULL,
  `date_end` date DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 0,
  `grading_system_type_id` int(11) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Academic school years';

-- --------------------------------------------------------

--
-- Table structure for table `sections`
--

CREATE TABLE `sections` (
  `section_id` int(11) NOT NULL,
  `section_name` varchar(100) NOT NULL,
  `grade_level_id` int(11) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Class sections per grade level';

-- --------------------------------------------------------

--
-- Table structure for table `section_rankings`
--

CREATE TABLE `section_rankings` (
  `ranking_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `section_id` int(11) NOT NULL,
  `school_year_id` int(11) NOT NULL,
  `rank` int(11) DEFAULT NULL,
  `honor_level_id` int(11) DEFAULT NULL,
  `ranked_by` int(11) DEFAULT NULL,
  `ranked_at` datetime DEFAULT current_timestamp(),
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Section honor rankings per learner per school year';

-- --------------------------------------------------------

--
-- Table structure for table `subjects`
--

CREATE TABLE `subjects` (
  `subject_id` int(11) NOT NULL,
  `subject_name` varchar(150) NOT NULL,
  `subject_code_id` int(11) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Subject master list';

--
-- Dumping data for table `subjects`
--

INSERT INTO `subjects` (`subject_id`, `subject_name`, `subject_code_id`, `description`, `is_deleted`, `deleted_at`) VALUES
(1, 'Mother Tongue (MTB-MLE)', 1, 'Primary language of instruction — Grades 1 to 3 (DO 16, s. 2012)', 0, NULL),
(2, 'Filipino', 2, 'Filipino language — all elementary levels', 0, NULL),
(3, 'English', 3, 'English language — all elementary levels', 0, NULL),
(4, 'Mathematics', 4, 'Mathematics — all levels; spiral progression', 0, NULL),
(5, 'Araling Panlipunan', 6, 'Social Studies — all levels', 0, NULL),
(6, 'Edukasyon sa Pagpapakatao (EsP)', 7, 'Values Education — all levels', 0, NULL),
(7, 'Music, Arts, Physical Education and Health (MAPEH)', 8, 'Clustered learning area — all levels', 0, NULL),
(8, 'Good Manners and Right Conduct (GMRC)', 11, 'MATATAG Curriculum — Grades 1-6', 0, NULL),
(9, 'Makabansa', 12, 'MATATAG Curriculum — Grades 1-6; Filipino identity', 0, NULL),
(10, 'Science', 5, 'Science — introduced Grade 3; spiral progression', 0, NULL),
(11, 'Edukasyong Pantahanan at Pangkabuhayan (EPP)', 9, 'Home Economics and Livelihood — Grades 4-6', 0, NULL),
(12, 'Technology and Livelihood Education (TLE)', 10, 'Exploratory courses — JHS Grades 7-10', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `subject_codes`
--

CREATE TABLE `subject_codes` (
  `subject_code_id` int(11) NOT NULL,
  `subject_code` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='DepEd subject codes — used to standardize subject naming across grade levels';

--
-- Dumping data for table `subject_codes`
--

INSERT INTO `subject_codes` (`subject_code_id`, `subject_code`, `description`, `is_deleted`, `deleted_at`) VALUES
(1, 'MTB-MLE', 'Mother Tongue-Based Multilingual Education', 0, NULL),
(2, 'FIL', 'Filipino', 0, NULL),
(3, 'ENG', 'English', 0, NULL),
(4, 'MATH', 'Mathematics', 0, NULL),
(5, 'SCI', 'Science', 0, NULL),
(6, 'AP', 'Araling Panlipunan (Social Studies)', 0, NULL),
(7, 'ESP', 'Edukasyon sa Pagpapakatao (Values Education)', 0, NULL),
(8, 'MAPEH', 'Music, Arts, Physical Education and Health', 0, NULL),
(9, 'EPP', 'Edukasyong Pantahanan at Pangkabuhayan', 0, NULL),
(10, 'TLE', 'Technology and Livelihood Education', 0, NULL),
(11, 'GMRC', 'Good Manners and Right Conduct (MATATAG Curriculum)', 0, NULL),
(12, 'MAKABANSA', 'Makabansa — Filipino Identity and Nationalism (MATATAG Curriculum)', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role_id` int(11) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `last_login` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='System user accounts — all roles share this table';

--
-- Indexes for dumped tables
--

--
-- Indexes for table `announcements`
--
ALTER TABLE `announcements`
  ADD PRIMARY KEY (`announcement_id`),
  ADD KEY `idx_ann_posted_by` (`posted_by`),
  ADD KEY `idx_ann_target_role` (`target_role_id`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`audit_id`),
  ADD KEY `idx_audit_user` (`user_id`),
  ADD KEY `idx_audit_table_record` (`table_name`,`record_id`),
  ADD KEY `idx_audit_action_time` (`action_time`);

--
-- Indexes for table `citizenships`
--
ALTER TABLE `citizenships`
  ADD PRIMARY KEY (`citizenship_id`),
  ADD UNIQUE KEY `uq_country_name` (`country_name`);

--
-- Indexes for table `civil_statuses`
--
ALTER TABLE `civil_statuses`
  ADD PRIMARY KEY (`civil_status_id`),
  ADD UNIQUE KEY `uq_civil_status_name` (`status_name`);

--
-- Indexes for table `class_offerings`
--
ALTER TABLE `class_offerings`
  ADD PRIMARY KEY (`class_id`),
  ADD KEY `idx_class_subject` (`subject_id`),
  ADD KEY `idx_class_section` (`section_id`),
  ADD KEY `idx_class_teacher` (`teacher_id`),
  ADD KEY `idx_class_sy` (`school_year_id`);

--
-- Indexes for table `document_types`
--
ALTER TABLE `document_types`
  ADD PRIMARY KEY (`document_type_id`);

--
-- Indexes for table `education_levels`
--
ALTER TABLE `education_levels`
  ADD PRIMARY KEY (`education_level_id`),
  ADD UNIQUE KEY `uq_level_name` (`level_name`);

--
-- Indexes for table `emergency_contacts`
--
ALTER TABLE `emergency_contacts`
  ADD PRIMARY KEY (`emergency_contact_id`),
  ADD KEY `idx_ec_learner` (`learner_id`),
  ADD KEY `idx_ec_relationship` (`family_relationship_id`);

--
-- Indexes for table `employees`
--
ALTER TABLE `employees`
  ADD PRIMARY KEY (`employee_id`),
  ADD UNIQUE KEY `uq_employee_user` (`user_id`),
  ADD UNIQUE KEY `uq_employee_number` (`employee_number`);

--
-- Indexes for table `enrollments`
--
ALTER TABLE `enrollments`
  ADD PRIMARY KEY (`enrollment_id`),
  ADD UNIQUE KEY `uq_learner_school_year` (`learner_id`,`school_year_id`),
  ADD KEY `idx_enroll_learner` (`learner_id`),
  ADD KEY `idx_enroll_sy` (`school_year_id`),
  ADD KEY `idx_enroll_grade` (`grade_level_id`),
  ADD KEY `idx_enroll_section` (`section_id`),
  ADD KEY `idx_dashboard_composite` (`school_year_id`,`grade_level_id`,`section_id`) COMMENT 'Composite index for optimized dashboard queries',
  ADD KEY `fk_enroll_type_id` (`enrollment_type_id`);

--
-- Indexes for table `enrollment_requirements`
--
ALTER TABLE `enrollment_requirements`
  ADD PRIMARY KEY (`requirement_id`),
  ADD KEY `idx_er_school_year` (`school_year_id`),
  ADD KEY `idx_er_grade_level` (`grade_level_id`),
  ADD KEY `idx_er_document_type` (`document_type_id`);

--
-- Indexes for table `enrollment_types`
--
ALTER TABLE `enrollment_types`
  ADD PRIMARY KEY (`enrollment_type_id`);

--
-- Indexes for table `family_members`
--
ALTER TABLE `family_members`
  ADD PRIMARY KEY (`family_member_id`),
  ADD KEY `idx_family_learner` (`learner_id`),
  ADD KEY `idx_family_relationship` (`family_relationship_id`);

--
-- Indexes for table `family_relationships`
--
ALTER TABLE `family_relationships`
  ADD PRIMARY KEY (`family_relationship_id`),
  ADD UNIQUE KEY `uq_relationship_name` (`relationship_name`);

--
-- Indexes for table `final_grades`
--
ALTER TABLE `final_grades`
  ADD PRIMARY KEY (`final_grade_id`),
  ADD UNIQUE KEY `uq_final_grade_enrollment_class` (`enrollment_id`,`class_id`),
  ADD KEY `idx_fg_class` (`class_id`),
  ADD KEY `idx_fg_computed_by` (`computed_by`),
  ADD KEY `idx_fg_remark` (`grade_remark_id`);

--
-- Indexes for table `general_averages`
--
ALTER TABLE `general_averages`
  ADD PRIMARY KEY (`general_average_id`),
  ADD UNIQUE KEY `uq_ga_enrollment` (`enrollment_id`),
  ADD KEY `idx_ga_school_year` (`school_year_id`),
  ADD KEY `idx_ga_computed_by` (`computed_by`);

--
-- Indexes for table `grades`
--
ALTER TABLE `grades`
  ADD PRIMARY KEY (`grade_id`),
  ADD UNIQUE KEY `uq_grade_entry` (`enrollment_id`,`class_id`,`grading_period_id`),
  ADD KEY `idx_grade_class` (`class_id`),
  ADD KEY `idx_grade_period` (`grading_period_id`);

--
-- Indexes for table `grade_levels`
--
ALTER TABLE `grade_levels`
  ADD PRIMARY KEY (`grade_level_id`),
  ADD UNIQUE KEY `uq_grade_name` (`grade_name`),
  ADD KEY `idx_grade_level_education` (`education_level_id`);

--
-- Indexes for table `grade_remarks`
--
ALTER TABLE `grade_remarks`
  ADD PRIMARY KEY (`grade_remark_id`),
  ADD UNIQUE KEY `uq_grade_remark_name` (`remark_name`);

--
-- Indexes for table `grading_periods`
--
ALTER TABLE `grading_periods`
  ADD PRIMARY KEY (`grading_period_id`),
  ADD UNIQUE KEY `uq_period_school_year` (`school_year_id`,`period_name`),
  ADD KEY `idx_gp_locked_by` (`locked_by`),
  ADD KEY `idx_gp_status` (`grading_period_status_id`);

--
-- Indexes for table `grading_period_statuses`
--
ALTER TABLE `grading_period_statuses`
  ADD PRIMARY KEY (`grading_period_status_id`),
  ADD UNIQUE KEY `uq_gp_status_name` (`status_name`);

--
-- Indexes for table `grading_system_types`
--
ALTER TABLE `grading_system_types`
  ADD PRIMARY KEY (`grading_system_type_id`),
  ADD UNIQUE KEY `uq_system_name` (`system_name`);

--
-- Indexes for table `honor_levels`
--
ALTER TABLE `honor_levels`
  ADD PRIMARY KEY (`honor_level_id`),
  ADD UNIQUE KEY `uq_honor_name` (`honor_name`);

--
-- Indexes for table `indigenous_groups`
--
ALTER TABLE `indigenous_groups`
  ADD PRIMARY KEY (`indigenous_group_id`),
  ADD UNIQUE KEY `uq_group_name` (`group_name`);

--
-- Indexes for table `interventions`
--
ALTER TABLE `interventions`
  ADD PRIMARY KEY (`intervention_id`),
  ADD KEY `idx_intervention_enrollment` (`enrollment_id`),
  ADD KEY `idx_intervention_risk` (`risk_assessment_id`),
  ADD KEY `idx_intervention_conductor` (`conducted_by`),
  ADD KEY `idx_intervention_status` (`intervention_status_id`);

--
-- Indexes for table `intervention_statuses`
--
ALTER TABLE `intervention_statuses`
  ADD PRIMARY KEY (`intervention_status_id`),
  ADD UNIQUE KEY `uq_intervention_status_name` (`status_name`);

--
-- Indexes for table `learners`
--
ALTER TABLE `learners`
  ADD PRIMARY KEY (`learner_id`),
  ADD UNIQUE KEY `uq_learner_lrn` (`lrn`),
  ADD UNIQUE KEY `uq_learner_user` (`user_id`),
  ADD KEY `idx_learner_status` (`learner_status_id`),
  ADD KEY `idx_learner_religion` (`religion_id`),
  ADD KEY `idx_learner_civil` (`civil_status_id`),
  ADD KEY `idx_learner_extension` (`name_extension_id`),
  ADD KEY `idx_learner_mother_tongue` (`mother_tongue_id`),
  ADD KEY `idx_learner_indigenous_group` (`indigenous_group_id`);

--
-- Indexes for table `learner_citizenships`
--
ALTER TABLE `learner_citizenships`
  ADD PRIMARY KEY (`learner_citizenship_id`),
  ADD UNIQUE KEY `uq_learner_citizenship` (`learner_id`,`citizenship_id`),
  ADD KEY `idx_lc_citizenship` (`citizenship_id`);

--
-- Indexes for table `learner_documents`
--
ALTER TABLE `learner_documents`
  ADD PRIMARY KEY (`document_id`),
  ADD KEY `idx_ld_learner` (`learner_id`),
  ADD KEY `idx_ld_enrollment` (`enrollment_id`),
  ADD KEY `idx_ld_document_type` (`document_type_id`),
  ADD KEY `idx_ld_submitted_by` (`submitted_by`),
  ADD KEY `fk_ld_school_year` (`school_year_id`);

--
-- Indexes for table `learner_preferred_modalities`
--
ALTER TABLE `learner_preferred_modalities`
  ADD PRIMARY KEY (`preference_id`),
  ADD UNIQUE KEY `uq_enroll_modality` (`enrollment_id`,`modality_id`),
  ADD KEY `idx_lpm_enrollment` (`enrollment_id`),
  ADD KEY `idx_lpm_modality` (`modality_id`);

--
-- Indexes for table `learner_previous_schools`
--
ALTER TABLE `learner_previous_schools`
  ADD PRIMARY KEY (`previous_school_id`),
  ADD KEY `idx_lps_learner` (`learner_id`),
  ADD KEY `idx_lps_enrollment` (`enrollment_id`);

--
-- Indexes for table `learner_statuses`
--
ALTER TABLE `learner_statuses`
  ADD PRIMARY KEY (`learner_status_id`),
  ADD UNIQUE KEY `uq_learner_status_name` (`status_name`);

--
-- Indexes for table `learning_modalities`
--
ALTER TABLE `learning_modalities`
  ADD PRIMARY KEY (`modality_id`);

--
-- Indexes for table `mother_tongues`
--
ALTER TABLE `mother_tongues`
  ADD PRIMARY KEY (`mother_tongue_id`),
  ADD UNIQUE KEY `uq_tongue_name` (`tongue_name`);

--
-- Indexes for table `name_extensions`
--
ALTER TABLE `name_extensions`
  ADD PRIMARY KEY (`extension_id`),
  ADD UNIQUE KEY `uq_extension_name` (`extension_name`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`notification_id`),
  ADD KEY `idx_notif_user` (`user_id`),
  ADD KEY `idx_notif_type` (`notification_type_id`),
  ADD KEY `idx_notif_read` (`is_read`);

--
-- Indexes for table `notification_types`
--
ALTER TABLE `notification_types`
  ADD PRIMARY KEY (`notification_type_id`);

--
-- Indexes for table `religions`
--
ALTER TABLE `religions`
  ADD PRIMARY KEY (`religion_id`),
  ADD UNIQUE KEY `uq_religion_name` (`religion_name`);

--
-- Indexes for table `report_cards`
--
ALTER TABLE `report_cards`
  ADD PRIMARY KEY (`report_card_id`),
  ADD UNIQUE KEY `uq_rc_enrollment_period` (`enrollment_id`,`grading_period_id`),
  ADD KEY `idx_rc_period` (`grading_period_id`);

--
-- Indexes for table `risk_assessments`
--
ALTER TABLE `risk_assessments`
  ADD PRIMARY KEY (`risk_assessment_id`),
  ADD UNIQUE KEY `uq_risk_enrollment_period` (`enrollment_id`,`grading_period_id`),
  ADD KEY `idx_risk_period` (`grading_period_id`),
  ADD KEY `idx_risk_level` (`risk_level_id`),
  ADD KEY `fk_risk_assessed_by` (`assessed_by`);

--
-- Indexes for table `risk_indicators`
--
ALTER TABLE `risk_indicators`
  ADD PRIMARY KEY (`indicator_id`),
  ADD KEY `idx_ri_assessment` (`risk_assessment_id`);

--
-- Indexes for table `risk_levels`
--
ALTER TABLE `risk_levels`
  ADD PRIMARY KEY (`risk_level_id`),
  ADD UNIQUE KEY `uq_risk_name` (`risk_name`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`role_id`),
  ADD UNIQUE KEY `uq_role_name` (`role_name`);

--
-- Indexes for table `school_settings`
--
ALTER TABLE `school_settings`
  ADD PRIMARY KEY (`setting_id`),
  ADD UNIQUE KEY `uq_setting_key` (`setting_key`),
  ADD KEY `idx_ss_updated_by` (`updated_by`);

--
-- Indexes for table `school_years`
--
ALTER TABLE `school_years`
  ADD PRIMARY KEY (`school_year_id`),
  ADD KEY `idx_sy_grading_type` (`grading_system_type_id`);

--
-- Indexes for table `sections`
--
ALTER TABLE `sections`
  ADD PRIMARY KEY (`section_id`),
  ADD UNIQUE KEY `uq_section_grade` (`grade_level_id`,`section_name`),
  ADD KEY `idx_section_grade_level` (`grade_level_id`);

--
-- Indexes for table `section_rankings`
--
ALTER TABLE `section_rankings`
  ADD PRIMARY KEY (`ranking_id`),
  ADD UNIQUE KEY `uq_ranking_enrollment` (`enrollment_id`),
  ADD KEY `idx_ranking_section_sy` (`section_id`,`school_year_id`),
  ADD KEY `idx_ranking_honor` (`honor_level_id`),
  ADD KEY `idx_ranking_ranked_by` (`ranked_by`),
  ADD KEY `idx_ranking_school_year` (`school_year_id`);

--
-- Indexes for table `subjects`
--
ALTER TABLE `subjects`
  ADD PRIMARY KEY (`subject_id`),
  ADD KEY `idx_subject_code` (`subject_code_id`);

--
-- Indexes for table `subject_codes`
--
ALTER TABLE `subject_codes`
  ADD PRIMARY KEY (`subject_code_id`),
  ADD UNIQUE KEY `uq_subject_code` (`subject_code`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `uq_username` (`username`),
  ADD KEY `idx_user_role` (`role_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `announcements`
--
ALTER TABLE `announcements`
  MODIFY `announcement_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `audit_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `citizenships`
--
ALTER TABLE `citizenships`
  MODIFY `citizenship_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `civil_statuses`
--
ALTER TABLE `civil_statuses`
  MODIFY `civil_status_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `class_offerings`
--
ALTER TABLE `class_offerings`
  MODIFY `class_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `document_types`
--
ALTER TABLE `document_types`
  MODIFY `document_type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `education_levels`
--
ALTER TABLE `education_levels`
  MODIFY `education_level_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `emergency_contacts`
--
ALTER TABLE `emergency_contacts`
  MODIFY `emergency_contact_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `employees`
--
ALTER TABLE `employees`
  MODIFY `employee_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `enrollments`
--
ALTER TABLE `enrollments`
  MODIFY `enrollment_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `enrollment_requirements`
--
ALTER TABLE `enrollment_requirements`
  MODIFY `requirement_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `enrollment_types`
--
ALTER TABLE `enrollment_types`
  MODIFY `enrollment_type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `family_members`
--
ALTER TABLE `family_members`
  MODIFY `family_member_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `family_relationships`
--
ALTER TABLE `family_relationships`
  MODIFY `family_relationship_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `final_grades`
--
ALTER TABLE `final_grades`
  MODIFY `final_grade_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `general_averages`
--
ALTER TABLE `general_averages`
  MODIFY `general_average_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `grades`
--
ALTER TABLE `grades`
  MODIFY `grade_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `grade_levels`
--
ALTER TABLE `grade_levels`
  MODIFY `grade_level_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `grade_remarks`
--
ALTER TABLE `grade_remarks`
  MODIFY `grade_remark_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `grading_periods`
--
ALTER TABLE `grading_periods`
  MODIFY `grading_period_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `grading_period_statuses`
--
ALTER TABLE `grading_period_statuses`
  MODIFY `grading_period_status_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `grading_system_types`
--
ALTER TABLE `grading_system_types`
  MODIFY `grading_system_type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `honor_levels`
--
ALTER TABLE `honor_levels`
  MODIFY `honor_level_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `indigenous_groups`
--
ALTER TABLE `indigenous_groups`
  MODIFY `indigenous_group_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `interventions`
--
ALTER TABLE `interventions`
  MODIFY `intervention_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `intervention_statuses`
--
ALTER TABLE `intervention_statuses`
  MODIFY `intervention_status_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `learners`
--
ALTER TABLE `learners`
  MODIFY `learner_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `learner_citizenships`
--
ALTER TABLE `learner_citizenships`
  MODIFY `learner_citizenship_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `learner_documents`
--
ALTER TABLE `learner_documents`
  MODIFY `document_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `learner_preferred_modalities`
--
ALTER TABLE `learner_preferred_modalities`
  MODIFY `preference_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `learner_previous_schools`
--
ALTER TABLE `learner_previous_schools`
  MODIFY `previous_school_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `learner_statuses`
--
ALTER TABLE `learner_statuses`
  MODIFY `learner_status_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `learning_modalities`
--
ALTER TABLE `learning_modalities`
  MODIFY `modality_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `mother_tongues`
--
ALTER TABLE `mother_tongues`
  MODIFY `mother_tongue_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `name_extensions`
--
ALTER TABLE `name_extensions`
  MODIFY `extension_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notification_types`
--
ALTER TABLE `notification_types`
  MODIFY `notification_type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `religions`
--
ALTER TABLE `religions`
  MODIFY `religion_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `report_cards`
--
ALTER TABLE `report_cards`
  MODIFY `report_card_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `risk_assessments`
--
ALTER TABLE `risk_assessments`
  MODIFY `risk_assessment_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `risk_indicators`
--
ALTER TABLE `risk_indicators`
  MODIFY `indicator_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `risk_levels`
--
ALTER TABLE `risk_levels`
  MODIFY `risk_level_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `role_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `school_settings`
--
ALTER TABLE `school_settings`
  MODIFY `setting_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT for table `school_years`
--
ALTER TABLE `school_years`
  MODIFY `school_year_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `sections`
--
ALTER TABLE `sections`
  MODIFY `section_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `section_rankings`
--
ALTER TABLE `section_rankings`
  MODIFY `ranking_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `subjects`
--
ALTER TABLE `subjects`
  MODIFY `subject_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `subject_codes`
--
ALTER TABLE `subject_codes`
  MODIFY `subject_code_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `announcements`
--
ALTER TABLE `announcements`
  ADD CONSTRAINT `fk_ann_posted_by` FOREIGN KEY (`posted_by`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_ann_target_role` FOREIGN KEY (`target_role_id`) REFERENCES `roles` (`role_id`);

--
-- Constraints for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `fk_audit_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `class_offerings`
--
ALTER TABLE `class_offerings`
  ADD CONSTRAINT `fk_class_section` FOREIGN KEY (`section_id`) REFERENCES `sections` (`section_id`),
  ADD CONSTRAINT `fk_class_subject` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`),
  ADD CONSTRAINT `fk_class_sy` FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`),
  ADD CONSTRAINT `fk_class_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `employees` (`employee_id`);

--
-- Constraints for table `emergency_contacts`
--
ALTER TABLE `emergency_contacts`
  ADD CONSTRAINT `fk_ec_learner` FOREIGN KEY (`learner_id`) REFERENCES `learners` (`learner_id`),
  ADD CONSTRAINT `fk_ec_relationship` FOREIGN KEY (`family_relationship_id`) REFERENCES `family_relationships` (`family_relationship_id`);

--
-- Constraints for table `employees`
--
ALTER TABLE `employees`
  ADD CONSTRAINT `fk_employee_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `enrollments`
--
ALTER TABLE `enrollments`
  ADD CONSTRAINT `fk_enroll_grade` FOREIGN KEY (`grade_level_id`) REFERENCES `grade_levels` (`grade_level_id`),
  ADD CONSTRAINT `fk_enroll_learner` FOREIGN KEY (`learner_id`) REFERENCES `learners` (`learner_id`),
  ADD CONSTRAINT `fk_enroll_section` FOREIGN KEY (`section_id`) REFERENCES `sections` (`section_id`),
  ADD CONSTRAINT `fk_enroll_sy` FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`),
  ADD CONSTRAINT `fk_enroll_type_id` FOREIGN KEY (`enrollment_type_id`) REFERENCES `enrollment_types` (`enrollment_type_id`);

--
-- Constraints for table `enrollment_requirements`
--
ALTER TABLE `enrollment_requirements`
  ADD CONSTRAINT `fk_er_document_type` FOREIGN KEY (`document_type_id`) REFERENCES `document_types` (`document_type_id`),
  ADD CONSTRAINT `fk_er_grade_level` FOREIGN KEY (`grade_level_id`) REFERENCES `grade_levels` (`grade_level_id`),
  ADD CONSTRAINT `fk_er_school_year` FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`);

--
-- Constraints for table `family_members`
--
ALTER TABLE `family_members`
  ADD CONSTRAINT `fk_family_learner` FOREIGN KEY (`learner_id`) REFERENCES `learners` (`learner_id`),
  ADD CONSTRAINT `fk_family_relationship` FOREIGN KEY (`family_relationship_id`) REFERENCES `family_relationships` (`family_relationship_id`);

--
-- Constraints for table `final_grades`
--
ALTER TABLE `final_grades`
  ADD CONSTRAINT `fk_fg_class` FOREIGN KEY (`class_id`) REFERENCES `class_offerings` (`class_id`),
  ADD CONSTRAINT `fk_fg_computed_by` FOREIGN KEY (`computed_by`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_fg_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`enrollment_id`),
  ADD CONSTRAINT `fk_fg_remark` FOREIGN KEY (`grade_remark_id`) REFERENCES `grade_remarks` (`grade_remark_id`);

--
-- Constraints for table `general_averages`
--
ALTER TABLE `general_averages`
  ADD CONSTRAINT `fk_ga_computed_by` FOREIGN KEY (`computed_by`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_ga_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`enrollment_id`),
  ADD CONSTRAINT `fk_ga_school_year` FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`);

--
-- Constraints for table `grades`
--
ALTER TABLE `grades`
  ADD CONSTRAINT `fk_grade_class` FOREIGN KEY (`class_id`) REFERENCES `class_offerings` (`class_id`),
  ADD CONSTRAINT `fk_grade_enroll` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`enrollment_id`),
  ADD CONSTRAINT `fk_grade_period` FOREIGN KEY (`grading_period_id`) REFERENCES `grading_periods` (`grading_period_id`);

--
-- Constraints for table `grade_levels`
--
ALTER TABLE `grade_levels`
  ADD CONSTRAINT `fk_grade_education` FOREIGN KEY (`education_level_id`) REFERENCES `education_levels` (`education_level_id`);

--
-- Constraints for table `grading_periods`
--
ALTER TABLE `grading_periods`
  ADD CONSTRAINT `fk_gp_locked_by` FOREIGN KEY (`locked_by`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_gp_status` FOREIGN KEY (`grading_period_status_id`) REFERENCES `grading_period_statuses` (`grading_period_status_id`),
  ADD CONSTRAINT `fk_gp_sy` FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`);

--
-- Constraints for table `interventions`
--
ALTER TABLE `interventions`
  ADD CONSTRAINT `fk_iv_conductor` FOREIGN KEY (`conducted_by`) REFERENCES `employees` (`employee_id`),
  ADD CONSTRAINT `fk_iv_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`enrollment_id`),
  ADD CONSTRAINT `fk_iv_risk` FOREIGN KEY (`risk_assessment_id`) REFERENCES `risk_assessments` (`risk_assessment_id`),
  ADD CONSTRAINT `fk_iv_status` FOREIGN KEY (`intervention_status_id`) REFERENCES `intervention_statuses` (`intervention_status_id`);

--
-- Constraints for table `learners`
--
ALTER TABLE `learners`
  ADD CONSTRAINT `fk_learner_civil` FOREIGN KEY (`civil_status_id`) REFERENCES `civil_statuses` (`civil_status_id`),
  ADD CONSTRAINT `fk_learner_extension` FOREIGN KEY (`name_extension_id`) REFERENCES `name_extensions` (`extension_id`),
  ADD CONSTRAINT `fk_learner_indigenous_group` FOREIGN KEY (`indigenous_group_id`) REFERENCES `indigenous_groups` (`indigenous_group_id`),
  ADD CONSTRAINT `fk_learner_mother_tongue` FOREIGN KEY (`mother_tongue_id`) REFERENCES `mother_tongues` (`mother_tongue_id`),
  ADD CONSTRAINT `fk_learner_religion` FOREIGN KEY (`religion_id`) REFERENCES `religions` (`religion_id`),
  ADD CONSTRAINT `fk_learner_status` FOREIGN KEY (`learner_status_id`) REFERENCES `learner_statuses` (`learner_status_id`),
  ADD CONSTRAINT `fk_learner_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `learner_citizenships`
--
ALTER TABLE `learner_citizenships`
  ADD CONSTRAINT `fk_lc_citizenship` FOREIGN KEY (`citizenship_id`) REFERENCES `citizenships` (`citizenship_id`),
  ADD CONSTRAINT `fk_lc_learner` FOREIGN KEY (`learner_id`) REFERENCES `learners` (`learner_id`);

--
-- Constraints for table `learner_documents`
--
ALTER TABLE `learner_documents`
  ADD CONSTRAINT `fk_ld_document_type` FOREIGN KEY (`document_type_id`) REFERENCES `document_types` (`document_type_id`),
  ADD CONSTRAINT `fk_ld_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`enrollment_id`),
  ADD CONSTRAINT `fk_ld_learner` FOREIGN KEY (`learner_id`) REFERENCES `learners` (`learner_id`),
  ADD CONSTRAINT `fk_ld_school_year` FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`),
  ADD CONSTRAINT `fk_ld_submitted_by` FOREIGN KEY (`submitted_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `learner_preferred_modalities`
--
ALTER TABLE `learner_preferred_modalities`
  ADD CONSTRAINT `fk_lpm_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`enrollment_id`),
  ADD CONSTRAINT `fk_lpm_modality` FOREIGN KEY (`modality_id`) REFERENCES `learning_modalities` (`modality_id`);

--
-- Constraints for table `learner_previous_schools`
--
ALTER TABLE `learner_previous_schools`
  ADD CONSTRAINT `fk_lps_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`enrollment_id`),
  ADD CONSTRAINT `fk_lps_learner` FOREIGN KEY (`learner_id`) REFERENCES `learners` (`learner_id`);

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_notif_type` FOREIGN KEY (`notification_type_id`) REFERENCES `notification_types` (`notification_type_id`),
  ADD CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `report_cards`
--
ALTER TABLE `report_cards`
  ADD CONSTRAINT `fk_rc_enroll` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`enrollment_id`),
  ADD CONSTRAINT `fk_rc_period` FOREIGN KEY (`grading_period_id`) REFERENCES `grading_periods` (`grading_period_id`);

--
-- Constraints for table `risk_assessments`
--
ALTER TABLE `risk_assessments`
  ADD CONSTRAINT `fk_risk_assessed_by` FOREIGN KEY (`assessed_by`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_risk_enroll` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`enrollment_id`),
  ADD CONSTRAINT `fk_risk_level` FOREIGN KEY (`risk_level_id`) REFERENCES `risk_levels` (`risk_level_id`),
  ADD CONSTRAINT `fk_risk_period` FOREIGN KEY (`grading_period_id`) REFERENCES `grading_periods` (`grading_period_id`);

--
-- Constraints for table `risk_indicators`
--
ALTER TABLE `risk_indicators`
  ADD CONSTRAINT `fk_ri_assessment` FOREIGN KEY (`risk_assessment_id`) REFERENCES `risk_assessments` (`risk_assessment_id`);

--
-- Constraints for table `school_settings`
--
ALTER TABLE `school_settings`
  ADD CONSTRAINT `fk_ss_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `school_years`
--
ALTER TABLE `school_years`
  ADD CONSTRAINT `fk_sy_grading_type` FOREIGN KEY (`grading_system_type_id`) REFERENCES `grading_system_types` (`grading_system_type_id`);

--
-- Constraints for table `sections`
--
ALTER TABLE `sections`
  ADD CONSTRAINT `fk_section_grade` FOREIGN KEY (`grade_level_id`) REFERENCES `grade_levels` (`grade_level_id`);

--
-- Constraints for table `section_rankings`
--
ALTER TABLE `section_rankings`
  ADD CONSTRAINT `fk_sr_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`enrollment_id`),
  ADD CONSTRAINT `fk_sr_honor` FOREIGN KEY (`honor_level_id`) REFERENCES `honor_levels` (`honor_level_id`),
  ADD CONSTRAINT `fk_sr_ranked_by` FOREIGN KEY (`ranked_by`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_sr_school_year` FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`),
  ADD CONSTRAINT `fk_sr_section` FOREIGN KEY (`section_id`) REFERENCES `sections` (`section_id`);

--
-- Constraints for table `subjects`
--
ALTER TABLE `subjects`
  ADD CONSTRAINT `fk_subject_code` FOREIGN KEY (`subject_code_id`) REFERENCES `subject_codes` (`subject_code_id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
