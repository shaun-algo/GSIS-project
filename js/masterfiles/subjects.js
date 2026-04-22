const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const subjectsApi = {
    list: async () => axios.get(`${API_BASE_URL}/subjects/subjects.php`, { params: { operation: 'getAllSubjects' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/subjects/subjects.php?operation=createSubject`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/subjects/subjects.php?operation=updateSubject`, { ...data, subject_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/subjects/subjects.php?operation=deleteSubject`, { subject_id: id }).then(r => r.data)
};

const subjectCodesApi = {
    list: async () => axios.get(`${API_BASE_URL}/subject_codes/subject_codes.php`, { params: { operation: 'getAllSubjectCodes' } }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'subjects',
        navKey: 'subjects',
        entity: 'Subject',
        pageTitle: 'Subject Catalog',
        subtitle: 'Manage subject masterfile',
        breadcrumb: 'Subjects',
        addLabel: 'Add Subject',
        primaryKey: 'subject_id',
        columns: [
            { key: 'subject_code', label: 'Code' },
            { key: 'subject_name', label: 'Subject Name' }
        ],
        fields: [
            {
                key: 'subject_code_id',
                label: 'Subject Code',
                type: 'select',
                required: true,
                valueKey: 'subject_code_id',
                labelKey: 'subject_code',
                loadOptions: subjectCodesApi.list
            },
            { key: 'subject_name', label: 'Subject Name', type: 'text', required: true, maxLength: 100 }
        ],
        api: subjectsApi
    });
});
