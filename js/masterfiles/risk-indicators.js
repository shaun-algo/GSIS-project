const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const riskIndicatorsApi = {
    list: async () => axios.get(`${API_BASE_URL}/risk_indicators/risk_indicators.php`, { params: { operation: 'getAllRiskIndicators' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/risk_indicators/risk_indicators.php?operation=createRiskIndicator`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/risk_indicators/risk_indicators.php?operation=updateRiskIndicator`, { ...data, risk_indicator_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/risk_indicators/risk_indicators.php?operation=deleteRiskIndicator`, { risk_indicator_id: id }).then(r => r.data)
};

const riskAssessmentsApi = {
    list: async () => {
        const assessments = await axios.get(`${API_BASE_URL}/risk_assessments/risk_assessments.php`, { params: { operation: 'getAllRiskAssessments' } }).then(r => r.data);
        return assessments.map(a => ({ ...a, display_name: `${a.learner_name} - ${a.period_name} (${a.risk_name})` }));
    }
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'risk_indicators',
        navKey: 'risk_indicators',
        entity: 'Risk Indicator',
        pageTitle: 'Risk Indicators',
        subtitle: '',
        breadcrumb: 'Risk Indicators',
        addLabel: 'Add Risk Indicator',
        primaryKey: 'risk_indicator_id',
        columns: [
            { key: 'learner_name', label: 'Learner' },
            { key: 'indicator_type', label: 'Indicator Type' },
            { key: 'details', label: 'Details' }
        ],
        fields: [
            {
                key: 'risk_assessment_id',
                label: 'Risk Assessment',
                type: 'select',
                required: true,
                valueKey: 'risk_assessment_id',
                labelKey: 'display_name',
                loadOptions: riskAssessmentsApi.list
            },
            {
                key: 'indicator_type',
                label: 'Indicator Type',
                type: 'select',
                required: true,
                valueKey: 'value',
                labelKey: 'label',
                loadOptions: async () => ([
                    { value: 'Attendance', label: 'Attendance' },
                    { value: 'Grade Drop', label: 'Grade Drop' },
                    { value: 'Behavioral', label: 'Behavioral' },
                    { value: 'Family', label: 'Family' },
                    { value: 'Health', label: 'Health' }
                ])
            },
            { key: 'details', label: 'Details', type: 'textarea', required: false }
        ],
        api: riskIndicatorsApi
    });
});
