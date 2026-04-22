const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const subjectCodesApi = {
    list: async () => axios.get(`${API_BASE_URL}/subject_codes/subject_codes.php`, { params: { operation: 'getAllSubjectCodes' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/subject_codes/subject_codes.php?operation=createSubjectCode`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/subject_codes/subject_codes.php?operation=updateSubjectCode`, { ...data, subject_code_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/subject_codes/subject_codes.php?operation=deleteSubjectCode`, { subject_code_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'subject_codes',
        navKey: 'subject_codes',
        entity: 'Subject Code',
        pageTitle: 'Subject Codes',
        subtitle: 'Manage subject code definitions',
        breadcrumb: 'Subject Codes',
        addLabel: 'Add Subject Code',
        primaryKey: 'subject_code_id',
        columns: [
            { key: 'subject_code', label: 'Code' }
        ],
        fields: [
            { key: 'subject_code', label: 'Code', type: 'text', required: true, maxLength: 30 }
        ],
        api: subjectCodesApi
    });
});
