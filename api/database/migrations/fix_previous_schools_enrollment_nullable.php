<?php
/**
 * Migration: Make enrollment_id nullable in learner_previous_schools table
 * Reason: Previous school information should be collected during registration,
 *         before enrollment happens. Enrollment_id will be updated later when
 *         the student is officially enrolled.
 */

if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    header('Content-Type: text/plain');
    echo "Forbidden\n";
    exit(1);
}

require_once __DIR__ . '/../connection.php';

try {
    echo "Starting migration: Making enrollment_id nullable in learner_previous_schools...\n";

    // Modify the enrollment_id column to allow NULL values
    $sql = "ALTER TABLE learner_previous_schools
            MODIFY COLUMN enrollment_id int(11) DEFAULT NULL
            COMMENT 'FK to enrollments - NULL if not yet enrolled, will be updated upon enrollment'";

    $conn->exec($sql);

    echo "✅ Successfully modified enrollment_id column to allow NULL values\n";
    echo "✅ Previous school information can now be stored during initial registration\n";

} catch (PDOException $e) {
    echo "❌ Migration failed: " . $e->getMessage() . "\n";
    exit(1);
}
?>
