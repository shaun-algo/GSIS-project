const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const interventionStatusesApi = {
    list: async () => axios.get(`${API_BASE_URL}/intervention_statuses/intervention_statuses.php`, { params: { operation: 'getAllInterventionStatuses' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/intervention_statuses/intervention_statuses.php?operation=createInterventionStatus`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/intervention_statuses/intervention_statuses.php?operation=updateInterventionStatus`, { ...data, intervention_status_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/intervention_statuses/intervention_statuses.php?operation=deleteInterventionStatus`, { intervention_status_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'intervention_statuses',
        navKey: 'intervention_statuses',
        entity: 'Intervention Status',
        pageTitle: 'Intervention Statuses Masterfile',
        subtitle: 'Manage intervention status records',
        breadcrumb: 'Intervention Statuses',
        addLabel: 'Add Intervention Status',
        primaryKey: 'intervention_status_id',
        columns: [
            { key: 'status_name', label: 'Status Name' },
            { key: 'description', label: 'Description' }
        ],
        fields: [
            { key: 'status_name', label: 'Status Name', type: 'text', required: true, maxLength: 50 },
            { key: 'description', label: 'Description', type: 'text', required: false, maxLength: 150 }
        ],
        api: interventionStatusesApi
    });
});
