const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const civilStatusesApi = {
    list: async () => axios.get(`${API_BASE_URL}/civil_statuses/civil_statuses.php`, { params: { operation: 'getAllCivilStatuses' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/civil_statuses/civil_statuses.php?operation=createCivilStatus`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/civil_statuses/civil_statuses.php?operation=updateCivilStatus`, { ...data, civil_status_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/civil_statuses/civil_statuses.php?operation=deleteCivilStatus`, { civil_status_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'civil_statuses',
        navKey: 'civil_statuses',
        entity: 'Civil Status',
        pageTitle: 'Civil Status Masterfile',
        subtitle: 'Manage civil status records',
        breadcrumb: 'Civil Statuses',
        addLabel: 'Add Civil Status',
        primaryKey: 'civil_status_id',
        columns: [
            { key: 'status_name', label: 'Status Name' }
        ],
        fields: [
            { key: 'status_name', label: 'Status Name', type: 'text', required: true, maxLength: 50 }
        ],
        api: civilStatusesApi
    });
});
