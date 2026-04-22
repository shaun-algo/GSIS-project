const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const schoolYearsApi = {
    list: async () => axios.get(`${API_BASE_URL}/school_years/school_years.php`, { params: { operation: 'getAllSchoolYears' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/school_years/school_years.php?operation=createSchoolYear`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/school_years/school_years.php?operation=updateSchoolYear`, { ...data, school_year_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/school_years/school_years.php?operation=deleteSchoolYear`, { school_year_id: id }).then(r => r.data)
};

const gradingSystemOptions = [
    { value: 'Quarterly', label: 'Quarterly' },
    { value: 'Trimester', label: 'Trimester' },
    { value: 'Semester', label: 'Semester' }
];

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'school_years',
        navKey: 'school_years',
        entity: 'School Year',
        pageTitle: 'School Years',
        subtitle: 'Manage school year definitions',
        breadcrumb: 'School Years',
        addLabel: 'Add School Year',
        primaryKey: 'school_year_id',
        columns: [
            { key: 'year_label', label: 'School Year', formatter: (_value, row) => row.year_label || `${row.year_start}-${row.year_end}` },
            { key: 'system_name', label: 'Grading System' },
            { key: 'is_active', label: 'Active', formatter: (value) => (value ? 'Yes' : 'No') }
        ],
        fields: [
            { key: 'year_start', label: 'Year Start', type: 'number', required: true },
            { key: 'year_end', label: 'Year End', type: 'number', required: true },
            { key: 'date_start', label: 'Start Date', type: 'date', omitIfEmpty: true },
            { key: 'date_end', label: 'End Date', type: 'date', omitIfEmpty: true },
            {
                key: 'grading_system_type',
                label: 'Grading System Type',
                type: 'select',
                required: true,
                valueKey: 'value',
                labelKey: 'label',
                loadOptions: async () => gradingSystemOptions
            },
            { key: 'is_active', label: 'Set as Active Year', type: 'checkbox', defaultValue: false }
        ],
        api: schoolYearsApi
    });
});
