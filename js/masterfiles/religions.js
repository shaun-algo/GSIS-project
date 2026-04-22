const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const religionsApi = {
    list: async () => axios.get(`${API_BASE_URL}/religions/religions.php`, { params: { operation: 'getAllReligions' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/religions/religions.php?operation=createReligion`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/religions/religions.php?operation=updateReligion`, { ...data, religion_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/religions/religions.php?operation=deleteReligion`, { religion_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'religions',
        navKey: 'religions',
        entity: 'Religion',
        pageTitle: 'Religion Masterfile',
        subtitle: 'Manage religion records',
        breadcrumb: 'Religions',
        addLabel: 'Add Religion',
        primaryKey: 'religion_id',
        columns: [
            { key: 'religion_name', label: 'Religion Name' }
        ],
        fields: [
            { key: 'religion_name', label: 'Religion Name', type: 'text', required: true, maxLength: 50 }
        ],
        api: religionsApi
    });
});
