const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const learningModalitiesApi = {
    list: async () => axios.get(`${API_BASE_URL}/learning_modalities/learning_modalities.php`, { params: { operation: 'getAllLearningModalities' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/learning_modalities/learning_modalities.php?operation=createLearningModality`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/learning_modalities/learning_modalities.php?operation=updateLearningModality`, { ...data, modality_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/learning_modalities/learning_modalities.php?operation=deleteLearningModality`, { modality_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'learning_modalities',
        navKey: 'learning_modalities',
        entity: 'Learning Modality',
        pageTitle: 'Learning Modalities Masterfile',
        subtitle: 'Manage learning modality records',
        breadcrumb: 'Learning Modalities',
        addLabel: 'Add Learning Modality',
        primaryKey: 'modality_id',
        columns: [
            { key: 'modality_name', label: 'Modality Name' },
            { key: 'description', label: 'Description' }
        ],
        fields: [
            { key: 'modality_name', label: 'Modality Name', type: 'text', required: true, maxLength: 100 },
            { key: 'description', label: 'Description', type: 'text', required: false, maxLength: 255 }
        ],
        api: learningModalitiesApi
    });
});
