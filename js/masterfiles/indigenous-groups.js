const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const indigenousGroupsApi = {
    list: async () => axios.get(`${API_BASE_URL}/indigenous_groups/indigenous_groups.php`, { params: { operation: 'getAllIndigenousGroups' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/indigenous_groups/indigenous_groups.php?operation=createIndigenousGroup`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/indigenous_groups/indigenous_groups.php?operation=updateIndigenousGroup`, { ...data, indigenous_group_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/indigenous_groups/indigenous_groups.php?operation=deleteIndigenousGroup`, { indigenous_group_id: id }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'indigenous_groups',
        navKey: 'indigenous_groups',
        entity: 'Indigenous Group',
        pageTitle: 'Indigenous Groups Masterfile',
        subtitle: 'Manage indigenous group records',
        breadcrumb: 'Indigenous Groups',
        addLabel: 'Add Indigenous Group',
        primaryKey: 'indigenous_group_id',
        columns: [
            { key: 'group_name', label: 'Group Name' }
        ],
        fields: [
            { key: 'group_name', label: 'Group Name', type: 'text', required: true, maxLength: 150 }
        ],
        api: indigenousGroupsApi
    });
});
