const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const gradingPeriodsApi = {
    list: async () => axios.get(`${API_BASE_URL}/grading_periods/grading_periods.php`, { params: { operation: 'getAllGradingPeriods' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/grading_periods/grading_periods.php?operation=createGradingPeriod`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/grading_periods/grading_periods.php?operation=updateGradingPeriod`, { ...data, grading_period_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/grading_periods/grading_periods.php?operation=deleteGradingPeriod`, { grading_period_id: id }).then(r => r.data)
};

const schoolYearsApi = {
    list: async () => axios.get(`${API_BASE_URL}/school_years/school_years.php`, { params: { operation: 'getAllSchoolYears' } }).then(r => r.data)
};

const gradingPeriodStatusesApi = {
    list: async () => axios.get(`${API_BASE_URL}/grading_period_statuses/grading_period_statuses.php`, { params: { operation: 'getAllGradingPeriodStatuses' } }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'grading_periods',
        navKey: 'grading_periods',
        entity: 'Grading Period',
        pageTitle: 'Grading Periods',
        subtitle: '',
        breadcrumb: 'Grading Periods',
        addLabel: 'Add Grading Period',
        primaryKey: 'grading_period_id',
        columns: [
            { key: 'year_label', label: 'School Year' },
            { key: 'period_name', label: 'Period' },
            { key: 'date_start', label: 'Start Date' },
            { key: 'date_end', label: 'End Date' },
            { key: 'status_name', label: 'Status' }
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
            { key: 'period_name', label: 'Period Name', type: 'text', required: true, maxLength: 50 },
            { key: 'date_start', label: 'Start Date', type: 'date', required: true },
            { key: 'date_end', label: 'End Date', type: 'date', required: true },
            {
                key: 'grading_period_status_id',
                label: 'Status',
                type: 'select',
                required: true,
                valueKey: 'grading_period_status_id',
                labelKey: 'status_name',
                loadOptions: gradingPeriodStatusesApi.list
            }
        ],
        api: gradingPeriodsApi
    });
});
