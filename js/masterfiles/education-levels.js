const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const educationLevelsApi = {
    list: async () => axios.get(`${API_BASE_URL}/education_levels/education_levels.php`, { params: { operation: 'getAllEducationLevels' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/education_levels/education_levels.php?operation=createEducationLevel`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/education_levels/education_levels.php?operation=updateEducationLevel`, { ...data, education_level_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/education_levels/education_levels.php?operation=deleteEducationLevel`, { education_level_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'education_levels',
        navKey: 'education_levels',
        entity: 'Education Level',
        pageTitle: 'Education Levels',
        subtitle: 'Manage education levels',
        breadcrumb: 'Education Levels',
        addLabel: 'Add Education Level',
        primaryKey: 'education_level_id',
        columns: [
            { key: 'level_name', label: 'Level Name' }
        ],
        fields: [
            { key: 'level_name', label: 'Level Name', type: 'text', required: true, maxLength: 100 }
        ],
        api: educationLevelsApi
    });
});
