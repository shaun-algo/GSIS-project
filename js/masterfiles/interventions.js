const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const interventionsApi = {
    list: async () => axios.get(`${API_BASE_URL}/interventions/interventions.php`, { params: { operation: 'getAllInterventions' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/interventions/interventions.php?operation=createIntervention`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/interventions/interventions.php?operation=updateIntervention`, { ...data, intervention_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/interventions/interventions.php?operation=deleteIntervention`, { intervention_id: id }).then(r => r.data)
};

const enrollmentsApi = {
    list: async () => {
        const enrollments = await axios.get(`${API_BASE_URL}/enrollments/enrollments.php`, { params: { operation: 'getAllEnrollments' } }).then(r => r.data);
        return enrollments.map(e => ({ ...e, display_name: `${e.learner_name} - ${e.year_label}` }));
    }
};

const riskAssessmentsApi = {
    list: async () => {
        const assessments = await axios.get(`${API_BASE_URL}/risk_assessments/risk_assessments.php`, { params: { operation: 'getAllRiskAssessments' } }).then(r => r.data);
        return assessments.map(a => ({ ...a, display_name: `${a.learner_name} - ${a.period_name}` }));
    }
};

const employeesApi = {
    list: async () => {
        const employees = await axios.get(`${API_BASE_URL}/employees/employees.php`, { params: { operation: 'getAllEmployees' } }).then(r => r.data);
        return employees.map(e => ({ ...e, full_name: `${e.last_name}, ${e.first_name}` }));
    }
};

const interventionStatusesApi = {
    list: async () => axios.get(`${API_BASE_URL}/intervention_statuses/intervention_statuses.php`, { params: { operation: 'getAllInterventionStatuses' } }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'interventions',
        navKey: 'interventions',
        entity: 'Intervention',
        pageTitle: 'Interventions',
        subtitle: '',
        breadcrumb: 'Interventions',
        addLabel: 'Add Intervention',
        primaryKey: 'intervention_id',
        columns: [
            { key: 'learner_name', label: 'Learner' },
            { key: 'intervention_type', label: 'Type' },
            { key: 'conducted_by_name', label: 'Conducted By' },
            { key: 'conducted_at', label: 'Conducted At' },
            { key: 'status_name', label: 'Status' }
        ],
        fields: [
            {
                key: 'enrollment_id',
                label: 'Enrollment',
                type: 'select',
                required: true,
                valueKey: 'enrollment_id',
                labelKey: 'display_name',
                loadOptions: enrollmentsApi.list
            },
            {
                key: 'risk_assessment_id',
                label: 'Risk Assessment',
                type: 'select',
                required: false,
                valueKey: 'risk_assessment_id',
                labelKey: 'display_name',
                loadOptions: riskAssessmentsApi.list
            },
            {
                key: 'intervention_type',
                label: 'Intervention Type',
                type: 'select',
                required: true,
                valueKey: 'value',
                labelKey: 'label',
                loadOptions: async () => ([
                    { value: 'Counseling', label: 'Counseling' },
                    { value: 'Tutoring', label: 'Tutoring' },
                    { value: 'Home Visit', label: 'Home Visit' },
                    { value: 'Parent Conference', label: 'Parent Conference' },
                    { value: 'Referral', label: 'Referral' }
                ])
            },
            { key: 'description', label: 'Description', type: 'textarea', required: true },
            {
                key: 'conducted_by',
                label: 'Conducted By',
                type: 'select',
                required: true,
                valueKey: 'employee_id',
                labelKey: 'full_name',
                loadOptions: employeesApi.list
            },
            { key: 'follow_up_date', label: 'Follow-up Date', type: 'date', required: false },
            {
                key: 'intervention_status_id',
                label: 'Status',
                type: 'select',
                required: true,
                valueKey: 'intervention_status_id',
                labelKey: 'status_name',
                loadOptions: interventionStatusesApi.list
            },
            { key: 'notes', label: 'Notes', type: 'textarea', required: false }
        ],
        api: interventionsApi
    });
});
