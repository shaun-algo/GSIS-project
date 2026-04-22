const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

if (window.axios) {
    try {
        window.axios.defaults.withCredentials = true;
    } catch (_) {
        // ignore
    }
}

const registrationApi = {
    create: async (data) => axios
        .post(`${API_BASE_URL}/learner_registration/learner_registration.php?operation=createRegistration`, data)
        .then((r) => r.data)
};

const optionLoaders = {
    enrollment_type_id: () => axios.get(`${API_BASE_URL}/enrollment_types/enrollment_types.php`, { params: { operation: 'getAllEnrollmentTypes' } }).then((r) => r.data),
    grade_level_id: () => axios.get(`${API_BASE_URL}/grade_levels/grade_levels.php`, { params: { operation: 'getAllGradeLevels' } }).then((r) => r.data),
    school_year_id: () => axios.get(`${API_BASE_URL}/school_years/school_years.php`, { params: { operation: 'getAllSchoolYears' } }).then((r) => r.data),
    curriculum_id: () => axios.get(`${API_BASE_URL}/curricula/curricula.php`, { params: { operation: 'getAllCurricula', _: Date.now() } }).then((r) => r.data),
    name_extension_id: () => axios.get(`${API_BASE_URL}/name_extensions/name_extensions.php`, { params: { operation: 'getAllNameExtensions' } }).then((r) => r.data),
    civil_status_id: () => axios.get(`${API_BASE_URL}/civil_statuses/civil_statuses.php`, { params: { operation: 'getAllStatuses' } }).then((r) => r.data),
    religion_id: () => axios.get(`${API_BASE_URL}/religions/religions.php`, { params: { operation: 'getAllReligions' } }).then((r) => r.data),
    mother_tongue_id: () => axios.get(`${API_BASE_URL}/mother_tongues/mother_tongues.php`, { params: { operation: 'getAllMotherTongues' } }).then((r) => r.data),
    indigenous_group_id: () => axios.get(`${API_BASE_URL}/indigenous_groups/indigenous_groups.php`, { params: { operation: 'getAllIndigenousGroups' } }).then((r) => r.data),
    learner_status_id: () => axios.get(`${API_BASE_URL}/learner_statuses/learner_statuses.php`, { params: { operation: 'getAllStatuses' } }).then((r) => r.data),
    current_province_id: () => axios.get(`${API_BASE_URL}/geo/provinces.php`, { params: { operation: 'getAllProvinces' } }).then((r) => r.data),
    permanent_province_id: () => axios.get(`${API_BASE_URL}/geo/provinces.php`, { params: { operation: 'getAllProvinces' } }).then((r) => r.data)
};

const geoApi = {
    getCitiesMunicipalitiesByProvince: async (provinceId) => axios
        .get(`${API_BASE_URL}/geo/cities_municipalities.php`, { params: { operation: 'getCitiesMunicipalitiesByProvince', province_id: provinceId } })
        .then((r) => r.data),
    getBarangaysByCityMunicipality: async (cityMunicipalityId) => axios
        .get(`${API_BASE_URL}/geo/barangays.php`, { params: { operation: 'getBarangaysByCityMunicipality', city_municipality_id: cityMunicipalityId } })
        .then((r) => r.data)
};

const sectionsApi = {
    getByGradeLevel: async (gradeLevelId, schoolYearId) => axios
        .get(`${API_BASE_URL}/sections/sections.php`, {
            params: {
                operation: 'getSectionsByGradeLevel',
                grade_level_id: gradeLevelId,
                school_year_id: schoolYearId || undefined,
                only_with_slots: 1
            }
        })
        .then((r) => r.data)
};

const curriculaApi = {
    getForSchoolYear: async (schoolYearId, gradeLevelId) => axios
        .get(`${API_BASE_URL}/curricula/curricula.php`, {
            params: {
                operation: 'getCurriculaForSchoolYear',
                school_year_id: schoolYearId,
                grade_level_id: gradeLevelId || undefined,
                _: Date.now()
            }
        })
        .then((r) => r.data),
    getPrimaryForSchoolYear: async (schoolYearId) => axios
        .get(`${API_BASE_URL}/curricula/curricula.php`, {
            params: {
                operation: 'getPrimaryCurriculumForSchoolYear',
                school_year_id: schoolYearId,
                _: Date.now()
            }
        })
        .then((r) => r.data)
};

const optionConfig = {
    enrollment_type_id: { valueKey: 'enrollment_type_id', labelKey: 'type_name' },
    grade_level_id: { valueKey: 'grade_level_id', labelKey: 'grade_name' },
    section_id: { valueKey: 'section_id', labelKey: 'section_name' },
    school_year_id: { valueKey: 'school_year_id', labelKey: 'year_label', defaultPick: (row) => Number(row.is_active) === 1 },
    curriculum_id: { valueKey: 'curriculum_id', labelKey: 'curriculum_name' },
    name_extension_id: { valueKey: 'extension_name', labelKey: 'extension_name' },
    civil_status_id: { valueKey: 'status_name', labelKey: 'status_name' },
    religion_id: { valueKey: 'religion_name', labelKey: 'religion_name' },
    mother_tongue_id: { valueKey: 'tongue_name', labelKey: 'tongue_name' },
    indigenous_group_id: { valueKey: 'group_name', labelKey: 'group_name' },
    learner_status_id: { valueKey: 'status_name', labelKey: 'status_name' },
    current_province_id: { valueKey: 'province_id', labelKey: 'province_name' },
    permanent_province_id: { valueKey: 'province_id', labelKey: 'province_name' }
};

const fieldSections = [
    {
        title: 'Registration Overview',
        fields: [
            { key: 'lrn', label: 'LRN (Learner Reference Number)', type: 'text', required: true, maxLength: 20 },
            { key: 'grade_level_id', label: 'Grade Level', type: 'select', required: true },
            { key: 'section_id', label: 'Section', type: 'select', required: true },
            { key: 'school_year_id', label: 'School Year', type: 'select', required: true }
        ]
    },
    {
        title: 'Enrollment Details',
        fields: [
            { key: 'enrollment_type_id', label: 'Enrollment Type', type: 'select', required: false },
            { key: 'curriculum_id', label: 'Curriculum', type: 'select', required: false }
            // Enrollment Date is auto-set on save (server-side)
        ]
    },
    {
        title: 'Personal Details',
        fields: [
            { key: 'last_name', label: 'Last Name', type: 'text', required: true },
            { key: 'first_name', label: 'First Name', type: 'text', required: true },
            { key: 'middle_name', label: 'Middle Name', type: 'text', required: false },
            { key: 'name_extension_id', label: 'Extension Name', type: 'select', required: false },
            {
                key: 'gender',
                label: 'Gender',
                type: 'select',
                required: false,
                staticOptions: [
                    { value: 'Male', label: 'Male' },
                    { value: 'Female', label: 'Female' }
                ]
            },
            { key: 'date_of_birth', label: 'Date of Birth', type: 'date', required: false },
            { key: 'address', label: 'Address / Place of Birth', type: 'text', required: false },
            { key: 'civil_status_id', label: 'Civil Status', type: 'select', required: false },
            { key: 'religion_id', label: 'Religion', type: 'select', required: false },
            { key: 'contact_number', label: "Student's Mobile No.", type: 'tel', required: false },
            { key: 'email', label: 'Email', type: 'email', required: false },
            { key: 'mother_tongue_id', label: 'Mother Tongue', type: 'select', required: false },
            { key: 'learner_status_id', label: 'Learner Status', type: 'select', required: false },
            { key: 'is_indigenous', label: 'Is Indigenous', type: 'checkbox', required: false },
            { key: 'is_4ps_beneficiary', label: '4Ps Beneficiary', type: 'checkbox', required: false },
            { key: 'completed', label: 'Completed', type: 'checkbox', required: false },
            { key: 'indigenous_group_id', label: 'Indigenous Group', type: 'select', required: false },
            {
                key: 'citizenship',
                label: 'Citizenship',
                type: 'select',
                required: false,
                staticOptions: [
                    { value: 'Filipino', label: 'Filipino' },
                    { value: 'Dual Citizen', label: 'Dual Citizen' },
                    { value: 'Foreign National', label: 'Foreign National' }
                ]
            }
        ]
    },
    {
        title: 'Current Address',
        fields: [
            { key: 'current_house_no', label: 'House No.', type: 'text', required: false },
            { key: 'current_street', label: 'Street', type: 'text', required: false },
            { key: 'current_street_name', label: 'Street Name', type: 'text', required: false },
            { key: 'current_subdivision', label: 'Subdivision / Village', type: 'text', required: false },
            { key: 'current_province_id', label: 'Province', type: 'select', required: false },
            { key: 'current_city_municipality_id', label: 'City / Municipality', type: 'select', required: false },
            { key: 'current_barangay_id', label: 'Barangay', type: 'select', required: false },
            { key: 'current_zip_code', label: 'Zip Code', type: 'text', required: false }
        ]
    },
    {
        title: 'Permanent Address',
        fields: [
            { key: 'is_permanent_same_as_current', label: 'Permanent address is the same as current', type: 'checkbox', required: false },
            { key: 'permanent_house_no', label: 'House No.', type: 'text', required: false },
            { key: 'permanent_street', label: 'Street', type: 'text', required: false },
            { key: 'permanent_street_name', label: 'Street Name', type: 'text', required: false },
            { key: 'permanent_subdivision', label: 'Subdivision / Village', type: 'text', required: false },
            { key: 'permanent_province_id', label: 'Province', type: 'select', required: false },
            { key: 'permanent_city_municipality_id', label: 'City / Municipality', type: 'select', required: false },
            { key: 'permanent_barangay_id', label: 'Barangay', type: 'select', required: false },
            { key: 'permanent_zip_code', label: 'Zip Code', type: 'text', required: false }
        ]
    },
    {
        title: 'Family Details',
        fields: [
            { key: 'father_name', label: "Father's Full Name", type: 'text', required: false },
            { key: 'mother_name', label: "Mother's Full Name", type: 'text', required: false },
            { key: 'father_occupation', label: "Father's Occupation", type: 'text', required: false },
            { key: 'mother_occupation', label: "Mother's Occupation", type: 'text', required: false },
            { key: 'father_contact', label: "Father's Mobile No.", type: 'tel', required: false },
            { key: 'mother_contact', label: "Mother's Mobile No.", type: 'tel', required: false },
            { key: 'spouse_name', label: 'Name of Spouse', type: 'text', required: false },
            { key: 'guardian_name', label: 'Name of Guardian', type: 'text', required: false },
            { key: 'spouse_occupation', label: 'Spouse Occupation', type: 'text', required: false },
            { key: 'guardian_contact', label: "Guardian's Mobile No.", type: 'tel', required: false }
        ]
    },
    {
        title: 'Emergency Contact Details',
        fields: [
            { key: 'emergency_person_name', label: 'Person Name', type: 'text', required: false },
            { key: 'emergency_mobile', label: 'Mobile Number', type: 'tel', required: false },
            { key: 'emergency_address', label: 'Address', type: 'text', required: false }
        ]
    },
    {
        title: 'Previous School Information',
        fields: [
            { key: 'last_grade_level_completed', label: 'Last Grade Level Completed', type: 'text', required: false },
            { key: 'last_school_year_completed', label: 'Last School Year Completed', type: 'text', required: false },
            { key: 'last_school_attended', label: 'Last School Attended', type: 'text', required: false },
            { key: 'last_school_id', label: 'Last School ID', type: 'text', required: false }
        ]
    }
];

function notify(type, message, title) {
    if (typeof window.showNotification === 'function') {
        window.showNotification(type, message, title);
        return;
    }
    // eslint-disable-next-line no-console
    console[type === 'error' ? 'error' : 'log'](message);
}

function coerceValue(fieldKey, value) {
    if (value === '') return null;
    if (fieldKey.endsWith('_id')) {
        const trimmed = String(value).trim();
        if (/^\d+$/.test(trimmed)) return Number(trimmed);
        return value;
    }
    return value;
}

function getFormPayload(formElement) {
    const payload = {};

    for (const section of fieldSections) {
        for (const field of section.fields) {
            const input = formElement.querySelector(`#${CSS.escape(field.key)}`);
            if (!input) continue;

            if (field.type === 'checkbox') {
                payload[field.key] = input.checked ? 1 : 0;
                continue;
            }

            payload[field.key] = coerceValue(field.key, input.value);
        }
    }

    return payload;
}

function createLabel(field) {
    const label = document.createElement('label');
    label.setAttribute('for', field.key);
    label.textContent = field.label;

    if (field.required) {
        const required = document.createElement('span');
        required.className = 'required';
        required.textContent = '*';
        label.appendChild(required);
    }

    return label;
}

function renderField(field, selectOptionsByKey) {
    const fieldClass = `field-${String(field.key).replace(/[^a-z0-9]+/gi, '-').toLowerCase()}`;
    if (field.type === 'checkbox') {
        const wrapper = document.createElement('div');
        wrapper.className = `form-check ${fieldClass}`;

        const input = document.createElement('input');
        input.type = 'checkbox';
        input.id = field.key;
        input.name = field.key;

        const label = document.createElement('label');
        label.setAttribute('for', field.key);
        label.textContent = field.label;

        wrapper.appendChild(input);
        wrapper.appendChild(label);
        return wrapper;
    }

    const group = document.createElement('div');
    group.className = `form-group ${fieldClass}`;

    group.appendChild(createLabel(field));

    let control;
    if (field.type === 'select') {
        control = document.createElement('select');
        control.className = 'form-control';
        control.id = field.key;
        control.name = field.key;

        const defaultOption = document.createElement('option');
        defaultOption.value = '';
        defaultOption.textContent = 'Select...';
        control.appendChild(defaultOption);

        const options = field.staticOptions ?? selectOptionsByKey[field.key] ?? [];
        const cfg = optionConfig[field.key];

        for (const row of options) {
            const opt = document.createElement('option');
            if (field.staticOptions) {
                opt.value = row.value;
                opt.textContent = row.label;
            } else {
                opt.value = row?.[cfg.valueKey] ?? '';
                opt.textContent = row?.[cfg.labelKey] ?? '';
            }
            control.appendChild(opt);
        }

        // Default selection (e.g., active school year)
        if (!field.staticOptions && cfg?.defaultPick) {
            const match = options.find(cfg.defaultPick);
            if (match) {
                control.value = String(match[cfg.valueKey]);
            }
        }
    } else {
        control = document.createElement('input');
        control.className = 'form-control';
        control.type = field.type || 'text';
        control.id = field.key;
        control.name = field.key;
        if (field.maxLength) control.maxLength = field.maxLength;
    }

    if (field.required) control.required = true;

    group.appendChild(control);
    return group;
}

function renderForm(container, selectOptionsByKey) {
    container.innerHTML = '';

    const slugify = (s) => String(s || '')
        .trim()
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/(^-|-$)/g, '');

    for (const section of fieldSections) {
        const sectionEl = document.createElement('div');
        sectionEl.className = `form-section section-${slugify(section.title)}`;

        const title = document.createElement('h2');
        title.className = 'section-title';
        title.textContent = section.title;
        sectionEl.appendChild(title);

        const fieldsEl = document.createElement('div');
        fieldsEl.className = 'section-fields';

        const checkboxGroupKeys = ['is_indigenous', 'is_4ps_beneficiary', 'completed'];
        const inlineRowKeys = ['mother_tongue_id', 'learner_status_id', ...checkboxGroupKeys];
        const grouped = new Set();

        for (const field of section.fields) {
            // Personal Details: place Mother Tongue (left) + Learner Status (center) + 3 checkboxes (right) on the same row
            if (section.title === 'Personal Details' && field.key === 'mother_tongue_id' && grouped.size === 0) {
                const row = document.createElement('div');
                row.className = 'personal-status-row';

                const mt = section.fields.find((x) => x.key === 'mother_tongue_id');
                const ls = section.fields.find((x) => x.key === 'learner_status_id');

                if (mt) {
                    row.appendChild(renderField(mt, selectOptionsByKey));
                    grouped.add('mother_tongue_id');
                }

                if (ls) {
                    row.appendChild(renderField(ls, selectOptionsByKey));
                    grouped.add('learner_status_id');
                }

                const group = document.createElement('div');
                group.className = 'checkbox-group-outline';
                for (const k of checkboxGroupKeys) {
                    const f = section.fields.find((x) => x.key === k);
                    if (f) {
                        group.appendChild(renderField(f, selectOptionsByKey));
                        grouped.add(k);
                    }
                }
                row.appendChild(group);

                fieldsEl.appendChild(row);
                continue;
            }

            if (section.title === 'Personal Details' && inlineRowKeys.includes(field.key) && grouped.has(field.key)) {
                continue;
            }

            fieldsEl.appendChild(renderField(field, selectOptionsByKey));
        }

        sectionEl.appendChild(fieldsEl);
        container.appendChild(sectionEl);
    }
}

function resetSelect(selectEl, placeholderText = 'Select...') {
    if (!selectEl) return;
    selectEl.innerHTML = '';
    const defaultOption = document.createElement('option');
    defaultOption.value = '';
    defaultOption.textContent = placeholderText;
    selectEl.appendChild(defaultOption);
}

function setSelectRows(selectEl, rows, valueKey, labelKey, placeholderText = 'Select...') {
    resetSelect(selectEl, placeholderText);
    if (!selectEl) return;
    const list = Array.isArray(rows) ? rows : [];
    for (const row of list) {
        const opt = document.createElement('option');
        opt.value = row?.[valueKey] ?? '';
        opt.textContent = row?.[labelKey] ?? '';
        selectEl.appendChild(opt);
    }
}

function wireGeoCascade(formElement, prefix) {
    const provinceEl = formElement.querySelector(`#${CSS.escape(prefix + 'province_id')}`);
    const cityEl = formElement.querySelector(`#${CSS.escape(prefix + 'city_municipality_id')}`);
    const barangayEl = formElement.querySelector(`#${CSS.escape(prefix + 'barangay_id')}`);

    if (!provinceEl || !cityEl || !barangayEl) return;

    async function onProvinceChange() {
        const provinceId = Number(provinceEl.value || 0);
        resetSelect(cityEl, 'Select city / municipality...');
        resetSelect(barangayEl, 'Select barangay...');

        if (!provinceId) return;

        try {
            const rows = await geoApi.getCitiesMunicipalitiesByProvince(provinceId);
            setSelectRows(cityEl, rows, 'city_municipality_id', 'city_municipality_name', 'Select city / municipality...');
        } catch {
            // silent: keep empty
        }
    }

    async function onCityChange() {
        const cityMunicipalityId = Number(cityEl.value || 0);
        resetSelect(barangayEl, 'Select barangay...');

        if (!cityMunicipalityId) return;

        try {
            const rows = await geoApi.getBarangaysByCityMunicipality(cityMunicipalityId);
            setSelectRows(barangayEl, rows, 'barangay_id', 'barangay_name', 'Select barangay...');
        } catch {
            // silent: keep empty
        }
    }

    provinceEl.addEventListener('change', () => { void onProvinceChange(); });
    cityEl.addEventListener('change', () => { void onCityChange(); });

    // Initialize state
    resetSelect(cityEl, 'Select city / municipality...');
    resetSelect(barangayEl, 'Select barangay...');
}

function wirePermanentSameAsCurrent(formElement) {
    const sameEl = formElement.querySelector('#is_permanent_same_as_current');
    if (!sameEl) return;

    const permanentKeys = [
        'permanent_house_no',
        'permanent_street',
        'permanent_street_name',
        'permanent_subdivision',
        'permanent_province_id',
        'permanent_city_municipality_id',
        'permanent_barangay_id',
        'permanent_zip_code'
    ];

    function setEnabled(enabled) {
        for (const key of permanentKeys) {
            const el = formElement.querySelector(`#${CSS.escape(key)}`);
            if (!el) continue;
            el.disabled = !enabled;
            if (!enabled) {
                el.value = '';
            }
        }

        if (!enabled) {
            const permCity = formElement.querySelector('#permanent_city_municipality_id');
            const permBrgy = formElement.querySelector('#permanent_barangay_id');
            resetSelect(permCity, 'Select city / municipality...');
            resetSelect(permBrgy, 'Select barangay...');
        }
    }

    sameEl.addEventListener('change', () => {
        setEnabled(!sameEl.checked);
    });

    // Default: checked (matches DB default)
    sameEl.checked = true;
    setEnabled(false);
}

function wireIndigenousGroupToggle(formElement) {
    const indigenousEl = formElement.querySelector('#is_indigenous');
    const groupEl = formElement.querySelector('#indigenous_group_id');
    if (!indigenousEl || !groupEl) return;

    function syncChoicesDisabledState(selectEl) {
        const instance = selectEl?._choicesInstance;
        if (!instance) return;
        try {
            if (selectEl.disabled) instance.disable();
            else instance.enable();
        } catch {
            // ignore
        }
    }

    function syncChoicesCleared(selectEl) {
        const instance = selectEl?._choicesInstance;
        if (!instance) return;
        try {
            instance.removeActiveItems();
            instance.refresh();
        } catch {
            // ignore
        }
    }

    function applyState() {
        const enabled = indigenousEl.checked;
        groupEl.disabled = !enabled;
        syncChoicesDisabledState(groupEl);
        if (!enabled) {
            groupEl.value = '';
            syncChoicesCleared(groupEl);
        }
    }

    if (indigenousEl.dataset.wiredIndigenousToggle !== '1') {
        indigenousEl.dataset.wiredIndigenousToggle = '1';
        indigenousEl.addEventListener('change', applyState);
    }
    applyState();
}

function wireDefaultLearnerStatusEnrolled(formElement) {
    const statusEl = formElement.querySelector('#learner_status_id');
    if (!statusEl) return;

    const normalize = (s) => String(s || '').trim().toLowerCase();
    const options = Array.from(statusEl.options || []);
    const enrolled = options.find((o) => o.value && normalize(o.textContent) === 'enrolled')
        ?? options.find((o) => o.value && normalize(o.textContent).includes('enrolled'));

    if (enrolled) {
        statusEl.value = enrolled.value;
    } else if (!statusEl.value) {
        const firstReal = options.find((o) => o.value);
        if (firstReal) statusEl.value = firstReal.value;
    }

    statusEl.disabled = true;
}

function wireGradeSectionCascade(formElement) {
    const gradeEl = formElement.querySelector('#grade_level_id');
    const sectionEl = formElement.querySelector('#section_id');
    const schoolYearEl = formElement.querySelector('#school_year_id');
    if (!gradeEl || !sectionEl) return;

    async function onGradeChange() {
        const gradeLevelId = Number(gradeEl.value || 0);
        const schoolYearId = Number(schoolYearEl?.value || 0);
        resetSelect(sectionEl, 'Select section...');

        if (!gradeLevelId) return;

        try {
            const rows = await sectionsApi.getByGradeLevel(gradeLevelId, schoolYearId);
            setSelectRows(sectionEl, rows, 'section_id', 'section_name', 'Select section...');
        } catch {
            // keep empty
        }
    }

    gradeEl.addEventListener('change', () => { void onGradeChange(); });
    if (schoolYearEl) {
        schoolYearEl.addEventListener('change', () => { void onGradeChange(); });
    }

    // Initial state: no sections until a grade is chosen
    resetSelect(sectionEl, 'Select section...');
}

function wireCurriculumCascade(formElement) {
    const schoolYearEl = formElement.querySelector('#school_year_id');
    const gradeEl = formElement.querySelector('#grade_level_id');
    const curriculumEl = formElement.querySelector('#curriculum_id');
    if (!schoolYearEl || !curriculumEl) return;

    async function refreshCurricula() {
        const schoolYearId = Number(schoolYearEl.value || 0);
        const gradeLevelId = Number(gradeEl?.value || 0);

        if (!schoolYearId) {
            resetSelect(curriculumEl, 'Select school year first...');
            return;
        }

        try {
            const data = await curriculaApi.getForSchoolYear(schoolYearId, gradeLevelId || undefined);
            const rows = Array.isArray(data)
                ? data
                : (Array.isArray(data?.data) ? data.data : []);

            setSelectRows(
                curriculumEl,
                rows,
                'curriculum_id',
                'curriculum_name',
                rows.length ? 'Select curriculum...' : 'No curricula mapped for this school year'
            );

            const current = String(curriculumEl.value || '').trim();
            const exists = current !== '' && rows.some((r) => String(r.curriculum_id) === current);

            // Auto-pick: mapped primary curriculum, else API primary, else keep blank
            if (!exists) {
                const mappedPrimary = rows.find((r) => Number(r.is_primary) === 1);
                if (mappedPrimary) {
                    curriculumEl.value = String(mappedPrimary.curriculum_id);
                } else {
                    const primaryRes = await curriculaApi.getPrimaryForSchoolYear(schoolYearId);
                    const primary = primaryRes?.data || null;
                    if (primary?.curriculum_id) {
                        curriculumEl.value = String(primary.curriculum_id);
                    } else if (rows.length) {
                        curriculumEl.value = String(rows[0].curriculum_id);
                    } else {
                        curriculumEl.value = '';
                    }
                }
            }
        } catch {
            resetSelect(curriculumEl, 'Select curriculum...');
        }
    }

    schoolYearEl.addEventListener('change', () => { void refreshCurricula(); });
    gradeEl?.addEventListener('change', () => { void refreshCurricula(); });

    // Initial state (school year may be auto-selected)
    void refreshCurricula();
}

async function preloadSelectOptions() {
    const selectKeys = new Set();
    for (const section of fieldSections) {
        for (const field of section.fields) {
            if (field.type === 'select' && !field.staticOptions) {
                selectKeys.add(field.key);
            }
        }
    }

    const entries = Array.from(selectKeys).map(async (key) => {
        const loader = optionLoaders[key];
        if (!loader) return [key, []];

        try {
            const data = await loader();
            const rows = Array.isArray(data)
                ? data
                : (Array.isArray(data?.data) ? data.data : []);
            return [key, rows];
        } catch {
            return [key, []];
        }
    });

    const results = await Promise.all(entries);
    return Object.fromEntries(results);
}

document.addEventListener('DOMContentLoaded', async () => {
    const form = document.getElementById('registrationForm');
    const fieldsContainer = document.getElementById('registrationFormFields');
    const submitBtn = document.getElementById('submitRegistrationBtn');

    if (!form || !fieldsContainer) return;

    const selectOptionsByKey = await preloadSelectOptions();
    renderForm(fieldsContainer, selectOptionsByKey);
    wireGeoCascade(form, 'current_');
    wireGeoCascade(form, 'permanent_');
    wirePermanentSameAsCurrent(form);
    wireGradeSectionCascade(form);
    wireCurriculumCascade(form);
    wireIndigenousGroupToggle(form);
    wireDefaultLearnerStatusEnrolled(form);

    form.addEventListener('submit', async (e) => {
        e.preventDefault();

        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Submitting...';

        try {
            const payload = getFormPayload(form);
            const res = await registrationApi.create(payload);

            if (!res?.success) {
                notify('error', res?.message || 'Registration failed.', 'Registration');
                return;
            }

            notify('success', res?.message || 'Registration submitted.', 'Registration');
            form.reset();

            // Re-apply defaults (e.g., active school year)
            renderForm(fieldsContainer, selectOptionsByKey);
            wireGeoCascade(form, 'current_');
            wireGeoCascade(form, 'permanent_');
            wirePermanentSameAsCurrent(form);
            wireGradeSectionCascade(form);
            wireCurriculumCascade(form);
            wireIndigenousGroupToggle(form);
            wireDefaultLearnerStatusEnrolled(form);
        } catch (err) {
            notify('error', err?.response?.data?.message || err?.message || 'Server error.', 'Registration');
        } finally {
            submitBtn.disabled = false;
            submitBtn.innerHTML = '<i class="fas fa-paper-plane"></i> Submit Registration';
        }
    });
});
