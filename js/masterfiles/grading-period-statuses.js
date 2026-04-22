const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const gradingPeriodStatusesApi = {
    list: async () => axios.get(`${API_BASE_URL}/grading_period_statuses/grading_period_statuses.php`, { params: { operation: 'getAllGradingPeriodStatuses' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/grading_period_statuses/grading_period_statuses.php?operation=createGradingPeriodStatus`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/grading_period_statuses/grading_period_statuses.php?operation=updateGradingPeriodStatus`, { ...data, grading_period_status_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/grading_period_statuses/grading_period_statuses.php?operation=deleteGradingPeriodStatus`, { grading_period_status_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'grading_period_statuses',
        navKey: 'grading_period_statuses',
        entity: 'Grading Period Status',
        pageTitle: 'Grading Period Statuses Masterfile',
        subtitle: 'Manage grading period status records',
        breadcrumb: 'Grading Period Statuses',
        addLabel: 'Add Grading Period Status',
        primaryKey: 'grading_period_status_id',
        columns: [
            { key: 'status_name', label: 'Status Name' },
            { key: 'description', label: 'Description' }
        ],
        fields: [
            { key: 'status_name', label: 'Status Name', type: 'text', required: true, maxLength: 50 },
            { key: 'description', label: 'Description', type: 'text', required: false, maxLength: 150 }
        ],
        api: gradingPeriodStatusesApi
    });
});
