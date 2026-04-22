const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const announcementsApi = {
    list: async () => axios.get(`${API_BASE_URL}/announcements/announcements.php`, { params: { operation: 'getAllAnnouncements' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/announcements/announcements.php?operation=createAnnouncement`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/announcements/announcements.php?operation=updateAnnouncement`, { ...data, announcement_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/announcements/announcements.php?operation=deleteAnnouncement`, { announcement_id: id }).then(r => r.data)
};

const rolesApi = {
    list: async () => axios.get(`${API_BASE_URL}/roles/roles.php`, { params: { operation: 'getAllRoles' } }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'announcements',
        navKey: 'announcements',
        entity: 'Announcement',
        pageTitle: 'Announcements',
        subtitle: '',
        breadcrumb: 'Announcements',
        addLabel: 'Add Announcement',
        primaryKey: 'announcement_id',
        columns: [
            { key: 'title', label: 'Title' },
            { key: 'posted_by_name', label: 'Posted By' },
            { key: 'target_role_name', label: 'Target Role' },
            { key: 'published_at', label: 'Published At' },
            { key: 'expires_at', label: 'Expires At' }
        ],
        fields: [
            { key: 'title', label: 'Title', type: 'text', required: true, maxLength: 200 },
            { key: 'body', label: 'Body', type: 'textarea', required: true },
            {
                key: 'target_role_id',
                label: 'Target Role',
                type: 'select',
                required: false,
                valueKey: 'role_id',
                labelKey: 'role_name',
                loadOptions: rolesApi.list
            },
            { key: 'published_at', label: 'Published At', type: 'datetime-local', required: false },
            { key: 'expires_at', label: 'Expires At', type: 'datetime-local', required: false }
        ],
        api: announcementsApi
    });
});
