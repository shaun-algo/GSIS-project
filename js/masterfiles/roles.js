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

const rolesApi = {
    list: async () => axios.get(`${API_BASE_URL}/roles/roles.php`, { params: { operation: 'getAllRoles' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/roles/roles.php?operation=createRole`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/roles/roles.php?operation=updateRole`, { ...data, role_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/roles/roles.php?operation=deleteRole`, { role_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'roles',
        navKey: 'roles',
        entity: 'Role',
        pageTitle: 'Role Management',
        subtitle: 'Manage system roles and access labels',
        breadcrumb: 'Roles',
        addLabel: 'Add Role',
        primaryKey: 'role_id',
        columns: [
            { key: 'role_name', label: 'Role Name' }
        ],
        fields: [
            { key: 'role_name', label: 'Role Name', type: 'text', required: true, maxLength: 50 }
        ],
        api: rolesApi
    });
});
