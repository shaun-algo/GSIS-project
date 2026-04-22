const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const gradesApi = {
    list: async () => axios.get(`${API_BASE_URL}/grades/grades.php`, { params: { operation: 'getAllGrades' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/grades/grades.php?operation=createGrade`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/grades/grades.php?operation=updateGrade`, { ...data, grade_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/grades/grades.php?operation=deleteGrade`, { grade_id: id }).then(r => r.data)
};

const enrollmentsApi = {
    list: async () => {
        const enrollments = await axios.get(`${API_BASE_URL}/enrollments/enrollments.php`, { params: { operation: 'getAllEnrollments' } }).then(r => r.data);
        return enrollments.map(e => ({ ...e, display_name: `${e.learner_name} - ${e.year_label}` }));
    }
};

const classOfferingsApi = {
    list: async () => {
        const offerings = await axios.get(`${API_BASE_URL}/class_offerings/class_offerings.php`, { params: { operation: 'getAllClassOfferings' } }).then(r => r.data);
        return offerings.map(o => ({ ...o, display_name: `${o.subject_name} - ${o.section_name}` }));
    }
};

const gradingPeriodsApi = {
    list: async () => axios.get(`${API_BASE_URL}/grading_periods/grading_periods.php`, { params: { operation: 'getAllGradingPeriods' } }).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'grades',
        navKey: 'grades',
        entity: 'Grade',
        pageTitle: 'Grades',
        subtitle: '',
        breadcrumb: 'Grades',
        addLabel: 'Add Grade',
        primaryKey: 'grade_id',
        columns: [
            { key: 'learner_name', label: 'Learner' },
            { key: 'subject_name', label: 'Subject' },
            { key: 'period_name', label: 'Period' },
            { key: 'written_works', label: 'WW' },
            { key: 'performance_tasks', label: 'PT' },
            { key: 'quarterly_exam', label: 'QE' },
            { key: 'quarterly_grade', label: 'QG' }
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
                key: 'class_id',
                label: 'Class Offering',
                type: 'select',
                required: true,
                valueKey: 'class_id',
                labelKey: 'display_name',
                loadOptions: classOfferingsApi.list
            },
            {
                key: 'grading_period_id',
                label: 'Grading Period',
                type: 'select',
                required: true,
                valueKey: 'grading_period_id',
                labelKey: 'period_name',
                loadOptions: gradingPeriodsApi.list
            },
            { key: 'written_works', label: 'Written Works', type: 'number', step: '0.01', required: false },
            { key: 'performance_tasks', label: 'Performance Tasks', type: 'number', step: '0.01', required: false },
            { key: 'quarterly_exam', label: 'Quarterly Exam', type: 'number', step: '0.01', required: false }
        ],
        api: gradesApi
    });
});
