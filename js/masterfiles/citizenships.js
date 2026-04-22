const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const citizenshipsApi = {
    list: async () => axios.get(`${API_BASE_URL}/citizenships/citizenships.php`, { params: { operation: 'getAllCitizenships', _: Date.now() } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/citizenships/citizenships.php?operation=createCitizenship`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/citizenships/citizenships.php?operation=updateCitizenship`, { ...data, citizenship_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/citizenships/citizenships.php?operation=deleteCitizenship`, { citizenship_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'citizenships',
        navKey: 'citizenships',
        entity: 'Citizenship',
        pageTitle: 'Citizenships',
        subtitle: 'Manage citizenship/country lookup values',
        breadcrumb: 'Citizenships',
        addLabel: 'Add Citizenship',
        primaryKey: 'citizenship_id',
        columns: [
            { key: 'country_name', label: 'Country' }
        ],
        fields: [
            { key: 'country_name', label: 'Country', type: 'text', required: true, maxLength: 100 }
        ],
        api: citizenshipsApi
    });
});
