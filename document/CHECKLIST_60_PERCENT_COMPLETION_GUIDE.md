# 60 Percent Checklist Explanation Guide With Proofs

This document explains each item in the official 60 percent checklist and gives practical proof points for demo and panel defense.

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

### 13) Database design supports full system requirements
- Requirement meaning: Schema covers users, learners, classes, grades, risk, and reporting.
- Demo proof:
1. Show schema snapshot or table list.
2. Explain how key entities map to modules.
- Code proof:
	- api/database/dep_ed-2.sql
	- api/database/dep_ed-3.sql

### 14) Complex relationships (1:M and M:N) implemented correctly
- Requirement meaning: Proper FK links between related tables.
- Demo proof:
1. Show relationship examples:
	 - one learner to many enrollments
	 - one section to many class offerings
	 - one enrollment to many grades
- Code proof:
	- api/database/dep_ed-2.sql
	- api/enrollments/enrollments.php
	- api/grades/grades.php

### 15) Transactions and data consistency properly handled
- Requirement meaning: Writes remain consistent even when errors happen.
- Demo proof:
1. Explain beginTransaction, commit, rollback in multi-step modules.
- Code proof:
	- api/enrollments/enrollments.php
	- api/risk_assessments/risk_assessments.php

### 16) Data validation enforced at database and backend levels
- Requirement meaning: Invalid data is blocked before commit.
- Demo proof:
1. Trigger validation error (range or required fields).
2. Show user-friendly message and no invalid save.
- Code proof:
	- api/grades/grades.php
	- api/enrollments/enrollments.php
	- api/report_cards/report_cards.php

### 17) Database supports real-time system operations
- Requirement meaning: UI reflects recent changes quickly through API calls.
- Demo proof:
1. Save update and show immediate reflected list/detail.
- Code proof:
	- js/masterfiles/report-cards.js
	- js/profile-security.js
	- js/class-records.js

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
