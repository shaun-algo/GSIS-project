const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const sectionsApi = {
    list: async () => axios.get(`${API_BASE_URL}/sections/sections.php`, { params: { operation: 'getAllSections' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/sections/sections.php?operation=createSection`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/sections/sections.php?operation=updateSection`, { ...data, section_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/sections/sections.php?operation=deleteSection`, { section_id: id }).then(r => r.data)
};

const gradeLevelsApi = {
    list: async () => axios.get(`${API_BASE_URL}/grade_levels/grade_levels.php`, { params: { operation: 'getAllGradeLevels' } }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'sections',
        navKey: 'sections',
        entity: 'Section',
        pageTitle: 'Section Masterfile',
        subtitle: 'Manage school sections',
        breadcrumb: 'Sections',
        addLabel: 'Add Section',
        primaryKey: 'section_id',
        columns: [
            { key: 'grade_name', label: 'Grade Level' },
            { key: 'section_name', label: 'Section Name' },
            { key: 'max_capacity', label: 'Capacity' },
            { key: 'enrolled_count', label: 'Enrolled' },
            { key: 'available_slots', label: 'Slots Left' },
            { key: 'is_full', label: 'Status', formatter: occupancyBadge }
        ],
        fields: [
            {
                key: 'grade_level_id',
                label: 'Grade Level',
                type: 'select',
                required: true,
                valueKey: 'grade_level_id',
                labelKey: 'grade_name',
                loadOptions: gradeLevelsApi.list
            },
            { key: 'section_name', label: 'Section Name', type: 'text', required: true, maxLength: 50 },
            { key: 'max_capacity', label: 'Max Capacity', type: 'number', required: true, defaultValue: 45 }
        ],
        api: sectionsApi
    });
});

function occupancyBadge(value, row) {
    const isFull = value === 1 || value === true || value === '1' || Number(row?.available_slots || 0) <= 0;
    return `<span class="status-badge ${isFull ? 'inactive' : 'active'}">${isFull ? 'Full' : 'Available'}</span>`;
}
