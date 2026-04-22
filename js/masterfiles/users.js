function getApiBaseUrl() {
    const isApacheServed = String(window.location.pathname || '').includes('/deped_capstone2/');
    if (!isApacheServed) {
        return `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;
    }

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
    return `${appPrefix}/api`;
}

const API_BASE_URL = getApiBaseUrl();

if (window.axios) {
    try {
        window.axios.defaults.withCredentials = true;
    } catch (_) {
        // ignore
    }
}

const usersApi = {
    list: async () => axios.get(`${API_BASE_URL}/users/users.php`, { params: { operation: 'getAllUsers' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/users/users.php?operation=createUser`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/users/users.php?operation=updateUser`, { ...data, user_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/users/users.php?operation=deleteUser`, { user_id: id }).then(r => r.data)
};

const rolesApi = {
    list: async () => axios.get(`${API_BASE_URL}/roles/roles.php`, { params: { operation: 'getAllRoles' } }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'users',
        navKey: 'users',
        entity: 'User',
        pageTitle: 'User Management',
        subtitle: 'Manage system user accounts',
        breadcrumb: 'Users',
        addLabel: 'Add User',
        primaryKey: 'user_id',
        columns: [
            { key: 'username', label: 'Username' },
            { key: 'role_name', label: 'Role' },
            { key: 'is_active', label: 'Active', formatter: booleanBadge },
        ],
        fields: [
            { key: 'username', label: 'Username', type: 'text', required: true, maxLength: 30 },
            { key: 'password', label: 'Password', type: 'text', omitIfEmpty: true },
            {
                key: 'role_id',
                label: 'Role',
                type: 'select',
                required: true,
                valueKey: 'role_id',
                labelKey: 'role_name',
                loadOptions: rolesApi.list
            },
            { key: 'is_active', label: 'Active', type: 'checkbox', defaultValue: true },
        ],
        api: usersApi
    });
});

function booleanBadge(value) {
    const isTrue = value === 1 || value === true || value === '1';
    return `<span class="status-badge ${isTrue ? 'active' : 'inactive'}">${isTrue ? 'Yes' : 'No'}</span>`;
}
