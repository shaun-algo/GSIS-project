const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const positionsApi = {
    list: async () => axios.get(`${API_BASE_URL}/positions/positions.php`, { params: { operation: 'getAllPositions' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/positions/positions.php?operation=createPosition`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/positions/positions.php?operation=updatePosition`, { ...data, position_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/positions/positions.php?operation=deletePosition`, { position_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'positions',
        navKey: 'positions',
        entity: 'Position',
        pageTitle: 'Position Management',
        subtitle: 'Manage employee position lookup values',
        breadcrumb: 'Positions',
        addLabel: 'Add Position',
        primaryKey: 'position_id',
        columns: [
            { key: 'position_name', label: 'Position Name' },
            { key: 'description', label: 'Description' }
        ],
        fields: [
            { key: 'position_name', label: 'Position Name', type: 'text', required: true, maxLength: 150 },
            { key: 'description', label: 'Description', type: 'text', maxLength: 255 }
        ],
        api: positionsApi
    });
});
