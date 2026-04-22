const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const curriculaApi = {
    list: async () => axios.get(`${API_BASE_URL}/curricula/curricula.php`, { params: { operation: 'getAllCurricula' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/curricula/curricula.php?operation=createCurriculum`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/curricula/curricula.php?operation=updateCurriculum`, { ...data, curriculum_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/curricula/curricula.php?operation=deleteCurriculum`, { curriculum_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'curricula',
        navKey: 'curricula',
        entity: 'Curriculum',
        pageTitle: 'Curricula',
        subtitle: 'Manage DepEd curriculum editions',
        breadcrumb: 'Curricula',
        addLabel: 'Add Curriculum',
        primaryKey: 'curriculum_id',
        columns: [
            { key: 'curriculum_code', label: 'Code', sortable: true },
            { key: 'curriculum_name', label: 'Name', sortable: true },
            { key: 'effective_from', label: 'Effective From', sortable: true },
            { key: 'effective_until', label: 'Effective Until', sortable: true, formatter: (v) => (v ? v : '-') },
        ],
        fields: [
            { key: 'curriculum_code', label: 'Curriculum Code', type: 'text', required: true, maxLength: 30 },
            { key: 'curriculum_name', label: 'Curriculum Name', type: 'text', required: true, maxLength: 150 },
            { key: 'description', label: 'Description', type: 'text', omitIfEmpty: true },
            { key: 'effective_from', label: 'Effective From (Year)', type: 'number', required: true },
            { key: 'effective_until', label: 'Effective Until (Year)', type: 'number', omitIfEmpty: true },
        ],
        api: curriculaApi
    });
});
