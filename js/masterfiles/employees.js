const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

function normalizeOptionRows(data) {
    if (Array.isArray(data)) return data;
    if (Array.isArray(data?.rows)) return data.rows;
    if (Array.isArray(data?.data)) return data.data;
    return [];
}

const employeesApi = {
    list: async () => axios.get(`${API_BASE_URL}/employees/employees.php`, { params: { operation: 'getAllEmployees' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/employees/employees.php?operation=createEmployee`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/employees/employees.php?operation=updateEmployee`, { ...data, employee_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/employees/employees.php?operation=deleteEmployee`, { employee_id: id }).then(r => r.data)
};

const positionsApi = {
    list: async () => axios.get(`${API_BASE_URL}/positions/positions.php`, { params: { operation: 'getAllPositions', _: Date.now() } })
        .then(r => normalizeOptionRows(r.data))
};

const rolesApi = {
    list: async () => axios.get(`${API_BASE_URL}/roles/roles.php`, { params: { operation: 'getAllRoles', _: Date.now() } })
        .then(r => normalizeOptionRows(r.data))
};

function formatEmployeeFullName(row) {
    const first = (row?.first_name || '').trim();
    const middle = (row?.middle_name || '').trim();
    const last = (row?.last_name || '').trim();
    const ext = (row?.name_extension || '').trim();
    return [first, middle, last, ext].filter(Boolean).join(' ');
}

function maskEmployeeNumber(value) {
    const s = String(value ?? '').trim();
    if (!s) return '';

    const first2 = s.slice(0, 2);
    const next2 = s.slice(2, 4);
    const last1 = s.slice(-1);

    if (s.length <= 4) {
        return `${first2}**${last1}`;
    }

    return `${first2}**${next2}**${last1}`;
}

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'employees',
        navKey: 'employees',
        entity: 'Employee',
        pageTitle: 'Employee Directory',
        subtitle: 'Manage employee masterfile',
        breadcrumb: 'Employees',
        addLabel: 'Add Employee',
        primaryKey: 'employee_id',
        enableView: true,
        columns: [
            { key: 'employee_number', label: 'Employee #', formatter: (v) => maskEmployeeNumber(v) },
            { key: 'full_name', label: 'Full Name', formatter: (_v, row) => formatEmployeeFullName(row) },
            { key: 'contact_number', label: 'Phone #'},
            { key: 'email', label: 'Email' }
        ],
        fields: [
            { key: 'employee_number', label: 'Employee #', type: 'text', required: true },
            { key: 'first_name', label: 'First Name', type: 'text', required: true },
            { key: 'middle_name', label: 'Middle Name', type: 'text' },
            { key: 'last_name', label: 'Last Name', type: 'text', required: true },
            { key: 'name_extension', label: 'Name Extension', type: 'text' },
            { key: 'date_of_birth', label: 'Birth Date', type: 'date' },
            {
                key: 'gender',
                label: 'Gender',
                type: 'select',
                valueKey: 'value',
                labelKey: 'label',
                loadOptions: async () => ([
                    { value: 'Male', label: 'Male' },
                    { value: 'Female', label: 'Female' },
                    { value: 'Other', label: 'Other' }
                ])
            },
            { key: 'contact_number', label: 'Contact #', type: 'text' },
            { key: 'email', label: 'Email', type: 'text' },
            { key: 'address', label: 'Address', type: 'text' },
            {
                key: 'position_id',
                label: 'Position',
                type: 'select',
                valueKey: 'position_id',
                labelKey: 'position_name',
                loadOptions: async () => await positionsApi.list()
            },
            {
                key: 'role_id',
                label: 'Role',
                type: 'select',
                required: true,
                valueKey: 'role_id',
                labelKey: 'role_name',
                loadOptions: async () => await rolesApi.list()
            },
            { key: 'date_hired', label: 'Date Hired', type: 'date' }
        ],
        api: employeesApi
    });
});
