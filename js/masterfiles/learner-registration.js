const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const gradeLevelsApi = {
    list: async () => axios.get(`${API_BASE_URL}/grade_levels/grade_levels.php`, { params: { operation: 'getAllGradeLevels' } }).then(r => r.data)
};

const schoolYearsApi = {
    list: async () => axios.get(`${API_BASE_URL}/school_years/school_years.php`, { params: { operation: 'getAllSchoolYears' } }).then(r => r.data)
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

const learnerRegistrationApi = {
    list: async () => axios.get(`${API_BASE_URL}/learner_registration/learner_registration.php`, { params: { operation: 'getAllRegistrations' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/learner_registration/learner_registration.php?operation=createRegistration`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/learner_registration/learner_registration.php?operation=updateRegistration`, { ...data, learner_id: id }).then(r => r.data),
    markCompleted: async (id) => axios.post(`${API_BASE_URL}/learner_registration/learner_registration.php?operation=markEntryCompleted`, { learner_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/learner_registration/learner_registration.php?operation=deleteRegistration`, { learner_id: id }).then(r => r.data)
};

let REG_SECTION_OPTIONS = [];

function setSelectOptions(selectEl, label, options, valueKey, labelKey) {
    if (!selectEl) return;
    const safe = (v) => String(v ?? '').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    selectEl.innerHTML = `<option value="">Select ${safe(label)}</option>`
        + (options || []).map(opt => `<option value="${safe(opt[valueKey])}">${safe(opt[labelKey])}</option>`).join('');
}

async function reloadRegistrationSections() {
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
            sections = await sectionsApi.list();
        }
    } catch (e) {
        console.error('Failed to reload registration sections', e);
        sections = [];
    }

    REG_SECTION_OPTIONS = Array.isArray(sections) ? sections : [];
    const current = String(selSec.value || '');
    setSelectOptions(selSec, 'Section', REG_SECTION_OPTIONS, 'section_id', 'section_name');

    if (current && REG_SECTION_OPTIONS.some(s => String(s.section_id) === current)) {
        selSec.value = current;
    }
}

function wireRegistrationDependentSelects() {
    const selSY = document.getElementById('field-school_year_id');
    const selGL = document.getElementById('field-grade_level_id');
    const selSec = document.getElementById('field-section_id');
    if (!selSY || !selGL || !selSec) return;

    selSY.addEventListener('change', () => reloadRegistrationSections());
    selGL.addEventListener('change', () => reloadRegistrationSections());

    selSec.addEventListener('change', () => {
        const chosen = REG_SECTION_OPTIONS.find(s => String(s.section_id) === String(selSec.value || ''));
        if (!chosen) return;
        if (chosen.school_year_id && String(selSY.value || '') !== String(chosen.school_year_id)) {
            selSY.value = String(chosen.school_year_id);
        }
        if (chosen.grade_level_id && String(selGL.value || '') !== String(chosen.grade_level_id)) {
            selGL.value = String(chosen.grade_level_id);
        }
    });

    setTimeout(() => reloadRegistrationSections(), 0);
}

document.addEventListener('DOMContentLoaded', () => {
    initializeMasterfile({
        key: 'learner_registration',
        navKey: 'learner_registration',
        entity: 'Learner Registration',
        pageTitle: 'Learner Registration',
        subtitle: 'Manage learner registrations and entry completion',
        breadcrumb: 'Learner Registration',
        addLabel: 'Add Student',
        primaryKey: 'learner_id',
        columns: [
            { key: 'lrn', label: 'LRN' },
            { key: 'last_name', label: 'Last Name' },
            { key: 'first_name', label: 'First Name' },
            { key: 'middle_name', label: 'Middle Name' },
            { key: 'gender', label: 'Gender' },
            { key: 'date_of_birth', label: 'DOB' },
            { key: 'contact_number', label: 'Contact' },
            { key: 'status_name', label: 'Status' },
            { key: 'grade_name', label: 'Grade' },
            { key: 'section_name', label: 'Section' },
            { key: 'completed', label: 'Completed' },
            { key: 'entry_completion_status', label: 'Entry Status' }
        ],
        fieldSections: [
            {
                title: 'Enrollment Details',
                fields: [
                    {
                        key: 'school_year_id',
                        label: '* School Year',
                        type: 'select',
                        required: true,
                        valueKey: 'school_year_id',
                        labelKey: 'year_label',
                        loadOptions: schoolYearsApi.list
                    },
                    {
                        key: 'grade_level_id',
                        label: '* Grade Level',
                        type: 'select',
                        required: true,
                        valueKey: 'grade_level_id',
                        labelKey: 'grade_name',
                        loadOptions: gradeLevelsApi.list
                    },
                    {
                        key: 'section_id',
                        label: '* Section',
                        type: 'select',
                        required: true,
                        valueKey: 'section_id',
                        labelKey: 'section_name',
                        loadOptions: sectionsApi.list
                    }
                ]
            },
            {
                title: 'Personal Details',
                fields: [
                    { key: 'lrn', label: '* LRN (Learner Reference Number)', type: 'text', required: true, maxLength: 20 },
                    { key: 'last_name', label: '* Last Name', type: 'text', required: true },
                    { key: 'first_name', label: '* First Name', type: 'text', required: true },
                    { key: 'middle_name', label: 'Middle Name', type: 'text', omitIfEmpty: true },
                    {
                        key: 'name_extension_id',
                        label: 'Extension Name',
                        type: 'select',
                        required: false,
                        valueKey: 'extension_id',
                        labelKey: 'extension_name',
                        loadOptions: async () => {
                            try {
                                const res = await axios.get(`${API_BASE_URL}/name_extensions/name_extensions.php?operation=getAllNameExtensions`);
                                return res.data;
                            } catch {
                                return [];
                            }
                        }
                    },
                    {
                        key: 'gender',
                        label: '* Gender',
                        type: 'select',
                        required: true,
                        valueKey: 'value',
                        labelKey: 'label',
                        loadOptions: async () => ([
                            { value: 'Male', label: 'Male' },
                            { value: 'Female', label: 'Female' }
                        ])
                    },
                    { key: 'date_of_birth', label: '* Date of Birth', type: 'date', required: true },
                    { key: 'address', label: 'Place of Birth', type: 'text', required: false },
                    {
                        key: 'civil_status_id',
                        label: '* Civil Status',
                        type: 'select',
                        required: false,
                        valueKey: 'civil_status_id',
                        labelKey: 'status_name',
                        loadOptions: async () => {
                            try {
                                const res = await axios.get(`${API_BASE_URL}/civil_statuses/civil_statuses.php?operation=getAllStatuses`);
                                return res.data;
                            } catch {
                                return [];
                            }
                        }
                    },
                    {
                        key: 'religion_id',
                        label: '* Religion',
                        type: 'select',
                        required: false,
                        valueKey: 'religion_id',
                        labelKey: 'religion_name',
                        loadOptions: async () => {
                            try {
                                const res = await axios.get(`${API_BASE_URL}/religions/religions.php?operation=getAllReligions`);
                                return res.data;
                            } catch {
                                return [];
                            }
                        }
                    },
                    { key: 'contact_number', label: "* Student's Mobile No.", type: 'tel', required: false },
                    { key: 'email', label: '* Email', type: 'email', required: false },
                    {
                        key: 'mother_tongue_id',
                        label: 'Mother Tongue',
                        type: 'select',
                        required: false,
                        valueKey: 'mother_tongue_id',
                        labelKey: 'tongue_name',
                        loadOptions: async () => {
                            try {
                                const res = await axios.get(`${API_BASE_URL}/mother_tongues/mother_tongues.php?operation=getAllMotherTongues`);
                                return res.data;
                            } catch {
                                return [];
                            }
                        }
                    },
                    {
                        key: 'indigenous_group_id',
                        label: 'Indigenous Group',
                        type: 'select',
                        required: false,
                        valueKey: 'indigenous_group_id',
                        labelKey: 'group_name',
                        loadOptions: async () => {
                            try {
                                const res = await axios.get(`${API_BASE_URL}/indigenous_groups/indigenous_groups.php?operation=getAllIndigenousGroups`);
                                return res.data;
                            } catch {
                                return [];
                            }
                        }
                    },
                    {
                        key: 'is_indigenous',
                        label: 'Is Indigenous',
                        type: 'checkbox',
                        required: false
                    },
                    {
                        key: 'is_4ps_beneficiary',
                        label: '4Ps Beneficiary',
                        type: 'checkbox',
                        required: false
                    },
                    {
                        key: 'preferred_modality',
                        label: 'Preferred Learning Modality',
                        type: 'select',
                        required: false,
                        valueKey: 'modality_id',
                        labelKey: 'modality_name',
                        loadOptions: async () => {
                            try {
                                const res = await axios.get(`${API_BASE_URL}/learning_modalities/learning_modalities.php?operation=getAllLearningModalities`);
                                return res.data;
                            } catch {
                                return [];
                            }
                        }
                    },
                    {
                        key: 'learner_status_id',
                        label: 'Learner Status',
                        type: 'select',
                        required: false,
                        valueKey: 'learner_status_id',
                        labelKey: 'status_name',
                        loadOptions: async () => {
                            try {
                                const res = await axios.get(`${API_BASE_URL}/learner_statuses/learner_statuses.php?operation=getAllStatuses`);
                                return res.data;
                            } catch {
                                return [];
                            }
                        }
                    },
                    {
                        key: 'completed',
                        label: 'Completed',
                        type: 'select',
                        required: false,
                        valueKey: 'value',
                        labelKey: 'label',
                        loadOptions: async () => ([
                            { value: 0, label: 'No' },
                            { value: 1, label: 'Yes' }
                        ])
                    }
                ]
            },
            {
                title: 'Family Details',
                fields: [
                    { key: 'father_name', label: "* Father's Full Name", type: 'text', required: false },
                    { key: 'father_occupation', label: "* Father's Occupation", type: 'text', required: false },
                    { key: 'father_contact', label: "* Father's Mobile No.", type: 'tel', required: false },
                    { key: 'mother_name', label: "* Mother's Full Name", type: 'text', required: false },
                    { key: 'mother_occupation', label: "* Mother's Occupation", type: 'text', required: false },
                    { key: 'mother_contact', label: "* Mother's Mobile No.", type: 'tel', required: false },
                    { key: 'spouse_name', label: 'Name of Spouse', type: 'text', required: false },
                    { key: 'spouse_occupation', label: 'Spouse Occupation', type: 'text', required: false },
                    { key: 'number_of_children', label: 'Number of Children', type: 'number', required: false },
                    { key: 'number_of_brothers', label: '* Number of Brothers', type: 'number', required: false },
                    { key: 'number_of_sisters', label: '* Number of Sisters', type: 'number', required: false },
                    { key: 'guardian_name', label: 'Name of Guardian', type: 'text', required: false },
                    { key: 'guardian_relationship', label: 'Relationship with Guardian', type: 'text', required: false },
                    { key: 'guardian_contact', label: "Guardian's Mobile No.", type: 'tel', required: false }
                ]
            },
            {
                title: 'Emergency Person Contact Details',
                fields: [
                    { key: 'emergency_person_name', label: '* Person Name', type: 'text', required: false },
                    { key: 'emergency_relationship', label: '* Relationship', type: 'text', required: false },
                    { key: 'emergency_mobile', label: '* Emergency Mobile No.', type: 'tel', required: false },
                    { key: 'emergency_address', label: '* Address', type: 'textarea', required: false }
                ]
            },
            {
                title: 'Previous School Information',
                fields: [
                    { key: 'last_grade_level_completed', label: 'Last Grade Level Completed', type: 'text', required: false },
                    { key: 'last_school_year_completed', label: 'Last School Year Completed', type: 'text', required: false, placeholder: 'e.g., 2023-2024' },
                    { key: 'last_school_attended', label: 'Last School Attended', type: 'text', required: false },
                    { key: 'last_school_id', label: 'DepEd School ID', type: 'text', required: false, placeholder: '6-digit School ID' }
                ]
            }
        ],
        api: learnerRegistrationApi
    });

    wireRegistrationDependentSelects();
});
