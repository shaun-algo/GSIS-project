const API_BASE_URL = window.API_BASE || ((!!window.location.port && !['80', '443'].includes(String(window.location.port)))
    ? `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`
    : '/deped_capstone2/api');

axios.defaults.withCredentials = true;

const state = {
    classOfferings: [],
    gradingPeriods: [],
    selectedClassId: null,
    selectedSectionId: null,
    selectedSchoolYearId: null,
    selectedGradingPeriodId: null,
    classMeta: null,
    roster: [],
    fullRoster: [],
    honorsData: null,
    userRole: null,
};

function toast(icon, title) {
    const kind = String(icon || 'info').toLowerCase();
    const tone = (kind === 'success' || kind === 'error' || kind === 'warning' || kind === 'info') ? kind : 'info';
    const normalized = tone === 'warning' ? 'info' : tone;

    if (typeof window.showNotification === 'function') {
        window.showNotification(title, normalized);
        return Promise.resolve();
    }

    if (typeof Swal !== 'undefined' && typeof Swal.fire === 'function') {
        return Swal.fire({
            toast: true,
            position: 'bottom-end',
            showConfirmButton: false,
            timer: 2400,
            timerProgressBar: true,
            icon: tone,
            title,
            customClass: {
                popup: `deped-toast deped-toast--${tone}`,
            },
        });
    }

    if (typeof window.alert === 'function') {
        window.alert(title);
    }
    return Promise.resolve();
}

function fmt2(v) {
    if (v === null || v === undefined || Number.isNaN(Number(v))) return '—';
    return Number(v).toFixed(2);
}

function safeNum(v) {
    if (v === '' || v === null || v === undefined) return null;
    const n = Number(v);
    if (Number.isNaN(n)) return null;
    return n;
}

function fileSafe(value) {
    return String(value ?? '')
        .trim()
        .replace(/[\\/:*?"<>|]+/g, '-')
        .replace(/\s+/g, '_')
        .slice(0, 90);
}

function transmuteGrade(initial) {
    if (initial === null || initial === undefined || Number.isNaN(Number(initial))) return null;
    const g = Math.max(0, Math.min(100, Number(initial)));

    const trans = g <= 60
        ? (60 + (g / 60) * 15)
        : (75 + ((g - 60) / 40) * 25);

    return Math.round(Math.max(60, Math.min(100, trans)) * 100) / 100;
}

function computeQG(ww, pt, qe, weights) {
    if (ww === null || pt === null || qe === null) return null;
    const wWW = Number(weights?.WW ?? 0) / 100;
    const wPT = Number(weights?.PT ?? 0) / 100;
    const wQE = Number(weights?.QE ?? 0) / 100;
    const initial = ww * wWW + pt * wPT + qe * wQE;
    return transmuteGrade(initial);
}

function remarkFor(qg, passingMark) {
    if (qg === null) return '';
    return qg >= passingMark ? 'Passed' : 'Failed';
}

async function apiGet(path, params) {
    const res = await axios.get(`${API_BASE_URL}${path}`, { params: { ...params, _: Date.now() } });
    return res.data;
}

async function apiPost(path, params, body) {
    const res = await axios.post(`${API_BASE_URL}${path}?${new URLSearchParams(params)}`, body);
    return res.data;
}

function el(id) {
    return document.getElementById(id);
}

function setActiveTab(tab) {
    const btnGrades = el('tabBtnGrades');
    const btnHonors = el('tabBtnHonors');
    const tabGrades = el('tabGrades');
    const tabHonors = el('tabHonors');

    if (tab === 'honors') {
        btnGrades.classList.remove('active');
        btnHonors.classList.add('active');
        tabGrades.style.display = 'none';
        tabHonors.style.display = 'block';
        el('cr-header-title').textContent = 'Honors List & Export';
        el('cr-header-sub').textContent = 'Generate honors list from encoded grades';
    } else {
        btnHonors.classList.remove('active');
        btnGrades.classList.add('active');
        tabHonors.style.display = 'none';
        tabGrades.style.display = 'block';
        el('cr-header-title').textContent = 'Grade Encoding';
        el('cr-header-sub').textContent = '';
    }
}

function uniqueBy(arr, keyFn) {
    const seen = new Set();
    const out = [];
    for (const item of arr) {
        const k = keyFn(item);
        if (seen.has(k)) continue;
        seen.add(k);
        out.push(item);
    }
    return out;
}

function populateSelect(selectEl, items, { valueKey, labelKey, placeholder } = {}) {
    selectEl.innerHTML = '';

    if (placeholder) {
        const opt = document.createElement('option');
        opt.value = '';
        opt.textContent = placeholder;
        selectEl.appendChild(opt);
    }

    for (const it of items) {
        const opt = document.createElement('option');
        opt.value = String(it[valueKey]);
        opt.textContent = String(it[labelKey]);
        selectEl.appendChild(opt);
    }
}

function getQueryInt(name) {
    try {
        const params = new URLSearchParams(window.location.search || '');
        const raw = params.get(name);
        if (raw === null || raw === undefined || raw === '') return null;
        const n = Number(raw);
        return Number.isFinite(n) ? Math.trunc(n) : null;
    } catch (_) {
        return null;
    }
}

function selectHasValue(selectEl, value) {
    const v = String(value);
    return Array.from(selectEl.options || []).some((o) => String(o.value) === v);
}

function selectFirstNonEmpty(selectEl) {
    const opt = Array.from(selectEl.options || []).find((o) => String(o.value || '').trim() !== '');
    if (opt) selectEl.value = opt.value;
}

function pickDefaultSectionId(preferredSectionId = null, preferredClassId = null) {
    if (preferredSectionId && state.classOfferings.some((o) => Number(o.section_id) === Number(preferredSectionId))) {
        return Number(preferredSectionId);
    }

    if (preferredClassId) {
        const hit = state.classOfferings.find((o) => Number(o.class_id) === Number(preferredClassId));
        if (hit) return Number(hit.section_id);
    }

    const offerings = Array.isArray(state.classOfferings) ? state.classOfferings : [];
    if (!offerings.length) return null;

    const active = offerings.filter((o) => Number(o.school_year_is_active || 0) === 1);

    const base = active.length ? active : offerings;
    const syIds = base.map((o) => Number(o.school_year_id) || 0);
    const maxSy = syIds.length ? Math.max(...syIds) : 0;
    const latest = maxSy ? base.filter((o) => (Number(o.school_year_id) || 0) === maxSy) : base;

    // Prefer the teacher's assigned/advisory section when it exists in the dataset.
    // (sections.adviser_id matches the teacher's employee_id, which is also co.teacher_id.)
    const teacherIds = new Set(latest.map((o) => Number(o.teacher_id || 0)).filter((x) => x > 0));
    if (teacherIds.size === 1) {
        const adviserHit = latest.find((o) => {
            const adviserId = Number(o.adviser_id || 0);
            const teacherId = Number(o.teacher_id || 0);
            return adviserId > 0 && teacherId > 0 && adviserId === teacherId;
        });
        if (adviserHit) return Number(adviserHit.section_id);
    }

    const first = latest[0] || offerings[0];
    return first ? Number(first.section_id) : null;
}

function isPeriodOpen(p) {
    const status = String(p?.status_name ?? p?.status ?? '').trim().toLowerCase();
    return status === 'open';
}

function pickDefaultGradingPeriodId(schoolYearId, preferredGradingPeriodId = null) {
    if (preferredGradingPeriodId && state.gradingPeriods.some((p) => Number(p.grading_period_id) === Number(preferredGradingPeriodId) && Number(p.school_year_id) === Number(schoolYearId))) {
        return Number(preferredGradingPeriodId);
    }

    const periods = state.gradingPeriods.filter((p) => Number(p.school_year_id) === Number(schoolYearId));
    if (!periods.length) return null;

    const now = Date.now();
    const scored = periods.map((p) => {
        const start = p?.date_start ? Date.parse(p.date_start) : NaN;
        const end = p?.date_end ? Date.parse(p.date_end) : NaN;
        const inRange = Number.isFinite(start) && Number.isFinite(end) ? (start <= now && now <= end) : false;
        return {
            id: Number(p.grading_period_id),
            open: isPeriodOpen(p),
            inRange,
            start: Number.isFinite(start) ? start : Number.POSITIVE_INFINITY,
        };
    });

    scored.sort((a, b) => {
        if (a.inRange !== b.inRange) return a.inRange ? -1 : 1;
        if (a.open !== b.open) return a.open ? -1 : 1;
        if (a.start !== b.start) return a.start - b.start;
        return a.id - b.id;
    });

    return scored[0]?.id ?? null;
}

async function applyInitialGradeEncodingSelection() {
    if (!Array.isArray(state.classOfferings) || !state.classOfferings.length) {
        populateSelect(el('selSection'), [], { valueKey: 'section_id', labelKey: 'label', placeholder: 'No assigned sections' });
        populateSelect(el('selSubject'), [], { valueKey: 'class_id', labelKey: 'label', placeholder: 'No assigned subjects' });
        populateSelect(el('selPeriod'), [], { valueKey: 'grading_period_id', labelKey: 'label', placeholder: 'No grading periods' });
        return;
    }

    // Optional deep-linking support.
    const qpSectionId = getQueryInt('section_id');
    const qpClassId = getQueryInt('class_id');
    const qpGpId = getQueryInt('grading_period_id');

    // Only auto-pick when the user hasn't selected yet.
    const currentSection = Number(el('selSection')?.value || 0);
    const sectionId = currentSection || pickDefaultSectionId(qpSectionId, qpClassId);
    if (!sectionId) return;

    // Set section and build dependent selects.
    if (selectHasValue(el('selSection'), sectionId)) {
        el('selSection').value = String(sectionId);
    }
    state.selectedSectionId = sectionId;

    const meta = getSectionMeta(sectionId);
    state.selectedSchoolYearId = meta?.school_year_id ?? null;

    updateSubjectSelectForSection(sectionId, meta?.school_year_id ?? null);
    if (meta?.school_year_id) {
        updatePeriodsSelectForSchoolYear(meta.school_year_id, el('selPeriod'));
    } else {
        populateSelect(el('selPeriod'), [], { valueKey: 'grading_period_id', labelKey: 'label', placeholder: 'Select grading period' });
    }

    // Prefer query-provided subject if valid; otherwise default to first subject.
    if (qpClassId && selectHasValue(el('selSubject'), qpClassId)) {
        el('selSubject').value = String(qpClassId);
    } else {
        selectFirstNonEmpty(el('selSubject'));
    }

    // Prefer query-provided grading period; otherwise pick an Open/in-range one.
    if (meta?.school_year_id) {
        const suggestedGpId = pickDefaultGradingPeriodId(meta.school_year_id, qpGpId);
        if (suggestedGpId && selectHasValue(el('selPeriod'), suggestedGpId)) {
            el('selPeriod').value = String(suggestedGpId);
        } else {
            selectFirstNonEmpty(el('selPeriod'));
        }
    } else {
        selectFirstNonEmpty(el('selPeriod'));
    }

    await loadRoster();
}

async function loadClassOfferings() {
    const resp = await apiGet('/class_records/class_records.php', { operation: 'getMyClassOfferings' });
    if (!resp?.success) throw new Error(resp?.message || 'Failed to load class offerings');
    state.classOfferings = Array.isArray(resp.data) ? resp.data : [];

    const sections = uniqueBy(state.classOfferings, (o) => `${o.section_id}`)
        .map((o) => ({
            section_id: Number(o.section_id),
            school_year_id: Number(o.school_year_id),
            label: `${o.section_name} · ${o.grade_name || 'Grade'} · SY ${o.year_label || ''}`.trim(),
        }))
        .sort((a, b) => a.label.localeCompare(b.label));

    populateSelect(el('selSection'), sections, { valueKey: 'section_id', labelKey: 'label', placeholder: 'Select section' });
    populateSelect(el('selHonSection'), sections, { valueKey: 'section_id', labelKey: 'label', placeholder: 'Select section' });

    // Honors (Year Level scope) filters
    const years = uniqueBy(
        state.classOfferings
            .map((o) => ({
                school_year_id: Number(o.school_year_id),
                year_label: o.year_label || String(o.school_year_id || ''),
            }))
            .filter((x) => x.school_year_id),
        (x) => String(x.school_year_id)
    ).sort((a, b) => String(b.year_label).localeCompare(String(a.year_label)));

    const gradeLevels = uniqueBy(
        state.classOfferings
            .map((o) => ({
                grade_level_id: Number(o.grade_level_id),
                grade_name: o.grade_name || String(o.grade_level_id || ''),
            }))
            .filter((x) => x.grade_level_id),
        (x) => String(x.grade_level_id)
    ).sort((a, b) => String(a.grade_name).localeCompare(String(b.grade_name)));

    const syEl = el('selHonSchoolYear');
    const glEl = el('selHonGradeLevel');
    if (syEl) populateSelect(syEl, years, { valueKey: 'school_year_id', labelKey: 'year_label', placeholder: 'Select school year' });
    if (glEl) populateSelect(glEl, gradeLevels, { valueKey: 'grade_level_id', labelKey: 'grade_name', placeholder: 'Select year level' });
}

async function loadGradingPeriods() {
    const resp = await apiGet('/grading_periods/grading_periods.php', { operation: 'getAllGradingPeriods' });
    state.gradingPeriods = Array.isArray(resp) ? resp : [];
}

function getSectionMeta(sectionId) {
    const any = state.classOfferings.find((o) => Number(o.section_id) === Number(sectionId));
    if (!any) return null;
    return {
        section_id: Number(any.section_id),
        school_year_id: Number(any.school_year_id),
        section_name: any.section_name,
        grade_name: any.grade_name,
        year_label: any.year_label,
    };
}

function updateSubjectSelectForSection(sectionId, schoolYearId = null) {
    const offerings = state.classOfferings
        .filter((o) => Number(o.section_id) === Number(sectionId))
        .filter((o) => (schoolYearId ? Number(o.school_year_id) === Number(schoolYearId) : true));

    // Some datasets can contain duplicate offerings for the same subject.
    // Deduplicate by subject only and keep the latest class_id.
    const byKey = new Map();
    for (const o of offerings) {
        const subjectKey = (o.subject_id !== undefined && o.subject_id !== null && o.subject_id !== '')
            ? `sid:${o.subject_id}`
            : `scode:${o.subject_code || ''}`;
        const key = subjectKey;

        const existing = byKey.get(key);
        if (!existing || Number(o.class_id) > Number(existing.class_id)) {
            byKey.set(key, o);
        }
    }

    const subs = Array.from(byKey.values())
        .map((o) => ({
            class_id: Number(o.class_id),
            label: `${o.subject_name} (${o.subject_code})`,
        }))
        .sort((a, b) => a.label.localeCompare(b.label));

    populateSelect(el('selSubject'), subs, { valueKey: 'class_id', labelKey: 'label', placeholder: 'Select subject' });
}

function updatePeriodsSelectForSchoolYear(schoolYearId, targetSelect) {
    const items = state.gradingPeriods
        .filter((p) => Number(p.school_year_id) === Number(schoolYearId))
        .map((p) => ({
            grading_period_id: Number(p.grading_period_id),
            label: `${p.period_name}${p.status_name ? ` · ${p.status_name}` : ''}`,
        }));

    populateSelect(targetSelect, items, {
        valueKey: 'grading_period_id',
        labelKey: 'label',
        placeholder: 'Select grading period',
    });
}

function renderGradeMetrics() {
    const wrap = el('metricsGrades');
    // Metrics removed per UI request.
    if (!wrap) return;
    wrap.innerHTML = '';
    wrap.style.display = 'none';
}

function renderRosterTable() {
    const tbody = el('tbodyGrades');
    tbody.innerHTML = '';

    const searchTerm = String(el('cr-roster-search')?.value || '').trim().toLowerCase();
    const filteredRoster = searchTerm ? state.fullRoster.filter((r) => {
        const name = String(r.learner_name || '').toLowerCase();
        const lrn = String(r.lrn || '').toLowerCase();
        return name.includes(searchTerm) || lrn.includes(searchTerm);
    }) : state.fullRoster;

    const weights = state.classMeta?.weights || { WW: 0, PT: 0, QE: 0 };
    const passingMark = Number(state.classMeta?.passing_mark ?? 75);

    filteredRoster.forEach((r, idx) => {
        const ww = safeNum(r.written_works);
        const pt = safeNum(r.performance_tasks);
        const qe = safeNum(r.quarterly_exam);
        const qgFromComponents = computeQG(ww, pt, qe, weights);
        const qgFallback = safeNum(r.quarterly_grade);
        const qg = (qgFromComponents === null) ? qgFallback : qgFromComponents;
        r._computed_qg = qg;

        const tr = document.createElement('tr');
        tr.dataset.enrollmentId = String(r.enrollment_id);

        tr.innerHTML = `
            <td style="color: var(--gray-600); font-weight: 700;">${idx + 1}</td>
            <td>
                <div style="display:flex; flex-direction:column; gap:2px;">
                    <span style="font-weight: 800;">${r.learner_name}</span>
                    <span style="font-size: 12px; color: var(--gray-600);">${r.gender || ''}</span>
                </div>
            </td>
            <td style="font-size: 12px; color: var(--gray-600);">${r.lrn}</td>
            <td><input class="form-control cr-grade-input" type="number" min="0" max="100" step="0.01" value="${ww === null ? '' : ww}" data-field="written_works" placeholder="—"></td>
            <td><input class="form-control cr-grade-input" type="number" min="0" max="100" step="0.01" value="${pt === null ? '' : pt}" data-field="performance_tasks" placeholder="—"></td>
            <td><input class="form-control cr-grade-input" type="number" min="0" max="100" step="0.01" value="${qe === null ? '' : qe}" data-field="quarterly_exam" placeholder="—"></td>
            <td style="font-weight: 900;">${qg === null ? '—' : fmt2(qg)}</td>
            <td>${qg === null ? '' : `<span class="tx-badge">${remarkFor(qg, passingMark)}</span>`}</td>
        `;

        tbody.appendChild(tr);
    });

    tbody.querySelectorAll('input[data-field]').forEach((inp) => {
        inp.addEventListener('input', () => {
            const tr = inp.closest('tr');
            const enrollmentId = Number(tr?.dataset?.enrollmentId || 0);
            const row = state.fullRoster.find((x) => Number(x.enrollment_id) === enrollmentId);
            if (!row) return;

            const field = inp.dataset.field;
            const v = inp.value === '' ? null : Math.max(0, Math.min(100, Number(inp.value)));
            row[field] = v;

            const weights2 = state.classMeta?.weights || { WW: 0, PT: 0, QE: 0 };
            const ww2 = safeNum(row.written_works);
            const pt2 = safeNum(row.performance_tasks);
            const qe2 = safeNum(row.quarterly_exam);
            const qg2 = computeQG(ww2, pt2, qe2, weights2);
            row._computed_qg = qg2;

            const passingMark2 = Number(state.classMeta?.passing_mark ?? 75);
            const tds = tr.querySelectorAll('td');
            // QG column is 7th (0-based 6)
            if (tds[6]) tds[6].textContent = qg2 === null ? '—' : fmt2(qg2);
            if (tds[7]) tds[7].innerHTML = qg2 === null ? '' : `<span class="tx-badge">${remarkFor(qg2, passingMark2)}</span>`;

            renderGradeMetrics();
        });
    });

    renderGradeMetrics();
}

async function loadRoster() {
    const classId = Number(el('selSubject').value || 0);
    const gpId = Number(el('selPeriod').value || 0);
    if (!classId || !gpId) {
        state.roster = [];
        el('tbodyGrades').innerHTML = '';
        el('metricsGrades').innerHTML = '';
        return;
    }

    const resp = await apiGet('/class_records/class_records.php', {
        operation: 'getRosterGrades',
        class_id: classId,
        grading_period_id: gpId,
    });

    if (!resp?.success) throw new Error(resp?.message || 'Failed to load roster');

    state.selectedClassId = classId;
    state.selectedGradingPeriodId = gpId;
    state.classMeta = resp.data?.class || null;
    state.roster = Array.isArray(resp.data?.learners) ? resp.data.learners : [];
    state.fullRoster = [...state.roster];

    renderRosterTable();
}

async function saveGrades() {
    const classId = state.selectedClassId;
    const gpId = state.selectedGradingPeriodId;

    if (!classId || !gpId) {
        await toast('warning', 'Select subject and grading period first');
        return;
    }

    const grades = state.roster.map((r) => ({
        enrollment_id: Number(r.enrollment_id),
        written_works: r.written_works === '' ? null : safeNum(r.written_works),
        performance_tasks: r.performance_tasks === '' ? null : safeNum(r.performance_tasks),
        quarterly_exam: r.quarterly_exam === '' ? null : safeNum(r.quarterly_exam),
    }));

    const resp = await apiPost('/class_records/class_records.php', { operation: 'saveRosterGrades' }, {
        class_id: classId,
        grading_period_id: gpId,
        grades,
    });

    if (!resp?.success) {
        throw new Error(resp?.message || 'Save failed');
    }

    await toast('success', `Saved (${resp.data?.saved || 0}), skipped (${resp.data?.skipped || 0})`);
    await loadRoster();
}

function renderHonors(data) {
    const honorees = Array.isArray(data?.honorees) ? data.honorees : [];

    const head = el('theadHonors');
    const body = el('tbodyHonors');

    head.innerHTML = '';
    body.innerHTML = '';

    const trh = document.createElement('tr');
    trh.innerHTML = `
        <th style="width: 42px;">#</th>
        <th>Learner</th>
        <th style="width: 140px;">LRN</th>
        <th style="text-align:center; width: 120px;">Gen. Avg.</th>
        <th style="width: 180px; text-align:center;">Honor Level</th>
    `;
    head.appendChild(trh);

    if (!honorees.length) {
        const tr = document.createElement('tr');
        tr.innerHTML = `<td colspan="5" style="text-align:center; color: var(--gray-600); padding: 18px;">No honor qualifiers yet. Encode complete grades first.</td>`;
        body.appendChild(tr);
        return;
    }

    honorees.forEach((h, idx) => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td style="font-weight: 900;">${idx + 1}</td>
            <td style="font-weight: 800;">${h.learner_name}</td>
            <td style="font-size: 12px; color: var(--gray-600);">${h.lrn}</td>
            <td style="text-align:center; font-weight: 900;">${fmt2(h.general_average)}</td>
            <td style="text-align:center;"><span class="tx-badge">${h.honor?.honor_name || ''}</span></td>
        `;
        body.appendChild(tr);
    });
}

function buildPrintArea(data, options = {}) {
    const section = data?.section || {};
    const honorees = Array.isArray(data?.honorees) ? data.honorees : [];

    const mode = data?.mode === 'final' ? 'Final' : 'Quarterly';
    const today = new Date().toLocaleDateString('en-PH', { year: 'numeric', month: 'long', day: 'numeric' });

    const appBase = (typeof window !== 'undefined' && window.APP_BASE) ? String(window.APP_BASE) : '';
    const leftLogoUrl = options.leftLogoUrl || `${appBase}/assets/img/logo/logo.jpg`;
    const rightLogoUrl = options.rightLogoUrl || `${appBase}/assets/img/logo/pngegg.png`;

    const tableHtml = (() => {
        if (!honorees.length) {
            return `<p style="text-align:center; font-style: italic; padding: 18px;">No honor qualifiers.</p>`;
        }

        const thead = `
            <thead>
                <tr>
                    <th style="border:1px solid var(--gray-900); padding:6px;">Rank</th>
                    <th style="border:1px solid var(--gray-900); padding:6px;">Name</th>
                    <th style="border:1px solid var(--gray-900); padding:6px;">LRN</th>
                    <th style="border:1px solid var(--gray-900); padding:6px;">Gen. Avg.</th>
                    <th style="border:1px solid var(--gray-900); padding:6px; text-align:center;">Honor</th>
                </tr>
            </thead>`;

        const tbody = honorees.map((h, i) => {
            return `
                <tr>
                    <td style="border:1px solid var(--gray-900); padding:6px; text-align:center; font-weight:700;">${i + 1}</td>
                    <td style="border:1px solid var(--gray-900); padding:6px; font-weight:700;">${h.learner_name}</td>
                    <td style="border:1px solid var(--gray-900); padding:6px; text-align:center;">${h.lrn}</td>
                    <td style="border:1px solid var(--gray-900); padding:6px; text-align:center; font-weight:700;">${fmt2(h.general_average)}</td>
                    <td style="border:1px solid var(--gray-900); padding:6px; text-align:center;">${h.honor?.honor_name || ''}</td>
                </tr>`;
        }).join('');

        return `<table style="width:100%; border-collapse:collapse; font-size: 11px; color: var(--gray-900);">${thead}<tbody>${tbody}</tbody></table>`;
    })();

    return `
        <div style="padding: 18px 22px; color: var(--gray-900); font-family: Arial, Helvetica, sans-serif;">
            <div style="border-bottom: 2px solid var(--gray-900); padding-bottom: 14px; margin-bottom: 16px;">
                <div style="display:flex; align-items:center; justify-content:space-between; gap: 12px;">
                    <div style="width: 140px; display:flex; align-items:center; justify-content:flex-start;">
                        <img src="${leftLogoUrl}" alt="DepEd Logo" style="height: 92px; width: auto; object-fit: contain;" />
                    </div>
                    <div style="text-align:center; flex: 1;">
                        <div style="font-size: 12px; font-weight: 700; text-transform: uppercase;">Republic of the Philippines</div>
                        <div style="font-size: 13px; font-weight: 900; text-transform: uppercase;">Department of Education</div>
                        <div style="font-size: 11px; margin-top: 2px;">DepEd Academic Monitoring System</div>
                        <div style="font-size: 15px; font-weight: 900; text-transform: uppercase; margin-top: 8px;">Honors List</div>
                        <div style="font-size: 12px;">${mode} · SY ${section.year_label || ''}</div>
                    </div>
                    <div style="width: 140px; display:flex; align-items:center; justify-content:flex-end;">
                        <img src="${rightLogoUrl}" alt="DepEd Seal" style="height: 92px; width: auto; object-fit: contain;" />
                    </div>
                </div>
            </div>

            <div style="display:flex; justify-content:space-between; font-size: 12px; margin-bottom: 12px; gap: 12px; flex-wrap: wrap;">
                <div><b>Section:</b> ${section.section_name || ''} · ${section.grade_name || ''}</div>
                <div><b>Date:</b> ${today}</div>
            </div>

            <div style="margin-top: 12px;">${tableHtml}</div>

            <div style="margin-top: 18px; font-size: 11px; text-align:center; color: var(--gray-600);">
                Generated by SIAS · DepEd Academic Monitoring System
            </div>
        </div>
    `;
}

async function loadUserRole() {
    try {
        const resp = await axios.get(`${API_BASE_URL}/auth/me.php`, { withCredentials: true });
        if (resp.data?.success) {
            const me = resp.data.data || {};
            state.userRole = me?.role_id ?? null;
            state.roleKey = String(me?.role_key || '');
            state.privileges = me?.privileges || {};
            state.isRegistrar = !!me?.is_registrar;
            state.isAdviser = !!me?.is_adviser;
        }
    } catch (e) {
        console.error('Failed to load user role:', e);
    }
}

function downloadTextFile(filename, text, mime = 'text/csv;charset=utf-8;') {
    const blob = new Blob(["\uFEFF" + text], { type: mime });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    a.remove();
    URL.revokeObjectURL(url);
}

function downloadBlobFile(filename, blob) {
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    a.remove();
    URL.revokeObjectURL(url);
}

function blobToDataUrl(blob) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onerror = () => reject(new Error('Failed to read blob'));
        reader.onload = () => resolve(String(reader.result || ''));
        reader.readAsDataURL(blob);
    });
}

async function tryFetchAsDataUrl(url) {
    try {
        const res = await fetch(url, { credentials: 'include' });
        if (!res.ok) return null;
        const blob = await res.blob();
        return await blobToDataUrl(blob);
    } catch (_) {
        return null;
    }
}

function buildHonorsExportHtmlDocument(data, options = {}) {
    const content = buildPrintArea(data, options);

    // Minimal CSS variables so the exported HTML looks like the in-app print template.
    // (When downloaded, it won't have access to dashboard.css.)
    const style = `
        :root{
            --gray-900:#111827;
            --gray-600:#4B5563;
        }
        body{margin:0;padding:0;background:#fff;}
        img{display:block;}
        table{width:100%;}
        @media print{
            body{margin:0;}
        }
    `;

    return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Honors List Export</title>
  <style>${style}</style>
</head>
<body>
  ${content}
</body>
</html>`;
}

async function ensureHtml2Pdf() {
    if (window.html2pdf) return window.html2pdf;

    await new Promise((resolve, reject) => {
        const existing = document.querySelector('script[data-hon-html2pdf="1"]');
        if (existing) {
            existing.addEventListener('load', resolve, { once: true });
            existing.addEventListener('error', () => reject(new Error('Failed to load PDF library')), { once: true });
            return;
        }

        const script = document.createElement('script');
        script.src = 'https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js';
        script.async = true;
        script.dataset.honHtml2pdf = '1';
        script.onload = () => resolve();
        script.onerror = () => reject(new Error('Failed to load PDF library'));
        document.head.appendChild(script);
    });

    if (!window.html2pdf) {
        throw new Error('PDF library is unavailable');
    }
    return window.html2pdf;
}

async function downloadHonorsExport() {
    if (!state.honorsData) {
        const ok = await loadHonors({ requireReady: true });
        if (!ok) return;
    }
    const data = state.honorsData;
    const honorees = Array.isArray(data?.honorees) ? data.honorees : [];
    if (!honorees.length) {
        await toast('info', 'No honor qualifiers to export');
        return;
    }

    const section = data?.section || {};
    const mode = data?.mode === 'final' ? 'Final' : 'Quarterly';
    const periodLabel = (data?.mode === 'quarter') ? (el('selHonPeriod')?.selectedOptions?.[0]?.textContent || '') : '';

    const nameParts = [
        'honors',
        fileSafe(section.section_name || 'section'),
        fileSafe(section.year_label || ''),
        fileSafe(mode),
        fileSafe(periodLabel)
    ].filter(Boolean);
    const filename = `${nameParts.join('_')}.pdf`;

    // Embed logos for offline viewing (file://) by converting them to data URLs.
    const appBase = (typeof window !== 'undefined' && window.APP_BASE) ? String(window.APP_BASE) : '';
    const leftPath = `${appBase}/assets/img/logo/logo.jpg`;
    const rightPath = `${appBase}/assets/img/logo/pngegg.png`;
    const leftAbs = new URL(leftPath, window.location.origin).toString();
    const rightAbs = new URL(rightPath, window.location.origin).toString();

    const [leftDataUrl, rightDataUrl] = await Promise.all([
        tryFetchAsDataUrl(leftAbs),
        tryFetchAsDataUrl(rightAbs),
    ]);

    const html = buildHonorsExportHtmlDocument(data, {
        leftLogoUrl: leftDataUrl || leftAbs,
        rightLogoUrl: rightDataUrl || rightAbs,
    });

    // html2pdf works best when given regular DOM nodes. Mounting a full
    // <!doctype html><html>...</html> string inside a div can result in blank
    // captures in some browsers, so we extract the body + inline styles.
    let mountInnerHtml = html;
    try {
        const doc = new DOMParser().parseFromString(html, 'text/html');
        const inlineStyle = doc.querySelector('style')?.textContent || '';
        const bodyHtml = doc.body?.innerHTML || '';
        mountInnerHtml = `${inlineStyle ? `<style>${inlineStyle}</style>` : ''}${bodyHtml}`;
    } catch (_) {
        // Fall back to raw html string.
    }

    const html2pdfLib = await ensureHtml2Pdf();
    const mount = document.createElement('div');
    mount.style.position = 'absolute';
    // Keep it fully visible (opacity 1) to avoid blank captures, but move it
    // just outside the viewport using a transform (not huge coordinates).
    mount.style.left = '0';
    mount.style.top = '0';
    mount.style.transform = 'translateX(120vw)';
    mount.style.opacity = '1';
    mount.style.pointerEvents = 'none';
    mount.style.zIndex = '2147483647';
    mount.style.width = '1000px';
    mount.style.background = '#ffffff';
    mount.innerHTML = mountInnerHtml;
    document.body.appendChild(mount);

    const waitForImages = async (container, timeoutMs = 6000) => {
        const imgs = Array.from(container.querySelectorAll('img'));
        if (!imgs.length) return;

        const start = Date.now();
        await Promise.all(imgs.map((img) => {
            if (img.complete && img.naturalWidth > 0) return Promise.resolve();
            return new Promise((resolve) => {
                const done = () => resolve();
                img.addEventListener('load', done, { once: true });
                img.addEventListener('error', done, { once: true });
                const poll = () => {
                    if ((img.complete && img.naturalWidth > 0) || (Date.now() - start) > timeoutMs) {
                        resolve();
                        return;
                    }
                    setTimeout(poll, 150);
                };
                poll();
            });
        }));
    };

    try {
        await waitForImages(mount);

        // Give the browser time to paint/layout before html2canvas capture.
        await new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)));

        const rect = mount.getBoundingClientRect();
        if (!rect.width || !rect.height) {
            throw new Error('Export content is not renderable (empty layout)');
        }

        const worker = html2pdfLib()
            .set({
                filename,
                margin: [0.3, 0.3, 0.3, 0.3],
                image: { type: 'jpeg', quality: 1 },
                html2canvas: {
                    scale: 2,
                    useCORS: true,
                    allowTaint: true,
                    backgroundColor: '#ffffff',
                    scrollX: 0,
                    scrollY: 0,
                },
                jsPDF: { unit: 'in', format: 'a4', orientation: 'portrait' },
            })
            .from(mount);

        // Generate a blob so we can detect blank/suspicious outputs.
        let pdfBlob = null;
        try {
            if (typeof worker.outputPdf === 'function') {
                pdfBlob = await worker.outputPdf('blob');
            } else if (typeof worker.output === 'function') {
                pdfBlob = await worker.output('blob');
            }
        } catch (e) {
            console.warn('Honors export: blob output failed, falling back to save()', e);
            pdfBlob = null;
        }

        if (pdfBlob instanceof Blob) {
            // A totally blank PDF is usually very small. If it's suspiciously
            // tiny, fall back to downloading the HTML export instead.
            if (pdfBlob.size < 15000) {
                const htmlName = filename.replace(/\.pdf$/i, '.html');
                downloadTextFile(htmlName, html, 'text/html;charset=utf-8;');
                await toast('warning', 'PDF export was blank; downloaded HTML instead');
                return;
            }

            downloadBlobFile(filename, pdfBlob);
            await toast('success', 'Honors export downloaded');
            return;
        }

        // Last resort: let html2pdf trigger the download itself.
        await worker.save();
    } finally {
        mount.remove();
    }
}

async function loadHonors(options = {}) {
    const requireReady = Boolean(options.requireReady);
    const mode = String(el('selHonMode').value || 'quarter');

    const scope = String(el('selHonScope')?.value || 'section');
    const isGrade = scope === 'grade';

    let params;
    if (isGrade) {
        const sy = Number(el('selHonSchoolYear')?.value || 0);
        const gl = Number(el('selHonGradeLevel')?.value || 0);
        if (!sy || !gl) {
            const mh = el('metricsHonors'); if (mh) mh.innerHTML = '';
            const th = el('theadHonors'); if (th) th.innerHTML = '';
            const tb = el('tbodyHonors'); if (tb) tb.innerHTML = '';
            state.honorsData = null;
            const pa = el('cr-print-area'); if (pa) pa.innerHTML = '';
            if (requireReady) await toast('warning', 'Select school year and year level first');
            return false;
        }
        params = { operation: 'getHonorsListByGradeLevel', school_year_id: sy, grade_level_id: gl, mode };
    } else {
        const sectionId = Number(el('selHonSection').value || 0);
        if (!sectionId) {
            const mh = el('metricsHonors'); if (mh) mh.innerHTML = '';
            const th = el('theadHonors'); if (th) th.innerHTML = '';
            const tb = el('tbodyHonors'); if (tb) tb.innerHTML = '';
            state.honorsData = null;
            const pa = el('cr-print-area'); if (pa) pa.innerHTML = '';
            if (requireReady) await toast('warning', 'Select section first');
            return false;
        }
        params = { operation: 'getHonorsList', section_id: sectionId, mode };
    }

    if (mode === 'quarter') {
        const gpId = Number(el('selHonPeriod').value || 0);
        if (!gpId) {
            if (requireReady) await toast('warning', 'Select grading period');
            return false;
        }
        params = { ...params, grading_period_id: gpId };
    }

    const resp = await apiGet('/class_records/class_records.php', params);
    if (!resp?.success) throw new Error(resp?.message || 'Failed to load honors');

    state.honorsData = resp.data;

    renderHonors(resp.data);

    const printArea = el('cr-print-area');
    printArea.innerHTML = buildPrintArea(resp.data);

    return true;
}

function updateHonorsModeUI() {
    const mode = String(el('selHonMode').value || 'quarter');
    el('wrapHonPeriod').style.display = (mode === 'quarter') ? 'block' : 'none';
}

function updateHonorsScopeUI() {
    const scope = String(el('selHonScope')?.value || 'section');
    const isGrade = scope === 'grade';
    const sectionGroup = el('selHonSection')?.closest('.form-group');
    if (sectionGroup) sectionGroup.style.display = isGrade ? 'none' : 'block';
    const wrapSy = el('wrapHonSchoolYear');
    const wrapGl = el('wrapHonGradeLevel');
    if (wrapSy) wrapSy.style.display = isGrade ? 'block' : 'none';
    if (wrapGl) wrapGl.style.display = isGrade ? 'block' : 'none';
}

async function init() {
    setActiveTab('grades');

    await loadUserRole();

    el('tabBtnGrades').addEventListener('click', () => setActiveTab('grades'));
    el('tabBtnHonors').addEventListener('click', () => {
        setActiveTab('honors');
        loadHonors().catch((e) => {
            console.error(e);
            toast('error', e.message || 'Failed to load honors');
        });
    });

    await loadGradingPeriods();
    await loadClassOfferings();

    // Default to the teacher's assigned section (latest SY) and load its roster.
    await applyInitialGradeEncodingSelection();

    el('selSection').addEventListener('change', async () => {
        const sectionId = Number(el('selSection').value || 0);
        state.selectedSectionId = sectionId;

        if (!sectionId) {
            el('selSubject').innerHTML = '';
            el('selPeriod').innerHTML = '';
            return;
        }

        const meta = getSectionMeta(sectionId);
        state.selectedSchoolYearId = meta?.school_year_id ?? null;

        updateSubjectSelectForSection(sectionId, meta?.school_year_id ?? null);
        if (meta?.school_year_id) updatePeriodsSelectForSchoolYear(meta.school_year_id, el('selPeriod'));
        else populateSelect(el('selPeriod'), [], { valueKey: 'grading_period_id', labelKey: 'label', placeholder: 'Select grading period' });

        // Default to first subject and an Open/in-range grading period when possible.
        selectFirstNonEmpty(el('selSubject'));
        if (meta?.school_year_id) {
            const suggestedGpId = pickDefaultGradingPeriodId(meta.school_year_id, null);
            if (suggestedGpId && selectHasValue(el('selPeriod'), suggestedGpId)) {
                el('selPeriod').value = String(suggestedGpId);
            } else {
                selectFirstNonEmpty(el('selPeriod'));
            }
        } else {
            selectFirstNonEmpty(el('selPeriod'));
        }

        await loadRoster();
    });

    el('selSubject').addEventListener('change', () => loadRoster().catch((e) => toast('error', e.message || 'Failed')));
    el('selPeriod').addEventListener('change', () => loadRoster().catch((e) => toast('error', e.message || 'Failed')));

    // Search input for roster filtering
    const rosterSearch = el('cr-roster-search');
    if (rosterSearch) {
        rosterSearch.addEventListener('input', () => {
            renderRosterTable();
        });
    }

    // Reload button removed from UI.
    el('btnSave').addEventListener('click', () => saveGrades().catch((e) => {
        console.error(e);
        toast('error', e.message || 'Save failed');
    }));

    // Honors controls
    el('selHonScope')?.addEventListener('change', () => {
        updateHonorsScopeUI();

        // When switching to year-level scope, update periods using selected SY.
        if (String(el('selHonScope')?.value || 'section') === 'grade') {
            const sy = Number(el('selHonSchoolYear')?.value || 0);
            if (sy) {
                updatePeriodsSelectForSchoolYear(sy, el('selHonPeriod'));
                if (el('selHonPeriod').options.length > 1) el('selHonPeriod').selectedIndex = 1;
            }
        }

        loadHonors().catch((e) => toast('error', e.message || 'Failed'));
    });

    el('selHonSection').addEventListener('change', () => {
        const sectionId = Number(el('selHonSection').value || 0);
        if (!sectionId) return;
        const meta = getSectionMeta(sectionId);
        if (meta) {
            updatePeriodsSelectForSchoolYear(meta.school_year_id, el('selHonPeriod'));
            if (el('selHonPeriod').options.length > 1) el('selHonPeriod').selectedIndex = 1;
        }
        loadHonors().catch((e) => toast('error', e.message || 'Failed'));
    });

    el('selHonSchoolYear')?.addEventListener('change', () => {
        const sy = Number(el('selHonSchoolYear')?.value || 0);
        if (sy) {
            updatePeriodsSelectForSchoolYear(sy, el('selHonPeriod'));
            if (el('selHonPeriod').options.length > 1) el('selHonPeriod').selectedIndex = 1;
        }
        loadHonors().catch((e) => toast('error', e.message || 'Failed'));
    });

    el('selHonGradeLevel')?.addEventListener('change', () => loadHonors().catch((e) => toast('error', e.message || 'Failed')));

    el('selHonMode').addEventListener('change', () => {
        updateHonorsModeUI();
        loadHonors().catch((e) => toast('error', e.message || 'Failed'));
    });

    el('selHonPeriod').addEventListener('change', () => loadHonors().catch((e) => toast('error', e.message || 'Failed')));

    el('btnHonExport')?.addEventListener('click', () => {
        const scope = String(el('selHonScope')?.value || 'section');
        const isGradeLevel = scope === 'grade';
        const canExportYearLevel = !!(state?.privileges && state.privileges.can_export_honors_year_level);
        const isAdmin = Number(state.userRole || 0) === 8 || String(state.roleKey || '').toLowerCase() === 'admin';

        if (isGradeLevel && !(canExportYearLevel || isAdmin)) {
            toast('error', 'Export for year level is restricted to admins, registrars, and advisors only.');
            return;
        }

        downloadHonorsExport().catch((e) => {
            console.error(e);
            toast('error', e.message || 'Export failed');
        });
    });

    el('btnHonPrint').addEventListener('click', async () => {
        const ok = await loadHonors({ requireReady: true });
        if (!ok) return;

        const printArea = el('cr-print-area');
        if (!printArea.innerHTML.trim()) return;
        printArea.style.display = 'block';
        window.print();
        printArea.style.display = 'none';
    });

    updateHonorsModeUI();
    updateHonorsScopeUI();
}

document.addEventListener('DOMContentLoaded', () => {
    init().catch((e) => {
        console.error(e);
        toast('error', e.message || 'Failed to initialize');
    });
});
