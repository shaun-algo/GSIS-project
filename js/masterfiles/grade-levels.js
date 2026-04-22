const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const gradeLevelsApi = {
    list: async () => axios.get(`${API_BASE_URL}/grade_levels/grade_levels.php`, { params: { operation: 'getAllGradeLevels' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/grade_levels/grade_levels.php?operation=createGradeLevel`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/grade_levels/grade_levels.php?operation=updateGradeLevel`, { ...data, grade_level_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/grade_levels/grade_levels.php?operation=deleteGradeLevel`, { grade_level_id: id }).then(r => r.data)
};

const educationLevelsApi = {
    list: async () => axios.get(`${API_BASE_URL}/education_levels/education_levels.php`, { params: { operation: 'getAllEducationLevels' } }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'grade_levels',
        navKey: 'grade_levels',
        entity: 'Grade Level',
        pageTitle: 'Grade Levels',
        subtitle: 'Manage grade level offerings',
        breadcrumb: 'Grade Levels',
        addLabel: 'Add Grade Level',
        primaryKey: 'grade_level_id',
        columns: [
            { key: 'grade_name', label: 'Grade Name' },
            { key: 'level_name', label: 'Education Level' }
        ],
        fields: [
            { key: 'grade_name', label: 'Grade Name', type: 'text', required: true, maxLength: 50 },
            {
                key: 'education_level_id',
                label: 'Education Level',
                type: 'select',
                required: true,
                valueKey: 'education_level_id',
                labelKey: 'level_name',
                loadOptions: educationLevelsApi.list
            }
        ],
        api: gradeLevelsApi
    });
});
