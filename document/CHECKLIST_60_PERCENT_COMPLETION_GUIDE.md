# 60 Percent Checklist Explanation Guide With Proofs

This document explains each item in the official 60 percent checklist and gives practical proof points for demo and panel defense.

It now also includes a technical IoT explanation that you can use during defense, especially for the Advanced Database Implementation section.

Use this format per item:
- Requirement meaning: What the panel is really checking.
- Demo proof: What action to perform live.
- Code proof: Which files or endpoints prove implementation.

---

## A. Enhanced User Management Module (Items 1 to 5)

### 1) User roles fully integrated across all modules
- Requirement meaning: Role affects access, page behavior, and API authorization.
- Demo proof:
1. Login as Admin and show full modules.
2. Login as Registrar or Teacher and show role-limited modules.
3. Attempt restricted action as non-admin.
- Code proof:
	- api/auth/login.php
	- api/auth/me.php
	- api/utils/auth.php
	- assets/js/dashboard.js

### 2) Dynamic user permissions enforced in workflows
- Requirement meaning: Permissions are evaluated at request time, not only hidden in UI.
- Demo proof:
1. As Admin, perform write operation in an admin module.
2. As non-admin, attempt same write operation and show denial.
- Code proof:
	- api/utils/auth.php (role enforcement)
	- api/users/users.php
	- api/report_cards/report_cards.php

### 3) User profile management (view and update) functional
- Requirement meaning: Authenticated user can view own profile and save allowed fields.
- Demo proof:
1. Open pages/profile-security.html.
2. Reveal fields, edit contact data, click Save.
3. Refresh and verify persistence.
- Code proof:
	- js/profile-security.js
	- api/employees/employees.php (getMyEmployee and updateMyEmployee)

### 4) Account status control (activate and deactivate)
- Requirement meaning: Inactive accounts are blocked from login.
- Demo proof:
1. Deactivate test account.
2. Attempt login with test account and show blocked result.
3. Reactivate and show successful login.
- Code proof:
	- api/users/users.php
	- api/auth/login.php

### 5) Session timeout and user activity tracking
- Requirement meaning: Session freshness is enforced and idle sessions expire.
- Demo proof:
1. Show protected API call while logged in.
2. Explain idle timeout handling and 401 behavior when expired.
- Code proof:
	- api/utils/auth.php
	- api/auth/login.php

---

## B. Expanded Core Functional Module (Items 6 to 12)

Recommended flagship flow:
Enrollment to Grades to Risk Assessment to Report Card

### 6) All major system modules are developed (not partial)
- Requirement meaning: Modules are complete enough for real operation.
- Demo proof:
1. Navigate through Enrollments, Grades, Risk Assessment, Report Cards.
2. Show each module can load and execute its core operation.
- Code proof:
	- pages/enrollments.html
	- pages/grades.html
	- pages/risk-assessment.html
	- pages/report-cards.html
	- api/enrollments/enrollments.php
	- api/grades/grades.php
	- api/risk_assessments/risk_assessments.php
	- api/report_cards/report_cards.php

### 7) Complete workflows across modules are operational
- Requirement meaning: End-to-end process works across multiple modules.
- Demo proof:
1. Enroll learner.
2. Encode grades.
3. Show risk output updates.
4. Generate SF9 report card preview.
- Code proof:
	- api/enrollments/enrollments.php
	- api/grades/grades.php
	- api/risk_assessments/risk_assessments.php
	- js/masterfiles/report-cards.js

### 8) Complex business logic implemented (beyond CRUD)
- Requirement meaning: Domain rules and calculations are implemented.
- Demo proof:
1. Show grade computation and transmutation.
2. Show risk indicators and risk levels.
- Code proof:
	- api/grades/grades.php
	- api/risk_assessments/risk_assessments.php

### 9) System handles multiple transactions correctly
- Requirement meaning: Multi-step writes are safe and atomic.
- Demo proof:
1. Perform operation with multiple dependent writes.
2. Explain rollback behavior on failure.
- Code proof:
	- api/enrollments/enrollments.php
	- api/risk_assessments/risk_assessments.php
	- api/class_offerings/class_offerings.php

### 10) Data flow between modules is seamless and consistent
- Requirement meaning: Data created in one module is usable by others without manual fixes.
- Demo proof:
1. Newly enrolled learner appears in grade-related workflow.
2. Updated grade values appear in risk and report outputs.
- Code proof:
	- api/enrollments/enrollments.php
	- api/grades/grades.php
	- api/final_grades/final_grades.php
	- api/general_averages/general_averages.php
	- api/report_cards/report_cards.php

### 11) Edge cases and alternative flows handled
- Requirement meaning: System handles invalid and incomplete scenarios properly.
- Demo proof:
1. Enter invalid grade range and show validation message.
2. Submit required form with missing fields and show rejection.
3. Execute restricted action with wrong role and show 401 or 403.
- Code proof:
	- api/grades/grades.php
	- api/enrollments/enrollments.php
	- api/utils/auth.php

### 12) No redundant or unused features in the system
- Requirement meaning: Active UI features are connected and meaningful.
- Demo proof:
1. Show major buttons trigger real API actions.
2. Explain removed dead controls and aligned behavior.
- Code proof:
	- pages/class-offerings.html
	- js/masterfiles/class-offerings.js
	- js/masterfiles/report-cards.js

---

## C. Advanced Database Implementation (Items 13 to 17)

### IoT Data Flow Primer (Use this before Item 13)

Use this 7-step explanation when the panel asks, "How does IoT work in your system?"

1. **Sense (Device Layer)**  
   IoT devices (for example sensors, RFID readers, attendance scanners, or mobile data collectors) capture raw signals such as IDs, timestamps, or environmental values.
2. **Package (Edge Layer)**  
   The device or gateway converts raw values into structured payloads (usually JSON) with metadata like `device_id`, `captured_at`, and `reading_type`.
3. **Transmit (Network Layer)**  
   Data is sent through Wi-Fi/LTE/LAN using secure protocols (HTTPS REST, MQTT over TLS, or WebSocket).
4. **Ingest (Backend API Layer)**  
   Your backend validates auth token, schema, value ranges, and duplicate events, then accepts or rejects the payload.
5. **Persist (Database Layer)**  
   Valid data is written to normalized tables, often with transaction control for multi-table consistency.
6. **Process (Application Logic Layer)**  
   The system computes derived outputs (risk scores, alerts, grade impact, attendance summaries, report values).
7. **Present/React (UI + Notification Layer)**  
   Dashboards refresh, analytics update, and optional alerts (email/SMS/in-app) are triggered for actionable conditions.

Defense one-liner:

"Our IoT pipeline is device to gateway to validated API to transaction-safe database to computed module outputs, with real-time UI reflection and strict data integrity controls."

---

### IoT-to-Database Reference Architecture (For Whiteboard/Slide)

- **Acquisition tables**: `iot_devices`, `iot_readings_raw`
- **Core domain tables**: `students`, `enrollments`, `grades`, `risk_assessments`, `report_cards`
- **Linking tables**: `student_device_map`, `reading_enrollment_links`
- **Audit and reliability tables**: `api_event_logs`, `failed_payload_queue`, `sync_checkpoints`

Why this matters:
- Raw data is preserved for traceability.
- Core tables stay clean and business-focused.
- Failed packets can be replayed safely.
- Panel can verify that you designed for real operations, not just demo inserts.

### 13) Database design supports full system requirements
- Requirement meaning: Schema covers users, learners, classes, grades, risk, and reporting.
- Demo proof:
1. Show schema snapshot or table list.
2. Explain how key entities map to modules.
- Code proof:
	- api/database/dep_ed-3.sql
- Advanced defense checklist:
	- Show that each major workflow has a table owner (auth, enrollment, grading, risk, report generation).
	- Show indexed search paths for high-frequency operations (e.g., learner by school year, class offering by section).
	- Show lifecycle columns: `created_at`, `updated_at`, `status`, `source_device`.
	- Show archival strategy (active tables + archive/history tables if volume grows).
- Example DDL pattern:

```sql
CREATE TABLE iot_readings_raw (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  device_id VARCHAR(64) NOT NULL,
  student_id BIGINT NULL,
  reading_type VARCHAR(40) NOT NULL,
  reading_value DECIMAL(10,2) NOT NULL,
  captured_at DATETIME NOT NULL,
  received_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  request_id VARCHAR(80) NOT NULL,
  source_ip VARCHAR(45) NULL,
  UNIQUE KEY uq_device_request (device_id, request_id),
  KEY idx_student_time (student_id, captured_at),
  KEY idx_type_time (reading_type, captured_at)
);
```

### 14) Complex relationships (1:M and M:N) implemented correctly
- Requirement meaning: Proper FK links between related tables.
- Demo proof:
1. Show relationship examples:
	 - one learner to many enrollments
	 - one section to many class offerings
	 - one enrollment to many grades
- Code proof:
	- api/database/dep_ed-3.sql
	- api/enrollments/enrollments.php
	- api/grades/grades.php
- Advanced defense checklist:
	- Explain at least 2 explicit one-to-many chains and 1 many-to-many chain.
	- Show foreign key actions (`CASCADE`, `RESTRICT`, `SET NULL`) and justify each choice.
	- Clarify why M:N mapping table prevents duplicate or conflicting associations.
- Example relationship set:

```sql
CREATE TABLE student_device_map (
  student_id BIGINT NOT NULL,
  device_id VARCHAR(64) NOT NULL,
  assigned_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (student_id, device_id),
  CONSTRAINT fk_map_student FOREIGN KEY (student_id) REFERENCES students(id)
    ON DELETE CASCADE ON UPDATE CASCADE
);
```

### 15) Transactions and data consistency properly handled
- Requirement meaning: Writes remain consistent even when errors happen.
- Demo proof:
1. Explain beginTransaction, commit, rollback in multi-step modules.
- Code proof:
	- api/enrollments/enrollments.php
	- api/risk_assessments/risk_assessments.php
- Advanced defense checklist:
	- Identify all multi-table writes and show they are wrapped in one transaction.
	- Use idempotency key (`request_id`) so retry does not duplicate data.
	- Roll back if any downstream operation fails (link write, risk compute, summary update).
	- Log failure reason into a retry queue for recoverability.
- Example backend flow (PHP/PDO):

```php
$pdo->beginTransaction();
try {
    // 1) Insert IoT reading if request_id is new
    // 2) Link reading to enrollment/student context
    // 3) Update derived risk summary
    // 4) Write audit log
    $pdo->commit();
} catch (Throwable $e) {
    $pdo->rollBack();
    throw $e;
}
```

### 16) Data validation enforced at database and backend levels
- Requirement meaning: Invalid data is blocked before commit.
- Demo proof:
1. Trigger validation error (range or required fields).
2. Show user-friendly message and no invalid save.
- Code proof:
	- api/grades/grades.php
	- api/enrollments/enrollments.php
	- api/report_cards/report_cards.php
- Advanced defense checklist:
	- Backend validation: required fields, type checks, allowed ranges, ownership/role checks.
	- Database validation: NOT NULL, CHECK constraints (or enum + trigger pattern), FK integrity, uniqueness.
	- Anti-duplication: unique key on logical event identity (example: `device_id + request_id`).
	- Temporal validation: reject impossible timestamps (future time beyond tolerance).
- Example rules you can say:
	- Grade must be 60 to 100.
	- Attendance event must map to an existing active enrollment.
	- Device must be registered and active before submitting readings.

### 17) Database supports real-time system operations
- Requirement meaning: UI reflects recent changes quickly through API calls.
- Demo proof:
1. Save update and show immediate reflected list/detail.
- Code proof:
	- js/masterfiles/report-cards.js
	- js/profile-security.js
	- js/class-records.js
- Advanced defense checklist:
	- Add indexes for list/filter endpoints used by live dashboards.
	- Use pagination and selective fields for large datasets.
	- Use "latest state + event history" model for fast reads and complete audit.
	- Keep latency targets (example: API read below 300ms for common views).
	- Optional: push updates via WebSocket/SSE if strict real-time is required.
- Example read optimization approach:
	- Maintain summary tables/materialized aggregates per learner per term.
	- Refresh summary on transaction commit to keep UI fast.
	- Fallback to on-demand recompute for data repair/verification.

---

## Advanced Database Defense Script (2 to 3 minutes)

Use this if the panel asks deeply technical questions.

1. "Our schema separates raw IoT events from academic business tables to maintain both traceability and clean domain logic."
2. "We implemented one-to-many and many-to-many relations with explicit foreign keys and deliberate delete/update actions to protect integrity."
3. "All multi-step writes use transaction boundaries, so partial failures are rolled back and do not corrupt enrollment, grading, or risk data."
4. "Validation is dual-layer: backend business validation plus database structural constraints."
5. "For real-time performance, we index high-frequency queries, return paginated API payloads, and maintain computed summaries used by report and risk modules."
6. "We support replay-safe ingestion using unique request IDs to prevent duplicate writes when devices retry transmission."

### Proof Code Snippets (Items 13 to 17)

Use these snippets as direct technical evidence during defense.

#### Item 13: Database design supports full system requirements

`api/database/dep_ed-3.sql`

```sql
UNIQUE KEY `uq_learner_school_year` (`learner_id`,`school_year_id`),
KEY `idx_enroll_learner` (`learner_id`),
KEY `idx_enroll_sy` (`school_year_id`),
KEY `idx_enroll_grade` (`grade_level_id`),
KEY `idx_enroll_section` (`section_id`),
KEY `idx_dash_composite` (`school_year_id`,`grade_level_id`,`section_id`)
```

Why this is proof:
- Shows production-style indexing and uniqueness for enrollment integrity and dashboard performance.

#### Item 14: Complex relationships (1:M and M:N) implemented correctly

`api/database/dep_ed-3.sql`

```sql
CONSTRAINT `fk_enroll_learner` FOREIGN KEY (`learner_id`) REFERENCES `learners` (`learner_id`),
CONSTRAINT `fk_enroll_sy` FOREIGN KEY (`school_year_id`) REFERENCES `school_years` (`school_year_id`),
CONSTRAINT `fk_enroll_grade` FOREIGN KEY (`grade_level_id`) REFERENCES `grade_levels` (`grade_level_id`),
CONSTRAINT `fk_enroll_section` FOREIGN KEY (`section_id`) REFERENCES `sections` (`section_id`)
```

Why this is proof:
- Demonstrates strict relational links between learner, school year, grade level, and section.

#### Item 15: Transactions and data consistency handled

`api/enrollments/enrollments.php`

```php
try {
    $conn->beginTransaction();
    $stmt = $conn->prepare('INSERT INTO enrollments (...) VALUES (...)');
    $stmt->execute();
    $account = ensureLearnerUserAccount($conn, (int)$data['learner_id']);
    $conn->commit();
} catch (PDOException $e) {
    if ($conn && $conn->inTransaction()) {
        $conn->rollBack();
    }
    throw $e;
}
```

`api/risk_assessments/risk_assessments.php`

```php
$conn->beginTransaction();
try {
    // compute quarterly grades, final grades, averages, risk assessments
    $counts['final_grades_upserted'] = upsertFinalGrades($conn, $finalGrades, $userId);
    $counts['general_averages_upserted'] = upsertGeneralAverages($conn, $schoolYearId, $generalAverages, $userId);
    $riskResult = computeRiskAssessments($conn, $schoolYearId, $userId, $generalAverages, $finalGrades);
    $conn->commit();
} catch (Exception $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    throw $e;
}
```

Why this is proof:
- Confirms atomic multi-step writes with rollback protection.

#### Item 16: Validation at backend and database levels

`api/report_cards/report_cards.php`

```php
if (empty($data['enrollment_id']) || empty($data['grading_period_id'])) {
    respond(['success' => false, 'message' => 'Enrollment and grading period are required'], 422);
}
```

`api/enrollments/enrollments.php`

```php
if (empty($data['learner_id']) || empty($data['school_year_id']) || empty($data['grade_level_id']) || empty($data['section_id'])) {
    respond(['success' => false, 'message' => 'Learner, school year, grade level, and section are required'], 422);
}
```

`api/database/dep_ed-3.sql`

```sql
UNIQUE KEY `uq_learner_school_year` (`learner_id`,`school_year_id`)
```

Why this is proof:
- Backend prevents incomplete input, while DB prevents duplicate logical records.

#### Item 17: Database supports real-time system operations

`js/masterfiles/report-cards.js`

```javascript
const roster = await reportCardsApi.getRoster(currentSectionId, currentSchoolYearId);
currentStudents = Array.isArray(roster) ? roster : (roster.students || []);
renderStudentList();
```

```javascript
const sf9Data = await reportCardsApi.sf9ByEnrollment(student.enrollment_id);
const grades = sf9Data.grades || [];
detailContainer.innerHTML = `...`;
```

`js/masterfiles/report-cards.js` (API wiring)

```javascript
sf9ByEnrollment: async (enrollmentId) =>
  axios.get(`${API_BASE_URL}/report_cards/report_cards.php`, {
    params: { operation: 'getSF9DataByEnrollment', enrollment_id: enrollmentId }
  }).then(r => r.data)
```

Why this is proof:
- UI loads latest server data through API calls and re-renders immediately after retrieval.

---

## D. System Architecture and Module Integration (Items 18 to 22)

### 18) System architecture reflects actual implementation
- Requirement meaning: Diagram and explanation match real code structure.
- Demo proof:
1. Explain Browser to API to Database flow.
2. Point to modules and endpoints used in demo.
- Code proof:
	- pages/report-cards.html
	- js/masterfiles/report-cards.js
	- api/report_cards/report_cards.php

### 19) Frontend, backend, and database fully connected
- Requirement meaning: User action in UI reaches backend and persists in DB-derived response.
- Demo proof:
1. Trigger create or update.
2. Show API response in Network tab.
3. Show refreshed result from backend data.
- Code proof:
	- js/masterfiles/report-cards.js
	- api/enrollments/enrollments.php
	- api/grades/grades.php

### 20) APIs and controllers properly handling requests
- Requirement meaning: Each endpoint validates input, enforces auth, and returns clear JSON result.
- Demo proof:
1. Show successful response.
2. Show controlled error response with message.
- Code proof:
	- api/report_cards/report_cards.php
	- api/employees/employees.php
	- api/utils/auth.php

### 21) Modular structure (separation of concerns) applied
- Requirement meaning: UI logic, API logic, and data model are separated by module.
- Demo proof:
1. Show page file, script file, and API file for one module.
- Code proof:
	- pages/report-cards.html
	- js/masterfiles/report-cards.js
	- api/report_cards/report_cards.php

### 22) Navigation across modules is seamless and logical
- Requirement meaning: Users can move through workflows without dead pages.
- Demo proof:
1. Navigate sidebar through transaction modules.
2. Show context continuity for selected records.
- Code proof:
	- assets/js/dashboard.js
	- pages/enrollments.html
	- pages/grades.html
	- pages/report-cards.html

---

## E. Interface Functionality and User Interaction (Items 23 to 27)

### 23) All forms fully functional and connected to backend
- Requirement meaning: Form submission executes real API operation.
- Demo proof:
1. Submit form action.
2. Show backend response and persisted result.
- Code proof:
	- pages/profile-security.html
	- js/profile-security.js
	- api/employees/employees.php

### 24) Dynamic content updates (no static-only pages)
- Requirement meaning: Lists and details are rendered from live API data.
- Demo proof:
1. Change selection or search input and observe dynamic updates.
- Code proof:
	- js/masterfiles/report-cards.js
	- pages/report-cards.html

### 25) System provides correct feedback for user actions
- Requirement meaning: Success and failure states are clearly shown.
- Demo proof:
1. Show success toast after save.
2. Show warning or error on invalid action.
- Code proof:
	- js/profile-security.js
	- js/profile.js
	- js/masterfiles/report-cards.js

### 26) Error handling integrated within user workflows
- Requirement meaning: Errors are caught and presented without breaking page.
- Demo proof:
1. Force endpoint error and show graceful message.
- Code proof:
	- js/masterfiles/report-cards.js
	- api/report_cards/report_cards.php
	- api/employees/employees.php

### 27) Interface supports actual system operations (not demo-only)
- Requirement meaning: UI controls correspond to real workflows and stored data.
- Demo proof:
1. Generate SF9 preview from real enrollment and grades.
2. Show risk and grading data consistency.
- Code proof:
	- pages/report-cards.html
	- js/masterfiles/report-cards.js
	- api/report_cards/report_cards.php
	- api/risk_assessments/risk_assessments.php

---

## Suggested Live Demo Order for Maximum Score

1. Login and role switch proof (Items 1, 2, 4, 5)
2. Profile update proof (Items 3, 23, 25, 26)
3. Enrollment to grading to risk to report-card flow (Items 6 to 12, 19, 20, 27)
4. DB and architecture explanation with schema and endpoint references (Items 13 to 18, 21, 22)

---

## Presenter Quick Script

Use this short line when asked for strongest evidence:

Our strongest evidence for 60 percent completion is the connected transaction flow from enrollment to grade computation to risk detection to SF9 reporting, protected by role-based backend authorization, validated server-side inputs, and transaction-safe database writes.
