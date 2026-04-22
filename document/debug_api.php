<?php
// Simple API test script
header('Content-Type: application/json');

require_once __DIR__ . '/api/database/connection.php';

try {
    // Test sections
    $stmt = $conn->prepare("SELECT section_id, grade_level, section_name FROM sections WHERE is_deleted = 0 LIMIT 5");
    $stmt->execute();
    $sections = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Test school years
    $stmt = $conn->prepare("SELECT school_year_id, year_label, is_active FROM school_years WHERE is_deleted = 0 ORDER BY year_start DESC LIMIT 3");
    $stmt->execute();
    $schoolYears = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Test enrollments/roster for first section if available
    $roster = [];
    if (!empty($sections)) {
        $sectionId = $sections[0]['section_id'];
        $schoolYearId = !empty($schoolYears) ? $schoolYears[0]['school_year_id'] : 0;
        
        if ($schoolYearId > 0) {
            $stmt = $conn->prepare("SELECT e.enrollment_id, e.learner_id, l.lrn, 
                CONCAT(l.last_name, ', ', l.first_name) AS learner_name,
                l.gender, gl.grade_name, sec.section_name, sy.year_label, ga.general_average
                FROM enrollments e
                JOIN learners l ON e.learner_id = l.learner_id
                LEFT JOIN grade_levels gl ON gl.grade_level_id = e.grade_level_id
                LEFT JOIN sections sec ON sec.section_id = e.section_id
                LEFT JOIN school_years sy ON sy.school_year_id = e.school_year_id
                LEFT JOIN general_averages ga ON ga.enrollment_id = e.enrollment_id
                WHERE e.is_deleted = 0 AND e.section_id = ? AND e.school_year_id = ?
                ORDER BY l.last_name, l.first_name
                LIMIT 5");
            $stmt->execute([$sectionId, $schoolYearId]);
            $roster = $stmt->fetchAll(PDO::FETCH_ASSOC);
        }
    }
    
    echo json_encode([
        'success' => true,
        'sections' => $sections,
        'school_years' => $schoolYears,
        'roster_sample' => $roster,
        'total_sections' => count($sections),
        'total_school_years' => count($schoolYears),
        'total_roster_sample' => count($roster)
    ], JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ], JSON_PRETTY_PRINT);
}
?>
