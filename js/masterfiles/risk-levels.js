const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const riskLevelsApi = {
    list: async () => axios.get(`${API_BASE_URL}/risk_levels/risk_levels.php`, { params: { operation: 'getAllRiskLevels' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/risk_levels/risk_levels.php?operation=createRiskLevel`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/risk_levels/risk_levels.php?operation=updateRiskLevel`, { ...data, risk_level_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/risk_levels/risk_levels.php?operation=deleteRiskLevel`, { risk_level_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'risk_levels',
        navKey: 'risk_levels',
        entity: 'Risk Level',
        pageTitle: 'Risk Levels Masterfile',
        subtitle: 'Manage student risk classification levels',
        breadcrumb: 'Risk Levels',
        addLabel: 'Add Risk Level',
        primaryKey: 'risk_level_id',
        columns: [
            { key: 'risk_name', label: 'Risk Level Name' }
        ],
        fields: [
            { key: 'risk_name', label: 'Risk Level Name', type: 'text', required: true, maxLength: 50 }
        ],
        api: riskLevelsApi
    });
});
