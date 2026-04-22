const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const familyMembersApi = {
    list: async () => axios.get(`${API_BASE_URL}/family_members/family_members.php`, { params: { operation: 'getAllFamilyMembers' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/family_members/family_members.php?operation=createFamilyMember`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/family_members/family_members.php?operation=updateFamilyMember`, { ...data, family_member_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/family_members/family_members.php?operation=deleteFamilyMember`, { family_member_id: id }).then(r => r.data)
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
        key: 'family_members',
        navKey: 'family_members',
        entity: 'Family Member',
        pageTitle: 'Family Members',
        subtitle: '',
        breadcrumb: 'Family Members',
        addLabel: 'Add Family Member',
        primaryKey: 'family_member_id',
        columns: [
            { key: 'learner_name', label: 'Learner' },
            { key: 'full_name', label: 'Family Member' },
            { key: 'relationship_name', label: 'Relationship' },
            { key: 'occupation', label: 'Occupation' },
            { key: 'contact_number', label: 'Contact' }
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
            { key: 'full_name', label: 'Full Name', type: 'text', required: true },
            {
                key: 'family_relationship_id',
                label: 'Relationship',
                type: 'select',
                required: true,
                valueKey: 'family_relationship_id',
                labelKey: 'relationship_name',
                loadOptions: familyRelationshipsApi.list
            },
            { key: 'date_of_birth', label: 'Birth Date', type: 'date', required: false },
            { key: 'occupation', label: 'Occupation', type: 'text', required: false },
            { key: 'contact_number', label: 'Contact Number', type: 'tel', required: false },
            { key: 'monthly_income', label: 'Monthly Income', type: 'number', step: '0.01', required: false }
        ],
        api: familyMembersApi
    });
});
