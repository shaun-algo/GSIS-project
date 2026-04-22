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

const APP_BASE_URL = getAppBaseUrl();
const isApacheServed = String(window.location.pathname || '').includes('/deped_capstone2/');
const API_BASE_URL = isApacheServed
    ? `${APP_BASE_URL}/api`
    : `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const authApi = {
    login: async (payload) => axios.post(`${API_BASE_URL}/auth/login.php`, payload).then(r => r.data)
};

const ROLE_REDIRECTS = {
    Teacher: 'dashboard/teacher_dashboard.html',
    // DepEd term: Learner. Keep Student mapping for existing DB role names.
    Student: 'dashboard/learner_dashboard.html',
    Learner: 'dashboard/learner_dashboard.html'
};

function normalizeRoleName(roleName) {
    return String(roleName || '').trim().toLowerCase();
}

function getRedirectForRole(roleName, roleId) {
    // Prefer numeric role_id when available (most reliable).
    // DB currently uses: 8=admin, 9=teacher, 10=learners
    const rid = Number(roleId);
    if (Number.isFinite(rid)) {
        if (rid === 9) return `${APP_BASE_URL}/dashboard/teacher_dashboard.html`;
        if (rid === 10) return `${APP_BASE_URL}/dashboard/learner_dashboard.html`;
        if (rid === 8) return `${APP_BASE_URL}/dashboard/admin_dashboard.html`;
    }

    const normalized = normalizeRoleName(roleName);

    // Prefer tolerant matching so DB values like "Learners" / "teacher " still work.
    if (normalized.includes('teacher')) {
        return `${APP_BASE_URL}/dashboard/teacher_dashboard.html`;
    }
    if (normalized.includes('learner') || normalized.includes('student')) {
        return `${APP_BASE_URL}/dashboard/learner_dashboard.html`;
    }
    if (normalized.includes('admin')) {
        return `${APP_BASE_URL}/dashboard/admin_dashboard.html`;
    }

    // Backward-compatible exact map
    const exactKey = String(roleName || '').trim();
    const route = ROLE_REDIRECTS[exactKey];
    if (route) return `${APP_BASE_URL}/${route}`;

    return `${APP_BASE_URL}/dashboard/admin_dashboard.html`;
}

function setFieldError(field, isError) {
    if (!field) return;
    const group = field.closest('.form-group') || field.parentElement;
    if (!group) return;
    if (isError) {
        group.classList.add('error');
    } else {
        group.classList.remove('error');
    }
}

function setStatus(message, isError) {
    const note = document.getElementById('loginStatus');
    if (!note) return;
    note.textContent = message || '';
    note.dataset.state = isError ? 'error' : 'info';
    note.style.display = message ? 'block' : 'none';
}

function setLoading(isLoading) {
    const loginBtn = document.getElementById('loginBtn');
    if (!loginBtn) return;
    if (isLoading) {
        loginBtn.disabled = true;
        loginBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Signing In...';
    } else {
        loginBtn.disabled = false;
        loginBtn.innerHTML = '<i class="fas fa-sign-in-alt"></i> Sign In';
    }
}

document.addEventListener('DOMContentLoaded', () => {
    if (window.axios) {
        try {
            window.axios.defaults.withCredentials = true;
        } catch (_) {
            // ignore
        }
    }
    if (window.AOS) {
        AOS.init({
            duration: 800,
            easing: 'ease-out',
            once: true
        });
    }

    const togglePassword = document.getElementById('togglePassword');
    const passwordInput = document.getElementById('password');

    if (togglePassword && passwordInput) {
        togglePassword.addEventListener('click', function() {
            const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordInput.setAttribute('type', type);
            this.classList.toggle('fa-eye');
            this.classList.toggle('fa-eye-slash');
        });
    }

    const loginForm = document.getElementById('loginForm');
    if (!loginForm) return;

    loginForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        const username = document.getElementById('username');
        const password = document.getElementById('password');

        const usernameValue = username?.value.trim() || '';
        const passwordValue = password?.value || '';

        setFieldError(username, !usernameValue);
        setFieldError(password, !passwordValue);

        if (!usernameValue || !passwordValue) {
            setStatus('Please enter your username and password.', true);
            return;
        }

        setStatus('', false);
        setLoading(true);

        try {
            const response = await authApi.login({
                username: usernameValue,
                password: passwordValue
            });

            if (!response?.success) {
                setStatus(response?.message || 'Login failed.', true);
                setLoading(false);
                return;
            }

            let roleName = response?.data?.role_name || '';
            const roleId = response?.data?.role_id;

            if (!String(roleName || '').trim() && roleId != null) {
                try {
                    const rolesResp = await axios.get(`${API_BASE_URL}/roles/roles.php?operation=getAllRoles`);
                    const roles = Array.isArray(rolesResp.data) ? rolesResp.data : [];
                    const match = roles.find((r) => String(r.role_id) === String(roleId));
                    if (match?.role_name) {
                        roleName = match.role_name;
                    }
                } catch (_) {
                    // ignore mapping failures; fall back to default redirect
                }
            }

            const target = getRedirectForRole(roleName, roleId);
            try {
                sessionStorage.removeItem('sessionEnded');
            } catch (_) {
                // ignore storage errors
            }
            window.location.href = target;
        } catch (error) {
            const status = error?.response?.status;
            const apiMessage = error?.response?.data?.message;

            if (window.location.protocol === 'file:') {
                setStatus('Login won\'t work on file://. Open via http://localhost/deped_capstone2/.', true);
                setLoading(false);
                return;
            }

            if (status === 405) {
                setStatus(
                    'Login endpoint is not reachable (HTTP 405). Open the system via XAMPP/Apache: http://localhost/deped_capstone2/ (not VS Code Live Server).',
                    true
                );
                setLoading(false);
                return;
            }

            if (apiMessage) {
                setStatus(apiMessage, true);
            } else if (status) {
                setStatus(`Unable to sign in (HTTP ${status}). Please try again.`, true);
            } else {
                setStatus('Unable to sign in. Please check your connection and try again.', true);
            }
            setLoading(false);
        }
    });
});
