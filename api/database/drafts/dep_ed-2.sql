-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Mar 25, 2026 at 02:30 PM
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
-- Database: `dep_ed`
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
  `is_pinned` tinyint(1) DEFAULT 0,
  `attachment_url` varchar(500) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='School-wide announcements — enrollment schedules, events, urgent notices';

--
-- Dumping data for table `announcements`
--

INSERT INTO `announcements` (`announcement_id`, `title`, `body`, `posted_by`, `target_role_id`, `published_at`, `expires_at`, `is_pinned`, `attachment_url`, `is_deleted`, `deleted_at`) VALUES
(6, 'Welcome to Academic Year 2025-2026', 'We are excited to welcome all students and faculty to the new academic year! Classes begin on Monday.', 1, NULL, '2026-02-20 22:37:10', NULL, 0, NULL, 0, NULL),
(7, 'Parent-Teacher Meeting This Friday', 'All parents are invited. Venue: School Auditorium. Time: 2:00 PM – 5:00 PM.', 1, NULL, '2026-02-20 20:37:43', NULL, 0, NULL, 0, NULL),
(8, 'School Clinic Hours Extended', 'Our school clinic will now be open from 7:00 AM to 6:00 PM daily.', 1, NULL, '2026-02-20 17:37:43', NULL, 0, NULL, 0, NULL),
(9, 'Upcoming Science Fair', 'The annual Science Fair will be held on March 15, 2026. Registration forms available at the Science Department.', 1, NULL, '2026-02-19 22:37:43', NULL, 0, NULL, 0, NULL),
(38, 'Deadline Notice', 'Grade Submission Deadline on October 1, 2027! Stay tuned!', 1, NULL, '2026-02-21 02:19:41', NULL, 0, NULL, 0, NULL),
(48, 'REPOST', 'Good morning everyone! DepEd to conduct Early Registration this January 26, 2019.', 27, 8, '2026-02-21 13:09:09', NULL, 0, NULL, 1, '2026-03-20 21:22:30'),
(50, 'Greetings for students', 'Hello!!', 1, 10, '2026-02-23 12:47:58', NULL, 0, NULL, 0, NULL),
(51, 'students can you see this?', 'testing', 1, 9, '2026-02-23 13:09:02', NULL, 0, NULL, 0, NULL),
(52, 'a', 'a', 28, 8, '2026-02-23 13:10:03', NULL, 0, NULL, 0, NULL),
(53, 'hello teacher only view post', 'test', 29, 9, '2026-02-23 14:21:00', NULL, 0, NULL, 0, NULL),
(54, 'this post is specialized for the teachers', 'test', 1, 9, '2026-02-23 14:27:35', NULL, 0, NULL, 0, NULL),
(55, 'hello', 'hey', 27, 10, '2026-03-20 18:15:38', NULL, 0, NULL, 1, '2026-03-20 19:41:22'),
(56, 'expiry', 'test', 27, NULL, '2026-03-20 19:48:29', '2026-03-20 07:50:00', 0, NULL, 1, '2026-03-20 19:48:40'),
(57, 'test', 'test', 27, NULL, '2026-03-20 19:49:25', '2026-03-20 18:55:00', 0, NULL, 1, '2026-03-20 20:18:21'),
(58, 'e', 'e', 1, NULL, '2026-03-20 21:56:43', NULL, 0, NULL, 1, '2026-03-20 22:31:38'),
(59, 'announcement', 'attention teachers!', 27, 9, '2026-03-24 16:54:11', NULL, 0, NULL, 0, NULL),
(60, 'fuck u', 'fuck me', 1, NULL, '2026-03-25 14:32:35', NULL, 0, NULL, 1, '2026-03-25 14:32:40');

-- --------------------------------------------------------

--
-- Table structure for table `attendance`
--

CREATE TABLE `attendance` (
  `attendance_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `class_id` int(11) NOT NULL DEFAULT 0 COMMENT '0 = whole-day homeroom; >0 = specific class',
  `grading_period_id` int(11) NOT NULL,
  `attendance_date` date NOT NULL,
  `status` enum('Present','Absent','Late','Excused') NOT NULL DEFAULT 'Present',
  `remarks` varchar(255) DEFAULT NULL,
  `recorded_by` int(11) DEFAULT NULL,
  `recorded_at` datetime DEFAULT current_timestamp(),
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Daily or per-period attendance. class_id=0 means whole-day homeroom record.';

--
-- Triggers `attendance`
--
DELIMITER $$
CREATE TRIGGER `trg_attendance_bi_validate_refs` BEFORE INSERT ON `attendance` FOR EACH ROW BEGIN
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
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_attendance_bu_validate_refs` BEFORE UPDATE ON `attendance` FOR EACH ROW BEGIN
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
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `attendance_monthly_summaries`
--

CREATE TABLE `attendance_monthly_summaries` (
  `summary_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `school_year_id` int(11) NOT NULL,
  `month_no` tinyint(3) UNSIGNED NOT NULL COMMENT '1..12',
  `total_school_days` int(11) DEFAULT NULL,
  `days_present` int(11) DEFAULT 0,
  `days_absent` int(11) DEFAULT 0,
  `days_late` int(11) DEFAULT 0,
  `days_excused` int(11) DEFAULT 0,
  `computed_by` int(11) DEFAULT NULL,
  `computed_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `audit_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `table_name` varchar(100) NOT NULL,
  `record_id` int(11) DEFAULT NULL,
  `action` varchar(50) NOT NULL COMMENT 'INSERT, UPDATE, DELETE',
  `old_values` longtext DEFAULT NULL,
  `new_values` longtext DEFAULT NULL,
  `action_time` datetime DEFAULT current_timestamp(),
  `ip_address` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Tracks all data changes for accountability';

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
(1, 'Filipino', 0, NULL);

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

--
-- Dumping data for table `class_offerings`
--

INSERT INTO `class_offerings` (`class_id`, `subject_id`, `section_id`, `teacher_id`, `school_year_id`, `is_deleted`, `deleted_at`) VALUES
(1, 5, 2, 1, 2, 0, NULL),
(2, 3, 2, 1, 2, 0, NULL),
(3, 8, 2, 1, 2, 0, NULL),
(4, 10, 3, 1, 2, 0, NULL),
(5, 2, 3, 26, 5, 0, NULL),
(6, 11, 3, 27, 5, 0, NULL),
(7, 3, 3, 27, 5, 0, NULL),
(8, 7, 3, 27, 5, 0, NULL),
(9, 9, 3, 27, 5, 0, NULL),
(10, 12, 3, 27, 5, 0, NULL),
(11, 16, 3, 27, 5, 0, NULL),
(12, 15, 2, 1, 5, 0, NULL),
(13, 13, 2, 1, 5, 0, NULL),
(14, 2, 2, 1, 5, 0, NULL),
(15, 8, 2, 1, 5, 0, NULL),
(16, 1, 2, 1, 5, 0, NULL),
(17, 4, 2, 1, 5, 0, NULL),
(18, 13, 3, 27, 5, 0, NULL),
(19, 5, 3, 26, 5, 0, NULL),
(20, 16, 3, 26, 5, 0, NULL),
(21, 10, 3, 26, 5, 0, NULL),
(22, 12, 3, 26, 5, 0, NULL),
(23, 9, 3, 26, 5, 0, NULL),
(24, 7, 3, 26, 5, 0, NULL),
(25, 4, 3, 26, 5, 0, NULL),
(26, 11, 3, 26, 5, 0, NULL),
(27, 1, 3, 26, 5, 0, NULL),
(28, 6, 3, 26, 5, 0, NULL),
(29, 13, 3, 26, 5, 0, NULL),
(30, 15, 3, 26, 5, 0, NULL),
(31, 8, 3, 26, 5, 0, NULL),
(32, 2, 4, 28, 5, 0, NULL),
(33, 3, 4, 28, 5, 0, NULL),
(34, 4, 4, 28, 5, 0, NULL),
(35, 5, 4, 28, 5, 0, NULL),
(36, 6, 4, 28, 5, 0, NULL),
(37, 7, 4, 28, 5, 0, NULL),
(38, 10, 4, 28, 5, 0, NULL),
(39, 12, 4, 28, 5, 0, NULL),
(40, 2, 4, 1, 5, 0, NULL),
(41, 3, 4, 1, 5, 0, NULL),
(42, 4, 4, 1, 5, 0, NULL),
(43, 5, 4, 1, 5, 0, NULL),
(44, 6, 4, 1, 5, 0, NULL),
(45, 7, 4, 1, 5, 0, NULL),
(46, 10, 4, 1, 5, 0, NULL),
(47, 12, 4, 1, 5, 0, NULL),
(48, 1, 3, 27, 5, 0, NULL),
(49, 2, 3, 27, 5, 0, NULL),
(50, 4, 3, 27, 5, 0, NULL),
(51, 5, 3, 27, 5, 0, NULL),
(52, 6, 3, 27, 5, 0, NULL),
(53, 8, 3, 27, 5, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `class_schedules`
--

CREATE TABLE `class_schedules` (
  `schedule_id` int(11) NOT NULL,
  `class_id` int(11) NOT NULL,
  `day_of_week` enum('Mon','Tue','Wed','Thu','Fri','Sat') NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `room` varchar(50) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `curricula`
--

CREATE TABLE `curricula` (
  `curriculum_id` int(11) NOT NULL,
  `curriculum_code` varchar(30) NOT NULL COMMENT 'e.g. K12-2013, MATATAG-2023',
  `curriculum_name` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `effective_from` year(4) NOT NULL,
  `effective_until` year(4) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Master list of DepEd curriculum editions';

--
-- Dumping data for table `curricula`
--

INSERT INTO `curricula` (`curriculum_id`, `curriculum_code`, `curriculum_name`, `description`, `effective_from`, `effective_until`, `is_active`, `is_deleted`, `deleted_at`, `created_at`, `created_by`) VALUES
(1, 'MATATAG-2023', 'MATATAG K-12 Curriculum (DepEd 2023)', 'Revised DepEd curriculum effective SY 2023-2024 onward. Covers Grades 1-10 with updated subjects including GMRC and Makabansa.', '2023', NULL, 1, 0, NULL, '2026-03-21 14:51:04', 1);

-- --------------------------------------------------------

--
-- Table structure for table `curriculum_grade_levels`
--

CREATE TABLE `curriculum_grade_levels` (
  `cgl_id` int(11) NOT NULL,
  `curriculum_id` int(11) NOT NULL,
  `grade_level_id` int(11) NOT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Which grade levels are covered by a curriculum edition';

--
-- Dumping data for table `curriculum_grade_levels`
--

INSERT INTO `curriculum_grade_levels` (`cgl_id`, `curriculum_id`, `grade_level_id`, `sort_order`, `is_deleted`, `deleted_at`) VALUES
(1, 1, 1, 1, 0, NULL),
(2, 1, 2, 2, 0, NULL),
(3, 1, 3, 3, 0, NULL),
(4, 1, 4, 4, 0, NULL),
(5, 1, 5, 5, 0, NULL),
(6, 1, 6, 6, 0, NULL),
(7, 1, 7, 7, 0, NULL),
(8, 1, 8, 8, 0, NULL),
(9, 1, 9, 9, 0, NULL),
(10, 1, 10, 10, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `curriculum_grading_components`
--

CREATE TABLE `curriculum_grading_components` (
  `component_id` int(11) NOT NULL,
  `curriculum_id` int(11) NOT NULL,
  `grade_level_id` int(11) DEFAULT NULL COMMENT 'NULL = all grades in this curriculum',
  `component_code` varchar(30) NOT NULL COMMENT 'WW, PT, QE',
  `component_name` varchar(100) NOT NULL,
  `weight_percent` decimal(5,2) NOT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Grading component weights per curriculum (WW, PT, QE)';

--
-- Dumping data for table `curriculum_grading_components`
--

INSERT INTO `curriculum_grading_components` (`component_id`, `curriculum_id`, `grade_level_id`, `component_code`, `component_name`, `weight_percent`, `sort_order`, `is_deleted`, `deleted_at`) VALUES
(1, 1, 1, 'WW', 'Written Works', 40.00, 1, 0, NULL),
(2, 1, 1, 'PT', 'Performance Tasks', 40.00, 2, 0, NULL),
(3, 1, 1, 'QE', 'Quarterly Assessment', 20.00, 3, 0, NULL),
(4, 1, 2, 'WW', 'Written Works', 40.00, 1, 0, NULL),
(5, 1, 2, 'PT', 'Performance Tasks', 40.00, 2, 0, NULL),
(6, 1, 2, 'QE', 'Quarterly Assessment', 20.00, 3, 0, NULL),
(7, 1, 3, 'WW', 'Written Works', 40.00, 1, 0, NULL),
(8, 1, 3, 'PT', 'Performance Tasks', 40.00, 2, 0, NULL),
(9, 1, 3, 'QE', 'Quarterly Assessment', 20.00, 3, 0, NULL),
(10, 1, 4, 'WW', 'Written Works', 40.00, 1, 0, NULL),
(11, 1, 4, 'PT', 'Performance Tasks', 40.00, 2, 0, NULL),
(12, 1, 4, 'QE', 'Quarterly Assessment', 20.00, 3, 0, NULL),
(13, 1, 5, 'WW', 'Written Works', 40.00, 1, 0, NULL),
(14, 1, 5, 'PT', 'Performance Tasks', 40.00, 2, 0, NULL),
(15, 1, 5, 'QE', 'Quarterly Assessment', 20.00, 3, 0, NULL),
(16, 1, 6, 'WW', 'Written Works', 40.00, 1, 0, NULL),
(17, 1, 6, 'PT', 'Performance Tasks', 40.00, 2, 0, NULL),
(18, 1, 6, 'QE', 'Quarterly Assessment', 20.00, 3, 0, NULL),
(19, 1, 7, 'WW', 'Written Works', 25.00, 1, 0, NULL),
(20, 1, 7, 'PT', 'Performance Tasks', 50.00, 2, 0, NULL),
(21, 1, 7, 'QE', 'Quarterly Assessment', 25.00, 3, 0, NULL),
(22, 1, 8, 'WW', 'Written Works', 25.00, 1, 0, NULL),
(23, 1, 8, 'PT', 'Performance Tasks', 50.00, 2, 0, NULL),
(24, 1, 8, 'QE', 'Quarterly Assessment', 25.00, 3, 0, NULL),
(25, 1, 9, 'WW', 'Written Works', 25.00, 1, 0, NULL),
(26, 1, 9, 'PT', 'Performance Tasks', 50.00, 2, 0, NULL),
(27, 1, 9, 'QE', 'Quarterly Assessment', 25.00, 3, 0, NULL),
(28, 1, 10, 'WW', 'Written Works', 25.00, 1, 0, NULL),
(29, 1, 10, 'PT', 'Performance Tasks', 50.00, 2, 0, NULL),
(30, 1, 10, 'QE', 'Quarterly Assessment', 25.00, 3, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `curriculum_passing_marks`
--

CREATE TABLE `curriculum_passing_marks` (
  `passing_mark_id` int(11) NOT NULL,
  `curriculum_id` int(11) NOT NULL,
  `grade_level_id` int(11) DEFAULT NULL COMMENT 'NULL = all grade levels',
  `subject_id` int(11) DEFAULT NULL COMMENT 'NULL = all subjects',
  `passing_mark` decimal(5,2) NOT NULL DEFAULT 60.00,
  `notes` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Passing marks per curriculum, optionally per grade level or subject';

--
-- Dumping data for table `curriculum_passing_marks`
--

INSERT INTO `curriculum_passing_marks` (`passing_mark_id`, `curriculum_id`, `grade_level_id`, `subject_id`, `passing_mark`, `notes`, `is_deleted`, `deleted_at`) VALUES
(1, 1, NULL, NULL, 75.00, NULL, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `curriculum_school_year_map`
--

CREATE TABLE `curriculum_school_year_map` (
  `map_id` int(11) NOT NULL,
  `curriculum_id` int(11) NOT NULL,
  `school_year_id` int(11) NOT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT 1 COMMENT '1 = default curriculum for this SY',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Maps which curriculum is in effect for each school year';

--
-- Dumping data for table `curriculum_school_year_map`
--

INSERT INTO `curriculum_school_year_map` (`map_id`, `curriculum_id`, `school_year_id`, `is_primary`, `is_deleted`, `deleted_at`) VALUES
(1, 1, 5, 1, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `curriculum_subjects`
--

CREATE TABLE `curriculum_subjects` (
  `curriculum_subject_id` int(11) NOT NULL,
  `curriculum_id` int(11) NOT NULL,
  `grade_level_id` int(11) NOT NULL,
  `subject_id` int(11) NOT NULL,
  `is_required` tinyint(1) NOT NULL DEFAULT 1 COMMENT '0 = elective',
  `weekly_minutes` int(11) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Subject-grade level assignments per curriculum edition';

--
-- Dumping data for table `curriculum_subjects`
--

INSERT INTO `curriculum_subjects` (`curriculum_subject_id`, `curriculum_id`, `grade_level_id`, `subject_id`, `is_required`, `weekly_minutes`, `sort_order`, `notes`, `is_deleted`, `deleted_at`) VALUES
(1, 1, 1, 1, 1, NULL, 1, NULL, 0, NULL),
(2, 1, 1, 2, 1, NULL, 2, NULL, 0, NULL),
(3, 1, 1, 3, 1, NULL, 3, NULL, 0, NULL),
(4, 1, 1, 4, 1, NULL, 4, NULL, 0, NULL),
(5, 1, 1, 5, 1, NULL, 5, NULL, 0, NULL),
(6, 1, 1, 6, 1, NULL, 6, NULL, 0, NULL),
(7, 1, 1, 7, 1, NULL, 7, NULL, 0, NULL),
(8, 1, 1, 8, 1, NULL, 8, NULL, 0, NULL),
(9, 1, 1, 9, 1, NULL, 9, NULL, 0, NULL),
(10, 1, 2, 1, 1, NULL, 1, NULL, 0, NULL),
(11, 1, 2, 2, 1, NULL, 2, NULL, 0, NULL),
(12, 1, 2, 3, 1, NULL, 3, NULL, 0, NULL),
(13, 1, 2, 4, 1, NULL, 4, NULL, 0, NULL),
(14, 1, 2, 5, 1, NULL, 5, NULL, 0, NULL),
(15, 1, 2, 6, 1, NULL, 6, NULL, 0, NULL),
(16, 1, 2, 7, 1, NULL, 7, NULL, 0, NULL),
(17, 1, 2, 8, 1, NULL, 8, NULL, 0, NULL),
(18, 1, 2, 9, 1, NULL, 9, NULL, 0, NULL),
(19, 1, 3, 1, 1, NULL, 1, NULL, 0, NULL),
(20, 1, 3, 2, 1, NULL, 2, NULL, 0, NULL),
(21, 1, 3, 3, 1, NULL, 3, NULL, 0, NULL),
(22, 1, 3, 4, 1, NULL, 4, NULL, 0, NULL),
(23, 1, 3, 5, 1, NULL, 5, NULL, 0, NULL),
(24, 1, 3, 6, 1, NULL, 6, NULL, 0, NULL),
(25, 1, 3, 7, 1, NULL, 7, NULL, 0, NULL),
(26, 1, 3, 8, 1, NULL, 8, NULL, 0, NULL),
(27, 1, 3, 9, 1, NULL, 9, NULL, 0, NULL),
(28, 1, 3, 10, 1, NULL, 10, NULL, 0, NULL),
(29, 1, 4, 2, 1, NULL, 1, NULL, 0, NULL),
(30, 1, 4, 3, 1, NULL, 2, NULL, 0, NULL),
(31, 1, 4, 4, 1, NULL, 3, NULL, 0, NULL),
(32, 1, 4, 5, 1, NULL, 4, NULL, 0, NULL),
(33, 1, 4, 6, 1, NULL, 5, NULL, 0, NULL),
(34, 1, 4, 7, 1, NULL, 6, NULL, 0, NULL),
(35, 1, 4, 8, 1, NULL, 7, NULL, 0, NULL),
(36, 1, 4, 9, 1, NULL, 8, NULL, 0, NULL),
(37, 1, 4, 10, 1, NULL, 9, NULL, 0, NULL),
(38, 1, 4, 11, 1, NULL, 10, NULL, 0, NULL),
(39, 1, 5, 2, 1, NULL, 1, NULL, 0, NULL),
(40, 1, 5, 3, 1, NULL, 2, NULL, 0, NULL),
(41, 1, 5, 4, 1, NULL, 3, NULL, 0, NULL),
(42, 1, 5, 5, 1, NULL, 4, NULL, 0, NULL),
(43, 1, 5, 6, 1, NULL, 5, NULL, 0, NULL),
(44, 1, 5, 7, 1, NULL, 6, NULL, 0, NULL),
(45, 1, 5, 8, 1, NULL, 7, NULL, 0, NULL),
(46, 1, 5, 9, 1, NULL, 8, NULL, 0, NULL),
(47, 1, 5, 10, 1, NULL, 9, NULL, 0, NULL),
(48, 1, 5, 11, 1, NULL, 10, NULL, 0, NULL),
(49, 1, 6, 2, 1, NULL, 1, NULL, 0, NULL),
(50, 1, 6, 3, 1, NULL, 2, NULL, 0, NULL),
(51, 1, 6, 4, 1, NULL, 3, NULL, 0, NULL),
(52, 1, 6, 5, 1, NULL, 4, NULL, 0, NULL),
(53, 1, 6, 6, 1, NULL, 5, NULL, 0, NULL),
(54, 1, 6, 7, 1, NULL, 6, NULL, 0, NULL),
(55, 1, 6, 8, 1, NULL, 7, NULL, 0, NULL),
(56, 1, 6, 9, 1, NULL, 8, NULL, 0, NULL),
(57, 1, 6, 10, 1, NULL, 9, NULL, 0, NULL),
(58, 1, 6, 11, 1, NULL, 10, NULL, 0, NULL),
(59, 1, 7, 2, 1, NULL, 1, NULL, 0, NULL),
(60, 1, 7, 3, 1, NULL, 2, NULL, 0, NULL),
(61, 1, 7, 4, 1, NULL, 3, NULL, 0, NULL),
(62, 1, 7, 5, 1, NULL, 4, NULL, 0, NULL),
(63, 1, 7, 6, 1, NULL, 5, NULL, 0, NULL),
(64, 1, 7, 7, 1, NULL, 6, NULL, 0, NULL),
(65, 1, 7, 10, 1, NULL, 7, NULL, 0, NULL),
(66, 1, 7, 12, 1, NULL, 8, NULL, 0, NULL),
(67, 1, 8, 2, 1, NULL, 1, NULL, 0, NULL),
(68, 1, 8, 3, 1, NULL, 2, NULL, 0, NULL),
(69, 1, 8, 4, 1, NULL, 3, NULL, 0, NULL),
(70, 1, 8, 5, 1, NULL, 4, NULL, 0, NULL),
(71, 1, 8, 6, 1, NULL, 5, NULL, 0, NULL),
(72, 1, 8, 7, 1, NULL, 6, NULL, 0, NULL),
(73, 1, 8, 10, 1, NULL, 7, NULL, 0, NULL),
(74, 1, 8, 12, 1, NULL, 8, NULL, 0, NULL),
(75, 1, 9, 2, 1, NULL, 1, NULL, 0, NULL),
(76, 1, 9, 3, 1, NULL, 2, NULL, 0, NULL),
(77, 1, 9, 4, 1, NULL, 3, NULL, 0, NULL),
(78, 1, 9, 5, 1, NULL, 4, NULL, 0, NULL),
(79, 1, 9, 6, 1, NULL, 5, NULL, 0, NULL),
(80, 1, 9, 7, 1, NULL, 6, NULL, 0, NULL),
(81, 1, 9, 10, 1, NULL, 7, NULL, 0, NULL),
(82, 1, 9, 12, 1, NULL, 8, NULL, 0, NULL),
(83, 1, 10, 2, 1, NULL, 1, NULL, 0, NULL),
(84, 1, 10, 3, 1, NULL, 2, NULL, 0, NULL),
(85, 1, 10, 4, 1, NULL, 3, NULL, 0, NULL),
(86, 1, 10, 5, 1, NULL, 4, NULL, 0, NULL),
(87, 1, 10, 6, 1, NULL, 5, NULL, 0, NULL),
(88, 1, 10, 7, 1, NULL, 6, NULL, 0, NULL),
(89, 1, 10, 10, 1, NULL, 7, NULL, 0, NULL),
(90, 1, 10, 12, 1, NULL, 8, NULL, 0, NULL);

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
(1, 'PSA Birth Certificate', 'Primary enrollment document', 0, NULL),
(2, 'Form 137 (Permanent Record)', 'Official DepEd permanent academic record', 0, NULL),
(3, 'Form 138 (Report Card)', 'Official DepEd report card', 0, NULL),
(4, 'Certificate of Completion', 'Issued to Grade 6 and Grade 10 completers', 0, NULL),
(5, 'Good Moral Certificate', 'Character reference from previous school', 0, NULL),
(6, 'Diploma', 'Issued to Grade 6 and Grade 12 graduates', 0, NULL),
(7, 'Barangay Certification', 'Acceptable substitute for PSA Birth Certificate', 0, NULL),
(8, 'LCR Birth Certificate', 'Local Civil Registrar-issued birth certificate', 0, NULL);

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
  `relationship` varchar(50) NOT NULL,
  `contact_number` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Emergency contacts per learner';

--
-- Dumping data for table `emergency_contacts`
--

INSERT INTO `emergency_contacts` (`emergency_contact_id`, `learner_id`, `contact_name`, `relationship`, `contact_number`, `address`, `is_deleted`, `deleted_at`) VALUES
(3, 3, 'Updated Emergency', 'Father', '09111222333', NULL, 0, NULL),
(9, 4, 'dfgbfgbfgb', 'Father', '345345345', 'dfdfbdfb', 0, NULL),
(11, 6, 'Guko B. Gohan', 'Father', '091231289329', 'Carmen Cdo', 1, '2026-03-20 23:09:22'),
(13, 7, 'Gael Gatilogo', 'Father', '0981238348', 'Wao', 1, '2026-03-20 20:54:57'),
(14, 7, 'Gael Gatilogo', 'Emergency Contact', '0981238348', 'Wao', 1, '2026-03-20 20:55:03'),
(15, 7, 'Gael Gatilogo', 'Emergency Contact', '0981238348', 'Wao', 1, '2026-03-20 20:55:32'),
(16, 7, 'Gael Gatilogo', 'Emergency Contact', '0981238348', 'Wao', 1, '2026-03-20 20:55:37'),
(17, 7, 'Gael Gatilogo', 'Emergency Contact', '0981238348', 'Wao', 1, '2026-03-20 22:07:56'),
(18, 7, 'Gas Gas', 'Emergency Contact', '0981238348', 'Wao', 0, NULL),
(19, 6, 'Guko B. Gohan', 'Emergency Contact', '091231289329', 'Carmen Cdo', 1, '2026-03-20 23:09:33'),
(20, 6, 'Guko B. Gohan', 'Emergency Contact', '091231289329', 'Carmen Cdo', 1, '2026-03-20 23:09:38'),
(21, 6, 'Guko B. Gohan', 'Emergency Contact', '091231289329', 'Carmen Cdo', 1, '2026-03-20 23:09:41'),
(22, 6, 'Guko B. Gohan', 'Emergency Contact', '091231289329', 'Carmen Cdo', 1, '2026-03-20 23:09:44'),
(23, 6, 'Guko B. Gohan', 'Emergency Contact', '091231289329', 'Carmen Cdo', 1, '2026-03-25 14:50:15'),
(24, 6, 'Guko B. Gohan', 'Emergency Contact', '091231289329', 'Carmen Cdo', 0, NULL);

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
  `name_extension` varchar(10) DEFAULT NULL COMMENT 'Jr., Sr., II, III …',
  `date_of_birth` date DEFAULT NULL,
  `gender` enum('Male','Female','Other') DEFAULT NULL,
  `contact_number` varchar(20) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `position_id` int(11) DEFAULT NULL,
  `date_hired` date DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Employee (teacher/staff) profiles linked to a user account';

--
-- Dumping data for table `employees`
--

INSERT INTO `employees` (`employee_id`, `user_id`, `employee_number`, `first_name`, `middle_name`, `last_name`, `name_extension`, `date_of_birth`, `gender`, `contact_number`, `email`, `address`, `position_id`, `date_hired`, `is_deleted`, `deleted_at`) VALUES
(1, 1, '123', 'Carlo', NULL, 'Yulo', NULL, NULL, NULL, '09361470082', NULL, NULL, NULL, NULL, 0, NULL),
(26, 26, '911', 'Shaunu', 'T.', 'Belono-ac', 'test', '2026-02-21', 'Male', 'test', 'belonoacshaun1@gmail.com', 'test', 9, '2026-02-21', 0, NULL),
(27, 27, '12-12-12', 'jane', 'j', 'tejo', NULL, '2026-02-21', 'Female', '09723484584', 'jane@gmail.com', 'test', 4, '2026-02-21', 0, NULL),
(28, 29, '28-28-28', 'Neilban', 'Colinares', 'Ong', NULL, '2026-01-28', 'Other', '0914314390', 'nico.Ong.coc@phinmaed.com', NULL, 4, '2026-02-23', 0, NULL);

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
  `curriculum_id` int(11) DEFAULT NULL COMMENT 'FK to curricula — which curriculum this enrollment follows',
  `enrollment_type_id` int(11) DEFAULT NULL,
  `enrollment_date` date DEFAULT NULL,
  `enrollment_status` enum('Enrolled','Dropped','Transferred Out','Completed') NOT NULL DEFAULT 'Enrolled',
  `status_updated_at` datetime DEFAULT current_timestamp(),
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Learner enrollment records per school year';

--
-- Dumping data for table `enrollments`
--

INSERT INTO `enrollments` (`enrollment_id`, `learner_id`, `school_year_id`, `grade_level_id`, `section_id`, `curriculum_id`, `enrollment_type_id`, `enrollment_date`, `enrollment_status`, `status_updated_at`, `is_deleted`, `deleted_at`) VALUES
(5, 5, 5, 10, 4, NULL, 1, '2026-02-21', 'Enrolled', '2026-03-20 10:09:36', 0, NULL),
(6, 4, 5, 1, 3, NULL, 1, '2026-02-20', 'Enrolled', '2026-03-20 10:09:36', 0, NULL),
(8, 6, 5, 1, 2, 1, 2, '2026-02-21', 'Enrolled', '2026-03-20 10:09:36', 0, NULL),
(9, 7, 5, 1, 3, NULL, 1, '2026-02-11', 'Enrolled', '2026-03-20 10:09:36', 0, NULL),
(10, 8, 5, 1, 3, 1, 1, '2026-03-21', 'Enrolled', '2026-03-21 16:24:34', 0, NULL),
(11, 9, 5, 10, 4, 1, 1, '2026-03-24', 'Enrolled', '2026-03-24 16:26:30', 0, NULL);

--
-- Triggers `enrollments`
--
DELIMITER $$
CREATE TRIGGER `trg_enrollments_bi_capacity_consistency` BEFORE INSERT ON `enrollments` FOR EACH ROW BEGIN
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
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_enrollments_bu_capacity_consistency` BEFORE UPDATE ON `enrollments` FOR EACH ROW BEGIN
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
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `enrollment_requirements`
--

CREATE TABLE `enrollment_requirements` (
  `requirement_id` int(11) NOT NULL,
  `school_year_id` int(11) NOT NULL,
  `grade_level_id` int(11) DEFAULT NULL COMMENT 'NULL = all grade levels',
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Enrollment type — New, Returning, Transfer-In, Balik-Aral';

--
-- Dumping data for table `enrollment_types`
--

INSERT INTO `enrollment_types` (`enrollment_type_id`, `type_name`, `description`, `is_deleted`, `deleted_at`) VALUES
(1, 'New Enrollee', 'Learner enrolling in a DepEd school for the first time', 0, NULL),
(2, 'Returning', 'Learner previously enrolled, re-enrolling for a new school year', 0, NULL),
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
  `relationship` varchar(50) NOT NULL COMMENT 'Father, Mother, Legal Guardian …',
  `date_of_birth` date DEFAULT NULL,
  `occupation` varchar(150) DEFAULT NULL,
  `contact_number` varchar(20) DEFAULT NULL,
  `monthly_income` decimal(12,2) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Family background per learner';

--
-- Dumping data for table `family_members`
--

INSERT INTO `family_members` (`family_member_id`, `learner_id`, `full_name`, `relationship`, `date_of_birth`, `occupation`, `contact_number`, `monthly_income`, `is_deleted`, `deleted_at`) VALUES
(23, 4, 'sdfsdfs', 'Father', NULL, 'dfsdfsd', '2342343534', NULL, 0, NULL),
(24, 4, 'efgdfgdfgh', 'Mother', NULL, 'hfhfghfghgfh', '34546456456', NULL, 0, NULL),
(25, 4, 'sgdfgdfgd', 'Step-Father', NULL, 'fdfbdfbdfb', NULL, NULL, 0, NULL),
(26, 4, 'sfdfbdfb', 'Legal Guardian', NULL, NULL, 'bfgbfgbfgb', NULL, 0, NULL),
(29, 6, 'Guko B. Gohan', 'Father', NULL, 'Hired Killer', '091231289329', NULL, 1, '2026-03-20 23:09:22'),
(30, 6, 'Darna X. Batallion', 'Mother', NULL, 'Bad Ass Killer', '091872318273', NULL, 1, '2026-03-20 23:09:22'),
(34, 7, 'Montalba, Wilfredo', 'Father', NULL, 'Teaching', '09873248234', NULL, 1, '2026-03-20 20:54:57'),
(35, 7, 'Gladys H. Montalba', 'Mother', NULL, 'Prostitute', '09723476237', NULL, 1, '2026-03-20 20:54:57'),
(36, 7, 'Alwin Magallanes', 'Step-Father', NULL, NULL, NULL, NULL, 1, '2026-03-20 20:54:57'),
(37, 7, 'Montalba, Wilfredo', 'Father', NULL, 'Teaching', '09873248234', NULL, 1, '2026-03-20 20:55:03'),
(38, 7, 'Gladys H. Montalba', 'Mother', NULL, 'Prostitute', '09723476237', NULL, 1, '2026-03-20 20:55:03'),
(39, 7, 'Montalba, Wilfredo', 'Father', NULL, 'Teaching', '09873248234', NULL, 1, '2026-03-20 20:55:32'),
(40, 7, 'Gladys H. Montalba', 'Mother', NULL, 'Prostitute', '09723476237', NULL, 1, '2026-03-20 20:55:32'),
(41, 7, 'Montalba, Wilfredo', 'Father', NULL, 'Teaching', '09873248234', NULL, 1, '2026-03-20 20:55:37'),
(42, 7, 'Gladys H. Montalba', 'Mother', NULL, 'Prostitute', '09723476237', NULL, 1, '2026-03-20 20:55:37'),
(43, 7, 'Montalba, Wilfredo', 'Father', NULL, 'Teaching', '09873248234', NULL, 1, '2026-03-20 22:07:56'),
(44, 7, 'Gladys H. Montalba', 'Mother', NULL, 'Prostitute', '09723476237', NULL, 1, '2026-03-20 22:07:56'),
(45, 7, 'Montalba, Wilfredo', 'Father', NULL, 'Teaching', '09873248234', NULL, 0, NULL),
(46, 7, 'Gladys H. Montalba', 'Mother', NULL, 'Prostitute', '09723476237', NULL, 0, NULL),
(47, 6, 'Guko B. Gohan', 'Father', NULL, 'Hired Killer', '091231289329', NULL, 1, '2026-03-20 23:09:33'),
(48, 6, 'Darna X. Batallion', 'Mother', NULL, 'Bad Ass Killer', '091872318273', NULL, 1, '2026-03-20 23:09:33'),
(49, 6, 'Guko B. Gohan', 'Father', NULL, 'Hired Killer', '091231289329', NULL, 1, '2026-03-20 23:09:38'),
(50, 6, 'Darna X. Batallion', 'Mother', NULL, 'Bad Ass Killer', '091872318273', NULL, 1, '2026-03-20 23:09:38'),
(51, 6, 'Guko B. Gohan', 'Father', NULL, 'Hired Killer', '091231289329', NULL, 1, '2026-03-20 23:09:41'),
(52, 6, 'Darna X. Batallion', 'Mother', NULL, 'Bad Ass Killer', '091872318273', NULL, 1, '2026-03-20 23:09:41'),
(53, 6, 'Guko B. Gohan', 'Father', NULL, 'Hired Killer', '091231289329', NULL, 1, '2026-03-20 23:09:44'),
(54, 6, 'Darna X. Batallion', 'Mother', NULL, 'Bad Ass Killer', '091872318273', NULL, 1, '2026-03-20 23:09:44'),
(55, 6, 'Guko B. Gohan', 'Father', NULL, 'Hired Killer', '091231289329', NULL, 1, '2026-03-25 14:50:15'),
(56, 6, 'Darna X. Batallion', 'Mother', NULL, 'Bad Ass Killer', '091872318273', NULL, 1, '2026-03-25 14:50:15'),
(57, 8, 'test father', 'Father', NULL, 'farmer', '09129381293812', NULL, 0, NULL),
(58, 8, 'test mother', 'Mother', NULL, 'farmer', '010293102340932', NULL, 0, NULL),
(59, 6, 'Guko B. Gohan', 'Father', NULL, 'Hired Killer', '091231289329', NULL, 0, NULL),
(60, 6, 'Darna X. Batallion', 'Mother', NULL, 'Bad Ass Killer', '091872318273', NULL, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `final_grades`
--

CREATE TABLE `final_grades` (
  `final_grade_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `class_id` int(11) NOT NULL,
  `final_grade` decimal(5,2) DEFAULT NULL,
  `remark` enum('Passed','Failed') NOT NULL DEFAULT 'Failed',
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
-- Table structure for table `geo_barangays`
--

CREATE TABLE `geo_barangays` (
  `barangay_id` int(11) NOT NULL,
  `city_municipality_id` int(11) NOT NULL,
  `psgc_code` varchar(20) DEFAULT NULL,
  `barangay_name` varchar(150) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `geo_barangays`
--

INSERT INTO `geo_barangays` (`barangay_id`, `city_municipality_id`, `psgc_code`, `barangay_name`, `is_active`, `created_at`) VALUES
(1, 1, '1004309001', 'Burnay', 1, '2026-02-21 05:18:41'),
(2, 1, '1004309002', 'Carlos P. Garcia', 1, '2026-02-21 05:18:41'),
(3, 1, '1004309004', 'Cogon', 1, '2026-02-21 05:18:41'),
(4, 1, '1004309005', 'Gregorio Pelaez (Lagutay)', 1, '2026-02-21 05:18:41'),
(5, 1, '1004309006', 'Kilangit', 1, '2026-02-21 05:18:41'),
(6, 1, '1004309007', 'Matangad', 1, '2026-02-21 05:18:41'),
(7, 1, '1004309008', 'Pangayawan', 1, '2026-02-21 05:18:41'),
(8, 1, '1004309009', 'Poblacion', 1, '2026-02-21 05:18:41'),
(9, 1, '1004309010', 'Quezon', 1, '2026-02-21 05:18:41'),
(10, 1, '1004309011', 'Tala-o', 1, '2026-02-21 05:18:41'),
(11, 1, '1004309012', 'Ulab', 1, '2026-02-21 05:18:41');

-- --------------------------------------------------------

--
-- Table structure for table `geo_cities_municipalities`
--

CREATE TABLE `geo_cities_municipalities` (
  `city_municipality_id` int(11) NOT NULL,
  `province_id` int(11) NOT NULL,
  `psgc_code` varchar(20) DEFAULT NULL,
  `city_municipality_name` varchar(150) NOT NULL,
  `is_city` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `geo_cities_municipalities`
--

INSERT INTO `geo_cities_municipalities` (`city_municipality_id`, `province_id`, `psgc_code`, `city_municipality_name`, `is_city`, `is_active`, `created_at`) VALUES
(1, 1, '100430', 'Gitagum', 0, 1, '2026-02-21 05:18:41');

-- --------------------------------------------------------

--
-- Table structure for table `geo_provinces`
--

CREATE TABLE `geo_provinces` (
  `province_id` int(11) NOT NULL,
  `psgc_code` varchar(20) DEFAULT NULL,
  `province_name` varchar(150) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `geo_provinces`
--

INSERT INTO `geo_provinces` (`province_id`, `psgc_code`, `province_name`, `is_active`, `created_at`) VALUES
(1, '1004', 'Misamis Oriental', 1, '2026-02-21 05:18:41');

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

--
-- Dumping data for table `grades`
--

INSERT INTO `grades` (`grade_id`, `enrollment_id`, `class_id`, `grading_period_id`, `written_works`, `performance_tasks`, `quarterly_exam`, `quarterly_grade`, `encoded_by`, `encoded_at`, `updated_at`, `is_deleted`, `deleted_at`) VALUES
(1, 5, 43, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 15:58:30', '2026-03-24 15:59:25', 0, NULL),
(4, 11, 43, 6, 100.00, 100.00, 95.00, 98.75, 1, '2026-03-24 16:27:30', '2026-03-24 16:27:30', 0, NULL),
(6, 11, 35, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:28:17', '2026-03-24 16:28:17', 0, NULL),
(7, 5, 35, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:28:17', '2026-03-24 16:28:17', 0, NULL),
(8, 11, 44, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:28:29', '2026-03-24 16:28:29', 0, NULL),
(9, 5, 44, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:28:29', '2026-03-24 16:28:29', 0, NULL),
(10, 11, 36, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:28:41', '2026-03-24 16:28:41', 0, NULL),
(11, 5, 36, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:28:41', '2026-03-24 16:28:41', 0, NULL),
(12, 11, 47, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:28:52', '2026-03-24 16:28:52', 0, NULL),
(13, 5, 47, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:28:52', '2026-03-24 16:28:52', 0, NULL),
(14, 11, 38, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:29:06', '2026-03-24 16:29:06', 0, NULL),
(15, 5, 38, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:29:06', '2026-03-24 16:29:06', 0, NULL),
(16, 11, 37, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:29:17', '2026-03-24 16:29:17', 0, NULL),
(17, 5, 37, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:29:17', '2026-03-24 16:29:17', 0, NULL),
(18, 11, 40, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:29:38', '2026-03-24 16:29:38', 0, NULL),
(19, 5, 40, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:29:38', '2026-03-24 16:29:38', 0, NULL),
(20, 11, 33, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:29:55', '2026-03-24 16:29:55', 0, NULL),
(21, 5, 33, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:29:55', '2026-03-24 16:29:55', 0, NULL),
(22, 11, 41, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:30:46', '2026-03-24 16:30:46', 0, NULL),
(23, 5, 41, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:30:46', '2026-03-24 16:30:46', 0, NULL),
(24, 11, 32, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:31:00', '2026-03-24 16:31:00', 0, NULL),
(25, 5, 32, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:31:00', '2026-03-24 16:31:00', 0, NULL),
(26, 11, 34, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:31:19', '2026-03-24 16:31:19', 0, NULL),
(27, 5, 34, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:31:19', '2026-03-24 16:31:19', 0, NULL),
(28, 11, 42, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:31:33', '2026-03-24 16:31:33', 0, NULL),
(29, 5, 42, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:31:33', '2026-03-24 16:31:33', 0, NULL),
(30, 11, 45, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:32:02', '2026-03-24 16:32:02', 0, NULL),
(31, 5, 45, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:32:02', '2026-03-24 16:32:02', 0, NULL),
(32, 11, 46, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:32:15', '2026-03-24 16:32:15', 0, NULL),
(33, 5, 46, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:32:15', '2026-03-24 16:32:15', 0, NULL),
(34, 11, 39, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:32:32', '2026-03-24 16:32:32', 0, NULL),
(35, 5, 39, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:32:32', '2026-03-24 16:32:32', 0, NULL),
(36, 8, 14, 6, 100.00, 90.00, 90.00, 94.00, 1, '2026-03-25 04:19:00', '2026-03-25 04:19:00', 0, NULL),
(37, 8, 15, 6, 90.00, 90.00, 100.00, 92.00, 1, '2026-03-25 04:24:14', '2026-03-25 04:24:14', 0, NULL);

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Grade levels — Grade 1 through Grade 10';

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
-- Table structure for table `grade_level_progression`
--

CREATE TABLE `grade_level_progression` (
  `grade_level_id` int(11) NOT NULL,
  `next_grade_level_id` int(11) DEFAULT NULL,
  `is_terminal` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='DepEd grade flow mapping used for promotion and re-enrollment';

--
-- Dumping data for table `grade_level_progression`
--

INSERT INTO `grade_level_progression` (`grade_level_id`, `next_grade_level_id`, `is_terminal`, `created_at`, `updated_at`) VALUES
(1, 2, 0, '2026-03-25 20:40:46', '2026-03-25 20:51:50'),
(2, 3, 0, '2026-03-25 20:40:46', '2026-03-25 20:51:50'),
(3, 4, 0, '2026-03-25 20:40:46', '2026-03-25 20:51:50'),
(4, 5, 0, '2026-03-25 20:40:46', '2026-03-25 20:51:50'),
(5, 6, 0, '2026-03-25 20:40:46', '2026-03-25 20:51:50'),
(6, 7, 0, '2026-03-25 20:40:46', '2026-03-25 20:51:50'),
(7, 8, 0, '2026-03-25 20:40:46', '2026-03-25 20:51:50'),
(8, 9, 0, '2026-03-25 20:40:46', '2026-03-25 20:51:50'),
(9, 10, 0, '2026-03-25 20:40:46', '2026-03-25 20:51:50'),
(10, NULL, 1, '2026-03-25 20:40:46', '2026-03-25 20:51:50');

-- --------------------------------------------------------

--
-- Table structure for table `grading_periods`
--

CREATE TABLE `grading_periods` (
  `grading_period_id` int(11) NOT NULL,
  `school_year_id` int(11) NOT NULL,
  `period_name` varchar(50) NOT NULL COMMENT 'e.g. 1st Quarter',
  `status` enum('Open','Submitted','Approved','Locked') NOT NULL DEFAULT 'Open',
  `date_start` date DEFAULT NULL,
  `date_end` date DEFAULT NULL,
  `locked_by` int(11) DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Quarterly grading periods per school year with lock workflow';

--
-- Dumping data for table `grading_periods`
--

INSERT INTO `grading_periods` (`grading_period_id`, `school_year_id`, `period_name`, `status`, `date_start`, `date_end`, `locked_by`, `locked_at`, `is_deleted`, `deleted_at`) VALUES
(5, 2, 'P1', 'Open', '2026-02-20', '2026-04-10', NULL, NULL, 0, NULL),
(6, 5, 'FIRST GRADING', 'Open', '2026-02-21', '2026-02-28', NULL, NULL, 0, NULL);

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
(1, 'With Highest Honors', 98.00, 100.00, 'GA of 98–100 (DO 36, s. 2016)', 0, NULL),
(2, 'With High Honors', 95.00, 97.99, 'GA of 95–97 (DO 36, s. 2016)', 0, NULL),
(3, 'With Honors', 90.00, 94.99, 'GA of 90–94 (DO 36, s. 2016)', 0, NULL);

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
  `status` enum('Pending','Ongoing','Resolved','Escalated') NOT NULL DEFAULT 'Pending',
  `notes` text DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Intervention records for at-risk learners';

--
-- Dumping data for table `interventions`
--

INSERT INTO `interventions` (`intervention_id`, `enrollment_id`, `risk_assessment_id`, `intervention_type`, `description`, `conducted_by`, `conducted_at`, `follow_up_date`, `status`, `notes`, `is_deleted`, `deleted_at`) VALUES
(2, 6, 2, 'Parent Conference', 's', 27, NULL, '2026-02-21', 'Ongoing', 's', 0, NULL);

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
  `name_extension` varchar(10) DEFAULT NULL COMMENT 'Jr., Sr., II, III …',
  `date_of_birth` date DEFAULT NULL,
  `gender` enum('Male','Female','Other') DEFAULT NULL,
  `civil_status` enum('Single','Married','Widowed','Legally Separated','Annulled') DEFAULT NULL,
  `religion` varchar(100) DEFAULT NULL,
  `mother_tongue` varchar(100) DEFAULT NULL,
  `indigenous_group` varchar(150) DEFAULT NULL COMMENT 'NULL if not indigenous',
  `citizenship` varchar(100) DEFAULT 'Filipino',
  `learner_status` enum('Enrolled','Temporarily Enrolled','Promoted','Conditionally Promoted','Retained','Transferred Out','Dropped','Graduated') DEFAULT NULL,
  `is_4ps_beneficiary` tinyint(1) DEFAULT 0,
  `is_indigenous` tinyint(1) DEFAULT 0,
  `completed` tinyint(1) DEFAULT 0,
  `is_permanent_same_as_current` tinyint(1) NOT NULL DEFAULT 1,
  `address` text DEFAULT NULL COMMENT 'Free-text current address for quick display',
  `contact_number` varchar(20) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Learner (student) master profiles';

--
-- Dumping data for table `learners`
--

INSERT INTO `learners` (`learner_id`, `user_id`, `lrn`, `first_name`, `middle_name`, `last_name`, `name_extension`, `date_of_birth`, `gender`, `civil_status`, `religion`, `mother_tongue`, `indigenous_group`, `citizenship`, `learner_status`, `is_4ps_beneficiary`, `is_indigenous`, `completed`, `is_permanent_same_as_current`, `address`, `contact_number`, `email`, `is_deleted`, `deleted_at`) VALUES
(4, NULL, '123123123123', 'Cloudenry', 'Blaan', 'Medina', NULL, '2026-02-20', 'Male', 'Legally Separated', 'Aglipayan (Philippine Independent Church)', 'Bikol', 'Ata (Davao del Norte)', 'Filipino', NULL, 1, 1, 0, 1, NULL, NULL, NULL, 0, NULL),
(5, NULL, '123090909090', 'Bhala', 'T', 'Bords', NULL, '2026-02-21', 'Male', 'Single', 'Waray', 'Cebuano', 'Ata (Davao del Norte)', 'Filipino', NULL, 1, 1, 1, 1, NULL, NULL, NULL, 0, NULL),
(6, NULL, '121208080880', 'Pitok Batolata', 'Luz', 'Kulas', NULL, '2026-02-18', 'Male', NULL, NULL, NULL, NULL, 'Filipino', NULL, 0, 0, 0, 1, NULL, NULL, NULL, 0, NULL),
(7, NULL, '128000000920', 'Marya', 'Pato', 'Hagorn', NULL, '2026-03-29', 'Female', NULL, NULL, NULL, NULL, 'Filipino', NULL, 1, 0, 0, 1, NULL, NULL, NULL, 0, NULL),
(8, NULL, '212012091029', 'test name', 'test', 'hello', 'Sr.', '2026-03-24', 'Male', 'Single', 'Aglipayan (Philippine Independent Church)', 'Cebuano', NULL, 'Filipino', 'Enrolled', 1, 0, 1, 1, NULL, '09361470082', 'tets@gmail.com', 0, NULL),
(9, NULL, '121212121212', 'Shaun Michael', 'Terceño', 'Belono-ac', NULL, '2026-03-16', 'Male', 'Single', 'Aglipayan (Philippine Independent Church)', 'Cebuano', NULL, 'Filipino', 'Enrolled', 0, 0, 1, 1, 'Kibawe Bukidnon', '091231241', 'acasx@gmail.com', 0, NULL);

--
-- Triggers `learners`
--
DELIMITER $$
CREATE TRIGGER `trg_learners_bi_validate_lrn` BEFORE INSERT ON `learners` FOR EACH ROW BEGIN
  IF NEW.lrn IS NULL OR NEW.lrn NOT REGEXP '^[0-9]{12}$' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'LRN must be exactly 12 digits';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_learners_bu_validate_lrn` BEFORE UPDATE ON `learners` FOR EACH ROW BEGIN
  IF NEW.lrn <> OLD.lrn THEN
    IF NEW.lrn IS NULL OR NEW.lrn NOT REGEXP '^[0-9]{12}$' THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'LRN must be exactly 12 digits';
    END IF;
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `learner_addresses`
--

CREATE TABLE `learner_addresses` (
  `learner_address_id` int(11) NOT NULL,
  `learner_id` int(11) NOT NULL,
  `address_type` enum('CURRENT','PERMANENT') NOT NULL,
  `house_no` varchar(50) DEFAULT NULL,
  `street_name` varchar(150) DEFAULT NULL,
  `subdivision` varchar(150) DEFAULT NULL,
  `zip_code` varchar(10) DEFAULT NULL,
  `province_id` int(11) DEFAULT NULL,
  `city_municipality_id` int(11) DEFAULT NULL,
  `barangay_id` int(11) DEFAULT NULL,
  `country_name` varchar(100) NOT NULL DEFAULT 'Philippines',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `learner_addresses`
--

INSERT INTO `learner_addresses` (`learner_address_id`, `learner_id`, `address_type`, `house_no`, `street_name`, `subdivision`, `zip_code`, `province_id`, `city_municipality_id`, `barangay_id`, `country_name`, `is_deleted`, `deleted_at`, `created_at`, `updated_at`) VALUES
(2, 5, 'CURRENT', NULL, NULL, NULL, '123123', 1, 1, 1, 'Philippines', 0, NULL, '2026-02-21 05:30:36', NULL),
(10, 7, 'CURRENT', NULL, NULL, NULL, '1209', 1, 1, 7, 'Philippines', 1, '2026-03-20 22:07:56', '2026-03-20 20:55:37', NULL),
(11, 7, 'CURRENT', NULL, NULL, NULL, '1209', 1, 1, 7, 'Philippines', 0, NULL, '2026-03-20 22:07:56', NULL),
(16, 6, 'CURRENT', NULL, NULL, NULL, '20189', 1, 1, 4, 'Philippines', 1, '2026-03-25 14:50:15', '2026-03-20 23:09:44', NULL),
(17, 8, 'CURRENT', '0912', 'test', 'test', '121212', 1, 1, 6, 'Philippines', 0, NULL, '2026-03-21 16:24:34', NULL),
(18, 9, 'CURRENT', '1212', 'test', 'et', '2323', 1, 1, 3, 'Philippines', 0, NULL, '2026-03-24 16:26:30', NULL),
(19, 6, 'CURRENT', NULL, NULL, NULL, '20189', 1, 1, 4, 'Philippines', 0, NULL, '2026-03-25 14:50:15', NULL);

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
  `enrollment_id` int(11) NOT NULL COMMENT 'SY-specific',
  `modality_id` int(11) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Learner preferred distance learning modalities per enrollment — multi-select';

-- --------------------------------------------------------

--
-- Table structure for table `learner_previous_schools`
--

CREATE TABLE `learner_previous_schools` (
  `previous_school_id` int(11) NOT NULL,
  `learner_id` int(11) NOT NULL,
  `enrollment_id` int(11) DEFAULT NULL,
  `last_grade_level_completed` varchar(50) DEFAULT NULL,
  `last_school_year_completed` varchar(20) DEFAULT NULL,
  `last_school_attended` varchar(200) DEFAULT NULL,
  `last_school_id` varchar(20) DEFAULT NULL COMMENT 'DepEd School ID of previous school',
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Previous school records for Balik-Aral and transfer-in learners';

-- --------------------------------------------------------

--
-- Table structure for table `learner_progression`
--

CREATE TABLE `learner_progression` (
  `progression_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `learner_id` int(11) NOT NULL,
  `school_year_id` int(11) NOT NULL,
  `current_grade_level_id` int(11) NOT NULL,
  `general_average` decimal(5,2) DEFAULT NULL,
  `final_status` enum('Promoted','Retained','Completed') NOT NULL,
  `next_grade_level_id` int(11) DEFAULT NULL,
  `remarks` varchar(255) DEFAULT NULL,
  `decided_at` datetime NOT NULL DEFAULT current_timestamp(),
  `is_processed` tinyint(1) NOT NULL DEFAULT 0,
  `processed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Promotion and rollover decision per learner enrollment';

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Distance learning modalities — Modular, Online, TV/Radio, Blended, etc.';

--
-- Dumping data for table `learning_modalities`
--

INSERT INTO `learning_modalities` (`modality_id`, `modality_name`, `description`, `is_deleted`, `deleted_at`) VALUES
(1, 'Face-to-Face', 'Traditional in-person classroom instruction', 0, NULL),
(2, 'Modular Distance Learning (Print)', 'Self-Learning Modules in print', 0, NULL),
(3, 'Modular Distance Learning (Digital)', 'Self-Learning Modules via USB, CD, or digital devices', 0, NULL),
(4, 'Online Distance Learning', 'Synchronous and asynchronous learning via internet platforms', 0, NULL),
(5, 'TV-Based Instruction', 'Learning via DepEd TV broadcasts', 0, NULL),
(6, 'Radio-Based Instruction', 'Learning via radio broadcast; for remote areas', 0, NULL),
(7, 'Blended Learning', 'Combination of two or more modalities', 0, NULL),
(8, 'Home Study Program', 'Formally supervised home learning for learners with special needs', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `notification_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `notification_type` enum('Grade Alert','Risk Flag','Intervention Due','Announcement','Grading Period') NOT NULL,
  `title` varchar(200) NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `read_at` datetime DEFAULT NULL,
  `reference_table` varchar(50) DEFAULT NULL COMMENT 'e.g. risk_assessments, interventions',
  `reference_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='In-app per-user notifications — grade alerts, risk flags, intervention follow-ups';

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`notification_id`, `user_id`, `notification_type`, `title`, `message`, `is_read`, `read_at`, `reference_table`, `reference_id`, `created_at`, `is_deleted`, `deleted_at`) VALUES
(1, 1, 'Risk Flag', 'Dashboard Alert', '2 students identified as at-risk', 1, '2026-03-20 21:55:57', 'dashboard_alerts', NULL, '2026-03-20 21:55:42', 0, NULL),
(2, 1, 'Risk Flag', 'Dashboard Alert', '1 students have low attendance', 1, '2026-03-20 21:55:47', 'dashboard_alerts', NULL, '2026-03-20 21:55:42', 0, NULL),
(3, 1, 'Risk Flag', 'Dashboard Alert', '1 students identified as at-risk', 1, '2026-03-21 15:29:16', 'dashboard_alerts', NULL, '2026-03-20 21:56:07', 0, NULL),
(4, 1, 'Announcement', 'e', 'e', 1, '2026-03-20 21:56:46', 'announcements', 58, '2026-03-20 21:56:43', 0, NULL),
(5, 26, 'Announcement', 'e', 'e', 0, NULL, 'announcements', 58, '2026-03-20 21:56:43', 0, NULL),
(6, 27, 'Announcement', 'e', 'e', 1, '2026-03-24 16:47:20', 'announcements', 58, '2026-03-20 21:56:43', 0, NULL),
(7, 28, 'Announcement', 'e', 'e', 0, NULL, 'announcements', 58, '2026-03-20 21:56:43', 0, NULL),
(8, 29, 'Announcement', 'e', 'e', 0, NULL, 'announcements', 58, '2026-03-20 21:56:43', 0, NULL),
(9, 1, 'Risk Flag', 'Dashboard Alert', '1 students identified as at-risk', 1, '2026-03-21 15:29:16', 'dashboard_alerts', NULL, '2026-03-21 12:28:54', 0, NULL),
(10, 1, 'Risk Flag', 'Dashboard Alert', '1 students have low attendance', 1, '2026-03-21 12:37:22', 'dashboard_alerts', NULL, '2026-03-21 12:28:54', 0, NULL),
(11, 27, 'Risk Flag', 'Dashboard Alert', '1 students identified as at-risk', 1, '2026-03-24 16:47:20', 'dashboard_alerts', NULL, '2026-03-21 13:02:34', 0, NULL),
(12, 27, 'Risk Flag', 'Dashboard Alert', '1 students have low attendance', 1, '2026-03-24 16:47:20', 'dashboard_alerts', NULL, '2026-03-21 13:02:34', 0, NULL),
(13, 1, 'Risk Flag', 'Dashboard Alert', '1 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-03-24 02:21:20', 0, NULL),
(14, 1, 'Risk Flag', 'Dashboard Alert', '1 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-03-24 02:21:20', 0, NULL),
(15, 27, 'Risk Flag', 'Dashboard Alert', '1 students identified as at-risk', 1, '2026-03-24 16:47:20', 'dashboard_alerts', NULL, '2026-03-24 16:00:57', 0, NULL),
(16, 27, 'Risk Flag', 'Dashboard Alert', '1 students have low attendance', 1, '2026-03-24 16:47:20', 'dashboard_alerts', NULL, '2026-03-24 16:00:57', 0, NULL),
(17, 29, 'Announcement', 'announcement', 'attention teachers!', 0, NULL, 'announcements', 59, '2026-03-24 16:54:11', 0, NULL),
(18, 29, 'Risk Flag', 'Dashboard Alert', '1 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-03-24 17:00:49', 0, NULL),
(19, 29, 'Risk Flag', 'Dashboard Alert', '1 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-03-24 17:00:49', 0, NULL),
(20, 29, 'Risk Flag', 'Dashboard Alert', '1 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-03-25 02:51:34', 0, NULL),
(21, 29, 'Risk Flag', 'Dashboard Alert', '1 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-03-25 02:51:34', 0, NULL),
(22, 1, 'Risk Flag', 'Dashboard Alert', '1 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-03-25 02:51:56', 0, NULL),
(23, 1, 'Risk Flag', 'Dashboard Alert', '1 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-03-25 02:51:56', 0, NULL),
(24, 1, 'Risk Flag', 'Dashboard Alert', '2 students have low attendance', 1, '2026-03-25 14:32:19', 'dashboard_alerts', NULL, '2026-03-25 04:38:04', 0, NULL),
(25, 1, 'Announcement', 'fuck u', 'fuck me', 0, NULL, 'announcements', 60, '2026-03-25 14:32:35', 0, NULL),
(26, 26, 'Announcement', 'fuck u', 'fuck me', 0, NULL, 'announcements', 60, '2026-03-25 14:32:35', 0, NULL),
(27, 27, 'Announcement', 'fuck u', 'fuck me', 0, NULL, 'announcements', 60, '2026-03-25 14:32:35', 0, NULL),
(28, 28, 'Announcement', 'fuck u', 'fuck me', 0, NULL, 'announcements', 60, '2026-03-25 14:32:35', 0, NULL),
(29, 29, 'Announcement', 'fuck u', 'fuck me', 0, NULL, 'announcements', 60, '2026-03-25 14:32:35', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `positions`
--

CREATE TABLE `positions` (
  `position_id` int(11) NOT NULL,
  `position_name` varchar(150) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Employee position lookup';

--
-- Dumping data for table `positions`
--

INSERT INTO `positions` (`position_id`, `position_name`, `description`, `is_deleted`, `deleted_at`) VALUES
(1, 'Principal', NULL, 0, NULL),
(2, 'Assistant Principal', NULL, 0, NULL),
(3, 'Registrar', NULL, 0, NULL),
(4, 'Teacher', NULL, 0, NULL),
(8, 'ICT Coordinator', NULL, 0, NULL),
(9, 'Administrative Staff', NULL, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `report_cards`
--

CREATE TABLE `report_cards` (
  `report_card_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `grading_period_id` int(11) NOT NULL,
  `learner_name` varchar(300) DEFAULT NULL COMMENT 'Full name at generation time',
  `lrn` varchar(20) DEFAULT NULL,
  `grade_level_name` varchar(50) DEFAULT NULL,
  `section_name` varchar(100) DEFAULT NULL,
  `school_year_label` varchar(20) DEFAULT NULL,
  `general_average` decimal(5,2) DEFAULT NULL,
  `days_present` int(11) DEFAULT NULL,
  `days_absent` int(11) DEFAULT NULL,
  `days_late` int(11) DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL COMMENT 'Path to generated PDF file',
  `generated_at` datetime DEFAULT current_timestamp(),
  `generated_by` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Generated report card header — snapshot allows reprint without live joins';

-- --------------------------------------------------------

--
-- Table structure for table `report_card_grades`
--

CREATE TABLE `report_card_grades` (
  `rc_grade_id` int(11) NOT NULL,
  `report_card_id` int(11) NOT NULL,
  `subject_name` varchar(150) NOT NULL COMMENT 'Snapshot of subject name at generation time',
  `subject_code` varchar(50) DEFAULT NULL,
  `quarterly_grade` decimal(5,2) DEFAULT NULL,
  `final_grade` decimal(5,2) DEFAULT NULL,
  `remark` enum('Passed','Failed') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Per-subject grade snapshot per report card — enables full offline reprint';

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

--
-- Dumping data for table `risk_assessments`
--

INSERT INTO `risk_assessments` (`risk_assessment_id`, `enrollment_id`, `grading_period_id`, `risk_level_id`, `assessed_by`, `assessed_at`, `notes`, `is_deleted`, `deleted_at`) VALUES
(2, 6, 6, 4, 27, '2026-02-21 12:44:01', '', 1, '2026-03-20 21:56:05'),
(3, 5, 6, 3, 1, '2026-02-23 10:42:48', 'Urgent!', 1, '2026-03-25 04:37:03'),
(4, 11, 6, 3, 28, '2026-03-25 04:37:44', '', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `risk_indicators`
--

CREATE TABLE `risk_indicators` (
  `indicator_id` int(11) NOT NULL,
  `risk_assessment_id` int(11) NOT NULL,
  `indicator_type` varchar(100) DEFAULT NULL COMMENT 'Attendance, Grade Drop, Behavioral …',
  `details` text DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Individual risk indicator flags tied to a risk assessment';

--
-- Dumping data for table `risk_indicators`
--

INSERT INTO `risk_indicators` (`indicator_id`, `risk_assessment_id`, `indicator_type`, `details`, `is_deleted`, `deleted_at`) VALUES
(1, 2, 'Grade Drop', '', 0, NULL),
(2, 4, 'Attendance', '', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `risk_levels`
--

CREATE TABLE `risk_levels` (
  `risk_level_id` int(11) NOT NULL,
  `risk_name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `color_code` varchar(10) DEFAULT NULL COMMENT 'Hex color for UI e.g. #FF0000',
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Risk level classification — Low, Moderate, High, Critical';

--
-- Dumping data for table `risk_levels`
--

INSERT INTO `risk_levels` (`risk_level_id`, `risk_name`, `description`, `color_code`, `is_deleted`, `deleted_at`) VALUES
(1, 'Low', 'Routine monitoring only', '#28A745', 0, NULL),
(2, 'Moderate', 'Early warning; advisory support required', '#FFC107', 0, NULL),
(3, 'High', 'Failing 1-2 subjects or chronic absences; active intervention needed', '#FF6B35', 0, NULL),
(4, 'Critical', 'High risk of dropout; urgent escalation to school head', '#DC3545', 0, NULL);

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='System user roles — Admin, Teacher, Learner, etc.';

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`role_id`, `role_name`, `description`, `is_deleted`, `deleted_at`) VALUES
(8, 'admin', NULL, 0, NULL),
(9, 'teacher', NULL, 0, NULL),
(10, 'learners', NULL, 0, NULL);

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
(1, 'school_name', NULL, 'Official name of the school', NULL, '2026-03-20 10:09:36', 0, NULL),
(2, 'school_id', NULL, 'DepEd School ID (printed on enrollment form)', NULL, '2026-03-20 10:09:36', 0, NULL),
(3, 'school_address', NULL, 'Complete school address', NULL, '2026-03-20 10:09:36', 0, NULL),
(4, 'division', NULL, 'DepEd Division', NULL, '2026-03-20 10:09:36', 0, NULL),
(5, 'district', NULL, 'DepEd District', NULL, '2026-03-20 10:09:36', 0, NULL),
(6, 'region', NULL, 'DepEd Region', NULL, '2026-03-20 10:09:36', 0, NULL),
(7, 'principal_name', NULL, 'Name of the School Principal', NULL, '2026-03-20 10:09:36', 0, NULL),
(8, 'school_year_label', NULL, 'Display label e.g. 2025-2026', NULL, '2026-03-20 10:09:36', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `school_years`
--

CREATE TABLE `school_years` (
  `school_year_id` int(11) NOT NULL,
  `year_start` int(4) DEFAULT NULL,
  `year_end` int(4) DEFAULT NULL,
  `year_label` varchar(20) NOT NULL COMMENT 'e.g. 2025-2026',
  `date_start` date DEFAULT NULL,
  `date_end` date DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 0,
  `grading_system_type` enum('Quarterly','Trimester','Semester') NOT NULL DEFAULT 'Quarterly',
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Academic school years';

--
-- Dumping data for table `school_years`
--

INSERT INTO `school_years` (`school_year_id`, `year_start`, `year_end`, `year_label`, `date_start`, `date_end`, `is_active`, `grading_system_type`, `is_deleted`, `deleted_at`) VALUES
(2, 2025, 2027, '2025-2027', '2026-02-20', '2027-03-12', 0, 'Trimester', 1, '2026-02-21 03:22:38'),
(5, 2026, 2027, '2026-2027', '2026-02-21', '2026-02-21', 1, 'Quarterly', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `sections`
--

CREATE TABLE `sections` (
  `section_id` int(11) NOT NULL,
  `section_name` varchar(100) NOT NULL,
  `grade_level_id` int(11) NOT NULL,
  `school_year_id` int(11) NOT NULL COMMENT 'Sections are per school year',
  `adviser_id` int(11) DEFAULT NULL COMMENT 'Class adviser / homeroom teacher',
  `max_capacity` int(11) NOT NULL DEFAULT 45 COMMENT 'Max enrolled learners allowed',
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ;

--
-- Dumping data for table `sections`
--

INSERT INTO `sections` (`section_id`, `section_name`, `grade_level_id`, `school_year_id`, `adviser_id`, `max_capacity`, `is_deleted`, `deleted_at`) VALUES
(2, 'Section Gemini', 1, 5, NULL, 45, 0, NULL),
(3, 'Gold', 1, 5, NULL, 45, 0, NULL),
(4, 'test grade 10', 10, 5, NULL, 45, 0, NULL),
(5, 'Aquarius', 8, 5, NULL, 45, 0, NULL);

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
  `subject_code` varchar(50) NOT NULL COMMENT 'DepEd code e.g. MATH, ENG, FIL',
  `description` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Subject master list';

--
-- Dumping data for table `subjects`
--

INSERT INTO `subjects` (`subject_id`, `subject_name`, `subject_code`, `description`, `is_deleted`, `deleted_at`) VALUES
(1, 'Mother Tongue (MTB-MLE)', 'MTB-MLE', 'Primary language of instruction — Grades 1 to 3', 0, NULL),
(2, 'Filipino', 'FIL', 'Filipino language — all elementary levels', 0, NULL),
(3, 'English', 'ENG', 'English language — all elementary levels', 0, NULL),
(4, 'Mathematics', 'MATH', 'Mathematics — all levels; spiral progression', 0, NULL),
(5, 'Araling Panlipunan', 'AP', 'Social Studies — all levels', 0, NULL),
(6, 'Edukasyon sa Pagpapakatao (EsP)', 'ESP', 'Values Education — all levels', 0, NULL),
(7, 'Music, Arts, Physical Education and Health (MAPEH)', 'MAPEH', 'Clustered learning area — all levels', 0, NULL),
(8, 'Good Manners and Right Conduct (GMRC)', 'GMRC', 'MATATAG Curriculum — Grades 1-6', 0, NULL),
(9, 'Makabansa', 'MAKABANSA', 'MATATAG Curriculum — Grades 1-6; Filipino identity', 0, NULL),
(10, 'Science', 'SCI', 'Science — introduced Grade 3; spiral progression', 0, NULL),
(11, 'Edukasyong Pantahanan at Pangkabuhayan (EPP)', 'EPP', 'Home Economics and Livelihood — Grades 4-6', 0, NULL),
(12, 'Technology and Livelihood Education (TLE)', 'TLE', 'Exploratory courses — JHS Grades 7-10', 0, NULL),
(13, 'Music (MAPEH Component)', 'MUSIC', 'MAPEH component subject', 0, NULL),
(14, 'Arts (MAPEH Component)', 'ARTS', 'MAPEH component subject', 0, NULL),
(15, 'Physical Education (MAPEH Component)', 'PE', 'MAPEH component subject', 0, NULL),
(16, 'Health (MAPEH Component)', 'HEALTH', 'MAPEH component subject', 0, NULL);

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
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `password`, `role_id`, `is_active`, `last_login`, `created_at`, `updated_at`, `is_deleted`, `deleted_at`) VALUES
(1, 'admin', '$2y$10$VKM.qCITU8xZ6vk/zsDctO..2JxgW/4BBp48USk8R6Cp7adFfyI7G', 8, 1, NULL, '2026-02-20 09:50:24', '2026-02-20 09:50:24', 0, NULL),
(26, '911', '$2y$10$AQSa5DbbKrugxc69Gr6VZzOVbuqV4gr.G6Ntmc8HUgXghiK0T6O71G', 8, 1, NULL, '2026-02-21 01:12:41', '2026-02-21 13:32:42', 0, NULL),
(27, '12-12-12', '$2y$10$66FPGWticM8NG/Vg1u.dYObUkMIJScmMDOdrccZJnJL5.fmzi8pNS', 8, 1, NULL, '2026-02-21 12:37:24', '2026-02-21 12:37:24', 0, NULL),
(28, '02-2324-06121', '$2y$10$bC9jkmOMT2GP2KgshYw7Zuh6LJ6tRF3ZAiUJNNbHfpZAxfWPYSHzi', 10, 1, NULL, '2026-02-23 13:07:42', '2026-02-23 13:07:42', 0, NULL),
(29, '28-28-28', '$2y$10$ugJkwO2s9MXWDrVSC277ZOAqcNowWhiCfhvZvPf/jbKJiFBHRhKeC', 9, 1, NULL, '2026-02-23 14:16:36', '2026-02-23 14:16:36', 0, NULL);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_learner_progression_candidates`
-- (See below for the actual view)
--
CREATE TABLE `vw_learner_progression_candidates` (
`progression_id` int(11)
,`enrollment_id` int(11)
,`learner_id` int(11)
,`source_school_year_id` int(11)
,`current_grade_level_id` int(11)
,`next_grade_level_id` int(11)
,`general_average` decimal(5,2)
,`final_status` enum('Promoted','Retained','Completed')
,`remarks` varchar(255)
,`is_processed` tinyint(1)
,`source_section_id` int(11)
,`source_section_name` varchar(100)
,`source_curriculum_id` int(11)
);

-- --------------------------------------------------------

--
-- Structure for view `vw_learner_progression_candidates`
--
DROP TABLE IF EXISTS `vw_learner_progression_candidates`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_learner_progression_candidates`  AS SELECT `lp`.`progression_id` AS `progression_id`, `lp`.`enrollment_id` AS `enrollment_id`, `lp`.`learner_id` AS `learner_id`, `lp`.`school_year_id` AS `source_school_year_id`, `lp`.`current_grade_level_id` AS `current_grade_level_id`, `lp`.`next_grade_level_id` AS `next_grade_level_id`, `lp`.`general_average` AS `general_average`, `lp`.`final_status` AS `final_status`, `lp`.`remarks` AS `remarks`, `lp`.`is_processed` AS `is_processed`, `e`.`section_id` AS `source_section_id`, `sec`.`section_name` AS `source_section_name`, `e`.`curriculum_id` AS `source_curriculum_id` FROM ((`learner_progression` `lp` join `enrollments` `e` on(`e`.`enrollment_id` = `lp`.`enrollment_id` and `e`.`is_deleted` = 0)) left join `sections` `sec` on(`sec`.`section_id` = `e`.`section_id`)) WHERE `lp`.`final_status` in ('Promoted','Retained') ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `announcements`
--
ALTER TABLE `announcements`
  ADD PRIMARY KEY (`announcement_id`),
  ADD KEY `idx_ann_posted_by` (`posted_by`),
  ADD KEY `idx_ann_target_role` (`target_role_id`),
  ADD KEY `idx_published_at` (`published_at`);

--
-- Indexes for table `attendance`
--
ALTER TABLE `attendance`
  ADD PRIMARY KEY (`attendance_id`),
  ADD UNIQUE KEY `uq_attendance_entry` (`enrollment_id`,`class_id`,`attendance_date`),
  ADD KEY `idx_att_enrollment` (`enrollment_id`),
  ADD KEY `idx_att_class` (`class_id`),
  ADD KEY `idx_att_period` (`grading_period_id`),
  ADD KEY `idx_att_date` (`attendance_date`),
  ADD KEY `idx_att_status` (`status`),
  ADD KEY `fk_att_recorded` (`recorded_by`);

--
-- Indexes for table `attendance_monthly_summaries`
--
ALTER TABLE `attendance_monthly_summaries`
  ADD PRIMARY KEY (`summary_id`),
  ADD UNIQUE KEY `uq_att_monthly` (`enrollment_id`,`school_year_id`,`month_no`),
  ADD KEY `idx_att_monthly_sy` (`school_year_id`,`month_no`),
  ADD KEY `fk_att_monthly_user` (`computed_by`);

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
-- Indexes for table `class_offerings`
--
ALTER TABLE `class_offerings`
  ADD PRIMARY KEY (`class_id`),
  ADD UNIQUE KEY `uq_class_offering` (`subject_id`,`section_id`,`teacher_id`,`school_year_id`),
  ADD KEY `idx_class_subject` (`subject_id`),
  ADD KEY `idx_class_section` (`section_id`),
  ADD KEY `idx_class_teacher` (`teacher_id`),
  ADD KEY `idx_class_sy` (`school_year_id`);

--
-- Indexes for table `class_schedules`
--
ALTER TABLE `class_schedules`
  ADD PRIMARY KEY (`schedule_id`),
  ADD UNIQUE KEY `uq_class_schedule_slot` (`class_id`,`day_of_week`,`start_time`,`end_time`),
  ADD KEY `idx_cs_class` (`class_id`),
  ADD KEY `idx_cs_day` (`day_of_week`);

--
-- Indexes for table `curricula`
--
ALTER TABLE `curricula`
  ADD PRIMARY KEY (`curriculum_id`),
  ADD UNIQUE KEY `uq_curriculum_code` (`curriculum_code`),
  ADD KEY `idx_cur_active` (`is_active`,`is_deleted`),
  ADD KEY `fk_cur_created_by` (`created_by`);

--
-- Indexes for table `curriculum_grade_levels`
--
ALTER TABLE `curriculum_grade_levels`
  ADD PRIMARY KEY (`cgl_id`),
  ADD UNIQUE KEY `uq_cgl_cur_grade` (`curriculum_id`,`grade_level_id`),
  ADD KEY `idx_cgl_curriculum` (`curriculum_id`),
  ADD KEY `idx_cgl_grade` (`grade_level_id`);

--
-- Indexes for table `curriculum_grading_components`
--
ALTER TABLE `curriculum_grading_components`
  ADD PRIMARY KEY (`component_id`),
  ADD UNIQUE KEY `uq_cgc_cur_grade_code` (`curriculum_id`,`grade_level_id`,`component_code`),
  ADD KEY `idx_cgc_curriculum` (`curriculum_id`),
  ADD KEY `idx_cgc_grade` (`grade_level_id`);

--
-- Indexes for table `curriculum_passing_marks`
--
ALTER TABLE `curriculum_passing_marks`
  ADD PRIMARY KEY (`passing_mark_id`),
  ADD UNIQUE KEY `uq_cpm_cur_grade_subj` (`curriculum_id`,`grade_level_id`,`subject_id`),
  ADD KEY `idx_cpm_curriculum` (`curriculum_id`),
  ADD KEY `fk_cpm_grade_level` (`grade_level_id`),
  ADD KEY `fk_cpm_subject` (`subject_id`);

--
-- Indexes for table `curriculum_school_year_map`
--
ALTER TABLE `curriculum_school_year_map`
  ADD PRIMARY KEY (`map_id`),
  ADD UNIQUE KEY `uq_csym_cur_sy` (`curriculum_id`,`school_year_id`),
  ADD KEY `idx_csym_curriculum` (`curriculum_id`),
  ADD KEY `idx_csym_school_year` (`school_year_id`);

--
-- Indexes for table `curriculum_subjects`
--
ALTER TABLE `curriculum_subjects`
  ADD PRIMARY KEY (`curriculum_subject_id`),
  ADD UNIQUE KEY `uq_cs_cur_grade_subj` (`curriculum_id`,`grade_level_id`,`subject_id`),
  ADD KEY `idx_cs_curriculum` (`curriculum_id`),
  ADD KEY `idx_cs_grade` (`grade_level_id`),
  ADD KEY `idx_cs_subject` (`subject_id`);

--
-- Indexes for table `document_types`
--
ALTER TABLE `document_types`
  ADD PRIMARY KEY (`document_type_id`),
  ADD UNIQUE KEY `uq_document_type_name` (`type_name`);

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
  ADD KEY `idx_ec_learner` (`learner_id`);

--
-- Indexes for table `employees`
--
ALTER TABLE `employees`
  ADD PRIMARY KEY (`employee_id`),
  ADD UNIQUE KEY `uq_employee_user` (`user_id`),
  ADD UNIQUE KEY `uq_employee_number` (`employee_number`),
  ADD KEY `idx_emp_position` (`position_id`);

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
  ADD KEY `idx_enroll_curriculum` (`curriculum_id`),
  ADD KEY `idx_dash_composite` (`school_year_id`,`grade_level_id`,`section_id`),
  ADD KEY `fk_enroll_type_id` (`enrollment_type_id`);

--
-- Indexes for table `enrollment_requirements`
--
ALTER TABLE `enrollment_requirements`
  ADD PRIMARY KEY (`requirement_id`),
  ADD UNIQUE KEY `uq_er_sy_grade_doc` (`school_year_id`,`grade_level_id`,`document_type_id`),
  ADD KEY `idx_er_school_year` (`school_year_id`),
  ADD KEY `idx_er_grade_level` (`grade_level_id`),
  ADD KEY `idx_er_document_type` (`document_type_id`);

--
-- Indexes for table `enrollment_types`
--
ALTER TABLE `enrollment_types`
  ADD PRIMARY KEY (`enrollment_type_id`),
  ADD UNIQUE KEY `uq_enrollment_type_name` (`type_name`);

--
-- Indexes for table `family_members`
--
ALTER TABLE `family_members`
  ADD PRIMARY KEY (`family_member_id`),
  ADD KEY `idx_family_learner` (`learner_id`);

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
-- Indexes for table `geo_barangays`
--
ALTER TABLE `geo_barangays`
  ADD PRIMARY KEY (`barangay_id`),
  ADD UNIQUE KEY `uq_geo_barangay_city_name` (`city_municipality_id`,`barangay_name`),
  ADD KEY `idx_geo_barangay_citymun` (`city_municipality_id`);

--
-- Indexes for table `geo_cities_municipalities`
--
ALTER TABLE `geo_cities_municipalities`
  ADD PRIMARY KEY (`city_municipality_id`),
  ADD UNIQUE KEY `uq_geo_citymun_prov_name` (`province_id`,`city_municipality_name`),
  ADD KEY `idx_geo_citymun_province` (`province_id`);

--
-- Indexes for table `geo_provinces`
--
ALTER TABLE `geo_provinces`
  ADD PRIMARY KEY (`province_id`),
  ADD UNIQUE KEY `uq_geo_provinces_name` (`province_name`),
  ADD UNIQUE KEY `uq_geo_provinces_psgc` (`psgc_code`);

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
-- Indexes for table `grade_level_progression`
--
ALTER TABLE `grade_level_progression`
  ADD PRIMARY KEY (`grade_level_id`),
  ADD KEY `idx_glp_next_grade` (`next_grade_level_id`);

--
-- Indexes for table `grading_periods`
--
ALTER TABLE `grading_periods`
  ADD PRIMARY KEY (`grading_period_id`),
  ADD UNIQUE KEY `uq_period_school_year` (`school_year_id`,`period_name`),
  ADD KEY `idx_gp_locked_by` (`locked_by`);

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
  ADD KEY `idx_iv_enrollment` (`enrollment_id`),
  ADD KEY `idx_iv_risk` (`risk_assessment_id`),
  ADD KEY `idx_iv_conductor` (`conducted_by`);

--
-- Indexes for table `learners`
--
ALTER TABLE `learners`
  ADD PRIMARY KEY (`learner_id`),
  ADD UNIQUE KEY `uq_learner_lrn` (`lrn`),
  ADD UNIQUE KEY `uq_learner_user` (`user_id`);

--
-- Indexes for table `learner_addresses`
--
ALTER TABLE `learner_addresses`
  ADD PRIMARY KEY (`learner_address_id`),
  ADD KEY `idx_la_learner` (`learner_id`),
  ADD KEY `idx_la_province` (`province_id`),
  ADD KEY `idx_la_citymun` (`city_municipality_id`),
  ADD KEY `idx_la_barangay` (`barangay_id`);

--
-- Indexes for table `learner_documents`
--
ALTER TABLE `learner_documents`
  ADD PRIMARY KEY (`document_id`),
  ADD KEY `idx_ld_learner` (`learner_id`),
  ADD KEY `idx_ld_enrollment` (`enrollment_id`),
  ADD KEY `idx_ld_document_type` (`document_type_id`),
  ADD KEY `idx_ld_submitted_by` (`submitted_by`),
  ADD KEY `idx_ld_school_year` (`school_year_id`);

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
-- Indexes for table `learner_progression`
--
ALTER TABLE `learner_progression`
  ADD PRIMARY KEY (`progression_id`),
  ADD UNIQUE KEY `uq_lp_enrollment` (`enrollment_id`),
  ADD KEY `idx_lp_learner_sy` (`learner_id`,`school_year_id`),
  ADD KEY `idx_lp_sy_processed` (`school_year_id`,`is_processed`),
  ADD KEY `idx_lp_next_grade` (`next_grade_level_id`),
  ADD KEY `fk_lp_current_grade` (`current_grade_level_id`);

--
-- Indexes for table `learning_modalities`
--
ALTER TABLE `learning_modalities`
  ADD PRIMARY KEY (`modality_id`),
  ADD UNIQUE KEY `uq_learning_modality_name` (`modality_name`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`notification_id`),
  ADD KEY `idx_notif_user` (`user_id`),
  ADD KEY `idx_notif_read` (`is_read`);

--
-- Indexes for table `positions`
--
ALTER TABLE `positions`
  ADD PRIMARY KEY (`position_id`);

--
-- Indexes for table `report_cards`
--
ALTER TABLE `report_cards`
  ADD PRIMARY KEY (`report_card_id`),
  ADD UNIQUE KEY `uq_rc_enrollment_period` (`enrollment_id`,`grading_period_id`),
  ADD KEY `idx_rc_period` (`grading_period_id`),
  ADD KEY `idx_rc_generated_by` (`generated_by`);

--
-- Indexes for table `report_card_grades`
--
ALTER TABLE `report_card_grades`
  ADD PRIMARY KEY (`rc_grade_id`),
  ADD UNIQUE KEY `uq_rcg_card_subject` (`report_card_id`,`subject_name`),
  ADD KEY `idx_rcg_report_card` (`report_card_id`);

--
-- Indexes for table `risk_assessments`
--
ALTER TABLE `risk_assessments`
  ADD PRIMARY KEY (`risk_assessment_id`),
  ADD UNIQUE KEY `uq_risk_enrollment_period` (`enrollment_id`,`grading_period_id`),
  ADD KEY `idx_risk_period` (`grading_period_id`),
  ADD KEY `idx_risk_level` (`risk_level_id`),
  ADD KEY `idx_risk_assessed_by` (`assessed_by`);

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
  ADD PRIMARY KEY (`school_year_id`);

--
-- Indexes for table `sections`
--
ALTER TABLE `sections`
  ADD PRIMARY KEY (`section_id`),
  ADD UNIQUE KEY `uq_section_grade_sy` (`grade_level_id`,`section_name`,`school_year_id`),
  ADD KEY `idx_section_grade_level` (`grade_level_id`),
  ADD KEY `idx_section_sy` (`school_year_id`),
  ADD KEY `idx_section_adviser` (`adviser_id`);

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
-- Indexes for table `subjects`
--
ALTER TABLE `subjects`
  ADD PRIMARY KEY (`subject_id`),
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
  MODIFY `announcement_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT for table `attendance`
--
ALTER TABLE `attendance`
  MODIFY `attendance_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `attendance_monthly_summaries`
--
ALTER TABLE `attendance_monthly_summaries`
  MODIFY `summary_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `audit_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `citizenships`
--
ALTER TABLE `citizenships`
  MODIFY `citizenship_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `class_offerings`
--
ALTER TABLE `class_offerings`
  MODIFY `class_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT for table `class_schedules`
--
ALTER TABLE `class_schedules`
  MODIFY `schedule_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `curricula`
--
ALTER TABLE `curricula`
  MODIFY `curriculum_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `curriculum_grade_levels`
--
ALTER TABLE `curriculum_grade_levels`
  MODIFY `cgl_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `curriculum_grading_components`
--
ALTER TABLE `curriculum_grading_components`
  MODIFY `component_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `curriculum_passing_marks`
--
ALTER TABLE `curriculum_passing_marks`
  MODIFY `passing_mark_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `curriculum_school_year_map`
--
ALTER TABLE `curriculum_school_year_map`
  MODIFY `map_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `curriculum_subjects`
--
ALTER TABLE `curriculum_subjects`
  MODIFY `curriculum_subject_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=91;

--
-- AUTO_INCREMENT for table `document_types`
--
ALTER TABLE `document_types`
  MODIFY `document_type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `education_levels`
--
ALTER TABLE `education_levels`
  MODIFY `education_level_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `emergency_contacts`
--
ALTER TABLE `emergency_contacts`
  MODIFY `emergency_contact_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `employees`
--
ALTER TABLE `employees`
  MODIFY `employee_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `enrollments`
--
ALTER TABLE `enrollments`
  MODIFY `enrollment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

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
  MODIFY `family_member_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

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
-- AUTO_INCREMENT for table `geo_barangays`
--
ALTER TABLE `geo_barangays`
  MODIFY `barangay_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `geo_cities_municipalities`
--
ALTER TABLE `geo_cities_municipalities`
  MODIFY `city_municipality_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `geo_provinces`
--
ALTER TABLE `geo_provinces`
  MODIFY `province_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `grades`
--
ALTER TABLE `grades`
  MODIFY `grade_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `grade_levels`
--
ALTER TABLE `grade_levels`
  MODIFY `grade_level_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `grading_periods`
--
ALTER TABLE `grading_periods`
  MODIFY `grading_period_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `honor_levels`
--
ALTER TABLE `honor_levels`
  MODIFY `honor_level_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `interventions`
--
ALTER TABLE `interventions`
  MODIFY `intervention_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `learners`
--
ALTER TABLE `learners`
  MODIFY `learner_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `learner_addresses`
--
ALTER TABLE `learner_addresses`
  MODIFY `learner_address_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

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
-- AUTO_INCREMENT for table `learner_progression`
--
ALTER TABLE `learner_progression`
  MODIFY `progression_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `learning_modalities`
--
ALTER TABLE `learning_modalities`
  MODIFY `modality_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT for table `positions`
--
ALTER TABLE `positions`
  MODIFY `position_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `report_cards`
--
ALTER TABLE `report_cards`
  MODIFY `report_card_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `report_card_grades`
--
ALTER TABLE `report_card_grades`
  MODIFY `rc_grade_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `risk_assessments`
--
ALTER TABLE `risk_assessments`
  MODIFY `risk_assessment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `risk_indicators`
--
ALTER TABLE `risk_indicators`
  MODIFY `indicator_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `risk_levels`
--
ALTER TABLE `risk_levels`
  MODIFY `risk_level_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `role_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `school_settings`
--
ALTER TABLE `school_settings`
  MODIFY `setting_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `school_years`
--
ALTER TABLE `school_years`
  MODIFY `school_year_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `sections`
--
ALTER TABLE `sections`
  MODIFY `section_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `section_rankings`
--
ALTER TABLE `section_rankings`
  MODIFY `ranking_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `subjects`
--
ALTER TABLE `subjects`
  MODIFY `subject_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

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
-- Constraints for table `attendance`
--
ALTER TABLE `attendance`
  ADD CONSTRAINT `fk_att_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`enrollment_id`),
  ADD CONSTRAINT `fk_att_period` FOREIGN KEY (`grading_period_id`) REFERENCES `grading_periods` (`grading_period_id`),
  ADD CONSTRAINT `fk_att_recorded` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `attendance_monthly_summaries`
--
ALTER TABLE `attendance_monthly_summaries`
  ADD CONSTRAINT `fk_att_monthly_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`enrollment_id`),
  ADD CONSTRAINT `fk_att_monthly_sy` FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`),
  ADD CONSTRAINT `fk_att_monthly_user` FOREIGN KEY (`computed_by`) REFERENCES `users` (`user_id`);

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
-- Constraints for table `class_schedules`
--
ALTER TABLE `class_schedules`
  ADD CONSTRAINT `fk_cs_class` FOREIGN KEY (`class_id`) REFERENCES `class_offerings` (`class_id`);

--
-- Constraints for table `curricula`
--
ALTER TABLE `curricula`
  ADD CONSTRAINT `fk_cur_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `curriculum_grade_levels`
--
ALTER TABLE `curriculum_grade_levels`
  ADD CONSTRAINT `fk_cgl_curriculum` FOREIGN KEY (`curriculum_id`) REFERENCES `curricula` (`curriculum_id`),
  ADD CONSTRAINT `fk_cgl_grade_level` FOREIGN KEY (`grade_level_id`) REFERENCES `grade_levels` (`grade_level_id`);

--
-- Constraints for table `curriculum_grading_components`
--
ALTER TABLE `curriculum_grading_components`
  ADD CONSTRAINT `fk_cgc_curriculum` FOREIGN KEY (`curriculum_id`) REFERENCES `curricula` (`curriculum_id`),
  ADD CONSTRAINT `fk_cgc_grade_level` FOREIGN KEY (`grade_level_id`) REFERENCES `grade_levels` (`grade_level_id`);

--
-- Constraints for table `curriculum_passing_marks`
--
ALTER TABLE `curriculum_passing_marks`
  ADD CONSTRAINT `fk_cpm_curriculum` FOREIGN KEY (`curriculum_id`) REFERENCES `curricula` (`curriculum_id`),
  ADD CONSTRAINT `fk_cpm_grade_level` FOREIGN KEY (`grade_level_id`) REFERENCES `grade_levels` (`grade_level_id`),
  ADD CONSTRAINT `fk_cpm_subject` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`);

--
-- Constraints for table `curriculum_school_year_map`
--
ALTER TABLE `curriculum_school_year_map`
  ADD CONSTRAINT `fk_csym_curriculum` FOREIGN KEY (`curriculum_id`) REFERENCES `curricula` (`curriculum_id`),
  ADD CONSTRAINT `fk_csym_school_year` FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`);

--
-- Constraints for table `curriculum_subjects`
--
ALTER TABLE `curriculum_subjects`
  ADD CONSTRAINT `fk_cs_curriculum` FOREIGN KEY (`curriculum_id`) REFERENCES `curricula` (`curriculum_id`),
  ADD CONSTRAINT `fk_cs_grade_level` FOREIGN KEY (`grade_level_id`) REFERENCES `grade_levels` (`grade_level_id`),
  ADD CONSTRAINT `fk_cs_subject` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`);

--
-- Constraints for table `emergency_contacts`
--
ALTER TABLE `emergency_contacts`
  ADD CONSTRAINT `fk_ec_learner` FOREIGN KEY (`learner_id`) REFERENCES `learners` (`learner_id`);

--
-- Constraints for table `employees`
--
ALTER TABLE `employees`
  ADD CONSTRAINT `fk_employee_position` FOREIGN KEY (`position_id`) REFERENCES `positions` (`position_id`),
  ADD CONSTRAINT `fk_employee_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `enrollments`
--
ALTER TABLE `enrollments`
  ADD CONSTRAINT `fk_enroll_curriculum` FOREIGN KEY (`curriculum_id`) REFERENCES `curricula` (`curriculum_id`),
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
  ADD CONSTRAINT `fk_family_learner` FOREIGN KEY (`learner_id`) REFERENCES `learners` (`learner_id`);

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
-- Constraints for table `geo_barangays`
--
ALTER TABLE `geo_barangays`
  ADD CONSTRAINT `fk_geo_barangay_citymun` FOREIGN KEY (`city_municipality_id`) REFERENCES `geo_cities_municipalities` (`city_municipality_id`) ON UPDATE CASCADE;

--
-- Constraints for table `geo_cities_municipalities`
--
ALTER TABLE `geo_cities_municipalities`
  ADD CONSTRAINT `fk_geo_citymun_province` FOREIGN KEY (`province_id`) REFERENCES `geo_provinces` (`province_id`) ON UPDATE CASCADE;

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
-- Constraints for table `grade_level_progression`
--
ALTER TABLE `grade_level_progression`
  ADD CONSTRAINT `fk_glp_grade` FOREIGN KEY (`grade_level_id`) REFERENCES `grade_levels` (`grade_level_id`),
  ADD CONSTRAINT `fk_glp_next_grade` FOREIGN KEY (`next_grade_level_id`) REFERENCES `grade_levels` (`grade_level_id`);

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
-- Constraints for table `learners`
--
ALTER TABLE `learners`
  ADD CONSTRAINT `fk_learner_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `learner_addresses`
--
ALTER TABLE `learner_addresses`
  ADD CONSTRAINT `fk_la_barangay` FOREIGN KEY (`barangay_id`) REFERENCES `geo_barangays` (`barangay_id`),
  ADD CONSTRAINT `fk_la_citymun` FOREIGN KEY (`city_municipality_id`) REFERENCES `geo_cities_municipalities` (`city_municipality_id`),
  ADD CONSTRAINT `fk_la_learner` FOREIGN KEY (`learner_id`) REFERENCES `learners` (`learner_id`),
  ADD CONSTRAINT `fk_la_province` FOREIGN KEY (`province_id`) REFERENCES `geo_provinces` (`province_id`);

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
-- Constraints for table `learner_progression`
--
ALTER TABLE `learner_progression`
  ADD CONSTRAINT `fk_lp_current_grade` FOREIGN KEY (`current_grade_level_id`) REFERENCES `grade_levels` (`grade_level_id`),
  ADD CONSTRAINT `fk_lp_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`enrollment_id`),
  ADD CONSTRAINT `fk_lp_learner` FOREIGN KEY (`learner_id`) REFERENCES `learners` (`learner_id`),
  ADD CONSTRAINT `fk_lp_next_grade` FOREIGN KEY (`next_grade_level_id`) REFERENCES `grade_levels` (`grade_level_id`),
  ADD CONSTRAINT `fk_lp_school_year` FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`);

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `report_cards`
--
ALTER TABLE `report_cards`
  ADD CONSTRAINT `fk_rc_enroll` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`enrollment_id`),
  ADD CONSTRAINT `fk_rc_generated` FOREIGN KEY (`generated_by`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_rc_period` FOREIGN KEY (`grading_period_id`) REFERENCES `grading_periods` (`grading_period_id`);

--
-- Constraints for table `report_card_grades`
--
ALTER TABLE `report_card_grades`
  ADD CONSTRAINT `fk_rcg_report_card` FOREIGN KEY (`report_card_id`) REFERENCES `report_cards` (`report_card_id`);

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
-- Constraints for table `sections`
--
ALTER TABLE `sections`
  ADD CONSTRAINT `fk_section_adviser` FOREIGN KEY (`adviser_id`) REFERENCES `employees` (`employee_id`),
  ADD CONSTRAINT `fk_section_grade` FOREIGN KEY (`grade_level_id`) REFERENCES `grade_levels` (`grade_level_id`),
  ADD CONSTRAINT `fk_section_sy` FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`);

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
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
