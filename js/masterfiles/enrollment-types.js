const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const enrollmentTypesApi = {
    list: async () => axios.get(`${API_BASE_URL}/enrollment_types/enrollment_types.php`, { params: { operation: 'getAllEnrollmentTypes' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/enrollment_types/enrollment_types.php?operation=createEnrollmentType`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/enrollment_types/enrollment_types.php?operation=updateEnrollmentType`, { ...data, enrollment_type_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/enrollment_types/enrollment_types.php?operation=deleteEnrollmentType`, { enrollment_type_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'enrollment_types',
        navKey: 'enrollment_types',
        entity: 'Enrollment Type',
        pageTitle: 'Enrollment Types Masterfile',
        subtitle: 'Manage enrollment type records',
        breadcrumb: 'Enrollment Types',
        addLabel: 'Add Enrollment Type',
        primaryKey: 'enrollment_type_id',
        columns: [
            { key: 'type_name', label: 'Type Name' },
            { key: 'description', label: 'Description' }
        ],
        fields: [
            { key: 'type_name', label: 'Type Name', type: 'text', required: true, maxLength: 100 },
            { key: 'description', label: 'Description', type: 'text', required: false, maxLength: 255 }
        ],
        api: enrollmentTypesApi
    });
});
