<?php
// Central audit-log helper.
// Call audit_log() after any successful INSERT / UPDATE / DELETE to record the change.

require_once __DIR__ . '/auth.php';

/**
 * Write an entry to the audit_logs table.
 *
 * @param PDO    $conn      Active DB connection (same transaction).
 * @param string $tableName DB table that was modified (e.g. 'roles').
 * @param ?int   $recordId  Primary key of the affected row (null if N/A).
 * @param string $action    'INSERT', 'UPDATE', or 'DELETE'.
 * @param ?array $oldValues Key-value map of the row BEFORE the change (null for INSERT).
 * @param ?array $newValues Key-value map of the row AFTER the change (null for DELETE).
 * @return bool  True on success.
 */
function audit_log(
    PDO $conn,
    string $tableName,
    ?int $recordId,
    string $action,
    ?array $oldValues = null,
    ?array $newValues = null
): bool {
    $userId = (int)($_SESSION['user_id'] ?? 0) ?: null;
    $ipAddress = $_SERVER['REMOTE_ADDR'] ?? null;

    // Truncate very long values to keep the row manageable.
    $oldJson = $oldValues !== null ? json_encode_utf8($oldValues) : null;
    $newJson = $newValues !== null ? json_encode_utf8($newValues) : null;

    try {
        $stmt = $conn->prepare(
            'INSERT INTO audit_logs (user_id, table_name, record_id, action, old_values, new_values, action_time, ip_address)
             VALUES (:user_id, :table_name, :record_id, :action, :old_values, :new_values, NOW(), :ip_address)'
        );
        $stmt->bindValue(':user_id', $userId, $userId === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
        $stmt->bindValue(':table_name', $tableName);
        $stmt->bindValue(':record_id', $recordId, $recordId === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
        $stmt->bindValue(':action', strtoupper($action));
        $stmt->bindValue(':old_values', $oldJson, $oldJson === null ? PDO::PARAM_NULL : PDO::PARAM_STR);
        $stmt->bindValue(':new_values', $newJson, $newJson === null ? PDO::PARAM_NULL : PDO::PARAM_STR);
        $stmt->bindValue(':ip_address', $ipAddress, $ipAddress === null ? PDO::PARAM_NULL : PDO::PARAM_STR);
        return $stmt->execute();
    } catch (Exception $e) {
        // Never let audit logging break the main operation.
        error_log('audit_log failed: ' . $e->getMessage());
        return false;
    }
}

/**
 * Convenience: fetch a single row by PK before an UPDATE/DELETE so we can
 * store the "old" values in the audit trail.
 *
 * @param PDO    $conn
 * @param string $tableName
 * @param string $pkColumn   Primary-key column name (e.g. 'role_id').
 * @param int    $pkValue
 * @return array|null  Associative row or null.
 */
function audit_fetch_old(PDO $conn, string $tableName, string $pkColumn, int $pkValue): ?array {
    try {
        // Whitelist: only allow known table/column combos to prevent injection.
        $allowed = [
            'announcements' => 'announcement_id',
            'roles' => 'role_id',
            'users' => 'user_id',
            'employees' => 'employee_id',
            'learners' => 'learner_id',
            'enrollments' => 'enrollment_id',
            'sections' => 'section_id',
            'subjects' => 'subject_id',
            'grade_levels' => 'grade_level_id',
            'school_years' => 'school_year_id',
            'positions' => 'position_id',
            'education_levels' => 'education_level_id',
            'citizenships' => 'citizenship_id',
            'civil_statuses' => 'civil_status_id',
            'religions' => 'religion_id',
            'family_relationships' => 'family_relationship_id',
            'name_extensions' => 'name_extension_id',
            'learner_statuses' => 'learner_status_id',
            'risk_levels' => 'risk_level_id',
            'honor_levels' => 'honor_level_id',
            'document_types' => 'document_type_id',
            'enrollment_types' => 'enrollment_type_id',
            'grading_period_statuses' => 'grading_period_status_id',
            'indigenous_groups' => 'indigenous_group_id',
            'intervention_statuses' => 'intervention_status_id',
            'learning_modalities' => 'learning_modality_id',
            'mother_tongues' => 'mother_tongue_id',
            'notification_types' => 'notification_type_id',
            'subject_codes' => 'subject_code_id',
            'grading_system_types' => 'grading_system_type_id',
            'class_offerings' => 'class_id',
            'grades' => 'grade_id',
            'final_grades' => 'final_grade_id',
            'general_averages' => 'general_average_id',
            'attendance' => 'attendance_id',
            'emergency_contacts' => 'emergency_contact_id',
            'family_members' => 'family_member_id',
            'interventions' => 'intervention_id',
            'risk_assessments' => 'risk_assessment_id',
            'risk_indicators' => 'risk_indicator_id',
            'report_cards' => 'report_card_id',
            'curricula' => 'curriculum_id',
            'grading_periods' => 'grading_period_id',
            'enrollment_requirements' => 'requirement_id',
        ];

        if (!isset($allowed[$tableName]) || $allowed[$tableName] !== $pkColumn) {
            return null;
        }

        $stmt = $conn->prepare("SELECT * FROM `{$tableName}` WHERE `{$pkColumn}` = :pk AND is_deleted = 0 LIMIT 1");
        $stmt->bindValue(':pk', $pkValue, PDO::PARAM_INT);
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row ?: null;
    } catch (Exception $e) {
        return null;
    }
}

/**
 * JSON encode that handles non-UTF8 gracefully.
 */
function json_encode_utf8(array $data): string {
    return json_encode($data, JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
}
?>
