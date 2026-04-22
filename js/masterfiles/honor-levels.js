const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const honorLevelsApi = {
    list: async () => axios.get(`${API_BASE_URL}/honor_levels/honor_levels.php`, { params: { operation: 'getAllHonorLevels' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/honor_levels/honor_levels.php?operation=createHonorLevel`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/honor_levels/honor_levels.php?operation=updateHonorLevel`, { ...data, honor_level_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/honor_levels/honor_levels.php?operation=deleteHonorLevel`, { honor_level_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'honor_levels',
        navKey: 'honor_levels',
        entity: 'Honor Level',
        pageTitle: 'Honor Levels Masterfile',
        subtitle: 'Configure DepEd honors policy (GWA thresholds)',
        breadcrumb: 'Honor Levels',
        addLabel: 'Add Honor Level',
        primaryKey: 'honor_level_id',
        columns: [
            { key: 'honor_name',        label: 'Honor Name' },
            { key: 'min_average',       label: 'Min GWA' },
            { key: 'max_average',       label: 'Max GWA' },
            { key: 'description',       label: 'Description' }
        ],
        fields: [
            { key: 'honor_name',        label: 'Honor Name',              type: 'text',   required: true,  maxLength: 100 },
            { key: 'min_average',       label: 'Minimum GWA',             type: 'number', required: true  },
            { key: 'max_average',       label: 'Maximum GWA',             type: 'number', required: true  },
            { key: 'description',       label: 'Description',             type: 'text',   omitIfEmpty: true, maxLength: 255 }
        ],
        api: honorLevelsApi
    });
});
