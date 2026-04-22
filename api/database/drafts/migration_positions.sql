-- Migration: Add positions lookup and link to employees

CREATE TABLE IF NOT EXISTS `positions` (
  `position_id` int(11) NOT NULL AUTO_INCREMENT,
  `position_name` varchar(150) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`position_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Employee position lookup';

INSERT INTO `positions` (`position_name`) VALUES
('Principal'),
('Assistant Principal'),
('Registrar'),
('Teacher'),
('Guidance Counselor'),
('Librarian'),
('School Nurse'),
('ICT Coordinator'),
('Administrative Staff'),
('Utility Staff');

ALTER TABLE `employees`
  ADD COLUMN `position_id` int(11) DEFAULT NULL AFTER `address`;

CREATE INDEX `idx_employees_position_id` ON `employees` (`position_id`);

UPDATE `employees` e
JOIN `positions` p ON e.position = p.position_name
SET e.position_id = p.position_id
WHERE e.position IS NOT NULL;
