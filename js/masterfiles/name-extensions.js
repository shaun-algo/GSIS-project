const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const nameExtensionsApi = {
    list: async () => axios.get(`${API_BASE_URL}/name_extensions/name_extensions.php`, { params: { operation: 'getAllNameExtensions' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/name_extensions/name_extensions.php?operation=createNameExtension`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/name_extensions/name_extensions.php?operation=updateNameExtension`, { ...data, extension_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/name_extensions/name_extensions.php?operation=deleteNameExtension`, { extension_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'name_extensions',
        navKey: 'name_extensions',
        entity: 'Name Extension',
        pageTitle: 'Name Extensions Masterfile',
        subtitle: 'Manage name suffix extensions (Jr., Sr., II, etc.)',
        breadcrumb: 'Name Extensions',
        addLabel: 'Add Extension',
        primaryKey: 'extension_id',
        columns: [
            { key: 'extension_name', label: 'Extension' }
        ],
        fields: [
            { key: 'extension_name', label: 'Extension (e.g. Jr., Sr., II)', type: 'text', required: true, maxLength: 10 }
        ],
        api: nameExtensionsApi
    });
});
