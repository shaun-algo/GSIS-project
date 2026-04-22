-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Feb 19, 2026 at 02:24 PM
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
-- Database: `learners_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `audit_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `action` varchar(100) NOT NULL,
  `table_name` varchar(50) DEFAULT NULL,
  `record_id` int(11) DEFAULT NULL,
  `old_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Previous state of the record (JSON)' CHECK (json_valid(`old_value`)),
  `new_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'New state of the record (JSON)' CHECK (json_valid(`new_value`)),
  `action_time` datetime DEFAULT current_timestamp(),
  `ip_address` varchar(45) DEFAULT NULL COMMENT 'Requester IP address',
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Detailed audit trail with old/new JSON values for all data changes';

-- --------------------------------------------------------

--
-- Table structure for table `citizenships`
--

CREATE TABLE `citizenships` (
  `citizenship_id` int(11) NOT NULL,
  `country_name` varchar(100) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `citizenships`
--

INSERT INTO `citizenships` (`citizenship_id`, `country_name`, `is_deleted`, `deleted_at`) VALUES
(1, 'Filipino', 0, NULL),
(2, 'American', 0, NULL),
(3, 'Chinese', 0, NULL),
(4, 'Japanese', 0, NULL),
(5, 'Korean', 0, NULL),
(6, 'Others', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `civil_statuses`
--

CREATE TABLE `civil_statuses` (
  `civil_status_id` int(11) NOT NULL,
  `status_name` varchar(50) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `civil_statuses`
--

INSERT INTO `civil_statuses` (`civil_status_id`, `status_name`, `is_deleted`, `deleted_at`) VALUES
(1, 'Single', 0, NULL),
(2, 'Married', 0, NULL),
(3, 'Widowed', 0, NULL),
(4, 'Separated', 0, NULL);

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `education_levels`
--

CREATE TABLE `education_levels` (
  `education_level_id` int(11) NOT NULL,
  `level_name` varchar(50) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
  `student_id` int(11) NOT NULL,
  `person_name` varchar(100) NOT NULL,
  `family_relationship_id` int(11) NOT NULL,
  `mobile_no` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `employees`
--

CREATE TABLE `employees` (
  `employee_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `employee_number` varchar(30) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `enrollments`
--

CREATE TABLE `enrollments` (
  `enrollment_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `school_year_id` int(11) NOT NULL,
  `grade_level_id` int(11) NOT NULL,
  `section_id` int(11) NOT NULL,
  `enrollment_date` date NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `family_members`
--

CREATE TABLE `family_members` (
  `family_member_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `family_relationship_id` int(11) NOT NULL,
  `occupation` varchar(100) DEFAULT NULL,
  `mobile_no` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `family_relationships`
--

CREATE TABLE `family_relationships` (
  `family_relationship_id` int(11) NOT NULL,
  `relationship_name` varchar(50) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `family_relationships`
--

INSERT INTO `family_relationships` (`family_relationship_id`, `relationship_name`, `is_deleted`, `deleted_at`) VALUES
(1, 'Father', 0, NULL),
(2, 'Mother', 0, NULL),
(3, 'Guardian', 0, NULL),
(4, 'Grandfather', 0, NULL),
(5, 'Grandmother', 0, NULL),
(6, 'Brother', 0, NULL),
(7, 'Sister', 0, NULL),
(8, 'Uncle', 0, NULL),
(9, 'Aunt', 0, NULL),
(10, 'Girlfriend', 1, '2026-02-19 21:22:59');

-- --------------------------------------------------------

--
-- Table structure for table `final_grades`
--

CREATE TABLE `final_grades` (
  `final_grade_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `class_id` int(11) NOT NULL COMMENT 'Which class offering (subject) this grade is for',
  `final_grade` decimal(5,2) NOT NULL COMMENT 'Average of all quarterly grades for this subject',
  `remarks` enum('Passed','Failed') NOT NULL DEFAULT 'Passed',
  `computed_at` datetime DEFAULT current_timestamp() COMMENT 'Timestamp of computation — recomputation requires Admin approval',
  `computed_by` int(11) DEFAULT NULL COMMENT 'user_id who triggered computation',
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Computed final subject grades. Requires all grading periods locked before computation.';

-- --------------------------------------------------------

--
-- Table structure for table `general_averages`
--

CREATE TABLE `general_averages` (
  `general_average_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `school_year_id` int(11) NOT NULL,
  `general_average` decimal(5,2) NOT NULL COMMENT 'Mean of all final subject grades',
  `computed_at` datetime DEFAULT current_timestamp(),
  `computed_by` int(11) DEFAULT NULL COMMENT 'user_id who triggered computation',
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Computed GWA per student per school year. Feeds into section_rankings.';

-- --------------------------------------------------------

--
-- Table structure for table `grades`
--

CREATE TABLE `grades` (
  `grade_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `class_id` int(11) NOT NULL,
  `grading_period_id` int(11) NOT NULL,
  `grade_value` decimal(5,2) NOT NULL,
  `encoded_at` datetime DEFAULT current_timestamp(),
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `grade_levels`
--

CREATE TABLE `grade_levels` (
  `grade_level_id` int(11) NOT NULL,
  `grade_name` varchar(50) NOT NULL,
  `education_level_id` int(11) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `grade_levels`
--

INSERT INTO `grade_levels` (`grade_level_id`, `grade_name`, `education_level_id`, `is_deleted`, `deleted_at`) VALUES
(1, 'Grade 1', 1, 0, NULL),
(2, 'Grade 2', 1, 0, NULL),
(3, 'Grade 3', 1, 0, NULL),
(4, 'Grade 4', 1, 0, NULL),
(5, 'Grade 5', 1, 0, NULL),
(6, 'Grade 6', 1, 0, NULL),
(7, 'Grade 7', 2, 0, NULL),
(8, 'Grade 8', 2, 0, NULL),
(9, 'Grade 9', 2, 0, NULL),
(10, 'Grade 10', 2, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `grading_periods`
--

CREATE TABLE `grading_periods` (
  `grading_period_id` int(11) NOT NULL,
  `period_name` varchar(50) NOT NULL,
  `school_year_id` int(11) NOT NULL,
  `lock_status` enum('Open','Submitted','Approved','Locked') NOT NULL DEFAULT 'Open' COMMENT 'Grade locking workflow status',
  `locked_at` datetime DEFAULT NULL COMMENT 'Timestamp when period was locked',
  `locked_by` int(11) DEFAULT NULL COMMENT 'user_id who locked the period',
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `grading_periods`
--

INSERT INTO `grading_periods` (`grading_period_id`, `period_name`, `school_year_id`, `lock_status`, `locked_at`, `locked_by`, `is_deleted`, `deleted_at`) VALUES
(1, '1st Quarter', 1, 'Open', NULL, NULL, 0, NULL),
(2, '2nd Quarter', 1, 'Open', NULL, NULL, 0, NULL),
(3, '3rd Quarter', 1, 'Open', NULL, NULL, 0, NULL),
(4, '4th Quarter', 1, 'Open', NULL, NULL, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `grading_system_types`
--

CREATE TABLE `grading_system_types` (
  `grading_system_type_id` int(11) NOT NULL,
  `system_name` varchar(50) NOT NULL,
  `period_count` int(11) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `grading_system_types`
--

INSERT INTO `grading_system_types` (`grading_system_type_id`, `system_name`, `period_count`, `is_deleted`, `deleted_at`) VALUES
(1, 'Quarterly', 4, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `honor_levels`
--

CREATE TABLE `honor_levels` (
  `honor_level_id` int(11) NOT NULL,
  `honor_name` varchar(100) NOT NULL COMMENT 'e.g., With Honors',
  `min_average` decimal(5,2) NOT NULL COMMENT 'Minimum GWA to qualify',
  `max_average` decimal(5,2) NOT NULL COMMENT 'Maximum GWA for this level',
  `min_subject_grade` decimal(5,2) NOT NULL DEFAULT 85.00 COMMENT 'No subject grade below this value',
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Configurable DepEd honors policy — do not hardcode these values in application code';

--
-- Dumping data for table `honor_levels`
--

INSERT INTO `honor_levels` (`honor_level_id`, `honor_name`, `min_average`, `max_average`, `min_subject_grade`, `is_deleted`, `deleted_at`) VALUES
(1, 'With Honors', 90.00, 94.99, 85.00, 0, NULL),
(2, 'With High Honors', 95.00, 97.99, 85.00, 0, NULL),
(3, 'With Highest Honors', 98.00, 100.00, 85.00, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `interventions`
--

CREATE TABLE `interventions` (
  `intervention_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `risk_assessment_id` int(11) DEFAULT NULL COMMENT 'Linked risk assessment if applicable',
  `conducted_by` int(11) NOT NULL COMMENT 'employee_id of Guidance/Adviser',
  `intervention_type` varchar(100) NOT NULL COMMENT 'e.g., Counseling, Academic Support, Parent Meeting',
  `description` text DEFAULT NULL,
  `conducted_at` datetime DEFAULT current_timestamp(),
  `follow_up_date` date DEFAULT NULL,
  `status` enum('Pending','Ongoing','Resolved','Escalated') NOT NULL DEFAULT 'Pending',
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Intervention records for at-risk students, tracked by Guidance and Adviser';

-- --------------------------------------------------------

--
-- Table structure for table `name_extensions`
--

CREATE TABLE `name_extensions` (
  `extension_id` int(11) NOT NULL,
  `extension_name` varchar(10) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `name_extensions`
--

INSERT INTO `name_extensions` (`extension_id`, `extension_name`, `is_deleted`, `deleted_at`) VALUES
(1, 'Jr.', 0, NULL),
(2, 'Sr.', 0, NULL),
(3, 'II', 0, NULL),
(4, 'III', 0, NULL),
(5, 'IV', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `religions`
--

CREATE TABLE `religions` (
  `religion_id` int(11) NOT NULL,
  `religion_name` varchar(50) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `religions`
--

INSERT INTO `religions` (`religion_id`, `religion_name`, `is_deleted`, `deleted_at`) VALUES
(1, 'Roman Catholic', 0, NULL),
(2, 'Islam', 0, NULL),
(3, 'Iglesia ni Cristo', 0, NULL),
(4, 'Born Again Christian', 0, NULL),
(5, 'Seventh-day Adventist', 0, NULL),
(6, 'Jehovah\'s Witness', 0, NULL),
(7, 'Baptist', 0, NULL),
(8, 'Methodist', 0, NULL),
(9, 'Aglipayan', 0, NULL),
(10, 'Others', 0, NULL),
(11, 'DragonBall', 1, '2026-02-19 21:19:23');

-- --------------------------------------------------------

--
-- Table structure for table `report_cards`
--

CREATE TABLE `report_cards` (
  `report_card_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `grading_period_id` int(11) NOT NULL,
  `generated_at` datetime DEFAULT current_timestamp(),
  `file_path` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `risk_assessments`
--

CREATE TABLE `risk_assessments` (
  `risk_assessment_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `grading_period_id` int(11) NOT NULL,
  `risk_level_id` int(11) NOT NULL,
  `risk_score` int(11) NOT NULL,
  `assessed_at` datetime DEFAULT current_timestamp(),
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `risk_indicators`
--

CREATE TABLE `risk_indicators` (
  `indicator_id` int(11) NOT NULL,
  `risk_assessment_id` int(11) NOT NULL,
  `indicator_name` varchar(100) NOT NULL COMMENT 'e.g., Grade Score, Trend Score',
  `indicator_score` int(11) NOT NULL COMMENT 'Component score',
  `indicator_weight` decimal(5,2) DEFAULT NULL COMMENT 'Weight applied to this component',
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Detailed breakdown of risk score per indicator for explainable analytics';

-- --------------------------------------------------------

--
-- Table structure for table `risk_levels`
--

CREATE TABLE `risk_levels` (
  `risk_level_id` int(11) NOT NULL,
  `risk_name` varchar(50) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `risk_levels`
--

INSERT INTO `risk_levels` (`risk_level_id`, `risk_name`, `is_deleted`, `deleted_at`) VALUES
(1, 'Low Risk', 0, NULL),
(2, 'Moderate Risk', 0, NULL),
(3, 'High Risk', 0, NULL),
(4, 'Critical', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `role_id` int(11) NOT NULL,
  `role_name` varchar(50) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`role_id`, `role_name`, `is_deleted`, `deleted_at`) VALUES
(1, 'Super Admin', 0, NULL),
(2, 'School Administrator', 0, NULL),
(3, 'Registrar', 0, NULL),
(4, 'Teacher', 0, NULL),
(5, 'Guidance Counselor', 0, NULL),
(6, 'Principal', 0, NULL),
(7, 'Adviser', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `school_years`
--

CREATE TABLE `school_years` (
  `school_year_id` int(11) NOT NULL,
  `year_start` year(4) NOT NULL,
  `year_end` year(4) NOT NULL,
  `grading_system_type_id` int(11) NOT NULL,
  `is_active` tinyint(1) DEFAULT 0,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `school_years`
--

INSERT INTO `school_years` (`school_year_id`, `year_start`, `year_end`, `grading_system_type_id`, `is_active`, `is_deleted`, `deleted_at`) VALUES
(1, '2025', '2026', 1, 1, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `sections`
--

CREATE TABLE `sections` (
  `section_id` int(11) NOT NULL,
  `grade_level_id` int(11) NOT NULL,
  `section_name` varchar(50) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sections`
--

INSERT INTO `sections` (`section_id`, `grade_level_id`, `section_name`, `is_deleted`, `deleted_at`) VALUES
(1, 1, 'Euclid', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `section_rankings`
--

CREATE TABLE `section_rankings` (
  `ranking_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `section_id` int(11) NOT NULL,
  `school_year_id` int(11) NOT NULL,
  `rank_position` int(11) NOT NULL COMMENT 'Rank within section (1 = highest GWA)',
  `honor_level_id` int(11) DEFAULT NULL COMMENT 'NULL if student does not qualify for honors',
  `ranked_at` datetime DEFAULT current_timestamp(),
  `ranked_by` int(11) DEFAULT NULL COMMENT 'user_id (Admin/Principal) who triggered ranking',
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Section ranking and honors classification. Only Admin/Principal may trigger computation.';

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `student_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `lrn` varchar(20) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `name_extension_id` int(11) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `sex` varchar(10) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `student_status_id` int(11) DEFAULT NULL,
  `religion_id` int(11) DEFAULT NULL,
  `civil_status_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_citizenships`
--

CREATE TABLE `student_citizenships` (
  `student_citizenship_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `citizenship_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_statuses`
--

CREATE TABLE `student_statuses` (
  `student_status_id` int(11) NOT NULL,
  `status_name` varchar(50) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student_statuses`
--

INSERT INTO `student_statuses` (`student_status_id`, `status_name`, `is_deleted`, `deleted_at`) VALUES
(1, 'Active', 0, NULL),
(2, 'Transferred In', 0, NULL),
(3, 'Transferred Out', 0, NULL),
(4, 'Dropped', 0, NULL),
(5, 'Graduated', 0, NULL),
(6, 'Promoted', 0, NULL),
(7, 'Retained', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `subjects`
--

CREATE TABLE `subjects` (
  `subject_id` int(11) NOT NULL,
  `subject_code_id` int(11) NOT NULL,
  `subject_name` varchar(100) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `subjects`
--

INSERT INTO `subjects` (`subject_id`, `subject_code_id`, `subject_name`, `is_deleted`, `deleted_at`) VALUES
(1, 1, 'Mother Tongue', 0, NULL),
(2, 2, 'Filipino', 0, NULL),
(3, 3, 'English', 0, NULL),
(4, 4, 'Mathematics', 0, NULL),
(5, 5, 'Science', 0, NULL),
(6, 6, 'Araling Panlipunan', 0, NULL),
(7, 7, 'Edukasyon sa Pagpapakatao', 0, NULL),
(8, 8, 'Music', 0, NULL),
(9, 9, 'Arts', 0, NULL),
(10, 10, 'Physical Education and Health', 0, NULL),
(11, 11, 'Technology & Livelihood Education', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `subject_codes`
--

CREATE TABLE `subject_codes` (
  `subject_code_id` int(11) NOT NULL,
  `subject_code` varchar(30) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `subject_codes`
--

INSERT INTO `subject_codes` (`subject_code_id`, `subject_code`, `is_deleted`, `deleted_at`) VALUES
(1, 'MT', 0, NULL),
(2, 'FIL', 0, NULL),
(3, 'ENG', 0, NULL),
(4, 'MATH', 0, NULL),
(5, 'SCI', 0, NULL),
(6, 'AP', 0, NULL),
(7, 'ESP', 0, NULL),
(8, 'MUS', 0, NULL),
(9, 'ART', 0, NULL),
(10, 'PEH', 0, NULL),
(11, 'TLE', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(30) NOT NULL,
  `password_hash` varchar(255) NOT NULL COMMENT 'Hashed via password_hash() PHP function',
  `role_id` int(11) NOT NULL,
  `must_change_password` tinyint(1) DEFAULT 1,
  `is_active` tinyint(1) DEFAULT 1,
  `failed_login_attempts` int(11) DEFAULT 0 COMMENT 'Tracks consecutive failed login attempts',
  `locked_until` datetime DEFAULT NULL COMMENT 'Account locked until this datetime after too many failures',
  `last_login_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `announcements`
--

CREATE TABLE `announcements` (
  `announcement_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` longtext NOT NULL,
  `posted_by` int(11) NOT NULL COMMENT 'FK to users table',
  `posted_at` datetime DEFAULT current_timestamp(),
  `posted_date` date DEFAULT NULL COMMENT 'Date for easy reporting',
  `target_audience` enum('All','Admin','Teachers','Parents','Students') DEFAULT 'All',
  `is_active` tinyint(1) DEFAULT 1,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='School announcements and notices for all users';

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_at_risk_students`
-- (See below for the actual view)
--
CREATE TABLE `vw_at_risk_students` (
`student_id` int(11)
,`student_name` varchar(201)
,`section_name` varchar(50)
,`grade_name` varchar(50)
,`risk_name` varchar(50)
,`risk_score` int(11)
,`assessed_at` datetime
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_honors_list`
-- (See below for the actual view)
--
CREATE TABLE `vw_honors_list` (
`student_id` int(11)
,`student_name` varchar(201)
,`section_name` varchar(50)
,`grade_name` varchar(50)
,`year_start` year(4)
,`year_end` year(4)
,`general_average` decimal(5,2)
,`rank_position` int(11)
,`honor_name` varchar(100)
);

-- --------------------------------------------------------

--
-- Structure for view `vw_at_risk_students`
--
DROP TABLE IF EXISTS `vw_at_risk_students`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_at_risk_students`  AS SELECT `s`.`student_id` AS `student_id`, concat(`s`.`first_name`,' ',`s`.`last_name`) AS `student_name`, `sec`.`section_name` AS `section_name`, `gl`.`grade_name` AS `grade_name`, `rl`.`risk_name` AS `risk_name`, `ra`.`risk_score` AS `risk_score`, `ra`.`assessed_at` AS `assessed_at` FROM (((((`risk_assessments` `ra` join `enrollments` `e` on(`e`.`enrollment_id` = `ra`.`enrollment_id` and `e`.`is_deleted` = 0)) join `students` `s` on(`s`.`student_id` = `e`.`student_id` and `s`.`is_deleted` = 0)) join `sections` `sec` on(`sec`.`section_id` = `e`.`section_id` and `sec`.`is_deleted` = 0)) join `grade_levels` `gl` on(`gl`.`grade_level_id` = `e`.`grade_level_id` and `gl`.`is_deleted` = 0)) join `risk_levels` `rl` on(`rl`.`risk_level_id` = `ra`.`risk_level_id` and `rl`.`is_deleted` = 0)) WHERE `ra`.`is_deleted` = 0 AND `rl`.`risk_name` in ('High Risk','Critical') ORDER BY `ra`.`risk_score` DESC ;

-- --------------------------------------------------------

--
-- Structure for view `vw_honors_list`
--
DROP TABLE IF EXISTS `vw_honors_list`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_honors_list`  AS SELECT `s`.`student_id` AS `student_id`, concat(`s`.`first_name`,' ',`s`.`last_name`) AS `student_name`, `sec`.`section_name` AS `section_name`, `gl`.`grade_name` AS `grade_name`, `sy`.`year_start` AS `year_start`, `sy`.`year_end` AS `year_end`, `ga`.`general_average` AS `general_average`, `sr`.`rank_position` AS `rank_position`, `hl`.`honor_name` AS `honor_name` FROM (((((((`section_rankings` `sr` join `enrollments` `e` on(`e`.`enrollment_id` = `sr`.`enrollment_id` and `e`.`is_deleted` = 0)) join `students` `s` on(`s`.`student_id` = `e`.`student_id` and `s`.`is_deleted` = 0)) join `sections` `sec` on(`sec`.`section_id` = `sr`.`section_id` and `sec`.`is_deleted` = 0)) join `grade_levels` `gl` on(`gl`.`grade_level_id` = `e`.`grade_level_id` and `gl`.`is_deleted` = 0)) join `school_years` `sy` on(`sy`.`school_year_id` = `sr`.`school_year_id` and `sy`.`is_deleted` = 0)) join `general_averages` `ga` on(`ga`.`enrollment_id` = `sr`.`enrollment_id` and `ga`.`is_deleted` = 0)) left join `honor_levels` `hl` on(`hl`.`honor_level_id` = `sr`.`honor_level_id` and `hl`.`is_deleted` = 0)) WHERE `sr`.`is_deleted` = 0 ORDER BY `sec`.`section_name` ASC, `sr`.`rank_position` ASC ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`audit_id`),
  ADD KEY `idx_audit_user` (`user_id`),
  ADD KEY `idx_audit_table_record` (`table_name`,`record_id`),
  ADD KEY `idx_audit_action_time` (`action_time`);

--
-- Indexes for table `announcements`
--
ALTER TABLE `announcements`
  ADD PRIMARY KEY (`announcement_id`),
  ADD KEY `idx_announcement_posted_by` (`posted_by`),
  ADD KEY `idx_announcement_posted_date` (`posted_date`),
  ADD KEY `idx_announcement_active` (`is_active`);

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
  ADD UNIQUE KEY `uq_status_name` (`status_name`);

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
  ADD KEY `idx_ec_student` (`student_id`),
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
  ADD UNIQUE KEY `uq_student_school_year` (`student_id`,`school_year_id`),
  ADD KEY `idx_enroll_student` (`student_id`),
  ADD KEY `idx_enroll_sy` (`school_year_id`),
  ADD KEY `idx_enroll_grade` (`grade_level_id`),
  ADD KEY `idx_enroll_section` (`section_id`),
  ADD KEY `idx_dashboard_composite` (`school_year_id`,`grade_level_id`,`section_id`) COMMENT 'Composite index for optimized dashboard queries';

--
-- Indexes for table `family_members`
--
ALTER TABLE `family_members`
  ADD PRIMARY KEY (`family_member_id`),
  ADD KEY `idx_family_student` (`student_id`),
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
  ADD KEY `idx_fg_computed_by` (`computed_by`);

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
-- Indexes for table `grading_periods`
--
ALTER TABLE `grading_periods`
  ADD PRIMARY KEY (`grading_period_id`),
  ADD UNIQUE KEY `uq_period_school_year` (`school_year_id`,`period_name`),
  ADD KEY `idx_gp_locked_by` (`locked_by`);

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
-- Indexes for table `interventions`
--
ALTER TABLE `interventions`
  ADD PRIMARY KEY (`intervention_id`),
  ADD KEY `idx_intervention_enrollment` (`enrollment_id`),
  ADD KEY `idx_intervention_risk` (`risk_assessment_id`),
  ADD KEY `idx_intervention_conductor` (`conducted_by`);

--
-- Indexes for table `name_extensions`
--
ALTER TABLE `name_extensions`
  ADD PRIMARY KEY (`extension_id`),
  ADD UNIQUE KEY `uq_extension_name` (`extension_name`);

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
  ADD KEY `idx_risk_level` (`risk_level_id`);

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
  ADD KEY `fk_sr_school_year` (`school_year_id`);

--
-- Indexes for table `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`student_id`),
  ADD UNIQUE KEY `uq_student_user` (`user_id`),
  ADD UNIQUE KEY `uq_student_lrn` (`lrn`),
  ADD KEY `idx_student_status` (`student_status_id`),
  ADD KEY `idx_student_religion` (`religion_id`),
  ADD KEY `idx_student_civil` (`civil_status_id`),
  ADD KEY `idx_student_extension` (`name_extension_id`);

--
-- Indexes for table `student_citizenships`
--
ALTER TABLE `student_citizenships`
  ADD PRIMARY KEY (`student_citizenship_id`),
  ADD UNIQUE KEY `uq_student_citizenship` (`student_id`,`citizenship_id`),
  ADD KEY `idx_sc_citizenship` (`citizenship_id`);

--
-- Indexes for table `student_statuses`
--
ALTER TABLE `student_statuses`
  ADD PRIMARY KEY (`student_status_id`),
  ADD UNIQUE KEY `uq_status_name` (`status_name`);

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
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `audit_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `announcements`
--
ALTER TABLE `announcements`
  MODIFY `announcement_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `citizenships`
--
ALTER TABLE `citizenships`
  MODIFY `citizenship_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `civil_statuses`
--
ALTER TABLE `civil_statuses`
  MODIFY `civil_status_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `class_offerings`
--
ALTER TABLE `class_offerings`
  MODIFY `class_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `education_levels`
--
ALTER TABLE `education_levels`
  MODIFY `education_level_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

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
-- AUTO_INCREMENT for table `family_members`
--
ALTER TABLE `family_members`
  MODIFY `family_member_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `family_relationships`
--
ALTER TABLE `family_relationships`
  MODIFY `family_relationship_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

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
  MODIFY `grade_level_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `grading_periods`
--
ALTER TABLE `grading_periods`
  MODIFY `grading_period_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

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
-- AUTO_INCREMENT for table `interventions`
--
ALTER TABLE `interventions`
  MODIFY `intervention_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `name_extensions`
--
ALTER TABLE `name_extensions`
  MODIFY `extension_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `religions`
--
ALTER TABLE `religions`
  MODIFY `religion_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

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
-- AUTO_INCREMENT for table `students`
--
ALTER TABLE `students`
  MODIFY `student_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `student_citizenships`
--
ALTER TABLE `student_citizenships`
  MODIFY `student_citizenship_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `student_statuses`
--
ALTER TABLE `student_statuses`
  MODIFY `student_status_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `subjects`
--
ALTER TABLE `subjects`
  MODIFY `subject_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `subject_codes`
--
ALTER TABLE `subject_codes`
  MODIFY `subject_code_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `fk_audit_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `announcements`
--
ALTER TABLE `announcements`
  ADD CONSTRAINT `fk_announcement_user` FOREIGN KEY (`posted_by`) REFERENCES `users` (`user_id`);

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
  ADD CONSTRAINT `fk_ec_relationship` FOREIGN KEY (`family_relationship_id`) REFERENCES `family_relationships` (`family_relationship_id`),
  ADD CONSTRAINT `fk_ec_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`);

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
  ADD CONSTRAINT `fk_enroll_section` FOREIGN KEY (`section_id`) REFERENCES `sections` (`section_id`),
  ADD CONSTRAINT `fk_enroll_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  ADD CONSTRAINT `fk_enroll_sy` FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`);

--
-- Constraints for table `family_members`
--
ALTER TABLE `family_members`
  ADD CONSTRAINT `fk_family_relationship` FOREIGN KEY (`family_relationship_id`) REFERENCES `family_relationships` (`family_relationship_id`),
  ADD CONSTRAINT `fk_family_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`);

--
-- Constraints for table `final_grades`
--
ALTER TABLE `final_grades`
  ADD CONSTRAINT `fk_fg_class` FOREIGN KEY (`class_id`) REFERENCES `class_offerings` (`class_id`),
  ADD CONSTRAINT `fk_fg_computed_by` FOREIGN KEY (`computed_by`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_fg_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`enrollment_id`);

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
  ADD CONSTRAINT `fk_gp_sy` FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`);

--
-- Constraints for table `interventions`
--
ALTER TABLE `interventions`
  ADD CONSTRAINT `fk_iv_conductor` FOREIGN KEY (`conducted_by`) REFERENCES `employees` (`employee_id`),
  ADD CONSTRAINT `fk_iv_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`enrollment_id`),
  ADD CONSTRAINT `fk_iv_risk` FOREIGN KEY (`risk_assessment_id`) REFERENCES `risk_assessments` (`risk_assessment_id`);

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
  ADD CONSTRAINT `fk_risk_enroll` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`enrollment_id`),
  ADD CONSTRAINT `fk_risk_level` FOREIGN KEY (`risk_level_id`) REFERENCES `risk_levels` (`risk_level_id`),
  ADD CONSTRAINT `fk_risk_period` FOREIGN KEY (`grading_period_id`) REFERENCES `grading_periods` (`grading_period_id`);

--
-- Constraints for table `risk_indicators`
--
ALTER TABLE `risk_indicators`
  ADD CONSTRAINT `fk_ri_assessment` FOREIGN KEY (`risk_assessment_id`) REFERENCES `risk_assessments` (`risk_assessment_id`);

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
-- Constraints for table `students`
--
ALTER TABLE `students`
  ADD CONSTRAINT `fk_student_civil` FOREIGN KEY (`civil_status_id`) REFERENCES `civil_statuses` (`civil_status_id`),
  ADD CONSTRAINT `fk_student_extension` FOREIGN KEY (`name_extension_id`) REFERENCES `name_extensions` (`extension_id`),
  ADD CONSTRAINT `fk_student_religion` FOREIGN KEY (`religion_id`) REFERENCES `religions` (`religion_id`),
  ADD CONSTRAINT `fk_student_status` FOREIGN KEY (`student_status_id`) REFERENCES `student_statuses` (`student_status_id`),
  ADD CONSTRAINT `fk_student_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `student_citizenships`
--
ALTER TABLE `student_citizenships`
  ADD CONSTRAINT `fk_sc_citizenship` FOREIGN KEY (`citizenship_id`) REFERENCES `citizenships` (`citizenship_id`),
  ADD CONSTRAINT `fk_sc_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`);

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
