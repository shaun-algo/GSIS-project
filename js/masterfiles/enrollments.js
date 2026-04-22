const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const enrollmentsApi = {
    list: async () => axios.get(`${API_BASE_URL}/enrollments/enrollments.php`, { params: { operation: 'getAllEnrollments' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/enrollments/enrollments.php?operation=createEnrollment`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/enrollments/enrollments.php?operation=updateEnrollment`, { ...data, enrollment_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/enrollments/enrollments.php?operation=deleteEnrollment`, { enrollment_id: id }).then(r => r.data)
};

const learnersApi = {
    list: async () => axios.get(`${API_BASE_URL}/learners/learners.php`, { params: { operation: 'getAllLearners' } }).then(r => r.data)
};

const enrollmentTypesApi = {
    list: async () => axios.get(`${API_BASE_URL}/enrollment_types/enrollment_types.php`, { params: { operation: 'getAllEnrollmentTypes' } }).then(r => r.data)
};

const gradeLevelsApi = {
    list: async () => axios.get(`${API_BASE_URL}/grade_levels/grade_levels.php`, { params: { operation: 'getAllGradeLevels' } }).then(r => r.data)
};

const sectionsApi = {
    list: async (params = {}) => axios.get(`${API_BASE_URL}/sections/sections.php`, { params: { operation: 'getAllSections', ...params } }).then(r => r.data),
    listByGradeLevel: async (gradeLevelId, schoolYearId) => axios.get(`${API_BASE_URL}/sections/sections.php`, {
        params: {
            operation: 'getSectionsByGradeLevel',
            grade_level_id: gradeLevelId,
            ...(schoolYearId ? { school_year_id: schoolYearId } : {})
        }
    }).then(r => r.data)
};

const schoolYearsApi = {
    list: async () => axios.get(`${API_BASE_URL}/school_years/school_years.php`, { params: { operation: 'getAllSchoolYears' } }).then(r => r.data)
};

let ENROLLMENT_SECTION_OPTIONS = [];

function setSelectOptions(selectEl, label, options, valueKey, labelKey) {
    if (!selectEl) return;
    const safe = (v) => String(v ?? '').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    selectEl.innerHTML = `<option value="">Select ${safe(label)}</option>`
        + (options || []).map(opt => `<option value="${safe(opt[valueKey])}">${safe(opt[labelKey])}</option>`).join('');
}

async function reloadEnrollmentSections() {
    const selSY = document.getElementById('field-school_year_id');
    const selGL = document.getElementById('field-grade_level_id');
    const selSec = document.getElementById('field-section_id');
    if (!selSec) return;

    const schoolYearId = Number(selSY?.value || 0);
    const gradeLevelId = Number(selGL?.value || 0);

    let sections = [];
    try {
        if (gradeLevelId > 0) {
            sections = await sectionsApi.listByGradeLevel(gradeLevelId, schoolYearId);
        } else if (schoolYearId > 0) {
            sections = await sectionsApi.list({ school_year_id: schoolYearId, include_all: 1 });
        } else {
            // Default behavior: API will return the active school year sections.
            sections = await sectionsApi.list();
        }
    } catch (e) {
        console.error('Failed to reload sections', e);
        sections = [];
    }

    ENROLLMENT_SECTION_OPTIONS = Array.isArray(sections) ? sections : [];

    const current = String(selSec.value || '');
    setSelectOptions(selSec, 'Section', ENROLLMENT_SECTION_OPTIONS, 'section_id', 'section_name');

    // Preserve current selection if still valid; otherwise clear.
    if (current && ENROLLMENT_SECTION_OPTIONS.some(s => String(s.section_id) === current)) {
        selSec.value = current;
    }
}

function wireEnrollmentDependentSelects() {
    const selSY = document.getElementById('field-school_year_id');
    const selGL = document.getElementById('field-grade_level_id');
    const selSec = document.getElementById('field-section_id');
    if (!selSY || !selGL || !selSec) return;

    // Keep Section options consistent with selected SY + Grade.
    selSY.addEventListener('change', () => {
        reloadEnrollmentSections();
    });
    selGL.addEventListener('change', () => {
        reloadEnrollmentSections();
    });

    // If user picks a section, auto-align SY + Grade to avoid trigger failures.
    selSec.addEventListener('change', () => {
        const chosen = ENROLLMENT_SECTION_OPTIONS.find(s => String(s.section_id) === String(selSec.value || ''));
        if (!chosen) return;
        if (chosen.school_year_id && String(selSY.value || '') !== String(chosen.school_year_id)) {
            selSY.value = String(chosen.school_year_id);
        }
        if (chosen.grade_level_id && String(selGL.value || '') !== String(chosen.grade_level_id)) {
            selGL.value = String(chosen.grade_level_id);
        }
    });

    // Initial load (after reference data is populated by masterfile-common)
    setTimeout(() => reloadEnrollmentSections(), 0);
}

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'enrollments',
        navKey: 'enrollments',
        entity: 'Enrollment',
        pageTitle: 'Enrollments',
        subtitle: '',
        breadcrumb: 'Enrollments',
        addLabel: 'Add Enrollment',
        primaryKey: 'enrollment_id',
        columns: [
            { key: 'learner_name', label: 'Learner' },
            { key: 'type_name', label: 'Type' },
            { key: 'grade_name', label: 'Grade' },
            { key: 'section_name', label: 'Section' },
            { key: 'year_label', label: 'School Year' },
            { key: 'enrollment_date', label: 'Enrollment Date' }
        ],
        fields: [
            {
                key: 'learner_id',
                label: 'Learner',
                type: 'select',
                required: true,
                valueKey: 'learner_id',
                labelKey: 'full_name',
                loadOptions: async () => {
                    const learners = await learnersApi.list();
                    return learners.map(l => ({ ...l, full_name: `${l.last_name}, ${l.first_name}` }));
                }
            },
            {
                key: 'enrollment_type_id',
                label: 'Enrollment Type',
                type: 'select',
                required: true,
                valueKey: 'enrollment_type_id',
                labelKey: 'type_name',
                loadOptions: enrollmentTypesApi.list
            },
            {
                key: 'grade_level_id',
                label: 'Grade Level',
                type: 'select',
                required: true,
                valueKey: 'grade_level_id',
                labelKey: 'grade_name',
                loadOptions: gradeLevelsApi.list
            },
            {
                key: 'section_id',
                label: 'Section',
                type: 'select',
                required: true,
                valueKey: 'section_id',
                labelKey: 'section_name',
                loadOptions: sectionsApi.list
            },
            {
                key: 'school_year_id',
                label: 'School Year',
                type: 'select',
                required: true,
                valueKey: 'school_year_id',
                labelKey: 'year_label',
                loadOptions: schoolYearsApi.list
            },
            { key: 'enrollment_date', label: 'Enrollment Date', type: 'date', required: true }
        ],
        api: enrollmentsApi
    });

    wireEnrollmentDependentSelects();
});
