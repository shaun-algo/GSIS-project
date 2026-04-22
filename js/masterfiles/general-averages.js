const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const generalAveragesApi = {
    list: async () => axios.get(`${API_BASE_URL}/general_averages/general_averages.php`, { params: { operation: 'getAllGeneralAverages' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/general_averages/general_averages.php?operation=createGeneralAverage`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/general_averages/general_averages.php?operation=updateGeneralAverage`, { ...data, general_average_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/general_averages/general_averages.php?operation=deleteGeneralAverage`, { general_average_id: id }).then(r => r.data)
};

const enrollmentsApi = {
    list: async () => {
        const enrollments = await axios.get(`${API_BASE_URL}/enrollments/enrollments.php`, { params: { operation: 'getAllEnrollments' } }).then(r => r.data);
        return enrollments.map(e => ({ ...e, display_name: `${e.learner_name} - ${e.year_label}` }));
    }
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'general_averages',
        navKey: 'general_averages',
        entity: 'General Average',
        pageTitle: 'General Averages',
        subtitle: '',
        breadcrumb: 'General Averages',
        addLabel: 'Add General Average',
        primaryKey: 'general_average_id',
        columns: [
            { key: 'learner_name', label: 'Learner' },
            { key: 'year_label', label: 'School Year' },
            { key: 'general_average', label: 'General Average' }
        ],
        fields: [
            {
                key: 'enrollment_id',
                label: 'Enrollment',
                type: 'select',
                required: true,
                valueKey: 'enrollment_id',
                labelKey: 'display_name',
                loadOptions: enrollmentsApi.list
            },
            { key: 'general_average', label: 'General Average', type: 'number', step: '0.01', required: true }
        ],
        api: generalAveragesApi
    });
});
