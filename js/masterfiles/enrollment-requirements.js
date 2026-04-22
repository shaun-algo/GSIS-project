const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const enrollmentRequirementsApi = {
    list: async () => axios.get(`${API_BASE_URL}/enrollment_requirements/enrollment_requirements.php`, { params: { operation: 'getAllRequirements', _: Date.now() } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/enrollment_requirements/enrollment_requirements.php?operation=createRequirement`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/enrollment_requirements/enrollment_requirements.php?operation=updateRequirement`, { ...data, requirement_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/enrollment_requirements/enrollment_requirements.php?operation=deleteRequirement`, { requirement_id: id }).then(r => r.data)
};

const schoolYearsApi = {
    list: async () => axios.get(`${API_BASE_URL}/school_years/school_years.php`, { params: { operation: 'getAllSchoolYears', _: Date.now() } }).then(r => r.data)
};

const gradeLevelsApi = {
    list: async () => axios.get(`${API_BASE_URL}/grade_levels/grade_levels.php`, { params: { operation: 'getAllGradeLevels', _: Date.now() } }).then(r => r.data)
};

const documentTypesApi = {
    list: async () => axios.get(`${API_BASE_URL}/document_types/document_types.php`, { params: { operation: 'getAllDocumentTypes', _: Date.now() } }).then(r => r.data)
};

const yesNoOptions = [
    { value: 1, label: 'Yes' },
    { value: 0, label: 'No' }
];

function formatYesNo(value) {
    const v = Number(value);
    return v === 1 ? 'Yes' : 'No';
}

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'enrollment_requirements',
        navKey: 'enrollment_requirements',
        entity: 'Requirement',
        pageTitle: 'Enrollment Requirements',
        subtitle: 'Configure required documents per school year and grade level',
        breadcrumb: 'Enrollment Requirements',
        addLabel: 'Add Requirement',
        primaryKey: 'requirement_id',
        columns: [
            { key: 'school_year_label', label: 'School Year' },
            { key: 'grade_name', label: 'Grade Level' },
            { key: 'type_name', label: 'Document Type' },
            { key: 'is_mandatory', label: 'Mandatory', formatter: (v) => formatYesNo(v) },
            { key: 'notes', label: 'Notes' }
        ],
        fields: [
            {
                key: 'school_year_id',
                label: 'School Year',
                type: 'select',
                required: true,
                valueKey: 'school_year_id',
                labelKey: 'year_label',
                loadOptions: schoolYearsApi.list
            },
            {
                key: 'grade_level_id',
                label: 'Grade Level (optional)',
                type: 'select',
                required: false,
                valueKey: 'grade_level_id',
                labelKey: 'grade_name',
                loadOptions: gradeLevelsApi.list
            },
            {
                key: 'document_type_id',
                label: 'Document Type',
                type: 'select',
                required: true,
                valueKey: 'document_type_id',
                labelKey: 'type_name',
                loadOptions: documentTypesApi.list
            },
            {
                key: 'is_mandatory',
                label: 'Mandatory',
                type: 'select',
                required: true,
                valueKey: 'value',
                labelKey: 'label',
                loadOptions: async () => yesNoOptions
            },
            { key: 'notes', label: 'Notes', type: 'text', required: false, maxLength: 255 }
        ],
        api: enrollmentRequirementsApi
    });
});
