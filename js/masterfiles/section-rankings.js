const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const sectionRankingsApi = {
    list: async () => axios.get(`${API_BASE_URL}/section_rankings/section_rankings.php`, { params: { operation: 'getAllSectionRankings' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/section_rankings/section_rankings.php?operation=createSectionRanking`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/section_rankings/section_rankings.php?operation=updateSectionRanking`, { ...data, section_ranking_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/section_rankings/section_rankings.php?operation=deleteSectionRanking`, { section_ranking_id: id }).then(r => r.data)
};

const enrollmentsApi = {
    list: async () => {
        const enrollments = await axios.get(`${API_BASE_URL}/enrollments/enrollments.php`, { params: { operation: 'getAllEnrollments' } }).then(r => r.data);
        return enrollments.map(e => ({ ...e, display_name: `${e.learner_name} - ${e.year_label}` }));
    }
};

const honorLevelsApi = {
    list: async () => axios.get(`${API_BASE_URL}/honor_levels/honor_levels.php`, { params: { operation: 'getAllHonorLevels' } }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'section_rankings',
        navKey: 'section_rankings',
        entity: 'Section Ranking',
        pageTitle: 'Section Rankings',
        subtitle: '',
        breadcrumb: 'Section Rankings',
        addLabel: 'Add Section Ranking',
        primaryKey: 'section_ranking_id',
        columns: [
            { key: 'learner_name', label: 'Learner' },
            { key: 'section_name', label: 'Section' },
            { key: 'rank', label: 'Rank' },
            { key: 'honor_name', label: 'Honor' }
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
            { key: 'rank', label: 'Rank', type: 'number', required: true },
            {
                key: 'honor_level_id',
                label: 'Honor Level',
                type: 'select',
                required: false,
                valueKey: 'honor_level_id',
                labelKey: 'honor_name',
                loadOptions: honorLevelsApi.list
            }
        ],
        api: sectionRankingsApi
    });
});
