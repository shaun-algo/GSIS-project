function getApiBaseUrl() {
    const parts = String(window.location.pathname || '/').split('/').filter(Boolean);
    const appPrefix = parts.length ? `/${parts[0]}` : '';
    return `${window.location.origin}${appPrefix}/api`;
}

const API_BASE_URL = window.API_BASE || getApiBaseUrl();

const learnerStatusesApi = {
    list: async () => axios.get(`${API_BASE_URL}/learner_statuses/learner_statuses.php`, { params: { operation: 'getAllStatuses' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/learner_statuses/learner_statuses.php?operation=createStatus`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/learner_statuses/learner_statuses.php?operation=updateStatus`, { ...data, learner_status_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/learner_statuses/learner_statuses.php?operation=deleteStatus`, { learner_status_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'learner_statuses',
        navKey: 'learner_statuses',
        entity: 'Learner Status',
        pageTitle: 'Learner Statuses Masterfile',
        subtitle: 'Manage learner enrollment status types',
        breadcrumb: 'Learner Statuses',
        addLabel: 'Add Status',
        primaryKey: 'learner_status_id',
        columns: [
            { key: 'status_name', label: 'Status Name' }
        ],
        fields: [
            { key: 'status_name', label: 'Status Name', type: 'text', required: true, maxLength: 50 }
        ],
        api: learnerStatusesApi
    });
});
