const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const finalGradesApi = {
    list: async () => axios.get(`${API_BASE_URL}/final_grades/final_grades.php`, { params: { operation: 'getAllFinalGrades' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/final_grades/final_grades.php?operation=createFinalGrade`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/final_grades/final_grades.php?operation=updateFinalGrade`, { ...data, final_grade_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/final_grades/final_grades.php?operation=deleteFinalGrade`, { final_grade_id: id }).then(r => r.data)
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

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'final_grades',
        navKey: 'final_grades',
        entity: 'Final Grade',
        pageTitle: 'Final Grades',
        subtitle: '',
        breadcrumb: 'Final Grades',
        addLabel: 'Add Final Grade',
        primaryKey: 'final_grade_id',
        columns: [
            { key: 'learner_name', label: 'Learner' },
            { key: 'subject_name', label: 'Subject' },
            { key: 'final_grade', label: 'Final Grade' },
            { key: 'remark', label: 'Remark' }
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
                key: 'class_offering_id',
                label: 'Class Offering',
                type: 'select',
                required: true,
                valueKey: 'class_offering_id',
                labelKey: 'display_name',
                loadOptions: classOfferingsApi.list
            },
            { key: 'final_grade', label: 'Final Grade', type: 'number', step: '0.01', required: true },
            {
                key: 'grade_remark_id',
                label: 'Remark',
                type: 'select',
                required: false,
                valueKey: 'value',
                labelKey: 'label',
                loadOptions: async () => ([
                    { value: 1, label: 'Passed' },
                    { value: 2, label: 'Failed' }
                ])
            }
        ],
        api: finalGradesApi
    });
});
