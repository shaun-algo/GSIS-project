const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const motherTonguesApi = {
    list: async () => axios.get(`${API_BASE_URL}/mother_tongues/mother_tongues.php`, { params: { operation: 'getAllMotherTongues' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/mother_tongues/mother_tongues.php?operation=createMotherTongue`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/mother_tongues/mother_tongues.php?operation=updateMotherTongue`, { ...data, mother_tongue_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/mother_tongues/mother_tongues.php?operation=deleteMotherTongue`, { mother_tongue_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'mother_tongues',
        navKey: 'mother_tongues',
        entity: 'Mother Tongue',
        pageTitle: 'Mother Tongues Masterfile',
        subtitle: 'Manage mother tongue records',
        breadcrumb: 'Mother Tongues',
        addLabel: 'Add Mother Tongue',
        primaryKey: 'mother_tongue_id',
        columns: [
            { key: 'tongue_name', label: 'Tongue Name' }
        ],
        fields: [
            { key: 'tongue_name', label: 'Tongue Name', type: 'text', required: true, maxLength: 100 }
        ],
        api: motherTonguesApi
    });
});
