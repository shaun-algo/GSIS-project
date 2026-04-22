const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const documentTypesApi = {
    list: async () => axios.get(`${API_BASE_URL}/document_types/document_types.php`, { params: { operation: 'getAllDocumentTypes' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/document_types/document_types.php?operation=createDocumentType`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/document_types/document_types.php?operation=updateDocumentType`, { ...data, document_type_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/document_types/document_types.php?operation=deleteDocumentType`, { document_type_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'document_types',
        navKey: 'document_types',
        entity: 'Document Type',
        pageTitle: 'Document Types Masterfile',
        subtitle: 'Manage document type records',
        breadcrumb: 'Document Types',
        addLabel: 'Add Document Type',
        primaryKey: 'document_type_id',
        columns: [
            { key: 'type_name', label: 'Type Name' },
            { key: 'description', label: 'Description' }
        ],
        fields: [
            { key: 'type_name', label: 'Type Name', type: 'text', required: true, maxLength: 100 },
            { key: 'description', label: 'Description', type: 'text', required: false, maxLength: 255 }
        ],
        api: documentTypesApi
    });
});
