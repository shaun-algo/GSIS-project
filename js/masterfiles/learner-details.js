function getApiBaseUrl() {
    const parts = String(window.location.pathname || '/').split('/').filter(Boolean);
    const appPrefix = parts.length ? `/${parts[0]}` : '';
    return `${window.location.origin}${appPrefix}/api`;
}

const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const learnerRegistrationApi = {
    list: async () => axios
        .get(`${API_BASE_URL}/learner_registration/learner_registration.php`, { params: { operation: 'getAllRegistrations' } })
        .then((r) => r.data),
    update: async (learnerId, data) => axios
        .post(`${API_BASE_URL}/learner_registration/learner_registration.php?operation=updateRegistration`, { ...data, learner_id: learnerId })
        .then((r) => r.data)
};

const optionLoaders = {
    enrollment_type_id: () => axios.get(`${API_BASE_URL}/enrollment_types/enrollment_types.php`, { params: { operation: 'getAllEnrollmentTypes' } }).then((r) => r.data),
    grade_level_id: () => axios.get(`${API_BASE_URL}/grade_levels/grade_levels.php`, { params: { operation: 'getAllGradeLevels' } }).then((r) => r.data),
    school_year_id: () => axios.get(`${API_BASE_URL}/school_years/school_years.php`, { params: { operation: 'getAllSchoolYears' } }).then((r) => r.data),
    curriculum_id: () => axios.get(`${API_BASE_URL}/curricula/curricula.php`, { params: { operation: 'getAllCurricula' } }).then((r) => r.data),
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
                school_year_id: schoolYearId || undefined
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
            { key: 'curriculum_id', label: 'Curriculum', type: 'select', required: false },
            { key: 'enrollment_date', label: 'Enrollment Date', type: 'date', required: false }
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
            { key: 'contact_number', label: "Learner's Mobile No.", type: 'tel', required: false },
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
        const msg = title ? `${title}: ${message}` : message;
        window.showNotification(msg, type);
        return;
    }
    // eslint-disable-next-line no-console
    console[type === 'error' ? 'error' : 'log'](message);
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

    const error = document.createElement('div');
    error.className = 'error-message';
    error.setAttribute('aria-live', 'polite');
    group.appendChild(error);

    return group;
}

function clearControlError(control) {
    if (!control) return;
    control.classList.remove('error');
    const group = control.closest('.form-group');
    const msg = group?.querySelector('.error-message');
    if (msg) msg.textContent = '';
}

function setControlError(control, message) {
    if (!control) return;
    control.classList.add('error');
    const group = control.closest('.form-group');
    const msg = group?.querySelector('.error-message');
    if (msg) msg.textContent = message || 'This field is required.';
}

function validateRequiredFields(form) {
    const requiredFields = fieldSections.flatMap((s) => s.fields).filter((f) => f.required);
    const invalidControls = [];

    for (const field of requiredFields) {
        const el = form.querySelector(`#${CSS.escape(String(field.key))}`);
        if (!el) continue;

        // Skip if disabled (e.g., permanent address fields when same-as-current)
        if (el.disabled) {
            clearControlError(el);
            continue;
        }

        const raw = el.type === 'checkbox' ? (el.checked ? '1' : '') : String(el.value || '').trim();
        if (!raw) {
            setControlError(el, 'This field is required.');
            invalidControls.push(el);
        } else {
            clearControlError(el);
        }
    }

    return invalidControls;
}

function highlightFieldsFromServerMessage(form, message) {
    const msg = String(message || '').toLowerCase();
    const candidates = [];

    const map = [
        { re: /\bgrade\b/, id: 'grade_level_id' },
        { re: /\bsection\b/, id: 'section_id' },
        { re: /\bschool\s*year\b|\byear\b/, id: 'school_year_id' },
        { re: /\blrn\b/, id: 'lrn' },
        { re: /\blast\s*name\b|\bsurname\b/, id: 'last_name' },
        { re: /\bfirst\s*name\b/, id: 'first_name' }
    ];

    for (const m of map) {
        if (!m.re.test(msg)) continue;
        const el = form.querySelector(`#${CSS.escape(m.id)}`);
        if (el && !el.disabled) candidates.push(el);
    }

    for (const el of candidates) {
        setControlError(el, 'Please check this field.');
    }

    return candidates;
}

function applyFieldErrors(form, fieldErrors) {
    if (!fieldErrors || typeof fieldErrors !== 'object') return [];
    const controls = [];

    for (const [key, msg] of Object.entries(fieldErrors)) {
        const id = String(key);
        const el = form.querySelector(`#${CSS.escape(id)}`);
        if (!el || el.disabled) continue;
        setControlError(el, String(msg || 'Invalid value'));
        controls.push(el);
    }

    return controls;
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

function syncChoicesDisabledState(selectEl) {
    const instance = selectEl?._choicesInstance;
    if (!instance) return;
    try {
        if (selectEl.disabled) {
            instance.disable();
        } else {
            instance.enable();
        }
    } catch {
        // ignore
    }
}

function syncChoicesValue(selectEl, value) {
    if (!selectEl) return;

    const instance = selectEl?._choicesInstance;
    const isMultiple = !!selectEl.multiple;

    const normalizedValues = isMultiple
        ? (Array.isArray(value) ? value : value ? [value] : []).map((v) => String(v))
        : [value === null || value === undefined ? '' : String(value)];

    // Always set the underlying element value for form submission.
    if (!isMultiple) {
        selectEl.value = normalizedValues[0];
    } else {
        // For multiple selects, keep DOM options in sync.
        const want = new Set(normalizedValues);
        Array.from(selectEl.options || []).forEach((opt) => {
            opt.selected = want.has(String(opt.value));
        });
    }

    if (!instance) {
        selectEl.dispatchEvent(new Event('change', { bubbles: true }));
        return;
    }

    try {
        // Ensure Choices has the latest options, then apply selection.
        instance.refresh();
        instance.removeActiveItems();
        if (normalizedValues.length && normalizedValues[0] !== '') {
            instance.setChoiceByValue(isMultiple ? normalizedValues : normalizedValues[0]);
        }
    } catch {
        // ignore
    }
}

function syncFlatpickrValue(inputEl, value) {
    if (!inputEl) return;
    const fp = inputEl?._flatpickr;
    if (!fp) return;
    try {
        if (value === null || value === undefined || String(value).trim() === '') {
            fp.clear();
            return;
        }
        fp.setDate(String(value), true);
    } catch {
        // ignore
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
        syncChoicesValue(cityEl, '');
        syncChoicesValue(barangayEl, '');

        if (!provinceId) return;

        try {
            const rows = await geoApi.getCitiesMunicipalitiesByProvince(provinceId);
            setSelectRows(cityEl, rows, 'city_municipality_id', 'city_municipality_name', 'Select city / municipality...');
            syncChoicesValue(cityEl, '');
        } catch {
            // silent
        }
    }

    async function onCityChange() {
        const cityMunicipalityId = Number(cityEl.value || 0);
        resetSelect(barangayEl, 'Select barangay...');
        syncChoicesValue(barangayEl, '');

        if (!cityMunicipalityId) return;

        try {
            const rows = await geoApi.getBarangaysByCityMunicipality(cityMunicipalityId);
            setSelectRows(barangayEl, rows, 'barangay_id', 'barangay_name', 'Select barangay...');
            syncChoicesValue(barangayEl, '');
        } catch {
            // silent
        }
    }

    provinceEl.addEventListener('change', () => { void onProvinceChange(); });
    cityEl.addEventListener('change', () => { void onCityChange(); });

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
            if (el.tagName === 'SELECT') syncChoicesDisabledState(el);
            if (!enabled) {
                el.value = '';
                if (el.tagName === 'SELECT') syncChoicesValue(el, '');
            }
        }

        if (!enabled) {
            const permCity = formElement.querySelector('#permanent_city_municipality_id');
            const permBrgy = formElement.querySelector('#permanent_barangay_id');
            resetSelect(permCity, 'Select city / municipality...');
            resetSelect(permBrgy, 'Select barangay...');
            if (permCity) syncChoicesValue(permCity, '');
            if (permBrgy) syncChoicesValue(permBrgy, '');
        }
    }

    sameEl.addEventListener('change', () => {
        setEnabled(!sameEl.checked);
    });

    // Will be set from record; default to checked.
    if (sameEl.checked) {
        setEnabled(false);
    }
}

function wireIndigenousGroupToggle(formElement) {
    const indigenousEl = formElement.querySelector('#is_indigenous');
    const groupEl = formElement.querySelector('#indigenous_group_id');
    if (!indigenousEl || !groupEl) return;

    function applyState() {
        const enabled = indigenousEl.checked;
        groupEl.disabled = !enabled;
        syncChoicesDisabledState(groupEl);
        if (!enabled) {
            groupEl.value = '';
        }
    }

    if (indigenousEl.dataset.wiredIndigenousToggle !== '1') {
        indigenousEl.dataset.wiredIndigenousToggle = '1';
        indigenousEl.addEventListener('change', applyState);
    }
    applyState();
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

async function populateSections(formElement, record) {
    const gradeEl = formElement.querySelector('#grade_level_id');
    const sectionEl = formElement.querySelector('#section_id');
    const schoolYearEl = formElement.querySelector('#school_year_id');
    if (!gradeEl || !sectionEl) return;

    const gradeLevelId = Number(record?.grade_level_id || 0);
    const schoolYearId = Number(record?.school_year_id || schoolYearEl?.value || 0);
    const sectionId = Number(record?.section_id || 0);

    resetSelect(sectionEl, 'Select section...');
    if (!gradeLevelId) return;

    try {
        const rows = await sectionsApi.getByGradeLevel(gradeLevelId, schoolYearId);
        setSelectRows(sectionEl, rows, 'section_id', 'section_name', 'Select section...');
        syncChoicesValue(sectionEl, sectionId ? String(sectionId) : '');
    } catch {
        // ignore
    }
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

function normalizeSortText(value) {
    return String(value || '').trim().toLowerCase();
}

function compareLearnersByName(a, b) {
    const aLast = normalizeSortText(a?.last_name);
    const bLast = normalizeSortText(b?.last_name);
    if (aLast !== bLast) return aLast.localeCompare(bLast);

    const aFirst = normalizeSortText(a?.first_name);
    const bFirst = normalizeSortText(b?.first_name);
    if (aFirst !== bFirst) return aFirst.localeCompare(bFirst);

    const aMiddle = normalizeSortText(a?.middle_name);
    const bMiddle = normalizeSortText(b?.middle_name);
    if (aMiddle !== bMiddle) return aMiddle.localeCompare(bMiddle);

    const aId = Number(a?.learner_id || 0);
    const bId = Number(b?.learner_id || 0);
    return aId - bId;
}

function formatLearnerLabel(row) {
    const last = row?.last_name ?? '';
    const first = row?.first_name ?? '';
    const middle = row?.middle_name ?? '';

    const base = `${last}, ${first}`.trim().replace(/^,\s*/, '');
    const mid = middle ? ` ${middle}` : '';
    return `${base}${mid}`.trim();
}

function setFixedHeader(record) {
    const header = document.getElementById('studentFixedHeader');
    if (!header) return;

    // Always visible; show placeholders when no learner is selected.
    document.getElementById('fixedLrn').textContent = record?.lrn || '—';
    document.getElementById('fixedGrade').textContent = record?.grade_name || '—';
    document.getElementById('fixedSection').textContent = record?.section_name || '—';
    document.getElementById('fixedSchoolYear').textContent = record?.year_label || '—';
}

function populateForm(formElement, record) {
    for (const section of fieldSections) {
        for (const field of section.fields) {
            const input = formElement.querySelector(`#${CSS.escape(field.key)}`);
            if (!input) continue;

            if (field.type === 'checkbox') {
                input.checked = Number(record?.[field.key]) === 1;
                continue;
            }

            const value = record?.[field.key];
            if (input.tagName === 'SELECT') {
                syncChoicesValue(input, value);
                continue;
            }

            input.value = value === null || value === undefined ? '' : String(value);

            // If this input is enhanced by flatpickr, set it through flatpickr so UI matches.
            if (input.dataset?.enhanced === 'flatpickr' || input._flatpickr) {
                syncFlatpickrValue(input, value);
            }
        }
    }
}

async function populateGeo(formElement, record, prefix) {
    const provinceEl = formElement.querySelector(`#${CSS.escape(prefix + 'province_id')}`);
    const cityEl = formElement.querySelector(`#${CSS.escape(prefix + 'city_municipality_id')}`);
    const barangayEl = formElement.querySelector(`#${CSS.escape(prefix + 'barangay_id')}`);
    if (!provinceEl || !cityEl || !barangayEl) return;

    const provinceId = Number(record?.[prefix + 'province_id'] || 0);
    const cityId = Number(record?.[prefix + 'city_municipality_id'] || 0);
    const barangayId = Number(record?.[prefix + 'barangay_id'] || 0);

    syncChoicesValue(provinceEl, provinceId ? String(provinceId) : '');
    resetSelect(cityEl, 'Select city / municipality...');
    resetSelect(barangayEl, 'Select barangay...');
    syncChoicesValue(cityEl, '');
    syncChoicesValue(barangayEl, '');

    if (!provinceId) return;

    try {
        const cities = await geoApi.getCitiesMunicipalitiesByProvince(provinceId);
        setSelectRows(cityEl, cities, 'city_municipality_id', 'city_municipality_name', 'Select city / municipality...');
        syncChoicesValue(cityEl, cityId ? String(cityId) : '');
    } catch {
        return;
    }

    if (!cityId) return;

    try {
        const barangays = await geoApi.getBarangaysByCityMunicipality(cityId);
        setSelectRows(barangayEl, barangays, 'barangay_id', 'barangay_name', 'Select barangay...');
        syncChoicesValue(barangayEl, barangayId ? String(barangayId) : '');
    } catch {
        // ignore
    }
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
            return [key, Array.isArray(data) ? data : []];
        } catch {
            return [key, []];
        }
    });

    const results = await Promise.all(entries);
    return Object.fromEntries(results);
}

document.addEventListener('DOMContentLoaded', async () => {
    const filterInput = document.getElementById('studentFilterInput');
    const selectEl = document.getElementById('studentSelect');
    const fieldsContainer = document.getElementById('studentDetailsFields');
    const form = document.getElementById('studentDetailsForm');
    const saveBtn = document.getElementById('saveChangesBtn');

    if (!selectEl || !fieldsContainer || !form || !filterInput || !saveBtn) return;

    const setFormEnabled = (enabled) => {
        const controls = Array.from(fieldsContainer.querySelectorAll('input, select, textarea'));
        for (const el of controls) {
            el.disabled = !enabled;
            if (el.tagName === 'SELECT') syncChoicesDisabledState(el);
        }
    };

    const selectOptionsByKey = await preloadSelectOptions();
    renderForm(fieldsContainer, selectOptionsByKey);
    wireGeoCascade(form, 'current_');
    wireGeoCascade(form, 'permanent_');
    wirePermanentSameAsCurrent(form);
    wireGradeSectionCascade(form);
    wireIndigenousGroupToggle(form);

    // Clear validation errors as the user edits
    const clearIfEditable = (target) => {
        if (!target) return;
        if (!target.classList?.contains('form-control')) return;
        if (target.disabled || target.readOnly) return;
        clearControlError(target);
    };
    form.addEventListener('input', (e) => clearIfEditable(e.target));
    form.addEventListener('change', (e) => clearIfEditable(e.target));

    // Default: no learner selected
    saveBtn.disabled = true;
    setFormEnabled(false);
    setFixedHeader(null);

    let allRows = [];
    let filteredRows = [];
    let currentLearnerId = null;

    function rebuildSelectOptions(keepLearnerId) {
        const keepId = keepLearnerId ?? selectEl.value;
        selectEl.innerHTML = '';

        const placeholder = document.createElement('option');
        placeholder.value = '';
        placeholder.textContent = filteredRows.length ? 'Select learner...' : 'No matching learners';
        selectEl.appendChild(placeholder);

        for (const row of filteredRows) {
            const opt = document.createElement('option');
            opt.value = String(row.learner_id);
            opt.textContent = formatLearnerLabel(row);
            selectEl.appendChild(opt);
        }

        if (keepId && filteredRows.some((r) => String(r.learner_id) === String(keepId))) {
            selectEl.value = String(keepId);
        } else {
            selectEl.value = '';
        }

        // If the selection got cleared (e.g., filter removed it), reset state.
        if (!selectEl.value) {
            currentLearnerId = null;
            setFixedHeader(null);
            form.reset();
            saveBtn.disabled = true;
            setFormEnabled(false);
        }
    }

    function applyFilter() {
        const term = (filterInput.value || '').trim().toLowerCase();
        if (!term) {
            filteredRows = allRows;
            rebuildSelectOptions(currentLearnerId);
            return;
        }

        filteredRows = allRows.filter((row) => {
            const label = formatLearnerLabel(row).toLowerCase();
            return label.includes(term);
        });

        rebuildSelectOptions(currentLearnerId);
    }

    async function refreshRows() {
        try {
            const data = await learnerRegistrationApi.list();
            allRows = Array.isArray(data) ? data : [];
            allRows.sort(compareLearnersByName);
            filteredRows = allRows;
            rebuildSelectOptions(currentLearnerId);
        } catch (err) {
            // Helpful diagnostics for 4xx/5xx (especially 422 validation responses)
            try {
                console.error('Learner registration list failed', {
                    status: err?.response?.status,
                    data: err?.response?.data,
                    url: err?.config?.url,
                    params: err?.config?.params
                });
            } catch {
                // ignore
            }
            notify('error', err?.response?.data?.message || err?.message || 'Failed to load learners.', 'Registered Details');
        }
    }

    async function selectLearnerById(learnerId) {
        const record = allRows.find((r) => String(r.learner_id) === String(learnerId));
        currentLearnerId = record ? String(record.learner_id) : null;

        if (!record) {
            setFixedHeader(null);
            form.reset();
            saveBtn.disabled = true;
            setFormEnabled(false);
            return;
        }

        saveBtn.disabled = false;
        setFormEnabled(true);

        setFixedHeader(record);
        populateForm(form, record);

        // Section options depend on selected grade level
        await populateSections(form, record);

        // Refresh Indigenous Group enable/disable state
        const indigenousEl = form.querySelector('#is_indigenous');
        if (indigenousEl) {
            indigenousEl.dispatchEvent(new Event('change'));
        }

        // Same-as-current toggle
        const sameEl = form.querySelector('#is_permanent_same_as_current');
        if (sameEl) {
            sameEl.checked = Number(record?.is_permanent_same_as_current ?? 1) === 1;
            sameEl.dispatchEvent(new Event('change'));
        }

        await populateGeo(form, record, 'current_');

        if (Number(record?.is_permanent_same_as_current ?? 1) === 1) {
            // Leave permanent disabled/empty
            resetSelect(form.querySelector('#permanent_city_municipality_id'), 'Select city / municipality...');
            resetSelect(form.querySelector('#permanent_barangay_id'), 'Select barangay...');
            return;
        }

        await populateGeo(form, record, 'permanent_');
    }

    filterInput.addEventListener('input', applyFilter);

    selectEl.addEventListener('change', () => {
        void selectLearnerById(selectEl.value);
    });

    saveBtn.addEventListener('click', async () => {
        if (!currentLearnerId) {
            notify('info', 'Select a learner first.', 'Registered Details');
            return;
        }

        const invalidControls = validateRequiredFields(form);
        if (invalidControls.length) {
            const first = invalidControls[0];
            try {
                first.focus?.();
                first.scrollIntoView?.({ behavior: 'smooth', block: 'center' });
            } catch {
                // ignore
            }
            notify('error', 'Please correct the highlighted fields.', 'Registered Details');
            return;
        }

        saveBtn.disabled = true;
        const oldHtml = saveBtn.innerHTML;
        saveBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...';

        try {
            const payload = getFormPayload(form);
            const res = await learnerRegistrationApi.update(Number(currentLearnerId), payload);

            if (!res?.success) {
                notify('error', res?.message || 'Update failed.', 'Registered Details');
                return;
            }

            notify('success', res?.message || 'Registration updated.', 'Registered Details');
            await refreshRows();
            await selectLearnerById(currentLearnerId);
        } catch (err) {
            const data = err?.response?.data;
            const serverMessage = (data && typeof data === 'object' && data.message)
                ? data.message
                : (typeof data === 'string' && data.trim() ? data : (err?.message || 'Server error.'));
            try {
                console.error('Learner registration update failed', {
                    status: err?.response?.status,
                    data: err?.response?.data,
                    url: err?.config?.url
                });
            } catch {
                // ignore
            }
            const byField = applyFieldErrors(form, (data && typeof data === 'object') ? data.field_errors : null);
            const highlighted = byField.length ? byField : highlightFieldsFromServerMessage(form, serverMessage);
            if (highlighted.length) {
                try {
                    highlighted[0].focus?.();
                    highlighted[0].scrollIntoView?.({ behavior: 'smooth', block: 'center' });
                } catch {
                    // ignore
                }
            }
            notify('error', serverMessage, 'Registered Details');
        } finally {
            saveBtn.disabled = false;
            saveBtn.innerHTML = oldHtml;
        }
    });

    await refreshRows();

    // Keep the selection blank until the user chooses a learner.
    selectEl.value = '';
    currentLearnerId = null;
    filterInput.value = '';
    setFixedHeader(null);
    saveBtn.disabled = true;
    setFormEnabled(false);
});
