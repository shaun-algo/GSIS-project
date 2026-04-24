-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Apr 24, 2026 at 02:48 PM
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
(60, 'fuck u', 'fuck me', 1, NULL, '2026-03-25 14:32:35', NULL, 0, NULL, 1, '2026-03-25 14:32:40'),
(61, 'test post', 'test', 1, 10, '2026-03-28 15:19:08', NULL, 0, NULL, 1, '2026-03-28 15:21:57'),
(62, 'test', 'test', 1, NULL, '2026-03-28 15:27:51', NULL, 0, NULL, 1, '2026-03-29 23:25:34'),
(63, 'test', 'test', 1, NULL, '2026-03-28 15:42:49', NULL, 1, NULL, 1, '2026-03-28 15:42:57'),
(64, 'TEST', 'Privacy Policy  \nLast updated: March 28, 2026\n\nNumen in the Sewer respects your privacy.\n\nWhat we collect  \n- Basic device/app info (such as device type, OS version, app version)  \n- Crash and performance data (to fix bugs and improve the game)\n\nWhat we do with it  \n- Keep the game working  \n- Improve performance and stability  \n- Fix errors and prevent abuse\n\nWhat we don’t do  \n- We do not sell your personal information.\n\nThird-party services  \nThe game may use services like Google Play Services, analytics, crash reporting, or ads.  \nThese services may collect data according to their own privacy policies.\n\nChildren  \nThe game is not intended for children under the age required by local law unless stated otherwise.\n\nSecurity  \nWe use reasonable steps to protect data, but no system is completely secure.\n\nChanges  \nWe may update this policy. Updates will be posted with a new “Last updated” date.\n\nContact  \nEmail: belonoacshaun@gmail.com\nDeveloper: shn.studio', 1, NULL, '2026-03-28 22:29:53', NULL, 0, NULL, 0, NULL),
(65, 'test', 'test', 1, NULL, '2026-03-29 23:25:02', NULL, 0, NULL, 1, '2026-03-29 23:25:37'),
(66, 'hi ', 'hello', 35, NULL, '2026-04-22 03:57:16', NULL, 0, NULL, 1, '2026-04-24 16:26:00'),
(67, 'awdasd', 'asdasdasdass', 30, NULL, '2026-04-24 16:31:26', NULL, 0, NULL, 1, '2026-04-24 18:34:40'),
(68, 'asd', 'asd', 30, NULL, '2026-04-24 18:34:44', NULL, 0, NULL, 1, '2026-04-24 18:57:19'),
(69, 'asdasd', 'asdasd', 30, NULL, '2026-04-24 18:57:22', NULL, 0, NULL, 1, '2026-04-24 19:46:43'),
(70, 'asdasd', 'asd', 30, NULL, '2026-04-24 20:09:24', NULL, 0, NULL, 1, '2026-04-24 20:09:41'),
(71, 'sdfsdf', 'sdfsdfsdf', 30, NULL, '2026-04-24 20:42:33', NULL, 0, NULL, 0, NULL),
(72, 'sefsef', 'esfefsefs', 30, NULL, '2026-04-24 20:42:41', NULL, 0, NULL, 1, '2026-04-24 20:42:50');

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
  `session` enum('AM','PM') NOT NULL DEFAULT 'AM' COMMENT 'SF2: AM or PM half-day session',
  `nls_reason` enum('a1','a2','a3','a4','b1','b2','b3','b4','b5','b6','b7','c1','c2','c3','d1','d2','d3','e1','f') DEFAULT NULL COMMENT 'SF2 NLS reason code; only set when status = Absent',
  `transfer_note` varchar(255) DEFAULT NULL COMMENT 'SF2 Remarks: school name if learner was TRANSFERRED IN or OUT',
  `status` enum('Present','Absent','Late','Cutting','Excused','Official Business') NOT NULL DEFAULT 'Present' COMMENT 'SF2: blank=Present X=Absent upper-half=Late lower-half=Cutting',
  `remarks` varchar(255) DEFAULT NULL,
  `recorded_by` int(11) DEFAULT NULL,
  `recorded_at` datetime DEFAULT current_timestamp(),
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Daily or per-period attendance. class_id=0 means whole-day homeroom record.';

--
-- Dumping data for table `attendance`
--

INSERT INTO `attendance` (`attendance_id`, `enrollment_id`, `class_id`, `grading_period_id`, `attendance_date`, `session`, `nls_reason`, `transfer_note`, `status`, `remarks`, `recorded_by`, `recorded_at`, `is_deleted`, `deleted_at`) VALUES
(1, 10, 0, 6, '2026-03-01', 'AM', NULL, NULL, 'Present', NULL, 1, '2026-03-26 10:04:05', 0, NULL),
(2, 6, 0, 6, '2026-03-01', 'AM', NULL, NULL, 'Present', NULL, 1, '2026-03-26 10:04:05', 0, NULL),
(3, 9, 0, 6, '2026-03-01', 'AM', NULL, NULL, 'Present', NULL, 1, '2026-03-26 10:04:05', 0, NULL),
(4, 11, 0, 6, '2026-03-01', 'AM', NULL, NULL, 'Present', NULL, 1, '2026-03-26 10:04:27', 0, NULL),
(5, 5, 0, 6, '2026-03-01', 'AM', NULL, NULL, 'Present', NULL, 1, '2026-03-26 10:04:27', 0, NULL),
(6, 9, 0, 6, '2026-03-26', 'AM', NULL, NULL, 'Absent', NULL, 1, '2026-03-26 10:39:15', 0, NULL),
(7, 9, 0, 6, '2026-03-26', 'PM', NULL, NULL, 'Absent', NULL, 1, '2026-03-26 10:39:21', 0, NULL),
(8, 8, 0, 6, '2026-03-26', 'PM', NULL, NULL, 'Present', NULL, 1, '2026-03-26 18:27:14', 0, NULL),
(10, 10, 0, 6, '2026-03-27', 'AM', NULL, NULL, 'Absent', NULL, 1, '2026-03-27 12:03:18', 0, NULL),
(11, 6, 0, 6, '2026-03-27', 'AM', NULL, NULL, 'Late', NULL, 1, '2026-03-27 12:03:18', 0, NULL),
(12, 10, 0, 6, '2026-03-27', 'PM', NULL, NULL, 'Absent', NULL, 1, '2026-03-27 12:03:22', 0, NULL),
(13, 6, 0, 6, '2026-03-27', 'PM', NULL, NULL, 'Absent', NULL, 1, '2026-03-27 12:03:22', 0, NULL),
(14, 12, 0, 6, '2026-03-27', 'AM', NULL, NULL, 'Present', NULL, 1, '2026-03-27 13:30:39', 0, NULL),
(15, 12, 0, 6, '2026-03-27', 'PM', NULL, NULL, 'Present', NULL, 1, '2026-03-27 13:30:49', 0, NULL),
(18, 9, 0, 6, '2026-03-28', 'AM', NULL, NULL, 'Present', NULL, 1, '2026-03-28 15:24:43', 0, NULL),
(19, 10, 0, 6, '2026-03-28', 'AM', NULL, NULL, 'Present', NULL, 1, '2026-03-28 15:24:43', 0, NULL),
(20, 6, 0, 6, '2026-03-28', 'AM', NULL, NULL, 'Present', NULL, 1, '2026-03-28 15:24:43', 0, NULL),
(21, 9, 0, 6, '2026-03-28', 'PM', NULL, NULL, 'Present', NULL, 1, '2026-03-28 15:24:48', 0, NULL),
(22, 10, 0, 6, '2026-03-28', 'PM', NULL, NULL, 'Present', NULL, 1, '2026-03-28 15:24:48', 0, NULL),
(23, 6, 0, 6, '2026-03-28', 'PM', NULL, NULL, 'Present', NULL, 1, '2026-03-28 15:24:48', 0, NULL),
(24, 12, 0, 6, '2026-03-28', 'AM', NULL, NULL, 'Present', NULL, 1, '2026-03-28 15:39:54', 0, NULL),
(25, 12, 0, 6, '2026-03-28', 'PM', NULL, NULL, 'Present', NULL, 1, '2026-03-28 15:39:56', 0, NULL),
(42, 8, 0, 6, '2026-03-29', 'AM', NULL, NULL, 'Absent', NULL, 1, '2026-03-29 23:19:52', 0, NULL),
(43, 8, 0, 6, '2026-03-29', 'PM', NULL, NULL, 'Absent', NULL, 1, '2026-03-29 23:19:56', 0, NULL),
(44, 15, 0, 6, '2026-04-21', 'AM', NULL, NULL, 'Present', NULL, 35, '2026-04-22 03:48:07', 0, NULL),
(46, 8, 0, 6, '2026-04-21', 'AM', NULL, NULL, 'Absent', NULL, 35, '2026-04-22 03:48:07', 0, NULL),
(47, 15, 0, 6, '2026-04-21', 'PM', NULL, NULL, 'Cutting', NULL, 35, '2026-04-22 03:48:22', 0, NULL),
(48, 15, 87, 6, '2026-04-21', 'AM', NULL, NULL, 'Absent', NULL, 35, '2026-04-22 03:55:19', 0, NULL),
(49, 8, 87, 6, '2026-04-21', 'AM', NULL, NULL, 'Present', NULL, 35, '2026-04-24 19:34:12', 0, NULL),
(50, 8, 87, 6, '2026-04-22', 'AM', NULL, NULL, 'Present', NULL, 35, '2026-04-22 20:28:38', 0, NULL),
(52, 15, 87, 6, '2026-04-22', 'PM', NULL, NULL, 'Late', NULL, 35, '2026-04-22 20:28:43', 0, NULL),
(53, 17, 19, 6, '2026-04-24', 'AM', NULL, NULL, 'Absent', NULL, 39, '2026-04-24 19:01:14', 0, NULL),
(55, 15, 87, 6, '2026-03-26', 'AM', NULL, NULL, 'Absent', NULL, 35, '2026-04-24 19:34:42', 0, NULL);

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

--
-- Dumping data for table `audit_logs`
--

INSERT INTO `audit_logs` (`audit_id`, `user_id`, `table_name`, `record_id`, `action`, `old_values`, `new_values`, `action_time`, `ip_address`) VALUES
(1, 30, 'announcements', 68, 'DELETE', NULL, NULL, '2026-04-24 18:57:19', '::1'),
(2, 30, 'announcements', 69, 'INSERT', NULL, '{\"announcement_id\":69,\"title\":\"asdasd\",\"target_role_id\":null,\"is_pinned\":0}', '2026-04-24 18:57:22', '::1'),
(3, 30, 'users', 28, 'UPDATE', '{\"user_id\":28,\"username\":\"02-2324-06121\",\"password\":\"$2y$10$bC9jkmOMT2GP2KgshYw7Zuh6LJ6tRF3ZAiUJNNbHfpZAxfWPYSHzi\",\"role_id\":10,\"is_active\":1,\"last_login\":\"2026-04-24 16:22:26\",\"created_at\":\"2026-02-23 13:07:42\",\"updated_at\":\"2026-04-24 18:59:04\",\"is_deleted\":0,\"deleted_at\":null}', '{\"user_id\":28,\"username\":\"02-2324-06121\",\"role_id\":\"10\",\"is_active\":1}', '2026-04-24 18:59:04', '::1'),
(4, 30, 'announcements', 69, 'DELETE', NULL, NULL, '2026-04-24 19:46:43', '127.0.0.1'),
(5, 30, 'announcements', 70, 'INSERT', NULL, '{\"announcement_id\":70,\"title\":\"asdasd\",\"target_role_id\":null,\"is_pinned\":0}', '2026-04-24 20:09:24', '127.0.0.1'),
(6, 30, 'announcements', 70, 'DELETE', NULL, NULL, '2026-04-24 20:09:41', '127.0.0.1'),
(7, 30, 'announcements', 71, 'INSERT', NULL, '{\"announcement_id\":71,\"title\":\"sdfsdf\",\"target_role_id\":null,\"is_pinned\":0}', '2026-04-24 20:42:33', '127.0.0.1'),
(8, 30, 'announcements', 72, 'INSERT', NULL, '{\"announcement_id\":72,\"title\":\"sefsef\",\"target_role_id\":null,\"is_pinned\":0}', '2026-04-24 20:42:41', '127.0.0.1'),
(9, 30, 'announcements', 72, 'DELETE', NULL, NULL, '2026-04-24 20:42:50', '127.0.0.1');

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
(14, 2, 2, 1, 5, 0, NULL),
(15, 8, 2, 1, 5, 0, NULL),
(16, 1, 2, 1, 5, 1, '2026-03-26 14:52:19'),
(17, 4, 2, 1, 5, 1, '2026-03-26 14:52:19'),
(18, 13, 3, 27, 5, 1, '2026-03-26 14:48:07'),
(19, 5, 3, 32, 5, 0, NULL),
(20, 16, 3, 26, 5, 1, '2026-03-26 16:30:26'),
(21, 10, 3, 26, 5, 1, '2026-03-26 16:30:41'),
(22, 12, 3, 26, 5, 1, '2026-03-26 16:30:42'),
(23, 9, 3, 26, 5, 0, NULL),
(24, 7, 3, 27, 5, 0, NULL),
(25, 4, 3, 26, 5, 0, NULL),
(26, 11, 3, 26, 5, 1, '2026-03-26 16:30:08'),
(27, 1, 3, 26, 5, 0, NULL),
(28, 6, 3, 26, 5, 0, NULL),
(29, 13, 3, 26, 5, 1, '2026-03-26 16:30:35'),
(30, 15, 3, 26, 5, 1, '2026-03-26 16:30:39'),
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
(47, 12, 4, 32, 5, 0, NULL),
(48, 1, 3, 27, 5, 1, '2026-03-26 14:48:07'),
(49, 2, 3, 27, 5, 1, '2026-03-26 14:48:07'),
(50, 4, 3, 27, 5, 1, '2026-03-26 14:48:07'),
(51, 5, 3, 27, 5, 0, NULL),
(52, 6, 3, 27, 5, 1, '2026-03-26 14:48:07'),
(53, 8, 3, 27, 5, 1, '2026-03-26 14:48:07'),
(54, 1, 2, 26, 5, 0, NULL),
(55, 2, 2, 26, 5, 0, NULL),
(56, 3, 2, 26, 5, 0, NULL),
(57, 4, 2, 26, 5, 0, NULL),
(58, 5, 2, 26, 5, 0, NULL),
(59, 6, 2, 26, 5, 0, NULL),
(60, 7, 2, 26, 5, 0, NULL),
(61, 8, 2, 26, 5, 0, NULL),
(62, 9, 2, 26, 5, 0, NULL),
(63, 1, 2, 27, 5, 1, '2026-03-26 14:48:13'),
(64, 2, 5, 1, 5, 0, NULL),
(65, 3, 5, 1, 5, 0, NULL),
(66, 4, 5, 1, 5, 1, '2026-03-26 14:51:53'),
(67, 5, 5, 1, 5, 1, '2026-03-26 14:51:53'),
(68, 6, 5, 1, 5, 0, NULL),
(69, 7, 5, 1, 5, 1, '2026-03-26 14:51:53'),
(70, 10, 5, 1, 5, 1, '2026-03-26 14:51:53'),
(71, 12, 5, 1, 5, 1, '2026-03-26 14:51:53'),
(72, 3, 3, 26, 5, 1, '2026-03-26 16:30:06'),
(73, 5, 5, 27, 5, 0, NULL),
(74, 5, 2, 27, 5, 0, NULL),
(75, 5, 4, 27, 5, 0, NULL),
(76, 14, 4, 1, 5, 1, '2026-03-26 14:53:41'),
(77, 11, 4, 1, 5, 1, '2026-03-26 14:53:41'),
(78, 11, 5, 1, 5, 0, NULL),
(79, 14, 5, 1, 5, 0, NULL),
(80, 14, 3, 1, 5, 1, '2026-03-26 16:30:13'),
(81, 2, 3, 1, 5, 0, NULL),
(82, 3, 3, 32, 5, 0, NULL),
(83, 6, 3, 1, 5, 1, '2026-03-26 16:30:10'),
(84, 11, 3, 1, 5, 1, '2026-03-26 16:30:08'),
(85, 14, 2, 1, 5, 0, NULL),
(86, 3, 2, 1, 5, 0, NULL),
(87, 11, 2, 31, 5, 0, NULL),
(88, 6, 2, 32, 5, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `class_offering_assignment_requests`
--

CREATE TABLE `class_offering_assignment_requests` (
  `request_id` int(11) NOT NULL,
  `section_id` int(11) NOT NULL,
  `school_year_id` int(11) NOT NULL,
  `requested_by_user_id` int(11) NOT NULL,
  `status` enum('Pending','Approved','Rejected') NOT NULL DEFAULT 'Pending',
  `note` varchar(255) DEFAULT NULL,
  `reviewed_by_user_id` int(11) DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `class_offering_assignment_requests`
--

INSERT INTO `class_offering_assignment_requests` (`request_id`, `section_id`, `school_year_id`, `requested_by_user_id`, `status`, `note`, `reviewed_by_user_id`, `reviewed_at`, `created_at`) VALUES
(7, 5, 5, 29, 'Pending', NULL, NULL, NULL, '2026-04-21 22:26:02'),
(8, 2, 5, 35, 'Pending', NULL, NULL, NULL, '2026-04-21 22:28:48');

-- --------------------------------------------------------

--
-- Table structure for table `class_offering_assignment_request_items`
--

CREATE TABLE `class_offering_assignment_request_items` (
  `request_item_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `subject_id` int(11) NOT NULL,
  `teacher_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `class_offering_assignment_request_items`
--

INSERT INTO `class_offering_assignment_request_items` (`request_item_id`, `request_id`, `subject_id`, `teacher_id`, `created_at`) VALUES
(8, 7, 5, 1, '2026-04-21 22:26:02'),
(9, 8, 5, 31, '2026-04-21 22:28:48');

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
(18, 7, 'Gas Gas', 'Emergency Contact', '0981238348', 'Wao', 1, '2026-04-23 20:45:38'),
(19, 6, 'Guko B. Gohan', 'Emergency Contact', '091231289329', 'Carmen Cdo', 1, '2026-03-20 23:09:33'),
(20, 6, 'Guko B. Gohan', 'Emergency Contact', '091231289329', 'Carmen Cdo', 1, '2026-03-20 23:09:38'),
(21, 6, 'Guko B. Gohan', 'Emergency Contact', '091231289329', 'Carmen Cdo', 1, '2026-03-20 23:09:41'),
(22, 6, 'Guko B. Gohan', 'Emergency Contact', '091231289329', 'Carmen Cdo', 1, '2026-03-20 23:09:44'),
(23, 6, 'Guko B. Gohan', 'Emergency Contact', '091231289329', 'Carmen Cdo', 1, '2026-03-25 14:50:15'),
(24, 6, 'Guko B. Gohan', 'Emergency Contact', '091231289329', 'Carmen Cdo', 0, NULL),
(25, 10, 'Gladys H. Montalba', 'Emergency Contact', '09978503470', 'Poblacion 2 , Banisilan North Cotabato', 1, '2026-03-27 11:34:18'),
(26, 10, 'Gladys H. Montalba', 'Emergency Contact', '09978503470', 'Poblacion 2 , Banisilan North Cotabato', 0, NULL),
(27, 7, 'Gas Gas', 'Emergency Contact', '0981238348', 'Wao', 0, NULL);

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
(28, 29, '28-28-28', 'Neilban', 'Colinaresssss', 'Ong', NULL, '2026-01-28', NULL, '0914314390', 'nico.Ong.coc@phinmaed.com', NULL, 4, '2026-02-23', 0, NULL),
(29, 30, '09090909', 'tewst', 'wad', 'awda', NULL, '2026-03-06', 'Male', '091398423423', 'ads@gmail.com', 'ad', 9, NULL, 1, '2026-03-28 14:49:58'),
(30, 31, '45888', 'Muhammad', 'Bern', 'Ali', NULL, '2026-03-02', 'Male', '098712761276', 'muhammad@gmail.com', 'USA', 3, NULL, 1, '2026-03-28 15:02:07'),
(31, 35, '2026', 'Estroga Jb', 'Terceño', 'Barera', 'test', '2026-04-01', 'Male', '098172387123', 'barera@gmail.com', 'test', 4, '2026-04-22', 0, NULL),
(32, 39, '2026-1001', 'Teacher John', 'test', 'test', 'testt', '2026-03-31', NULL, NULL, NULL, NULL, 4, NULL, 0, NULL);

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
(9, 7, 5, 1, 3, 1, 1, '2026-02-11', 'Enrolled', '2026-03-20 10:09:36', 0, NULL),
(10, 8, 5, 1, 3, 1, 1, '2026-03-21', 'Enrolled', '2026-03-21 16:24:34', 0, NULL),
(11, 9, 5, 10, 4, 1, 1, '2026-03-24', 'Enrolled', '2026-03-24 16:26:30', 0, NULL),
(12, 10, 5, 1, 3, 1, 1, '2026-03-27', 'Enrolled', '2026-03-27 10:48:50', 0, NULL),
(13, 11, 5, 1, 2, 1, NULL, '2026-04-21', 'Enrolled', '2026-04-21 09:34:23', 0, NULL),
(14, 12, 5, 1, 2, NULL, NULL, '2026-04-21', 'Enrolled', '2026-04-21 10:17:59', 0, NULL),
(15, 13, 5, 1, 2, 1, NULL, '2026-04-21', 'Enrolled', '2026-04-21 10:22:00', 0, NULL),
(16, 14, 5, 10, 4, 1, 4, '2026-04-21', 'Enrolled', '2026-04-22 00:27:11', 0, NULL),
(17, 15, 5, 1, 3, 1, 4, '2026-04-22', 'Enrolled', '2026-04-22 19:15:52', 0, NULL);

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
(45, 7, 'Montalba, Wilfredo', 'Father', NULL, 'Teaching', '09873248234', NULL, 1, '2026-04-23 20:45:38'),
(46, 7, 'Gladys H. Montalba', 'Mother', NULL, 'Prostitute', '09723476237', NULL, 1, '2026-04-23 20:45:38'),
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
(60, 6, 'Darna X. Batallion', 'Mother', NULL, 'Bad Ass Killer', '091872318273', NULL, 0, NULL),
(61, 10, 'Wilfredo L. Montalba', 'Father', NULL, 'Teaching', '09169919600', NULL, 1, '2026-03-27 11:34:18'),
(62, 10, 'Gladys H. Montalba', 'Mother', NULL, 'Teaching', '09978503470', NULL, 1, '2026-03-27 11:34:18'),
(63, 10, 'None', 'Spouse', NULL, 'None', NULL, NULL, 1, '2026-03-27 11:34:18'),
(64, 10, 'None', 'Legal Guardian', NULL, NULL, 'None', NULL, 1, '2026-03-27 11:34:18'),
(65, 10, 'Wilfredo L. Montalba', 'Father', NULL, 'Teaching', '09169919600', NULL, 0, NULL),
(66, 10, 'Gladys H. Montalba', 'Mother', NULL, 'Teaching', '09978503470', NULL, 0, NULL),
(67, 10, 'None', 'Spouse', NULL, 'None', NULL, NULL, 0, NULL),
(68, 10, 'None', 'Legal Guardian', NULL, NULL, 'None', NULL, 0, NULL),
(69, 15, 'kulas', 'Father', NULL, NULL, NULL, NULL, 0, NULL),
(70, 7, 'mona, Wilfredo', 'Father', NULL, 'Teaching', '09873248234', NULL, 0, NULL),
(71, 7, 'hell H. mona', 'Mother', NULL, 'Prostitute', '09723476237', NULL, 0, NULL);

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

--
-- Dumping data for table `final_grades`
--

INSERT INTO `final_grades` (`final_grade_id`, `enrollment_id`, `class_id`, `final_grade`, `remark`, `computed_by`, `computed_at`, `is_deleted`, `deleted_at`) VALUES
(22, 5, 40, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(23, 5, 41, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(24, 5, 42, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(25, 5, 43, 100.00, 'Passed', 1, '2026-03-26 11:35:30', 0, NULL),
(26, 5, 44, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(27, 5, 45, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(28, 5, 46, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(29, 5, 47, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(30, 6, 51, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(31, 8, 14, 94.00, 'Passed', 1, '2026-03-26 00:34:33', 0, NULL),
(32, 8, 15, 92.00, 'Passed', 1, '2026-03-26 00:34:33', 0, NULL),
(33, 9, 51, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(34, 10, 51, 94.63, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(35, 11, 40, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(36, 11, 41, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(37, 11, 42, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(38, 11, 43, 98.75, 'Passed', 1, '2026-03-26 11:35:30', 0, NULL),
(39, 11, 44, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(40, 11, 45, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(41, 11, 46, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(42, 11, 47, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(43, 6, 23, 94.63, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(44, 6, 24, 96.38, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(45, 6, 25, 95.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(46, 6, 27, 95.13, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(47, 6, 28, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(48, 6, 31, 98.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(49, 6, 81, 95.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(50, 6, 82, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(51, 9, 23, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(52, 9, 24, 94.50, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(53, 9, 25, 96.88, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(54, 9, 27, 97.63, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(55, 9, 28, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(56, 9, 31, 96.63, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(57, 9, 81, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(58, 9, 82, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(59, 10, 23, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(60, 10, 24, 98.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(61, 10, 25, 96.25, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(62, 10, 27, 94.13, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(63, 10, 28, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(64, 10, 31, 99.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(65, 10, 81, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(66, 10, 82, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(67, 12, 23, 99.50, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(68, 12, 24, 99.50, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(69, 12, 25, 99.75, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(70, 12, 27, 99.38, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(71, 12, 28, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(72, 12, 31, 100.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(73, 12, 51, 83.75, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(74, 12, 81, 92.38, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(75, 12, 82, 96.25, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(76, 11, 75, 93.75, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(77, 8, 54, 96.88, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(78, 8, 55, 95.38, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(79, 8, 57, 96.63, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(80, 8, 60, 96.50, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(81, 8, 61, 94.38, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(82, 8, 62, 95.50, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(83, 8, 74, 82.50, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(84, 8, 85, 95.75, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(85, 8, 86, 94.38, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(86, 8, 87, 96.63, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(87, 8, 88, 95.63, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(88, 15, 87, 69.20, 'Failed', 30, '2026-04-24 20:42:19', 0, NULL),
(89, 17, 23, 89.75, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(90, 17, 24, 87.75, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(91, 17, 25, 80.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(92, 17, 27, 87.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(93, 17, 28, 91.00, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(94, 17, 31, 82.50, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(95, 17, 51, 88.75, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(96, 17, 81, 88.50, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(97, 17, 82, 88.75, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(98, 13, 87, 95.25, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL),
(99, 13, 88, 68.25, 'Failed', 30, '2026-04-24 20:42:19', 0, NULL),
(100, 16, 47, 99.38, 'Passed', 30, '2026-04-24 20:42:19', 0, NULL);

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

--
-- Dumping data for table `general_averages`
--

INSERT INTO `general_averages` (`general_average_id`, `enrollment_id`, `school_year_id`, `general_average`, `computed_by`, `computed_at`, `is_deleted`, `deleted_at`) VALUES
(7, 5, 5, 100.00, 30, '2026-04-24 20:42:19', 0, NULL),
(8, 6, 5, 97.13, 30, '2026-04-24 20:42:19', 0, NULL),
(9, 8, 5, 94.56, 30, '2026-04-24 20:42:19', 0, NULL),
(10, 9, 5, 98.40, 30, '2026-04-24 20:42:19', 0, NULL),
(11, 10, 5, 98.00, 30, '2026-04-24 20:42:19', 0, NULL),
(12, 11, 5, 99.22, 30, '2026-04-24 20:42:19', 0, NULL),
(13, 12, 5, 96.72, 30, '2026-04-24 20:42:19', 0, NULL),
(14, 15, 5, 69.20, 30, '2026-04-24 20:42:19', 0, NULL),
(15, 17, 5, 87.11, 30, '2026-04-24 20:42:19', 0, NULL),
(16, 13, 5, 81.75, 30, '2026-04-24 20:42:19', 0, NULL),
(17, 16, 5, 99.38, 30, '2026-04-24 20:42:19', 0, NULL);

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
  `deleted_at` datetime DEFAULT NULL,
  `initial_grade` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Per-subject quarterly grade entries';

--
-- Dumping data for table `grades`
--

INSERT INTO `grades` (`grade_id`, `enrollment_id`, `class_id`, `grading_period_id`, `written_works`, `performance_tasks`, `quarterly_exam`, `quarterly_grade`, `encoded_by`, `encoded_at`, `updated_at`, `is_deleted`, `deleted_at`, `initial_grade`) VALUES
(1, 5, 43, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 15:58:30', '2026-03-24 15:59:25', 0, NULL, NULL),
(4, 11, 43, 6, 100.00, 100.00, 95.00, 99.22, 1, '2026-03-24 16:27:30', '2026-04-22 04:21:45', 0, NULL, 98.75),
(6, 11, 35, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:28:17', '2026-03-24 16:28:17', 0, NULL, NULL),
(7, 5, 35, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:28:17', '2026-03-24 16:28:17', 0, NULL, NULL),
(8, 11, 44, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:28:29', '2026-03-24 16:28:29', 0, NULL, NULL),
(9, 5, 44, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:28:29', '2026-03-24 16:28:29', 0, NULL, NULL),
(10, 11, 36, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:28:41', '2026-03-24 16:28:41', 0, NULL, NULL),
(11, 5, 36, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:28:41', '2026-03-24 16:28:41', 0, NULL, NULL),
(12, 11, 47, 6, 100.00, 100.00, 100.00, 100.00, 39, '2026-03-24 16:28:52', '2026-04-24 17:39:42', 0, NULL, 100.00),
(13, 5, 47, 6, 100.00, 100.00, 100.00, 100.00, 39, '2026-03-24 16:28:52', '2026-04-24 17:39:42', 0, NULL, 100.00),
(14, 11, 38, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:29:06', '2026-03-24 16:29:06', 0, NULL, NULL),
(15, 5, 38, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:29:06', '2026-03-24 16:29:06', 0, NULL, NULL),
(16, 11, 37, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:29:17', '2026-03-24 16:29:17', 0, NULL, NULL),
(17, 5, 37, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:29:17', '2026-03-24 16:29:17', 0, NULL, NULL),
(18, 11, 40, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:29:38', '2026-03-24 16:29:38', 0, NULL, NULL),
(19, 5, 40, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:29:38', '2026-03-24 16:29:38', 0, NULL, NULL),
(20, 11, 33, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:29:55', '2026-03-24 16:29:55', 0, NULL, NULL),
(21, 5, 33, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:29:55', '2026-03-24 16:29:55', 0, NULL, NULL),
(22, 11, 41, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:30:46', '2026-03-24 16:30:46', 0, NULL, NULL),
(23, 5, 41, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:30:46', '2026-03-24 16:30:46', 0, NULL, NULL),
(24, 11, 32, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:31:00', '2026-03-24 16:31:00', 0, NULL, NULL),
(25, 5, 32, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:31:00', '2026-03-24 16:31:00', 0, NULL, NULL),
(26, 11, 34, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:31:19', '2026-03-24 16:31:19', 0, NULL, NULL),
(27, 5, 34, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:31:19', '2026-03-24 16:31:19', 0, NULL, NULL),
(28, 11, 42, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:31:33', '2026-03-24 16:31:33', 0, NULL, NULL),
(29, 5, 42, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:31:33', '2026-03-24 16:31:33', 0, NULL, NULL),
(30, 11, 45, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:32:02', '2026-03-24 16:32:02', 0, NULL, NULL),
(31, 5, 45, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:32:02', '2026-03-24 16:32:02', 0, NULL, NULL),
(32, 11, 46, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:32:15', '2026-03-24 16:32:15', 0, NULL, NULL),
(33, 5, 46, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:32:15', '2026-03-24 16:32:15', 0, NULL, NULL),
(34, 11, 39, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:32:32', '2026-03-24 16:32:32', 0, NULL, NULL),
(35, 5, 39, 6, 100.00, 100.00, 100.00, 100.00, 1, '2026-03-24 16:32:32', '2026-03-24 16:32:32', 0, NULL, NULL),
(36, 8, 14, 6, 100.00, 90.00, 90.00, 96.25, 1, '2026-03-25 04:19:00', '2026-04-22 04:21:45', 0, NULL, 94.00),
(37, 8, 15, 6, 90.00, 90.00, 100.00, 95.00, 1, '2026-03-25 04:24:14', '2026-04-22 04:21:45', 0, NULL, 92.00),
(38, 9, 19, 6, 100.00, 100.00, 100.00, 100.00, 39, '2026-03-25 22:21:22', '2026-04-24 17:09:53', 0, NULL, 100.00),
(39, 10, 19, 6, 89.00, 90.00, 99.00, 94.63, 39, '2026-03-25 22:21:22', '2026-04-24 17:13:02', 0, NULL, 91.40),
(40, 6, 19, 6, 100.00, 100.00, 100.00, 100.00, 39, '2026-03-25 22:21:22', '2026-04-24 17:29:45', 0, NULL, 100.00),
(41, 9, 51, 6, 100.00, 100.00, 100.00, 100.00, 30, '2026-03-25 22:22:07', '2026-04-24 08:29:03', 0, NULL, 100.00),
(42, 10, 51, 6, 89.00, 90.00, 99.00, 94.63, 30, '2026-03-25 22:22:07', '2026-04-24 08:29:03', 0, NULL, 91.40),
(43, 6, 51, 6, 100.00, 100.00, 100.00, 100.00, 30, '2026-03-25 22:22:07', '2026-04-24 08:29:03', 0, NULL, 100.00),
(44, 9, 31, 6, 90.00, 99.00, 95.00, 96.63, 30, '2026-03-27 10:54:08', '2026-04-24 08:30:01', 0, NULL, 94.60),
(45, 10, 31, 6, 100.00, 99.00, 94.00, 99.00, 30, '2026-03-27 10:54:08', '2026-04-24 08:30:01', 0, NULL, 98.40),
(46, 6, 31, 6, 97.00, 96.00, 98.00, 98.00, 30, '2026-03-27 10:54:08', '2026-04-24 08:30:01', 0, NULL, 96.80),
(47, 12, 31, 6, 100.00, 100.00, 100.00, 100.00, 30, '2026-03-27 10:54:08', '2026-04-24 08:30:01', 0, NULL, 100.00),
(51, 12, 51, 6, 70.00, 80.00, 70.00, 83.75, 30, '2026-03-27 10:54:27', '2026-04-24 08:29:03', 0, NULL, 74.00),
(52, 9, 28, 6, 100.00, 100.00, 100.00, 100.00, 30, '2026-03-27 10:55:00', '2026-04-24 08:29:11', 0, NULL, 100.00),
(53, 10, 28, 6, 100.00, 100.00, 100.00, 100.00, 30, '2026-03-27 10:55:00', '2026-04-24 08:29:11', 0, NULL, 100.00),
(54, 6, 28, 6, 100.00, 100.00, 100.00, 100.00, 30, '2026-03-27 10:55:00', '2026-04-24 08:29:11', 0, NULL, 100.00),
(55, 12, 28, 6, 100.00, 100.00, 100.00, 100.00, 30, '2026-03-27 10:55:00', '2026-04-24 08:29:11', 0, NULL, 100.00),
(56, 9, 82, 6, 100.00, 100.00, 100.00, 100.00, 39, '2026-03-27 10:55:19', '2026-04-24 20:06:29', 0, NULL, 100.00),
(57, 10, 82, 6, 100.00, 100.00, 100.00, 100.00, 39, '2026-03-27 10:55:19', '2026-04-24 20:06:29', 0, NULL, 100.00),
(58, 6, 82, 6, 100.00, 100.00, 100.00, 100.00, 39, '2026-03-27 10:55:19', '2026-04-24 20:06:29', 0, NULL, 100.00),
(59, 12, 82, 6, 95.00, 90.00, 100.00, 96.25, 39, '2026-03-27 10:55:19', '2026-04-24 20:06:29', 0, NULL, 94.00),
(60, 9, 81, 6, 100.00, 100.00, 100.00, 100.00, 30, '2026-03-27 10:55:44', '2026-04-24 08:29:53', 0, NULL, 100.00),
(61, 10, 81, 6, 100.00, 100.00, 100.00, 100.00, 30, '2026-03-27 10:55:44', '2026-04-24 08:29:53', 0, NULL, 100.00),
(62, 6, 81, 6, 100.00, 90.00, 80.00, 95.00, 30, '2026-03-27 10:55:44', '2026-04-24 08:29:53', 0, NULL, 92.00),
(63, 12, 81, 6, 80.00, 90.00, 99.00, 92.38, 30, '2026-03-27 10:55:44', '2026-04-24 08:29:53', 0, NULL, 87.80),
(64, 9, 23, 6, 100.00, 100.00, 100.00, 100.00, 30, '2026-03-27 10:56:17', '2026-04-24 08:30:08', 0, NULL, 100.00),
(65, 10, 23, 6, 100.00, 100.00, 100.00, 100.00, 30, '2026-03-27 10:56:17', '2026-04-24 08:30:08', 0, NULL, 100.00),
(66, 6, 23, 6, 91.00, 91.00, 93.00, 94.63, 30, '2026-03-27 10:56:17', '2026-04-24 08:30:08', 0, NULL, 91.40),
(67, 12, 23, 6, 100.00, 100.00, 96.00, 99.50, 30, '2026-03-27 10:56:17', '2026-04-24 08:30:08', 0, NULL, 99.20),
(68, 9, 25, 6, 100.00, 90.00, 95.00, 96.88, 30, '2026-03-27 10:57:00', '2026-04-24 08:30:17', 0, NULL, 95.00),
(69, 10, 25, 6, 98.00, 90.00, 94.00, 96.25, 30, '2026-03-27 10:57:00', '2026-04-24 08:30:17', 0, NULL, 94.00),
(70, 6, 25, 6, 97.00, 89.00, 88.00, 95.00, 30, '2026-03-27 10:57:00', '2026-04-24 08:30:17', 0, NULL, 92.00),
(71, 12, 25, 6, 100.00, 100.00, 98.00, 99.75, 30, '2026-03-27 10:57:00', '2026-04-24 08:30:17', 0, NULL, 99.60),
(72, 9, 27, 6, 98.00, 98.00, 89.00, 97.63, 30, '2026-03-27 10:57:35', '2026-04-24 08:30:25', 0, NULL, 96.20),
(73, 10, 27, 6, 89.00, 89.00, 97.00, 94.13, 30, '2026-03-27 10:57:35', '2026-04-24 08:30:25', 0, NULL, 90.60),
(74, 6, 27, 6, 96.00, 90.00, 89.00, 95.13, 30, '2026-03-27 10:57:35', '2026-04-24 08:30:25', 0, NULL, 92.20),
(75, 12, 27, 6, 100.00, 98.00, 99.00, 99.38, 30, '2026-03-27 10:57:35', '2026-04-24 08:30:25', 0, NULL, 99.00),
(76, 9, 24, 6, 89.00, 90.00, 98.00, 94.50, 30, '2026-03-27 10:59:09', '2026-04-24 08:30:35', 0, NULL, 91.20),
(77, 10, 24, 6, 98.00, 97.00, 94.00, 98.00, 30, '2026-03-27 10:59:09', '2026-04-24 08:30:35', 0, NULL, 96.80),
(78, 6, 24, 6, 94.00, 96.00, 91.00, 96.38, 30, '2026-03-27 10:59:09', '2026-04-24 08:30:35', 0, NULL, 94.20),
(79, 12, 24, 6, 100.00, 100.00, 96.00, 99.50, 30, '2026-03-27 10:59:09', '2026-04-24 08:30:35', 0, NULL, 99.20),
(132, 11, 75, 6, 90.00, 90.00, 90.00, 93.75, 1, '2026-03-27 14:22:42', '2026-04-22 04:21:45', 0, NULL, 90.00),
(133, 5, 75, 6, NULL, NULL, NULL, NULL, 1, '2026-03-27 14:22:42', '2026-03-27 14:22:42', 0, NULL, NULL),
(162, 8, 74, 6, 75.00, 70.00, 70.00, 82.50, 1, '2026-03-29 23:15:54', '2026-04-22 04:21:45', 0, NULL, 72.00),
(163, 8, 85, 6, 89.00, 99.00, 90.00, 95.75, 1, '2026-03-29 23:16:06', '2026-04-22 04:21:45', 0, NULL, 93.20),
(164, 8, 88, 6, 90.00, 93.00, 99.00, 95.63, 39, '2026-03-29 23:16:17', '2026-04-24 20:19:23', 0, NULL, 93.00),
(165, 8, 87, 6, 99.00, 89.00, 97.00, 96.63, 35, '2026-03-29 23:16:24', '2026-04-24 07:21:28', 0, NULL, 94.60),
(166, 8, 86, 6, 90.00, 89.00, 97.00, 94.38, 1, '2026-03-29 23:16:30', '2026-04-22 04:21:45', 0, NULL, 91.00),
(167, 8, 55, 6, 98.00, 89.00, 89.00, 95.38, 1, '2026-03-29 23:16:39', '2026-04-22 04:21:45', 0, NULL, 92.60),
(168, 8, 61, 6, 85.00, 93.00, 99.00, 94.38, 1, '2026-03-29 23:16:56', '2026-04-22 04:21:45', 0, NULL, 91.00),
(169, 8, 62, 6, 98.00, 89.00, 90.00, 95.50, 1, '2026-03-29 23:17:11', '2026-04-22 04:21:45', 0, NULL, 92.80),
(170, 8, 57, 6, 89.00, 99.00, 97.00, 96.63, 1, '2026-03-29 23:17:20', '2026-04-22 04:21:45', 0, NULL, 94.60),
(171, 8, 54, 6, 89.00, 99.00, 99.00, 96.88, 1, '2026-03-29 23:17:30', '2026-04-22 04:21:45', 0, NULL, 95.00),
(172, 8, 60, 6, 99.00, 89.00, 96.00, 96.50, 1, '2026-03-29 23:17:37', '2026-04-22 04:21:45', 0, NULL, 94.40),
(174, 15, 87, 6, 80.00, 8.00, 8.00, 69.20, 35, '2026-04-24 07:21:28', '2026-04-24 20:07:38', 0, NULL, 36.80),
(176, 13, 87, 6, 88.00, 98.00, 90.00, 95.25, 35, '2026-04-24 07:21:28', '2026-04-24 16:58:41', 0, NULL, 92.40),
(177, 14, 87, 6, NULL, NULL, NULL, NULL, 35, '2026-04-24 07:21:28', '2026-04-24 07:21:28', 0, NULL, NULL),
(178, 17, 51, 6, 70.00, 90.00, 90.00, 88.75, 30, '2026-04-24 08:29:03', '2026-04-24 08:29:03', 0, NULL, 82.00),
(183, 17, 28, 6, 89.00, 90.00, 70.00, 91.00, 30, '2026-04-24 08:29:11', '2026-04-24 08:29:11', 0, NULL, 85.60),
(188, 17, 82, 6, 80.00, 80.00, 90.00, 88.75, 39, '2026-04-24 08:29:46', '2026-04-24 20:06:29', 0, NULL, 82.00),
(193, 17, 81, 6, 89.00, 76.00, 78.00, 88.50, 30, '2026-04-24 08:29:53', '2026-04-24 08:29:53', 0, NULL, 81.60),
(198, 17, 31, 6, 56.00, 89.00, 70.00, 82.50, 30, '2026-04-24 08:30:01', '2026-04-24 08:30:01', 0, NULL, 72.00),
(203, 17, 23, 6, 87.00, 89.00, 66.00, 89.75, 30, '2026-04-24 08:30:07', '2026-04-24 08:30:07', 0, NULL, 83.60),
(208, 17, 25, 6, 70.00, 60.00, 80.00, 80.00, 30, '2026-04-24 08:30:17', '2026-04-24 08:30:17', 0, NULL, 68.00),
(213, 17, 27, 6, 78.00, 90.00, 60.00, 87.00, 30, '2026-04-24 08:30:25', '2026-04-24 08:30:25', 0, NULL, 79.20),
(218, 17, 24, 6, 67.00, 89.00, 90.00, 87.75, 30, '2026-04-24 08:30:35', '2026-04-24 08:30:35', 0, NULL, 80.40),
(231, 17, 19, 6, 100.00, 100.00, 100.00, 100.00, 39, '2026-04-24 17:09:53', '2026-04-24 20:13:35', 0, NULL, 100.00),
(235, 12, 19, 6, 90.00, 0.00, 9.00, 69.45, 39, '2026-04-24 17:09:53', '2026-04-24 17:35:30', 0, NULL, 37.80),
(271, 16, 47, 6, 99.00, 99.00, 99.00, 99.38, 39, '2026-04-24 17:39:42', '2026-04-24 17:39:42', 0, NULL, 99.00),
(338, 15, 88, 6, NULL, NULL, NULL, NULL, 39, '2026-04-24 20:19:23', '2026-04-24 20:19:23', 0, NULL, NULL),
(340, 13, 88, 6, 33.00, 33.00, 33.00, 68.25, 39, '2026-04-24 20:19:23', '2026-04-24 20:19:23', 0, NULL, 33.00),
(341, 14, 88, 6, NULL, NULL, NULL, NULL, 39, '2026-04-24 20:19:23', '2026-04-24 20:19:23', 0, NULL, NULL);

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
(7, NULL, '128000000920', 'Marya', 'Pato', 'Hagorn', NULL, '2026-03-29', 'Female', 'Single', NULL, NULL, NULL, 'Filipino', NULL, 1, 0, 0, 1, NULL, NULL, NULL, 0, NULL),
(8, NULL, '212012091029', 'test name', 'test', 'hello', 'Sr.', '2026-03-24', 'Male', 'Single', 'Aglipayan (Philippine Independent Church)', 'Cebuano', NULL, 'Filipino', 'Enrolled', 1, 0, 1, 1, NULL, '09361470082', 'tets@gmail.com', 0, NULL),
(9, NULL, '121212121212', 'Shaun Michael', 'Terceño', 'Belono-ac', NULL, '2026-03-16', 'Male', 'Single', 'Aglipayan (Philippine Independent Church)', 'Cebuano', NULL, 'Filipino', 'Enrolled', 0, 0, 1, 1, 'Kibawe Bukidnon', '091231241', 'acasx@gmail.com', 0, NULL),
(10, NULL, '129932120310', 'Sherla', 'H', 'Molly', NULL, '2003-08-29', 'Female', 'Single', 'Aglipayan (Philippine Independent Church)', 'Cebuano', NULL, 'Filipino', 'Enrolled', 0, 0, 1, 1, 'Wao, Lanao del Sur', '09271911499', 'xpensiveeeli@gmail.com', 0, NULL),
(11, NULL, '999000000002', 'Test', NULL, 'Learner2', NULL, NULL, NULL, NULL, NULL, 'Bikol', NULL, 'Filipino', NULL, 0, 0, 0, 1, NULL, NULL, NULL, 0, NULL),
(12, 33, '999000000003', 'UI', NULL, 'Visible', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 1, NULL, NULL, NULL, 0, NULL),
(13, 34, '999000000004', 'Reg', NULL, 'Created', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Filipino', 'Enrolled', 0, 0, 1, 1, NULL, NULL, NULL, 0, NULL),
(14, 36, '234234234234', 'awdawdaw', 'dawdawd', 'awdawd', NULL, '2026-04-14', 'Female', 'Annulled', 'Aglipayan (Philippine Independent Church)', 'Bikol', NULL, 'Filipino', 'Enrolled', 0, 0, 1, 1, 'awdawdawd', '2134234234234', 'eadfasd@gmail.com', 0, NULL),
(15, NULL, '123456789101', 'Johnbert', 'Test', 'Estroga', 'IV', '2026-04-14', 'Male', 'Married', 'Aglipayan (Philippine Independent Church)', 'Bikol', NULL, 'Filipino', 'Enrolled', 0, 0, 1, 1, 'test', '09982349823', 'johenberte3@gmail.com', 0, NULL);

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
(11, 7, 'CURRENT', NULL, NULL, NULL, '1209', 1, 1, 7, 'Philippines', 1, '2026-04-23 20:45:38', '2026-03-20 22:07:56', NULL),
(16, 6, 'CURRENT', NULL, NULL, NULL, '20189', 1, 1, 4, 'Philippines', 1, '2026-03-25 14:50:15', '2026-03-20 23:09:44', NULL),
(17, 8, 'CURRENT', '0912', 'test', 'test', '121212', 1, 1, 6, 'Philippines', 0, NULL, '2026-03-21 16:24:34', NULL),
(18, 9, 'CURRENT', '1212', 'test', 'et', '2323', 1, 1, 3, 'Philippines', 0, NULL, '2026-03-24 16:26:30', NULL),
(19, 6, 'CURRENT', NULL, NULL, NULL, '20189', 1, 1, 4, 'Philippines', 0, NULL, '2026-03-25 14:50:15', NULL),
(20, 10, 'CURRENT', 'N/A', 'N/A', 'N/A', '9000', 1, 1, 5, 'Philippines', 1, '2026-03-27 11:34:18', '2026-03-27 10:48:50', NULL),
(21, 10, 'CURRENT', 'N/A', 'N/A', 'N/A', '9000', 1, 1, 5, 'Philippines', 0, NULL, '2026-03-27 11:34:18', NULL),
(22, 14, 'CURRENT', '13324', 'asdasd', 'asdasd', '234234', 1, 1, 6, 'Philippines', 0, NULL, '2026-04-22 00:27:11', NULL),
(23, 15, 'CURRENT', '0192343029', 'test', 'test', '0992349823', 1, 1, 5, 'Philippines', 1, '2026-04-22 20:50:38', '2026-04-22 19:15:52', NULL),
(24, 15, 'CURRENT', '0192343029', 'test', 'test', '0992349823', 1, 1, 5, 'Philippines', 0, NULL, '2026-04-22 20:50:38', NULL),
(25, 7, 'CURRENT', NULL, NULL, NULL, '1209', 1, 1, 7, 'Philippines', 0, NULL, '2026-04-23 20:45:38', NULL);

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

--
-- Dumping data for table `learner_previous_schools`
--

INSERT INTO `learner_previous_schools` (`previous_school_id`, `learner_id`, `enrollment_id`, `last_grade_level_completed`, `last_school_year_completed`, `last_school_attended`, `last_school_id`, `is_deleted`, `deleted_at`) VALUES
(1, 10, 12, 'Grade 10', '2019', 'Grade 11', '129932120310', 1, '2026-03-27 11:34:18'),
(2, 10, 12, 'Grade 10', '2019', 'Grade 11', '129932120310', 0, NULL);

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
(17, 29, 'Announcement', 'announcement', 'attention teachers!', 1, '2026-04-21 21:07:40', 'announcements', 59, '2026-03-24 16:54:11', 0, NULL),
(18, 29, 'Risk Flag', 'Dashboard Alert', '1 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-03-24 17:00:49', 0, NULL),
(19, 29, 'Risk Flag', 'Dashboard Alert', '1 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-03-24 17:00:49', 0, NULL),
(20, 29, 'Risk Flag', 'Dashboard Alert', '1 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-03-25 02:51:34', 0, NULL),
(21, 29, 'Risk Flag', 'Dashboard Alert', '1 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-03-25 02:51:34', 0, NULL),
(22, 1, 'Risk Flag', 'Dashboard Alert', '1 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-03-25 02:51:56', 0, NULL),
(23, 1, 'Risk Flag', 'Dashboard Alert', '1 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-03-25 02:51:56', 0, NULL),
(24, 1, 'Risk Flag', 'Dashboard Alert', '2 students have low attendance', 1, '2026-03-25 14:32:19', 'dashboard_alerts', NULL, '2026-03-25 04:38:04', 0, NULL),
(25, 1, 'Announcement', 'fuck u', 'fuck me', 1, '2026-03-27 11:21:46', 'announcements', 60, '2026-03-25 14:32:35', 0, NULL),
(26, 26, 'Announcement', 'fuck u', 'fuck me', 0, NULL, 'announcements', 60, '2026-03-25 14:32:35', 0, NULL),
(27, 27, 'Announcement', 'fuck u', 'fuck me', 0, NULL, 'announcements', 60, '2026-03-25 14:32:35', 0, NULL),
(28, 28, 'Announcement', 'fuck u', 'fuck me', 0, NULL, 'announcements', 60, '2026-03-25 14:32:35', 0, NULL),
(29, 29, 'Announcement', 'fuck u', 'fuck me', 1, '2026-04-21 21:07:34', 'announcements', 60, '2026-03-25 14:32:35', 0, NULL),
(30, 1, 'Risk Flag', 'Dashboard Alert', '4 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-03-25 22:42:59', 0, NULL),
(31, 1, 'Risk Flag', 'Dashboard Alert', '4 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-03-25 22:42:59', 0, NULL),
(32, 1, 'Risk Flag', 'Dashboard Alert', '4 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-03-26 00:01:05', 0, NULL),
(33, 1, 'Risk Flag', 'Dashboard Alert', '4 students have low attendance', 1, '2026-03-26 12:13:05', 'dashboard_alerts', NULL, '2026-03-26 00:01:05', 0, NULL),
(34, 27, 'Risk Flag', 'Dashboard Alert', '4 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-03-26 16:46:13', 0, NULL),
(35, 27, 'Risk Flag', 'Dashboard Alert', '4 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-03-26 16:46:13', 0, NULL),
(36, 1, 'Risk Flag', 'Dashboard Alert', '4 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-03-27 00:15:19', 0, NULL),
(37, 1, 'Risk Flag', 'Dashboard Alert', '4 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-03-27 00:15:19', 0, NULL),
(38, 1, 'Risk Flag', 'Dashboard Alert', '5 students identified as at-risk', 1, '2026-03-27 11:21:52', 'dashboard_alerts', NULL, '2026-03-27 11:07:09', 0, NULL),
(39, 1, 'Risk Flag', 'Dashboard Alert', '6 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-03-27 12:05:13', 0, NULL),
(40, 1, 'Risk Flag', 'Dashboard Alert', '6 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-03-27 12:05:13', 0, NULL),
(41, 1, 'Risk Flag', 'Dashboard Alert', '7 students identified as at-risk', 1, '2026-03-27 12:18:32', 'dashboard_alerts', NULL, '2026-03-27 12:07:41', 0, NULL),
(42, 1, 'Risk Flag', 'Dashboard Alert', '7 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-03-27 13:30:22', 0, NULL),
(43, 1, 'Risk Flag', 'Dashboard Alert', '5 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-03-27 14:22:52', 0, NULL),
(44, 1, 'Risk Flag', 'Dashboard Alert', '6 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-03-28 14:49:34', 0, NULL),
(45, 1, 'Risk Flag', 'Dashboard Alert', '5 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-03-28 14:49:34', 0, NULL),
(46, 31, 'Risk Flag', 'Dashboard Alert', '6 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-03-28 14:51:30', 0, NULL),
(47, 31, 'Risk Flag', 'Dashboard Alert', '5 students have low attendance', 1, '2026-03-28 15:02:33', 'dashboard_alerts', NULL, '2026-03-28 14:51:30', 0, NULL),
(48, 28, 'Announcement', 'test post', 'test', 0, NULL, 'announcements', 61, '2026-03-28 15:19:08', 0, NULL),
(49, 27, 'Risk Flag', 'Dashboard Alert', '6 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-03-28 15:19:47', 0, NULL),
(50, 27, 'Risk Flag', 'Dashboard Alert', '5 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-03-28 15:19:47', 0, NULL),
(51, 1, 'Risk Flag', 'Dashboard Alert', '5 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-03-28 15:26:18', 0, NULL),
(52, 1, 'Risk Flag', 'Dashboard Alert', '6 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-03-28 15:26:40', 0, NULL),
(53, 1, 'Announcement', 'test', 'test', 0, NULL, 'announcements', 62, '2026-03-28 15:27:51', 0, NULL),
(54, 26, 'Announcement', 'test', 'test', 0, NULL, 'announcements', 62, '2026-03-28 15:27:51', 0, NULL),
(55, 27, 'Announcement', 'test', 'test', 0, NULL, 'announcements', 62, '2026-03-28 15:27:51', 0, NULL),
(56, 28, 'Announcement', 'test', 'test', 0, NULL, 'announcements', 62, '2026-03-28 15:27:51', 0, NULL),
(57, 29, 'Announcement', 'test', 'test', 1, '2026-04-21 21:07:36', 'announcements', 62, '2026-03-28 15:27:51', 0, NULL),
(58, 30, 'Announcement', 'test', 'test', 0, NULL, 'announcements', 62, '2026-03-28 15:27:51', 0, NULL),
(59, 31, 'Announcement', 'test', 'test', 0, NULL, 'announcements', 62, '2026-03-28 15:27:51', 0, NULL),
(60, 1, 'Announcement', 'test', 'test', 0, NULL, 'announcements', 63, '2026-03-28 15:42:49', 0, NULL),
(61, 26, 'Announcement', 'test', 'test', 0, NULL, 'announcements', 63, '2026-03-28 15:42:49', 0, NULL),
(62, 27, 'Announcement', 'test', 'test', 0, NULL, 'announcements', 63, '2026-03-28 15:42:49', 0, NULL),
(63, 28, 'Announcement', 'test', 'test', 0, NULL, 'announcements', 63, '2026-03-28 15:42:49', 0, NULL),
(64, 29, 'Announcement', 'test', 'test', 1, '2026-04-21 21:07:29', 'announcements', 63, '2026-03-28 15:42:49', 0, NULL),
(65, 30, 'Announcement', 'test', 'test', 0, NULL, 'announcements', 63, '2026-03-28 15:42:49', 0, NULL),
(66, 31, 'Announcement', 'test', 'test', 0, NULL, 'announcements', 63, '2026-03-28 15:42:49', 0, NULL),
(67, 1, 'Announcement', 'TEST', 'Privacy Policy  \nLast updated: March 28, 2026\n\nNumen in the Sewer respects your privacy.\n\nWhat we collect  \n- Basic device/app info (such as device type, OS version, app version)  \n- Crash and performance data (to fix bugs and improve the game)\n\nWhat we do with it  \n- Keep the game working  \n- Improve performance and stability  \n- Fix errors and prevent abuse\n\nWhat we don’t do  \n- We do not sell your personal information.\n\nThird-party services  \nThe game may use services like Google Play Services, analytics, crash reporting, or ads.  \nThese services may collect data according to their own privacy policies.\n\nChildren  \nThe game is not intended for children under the age required by local law unless stated otherwise.\n\nSecurity  \nWe use reasonable steps to protect data, but no system is completely secure.\n\nChanges  \nWe may update this policy. Updates will be posted with a new “Last updated” date.\n\nContact  \nEmail: belonoacshaun@gmail.com\nDeveloper: shn.studio', 0, NULL, 'announcements', 64, '2026-03-28 22:29:53', 0, NULL),
(68, 26, 'Announcement', 'TEST', 'Privacy Policy  \nLast updated: March 28, 2026\n\nNumen in the Sewer respects your privacy.\n\nWhat we collect  \n- Basic device/app info (such as device type, OS version, app version)  \n- Crash and performance data (to fix bugs and improve the game)\n\nWhat we do with it  \n- Keep the game working  \n- Improve performance and stability  \n- Fix errors and prevent abuse\n\nWhat we don’t do  \n- We do not sell your personal information.\n\nThird-party services  \nThe game may use services like Google Play Services, analytics, crash reporting, or ads.  \nThese services may collect data according to their own privacy policies.\n\nChildren  \nThe game is not intended for children under the age required by local law unless stated otherwise.\n\nSecurity  \nWe use reasonable steps to protect data, but no system is completely secure.\n\nChanges  \nWe may update this policy. Updates will be posted with a new “Last updated” date.\n\nContact  \nEmail: belonoacshaun@gmail.com\nDeveloper: shn.studio', 0, NULL, 'announcements', 64, '2026-03-28 22:29:53', 0, NULL),
(69, 27, 'Announcement', 'TEST', 'Privacy Policy  \nLast updated: March 28, 2026\n\nNumen in the Sewer respects your privacy.\n\nWhat we collect  \n- Basic device/app info (such as device type, OS version, app version)  \n- Crash and performance data (to fix bugs and improve the game)\n\nWhat we do with it  \n- Keep the game working  \n- Improve performance and stability  \n- Fix errors and prevent abuse\n\nWhat we don’t do  \n- We do not sell your personal information.\n\nThird-party services  \nThe game may use services like Google Play Services, analytics, crash reporting, or ads.  \nThese services may collect data according to their own privacy policies.\n\nChildren  \nThe game is not intended for children under the age required by local law unless stated otherwise.\n\nSecurity  \nWe use reasonable steps to protect data, but no system is completely secure.\n\nChanges  \nWe may update this policy. Updates will be posted with a new “Last updated” date.\n\nContact  \nEmail: belonoacshaun@gmail.com\nDeveloper: shn.studio', 0, NULL, 'announcements', 64, '2026-03-28 22:29:53', 0, NULL),
(70, 28, 'Announcement', 'TEST', 'Privacy Policy  \nLast updated: March 28, 2026\n\nNumen in the Sewer respects your privacy.\n\nWhat we collect  \n- Basic device/app info (such as device type, OS version, app version)  \n- Crash and performance data (to fix bugs and improve the game)\n\nWhat we do with it  \n- Keep the game working  \n- Improve performance and stability  \n- Fix errors and prevent abuse\n\nWhat we don’t do  \n- We do not sell your personal information.\n\nThird-party services  \nThe game may use services like Google Play Services, analytics, crash reporting, or ads.  \nThese services may collect data according to their own privacy policies.\n\nChildren  \nThe game is not intended for children under the age required by local law unless stated otherwise.\n\nSecurity  \nWe use reasonable steps to protect data, but no system is completely secure.\n\nChanges  \nWe may update this policy. Updates will be posted with a new “Last updated” date.\n\nContact  \nEmail: belonoacshaun@gmail.com\nDeveloper: shn.studio', 0, NULL, 'announcements', 64, '2026-03-28 22:29:53', 0, NULL),
(71, 29, 'Announcement', 'TEST', 'Privacy Policy  \nLast updated: March 28, 2026\n\nNumen in the Sewer respects your privacy.\n\nWhat we collect  \n- Basic device/app info (such as device type, OS version, app version)  \n- Crash and performance data (to fix bugs and improve the game)\n\nWhat we do with it  \n- Keep the game working  \n- Improve performance and stability  \n- Fix errors and prevent abuse\n\nWhat we don’t do  \n- We do not sell your personal information.\n\nThird-party services  \nThe game may use services like Google Play Services, analytics, crash reporting, or ads.  \nThese services may collect data according to their own privacy policies.\n\nChildren  \nThe game is not intended for children under the age required by local law unless stated otherwise.\n\nSecurity  \nWe use reasonable steps to protect data, but no system is completely secure.\n\nChanges  \nWe may update this policy. Updates will be posted with a new “Last updated” date.\n\nContact  \nEmail: belonoacshaun@gmail.com\nDeveloper: shn.studio', 1, '2026-04-21 21:07:20', 'announcements', 64, '2026-03-28 22:29:53', 0, NULL),
(72, 30, 'Announcement', 'TEST', 'Privacy Policy  \nLast updated: March 28, 2026\n\nNumen in the Sewer respects your privacy.\n\nWhat we collect  \n- Basic device/app info (such as device type, OS version, app version)  \n- Crash and performance data (to fix bugs and improve the game)\n\nWhat we do with it  \n- Keep the game working  \n- Improve performance and stability  \n- Fix errors and prevent abuse\n\nWhat we don’t do  \n- We do not sell your personal information.\n\nThird-party services  \nThe game may use services like Google Play Services, analytics, crash reporting, or ads.  \nThese services may collect data according to their own privacy policies.\n\nChildren  \nThe game is not intended for children under the age required by local law unless stated otherwise.\n\nSecurity  \nWe use reasonable steps to protect data, but no system is completely secure.\n\nChanges  \nWe may update this policy. Updates will be posted with a new “Last updated” date.\n\nContact  \nEmail: belonoacshaun@gmail.com\nDeveloper: shn.studio', 1, '2026-04-21 11:04:43', 'announcements', 64, '2026-03-28 22:29:53', 0, NULL),
(73, 31, 'Announcement', 'TEST', 'Privacy Policy  \nLast updated: March 28, 2026\n\nNumen in the Sewer respects your privacy.\n\nWhat we collect  \n- Basic device/app info (such as device type, OS version, app version)  \n- Crash and performance data (to fix bugs and improve the game)\n\nWhat we do with it  \n- Keep the game working  \n- Improve performance and stability  \n- Fix errors and prevent abuse\n\nWhat we don’t do  \n- We do not sell your personal information.\n\nThird-party services  \nThe game may use services like Google Play Services, analytics, crash reporting, or ads.  \nThese services may collect data according to their own privacy policies.\n\nChildren  \nThe game is not intended for children under the age required by local law unless stated otherwise.\n\nSecurity  \nWe use reasonable steps to protect data, but no system is completely secure.\n\nChanges  \nWe may update this policy. Updates will be posted with a new “Last updated” date.\n\nContact  \nEmail: belonoacshaun@gmail.com\nDeveloper: shn.studio', 0, NULL, 'announcements', 64, '2026-03-28 22:29:53', 0, NULL),
(74, 1, 'Risk Flag', 'Dashboard Alert', '6 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-03-29 15:00:08', 0, NULL),
(75, 1, 'Risk Flag', 'Dashboard Alert', '5 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-03-29 15:00:08', 0, NULL),
(76, 1, 'Risk Flag', 'Dashboard Alert', '4 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-03-29 23:24:35', 0, NULL),
(77, 1, 'Announcement', 'test', 'test', 0, NULL, 'announcements', 65, '2026-03-29 23:25:02', 0, NULL),
(78, 26, 'Announcement', 'test', 'test', 0, NULL, 'announcements', 65, '2026-03-29 23:25:02', 0, NULL),
(79, 27, 'Announcement', 'test', 'test', 0, NULL, 'announcements', 65, '2026-03-29 23:25:02', 0, NULL),
(80, 28, 'Announcement', 'test', 'test', 1, '2026-04-22 20:39:51', 'announcements', 65, '2026-03-29 23:25:02', 0, NULL),
(81, 29, 'Announcement', 'test', 'test', 1, '2026-04-21 21:07:25', 'announcements', 65, '2026-03-29 23:25:02', 0, NULL),
(82, 30, 'Announcement', 'test', 'test', 1, '2026-04-21 11:04:31', 'announcements', 65, '2026-03-29 23:25:02', 0, NULL),
(83, 31, 'Announcement', 'test', 'test', 0, NULL, 'announcements', 65, '2026-03-29 23:25:02', 0, NULL),
(84, 1, 'Risk Flag', 'Dashboard Alert', '6 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-04-16 12:46:51', 0, NULL),
(85, 1, 'Risk Flag', 'Dashboard Alert', '4 students have low attendance', 1, '2026-04-16 12:48:14', 'dashboard_alerts', NULL, '2026-04-16 12:46:51', 0, NULL),
(86, 27, 'Risk Flag', 'Dashboard Alert', '6 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-04-16 16:33:38', 0, NULL),
(87, 27, 'Risk Flag', 'Dashboard Alert', '4 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-04-16 16:33:38', 0, NULL),
(88, 1, 'Risk Flag', 'Dashboard Alert', '6 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-04-19 19:20:32', 0, NULL),
(89, 1, 'Risk Flag', 'Dashboard Alert', '4 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-04-19 19:20:32', 0, NULL),
(90, 30, 'Risk Flag', 'Dashboard Alert', '6 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-04-21 08:20:44', 0, NULL),
(91, 30, 'Risk Flag', 'Dashboard Alert', '4 students have low attendance', 1, '2026-04-21 19:40:25', 'dashboard_alerts', NULL, '2026-04-21 08:20:44', 0, NULL),
(92, 29, 'Risk Flag', 'Dashboard Alert', '6 students identified as at-risk', 1, '2026-04-21 21:07:12', 'dashboard_alerts', NULL, '2026-04-21 19:25:05', 0, NULL),
(93, 29, 'Risk Flag', 'Dashboard Alert', '4 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-04-21 19:25:05', 0, NULL),
(94, 35, 'Risk Flag', 'Dashboard Alert', '6 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-04-21 22:28:30', 0, NULL),
(95, 35, 'Risk Flag', 'Dashboard Alert', '4 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-04-21 22:28:30', 0, NULL),
(96, 35, 'Risk Flag', 'Dashboard Alert', '6 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-04-22 00:05:25', 0, NULL),
(97, 35, 'Risk Flag', 'Dashboard Alert', '4 students have low attendance', 1, '2026-04-22 03:15:35', 'dashboard_alerts', NULL, '2026-04-22 00:05:25', 0, NULL),
(98, 30, 'Risk Flag', 'Dashboard Alert', '6 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-04-22 00:06:07', 0, NULL),
(99, 30, 'Risk Flag', 'Dashboard Alert', '4 students have low attendance', 1, '2026-04-22 00:27:53', 'dashboard_alerts', NULL, '2026-04-22 00:06:07', 0, NULL),
(100, 29, 'Risk Flag', 'Dashboard Alert', '6 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-04-22 00:06:28', 0, NULL),
(101, 29, 'Risk Flag', 'Dashboard Alert', '4 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-04-22 00:06:28', 0, NULL),
(102, 37, 'Risk Flag', 'Dashboard Alert', '6 students identified as at-risk', 1, '2026-04-22 02:32:18', 'dashboard_alerts', NULL, '2026-04-22 02:29:17', 0, NULL),
(103, 37, 'Risk Flag', 'Dashboard Alert', '4 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-04-22 02:29:17', 0, NULL),
(104, 1, 'Announcement', 'hi', 'hello', 0, NULL, 'announcements', 66, '2026-04-22 03:57:16', 0, NULL),
(105, 26, 'Announcement', 'hi', 'hello', 0, NULL, 'announcements', 66, '2026-04-22 03:57:16', 0, NULL),
(106, 27, 'Announcement', 'hi', 'hello', 0, NULL, 'announcements', 66, '2026-04-22 03:57:16', 0, NULL),
(107, 28, 'Announcement', 'hi', 'hello', 1, '2026-04-24 16:20:58', 'announcements', 66, '2026-04-22 03:57:16', 0, NULL),
(108, 29, 'Announcement', 'hi', 'hello', 0, NULL, 'announcements', 66, '2026-04-22 03:57:16', 0, NULL),
(109, 30, 'Announcement', 'hi', 'hello', 1, '2026-04-22 06:33:00', 'announcements', 66, '2026-04-22 03:57:16', 0, NULL),
(110, 31, 'Announcement', 'hi', 'hello', 0, NULL, 'announcements', 66, '2026-04-22 03:57:16', 0, NULL),
(111, 32, 'Announcement', 'hi', 'hello', 0, NULL, 'announcements', 66, '2026-04-22 03:57:16', 0, NULL),
(112, 33, 'Announcement', 'hi', 'hello', 0, NULL, 'announcements', 66, '2026-04-22 03:57:16', 0, NULL),
(113, 34, 'Announcement', 'hi', 'hello', 0, NULL, 'announcements', 66, '2026-04-22 03:57:16', 0, NULL),
(114, 35, 'Announcement', 'hi', 'hello', 1, '2026-04-22 03:57:20', 'announcements', 66, '2026-04-22 03:57:16', 0, NULL),
(115, 36, 'Announcement', 'hi', 'hello', 0, NULL, 'announcements', 66, '2026-04-22 03:57:16', 0, NULL),
(116, 37, 'Announcement', 'hi', 'hello', 1, '2026-04-22 06:16:48', 'announcements', 66, '2026-04-22 03:57:16', 0, NULL),
(117, 1, 'Risk Flag', 'At-Risk Learner', 'Medina, Cloudenry Blaan Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 20.00%', 0, NULL, 'risk_assessments', 2, '2026-04-22 04:21:45', 0, NULL),
(118, 26, 'Risk Flag', 'At-Risk Learner', 'Medina, Cloudenry Blaan Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 20.00%', 0, NULL, 'risk_assessments', 2, '2026-04-22 04:21:45', 0, NULL),
(119, 27, 'Risk Flag', 'At-Risk Learner', 'Medina, Cloudenry Blaan Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 20.00%', 0, NULL, 'risk_assessments', 2, '2026-04-22 04:21:45', 0, NULL),
(120, 30, 'Risk Flag', 'At-Risk Learner', 'Medina, Cloudenry Blaan Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 20.00%', 0, NULL, 'risk_assessments', 2, '2026-04-22 04:21:45', 0, NULL),
(121, 31, 'Risk Flag', 'At-Risk Learner', 'Medina, Cloudenry Blaan Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 20.00%', 0, NULL, 'risk_assessments', 2, '2026-04-22 04:21:45', 0, NULL),
(122, 1, 'Risk Flag', 'At-Risk Learner', 'Bords, Bhala T Grade 10 (test grade 10) flagged as High for FIRST GRADING. Incomplete Grades: Encoded 7/8 subjects', 0, NULL, 'risk_assessments', 3, '2026-04-22 04:21:45', 0, NULL),
(123, 26, 'Risk Flag', 'At-Risk Learner', 'Bords, Bhala T Grade 10 (test grade 10) flagged as High for FIRST GRADING. Incomplete Grades: Encoded 7/8 subjects', 0, NULL, 'risk_assessments', 3, '2026-04-22 04:21:45', 0, NULL),
(124, 27, 'Risk Flag', 'At-Risk Learner', 'Bords, Bhala T Grade 10 (test grade 10) flagged as High for FIRST GRADING. Incomplete Grades: Encoded 7/8 subjects', 0, NULL, 'risk_assessments', 3, '2026-04-22 04:21:45', 0, NULL),
(125, 30, 'Risk Flag', 'At-Risk Learner', 'Bords, Bhala T Grade 10 (test grade 10) flagged as High for FIRST GRADING. Incomplete Grades: Encoded 7/8 subjects', 0, NULL, 'risk_assessments', 3, '2026-04-22 04:21:45', 0, NULL),
(126, 31, 'Risk Flag', 'At-Risk Learner', 'Bords, Bhala T Grade 10 (test grade 10) flagged as High for FIRST GRADING. Incomplete Grades: Encoded 7/8 subjects', 0, NULL, 'risk_assessments', 3, '2026-04-22 04:21:45', 0, NULL),
(127, 1, 'Risk Flag', 'At-Risk Learner', 'Kulas, Pitok Batolata Luz Grade 1 (Section Gemini) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 60.00%', 0, NULL, 'risk_assessments', 6, '2026-04-22 04:21:45', 0, NULL),
(128, 26, 'Risk Flag', 'At-Risk Learner', 'Kulas, Pitok Batolata Luz Grade 1 (Section Gemini) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 60.00%', 0, NULL, 'risk_assessments', 6, '2026-04-22 04:21:45', 0, NULL),
(129, 27, 'Risk Flag', 'At-Risk Learner', 'Kulas, Pitok Batolata Luz Grade 1 (Section Gemini) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 60.00%', 0, NULL, 'risk_assessments', 6, '2026-04-22 04:21:45', 0, NULL),
(130, 30, 'Risk Flag', 'At-Risk Learner', 'Kulas, Pitok Batolata Luz Grade 1 (Section Gemini) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 60.00%', 0, NULL, 'risk_assessments', 6, '2026-04-22 04:21:45', 0, NULL),
(131, 31, 'Risk Flag', 'At-Risk Learner', 'Kulas, Pitok Batolata Luz Grade 1 (Section Gemini) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 60.00%', 0, NULL, 'risk_assessments', 6, '2026-04-22 04:21:45', 0, NULL),
(132, 1, 'Risk Flag', 'At-Risk Learner', 'Hagorn, Marya Pato Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 40.00%', 0, NULL, 'risk_assessments', 7, '2026-04-22 04:21:45', 0, NULL),
(133, 26, 'Risk Flag', 'At-Risk Learner', 'Hagorn, Marya Pato Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 40.00%', 0, NULL, 'risk_assessments', 7, '2026-04-22 04:21:45', 0, NULL),
(134, 27, 'Risk Flag', 'At-Risk Learner', 'Hagorn, Marya Pato Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 40.00%', 0, NULL, 'risk_assessments', 7, '2026-04-22 04:21:45', 0, NULL),
(135, 30, 'Risk Flag', 'At-Risk Learner', 'Hagorn, Marya Pato Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 40.00%', 0, NULL, 'risk_assessments', 7, '2026-04-22 04:21:45', 0, NULL),
(136, 31, 'Risk Flag', 'At-Risk Learner', 'Hagorn, Marya Pato Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 40.00%', 0, NULL, 'risk_assessments', 7, '2026-04-22 04:21:45', 0, NULL),
(137, 1, 'Risk Flag', 'At-Risk Learner', 'hello, test name test Sr. Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 40.00%', 0, NULL, 'risk_assessments', 8, '2026-04-22 04:21:45', 0, NULL),
(138, 26, 'Risk Flag', 'At-Risk Learner', 'hello, test name test Sr. Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 40.00%', 0, NULL, 'risk_assessments', 8, '2026-04-22 04:21:45', 0, NULL),
(139, 27, 'Risk Flag', 'At-Risk Learner', 'hello, test name test Sr. Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 40.00%', 0, NULL, 'risk_assessments', 8, '2026-04-22 04:21:45', 0, NULL),
(140, 30, 'Risk Flag', 'At-Risk Learner', 'hello, test name test Sr. Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 40.00%', 0, NULL, 'risk_assessments', 8, '2026-04-22 04:21:45', 0, NULL),
(141, 31, 'Risk Flag', 'At-Risk Learner', 'hello, test name test Sr. Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 40.00%', 0, NULL, 'risk_assessments', 8, '2026-04-22 04:21:45', 0, NULL),
(142, 1, 'Risk Flag', 'At-Risk Learner', 'Learner2, Test Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 10, '2026-04-22 04:21:45', 0, NULL),
(143, 26, 'Risk Flag', 'At-Risk Learner', 'Learner2, Test Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 10, '2026-04-22 04:21:45', 0, NULL),
(144, 27, 'Risk Flag', 'At-Risk Learner', 'Learner2, Test Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 10, '2026-04-22 04:21:45', 0, NULL),
(145, 30, 'Risk Flag', 'At-Risk Learner', 'Learner2, Test Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 10, '2026-04-22 04:21:45', 0, NULL),
(146, 31, 'Risk Flag', 'At-Risk Learner', 'Learner2, Test Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 10, '2026-04-22 04:21:45', 0, NULL),
(147, 1, 'Risk Flag', 'At-Risk Learner', 'Visible, UI Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 11, '2026-04-22 04:21:45', 0, NULL),
(148, 26, 'Risk Flag', 'At-Risk Learner', 'Visible, UI Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 11, '2026-04-22 04:21:45', 0, NULL),
(149, 27, 'Risk Flag', 'At-Risk Learner', 'Visible, UI Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 11, '2026-04-22 04:21:45', 0, NULL),
(150, 30, 'Risk Flag', 'At-Risk Learner', 'Visible, UI Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 11, '2026-04-22 04:21:45', 0, NULL),
(151, 31, 'Risk Flag', 'At-Risk Learner', 'Visible, UI Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 11, '2026-04-22 04:21:45', 0, NULL),
(152, 1, 'Risk Flag', 'At-Risk Learner', 'Created, Reg Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period | Chronic Absence: Absence rate: 33.33%', 0, NULL, 'risk_assessments', 12, '2026-04-22 04:21:45', 0, NULL),
(153, 26, 'Risk Flag', 'At-Risk Learner', 'Created, Reg Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period | Chronic Absence: Absence rate: 33.33%', 0, NULL, 'risk_assessments', 12, '2026-04-22 04:21:45', 0, NULL),
(154, 27, 'Risk Flag', 'At-Risk Learner', 'Created, Reg Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period | Chronic Absence: Absence rate: 33.33%', 0, NULL, 'risk_assessments', 12, '2026-04-22 04:21:45', 0, NULL),
(155, 30, 'Risk Flag', 'At-Risk Learner', 'Created, Reg Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period | Chronic Absence: Absence rate: 33.33%', 1, '2026-04-22 06:18:28', 'risk_assessments', 12, '2026-04-22 04:21:45', 0, NULL),
(156, 31, 'Risk Flag', 'At-Risk Learner', 'Created, Reg Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period | Chronic Absence: Absence rate: 33.33%', 0, NULL, 'risk_assessments', 12, '2026-04-22 04:21:45', 0, NULL),
(157, 1, 'Risk Flag', 'At-Risk Learner', 'awdawd, awdawdaw dawdawd Grade 10 (test grade 10) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 13, '2026-04-22 04:21:45', 0, NULL),
(158, 26, 'Risk Flag', 'At-Risk Learner', 'awdawd, awdawdaw dawdawd Grade 10 (test grade 10) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 13, '2026-04-22 04:21:45', 0, NULL),
(159, 27, 'Risk Flag', 'At-Risk Learner', 'awdawd, awdawdaw dawdawd Grade 10 (test grade 10) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 13, '2026-04-22 04:21:45', 0, NULL),
(160, 30, 'Risk Flag', 'At-Risk Learner', 'awdawd, awdawdaw dawdawd Grade 10 (test grade 10) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 1, '2026-04-22 19:16:15', 'risk_assessments', 13, '2026-04-22 04:21:45', 0, NULL),
(161, 31, 'Risk Flag', 'At-Risk Learner', 'awdawd, awdawdaw dawdawd Grade 10 (test grade 10) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 13, '2026-04-22 04:21:45', 0, NULL),
(162, 30, 'Risk Flag', 'Dashboard Alert', '9 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-04-22 04:25:22', 0, NULL),
(163, 30, 'Risk Flag', 'Dashboard Alert', '9 students have low attendance', 1, '2026-04-22 19:16:13', 'dashboard_alerts', NULL, '2026-04-22 04:25:22', 0, NULL),
(164, 37, 'Risk Flag', 'Dashboard Alert', '9 students identified as at-risk', 1, '2026-04-22 06:16:40', 'dashboard_alerts', NULL, '2026-04-22 06:13:35', 0, NULL),
(165, 37, 'Risk Flag', 'Dashboard Alert', '9 students have low attendance', 1, '2026-04-22 09:59:44', 'dashboard_alerts', NULL, '2026-04-22 06:13:35', 0, NULL),
(166, 35, 'Risk Flag', 'Dashboard Alert', '9 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-04-22 10:00:31', 0, NULL),
(167, 35, 'Risk Flag', 'Dashboard Alert', '9 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-04-22 10:00:31', 0, NULL),
(168, 1, 'Risk Flag', 'At-Risk Learner', 'Kulas, Pitok Batolata Luz Grade 1 (Section Gemini) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 50.00%', 0, NULL, 'risk_assessments', 6, '2026-04-22 19:16:16', 0, NULL),
(169, 26, 'Risk Flag', 'At-Risk Learner', 'Kulas, Pitok Batolata Luz Grade 1 (Section Gemini) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 50.00%', 0, NULL, 'risk_assessments', 6, '2026-04-22 19:16:16', 0, NULL),
(170, 27, 'Risk Flag', 'At-Risk Learner', 'Kulas, Pitok Batolata Luz Grade 1 (Section Gemini) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 50.00%', 0, NULL, 'risk_assessments', 6, '2026-04-22 19:16:16', 0, NULL),
(171, 30, 'Risk Flag', 'At-Risk Learner', 'Kulas, Pitok Batolata Luz Grade 1 (Section Gemini) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 50.00%', 0, NULL, 'risk_assessments', 6, '2026-04-22 19:16:16', 0, NULL),
(172, 31, 'Risk Flag', 'At-Risk Learner', 'Kulas, Pitok Batolata Luz Grade 1 (Section Gemini) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 50.00%', 0, NULL, 'risk_assessments', 6, '2026-04-22 19:16:16', 0, NULL),
(173, 1, 'Risk Flag', 'At-Risk Learner', 'Estroga, Johnbert Test IV Grade 1 (Gold) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 14, '2026-04-22 19:16:16', 0, NULL),
(174, 26, 'Risk Flag', 'At-Risk Learner', 'Estroga, Johnbert Test IV Grade 1 (Gold) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 14, '2026-04-22 19:16:16', 0, NULL),
(175, 27, 'Risk Flag', 'At-Risk Learner', 'Estroga, Johnbert Test IV Grade 1 (Gold) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 14, '2026-04-22 19:16:16', 0, NULL),
(176, 30, 'Risk Flag', 'At-Risk Learner', 'Estroga, Johnbert Test IV Grade 1 (Gold) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 14, '2026-04-22 19:16:16', 0, NULL),
(177, 31, 'Risk Flag', 'At-Risk Learner', 'Estroga, Johnbert Test IV Grade 1 (Gold) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 14, '2026-04-22 19:16:16', 0, NULL),
(178, 30, 'Risk Flag', 'Dashboard Alert', '10 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-04-22 19:16:50', 0, NULL),
(179, 30, 'Risk Flag', 'Dashboard Alert', '10 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-04-22 19:16:50', 0, NULL),
(180, 35, 'Risk Flag', 'Dashboard Alert', '10 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-04-22 20:11:45', 0, NULL),
(181, 35, 'Risk Flag', 'Dashboard Alert', '10 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-04-22 20:11:45', 0, NULL),
(182, 37, 'Risk Flag', 'Dashboard Alert', '10 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-04-22 20:49:30', 0, NULL),
(183, 37, 'Risk Flag', 'Dashboard Alert', '10 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-04-22 20:49:30', 0, NULL),
(184, 30, 'Risk Flag', 'Dashboard Alert', '10 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-04-23 19:58:23', 0, NULL),
(185, 30, 'Risk Flag', 'Dashboard Alert', '10 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-04-23 19:58:23', 0, NULL),
(186, 30, 'Risk Flag', 'Dashboard Alert', '10 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-04-24 07:17:04', 0, NULL),
(187, 30, 'Risk Flag', 'Dashboard Alert', '10 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-04-24 07:17:04', 0, NULL),
(188, 35, 'Risk Flag', 'Dashboard Alert', '10 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-04-24 07:17:36', 0, NULL),
(189, 35, 'Risk Flag', 'Dashboard Alert', '10 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-04-24 07:17:36', 0, NULL),
(190, 37, 'Risk Flag', 'Dashboard Alert', '10 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-04-24 16:20:22', 0, NULL),
(191, 37, 'Risk Flag', 'Dashboard Alert', '10 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-04-24 16:20:22', 0, NULL),
(192, 1, 'Announcement', 'awdasd', 'asdasdasdass', 0, NULL, 'announcements', 67, '2026-04-24 16:31:26', 0, NULL),
(193, 26, 'Announcement', 'awdasd', 'asdasdasdass', 0, NULL, 'announcements', 67, '2026-04-24 16:31:26', 0, NULL),
(194, 27, 'Announcement', 'awdasd', 'asdasdasdass', 0, NULL, 'announcements', 67, '2026-04-24 16:31:26', 0, NULL),
(195, 29, 'Announcement', 'awdasd', 'asdasdasdass', 0, NULL, 'announcements', 67, '2026-04-24 16:31:26', 0, NULL),
(196, 30, 'Announcement', 'awdasd', 'asdasdasdass', 1, '2026-04-24 16:31:29', 'announcements', 67, '2026-04-24 16:31:26', 0, NULL),
(197, 31, 'Announcement', 'awdasd', 'asdasdasdass', 0, NULL, 'announcements', 67, '2026-04-24 16:31:26', 0, NULL),
(198, 32, 'Announcement', 'awdasd', 'asdasdasdass', 0, NULL, 'announcements', 67, '2026-04-24 16:31:26', 0, NULL),
(199, 33, 'Announcement', 'awdasd', 'asdasdasdass', 0, NULL, 'announcements', 67, '2026-04-24 16:31:26', 0, NULL),
(200, 34, 'Announcement', 'awdasd', 'asdasdasdass', 0, NULL, 'announcements', 67, '2026-04-24 16:31:26', 0, NULL),
(201, 35, 'Announcement', 'awdasd', 'asdasdasdass', 1, '2026-04-24 19:46:24', 'announcements', 67, '2026-04-24 16:31:26', 0, NULL),
(202, 36, 'Announcement', 'awdasd', 'asdasdasdass', 0, NULL, 'announcements', 67, '2026-04-24 16:31:26', 0, NULL),
(203, 37, 'Announcement', 'awdasd', 'asdasdasdass', 0, NULL, 'announcements', 67, '2026-04-24 16:31:26', 0, NULL),
(204, 38, 'Announcement', 'awdasd', 'asdasdasdass', 0, NULL, 'announcements', 67, '2026-04-24 16:31:26', 0, NULL),
(205, 1, 'Risk Flag', 'At-Risk Learner', 'Bords, Bhala T Grade 10 (test grade 10) flagged as High for FIRST GRADING. Incomplete Grades: Encoded 7/8 subjects', 0, NULL, 'risk_assessments', 3, '2026-04-24 16:35:04', 0, NULL),
(206, 26, 'Risk Flag', 'At-Risk Learner', 'Bords, Bhala T Grade 10 (test grade 10) flagged as High for FIRST GRADING. Incomplete Grades: Encoded 7/8 subjects', 0, NULL, 'risk_assessments', 3, '2026-04-24 16:35:04', 0, NULL),
(207, 27, 'Risk Flag', 'At-Risk Learner', 'Bords, Bhala T Grade 10 (test grade 10) flagged as High for FIRST GRADING. Incomplete Grades: Encoded 7/8 subjects', 0, NULL, 'risk_assessments', 3, '2026-04-24 16:35:04', 0, NULL),
(208, 30, 'Risk Flag', 'At-Risk Learner', 'Bords, Bhala T Grade 10 (test grade 10) flagged as High for FIRST GRADING. Incomplete Grades: Encoded 7/8 subjects', 0, NULL, 'risk_assessments', 3, '2026-04-24 16:35:04', 0, NULL),
(209, 31, 'Risk Flag', 'At-Risk Learner', 'Bords, Bhala T Grade 10 (test grade 10) flagged as High for FIRST GRADING. Incomplete Grades: Encoded 7/8 subjects', 0, NULL, 'risk_assessments', 3, '2026-04-24 16:35:04', 0, NULL),
(210, 1, 'Risk Flag', 'At-Risk Learner', 'Medina, Cloudenry Blaan Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 20.00%', 0, NULL, 'risk_assessments', 2, '2026-04-24 16:35:04', 0, NULL),
(211, 26, 'Risk Flag', 'At-Risk Learner', 'Medina, Cloudenry Blaan Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 20.00%', 0, NULL, 'risk_assessments', 2, '2026-04-24 16:35:04', 0, NULL),
(212, 27, 'Risk Flag', 'At-Risk Learner', 'Medina, Cloudenry Blaan Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 20.00%', 0, NULL, 'risk_assessments', 2, '2026-04-24 16:35:04', 0, NULL),
(213, 30, 'Risk Flag', 'At-Risk Learner', 'Medina, Cloudenry Blaan Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 20.00%', 0, NULL, 'risk_assessments', 2, '2026-04-24 16:35:04', 0, NULL),
(214, 31, 'Risk Flag', 'At-Risk Learner', 'Medina, Cloudenry Blaan Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 20.00%', 0, NULL, 'risk_assessments', 2, '2026-04-24 16:35:04', 0, NULL),
(215, 1, 'Risk Flag', 'At-Risk Learner', 'Kulas, Pitok Batolata Luz Grade 1 (Section Gemini) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 50.00%', 0, NULL, 'risk_assessments', 6, '2026-04-24 16:35:04', 0, NULL),
(216, 26, 'Risk Flag', 'At-Risk Learner', 'Kulas, Pitok Batolata Luz Grade 1 (Section Gemini) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 50.00%', 0, NULL, 'risk_assessments', 6, '2026-04-24 16:35:04', 0, NULL),
(217, 27, 'Risk Flag', 'At-Risk Learner', 'Kulas, Pitok Batolata Luz Grade 1 (Section Gemini) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 50.00%', 0, NULL, 'risk_assessments', 6, '2026-04-24 16:35:04', 0, NULL),
(218, 30, 'Risk Flag', 'At-Risk Learner', 'Kulas, Pitok Batolata Luz Grade 1 (Section Gemini) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 50.00%', 1, '2026-04-24 20:42:19', 'risk_assessments', 6, '2026-04-24 16:35:04', 0, NULL),
(219, 31, 'Risk Flag', 'At-Risk Learner', 'Kulas, Pitok Batolata Luz Grade 1 (Section Gemini) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 50.00%', 0, NULL, 'risk_assessments', 6, '2026-04-24 16:35:04', 0, NULL),
(220, 1, 'Risk Flag', 'At-Risk Learner', 'Hagorn, Marya Pato Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 40.00%', 0, NULL, 'risk_assessments', 7, '2026-04-24 16:35:04', 0, NULL),
(221, 26, 'Risk Flag', 'At-Risk Learner', 'Hagorn, Marya Pato Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 40.00%', 0, NULL, 'risk_assessments', 7, '2026-04-24 16:35:04', 0, NULL),
(222, 27, 'Risk Flag', 'At-Risk Learner', 'Hagorn, Marya Pato Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 40.00%', 0, NULL, 'risk_assessments', 7, '2026-04-24 16:35:04', 0, NULL),
(223, 30, 'Risk Flag', 'At-Risk Learner', 'Hagorn, Marya Pato Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 40.00%', 0, NULL, 'risk_assessments', 7, '2026-04-24 16:35:04', 0, NULL),
(224, 31, 'Risk Flag', 'At-Risk Learner', 'Hagorn, Marya Pato Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 40.00%', 0, NULL, 'risk_assessments', 7, '2026-04-24 16:35:04', 0, NULL),
(225, 1, 'Risk Flag', 'At-Risk Learner', 'hello, test name test Sr. Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 40.00%', 0, NULL, 'risk_assessments', 8, '2026-04-24 16:35:04', 0, NULL),
(226, 26, 'Risk Flag', 'At-Risk Learner', 'hello, test name test Sr. Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 40.00%', 0, NULL, 'risk_assessments', 8, '2026-04-24 16:35:04', 0, NULL),
(227, 27, 'Risk Flag', 'At-Risk Learner', 'hello, test name test Sr. Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 40.00%', 0, NULL, 'risk_assessments', 8, '2026-04-24 16:35:04', 0, NULL),
(228, 30, 'Risk Flag', 'At-Risk Learner', 'hello, test name test Sr. Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 40.00%', 0, NULL, 'risk_assessments', 8, '2026-04-24 16:35:04', 0, NULL),
(229, 31, 'Risk Flag', 'At-Risk Learner', 'hello, test name test Sr. Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 40.00%', 0, NULL, 'risk_assessments', 8, '2026-04-24 16:35:04', 0, NULL),
(230, 1, 'Risk Flag', 'At-Risk Learner', 'Learner2, Test Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 10, '2026-04-24 16:35:04', 0, NULL),
(231, 26, 'Risk Flag', 'At-Risk Learner', 'Learner2, Test Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 10, '2026-04-24 16:35:04', 0, NULL),
(232, 27, 'Risk Flag', 'At-Risk Learner', 'Learner2, Test Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 10, '2026-04-24 16:35:04', 0, NULL),
(233, 30, 'Risk Flag', 'At-Risk Learner', 'Learner2, Test Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 10, '2026-04-24 16:35:04', 0, NULL),
(234, 31, 'Risk Flag', 'At-Risk Learner', 'Learner2, Test Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 10, '2026-04-24 16:35:04', 0, NULL),
(235, 1, 'Risk Flag', 'At-Risk Learner', 'Visible, UI Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 11, '2026-04-24 16:35:04', 0, NULL),
(236, 26, 'Risk Flag', 'At-Risk Learner', 'Visible, UI Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 11, '2026-04-24 16:35:04', 0, NULL),
(237, 27, 'Risk Flag', 'At-Risk Learner', 'Visible, UI Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 11, '2026-04-24 16:35:04', 0, NULL),
(238, 30, 'Risk Flag', 'At-Risk Learner', 'Visible, UI Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 11, '2026-04-24 16:35:04', 0, NULL),
(239, 31, 'Risk Flag', 'At-Risk Learner', 'Visible, UI Grade 1 (Section Gemini) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 11, '2026-04-24 16:35:04', 0, NULL),
(240, 1, 'Risk Flag', 'At-Risk Learner', 'Created, Reg Grade 1 (Section Gemini) flagged as High for FIRST GRADING. Incomplete Grades: Encoded 1/11 subjects | Chronic Absence: Absence rate: 25.00%', 0, NULL, 'risk_assessments', 12, '2026-04-24 16:35:04', 0, NULL),
(241, 26, 'Risk Flag', 'At-Risk Learner', 'Created, Reg Grade 1 (Section Gemini) flagged as High for FIRST GRADING. Incomplete Grades: Encoded 1/11 subjects | Chronic Absence: Absence rate: 25.00%', 0, NULL, 'risk_assessments', 12, '2026-04-24 16:35:04', 0, NULL),
(242, 27, 'Risk Flag', 'At-Risk Learner', 'Created, Reg Grade 1 (Section Gemini) flagged as High for FIRST GRADING. Incomplete Grades: Encoded 1/11 subjects | Chronic Absence: Absence rate: 25.00%', 0, NULL, 'risk_assessments', 12, '2026-04-24 16:35:04', 0, NULL),
(243, 30, 'Risk Flag', 'At-Risk Learner', 'Created, Reg Grade 1 (Section Gemini) flagged as High for FIRST GRADING. Incomplete Grades: Encoded 1/11 subjects | Chronic Absence: Absence rate: 25.00%', 0, NULL, 'risk_assessments', 12, '2026-04-24 16:35:04', 0, NULL),
(244, 31, 'Risk Flag', 'At-Risk Learner', 'Created, Reg Grade 1 (Section Gemini) flagged as High for FIRST GRADING. Incomplete Grades: Encoded 1/11 subjects | Chronic Absence: Absence rate: 25.00%', 0, NULL, 'risk_assessments', 12, '2026-04-24 16:35:04', 0, NULL),
(245, 1, 'Risk Flag', 'At-Risk Learner', 'awdawd, awdawdaw dawdawd Grade 10 (test grade 10) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 13, '2026-04-24 16:35:04', 0, NULL),
(246, 26, 'Risk Flag', 'At-Risk Learner', 'awdawd, awdawdaw dawdawd Grade 10 (test grade 10) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 13, '2026-04-24 16:35:04', 0, NULL),
(247, 27, 'Risk Flag', 'At-Risk Learner', 'awdawd, awdawdaw dawdawd Grade 10 (test grade 10) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 13, '2026-04-24 16:35:04', 0, NULL);
INSERT INTO `notifications` (`notification_id`, `user_id`, `notification_type`, `title`, `message`, `is_read`, `read_at`, `reference_table`, `reference_id`, `created_at`, `is_deleted`, `deleted_at`) VALUES
(248, 30, 'Risk Flag', 'At-Risk Learner', 'awdawd, awdawdaw dawdawd Grade 10 (test grade 10) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 13, '2026-04-24 16:35:04', 0, NULL),
(249, 31, 'Risk Flag', 'At-Risk Learner', 'awdawd, awdawdaw dawdawd Grade 10 (test grade 10) flagged as High for FIRST GRADING. No Encoded Grades: No quarterly grades encoded for this period', 0, NULL, 'risk_assessments', 13, '2026-04-24 16:35:04', 0, NULL),
(250, 1, 'Risk Flag', 'At-Risk Learner', 'Estroga, Johnbert Test IV Grade 1 (Gold) flagged as Critical for FIRST GRADING. Failing Quarterly Grade: Lowest quarterly grade: 74.05 | Failed Subject Final Grade: Lowest final grade: 74.05', 0, NULL, 'risk_assessments', 14, '2026-04-24 16:35:04', 0, NULL),
(251, 26, 'Risk Flag', 'At-Risk Learner', 'Estroga, Johnbert Test IV Grade 1 (Gold) flagged as Critical for FIRST GRADING. Failing Quarterly Grade: Lowest quarterly grade: 74.05 | Failed Subject Final Grade: Lowest final grade: 74.05', 0, NULL, 'risk_assessments', 14, '2026-04-24 16:35:04', 0, NULL),
(252, 27, 'Risk Flag', 'At-Risk Learner', 'Estroga, Johnbert Test IV Grade 1 (Gold) flagged as Critical for FIRST GRADING. Failing Quarterly Grade: Lowest quarterly grade: 74.05 | Failed Subject Final Grade: Lowest final grade: 74.05', 0, NULL, 'risk_assessments', 14, '2026-04-24 16:35:04', 0, NULL),
(253, 30, 'Risk Flag', 'At-Risk Learner', 'Estroga, Johnbert Test IV Grade 1 (Gold) flagged as Critical for FIRST GRADING. Failing Quarterly Grade: Lowest quarterly grade: 74.05 | Failed Subject Final Grade: Lowest final grade: 74.05', 0, NULL, 'risk_assessments', 14, '2026-04-24 16:35:04', 0, NULL),
(254, 31, 'Risk Flag', 'At-Risk Learner', 'Estroga, Johnbert Test IV Grade 1 (Gold) flagged as Critical for FIRST GRADING. Failing Quarterly Grade: Lowest quarterly grade: 74.05 | Failed Subject Final Grade: Lowest final grade: 74.05', 0, NULL, 'risk_assessments', 14, '2026-04-24 16:35:04', 0, NULL),
(255, 35, 'Risk Flag', 'Dashboard Alert', '9 students have low attendance', 1, '2026-04-24 19:46:22', 'dashboard_alerts', NULL, '2026-04-24 16:35:35', 0, NULL),
(256, 30, 'Risk Flag', 'Dashboard Alert', '9 students have low attendance', 1, '2026-04-24 20:42:06', 'dashboard_alerts', NULL, '2026-04-24 16:37:35', 0, NULL),
(257, 39, 'Risk Flag', 'Dashboard Alert', '10 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-04-24 16:50:43', 0, NULL),
(258, 39, 'Risk Flag', 'Dashboard Alert', '9 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-04-24 16:50:43', 0, NULL),
(259, 37, 'Risk Flag', 'Dashboard Alert', '9 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-04-24 16:52:58', 0, NULL),
(260, 29, 'Risk Flag', 'Dashboard Alert', '10 students identified as at-risk', 0, NULL, 'dashboard_alerts', NULL, '2026-04-24 17:01:41', 0, NULL),
(261, 29, 'Risk Flag', 'Dashboard Alert', '9 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-04-24 17:01:41', 0, NULL),
(262, 1, 'Announcement', 'asd', 'asd', 0, NULL, 'announcements', 68, '2026-04-24 18:34:44', 0, NULL),
(263, 26, 'Announcement', 'asd', 'asd', 0, NULL, 'announcements', 68, '2026-04-24 18:34:44', 0, NULL),
(264, 27, 'Announcement', 'asd', 'asd', 0, NULL, 'announcements', 68, '2026-04-24 18:34:44', 0, NULL),
(265, 29, 'Announcement', 'asd', 'asd', 0, NULL, 'announcements', 68, '2026-04-24 18:34:44', 0, NULL),
(266, 30, 'Announcement', 'asd', 'asd', 1, '2026-04-24 20:42:25', 'announcements', 68, '2026-04-24 18:34:44', 0, NULL),
(267, 31, 'Announcement', 'asd', 'asd', 0, NULL, 'announcements', 68, '2026-04-24 18:34:44', 0, NULL),
(268, 32, 'Announcement', 'asd', 'asd', 0, NULL, 'announcements', 68, '2026-04-24 18:34:44', 0, NULL),
(269, 33, 'Announcement', 'asd', 'asd', 0, NULL, 'announcements', 68, '2026-04-24 18:34:44', 0, NULL),
(270, 34, 'Announcement', 'asd', 'asd', 0, NULL, 'announcements', 68, '2026-04-24 18:34:44', 0, NULL),
(271, 35, 'Announcement', 'asd', 'asd', 0, NULL, 'announcements', 68, '2026-04-24 18:34:44', 0, NULL),
(272, 36, 'Announcement', 'asd', 'asd', 0, NULL, 'announcements', 68, '2026-04-24 18:34:44', 0, NULL),
(273, 37, 'Announcement', 'asd', 'asd', 0, NULL, 'announcements', 68, '2026-04-24 18:34:44', 0, NULL),
(274, 38, 'Announcement', 'asd', 'asd', 0, NULL, 'announcements', 68, '2026-04-24 18:34:44', 0, NULL),
(275, 39, 'Announcement', 'asd', 'asd', 0, NULL, 'announcements', 68, '2026-04-24 18:34:44', 0, NULL),
(276, 1, 'Announcement', 'asdasd', 'asdasd', 0, NULL, 'announcements', 69, '2026-04-24 18:57:22', 0, NULL),
(277, 26, 'Announcement', 'asdasd', 'asdasd', 0, NULL, 'announcements', 69, '2026-04-24 18:57:22', 0, NULL),
(278, 27, 'Announcement', 'asdasd', 'asdasd', 0, NULL, 'announcements', 69, '2026-04-24 18:57:22', 0, NULL),
(279, 29, 'Announcement', 'asdasd', 'asdasd', 0, NULL, 'announcements', 69, '2026-04-24 18:57:22', 0, NULL),
(280, 30, 'Announcement', 'asdasd', 'asdasd', 1, '2026-04-24 20:42:03', 'announcements', 69, '2026-04-24 18:57:22', 0, NULL),
(281, 31, 'Announcement', 'asdasd', 'asdasd', 0, NULL, 'announcements', 69, '2026-04-24 18:57:22', 0, NULL),
(282, 32, 'Announcement', 'asdasd', 'asdasd', 0, NULL, 'announcements', 69, '2026-04-24 18:57:22', 0, NULL),
(283, 33, 'Announcement', 'asdasd', 'asdasd', 0, NULL, 'announcements', 69, '2026-04-24 18:57:22', 0, NULL),
(284, 34, 'Announcement', 'asdasd', 'asdasd', 0, NULL, 'announcements', 69, '2026-04-24 18:57:22', 0, NULL),
(285, 35, 'Announcement', 'asdasd', 'asdasd', 1, '2026-04-24 19:46:49', 'announcements', 69, '2026-04-24 18:57:22', 0, NULL),
(286, 36, 'Announcement', 'asdasd', 'asdasd', 0, NULL, 'announcements', 69, '2026-04-24 18:57:22', 0, NULL),
(287, 37, 'Announcement', 'asdasd', 'asdasd', 0, NULL, 'announcements', 69, '2026-04-24 18:57:22', 0, NULL),
(288, 38, 'Announcement', 'asdasd', 'asdasd', 0, NULL, 'announcements', 69, '2026-04-24 18:57:22', 0, NULL),
(289, 39, 'Announcement', 'asdasd', 'asdasd', 1, '2026-04-24 19:03:23', 'announcements', 69, '2026-04-24 18:57:22', 0, NULL),
(290, 1, 'Announcement', 'asdasd', 'asd', 0, NULL, 'announcements', 70, '2026-04-24 20:09:24', 0, NULL),
(291, 26, 'Announcement', 'asdasd', 'asd', 0, NULL, 'announcements', 70, '2026-04-24 20:09:24', 0, NULL),
(292, 27, 'Announcement', 'asdasd', 'asd', 0, NULL, 'announcements', 70, '2026-04-24 20:09:24', 0, NULL),
(293, 28, 'Announcement', 'asdasd', 'asd', 0, NULL, 'announcements', 70, '2026-04-24 20:09:24', 0, NULL),
(294, 29, 'Announcement', 'asdasd', 'asd', 0, NULL, 'announcements', 70, '2026-04-24 20:09:24', 0, NULL),
(295, 30, 'Announcement', 'asdasd', 'asd', 1, '2026-04-24 20:41:59', 'announcements', 70, '2026-04-24 20:09:24', 0, NULL),
(296, 31, 'Announcement', 'asdasd', 'asd', 0, NULL, 'announcements', 70, '2026-04-24 20:09:24', 0, NULL),
(297, 32, 'Announcement', 'asdasd', 'asd', 0, NULL, 'announcements', 70, '2026-04-24 20:09:24', 0, NULL),
(298, 33, 'Announcement', 'asdasd', 'asd', 0, NULL, 'announcements', 70, '2026-04-24 20:09:24', 0, NULL),
(299, 34, 'Announcement', 'asdasd', 'asd', 0, NULL, 'announcements', 70, '2026-04-24 20:09:24', 0, NULL),
(300, 35, 'Announcement', 'asdasd', 'asd', 0, NULL, 'announcements', 70, '2026-04-24 20:09:24', 0, NULL),
(301, 36, 'Announcement', 'asdasd', 'asd', 0, NULL, 'announcements', 70, '2026-04-24 20:09:24', 0, NULL),
(302, 37, 'Announcement', 'asdasd', 'asd', 0, NULL, 'announcements', 70, '2026-04-24 20:09:24', 0, NULL),
(303, 38, 'Announcement', 'asdasd', 'asd', 0, NULL, 'announcements', 70, '2026-04-24 20:09:24', 0, NULL),
(304, 39, 'Announcement', 'asdasd', 'asd', 0, NULL, 'announcements', 70, '2026-04-24 20:09:24', 0, NULL),
(305, 1, 'Risk Flag', 'At-Risk Learner', 'awdawd, awdawdaw dawdawd Grade 10 (test grade 10) flagged as High for FIRST GRADING. Incomplete Grades: Encoded 1/8 subjects', 0, NULL, 'risk_assessments', 13, '2026-04-24 20:42:19', 0, NULL),
(306, 26, 'Risk Flag', 'At-Risk Learner', 'awdawd, awdawdaw dawdawd Grade 10 (test grade 10) flagged as High for FIRST GRADING. Incomplete Grades: Encoded 1/8 subjects', 0, NULL, 'risk_assessments', 13, '2026-04-24 20:42:19', 0, NULL),
(307, 27, 'Risk Flag', 'At-Risk Learner', 'awdawd, awdawdaw dawdawd Grade 10 (test grade 10) flagged as High for FIRST GRADING. Incomplete Grades: Encoded 1/8 subjects', 0, NULL, 'risk_assessments', 13, '2026-04-24 20:42:19', 0, NULL),
(308, 30, 'Risk Flag', 'At-Risk Learner', 'awdawd, awdawdaw dawdawd Grade 10 (test grade 10) flagged as High for FIRST GRADING. Incomplete Grades: Encoded 1/8 subjects', 0, NULL, 'risk_assessments', 13, '2026-04-24 20:42:19', 0, NULL),
(309, 31, 'Risk Flag', 'At-Risk Learner', 'awdawd, awdawdaw dawdawd Grade 10 (test grade 10) flagged as High for FIRST GRADING. Incomplete Grades: Encoded 1/8 subjects', 0, NULL, 'risk_assessments', 13, '2026-04-24 20:42:19', 0, NULL),
(310, 1, 'Risk Flag', 'At-Risk Learner', 'Estroga, Johnbert Test IV Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 100.00%', 0, NULL, 'risk_assessments', 14, '2026-04-24 20:42:19', 0, NULL),
(311, 26, 'Risk Flag', 'At-Risk Learner', 'Estroga, Johnbert Test IV Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 100.00%', 0, NULL, 'risk_assessments', 14, '2026-04-24 20:42:19', 0, NULL),
(312, 27, 'Risk Flag', 'At-Risk Learner', 'Estroga, Johnbert Test IV Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 100.00%', 0, NULL, 'risk_assessments', 14, '2026-04-24 20:42:19', 0, NULL),
(313, 30, 'Risk Flag', 'At-Risk Learner', 'Estroga, Johnbert Test IV Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 100.00%', 0, NULL, 'risk_assessments', 14, '2026-04-24 20:42:19', 0, NULL),
(314, 31, 'Risk Flag', 'At-Risk Learner', 'Estroga, Johnbert Test IV Grade 1 (Gold) flagged as High for FIRST GRADING. Chronic Absence: Absence rate: 100.00%', 0, NULL, 'risk_assessments', 14, '2026-04-24 20:42:19', 0, NULL),
(315, 1, 'Risk Flag', 'At-Risk Learner', 'Learner2, Test Grade 1 (Section Gemini) flagged as Critical for FIRST GRADING. Incomplete Grades: Encoded 2/11 subjects | Failing Quarterly Grade: Lowest quarterly grade: 68.25 | Failed Subject Final Grade: Lowest final grade: 68.25', 0, NULL, 'risk_assessments', 10, '2026-04-24 20:42:19', 0, NULL),
(316, 26, 'Risk Flag', 'At-Risk Learner', 'Learner2, Test Grade 1 (Section Gemini) flagged as Critical for FIRST GRADING. Incomplete Grades: Encoded 2/11 subjects | Failing Quarterly Grade: Lowest quarterly grade: 68.25 | Failed Subject Final Grade: Lowest final grade: 68.25', 0, NULL, 'risk_assessments', 10, '2026-04-24 20:42:19', 0, NULL),
(317, 27, 'Risk Flag', 'At-Risk Learner', 'Learner2, Test Grade 1 (Section Gemini) flagged as Critical for FIRST GRADING. Incomplete Grades: Encoded 2/11 subjects | Failing Quarterly Grade: Lowest quarterly grade: 68.25 | Failed Subject Final Grade: Lowest final grade: 68.25', 0, NULL, 'risk_assessments', 10, '2026-04-24 20:42:19', 0, NULL),
(318, 30, 'Risk Flag', 'At-Risk Learner', 'Learner2, Test Grade 1 (Section Gemini) flagged as Critical for FIRST GRADING. Incomplete Grades: Encoded 2/11 subjects | Failing Quarterly Grade: Lowest quarterly grade: 68.25 | Failed Subject Final Grade: Lowest final grade: 68.25', 0, NULL, 'risk_assessments', 10, '2026-04-24 20:42:20', 0, NULL),
(319, 31, 'Risk Flag', 'At-Risk Learner', 'Learner2, Test Grade 1 (Section Gemini) flagged as Critical for FIRST GRADING. Incomplete Grades: Encoded 2/11 subjects | Failing Quarterly Grade: Lowest quarterly grade: 68.25 | Failed Subject Final Grade: Lowest final grade: 68.25', 0, NULL, 'risk_assessments', 10, '2026-04-24 20:42:20', 0, NULL),
(320, 1, 'Risk Flag', 'At-Risk Learner', 'Created, Reg Grade 1 (Section Gemini) flagged as Critical for FIRST GRADING. Incomplete Grades: Encoded 1/11 subjects | Failing Quarterly Grade: Lowest quarterly grade: 69.20 | Chronic Absence: Absence rate: 40.00% | Failed Subject Final Grade: Lowest final grade: 69.20 | Low General Average: General average: 69.20', 0, NULL, 'risk_assessments', 12, '2026-04-24 20:42:20', 0, NULL),
(321, 26, 'Risk Flag', 'At-Risk Learner', 'Created, Reg Grade 1 (Section Gemini) flagged as Critical for FIRST GRADING. Incomplete Grades: Encoded 1/11 subjects | Failing Quarterly Grade: Lowest quarterly grade: 69.20 | Chronic Absence: Absence rate: 40.00% | Failed Subject Final Grade: Lowest final grade: 69.20 | Low General Average: General average: 69.20', 0, NULL, 'risk_assessments', 12, '2026-04-24 20:42:20', 0, NULL),
(322, 27, 'Risk Flag', 'At-Risk Learner', 'Created, Reg Grade 1 (Section Gemini) flagged as Critical for FIRST GRADING. Incomplete Grades: Encoded 1/11 subjects | Failing Quarterly Grade: Lowest quarterly grade: 69.20 | Chronic Absence: Absence rate: 40.00% | Failed Subject Final Grade: Lowest final grade: 69.20 | Low General Average: General average: 69.20', 0, NULL, 'risk_assessments', 12, '2026-04-24 20:42:20', 0, NULL),
(323, 30, 'Risk Flag', 'At-Risk Learner', 'Created, Reg Grade 1 (Section Gemini) flagged as Critical for FIRST GRADING. Incomplete Grades: Encoded 1/11 subjects | Failing Quarterly Grade: Lowest quarterly grade: 69.20 | Chronic Absence: Absence rate: 40.00% | Failed Subject Final Grade: Lowest final grade: 69.20 | Low General Average: General average: 69.20', 0, NULL, 'risk_assessments', 12, '2026-04-24 20:42:20', 0, NULL),
(324, 31, 'Risk Flag', 'At-Risk Learner', 'Created, Reg Grade 1 (Section Gemini) flagged as Critical for FIRST GRADING. Incomplete Grades: Encoded 1/11 subjects | Failing Quarterly Grade: Lowest quarterly grade: 69.20 | Chronic Absence: Absence rate: 40.00% | Failed Subject Final Grade: Lowest final grade: 69.20 | Low General Average: General average: 69.20', 0, NULL, 'risk_assessments', 12, '2026-04-24 20:42:20', 0, NULL),
(325, 30, 'Risk Flag', 'Dashboard Alert', '8 students have low attendance', 0, NULL, 'dashboard_alerts', NULL, '2026-04-24 20:42:25', 0, NULL),
(326, 1, 'Announcement', 'sdfsdf', 'sdfsdfsdf', 0, NULL, 'announcements', 71, '2026-04-24 20:42:33', 0, NULL),
(327, 26, 'Announcement', 'sdfsdf', 'sdfsdfsdf', 0, NULL, 'announcements', 71, '2026-04-24 20:42:33', 0, NULL),
(328, 27, 'Announcement', 'sdfsdf', 'sdfsdfsdf', 0, NULL, 'announcements', 71, '2026-04-24 20:42:33', 0, NULL),
(329, 28, 'Announcement', 'sdfsdf', 'sdfsdfsdf', 0, NULL, 'announcements', 71, '2026-04-24 20:42:33', 0, NULL),
(330, 29, 'Announcement', 'sdfsdf', 'sdfsdfsdf', 0, NULL, 'announcements', 71, '2026-04-24 20:42:33', 0, NULL),
(331, 30, 'Announcement', 'sdfsdf', 'sdfsdfsdf', 1, '2026-04-24 14:42:33', 'announcements', 71, '2026-04-24 20:42:33', 0, NULL),
(332, 31, 'Announcement', 'sdfsdf', 'sdfsdfsdf', 0, NULL, 'announcements', 71, '2026-04-24 20:42:33', 0, NULL),
(333, 32, 'Announcement', 'sdfsdf', 'sdfsdfsdf', 0, NULL, 'announcements', 71, '2026-04-24 20:42:33', 0, NULL),
(334, 33, 'Announcement', 'sdfsdf', 'sdfsdfsdf', 0, NULL, 'announcements', 71, '2026-04-24 20:42:33', 0, NULL),
(335, 34, 'Announcement', 'sdfsdf', 'sdfsdfsdf', 0, NULL, 'announcements', 71, '2026-04-24 20:42:33', 0, NULL),
(336, 35, 'Announcement', 'sdfsdf', 'sdfsdfsdf', 0, NULL, 'announcements', 71, '2026-04-24 20:42:33', 0, NULL),
(337, 36, 'Announcement', 'sdfsdf', 'sdfsdfsdf', 0, NULL, 'announcements', 71, '2026-04-24 20:42:33', 0, NULL),
(338, 37, 'Announcement', 'sdfsdf', 'sdfsdfsdf', 0, NULL, 'announcements', 71, '2026-04-24 20:42:33', 0, NULL),
(339, 38, 'Announcement', 'sdfsdf', 'sdfsdfsdf', 0, NULL, 'announcements', 71, '2026-04-24 20:42:33', 0, NULL),
(340, 39, 'Announcement', 'sdfsdf', 'sdfsdfsdf', 0, NULL, 'announcements', 71, '2026-04-24 20:42:33', 0, NULL),
(341, 1, 'Announcement', 'sefsef', 'esfefsefs', 0, NULL, 'announcements', 72, '2026-04-24 20:42:41', 0, NULL),
(342, 26, 'Announcement', 'sefsef', 'esfefsefs', 0, NULL, 'announcements', 72, '2026-04-24 20:42:41', 0, NULL),
(343, 27, 'Announcement', 'sefsef', 'esfefsefs', 0, NULL, 'announcements', 72, '2026-04-24 20:42:41', 0, NULL),
(344, 28, 'Announcement', 'sefsef', 'esfefsefs', 0, NULL, 'announcements', 72, '2026-04-24 20:42:41', 0, NULL),
(345, 29, 'Announcement', 'sefsef', 'esfefsefs', 0, NULL, 'announcements', 72, '2026-04-24 20:42:41', 0, NULL),
(346, 30, 'Announcement', 'sefsef', 'esfefsefs', 1, '2026-04-24 20:42:56', 'announcements', 72, '2026-04-24 20:42:41', 0, NULL),
(347, 31, 'Announcement', 'sefsef', 'esfefsefs', 0, NULL, 'announcements', 72, '2026-04-24 20:42:41', 0, NULL),
(348, 32, 'Announcement', 'sefsef', 'esfefsefs', 0, NULL, 'announcements', 72, '2026-04-24 20:42:41', 0, NULL),
(349, 33, 'Announcement', 'sefsef', 'esfefsefs', 0, NULL, 'announcements', 72, '2026-04-24 20:42:41', 0, NULL),
(350, 34, 'Announcement', 'sefsef', 'esfefsefs', 0, NULL, 'announcements', 72, '2026-04-24 20:42:41', 0, NULL),
(351, 35, 'Announcement', 'sefsef', 'esfefsefs', 0, NULL, 'announcements', 72, '2026-04-24 20:42:41', 0, NULL),
(352, 36, 'Announcement', 'sefsef', 'esfefsefs', 0, NULL, 'announcements', 72, '2026-04-24 20:42:41', 0, NULL),
(353, 37, 'Announcement', 'sefsef', 'esfefsefs', 0, NULL, 'announcements', 72, '2026-04-24 20:42:41', 0, NULL),
(354, 38, 'Announcement', 'sefsef', 'esfefsefs', 0, NULL, 'announcements', 72, '2026-04-24 20:42:41', 0, NULL),
(355, 39, 'Announcement', 'sefsef', 'esfefsefs', 0, NULL, 'announcements', 72, '2026-04-24 20:42:41', 0, NULL);

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
(2, 6, 6, 3, 30, '2026-04-24 20:42:19', 'Auto-assessed: Chronic Absence (Absence rate: 20.00%).', 0, NULL),
(3, 5, 6, 3, 30, '2026-04-24 20:42:19', 'Auto-assessed: Incomplete Grades (Encoded 7/8 subjects).', 0, NULL),
(4, 11, 6, 1, 30, '2026-04-24 20:42:19', 'Auto-assessed: No risk indicators detected.', 0, NULL),
(6, 8, 6, 3, 30, '2026-04-24 20:42:19', 'Auto-assessed: Chronic Absence (Absence rate: 50.00%).', 0, NULL),
(7, 9, 6, 3, 30, '2026-04-24 20:42:19', 'Auto-assessed: Chronic Absence (Absence rate: 40.00%).', 0, NULL),
(8, 10, 6, 3, 30, '2026-04-24 20:42:19', 'Auto-assessed: Chronic Absence (Absence rate: 40.00%).', 0, NULL),
(9, 12, 6, 1, 30, '2026-04-24 20:42:19', 'Auto-assessed: No risk indicators detected.', 0, NULL),
(10, 13, 6, 4, 30, '2026-04-24 20:42:19', 'Auto-assessed: Incomplete Grades (Encoded 2/11 subjects); Failing Quarterly Grade (Lowest quarterly grade: 68.25); Failed Subject Final Grade (Lowest final grade: 68.25).', 0, NULL),
(11, 14, 6, 3, 30, '2026-04-24 20:42:19', 'Auto-assessed: No Encoded Grades (No quarterly grades encoded for this period).', 0, NULL),
(12, 15, 6, 4, 30, '2026-04-24 20:42:19', 'Auto-assessed: Incomplete Grades (Encoded 1/11 subjects); Failing Quarterly Grade (Lowest quarterly grade: 69.20); Chronic Absence (Absence rate: 40.00%); Failed Subject Final Grade (Lowest final grade: 69.20); Low General Average (General average: 69.20).', 0, NULL),
(13, 16, 6, 3, 30, '2026-04-24 20:42:19', 'Auto-assessed: Incomplete Grades (Encoded 1/8 subjects).', 0, NULL),
(14, 17, 6, 3, 30, '2026-04-24 20:42:19', 'Auto-assessed: Chronic Absence (Absence rate: 100.00%).', 0, NULL);

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
(1, 2, 'Grade Drop', '', 1, '2026-03-25 22:36:55'),
(2, 4, 'Attendance', '', 1, '2026-03-25 22:36:55'),
(3, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 22:43:49'),
(4, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 22:43:49'),
(5, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 22:43:49'),
(6, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 22:43:49'),
(7, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 22:44:47'),
(8, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 22:44:47'),
(9, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 22:44:47'),
(10, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 22:44:47'),
(11, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:13:38'),
(12, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:13:38'),
(13, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:13:38'),
(14, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:13:38'),
(15, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:17:35'),
(16, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:17:35'),
(17, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:17:35'),
(18, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:17:35'),
(19, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:25:05'),
(20, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:25:05'),
(21, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:25:05'),
(22, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:25:05'),
(23, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:25:15'),
(24, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:25:15'),
(25, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:25:15'),
(26, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:25:15'),
(27, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:25:51'),
(28, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:25:51'),
(29, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:25:51'),
(30, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:25:51'),
(31, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:06'),
(32, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:36:06'),
(33, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:06'),
(34, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:06'),
(35, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:51'),
(36, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:36:51'),
(37, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:51'),
(38, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:51'),
(39, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:51'),
(40, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:36:51'),
(41, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:51'),
(42, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:51'),
(43, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:52'),
(44, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:36:52'),
(45, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:52'),
(46, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:52'),
(47, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:52'),
(48, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:36:52'),
(49, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:52'),
(50, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:52'),
(51, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:53'),
(52, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:36:53'),
(53, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:53'),
(54, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:53'),
(55, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:53'),
(56, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:36:53'),
(57, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:53'),
(58, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:53'),
(59, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:54'),
(60, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:36:54'),
(61, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:54'),
(62, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:36:54'),
(63, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:39:06'),
(64, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:39:06'),
(65, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:39:06'),
(66, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:39:07'),
(67, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:39:15'),
(68, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:39:15'),
(69, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:39:15'),
(70, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:39:15'),
(71, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:41:21'),
(72, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:41:21'),
(73, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:41:21'),
(74, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:41:21'),
(75, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:18'),
(76, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:42:18'),
(77, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:18'),
(78, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:18'),
(79, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:23'),
(80, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:42:23'),
(81, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:23'),
(82, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:23'),
(83, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:24'),
(84, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:42:24'),
(85, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:24'),
(86, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:24'),
(87, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:24'),
(88, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:42:24'),
(89, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:24'),
(90, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:24'),
(91, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:25'),
(92, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:42:25'),
(93, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:25'),
(94, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:25'),
(95, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:29'),
(96, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:42:29'),
(97, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:29'),
(98, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:29'),
(99, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:30'),
(100, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:42:30'),
(101, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:30'),
(102, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:42:30'),
(103, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:24'),
(104, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:44:24'),
(105, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:24'),
(106, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:24'),
(107, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:26'),
(108, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:44:26'),
(109, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:26'),
(110, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:26'),
(111, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:27'),
(112, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:44:27'),
(113, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:27'),
(114, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:27'),
(115, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:28'),
(116, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:44:28'),
(117, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:28'),
(118, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:28'),
(119, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:29'),
(120, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:44:29'),
(121, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:29'),
(122, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:29'),
(123, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:30'),
(124, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:44:30'),
(125, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:30'),
(126, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:30'),
(127, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:31'),
(128, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:44:31'),
(129, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:31'),
(130, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:31'),
(131, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:32'),
(132, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:44:32'),
(133, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:32'),
(134, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:32'),
(135, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:33'),
(136, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:44:33'),
(137, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:33'),
(138, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:33'),
(139, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:36'),
(140, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:44:36'),
(141, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:36'),
(142, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:36'),
(143, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:37'),
(144, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:44:37'),
(145, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:37'),
(146, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:37'),
(147, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:59'),
(148, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:44:59'),
(149, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:59'),
(150, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:44:59'),
(151, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:00'),
(152, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:45:00'),
(153, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:00'),
(154, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:00'),
(155, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:01'),
(156, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:45:01'),
(157, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:01'),
(158, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:01'),
(159, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:01'),
(160, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:45:01'),
(161, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:01'),
(162, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:01'),
(163, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:02'),
(164, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:45:02'),
(165, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:02'),
(166, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:02'),
(167, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:03'),
(168, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:45:03'),
(169, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:03'),
(170, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:03'),
(171, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:04'),
(172, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:45:04'),
(173, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:04'),
(174, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:04'),
(175, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:05'),
(176, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:45:05'),
(177, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:05'),
(178, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:05'),
(179, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:06'),
(180, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:45:06'),
(181, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:06'),
(182, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:06'),
(183, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:07'),
(184, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:45:07'),
(185, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:07'),
(186, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:07'),
(187, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:08'),
(188, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:45:08'),
(189, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:08'),
(190, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:08'),
(191, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:22'),
(192, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:45:22'),
(193, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:22'),
(194, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:22'),
(195, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:23'),
(196, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:45:23'),
(197, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:23'),
(198, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:23'),
(199, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:28'),
(200, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:45:28'),
(201, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:28'),
(202, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:45:28'),
(203, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:31'),
(204, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:46:31'),
(205, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:31'),
(206, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:31'),
(207, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:31'),
(208, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:46:31'),
(209, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:31'),
(210, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:31'),
(211, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:32'),
(212, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:46:32'),
(213, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:32'),
(214, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:32'),
(215, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:33'),
(216, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:46:33'),
(217, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:33'),
(218, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:33'),
(219, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:34'),
(220, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:46:34'),
(221, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:34'),
(222, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:34'),
(223, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:35'),
(224, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:46:35'),
(225, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:35'),
(226, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:35'),
(227, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:36'),
(228, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:46:36'),
(229, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:36'),
(230, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:36'),
(231, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:37'),
(232, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:46:37'),
(233, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:37'),
(234, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:37'),
(235, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:38'),
(236, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:46:38'),
(237, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:38'),
(238, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:38'),
(239, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:39'),
(240, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:46:39'),
(241, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:39'),
(242, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:39'),
(243, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:40'),
(244, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:46:40'),
(245, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:40'),
(246, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:40'),
(247, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:41'),
(248, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:46:41'),
(249, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:41'),
(250, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:41'),
(251, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:42'),
(252, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:46:42'),
(253, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:42'),
(254, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:42'),
(255, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:43'),
(256, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:46:43'),
(257, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:43'),
(258, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:43'),
(259, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:44'),
(260, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:46:44'),
(261, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:44'),
(262, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:44'),
(263, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:45'),
(264, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:46:45'),
(265, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:45'),
(266, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:45'),
(267, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:58'),
(268, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:46:58'),
(269, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:58'),
(270, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:58'),
(271, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:59'),
(272, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:46:59'),
(273, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:59'),
(274, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:46:59'),
(275, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:01'),
(276, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:47:01'),
(277, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:01'),
(278, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:01'),
(279, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:04'),
(280, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:47:04'),
(281, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:04'),
(282, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:04'),
(283, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:05'),
(284, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:47:05'),
(285, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:05'),
(286, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:05'),
(287, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:06'),
(288, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:47:06'),
(289, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:06'),
(290, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:06'),
(291, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:07'),
(292, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:47:07'),
(293, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:07'),
(294, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:07'),
(295, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:09'),
(296, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:47:09'),
(297, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:09'),
(298, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:09'),
(299, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:10'),
(300, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:47:10'),
(301, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:10'),
(302, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:10'),
(303, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:14'),
(304, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:47:14'),
(305, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:14'),
(306, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:14'),
(307, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:15'),
(308, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:47:15'),
(309, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:15'),
(310, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:15'),
(311, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:17'),
(312, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:47:17'),
(313, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:17'),
(314, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:17'),
(315, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:18'),
(316, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:47:18'),
(317, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:18'),
(318, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:18'),
(319, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:19'),
(320, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:47:19'),
(321, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:19'),
(322, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:19'),
(323, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:20'),
(324, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:47:20'),
(325, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:20'),
(326, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:20'),
(327, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:48'),
(328, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:47:48'),
(329, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:48'),
(330, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:48'),
(331, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:48'),
(332, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:47:48'),
(333, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:48'),
(334, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:48'),
(335, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:49'),
(336, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:47:49'),
(337, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:49'),
(338, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:49'),
(339, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:50'),
(340, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:47:50'),
(341, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:50'),
(342, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:47:50'),
(343, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:16'),
(344, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:16'),
(345, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:16'),
(346, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:16'),
(347, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:17'),
(348, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:17'),
(349, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:17'),
(350, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:17'),
(351, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:17'),
(352, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:17'),
(353, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:17'),
(354, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:17'),
(355, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:18'),
(356, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:18'),
(357, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:18'),
(358, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:18'),
(359, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:19'),
(360, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:19'),
(361, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:19'),
(362, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:19'),
(363, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:20'),
(364, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:20'),
(365, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:20'),
(366, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:20'),
(367, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:20'),
(368, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:20'),
(369, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:20'),
(370, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:20'),
(371, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:21'),
(372, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:21'),
(373, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:21'),
(374, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:21'),
(375, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:22'),
(376, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:22'),
(377, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:22'),
(378, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:22'),
(379, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:23'),
(380, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:23'),
(381, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:23'),
(382, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:23'),
(383, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:23'),
(384, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:23'),
(385, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:23'),
(386, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:23'),
(387, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:24'),
(388, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:24'),
(389, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:24'),
(390, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:24'),
(391, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:25'),
(392, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:25'),
(393, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:25'),
(394, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:25'),
(395, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:25'),
(396, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:25'),
(397, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:25'),
(398, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:25'),
(399, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:26'),
(400, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:26'),
(401, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:26'),
(402, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:26'),
(403, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:36'),
(404, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:36'),
(405, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:36'),
(406, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:36'),
(407, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:40'),
(408, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:40'),
(409, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:40'),
(410, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:40'),
(411, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:41'),
(412, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:41'),
(413, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:41'),
(414, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:41'),
(415, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:42'),
(416, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:42'),
(417, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:42'),
(418, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:42'),
(419, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:43'),
(420, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:43'),
(421, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:43'),
(422, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:43'),
(423, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:44'),
(424, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:44'),
(425, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:44'),
(426, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:44'),
(427, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:44'),
(428, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:44'),
(429, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:44'),
(430, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:44'),
(431, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:45'),
(432, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:45'),
(433, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:45'),
(434, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:45'),
(435, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:46'),
(436, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:46'),
(437, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:46'),
(438, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:46'),
(439, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:47'),
(440, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:47'),
(441, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:47'),
(442, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:47'),
(443, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:47'),
(444, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:47'),
(445, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:47'),
(446, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:47'),
(447, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:48'),
(448, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:48'),
(449, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:48'),
(450, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:48'),
(451, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:49'),
(452, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:48:49'),
(453, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:49'),
(454, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:48:49'),
(455, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:23'),
(456, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:50:23'),
(457, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:23'),
(458, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:23'),
(459, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:24'),
(460, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:50:24'),
(461, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:24'),
(462, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:24'),
(463, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:25'),
(464, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:50:25'),
(465, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:25'),
(466, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:25'),
(467, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:26'),
(468, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:50:26'),
(469, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:26'),
(470, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:26'),
(471, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:27'),
(472, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:50:27'),
(473, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:27'),
(474, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:27'),
(475, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:27'),
(476, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:50:27'),
(477, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:27'),
(478, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:27'),
(479, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:28'),
(480, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:50:28'),
(481, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:28'),
(482, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:28'),
(483, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:29'),
(484, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:50:29'),
(485, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:29'),
(486, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:29'),
(487, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:30'),
(488, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:50:30'),
(489, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:30'),
(490, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:30'),
(491, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:32'),
(492, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:50:32'),
(493, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:32'),
(494, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:50:32'),
(495, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:52:28'),
(496, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:52:28'),
(497, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:52:28'),
(498, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:52:28'),
(499, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:56:10'),
(500, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:56:10'),
(501, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:56:10'),
(502, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:56:10'),
(503, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:59:05'),
(504, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:59:05'),
(505, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:59:05'),
(506, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:59:05'),
(507, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:59:06'),
(508, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:59:06'),
(509, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:59:06'),
(510, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:59:06'),
(511, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:59:53'),
(512, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:59:53'),
(513, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:59:53'),
(514, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:59:53'),
(515, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:59:54'),
(516, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-25 23:59:54'),
(517, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:59:54'),
(518, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-25 23:59:54'),
(519, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:05'),
(520, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:01:05'),
(521, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:05'),
(522, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:05'),
(523, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:06'),
(524, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:01:06'),
(525, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:06'),
(526, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:06'),
(527, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:07'),
(528, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:01:07'),
(529, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:07'),
(530, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:07'),
(531, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:13'),
(532, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:01:13'),
(533, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:13'),
(534, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:13'),
(535, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:14'),
(536, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:01:14'),
(537, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:14'),
(538, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:14'),
(539, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:33'),
(540, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:01:33'),
(541, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:33'),
(542, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:33'),
(543, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:34'),
(544, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:01:34'),
(545, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:34'),
(546, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:34'),
(547, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:48'),
(548, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:01:48'),
(549, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:48'),
(550, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:48'),
(551, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:49'),
(552, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:01:49'),
(553, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:49'),
(554, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:49'),
(555, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:50'),
(556, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:01:50'),
(557, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:50'),
(558, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:50'),
(559, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:51'),
(560, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:01:51'),
(561, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:51'),
(562, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:51'),
(563, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:53'),
(564, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:01:53'),
(565, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:53'),
(566, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:53'),
(567, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:53'),
(568, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:01:53'),
(569, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:53'),
(570, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:01:53'),
(571, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:02:51'),
(572, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:02:51'),
(573, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:02:51'),
(574, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:02:51'),
(575, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:02:51'),
(576, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:02:51'),
(577, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:02:51'),
(578, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:02:51'),
(579, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:08:11'),
(580, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:08:11'),
(581, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:08:11'),
(582, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:08:11'),
(583, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:08:12'),
(584, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:08:12'),
(585, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:08:12'),
(586, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:08:12'),
(587, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:17:23'),
(588, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:17:23'),
(589, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:17:23'),
(590, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:17:23'),
(591, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:30:33'),
(592, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:30:33'),
(593, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:30:33'),
(594, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:30:33'),
(595, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:31:23'),
(596, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:31:23'),
(597, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:31:23'),
(598, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:31:23'),
(599, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:33:41'),
(600, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:33:41'),
(601, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:33:41'),
(602, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:33:41'),
(603, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:34:33'),
(604, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 00:34:33'),
(605, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:34:33'),
(606, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 00:34:33'),
(607, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:47:31'),
(608, 6, 'Incomplete Grades', 'Encoded 2/6 subjects', 1, '2026-03-26 10:47:31'),
(609, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:47:31'),
(610, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:47:31'),
(611, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:47:42'),
(612, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-26 10:47:42'),
(613, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:47:42'),
(614, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-26 10:47:42'),
(615, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:47:42'),
(616, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:48:23'),
(617, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-26 10:48:23'),
(618, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:48:23'),
(619, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-26 10:48:23'),
(620, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:48:23'),
(621, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:52:38'),
(622, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-26 10:52:38'),
(623, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:52:38'),
(624, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-26 10:52:38'),
(625, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:52:38'),
(626, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:54:31');
INSERT INTO `risk_indicators` (`indicator_id`, `risk_assessment_id`, `indicator_type`, `details`, `is_deleted`, `deleted_at`) VALUES
(627, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-26 10:54:31'),
(628, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:54:31'),
(629, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-26 10:54:31'),
(630, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:54:31'),
(631, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:55:47'),
(632, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-26 10:55:47'),
(633, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:55:47'),
(634, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-26 10:55:47'),
(635, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:55:47'),
(636, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:55:47'),
(637, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-26 10:55:47'),
(638, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:55:47'),
(639, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-26 10:55:47'),
(640, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 10:55:47'),
(641, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:14:43'),
(642, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-26 11:14:43'),
(643, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:14:43'),
(644, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-26 11:14:43'),
(645, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:14:43'),
(646, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:23:34'),
(647, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-26 11:23:34'),
(648, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:23:34'),
(649, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-26 11:23:34'),
(650, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:23:34'),
(651, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:34:51'),
(652, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-26 11:34:51'),
(653, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:34:51'),
(654, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-26 11:34:51'),
(655, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:34:51'),
(656, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:00'),
(657, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-26 11:35:00'),
(658, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:00'),
(659, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-26 11:35:00'),
(660, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:00'),
(661, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:01'),
(662, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-26 11:35:01'),
(663, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:01'),
(664, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-26 11:35:01'),
(665, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:01'),
(666, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:02'),
(667, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-26 11:35:02'),
(668, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:02'),
(669, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-26 11:35:02'),
(670, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:02'),
(671, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:05'),
(672, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-26 11:35:05'),
(673, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:05'),
(674, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-26 11:35:05'),
(675, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:05'),
(676, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:09'),
(677, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-26 11:35:09'),
(678, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:09'),
(679, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-26 11:35:09'),
(680, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:09'),
(681, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:10'),
(682, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-26 11:35:10'),
(683, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:10'),
(684, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-26 11:35:10'),
(685, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:10'),
(686, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:30'),
(687, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-26 11:35:30'),
(688, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:30'),
(689, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-26 11:35:30'),
(690, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-26 11:35:30'),
(691, 2, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-27 11:06:51'),
(692, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 11:06:51'),
(693, 7, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-27 11:06:51'),
(694, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 11:06:51'),
(695, 8, 'Incomplete Grades', 'Encoded 1/15 subjects', 1, '2026-03-27 11:06:51'),
(696, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 11:07:14'),
(697, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 11:07:14'),
(698, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 11:07:14'),
(699, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 11:07:14'),
(700, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 72.00', 1, '2026-03-27 11:07:14'),
(701, 9, 'Failed Subject Final Grade', 'Lowest final grade: 72.00', 1, '2026-03-27 11:07:14'),
(702, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 11:08:02'),
(703, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 11:08:02'),
(704, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 11:08:02'),
(705, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 11:08:02'),
(706, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 72.00', 1, '2026-03-27 11:08:02'),
(707, 9, 'Failed Subject Final Grade', 'Lowest final grade: 72.00', 1, '2026-03-27 11:08:02'),
(708, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 11:19:04'),
(709, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 11:19:04'),
(710, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 11:19:04'),
(711, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 11:19:04'),
(712, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 72.00', 1, '2026-03-27 11:19:04'),
(713, 9, 'Failed Subject Final Grade', 'Lowest final grade: 72.00', 1, '2026-03-27 11:19:04'),
(714, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 11:20:10'),
(715, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 11:20:10'),
(716, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 11:20:10'),
(717, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 11:20:10'),
(718, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 72.00', 1, '2026-03-27 11:20:10'),
(719, 9, 'Failed Subject Final Grade', 'Lowest final grade: 72.00', 1, '2026-03-27 11:20:10'),
(720, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:03:53'),
(721, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 12:03:53'),
(722, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:03:53'),
(723, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:03:53'),
(724, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 72.00', 1, '2026-03-27 12:03:53'),
(725, 9, 'Failed Subject Final Grade', 'Lowest final grade: 72.00', 1, '2026-03-27 12:03:53'),
(726, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:05:13'),
(727, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 12:05:13'),
(728, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 12:05:13'),
(729, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:05:13'),
(730, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:05:13'),
(731, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:05:13'),
(732, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:05:15'),
(733, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 12:05:15'),
(734, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 12:05:15'),
(735, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:05:15'),
(736, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:05:15'),
(737, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:05:15'),
(738, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:05:37'),
(739, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 12:05:37'),
(740, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 12:05:37'),
(741, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:05:37'),
(742, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:05:37'),
(743, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:05:37'),
(744, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:05:40'),
(745, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 12:05:40'),
(746, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 12:05:40'),
(747, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:05:40'),
(748, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:05:40'),
(749, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:05:40'),
(750, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:05:47'),
(751, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 12:05:47'),
(752, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 12:05:47'),
(753, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:05:47'),
(754, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:05:47'),
(755, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:05:47'),
(756, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:05:47'),
(757, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 12:05:47'),
(758, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 12:05:47'),
(759, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:05:47'),
(760, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:05:47'),
(761, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:05:47'),
(762, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:05:50'),
(763, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 12:05:50'),
(764, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 12:05:50'),
(765, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:05:50'),
(766, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:05:50'),
(767, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:05:50'),
(768, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:06:37'),
(769, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 12:06:37'),
(770, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 12:06:37'),
(771, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:06:37'),
(772, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:06:37'),
(773, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:06:37'),
(774, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:06:42'),
(775, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 12:06:42'),
(776, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 12:06:42'),
(777, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:06:42'),
(778, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:06:42'),
(779, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:06:42'),
(780, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:06:44'),
(781, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 12:06:44'),
(782, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 12:06:44'),
(783, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:06:44'),
(784, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:06:44'),
(785, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:06:44'),
(786, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:06:45'),
(787, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 12:06:45'),
(788, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 12:06:45'),
(789, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:06:45'),
(790, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:06:45'),
(791, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:06:45'),
(792, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:07:41'),
(793, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 12:07:41'),
(794, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 12:07:41'),
(795, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:07:41'),
(796, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:07:41'),
(797, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:07:41'),
(798, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:07:41'),
(799, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 12:07:41'),
(800, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 12:07:41'),
(801, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:07:41'),
(802, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:07:41'),
(803, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:07:41'),
(804, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 64.00', 1, '2026-03-27 12:07:41'),
(805, 9, 'Chronic Absence', 'Absence rate: 100.00%', 1, '2026-03-27 12:07:41'),
(806, 9, 'Failed Subject Final Grade', 'Lowest final grade: 64.00', 1, '2026-03-27 12:07:41'),
(807, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:08:38'),
(808, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 12:08:38'),
(809, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 12:08:38'),
(810, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:08:38'),
(811, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:08:38'),
(812, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:08:38'),
(813, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 64.00', 1, '2026-03-27 12:08:38'),
(814, 9, 'Chronic Absence', 'Absence rate: 100.00%', 1, '2026-03-27 12:08:38'),
(815, 9, 'Failed Subject Final Grade', 'Lowest final grade: 64.00', 1, '2026-03-27 12:08:38'),
(816, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:18:27'),
(817, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 12:18:27'),
(818, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 12:18:27'),
(819, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:18:27'),
(820, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 12:18:27'),
(821, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 12:18:27'),
(822, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 64.00', 1, '2026-03-27 12:18:27'),
(823, 9, 'Chronic Absence', 'Absence rate: 100.00%', 1, '2026-03-27 12:18:27'),
(824, 9, 'Failed Subject Final Grade', 'Lowest final grade: 64.00', 1, '2026-03-27 12:18:27'),
(825, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:29:00'),
(826, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:29:00'),
(827, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:29:00'),
(828, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:29:00'),
(829, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:29:00'),
(830, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:29:00'),
(831, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 64.00', 1, '2026-03-27 13:29:00'),
(832, 9, 'Chronic Absence', 'Absence rate: 100.00%', 1, '2026-03-27 13:29:00'),
(833, 9, 'Failed Subject Final Grade', 'Lowest final grade: 64.00', 1, '2026-03-27 13:29:00'),
(834, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:29:27'),
(835, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:29:27'),
(836, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:29:27'),
(837, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:29:27'),
(838, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:29:27'),
(839, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:29:27'),
(840, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 64.00', 1, '2026-03-27 13:29:27'),
(841, 9, 'Chronic Absence', 'Absence rate: 100.00%', 1, '2026-03-27 13:29:27'),
(842, 9, 'Failed Subject Final Grade', 'Lowest final grade: 64.00', 1, '2026-03-27 13:29:27'),
(843, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:29:58'),
(844, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:29:58'),
(845, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:29:58'),
(846, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:29:58'),
(847, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:29:58'),
(848, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:29:58'),
(849, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 64.00', 1, '2026-03-27 13:29:58'),
(850, 9, 'Chronic Absence', 'Absence rate: 100.00%', 1, '2026-03-27 13:29:58'),
(851, 9, 'Failed Subject Final Grade', 'Lowest final grade: 64.00', 1, '2026-03-27 13:29:58'),
(852, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:32:37'),
(853, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:32:37'),
(854, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:32:37'),
(855, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:32:37'),
(856, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:32:37'),
(857, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:32:37'),
(858, 9, 'Chronic Absence', 'Absence rate: 100.00%', 1, '2026-03-27 13:32:37'),
(859, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:33:16'),
(860, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:33:16'),
(861, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:33:16'),
(862, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:33:16'),
(863, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:33:16'),
(864, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:33:16'),
(865, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:33:19'),
(866, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:33:19'),
(867, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:33:19'),
(868, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:33:19'),
(869, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:33:19'),
(870, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:33:19'),
(871, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:36:37'),
(872, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:36:37'),
(873, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:36:37'),
(874, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:36:37'),
(875, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:36:37'),
(876, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:36:37'),
(877, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:36:40'),
(878, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:36:40'),
(879, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:36:40'),
(880, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:36:40'),
(881, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:36:40'),
(882, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:36:40'),
(883, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:36:42'),
(884, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:36:42'),
(885, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:36:42'),
(886, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:36:42'),
(887, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:36:42'),
(888, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:36:42'),
(889, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:36:43'),
(890, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:36:43'),
(891, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:36:43'),
(892, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:36:43'),
(893, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:36:43'),
(894, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:36:43'),
(895, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:36:44'),
(896, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:36:44'),
(897, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:36:44'),
(898, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:36:44'),
(899, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:36:44'),
(900, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:36:44'),
(901, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:36:45'),
(902, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:36:45'),
(903, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:36:45'),
(904, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:36:45'),
(905, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:36:45'),
(906, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:36:45'),
(907, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:36:47'),
(908, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:36:47'),
(909, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:36:47'),
(910, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:36:47'),
(911, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:36:47'),
(912, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:36:47'),
(913, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:37:05'),
(914, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:37:05'),
(915, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:37:05'),
(916, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:37:05'),
(917, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:37:05'),
(918, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:37:05'),
(919, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:37:05'),
(920, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:37:05'),
(921, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:37:05'),
(922, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:37:05'),
(923, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:37:05'),
(924, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:37:05'),
(925, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:37:15'),
(926, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:37:15'),
(927, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:37:15'),
(928, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:37:15'),
(929, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:37:15'),
(930, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:37:15'),
(931, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:37:15'),
(932, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:37:15'),
(933, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:37:15'),
(934, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:37:15'),
(935, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:37:15'),
(936, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:37:15'),
(937, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:41:53'),
(938, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:41:53'),
(939, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:41:53'),
(940, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:41:53'),
(941, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:41:53'),
(942, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:41:53'),
(943, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:41:55'),
(944, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:41:55'),
(945, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:41:55'),
(946, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:41:55'),
(947, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:41:55'),
(948, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:41:55'),
(949, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:41:59'),
(950, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:41:59'),
(951, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:41:59'),
(952, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:41:59'),
(953, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:41:59'),
(954, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:41:59'),
(955, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:41:59'),
(956, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:41:59'),
(957, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:41:59'),
(958, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:41:59'),
(959, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:41:59'),
(960, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:41:59'),
(961, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:00'),
(962, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:42:00'),
(963, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:42:00'),
(964, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:00'),
(965, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:00'),
(966, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:00'),
(967, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:01'),
(968, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:42:01'),
(969, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:42:01'),
(970, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:01'),
(971, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:01'),
(972, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:01'),
(973, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:01'),
(974, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:42:01'),
(975, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:42:01'),
(976, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:01'),
(977, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:01'),
(978, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:01'),
(979, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:02'),
(980, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:42:02'),
(981, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:42:02'),
(982, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:02'),
(983, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:02'),
(984, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:02'),
(985, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:06'),
(986, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:42:06'),
(987, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:42:06'),
(988, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:06'),
(989, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:06'),
(990, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:06'),
(991, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:07'),
(992, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:42:07'),
(993, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:42:07'),
(994, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:07'),
(995, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:07'),
(996, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:07'),
(997, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:07'),
(998, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:42:07'),
(999, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:42:07'),
(1000, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:07'),
(1001, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:07'),
(1002, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:07'),
(1003, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:07'),
(1004, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:42:07'),
(1005, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:42:07'),
(1006, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:07'),
(1007, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:07'),
(1008, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:07'),
(1009, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:08'),
(1010, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:42:08'),
(1011, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:42:08'),
(1012, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:08'),
(1013, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:08'),
(1014, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:08'),
(1015, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:08'),
(1016, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:42:08'),
(1017, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:42:08'),
(1018, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:08'),
(1019, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:08'),
(1020, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:08'),
(1021, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:08'),
(1022, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:42:08'),
(1023, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:42:08'),
(1024, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:08'),
(1025, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:08'),
(1026, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:08'),
(1027, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:09'),
(1028, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:42:09'),
(1029, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:42:09'),
(1030, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:09'),
(1031, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:42:09'),
(1032, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:42:09'),
(1033, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:49:48'),
(1034, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:49:48'),
(1035, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:49:48'),
(1036, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:49:48'),
(1037, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:49:48'),
(1038, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:49:48'),
(1039, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:50:26'),
(1040, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:50:26'),
(1041, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:50:26'),
(1042, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:50:26'),
(1043, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:50:26'),
(1044, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:50:26'),
(1045, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:50:26'),
(1046, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:50:26'),
(1047, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:50:26'),
(1048, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:50:26'),
(1049, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:50:26'),
(1050, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:50:26'),
(1051, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:50:27'),
(1052, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:50:27'),
(1053, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:50:27'),
(1054, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:50:27'),
(1055, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:50:27'),
(1056, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:50:27'),
(1057, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:50:33'),
(1058, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:50:33'),
(1059, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:50:33'),
(1060, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:50:33'),
(1061, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:50:33'),
(1062, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:50:33'),
(1063, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:50:42'),
(1064, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:50:42'),
(1065, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:50:42'),
(1066, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:50:42'),
(1067, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:50:42'),
(1068, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:50:42'),
(1069, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:50:42'),
(1070, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:50:42'),
(1071, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:50:42'),
(1072, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:50:42'),
(1073, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:50:42'),
(1074, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:50:42'),
(1075, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:53:02'),
(1076, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:53:02'),
(1077, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:53:02'),
(1078, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:53:02'),
(1079, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:53:02'),
(1080, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:53:02'),
(1081, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:53:03'),
(1082, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:53:03'),
(1083, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:53:03'),
(1084, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:53:03'),
(1085, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:53:03'),
(1086, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:53:03'),
(1087, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:56:10'),
(1088, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 13:56:10'),
(1089, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 13:56:10'),
(1090, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:56:10'),
(1091, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 13:56:10'),
(1092, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 13:56:10'),
(1093, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 14:22:02'),
(1094, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 14:22:02'),
(1095, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 14:22:02'),
(1096, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:22:02'),
(1097, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:22:02'),
(1098, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 14:22:02'),
(1099, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 14:22:52'),
(1100, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 14:22:52'),
(1101, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 14:22:52'),
(1102, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:22:52'),
(1103, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:22:52'),
(1104, 4, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 14:22:52'),
(1105, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 14:22:52'),
(1106, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 14:22:52'),
(1107, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 14:22:52'),
(1108, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:22:52'),
(1109, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:22:52'),
(1110, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 14:30:07'),
(1111, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 14:30:07'),
(1112, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 14:30:07'),
(1113, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:30:07'),
(1114, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:30:07'),
(1115, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 14:32:19'),
(1116, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 14:32:19'),
(1117, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 14:32:19'),
(1118, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:32:19'),
(1119, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:32:19'),
(1120, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 14:32:59'),
(1121, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 14:32:59'),
(1122, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 14:32:59'),
(1123, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:32:59'),
(1124, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:32:59'),
(1125, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 14:53:14'),
(1126, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 14:53:14'),
(1127, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 14:53:14'),
(1128, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:53:14'),
(1129, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:53:14'),
(1130, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 63.60', 1, '2026-03-27 14:53:14'),
(1131, 9, 'Failed Subject Final Grade', 'Lowest final grade: 63.60', 1, '2026-03-27 14:53:14'),
(1132, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 14:53:19'),
(1133, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 14:53:19'),
(1134, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 14:53:19'),
(1135, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:53:19'),
(1136, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:53:19'),
(1137, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 63.60', 1, '2026-03-27 14:53:19'),
(1138, 9, 'Failed Subject Final Grade', 'Lowest final grade: 63.60', 1, '2026-03-27 14:53:19'),
(1139, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 14:53:28'),
(1140, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 14:53:28'),
(1141, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 14:53:28'),
(1142, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:53:28'),
(1143, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:53:28'),
(1144, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 63.60', 1, '2026-03-27 14:53:28'),
(1145, 9, 'Failed Subject Final Grade', 'Lowest final grade: 63.60', 1, '2026-03-27 14:53:28'),
(1146, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 14:53:49'),
(1147, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 14:53:49'),
(1148, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 14:53:49'),
(1149, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:53:49'),
(1150, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:53:49'),
(1151, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 63.60', 1, '2026-03-27 14:53:49'),
(1152, 9, 'Failed Subject Final Grade', 'Lowest final grade: 63.60', 1, '2026-03-27 14:53:49'),
(1153, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 14:54:07'),
(1154, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 14:54:07'),
(1155, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 14:54:07'),
(1156, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:54:07'),
(1157, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:54:07'),
(1158, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 63.60', 1, '2026-03-27 14:54:07'),
(1159, 9, 'Failed Subject Final Grade', 'Lowest final grade: 63.60', 1, '2026-03-27 14:54:07'),
(1160, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-27 14:54:34'),
(1161, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-27 14:54:34'),
(1162, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-27 14:54:34'),
(1163, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:54:34'),
(1164, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-27 14:54:34'),
(1165, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 63.60', 1, '2026-03-27 14:54:34'),
(1166, 9, 'Failed Subject Final Grade', 'Lowest final grade: 63.60', 1, '2026-03-27 14:54:34'),
(1167, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-28 15:16:11'),
(1168, 2, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-03-28 15:16:11'),
(1169, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-28 15:16:11'),
(1170, 7, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-28 15:16:11'),
(1171, 8, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-03-28 15:16:11'),
(1172, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 63.60', 1, '2026-03-28 15:16:11'),
(1173, 9, 'Failed Subject Final Grade', 'Lowest final grade: 63.60', 1, '2026-03-28 15:16:11'),
(1174, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-28 15:17:08'),
(1175, 2, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:17:08'),
(1176, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-28 15:17:08'),
(1177, 7, 'Chronic Absence', 'Absence rate: 80.00%', 1, '2026-03-28 15:17:08'),
(1178, 8, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-03-28 15:17:08'),
(1179, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 70.00', 1, '2026-03-28 15:17:08'),
(1180, 9, 'Failed Subject Final Grade', 'Lowest final grade: 70.00', 1, '2026-03-28 15:17:08'),
(1181, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-28 15:18:01'),
(1182, 2, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:18:01'),
(1183, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-28 15:18:01'),
(1184, 7, 'Chronic Absence', 'Absence rate: 80.00%', 1, '2026-03-28 15:18:01'),
(1185, 8, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-03-28 15:18:01'),
(1186, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 70.00', 1, '2026-03-28 15:18:01'),
(1187, 9, 'Chronic Absence', 'Absence rate: 50.00%', 1, '2026-03-28 15:18:01'),
(1188, 9, 'Failed Subject Final Grade', 'Lowest final grade: 70.00', 1, '2026-03-28 15:18:01'),
(1189, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-28 15:25:27'),
(1190, 2, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:25:27'),
(1191, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-28 15:25:27'),
(1192, 7, 'Chronic Absence', 'Absence rate: 80.00%', 1, '2026-03-28 15:25:27'),
(1193, 8, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-03-28 15:25:27'),
(1194, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 70.00', 1, '2026-03-28 15:25:27'),
(1195, 9, 'Chronic Absence', 'Absence rate: 50.00%', 1, '2026-03-28 15:25:27'),
(1196, 9, 'Failed Subject Final Grade', 'Lowest final grade: 70.00', 1, '2026-03-28 15:25:27'),
(1197, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-28 15:25:43'),
(1198, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-03-28 15:25:43'),
(1199, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-28 15:25:43'),
(1200, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:25:43'),
(1201, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:25:43'),
(1202, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 70.00', 1, '2026-03-28 15:25:43'),
(1203, 9, 'Failed Subject Final Grade', 'Lowest final grade: 70.00', 1, '2026-03-28 15:25:43'),
(1204, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-28 15:26:14'),
(1205, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-03-28 15:26:14'),
(1206, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-28 15:26:14'),
(1207, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:26:14'),
(1208, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:26:14'),
(1209, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 70.00', 1, '2026-03-28 15:26:14'),
(1210, 9, 'Failed Subject Final Grade', 'Lowest final grade: 70.00', 1, '2026-03-28 15:26:14'),
(1211, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-28 15:26:18'),
(1212, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-03-28 15:26:18'),
(1213, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-28 15:26:18'),
(1214, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:26:18'),
(1215, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:26:18'),
(1216, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-28 15:26:38'),
(1217, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-03-28 15:26:38'),
(1218, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-28 15:26:38'),
(1219, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:26:38'),
(1220, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:26:38'),
(1221, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-28 15:26:40'),
(1222, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-03-28 15:26:40'),
(1223, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-28 15:26:40');
INSERT INTO `risk_indicators` (`indicator_id`, `risk_assessment_id`, `indicator_type`, `details`, `is_deleted`, `deleted_at`) VALUES
(1224, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:26:40'),
(1225, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:26:40'),
(1226, 9, 'Chronic Absence', 'Absence rate: 50.00%', 1, '2026-03-28 15:26:40'),
(1227, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-28 15:38:53'),
(1228, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-03-28 15:38:53'),
(1229, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-28 15:38:53'),
(1230, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:38:53'),
(1231, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:38:53'),
(1232, 9, 'Chronic Absence', 'Absence rate: 50.00%', 1, '2026-03-28 15:38:53'),
(1233, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-28 15:39:59'),
(1234, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-03-28 15:39:59'),
(1235, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-28 15:39:59'),
(1236, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:39:59'),
(1237, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:39:59'),
(1238, 9, 'Chronic Absence', 'Absence rate: 50.00%', 1, '2026-03-28 15:39:59'),
(1239, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-28 15:40:38'),
(1240, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-03-28 15:40:38'),
(1241, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-28 15:40:38'),
(1242, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:40:38'),
(1243, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:40:38'),
(1244, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-28 15:41:59'),
(1245, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-03-28 15:41:59'),
(1246, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-28 15:41:59'),
(1247, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:41:59'),
(1248, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-28 15:41:59'),
(1249, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 74.00', 1, '2026-03-28 15:41:59'),
(1250, 9, 'Failed Subject Final Grade', 'Lowest final grade: 74.00', 1, '2026-03-28 15:41:59'),
(1251, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-03-29 23:22:45'),
(1252, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-03-29 23:22:45'),
(1253, 6, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-03-29 23:22:45'),
(1254, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-29 23:22:45'),
(1255, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-03-29 23:22:45'),
(1256, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 74.00', 1, '2026-03-29 23:22:45'),
(1257, 9, 'Failed Subject Final Grade', 'Lowest final grade: 74.00', 1, '2026-03-29 23:22:45'),
(1258, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:21:45'),
(1259, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:21:45'),
(1260, 6, 'Failing Quarterly Grade', 'Lowest quarterly grade: 72.00', 1, '2026-04-22 04:21:45'),
(1261, 6, 'Chronic Absence', 'Absence rate: 66.67%', 1, '2026-04-22 04:21:45'),
(1262, 6, 'Failed Subject Final Grade', 'Lowest final grade: 72.00', 1, '2026-04-22 04:21:45'),
(1263, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:21:45'),
(1264, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:21:45'),
(1265, 9, 'Failing Quarterly Grade', 'Lowest quarterly grade: 74.00', 1, '2026-04-22 04:21:45'),
(1266, 9, 'Failed Subject Final Grade', 'Lowest final grade: 74.00', 1, '2026-04-22 04:21:45'),
(1267, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:25:23'),
(1268, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:25:23'),
(1269, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:25:23'),
(1270, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:25:23'),
(1271, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:25:23'),
(1272, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:23'),
(1273, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:23'),
(1274, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:23'),
(1275, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:25:23'),
(1276, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:23'),
(1277, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:25:23'),
(1278, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:25:23'),
(1279, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:25:23'),
(1280, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:25:23'),
(1281, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:25:23'),
(1282, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:23'),
(1283, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:23'),
(1284, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:23'),
(1285, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:25:23'),
(1286, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:23'),
(1287, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:25:27'),
(1288, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:25:27'),
(1289, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:25:27'),
(1290, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:25:27'),
(1291, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:25:27'),
(1292, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:27'),
(1293, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:27'),
(1294, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:27'),
(1295, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:25:27'),
(1296, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:27'),
(1297, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:25:27'),
(1298, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:25:27'),
(1299, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:25:27'),
(1300, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:25:27'),
(1301, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:25:27'),
(1302, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:27'),
(1303, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:27'),
(1304, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:27'),
(1305, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:25:27'),
(1306, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:27'),
(1307, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:25:31'),
(1308, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:25:31'),
(1309, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:25:31'),
(1310, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:25:31'),
(1311, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:25:31'),
(1312, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:31'),
(1313, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:31'),
(1314, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:31'),
(1315, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:25:31'),
(1316, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:31'),
(1317, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:25:33'),
(1318, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:25:33'),
(1319, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:25:33'),
(1320, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:25:33'),
(1321, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:25:33'),
(1322, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:33'),
(1323, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:33'),
(1324, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:33'),
(1325, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:25:33'),
(1326, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:25:33'),
(1327, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:26:22'),
(1328, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:26:22'),
(1329, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:26:22'),
(1330, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:26:22'),
(1331, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:26:22'),
(1332, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:26:22'),
(1333, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:26:22'),
(1334, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:26:22'),
(1335, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:26:22'),
(1336, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:26:22'),
(1337, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:26:23'),
(1338, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:26:23'),
(1339, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:26:23'),
(1340, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:26:23'),
(1341, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:26:23'),
(1342, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:26:23'),
(1343, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:26:23'),
(1344, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:26:23'),
(1345, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:26:23'),
(1346, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:26:23'),
(1347, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:26:25'),
(1348, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:26:25'),
(1349, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:26:25'),
(1350, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:26:25'),
(1351, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:26:25'),
(1352, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:26:25'),
(1353, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:26:25'),
(1354, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:26:25'),
(1355, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:26:25'),
(1356, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:26:25'),
(1357, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:28:59'),
(1358, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:28:59'),
(1359, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:28:59'),
(1360, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:28:59'),
(1361, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:28:59'),
(1362, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:28:59'),
(1363, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:28:59'),
(1364, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:28:59'),
(1365, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:28:59'),
(1366, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:28:59'),
(1367, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:28:59'),
(1368, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:28:59'),
(1369, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:28:59'),
(1370, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:28:59'),
(1371, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:28:59'),
(1372, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:28:59'),
(1373, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:28:59'),
(1374, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:28:59'),
(1375, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:28:59'),
(1376, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:28:59'),
(1377, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:29:00'),
(1378, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:29:00'),
(1379, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:29:00'),
(1380, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:29:00'),
(1381, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:29:00'),
(1382, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:29:00'),
(1383, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:29:00'),
(1384, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:29:00'),
(1385, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:29:00'),
(1386, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:29:00'),
(1387, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:39:33'),
(1388, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:39:33'),
(1389, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:39:33'),
(1390, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:39:33'),
(1391, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:39:33'),
(1392, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:33'),
(1393, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:33'),
(1394, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:33'),
(1395, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:39:33'),
(1396, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:33'),
(1397, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:39:45'),
(1398, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:39:45'),
(1399, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:39:45'),
(1400, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:39:45'),
(1401, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:39:45'),
(1402, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:45'),
(1403, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:45'),
(1404, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:45'),
(1405, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:39:45'),
(1406, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:45'),
(1407, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:39:46'),
(1408, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:39:46'),
(1409, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:39:46'),
(1410, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:39:46'),
(1411, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:39:46'),
(1412, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:46'),
(1413, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:46'),
(1414, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:46'),
(1415, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:39:46'),
(1416, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:46'),
(1417, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:39:46'),
(1418, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:39:46'),
(1419, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:39:46'),
(1420, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:39:46'),
(1421, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:39:46'),
(1422, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:46'),
(1423, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:46'),
(1424, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:46'),
(1425, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:39:46'),
(1426, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:46'),
(1427, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:39:47'),
(1428, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:39:47'),
(1429, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:39:47'),
(1430, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:39:47'),
(1431, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:39:47'),
(1432, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:47'),
(1433, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:47'),
(1434, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:47'),
(1435, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:39:47'),
(1436, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:47'),
(1437, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:39:49'),
(1438, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:39:49'),
(1439, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:39:49'),
(1440, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:39:49'),
(1441, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:39:49'),
(1442, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:49'),
(1443, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:49'),
(1444, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:49'),
(1445, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:39:49'),
(1446, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:49'),
(1447, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:39:50'),
(1448, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:39:50'),
(1449, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:39:50'),
(1450, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:39:50'),
(1451, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:39:50'),
(1452, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:50'),
(1453, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:50'),
(1454, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:50'),
(1455, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:39:50'),
(1456, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:50'),
(1457, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:39:50'),
(1458, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:39:50'),
(1459, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:39:50'),
(1460, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:39:50'),
(1461, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:39:50'),
(1462, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:50'),
(1463, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:50'),
(1464, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:50'),
(1465, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:39:50'),
(1466, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:39:50'),
(1467, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:40:09'),
(1468, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:40:09'),
(1469, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:40:09'),
(1470, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:40:09'),
(1471, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:40:09'),
(1472, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:40:09'),
(1473, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:40:09'),
(1474, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:40:09'),
(1475, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:40:09'),
(1476, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:40:09'),
(1477, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:45:59'),
(1478, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:45:59'),
(1479, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:45:59'),
(1480, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:45:59'),
(1481, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:45:59'),
(1482, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:45:59'),
(1483, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:45:59'),
(1484, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:45:59'),
(1485, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:45:59'),
(1486, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:45:59'),
(1487, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:52:57'),
(1488, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:52:57'),
(1489, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:52:57'),
(1490, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:52:57'),
(1491, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:52:57'),
(1492, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:52:57'),
(1493, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:52:57'),
(1494, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:52:57'),
(1495, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:52:57'),
(1496, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:52:57'),
(1497, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:53:00'),
(1498, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:53:00'),
(1499, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:53:00'),
(1500, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:53:00'),
(1501, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:53:00'),
(1502, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:53:00'),
(1503, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:53:00'),
(1504, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:53:00'),
(1505, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:53:00'),
(1506, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:53:00'),
(1507, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:53:08'),
(1508, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:53:08'),
(1509, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:53:08'),
(1510, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:53:08'),
(1511, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:53:08'),
(1512, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:53:08'),
(1513, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:53:08'),
(1514, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:53:08'),
(1515, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:53:08'),
(1516, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:53:08'),
(1517, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:57:37'),
(1518, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:57:37'),
(1519, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:57:37'),
(1520, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:57:37'),
(1521, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:57:37'),
(1522, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:57:37'),
(1523, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:57:37'),
(1524, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:57:37'),
(1525, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:57:37'),
(1526, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:57:37'),
(1527, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:57:40'),
(1528, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:57:40'),
(1529, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:57:40'),
(1530, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:57:40'),
(1531, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:57:40'),
(1532, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:57:40'),
(1533, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:57:40'),
(1534, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:57:40'),
(1535, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:57:40'),
(1536, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:57:40'),
(1537, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 04:57:46'),
(1538, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 04:57:46'),
(1539, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 04:57:46'),
(1540, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:57:46'),
(1541, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 04:57:46'),
(1542, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:57:46'),
(1543, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:57:46'),
(1544, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:57:46'),
(1545, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 04:57:46'),
(1546, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 04:57:46'),
(1547, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 05:02:29'),
(1548, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 05:02:29'),
(1549, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 05:02:29'),
(1550, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 05:02:29'),
(1551, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 05:02:29'),
(1552, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:02:29'),
(1553, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:02:29'),
(1554, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:02:29'),
(1555, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 05:02:29'),
(1556, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:02:29'),
(1557, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 05:02:34'),
(1558, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 05:02:34'),
(1559, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 05:02:34'),
(1560, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 05:02:34'),
(1561, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 05:02:34'),
(1562, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:02:34'),
(1563, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:02:34'),
(1564, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:02:34'),
(1565, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 05:02:34'),
(1566, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:02:34'),
(1567, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 05:02:42'),
(1568, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 05:02:42'),
(1569, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 05:02:42'),
(1570, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 05:02:42'),
(1571, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 05:02:42'),
(1572, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:02:42'),
(1573, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:02:42'),
(1574, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:02:42'),
(1575, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 05:02:42'),
(1576, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:02:42'),
(1577, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 05:06:43'),
(1578, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 05:06:43'),
(1579, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 05:06:43'),
(1580, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 05:06:43'),
(1581, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 05:06:43'),
(1582, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:06:43'),
(1583, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:06:43'),
(1584, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:06:43'),
(1585, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 05:06:43'),
(1586, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:06:43'),
(1587, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 05:06:45'),
(1588, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 05:06:45'),
(1589, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 05:06:45'),
(1590, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 05:06:45'),
(1591, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 05:06:45'),
(1592, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:06:45'),
(1593, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:06:45'),
(1594, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:06:45'),
(1595, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 05:06:45'),
(1596, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:06:45'),
(1597, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 05:08:27'),
(1598, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 05:08:27'),
(1599, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 05:08:27'),
(1600, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 05:08:27'),
(1601, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 05:08:27'),
(1602, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:08:27'),
(1603, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:08:27'),
(1604, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:08:27'),
(1605, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 05:08:27'),
(1606, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:08:27'),
(1607, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 05:08:29'),
(1608, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 05:08:29'),
(1609, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 05:08:29'),
(1610, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 05:08:29'),
(1611, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 05:08:29'),
(1612, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:08:29'),
(1613, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:08:29'),
(1614, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:08:29'),
(1615, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 05:08:29'),
(1616, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:08:29'),
(1617, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 05:08:31'),
(1618, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 05:08:31'),
(1619, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 05:08:31'),
(1620, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 05:08:31'),
(1621, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 05:08:31'),
(1622, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:08:31'),
(1623, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:08:31'),
(1624, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:08:31'),
(1625, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 05:08:31'),
(1626, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 05:08:31'),
(1627, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 06:18:25'),
(1628, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 06:18:25'),
(1629, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 06:18:25'),
(1630, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:18:25'),
(1631, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:18:25'),
(1632, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:18:25'),
(1633, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:18:25'),
(1634, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:18:25'),
(1635, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 06:18:25'),
(1636, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:18:25'),
(1637, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 06:18:28'),
(1638, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 06:18:28'),
(1639, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 06:18:28'),
(1640, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:18:28'),
(1641, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:18:28'),
(1642, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:18:28'),
(1643, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:18:28'),
(1644, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:18:28'),
(1645, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 06:18:28'),
(1646, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:18:28'),
(1647, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 06:30:29'),
(1648, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 06:30:29'),
(1649, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 06:30:29'),
(1650, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:30:29'),
(1651, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:30:29'),
(1652, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:30:29'),
(1653, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:30:29'),
(1654, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:30:29'),
(1655, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 06:30:29'),
(1656, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:30:29'),
(1657, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 06:30:31'),
(1658, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 06:30:31'),
(1659, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 06:30:31'),
(1660, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:30:31'),
(1661, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:30:31'),
(1662, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:30:31'),
(1663, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:30:31'),
(1664, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:30:31'),
(1665, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 06:30:31'),
(1666, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:30:31'),
(1667, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 06:31:02'),
(1668, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 06:31:02'),
(1669, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 06:31:02'),
(1670, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:31:02'),
(1671, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:31:02'),
(1672, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:31:02'),
(1673, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:31:02'),
(1674, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:31:02'),
(1675, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 06:31:02'),
(1676, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:31:02'),
(1677, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 06:31:04'),
(1678, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 06:31:04'),
(1679, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 06:31:04'),
(1680, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:31:04'),
(1681, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:31:04'),
(1682, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:31:04'),
(1683, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:31:04'),
(1684, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:31:04'),
(1685, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 06:31:04'),
(1686, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:31:04'),
(1687, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 06:32:18'),
(1688, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 06:32:18'),
(1689, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 06:32:18'),
(1690, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:32:18'),
(1691, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:32:18'),
(1692, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:32:18'),
(1693, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:32:18'),
(1694, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:32:18'),
(1695, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 06:32:18'),
(1696, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:32:18'),
(1697, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 06:32:34'),
(1698, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 06:32:34'),
(1699, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 06:32:34'),
(1700, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:32:34'),
(1701, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:32:34'),
(1702, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:32:34'),
(1703, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:32:34'),
(1704, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:32:34'),
(1705, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 06:32:34'),
(1706, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:32:34'),
(1707, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 06:36:17'),
(1708, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 06:36:17'),
(1709, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 06:36:17'),
(1710, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:36:17'),
(1711, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:36:17'),
(1712, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:36:17'),
(1713, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:36:17'),
(1714, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:36:17'),
(1715, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 06:36:17'),
(1716, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:36:17'),
(1717, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 06:36:37'),
(1718, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 06:36:37'),
(1719, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 06:36:37'),
(1720, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:36:37'),
(1721, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:36:37'),
(1722, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:36:37'),
(1723, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:36:37'),
(1724, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:36:37'),
(1725, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 06:36:37'),
(1726, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:36:37'),
(1727, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 06:42:13'),
(1728, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 06:42:13'),
(1729, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 06:42:13'),
(1730, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:42:13'),
(1731, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:42:13'),
(1732, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:42:13'),
(1733, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:42:13'),
(1734, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:42:13'),
(1735, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 06:42:13'),
(1736, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:42:13'),
(1737, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 06:42:44'),
(1738, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 06:42:44'),
(1739, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 06:42:44'),
(1740, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:42:44'),
(1741, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:42:44'),
(1742, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:42:44'),
(1743, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:42:44'),
(1744, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:42:44'),
(1745, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 06:42:44'),
(1746, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:42:44'),
(1747, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 06:42:48'),
(1748, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 06:42:48'),
(1749, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 06:42:48'),
(1750, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:42:48'),
(1751, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:42:48'),
(1752, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:42:48'),
(1753, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:42:48'),
(1754, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:42:48'),
(1755, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 06:42:48'),
(1756, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:42:48'),
(1757, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 06:43:08'),
(1758, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 06:43:08'),
(1759, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 06:43:08'),
(1760, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:43:08'),
(1761, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:43:08'),
(1762, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:43:08'),
(1763, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:43:08'),
(1764, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:43:08'),
(1765, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 06:43:08'),
(1766, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:43:08'),
(1767, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 06:47:41'),
(1768, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 06:47:41'),
(1769, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 06:47:41'),
(1770, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:47:41'),
(1771, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 06:47:41'),
(1772, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:47:41'),
(1773, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:47:41'),
(1774, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:47:41'),
(1775, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 06:47:41'),
(1776, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 06:47:41'),
(1777, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 19:16:16'),
(1778, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 19:16:16'),
(1779, 6, 'Chronic Absence', 'Absence rate: 60.00%', 1, '2026-04-22 19:16:16'),
(1780, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 19:16:16'),
(1781, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 19:16:16'),
(1782, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 19:16:16'),
(1783, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 19:16:16'),
(1784, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 19:16:16'),
(1785, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 19:16:16'),
(1786, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 19:16:16'),
(1787, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-22 19:17:43');
INSERT INTO `risk_indicators` (`indicator_id`, `risk_assessment_id`, `indicator_type`, `details`, `is_deleted`, `deleted_at`) VALUES
(1788, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-22 19:17:43'),
(1789, 6, 'Chronic Absence', 'Absence rate: 50.00%', 1, '2026-04-22 19:17:43'),
(1790, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 19:17:43'),
(1791, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-22 19:17:43'),
(1792, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 19:17:43'),
(1793, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 19:17:43'),
(1794, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 19:17:43'),
(1795, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-22 19:17:43'),
(1796, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 19:17:43'),
(1797, 14, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-22 19:17:43'),
(1798, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-24 16:35:04'),
(1799, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-24 16:35:04'),
(1800, 6, 'Chronic Absence', 'Absence rate: 50.00%', 1, '2026-04-24 16:35:04'),
(1801, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-24 16:35:04'),
(1802, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-24 16:35:04'),
(1803, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-24 16:35:04'),
(1804, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-24 16:35:04'),
(1805, 12, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-24 16:35:04'),
(1806, 12, 'Chronic Absence', 'Absence rate: 33.33%', 1, '2026-04-24 16:35:04'),
(1807, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-24 16:35:04'),
(1808, 14, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-24 16:35:04'),
(1809, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-24 16:38:01'),
(1810, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-24 16:38:01'),
(1811, 6, 'Chronic Absence', 'Absence rate: 50.00%', 1, '2026-04-24 16:38:01'),
(1812, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-24 16:38:01'),
(1813, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-24 16:38:01'),
(1814, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-24 16:38:01'),
(1815, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-24 16:38:01'),
(1816, 12, 'Incomplete Grades', 'Encoded 1/11 subjects', 1, '2026-04-24 16:38:01'),
(1817, 12, 'Chronic Absence', 'Absence rate: 25.00%', 1, '2026-04-24 16:38:01'),
(1818, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-24 16:38:01'),
(1819, 14, 'Failing Quarterly Grade', 'Lowest quarterly grade: 74.05', 1, '2026-04-24 16:38:01'),
(1820, 14, 'Failed Subject Final Grade', 'Lowest final grade: 74.05', 1, '2026-04-24 16:38:01'),
(1821, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 1, '2026-04-24 20:42:19'),
(1822, 2, 'Chronic Absence', 'Absence rate: 20.00%', 1, '2026-04-24 20:42:19'),
(1823, 6, 'Chronic Absence', 'Absence rate: 50.00%', 1, '2026-04-24 20:42:19'),
(1824, 7, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-24 20:42:19'),
(1825, 8, 'Chronic Absence', 'Absence rate: 40.00%', 1, '2026-04-24 20:42:19'),
(1826, 10, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-24 20:42:19'),
(1827, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-24 20:42:19'),
(1828, 12, 'Incomplete Grades', 'Encoded 1/11 subjects', 1, '2026-04-24 20:42:19'),
(1829, 12, 'Chronic Absence', 'Absence rate: 25.00%', 1, '2026-04-24 20:42:19'),
(1830, 13, 'No Encoded Grades', 'No quarterly grades encoded for this period', 1, '2026-04-24 20:42:19'),
(1831, 14, 'Failing Quarterly Grade', 'Lowest quarterly grade: 74.05', 1, '2026-04-24 20:42:19'),
(1832, 14, 'Failed Subject Final Grade', 'Lowest final grade: 74.05', 1, '2026-04-24 20:42:19'),
(1833, 3, 'Incomplete Grades', 'Encoded 7/8 subjects', 0, NULL),
(1834, 2, 'Chronic Absence', 'Absence rate: 20.00%', 0, NULL),
(1835, 6, 'Chronic Absence', 'Absence rate: 50.00%', 0, NULL),
(1836, 7, 'Chronic Absence', 'Absence rate: 40.00%', 0, NULL),
(1837, 8, 'Chronic Absence', 'Absence rate: 40.00%', 0, NULL),
(1838, 10, 'Incomplete Grades', 'Encoded 2/11 subjects', 0, NULL),
(1839, 10, 'Failing Quarterly Grade', 'Lowest quarterly grade: 68.25', 0, NULL),
(1840, 10, 'Failed Subject Final Grade', 'Lowest final grade: 68.25', 0, NULL),
(1841, 11, 'No Encoded Grades', 'No quarterly grades encoded for this period', 0, NULL),
(1842, 12, 'Incomplete Grades', 'Encoded 1/11 subjects', 0, NULL),
(1843, 12, 'Failing Quarterly Grade', 'Lowest quarterly grade: 69.20', 0, NULL),
(1844, 12, 'Chronic Absence', 'Absence rate: 40.00%', 0, NULL),
(1845, 12, 'Failed Subject Final Grade', 'Lowest final grade: 69.20', 0, NULL),
(1846, 12, 'Low General Average', 'General average: 69.20', 0, NULL),
(1847, 13, 'Incomplete Grades', 'Encoded 1/8 subjects', 0, NULL),
(1848, 14, 'Chronic Absence', 'Absence rate: 100.00%', 0, NULL);

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
(10, 'learners', NULL, 0, NULL),
(11, 'Registrar', NULL, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `role_permissions`
--

CREATE TABLE `role_permissions` (
  `role_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
(1, 'school_name', 'G.Pelaez Integrated School', 'Official name of the school', NULL, '2026-03-26 11:43:41', 0, NULL),
(2, 'school_id', '912313', 'DepEd School ID (printed on enrollment form)', NULL, '2026-03-26 11:43:26', 0, NULL),
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
(5, 'Aquarius', 8, 5, NULL, 45, 0, NULL),
(6, 'Test Section SY2', 1, 2, NULL, 45, 0, NULL);

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
(1, 'admin', '$2y$10$R41EtugQNllelt9lXUpfbOFHFpF7CjkRPjqd24/xgePqu3KnVs/XG', 8, 1, '2026-04-24 17:49:27', '2026-02-20 09:50:24', '2026-04-24 17:49:27', 0, NULL),
(26, '911', '$2y$10$AQSa5DbbKrugxc69Gr6VZzOVbuqV4gr.G6Ntmc8HUgXghiK0T6O71G', 8, 1, NULL, '2026-02-21 01:12:41', '2026-02-21 13:32:42', 0, NULL),
(27, '12-12-12', '$2y$10$66FPGWticM8NG/Vg1u.dYObUkMIJScmMDOdrccZJnJL5.fmzi8pNS', 8, 1, '2026-04-16 16:33:37', '2026-02-21 12:37:24', '2026-04-16 16:33:37', 0, NULL),
(28, '02-2324-06121', '$2y$10$bC9jkmOMT2GP2KgshYw7Zuh6LJ6tRF3ZAiUJNNbHfpZAxfWPYSHzi', 10, 1, '2026-04-24 16:22:26', '2026-02-23 13:07:42', '2026-04-24 18:59:04', 0, NULL),
(29, '28-28-28', '$2y$10$ugJkwO2s9MXWDrVSC277ZOAqcNowWhiCfhvZvPf/jbKJiFBHRhKeC', 9, 1, '2026-04-24 17:01:41', '2026-02-23 14:16:36', '2026-04-24 17:01:41', 0, NULL),
(30, '09090909', '$2y$10$sAntjE6MDcA5iPw/iG41K.enuvjAU/wC4p7j2FKIGjaRLlD8WeFcu', 8, 1, '2026-04-24 19:30:48', '2026-03-27 14:31:28', '2026-04-24 19:30:48', 0, NULL),
(31, '45888', '$2y$10$egD2SOc388kYfRdau6zK6eJ7JlMQg03YSDkh0ZZUOoDKRr.atMVN2', 8, 1, NULL, '2026-03-28 14:51:21', '2026-03-28 14:51:21', 0, NULL),
(32, '999000000002', '$2y$10$cuV3pqILhvWMuXy8Pyz/oOcsuOSIKbxPm8RW2Bb5t6lNujM2KnVNa', 10, 1, NULL, '2026-04-21 09:34:23', '2026-04-21 09:34:23', 0, NULL),
(33, '999000000003', '$2y$10$EpFWeWvYIyiMh3YU.yb2qejR87kTeFX2/PXRyRQqaTackugff2j5u', 10, 1, '2026-04-21 10:19:57', '2026-04-21 10:17:59', '2026-04-21 10:19:57', 0, NULL),
(34, '999000000004', '$2y$10$S3PbR/b7ddwRxqvEHSp0H.JXntjYC5ymO48Sp.8kqsqBM8bvBOgRy', 10, 1, NULL, '2026-04-21 10:22:00', '2026-04-21 10:22:00', 0, NULL),
(35, '2026', '$2y$10$mGhBaVoMYmb0vdKdAQbhPu4yxFih5zGT4Xxv/NwmKlUF7InfIkZNW', 9, 1, '2026-04-24 19:33:28', '2026-04-21 22:28:18', '2026-04-24 19:33:28', 0, NULL),
(36, '234234234234', '$2y$10$Q7b8USspHHFOWi9uG9Tj9utM6Hax3Q9ruPOmqrnhThGdAmwQjmxVa', 10, 1, NULL, '2026-04-22 00:27:11', '2026-04-22 00:27:11', 0, NULL),
(37, 'admin123', '$2y$10$SY1rySTiEeJZlf3OkkGzjOhXx2idEM1xNkIJizy0xOQVomkdgw4Ba', 11, 1, '2026-04-24 16:52:58', '2026-04-22 02:29:10', '2026-04-24 16:52:58', 0, NULL),
(38, '123456789101', '$2y$10$cc.tmlI9qm9mEUZ8hXfC1.O/zCAdBYVHK4hkGbWAA0Cq8w9/tFf0G', 10, 1, NULL, '2026-04-22 19:15:52', '2026-04-22 19:15:52', 0, NULL),
(39, '2026-1001', '$2y$10$FA7kxecMV1yX2ttTuO7i8u5n0o4Nn755KpqGnJfAR7/obIJDZ/5T2', 9, 1, '2026-04-24 20:36:41', '2026-04-24 16:50:29', '2026-04-24 20:36:41', 0, NULL);

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
  ADD UNIQUE KEY `uq_sf2_attendance` (`enrollment_id`,`class_id`,`attendance_date`,`session`),
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
-- Indexes for table `class_offering_assignment_requests`
--
ALTER TABLE `class_offering_assignment_requests`
  ADD PRIMARY KEY (`request_id`),
  ADD KEY `idx_coar_section_sy` (`section_id`,`school_year_id`),
  ADD KEY `idx_coar_status` (`status`);

--
-- Indexes for table `class_offering_assignment_request_items`
--
ALTER TABLE `class_offering_assignment_request_items`
  ADD PRIMARY KEY (`request_item_id`),
  ADD UNIQUE KEY `uq_coari_request_subject` (`request_id`,`subject_id`),
  ADD KEY `idx_coari_request` (`request_id`),
  ADD KEY `idx_coari_subject_teacher` (`subject_id`,`teacher_id`);

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
-- Indexes for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD PRIMARY KEY (`role_id`,`permission_id`),
  ADD KEY `idx_rp_permission` (`permission_id`),
  ADD KEY `idx_rp_created_by` (`created_by`);

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
  MODIFY `announcement_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=73;

--
-- AUTO_INCREMENT for table `attendance`
--
ALTER TABLE `attendance`
  MODIFY `attendance_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;

--
-- AUTO_INCREMENT for table `attendance_monthly_summaries`
--
ALTER TABLE `attendance_monthly_summaries`
  MODIFY `summary_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `audit_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `citizenships`
--
ALTER TABLE `citizenships`
  MODIFY `citizenship_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `class_offerings`
--
ALTER TABLE `class_offerings`
  MODIFY `class_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=89;

--
-- AUTO_INCREMENT for table `class_offering_assignment_requests`
--
ALTER TABLE `class_offering_assignment_requests`
  MODIFY `request_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `class_offering_assignment_request_items`
--
ALTER TABLE `class_offering_assignment_request_items`
  MODIFY `request_item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

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
  MODIFY `emergency_contact_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `employees`
--
ALTER TABLE `employees`
  MODIFY `employee_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `enrollments`
--
ALTER TABLE `enrollments`
  MODIFY `enrollment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

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
  MODIFY `family_member_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=72;

--
-- AUTO_INCREMENT for table `final_grades`
--
ALTER TABLE `final_grades`
  MODIFY `final_grade_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `general_averages`
--
ALTER TABLE `general_averages`
  MODIFY `general_average_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

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
  MODIFY `grade_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=347;

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
  MODIFY `learner_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `learner_addresses`
--
ALTER TABLE `learner_addresses`
  MODIFY `learner_address_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

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
  MODIFY `previous_school_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

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
  MODIFY `notification_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=356;

--
-- AUTO_INCREMENT for table `positions`
--
ALTER TABLE `positions`
  MODIFY `position_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `report_cards`
--
ALTER TABLE `report_cards`
  MODIFY `report_card_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `report_card_grades`
--
ALTER TABLE `report_card_grades`
  MODIFY `rc_grade_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `risk_assessments`
--
ALTER TABLE `risk_assessments`
  MODIFY `risk_assessment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `risk_indicators`
--
ALTER TABLE `risk_indicators`
  MODIFY `indicator_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1849;

--
-- AUTO_INCREMENT for table `risk_levels`
--
ALTER TABLE `risk_levels`
  MODIFY `risk_level_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `role_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `school_settings`
--
ALTER TABLE `school_settings`
  MODIFY `setting_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

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
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

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
