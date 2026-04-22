const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const familyRelationshipsApi = {
    list: async () => axios.get(`${API_BASE_URL}/family_relationships/family_relationships.php`, { params: { operation: 'getAllFamilyRelationships' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/family_relationships/family_relationships.php?operation=createFamilyRelationship`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/family_relationships/family_relationships.php?operation=updateFamilyRelationship`, { ...data, family_relationship_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/family_relationships/family_relationships.php?operation=deleteFamilyRelationship`, { family_relationship_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'family_relationships',
        navKey: 'family_relationships',
        entity: 'Family Relationship',
        pageTitle: 'Family Relationships Masterfile',
        subtitle: 'Manage family relationship types',
        breadcrumb: 'Family Relationships',
        addLabel: 'Add Relationship',
        primaryKey: 'family_relationship_id',
        columns: [
            { key: 'relationship_name', label: 'Relationship Name' }
        ],
        fields: [
            { key: 'relationship_name', label: 'Relationship Name', type: 'text', required: true, maxLength: 50 }
        ],
        api: familyRelationshipsApi
    });
});
