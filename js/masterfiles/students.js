const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const studentsApi = {
    list: async () => axios.get(`${API_BASE_URL}/students/students.php`, { params: { operation: 'getAllStudents' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/students/students.php?operation=createStudent`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/students/students.php?operation=updateStudent`, { ...data, learner_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/students/students.php?operation=deleteStudent`, { learner_id: id }).then(r => r.data)
};

const learnerStatusesApi = {
    list: async () => axios.get(`${API_BASE_URL}/student_statuses/student_statuses.php`, { params: { operation: 'getAllStudentStatuses' } }).then(r => r.data)
};

const gradeLevelsApi = {
    list: async () => axios.get(`${API_BASE_URL}/grade_levels/grade_levels.php`, { params: { operation: 'getAllGradeLevels' } }).then(r => r.data)
};

const sectionsApi = {
    list: async () => axios.get(`${API_BASE_URL}/sections/sections.php`, { params: { operation: 'getAllSections' } }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'students',
        navKey: 'students',
        entity: 'Student',
        pageTitle: 'Students',
        subtitle: 'Manage student records',
        breadcrumb: 'Students',
        addLabel: 'Add Student',
        primaryKey: 'learner_id',
        columns: [
            { key: 'lrn', label: 'LRN' },
            { key: 'last_name', label: 'Last Name' },
            { key: 'first_name', label: 'First Name' },
            { key: 'grade_name', label: 'Grade' },
            { key: 'section_name', label: 'Section' },
            { key: 'gender', label: 'Gender' },
            { key: 'status_name', label: 'Status' }
        ],
        fields: [
            { key: 'lrn', label: 'LRN', type: 'text', required: true, maxLength: 12 },
            { key: 'first_name', label: 'First Name', type: 'text', required: true },
            { key: 'middle_name', label: 'Middle Name', type: 'text', omitIfEmpty: true },
            { key: 'last_name', label: 'Last Name', type: 'text', required: true },
            { key: 'date_of_birth', label: 'Birth Date', type: 'date' },
            {
                key: 'gender',
                label: 'Gender',
                type: 'select',
                required: true,
                valueKey: 'value',
                labelKey: 'label',
                loadOptions: async () => ([{ value: 'Male', label: 'Male' }, { value: 'Female', label: 'Female' }])
            },
            {
                key: 'grade_level_id',
                label: 'Grade Level',
                type: 'select',
                required: true,
                valueKey: 'grade_level_id',
                labelKey: 'grade_name',
                loadOptions: gradeLevelsApi.list
            },
            {
                key: 'section_id',
                label: 'Section',
                type: 'select',
                required: true,
                valueKey: 'section_id',
                labelKey: 'section_name',
                loadOptions: sectionsApi.list
            },
            {
                key: 'learner_status_id',
                label: 'Status',
                type: 'select',
                required: false,
                valueKey: 'learner_status_id',
                labelKey: 'status_name',
                loadOptions: learnerStatusesApi.list
            }
        ],
        api: studentsApi
    });
});
