const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const notificationTypesApi = {
    list: async () => axios.get(`${API_BASE_URL}/notification_types/notification_types.php`, { params: { operation: 'getAllNotificationTypes' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/notification_types/notification_types.php?operation=createNotificationType`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/notification_types/notification_types.php?operation=updateNotificationType`, { ...data, notification_type_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/notification_types/notification_types.php?operation=deleteNotificationType`, { notification_type_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'notification_types',
        navKey: 'notification_types',
        entity: 'Notification Type',
        pageTitle: 'Notification Types Masterfile',
        subtitle: 'Manage notification type records',
        breadcrumb: 'Notification Types',
        addLabel: 'Add Notification Type',
        primaryKey: 'notification_type_id',
        columns: [
            { key: 'type_name', label: 'Type Name' },
            { key: 'description', label: 'Description' }
        ],
        fields: [
            { key: 'type_name', label: 'Type Name', type: 'text', required: true, maxLength: 100 },
            { key: 'description', label: 'Description', type: 'text', required: false, maxLength: 255 }
        ],
        api: notificationTypesApi
    });
});
