# 60% Checklist — A. Enhanced User Management (Items 1–5)

This document is a demo + discussion guide for the first 5 checklist requirements.

## Quick demo accounts to prepare

Use at least two accounts to demonstrate role-based behavior:
- Admin account
- Registrar account (or Teacher account)

Optional:
- Learner account (to show restrictions)

---

## 1) User roles fully integrated across all modules (2 pts)

### What to demo (live)

1. Log in as Admin.
2. Open any dashboard/module page.
3. Show that the system knows the signed-in role (sidebar items + allowed pages differ).
4. Log out, then log in as Registrar.
5. Show the Registrar sees Monitoring/Reporting pages (Analytics + Report Cards) but does not get Admin masterfiles.

### Expected result

- The role attached to the user account drives:
  - Which pages are accessible (page guards/redirects)
  - Which navigation items appear
  - Which API endpoints respond with success vs 403/401

### Where the code enforces it

Backend (authoritative):
- Login stores the user’s role in the session: [api/auth/login.php](api/auth/login.php#L59), [api/auth/login.php](api/auth/login.php#L60)
- Role normalization into a stable `role_key`: [api/utils/auth.php](api/utils/auth.php#L77), [api/utils/auth.php](api/utils/auth.php#L94)
- All authenticated requests go through the same auth gate (`auth_require`): [api/utils/auth.php](api/utils/auth.php#L130)
- Session “me” endpoint returns `role_key` to the frontend: [api/auth/me.php](api/auth/me.php#L59)

Frontend (UX gating):
- Registrar page access allowlist + redirects: [assets/js/dashboard.js](assets/js/dashboard.js#L1405)
- Canonical sidebar builder uses `roleKey`: [assets/js/dashboard.js](assets/js/dashboard.js#L1420)
- Analytics navigation shown to Admin + Registrar: [assets/js/dashboard.js](assets/js/dashboard.js#L1441)
- Report Cards navigation shown to Admin + Registrar: [assets/js/dashboard.js](assets/js/dashboard.js#L1497)

---

## 2) Dynamic user permissions enforced in workflows (2 pts)

Meaning for this project: permissions are enforced at runtime based on the signed-in user’s role (RBAC), including “read vs write” separation.

### What to demo (live)

Demo 1 (Admin-only workflow):
1. Log in as Admin.
2. Open Users masterfile page.
3. Create or update a user (should succeed).
4. Log in as Registrar.
5. Attempt to open Users masterfile page (should be blocked/redirected by UI, and API should also block).

Demo 2 (Read vs write permissions):
1. Log in as Registrar.
2. Open Report Cards page.
3. Show the list loads (read allowed).
4. Attempt to create/update/delete a report card (write should be blocked by API with 403).

### Expected result

- Admin can manage users.
- Registrar can monitor report cards (read) but cannot create/update/delete if those are “write operations”.

### Where the code enforces it

Core RBAC helpers:
- Read vs write detection: [api/utils/auth.php](api/utils/auth.php#L169)
- Enforce different roles for read vs write: [api/utils/auth.php](api/utils/auth.php#L177)

Example: Users module is Admin-only:
- Users endpoint gate: [api/users/users.php](api/users/users.php#L34)

Example: Report Cards allow Registrar read, Admin write:
- Endpoint gate: [api/report_cards/report_cards.php](api/report_cards/report_cards.php#L27)

Note:
- This is dynamic RBAC (role-based allowlists). It is not a per-user permission matrix stored in a permissions table.

---

## 3) User profile management (view/update) functional (2 pts)

### What to demo (live)

1. Log in as an employee account (Admin/Teacher/Registrar).
2. Open the Profile Security page.
3. Show that your employee record loads.
4. Change a safe field (ex: contact number, email, address), then Save.
5. Refresh the page and show the saved data persists.

(Optional security proof)
- If you have two employee accounts, try updating the other employee’s record by tampering the `employee_id` in the request; it should be rejected.

### Expected result

- Authenticated employee users can view their own profile data.
- Only the owner (same session user) can update their own employee record.
- Learner accounts are blocked from employee self-service endpoints.

### Where the code enforces it

Backend:
- Self-service endpoints exist and require auth: [api/employees/employees.php](api/employees/employees.php#L46)
- Learners blocked from employee self-service: [api/employees/employees.php](api/employees/employees.php#L50)
- Ownership enforcement when updating: [api/employees/employees.php](api/employees/employees.php#L250)

Frontend:
- Page loads current session via `me`: [js/profile-security.js](js/profile-security.js#L75)
- Page loads employee data via `getMyEmployee`: [js/profile-security.js](js/profile-security.js#L144)

---

## 4) Account status control (activate/deactivate) implemented (2 pts)

### What to demo (live)

1. Log in as Admin.
2. Open Users masterfile page.
3. Pick a test account and set Active = No.
4. Log out.
5. Attempt login using the deactivated account (should be blocked).
6. Reactivate the account and show it can log in again.

### Expected result

- Inactive users cannot log in.
- Admin can control `is_active` via Users module.

### Where the code enforces it

Backend:
- Login blocks inactive accounts: [api/auth/login.php](api/auth/login.php#L43)
- Users endpoint stores `is_active` during create/update: [api/users/users.php](api/users/users.php#L81), [api/users/users.php](api/users/users.php#L100)

Frontend:
- Users masterfile shows Active column and checkbox field: [js/masterfiles/users.js](js/masterfiles/users.js#L60), [js/masterfiles/users.js](js/masterfiles/users.js#L74)

---

## 5) Session timeout and user activity tracking implemented (2 pts)

### What to demo (live)

1. Log in as any role.
2. Open browser DevTools → Network.
3. Refresh or click a page that calls an API endpoint.
4. Show session freshness is enforced on every authenticated API call.

Optional live expiry demo (faster):
- Temporarily set a short timeout (e.g., 60 seconds) using the environment variable `AUTH_IDLE_TIMEOUT_SECONDS` in Apache/PHP, then:
  1) Log in
  2) Stop activity for 60+ seconds
  3) Trigger an API call; you should get `401 Session expired`

### Expected result

- The backend tracks `last_activity` and expires sessions after inactivity.
- Requests after expiry return 401 and require re-login.

### Where the code enforces it

Backend:
- Idle timeout default (30 minutes): [api/utils/auth.php](api/utils/auth.php#L11), [api/utils/auth.php](api/utils/auth.php#L15)
- Session freshness guard checks inactivity and expires: [api/utils/auth.php](api/utils/auth.php#L102), [api/utils/auth.php](api/utils/auth.php#L114)
- Activity tracking updates `last_activity` each authenticated request: [api/utils/auth.php](api/utils/auth.php#L127)
- Session is initialized with `last_activity` at login: [api/auth/login.php](api/auth/login.php#L63)

Extra session binding (anti-cookie-theft basic binding):
- User-Agent is bound to the session: [api/utils/auth.php](api/utils/auth.php#L119)

---

## Note about “Audit actions / audit trail”

The database schema includes an `audit_logs` table definition, but the API currently does not write to it.
- Table exists in schema dump: [api/database/dep_ed-3.sql](api/database/dep_ed-3.sql#L119)
- Login page claims auditing exists (UI text only): [index.html](index.html#L43)

If your panel expects a visible audit trail, this would need a small API + page that records events (create/update/delete) and displays them (Admin/Registrar).
