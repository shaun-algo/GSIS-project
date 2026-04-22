const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const emergencyContactsApi = {
    list: async () => axios.get(`${API_BASE_URL}/emergency_contacts/emergency_contacts.php`, { params: { operation: 'getAllEmergencyContacts' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/emergency_contacts/emergency_contacts.php?operation=createEmergencyContact`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/emergency_contacts/emergency_contacts.php?operation=updateEmergencyContact`, { ...data, emergency_contact_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/emergency_contacts/emergency_contacts.php?operation=deleteEmergencyContact`, { emergency_contact_id: id }).then(r => r.data)
};

const learnersApi = {
    list: async () => {
        const learners = await axios.get(`${API_BASE_URL}/learners/learners.php`, { params: { operation: 'getAllLearners' } }).then(r => r.data);
        return learners.map(l => ({ ...l, full_name: `${l.last_name}, ${l.first_name}` }));
    }
};

const familyRelationshipsApi = {
    list: async () => axios.get(`${API_BASE_URL}/family_relationships/family_relationships.php`, { params: { operation: 'getAllFamilyRelationships' } }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'emergency_contacts',
        navKey: 'emergency_contacts',
        entity: 'Emergency Contact',
        pageTitle: 'Emergency Contacts',
        subtitle: '',
        breadcrumb: 'Emergency Contacts',
        addLabel: 'Add Emergency Contact',
        primaryKey: 'emergency_contact_id',
        columns: [
            { key: 'learner_name', label: 'Learner' },
            { key: 'contact_name', label: 'Contact Name' },
            { key: 'relationship_name', label: 'Relationship' },
            { key: 'contact_number', label: 'Contact Number' },
            { key: 'address', label: 'Address' }
        ],
        fields: [
            {
                key: 'learner_id',
                label: 'Learner',
                type: 'select',
                required: true,
                valueKey: 'learner_id',
                labelKey: 'full_name',
                loadOptions: learnersApi.list
            },
            { key: 'contact_name', label: 'Contact Name', type: 'text', required: true },
            {
                key: 'family_relationship_id',
                label: 'Relationship',
                type: 'select',
                required: true,
                valueKey: 'family_relationship_id',
                labelKey: 'relationship_name',
                loadOptions: familyRelationshipsApi.list
            },
            { key: 'contact_number', label: 'Contact Number', type: 'tel', required: false },
            { key: 'address', label: 'Address', type: 'textarea', required: false }
        ],
        api: emergencyContactsApi
    });
});
