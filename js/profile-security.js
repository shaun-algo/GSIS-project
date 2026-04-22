function getAppBaseUrl() {
    const pathname = String(window.location.pathname || '/');
    let appPrefix = '';

    if (pathname.includes('/dashboard/')) {
        appPrefix = pathname.split('/dashboard/')[0] || '';
    } else if (pathname.includes('/pages/')) {
        appPrefix = pathname.split('/pages/')[0] || '';
    } else if (pathname.includes('/assets/')) {
        appPrefix = pathname.split('/assets/')[0] || '';
    } else if (pathname.includes('/api/')) {
        appPrefix = pathname.split('/api/')[0] || '';
    } else if (pathname.endsWith('.html')) {
        appPrefix = pathname.substring(0, pathname.lastIndexOf('/')) || '';
    } else {
        appPrefix = pathname.endsWith('/') ? pathname.slice(0, -1) : pathname;
    }

    if (appPrefix === '/') appPrefix = '';
    return appPrefix;
}

const API_BASE_URL = window.API_BASE || ((!!window.location.port && !['80', '443'].includes(String(window.location.port)))
    ? `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`
    : '/deped_capstone2/api');

// Keep session cookies when applicable.
axios.defaults.withCredentials = true;

let currentUser = null;
let employee = null;
let positions = [];
let editMode = false;

// These are masked by default.
const maskable = new Set([
    'employee_number',
    'username',
    'date_of_birth',
    'date_hired',
    'contact_number',
    'email',
    'address'
]);

document.addEventListener('DOMContentLoaded', () => {
    initMaskButtons();
    initEditButtons();
    loadPage();
});

function initMaskButtons() {
    document.querySelectorAll('[data-mask]').forEach((btn) => {
        btn.addEventListener('click', () => toggleMask(btn.dataset.mask));
    });
}

function initEditButtons() {
    const revealAllBtn = document.getElementById('revealAllBtn');
    const saveBtn = document.getElementById('saveBtn');

    if (revealAllBtn) revealAllBtn.addEventListener('click', toggleRevealAll);
    if (saveBtn) saveBtn.addEventListener('click', save);
}

async function loadPage() {
    try {
        if (window.location.protocol === 'file:') {
            showNotification('Open this page via http://localhost/deped_capstone2/ so login/session works.', 'error');
            return;
        }

        const meResp = await axios.get(`${API_BASE_URL}/auth/me.php`);
        if (!meResp.data?.success) {
            showNotification('Not authenticated. Please sign in again.', 'error');
            return;
        }
        currentUser = meResp.data.data;
        setText('headerUserName', currentUser.full_name || currentUser.username || 'User');
        setText('headerUserRole', currentUser.role_name || '');

        // Learner accounts don't have an employee record; avoid calling getMyEmployee (it returns 404).
        const roleNormalized = String(currentUser.role_name || '').trim().toLowerCase();
        const roleId = Number(currentUser.role_id);
        const isLearner = roleNormalized.includes('learner') || roleNormalized.includes('student') || roleId === 10;
        if (isLearner) {
            showNotification('Profile info on this page is for employee accounts. Learner accounts do not have an employee record.', 'info');
            disableSecurityEditing();
            return;
        }

        await loadPositions();
        await loadMyEmployee();
    } catch (err) {
        const status = err.response?.status;
        const apiMessage = err.response?.data?.message;
        const hint = status === 401
            ? 'Not authenticated. Please login again.'
            : status === 404
                ? (apiMessage || 'API endpoint not found. Check the URL and server.')
                : (apiMessage || err.message || 'Network error.');
        console.error('Security load failed:', { status, url: err.config?.url, data: err.response?.data, err });
        showNotification(`Unable to load security details. ${hint}`, 'error');
    }
}

function renderEmployeeProfile() {
    if (!employee || !employee.employee_id) {
        console.log('No employee data available, hiding profile');
        hideEmployeeProfile();
        return;
    }

    fillForm(employee);
    // Show the employee profile section
    const employeeSection = document.querySelector('.employee-profile-section');
    if (employeeSection) {
        employeeSection.style.display = 'block';
    }
}


function hideEmployeeProfile() {
    disableSecurityEditing();
    showStaticInfo('Employee profile is only available for staff accounts with an employee record.');
}

function disableSecurityEditing() {
    // Disable editing actions for non-employee accounts.
    const revealAllBtn = document.getElementById('revealAllBtn');
    const saveBtn = document.getElementById('saveBtn');

    if (revealAllBtn) revealAllBtn.disabled = true;
    if (saveBtn) saveBtn.disabled = true;

    // Keep the form read-only/disabled.
    setEditMode(false);
}

function showStaticInfo(message) {
    const form = document.getElementById('securityForm');
    if (!form) return;

    let panel = document.getElementById('securityInfoPanel');
    if (!panel) {
        panel = document.createElement('div');
        panel.id = 'securityInfoPanel';
        panel.style.cssText = 'margin-bottom: 1rem; padding: 0.9rem 1rem; border: 1px solid var(--gray-300); border-left: 4px solid var(--deped-blue); background: var(--gray-50); color: var(--gray-800); border-radius: 6px;';
        form.prepend(panel);
    }
    panel.textContent = message;
}

async function loadPositions() {
    try {
        const resp = await axios.get(`${API_BASE_URL}/positions/positions.php?operation=getAllPositions`);
        positions = Array.isArray(resp.data) ? resp.data : [];

        const select = document.getElementById('position_id');
        if (!select) return;

        // Keep the first option.
        while (select.options.length > 1) select.remove(1);

        positions.forEach((p) => {
            const option = document.createElement('option');
            option.value = p.position_id;
            option.textContent = p.position_name;
            select.appendChild(option);
        });
    } catch (err) {
        console.error('Positions error:', err);
    }
}

async function loadMyEmployee() {
    try {
        const resp = await axios.get(`${API_BASE_URL}/employees/employees.php?operation=getMyEmployee`);
        if (!resp.data?.success) {
            showNotification(resp.data?.message || 'Unable to load your employee record.', 'error');
            return;
        }
        employee = resp.data.data;
        if (!employee) {
            // User doesn't have an employee record (likely a learner/student)
            console.log('No employee record found for this user');
            // Hide employee-related UI elements
            hideEmployeeProfile();
            return;
        }
        renderEmployeeProfile();
    } catch (err) {
        console.error('Error loading employee data:', err);
        // Don't show error for missing employee records
        if (err.response?.status !== 404) {
            showNotification('Unable to load employee data.', 'error');
        }
    }
}

function fillForm(row) {
    if (!row) {
        console.error('fillForm called with null or undefined row');
        return;
    }

    setPlainValue('employee_id', row.employee_id || '');

    // Masked by default.
    setMaskedValue('employee_number', row.employee_number || '');
    setMaskedValue('username', row.username || row.employee_number || '');
    setMaskedValue('date_of_birth', row.date_of_birth, 'date');
    setMaskedValue('date_hired', row.date_hired, 'date');
    setMaskedValue('contact_number', row.contact_number || '');
    setMaskedValue('email', row.email || '');
    setMaskedValue('address', row.address || '');

    // Not masked by default.
    setPlainValue('first_name', row.first_name || '');
    setPlainValue('middle_name', row.middle_name || '');
    setPlainValue('last_name', row.last_name || '');
    setPlainValue('name_extension', row.name_extension || '');
    setPlainValue('department', row.department || '');

    setSelectValue('gender', row.gender || '');
    setSelectValue('position_id', row.position_id || '');

    setPlainValue('role_name', row.role_name || '');

    // Only allow editing when this user has a real employee record.
    const hasEmployeeRecord = Boolean(row.employee_id);
    setEditMode(hasEmployeeRecord);
    if (!hasEmployeeRecord) {
        disableSecurityEditing();
        showStaticInfo('This account has no employee profile record yet. Contact an administrator to link an employee record before editing profile info.');
    }

    // Sync reveal-all toggle state.
    updateRevealAllButton();
}

function setEditMode(enabled) {
    editMode = enabled;
    const saveBtn = document.getElementById('saveBtn');

    // Always keep these read-only.
    const alwaysReadOnly = new Set(['employee_number', 'username', 'role_name', 'employee_id']);

    document.querySelectorAll('#securityForm input, #securityForm textarea, #securityForm select').forEach((el) => {
        if (alwaysReadOnly.has(el.id)) {
            if (el.tagName === 'SELECT') {
                el.disabled = true;
            } else {
                // Keep readable and focusable; just not editable.
                el.disabled = false;
                el.removeAttribute('disabled');
                el.readOnly = true;
            }
            el.classList.add('read-only');
            return;
        }

        // If the field is maskable and currently masked, force it disabled
        // until the user clicks Show. This prevents editing bullet characters.
        const isMaskable = maskable.has(el.id);
        const isMasked = el.dataset.masked === 'true';
        if (enabled && isMaskable && isMasked) {
            el.disabled = true;
            el.setAttribute('disabled', 'disabled');
            if (el.tagName !== 'SELECT') el.readOnly = true;
            el.classList.add('read-only');
            return;
        }

        if (el.tagName === 'SELECT') {
            el.disabled = !enabled;
            if (enabled) {
                // Be explicit for browsers that keep the attribute around.
                el.removeAttribute('disabled');
            } else {
                el.setAttribute('disabled', 'disabled');
            }
        } else {
            // For inputs/textarea, always clear disabled and toggle readOnly instead.
            // This fixes fields that start with disabled="disabled" in HTML:
            // without removeAttribute here, el.value returns '' even after setPlainValue sets the value.
            el.disabled = false;
            el.removeAttribute('disabled');
            el.readOnly = !enabled;
        }

        el.classList.toggle('read-only', !enabled);
    });

    if (saveBtn) saveBtn.disabled = !enabled;
}

function isAnyMasked() {
    for (const fieldId of maskable) {
        const el = document.getElementById(fieldId);
        if (!el) continue;
        if (el.dataset.masked !== 'false') return true;
    }
    return false;
}

function updateRevealAllButton() {
    const btn = document.getElementById('revealAllBtn');
    if (!btn) return;

    const anyMasked = isAnyMasked();
    const icon = anyMasked ? 'fa-eye' : 'fa-eye-slash';
    const title = anyMasked ? 'Reveal All' : 'Hide All';

    btn.innerHTML = `<i class="fas ${icon}"></i>`;
    btn.title = title;
    btn.setAttribute('aria-label', title);
}

function revealAll() {
    [...maskable].forEach((fieldId) => {
        const el = document.getElementById(fieldId);
        if (!el) return;
        if (el.dataset.masked === 'true') toggleMask(fieldId);
    });

    updateRevealAllButton();
}

function hideAll() {
    [...maskable].forEach((fieldId) => {
        const el = document.getElementById(fieldId);
        if (!el) return;
        if (el.dataset.masked === 'false') toggleMask(fieldId);
    });

    updateRevealAllButton();
}

function toggleRevealAll() {
    if (isAnyMasked()) {
        revealAll();
    } else {
        hideAll();
    }
}

function toggleMask(fieldId) {
    const el = document.getElementById(fieldId);
    if (!el) return;

    const button = document.querySelector(`[data-mask="${fieldId}"]`);
    const isMasked = el.dataset.masked !== 'false';

    if (isMasked) {
        el.dataset.masked = 'false';
        el.value = el.dataset.actual || '';
        if (el.dataset.originalType && el.tagName === 'INPUT') {
            el.setAttribute('type', el.dataset.originalType);
        }
        if (button) button.textContent = 'Hide';

        // If editing is enabled, reveal also enables input.
        if (editMode) {
            const alwaysReadOnly = new Set(['employee_number', 'username', 'role_name', 'employee_id']);
            if (!alwaysReadOnly.has(el.id)) {
                el.disabled = false;
                el.removeAttribute('disabled');
                if (el.tagName !== 'SELECT') el.readOnly = false;
                el.classList.remove('read-only');
            }
        }
    } else {
        el.dataset.actual = el.value;
        el.dataset.masked = 'true';
        if (el.tagName === 'INPUT') el.setAttribute('type', 'text');
        el.value = maskValue(el.dataset.actual || '');
        if (button) button.textContent = 'Show';

        // If editing is enabled, masking again disables input.
        if (editMode) {
            el.disabled = true;
            el.setAttribute('disabled', 'disabled');
            if (el.tagName !== 'SELECT') el.readOnly = true;
            el.classList.add('read-only');
        }
    }

    updateRevealAllButton();
}

function setMaskedValue(id, value, inputType) {
    const el = document.getElementById(id);
    if (!el) return;

    const actual = value ?? '';
    el.dataset.actual = actual;
    el.dataset.masked = maskable.has(id) ? 'true' : 'false';

    if (el.tagName === 'INPUT') {
        el.dataset.originalType = inputType || el.getAttribute('type') || 'text';
        el.setAttribute('type', 'text');
    }

    el.value = maskValue(actual);

    const button = document.querySelector(`[data-mask="${id}"]`);
    if (button) button.textContent = 'Show';
}

function setPlainValue(id, value) {
    const el = document.getElementById(id);
    if (!el) return;
    el.dataset.actual = value ?? '';
    el.dataset.masked = 'false';
    el.value = value ?? '';
}

function setSelectValue(id, value) {
    const el = document.getElementById(id);
    if (!el) return;
    el.value = value ?? '';
}

async function save() {
    const saveBtn = document.getElementById('saveBtn');
    if (saveBtn) {
        saveBtn.disabled = true;
        saveBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...';
    }

    try {
        const payload = {
            first_name: getValue('first_name'),
            middle_name: getValue('middle_name'),
            last_name: getValue('last_name'),
            name_extension: getValue('name_extension'),
            date_of_birth: getActualOrPlain('date_of_birth'),
            gender: getValue('gender'),
            contact_number: getActualOrPlain('contact_number'),
            email: getActualOrPlain('email'),
            address: getActualOrPlain('address'),
            department: getValue('department'),
            position_id: getValue('position_id'),
            date_hired: getActualOrPlain('date_hired'),
            employee_id: employee?.employee_id || null
        };

        const resp = await axios.post(
            `${API_BASE_URL}/employees/employees.php?operation=updateMyEmployee`,
            payload,
            { headers: { 'Content-Type': 'application/json' } }
        );

        if (resp.data?.success) {
            showNotification('Your employee record was updated.', 'success');
            await loadMyEmployee();
            setEditMode(true);
        } else {
            showNotification(resp.data?.message || 'Update failed.', 'error');
        }
    } catch (err) {
        const msg = err.response?.data?.message || err.message || 'An error occurred while saving.';
        showNotification(msg, 'error');
        console.error('Save error', err.response?.data || err);
    } finally {
        if (saveBtn) {
            saveBtn.innerHTML = '<i class="fas fa-save"></i> Save';
            saveBtn.disabled = !editMode;
        }
    }
}

function getValue(id) {
    const el = document.getElementById(id);
    if (!el) return '';
    const val = el.value;
    return typeof val === 'string' ? val.trim() : val;
}

function getActualOrPlain(id) {
    const el = document.getElementById(id);
    if (!el) return null;
    if (el.dataset.masked === 'true') {
        return (el.dataset.actual || '').trim() || null;
    }
    return (el.value || '').trim() || null;
}

function maskValue(value) {
    if (!value) return '••••';
    const str = String(value);
    if (str.length <= 2) return '••';
    return `${'•'.repeat(Math.max(2, str.length - 2))}${str.slice(-2)}`;
}

function setText(id, text) {
    const el = document.getElementById(id);
    if (el) el.textContent = text;
}

function showNotification(message, type = 'info') {
    const ensureStyles = () => {
        if (document.getElementById('govToastStyles')) return;
        const style = document.createElement('style');
        style.id = 'govToastStyles';
        style.textContent = `
            .gov-toast{position:fixed;bottom:80px;right:20px;background:var(--surface-0);border:1px solid var(--gray-200);box-shadow:var(--shadow-md);border-radius:6px;padding:.9rem 1rem;z-index:10001;min-width:320px;max-width:420px;opacity:0;transform:translateX(30px);transition:opacity .25s ease,transform .25s ease}
            .gov-toast.show{opacity:1;transform:translateX(0)}
            .gov-toast__content{display:flex;align-items:flex-start;gap:.75rem}
            .gov-toast__icon{font-size:1.1rem;margin-top:.05rem}
            .gov-toast__text{display:flex;flex-direction:column;gap:.15rem;min-width:0;flex:1}
            .gov-toast__title{font-size:.78rem;font-weight:700;letter-spacing:.04em;text-transform:uppercase;color:var(--gray-700);line-height:1.15}
            .gov-toast__message{font-size:.92rem;color:var(--gray-900);line-height:1.35;word-break:break-word}
            .gov-toast__dismiss{background:transparent;border:none;color:var(--gray-500);font-size:1rem;cursor:pointer;line-height:1}
            .gov-toast--success{border-left:4px solid var(--deped-blue)}
            .gov-toast--success .gov-toast__icon{color:var(--deped-blue)}
            .gov-toast--error{border-left:4px solid var(--color-danger)}
            .gov-toast--error .gov-toast__icon{color:var(--color-danger)}
            .gov-toast--info{border-left:4px solid var(--deped-blue)}
            .gov-toast--info .gov-toast__icon{color:var(--deped-blue)}
        `;
        document.head.appendChild(style);
    };

    ensureStyles();
    document.querySelectorAll('.gov-toast').forEach((el) => el.remove());

    const normalized = type === 'success' || type === 'error' || type === 'info' ? type : 'info';
    const title = normalized === 'success' ? 'Completed' : normalized === 'error' ? 'Action Required' : 'Notice';
    const icon = normalized === 'success' ? 'fa-circle-check' : normalized === 'error' ? 'fa-triangle-exclamation' : 'fa-circle-info';

    const toast = document.createElement('div');
    toast.className = `gov-toast gov-toast--${normalized}`;
    toast.innerHTML = `
        <div class="gov-toast__content">
            <i class="fas ${icon} gov-toast__icon"></i>
            <div class="gov-toast__text">
                <div class="gov-toast__title">${title}</div>
                <div class="gov-toast__message">${message}</div>
            </div>
            <button type="button" class="gov-toast__dismiss" aria-label="Dismiss">&times;</button>
        </div>
    `;

    document.body.appendChild(toast);
    requestAnimationFrame(() => toast.classList.add('show'));

    const dismiss = toast.querySelector('.gov-toast__dismiss');
    if (dismiss) dismiss.addEventListener('click', () => toast.remove());

    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 250);
    }, 4000);
}
