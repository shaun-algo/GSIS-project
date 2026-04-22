const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const gradingSystemsApi = {
    list: async () => axios.get(`${API_BASE_URL}/grading_system_types/grading_system_types.php`, { params: { operation: 'getAllGradingSystems' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/grading_system_types/grading_system_types.php?operation=createGradingSystem`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/grading_system_types/grading_system_types.php?operation=updateGradingSystem`, { ...data, grading_system_type_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/grading_system_types/grading_system_types.php?operation=deleteGradingSystem`, { grading_system_type_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'grading_system_types',
        navKey: 'grading_system_types',
        entity: 'Grading System',
        pageTitle: 'Grading Systems',
        subtitle: 'Manage grading system templates',
        breadcrumb: 'Grading Systems',
        addLabel: 'Add Grading System',
        primaryKey: 'grading_system_type_id',
        columns: [
            { key: 'system_name', label: 'System Name' },
            { key: 'description', label: 'Description' }
        ],
        fields: [
            { key: 'system_name', label: 'System Name', type: 'text', required: true, maxLength: 100 },
            { key: 'description', label: 'Description', type: 'text', omitIfEmpty: true, maxLength: 255 }
        ],
        api: gradingSystemsApi
    });
});
