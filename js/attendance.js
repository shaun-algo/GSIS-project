const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;
axios.defaults.withCredentials = true;

function escapeHtml(s) {
    return String(s)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

function todayStr() {
    return new Date().toISOString().slice(0, 10);
}

function fmtDate(yyyyMmDd) {
    if (!yyyyMmDd) return '—';
    try {
        return new Date(`${yyyyMmDd}T00:00:00`).toLocaleDateString('en-PH', { month: 'short', day: 'numeric', year: 'numeric' });
    } catch {
        return yyyyMmDd;
    }
}

function normalizeGender(gender) {
    const g = String(gender || '').trim().toLowerCase();
    if (g === 'male') return 'Male';
    if (g === 'female') return 'Female';
    if (g) return 'Other';
    return '';
}

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
        });
    }

    if (typeof window.alert === 'function') window.alert(title);
    return Promise.resolve();
}

async function apiGet(path, params) {
    const res = await axios.get(`${API_BASE_URL}${path}`, { params: { ...params, _: Date.now() } });
    return res.data;
}

async function apiPost(path, params, body) {
    const res = await axios.post(`${API_BASE_URL}${path}?${new URLSearchParams(params)}`, body);
    return res.data;
}

const schoolYearsApi = {
    list: () => apiGet('/school_years/school_years.php', { operation: 'getAllSchoolYears' }),
};

const gradingPeriodsApi = {
    list: () => apiGet('/grading_periods/grading_periods.php', { operation: 'getAllGradingPeriods' }),
};

const sectionsApi = {
    list: (schoolYearId) => apiGet('/sections/sections.php', { operation: 'getAllSections', school_year_id: Number(schoolYearId) || 0 }),
};

const classOfferingsApi = {
    list: () => apiGet('/class_offerings/class_offerings.php', { operation: 'getAllClassOfferings' }),
};

const attendanceApi = {
    roster: ({ sectionId, schoolYearId }) => apiGet('/attendance/attendance.php', {
        operation: 'getSectionRoster',
        section_id: Number(sectionId),
        school_year_id: Number(schoolYearId),
    }),
    month: ({ sectionId, schoolYearId, gradingPeriodId, month, classId = 0 }) => apiGet('/attendance/attendance.php', {
        operation: 'getMonthAttendance',
        section_id: Number(sectionId),
        school_year_id: Number(schoolYearId),
        grading_period_id: Number(gradingPeriodId),
        month,
        class_id: Number(classId),
    }),
    day: ({ sectionId, schoolYearId, gradingPeriodId, date, session, classId = 0 }) => apiGet('/attendance/attendance.php', {
        operation: 'getDayAttendance',
        section_id: Number(sectionId),
        school_year_id: Number(schoolYearId),
        grading_period_id: Number(gradingPeriodId),
        date,
        session,
        class_id: Number(classId),
    }),
    saveDay: ({ sectionId, schoolYearId, gradingPeriodId, date, session, entries, classId = 0 }) => apiPost('/attendance/attendance.php', {
        operation: 'saveDayAttendance',
    }, {
        section_id: Number(sectionId),
        school_year_id: Number(schoolYearId),
        grading_period_id: Number(gradingPeriodId),
        date,
        session,
        class_id: Number(classId),
        entries,
    })
};

const schoolSettingsApi = {
    all: () => apiGet('/school_settings/school_settings.php', { operation: 'getAllSettings' }),
};

const CODE_TO_STATUS = {
    P: 'Present',
    A: 'Absent',
    L: 'Late',
    C: 'Cutting',
    E: 'Excused',
    O: 'Official Business',
};

const STATUS_TO_CODE = {
    Present: 'P',
    Absent: 'A',
    Late: 'L',
    Cutting: 'C',
    Excused: 'E',
    'Official Business': 'O',
};

const state = {
    schoolYears: [],
    sections: [],
    classOfferings: [],
    gradingPeriods: [],
    roster: [],
    att: new Map(),
    orig: new Map(),
    dirty: false,
    saving: false,
    session: 'AM',
    lastSel: { syId: 0, sectionId: 0, classId: 0, periodId: 0, date: '', session: 'AM' },
};

function setSaveIndicator(kind, text) {
    const el = document.getElementById('attSaveInd');
    const lbl = document.getElementById('attSaveLbl');
    if (!el || !lbl) return;
    el.classList.remove('is-dirty', 'is-saving', 'is-saved');
    if (kind) el.classList.add(kind);
    lbl.textContent = text || '—';
}

function setDirty() {
    state.dirty = true;
    if (state.saving) return;
    setSaveIndicator('is-dirty', 'Unsaved changes');
}

function setSaved() {
    state.dirty = false;
    if (state.saving) return;
    setSaveIndicator('is-saved', 'All saved');
    setTimeout(() => {
        if (!state.dirty && !state.saving) setSaveIndicator('', 'All saved');
    }, 2500);
}

function setSaving() {
    state.saving = true;
    setSaveIndicator('is-saving', 'Saving...');
}

function clearSaving() {
    state.saving = false;
    if (state.dirty) setSaveIndicator('is-dirty', 'Unsaved changes');
    else setSaveIndicator('is-saved', 'All saved');
}

function fullName(r) {
    return String(r.learner_name || '').trim();
}

function selectedClassId() {
    return Number(document.getElementById('attClass')?.value || 0);
}

function selectedClassOffering() {
    const classId = selectedClassId();
    return state.classOfferings.find((row) => Number(row.class_id) === classId) || null;
}

function getSelected() {
    const syId = Number(document.getElementById('attSchoolYear')?.value || 0);
    const sectionId = Number(document.getElementById('attSection')?.value || 0);
    const classId = selectedClassId();
    const periodId = Number(document.getElementById('attPeriod')?.value || 0);
    const date = String(document.getElementById('attDate')?.value || '').trim();
    return { syId, sectionId, classId, periodId, date, session: state.session };
}

function setSession(next) {
    state.session = next === 'PM' ? 'PM' : 'AM';
    const btnAM = document.getElementById('btnSessAM');
    const btnPM = document.getElementById('btnSessPM');
    if (btnAM) btnAM.classList.toggle('is-on', state.session === 'AM');
    if (btnPM) btnPM.classList.toggle('is-on', state.session === 'PM');
}

function updateInfoBar() {
    const { sectionId, classId } = getSelected();
    const secName = state.sections.find(s => Number(s.section_id) === Number(sectionId))?.section_name || '—';
    const offering = state.classOfferings.find((row) => Number(row.class_id) === Number(classId)) || null;
    const subjectName = offering
        ? [offering.subject_name, offering.subject_code ? `(${offering.subject_code})` : ''].filter(Boolean).join(' ')
        : '';
    const title = document.getElementById('attCardTitle');
    if (!title) return;
    if (!sectionId) {
        title.textContent = 'Select a section and subject to begin';
        return;
    }
    if (!classId || !subjectName) {
        title.textContent = `Select a subject for ${secName || 'this section'}`;
        return;
    }
    title.textContent = `Learners — ${secName} • ${subjectName}`;
}

function getEmptyRosterMessage() {
    const { syId, sectionId, classId } = getSelected();
    if (!syId) return 'Select School Year above.';
    if (!sectionId) return 'Select School Year and Section above.';
    if (!classId) return 'Select Subject above.';
    return 'No learners found for this subject.';
}

function resetAttendanceState() {
    state.roster = [];
    state.att = new Map();
    state.orig = new Map();
}

function renderStats() {
    const total = state.roster.length;
    const counts = { P: 0, A: 0, L: 0, C: 0, E: 0, O: 0 };
    state.roster.forEach((r) => {
        const code = state.att.get(Number(r.enrollment_id)) || 'P';
        if (counts[code] !== undefined) counts[code]++;
    });

    const elTotal = document.getElementById('stTotal');
    const elP = document.getElementById('stP');
    const elA = document.getElementById('stA');
    const elL = document.getElementById('stL');
    const elC = document.getElementById('stC');
    const elE = document.getElementById('stE');
    if (elTotal) elTotal.textContent = total ? String(total) : '—';
    if (elP) elP.textContent = total ? String(counts.P) : '—';
    if (elA) elA.textContent = total ? String(counts.A) : '—';
    if (elL) elL.textContent = total ? String(counts.L) : '—';
    if (elC) elC.textContent = total ? String(counts.C) : '—';
    if (elE) elE.textContent = total ? String(counts.E + counts.O) : '—';
}

function buildToggle(enrollmentId, code) {
    const curr = ['P', 'A', 'L', 'C', 'E', 'O'].includes(code) ? code : 'P';
    const pill = (() => {
        if (curr === 'A') return '<span class="att-pill-absent"><span class="att-dot att-dot-absent"></span>Absent</span>';
        if (curr === 'L') return '<span class="att-pill-warn"><span class="att-dot att-dot-warn"></span>Late</span>';
        if (curr === 'C') return '<span class="att-pill-warn"><span class="att-dot att-dot-warn"></span>Cutting</span>';
        if (curr === 'E') return '<span class="att-pill-info"><span class="att-dot att-dot-info"></span>Excused</span>';
        if (curr === 'O') return '<span class="att-pill-info"><span class="att-dot att-dot-info"></span>OB</span>';
        return '<span class="att-pill-present"><span class="att-dot"></span>Present</span>';
    })();
    return `
        <div style="display:inline-flex; align-items:center; gap:10px; justify-content:flex-end;">
            ${pill}
            <select class="att-select" data-eid="${enrollmentId}" data-native="true" aria-label="Attendance status">
                <option value="P"${curr === 'P' ? ' selected' : ''}>Present</option>
                <option value="A"${curr === 'A' ? ' selected' : ''}>Absent</option>
                <option value="L"${curr === 'L' ? ' selected' : ''}>Late</option>
                <option value="C"${curr === 'C' ? ' selected' : ''}>Cutting</option>
                <option value="E"${curr === 'E' ? ' selected' : ''}>Excused</option>
                <option value="O"${curr === 'O' ? ' selected' : ''}>OB</option>
            </select>
        </div>
    `;
}

function renderTable() {
    const tbody = document.getElementById('attTbody');
    if (!tbody) return;

    const q = String(document.getElementById('attSearch')?.value || '').trim().toLowerCase();
    const list = state.roster.filter((r) => {
        if (!q) return true;
        const name = fullName(r).toLowerCase();
        const lrn = String(r.lrn || '').toLowerCase();
        return name.includes(q) || lrn.includes(q);
    });

    if (!state.roster.length) {
        tbody.innerHTML = `
            <tr>
                <td colspan="5" style="padding: 28px; color: var(--gray-600); text-align:center;">${escapeHtml(getEmptyRosterMessage())}</td>
            </tr>
        `;
        renderStats();
        return;
    }

    if (!list.length) {
        tbody.innerHTML = `
            <tr>
                <td colspan="5" style="padding: 28px; color: var(--gray-600); text-align:center;">No results.</td>
            </tr>
        `;
        renderStats();
        return;
    }

    tbody.innerHTML = list.map((r, idx) => {
        const enrollmentId = Number(r.enrollment_id);
        const code = state.att.get(enrollmentId) || 'P';
        const sex = normalizeGender(r.gender);
        const sexShort = sex === 'Male' ? 'M' : sex === 'Female' ? 'F' : (sex ? 'O' : '—');
        return `
            <tr id="row-${enrollmentId}" data-idx="${idx + 1}">
                <td style="text-align:center; color: var(--gray-600);">${idx + 1}</td>
                <td><div class="att-name">${escapeHtml(fullName(r))}</div></td>
                <td><span class="att-lrn">${escapeHtml(r.lrn || '')}</span></td>
                <td><span class="att-sex">${escapeHtml(sexShort)}</span></td>
                <td style="text-align:right;">${buildToggle(enrollmentId, code)}</td>
            </tr>
        `;
    }).join('');

    renderStats();
}

function hasUnsavedChanges() {
    return Boolean(state.dirty);
}

async function confirmDiscardIfDirty() {
    if (!hasUnsavedChanges()) return true;

    if (typeof Swal !== 'undefined' && typeof Swal.fire === 'function') {
        const res = await Swal.fire({
            icon: 'warning',
            title: 'Unsaved changes',
            text: 'You have unsaved changes. Discard them and continue?',
            showCancelButton: true,
            confirmButtonText: 'Discard',
            cancelButtonText: 'Cancel',
        });
        return Boolean(res.isConfirmed);
    }

    return window.confirm('You have unsaved changes. Discard them and continue?');
}

async function loadSectionsAndPeriodsForSY() {
    const elSY = document.getElementById('attSchoolYear');
    const elSection = document.getElementById('attSection');
    const elClass = document.getElementById('attClass');
    const elPeriod = document.getElementById('attPeriod');
    const syId = Number(elSY?.value || 0);

    if (!syId) {
        if (elSection) elSection.innerHTML = '<option value="">— select school year —</option>';
        if (elClass) elClass.innerHTML = '<option value="">— select section first —</option>';
        state.classOfferings = [];
        state.lastSel.syId = 0;
        state.lastSel.sectionId = 0;
        state.lastSel.classId = 0;
        state.lastSel.periodId = 0;
        resetAttendanceState();
        setSaved();
        updateInfoBar();
        renderTable();
        return;
    }

    if (elSection) elSection.innerHTML = '<option value="">Loading...</option>';
    const rows = await sectionsApi.list(syId);
    state.sections = Array.isArray(rows) ? rows : [];
    if (elSection) {
        const opts = state.sections
            .filter(s => Number(s.is_deleted) !== 1)
            .sort((a, b) => String(a.section_name || '').localeCompare(String(b.section_name || '')))
            .map(s => `<option value="${Number(s.section_id)}">${escapeHtml(s.section_name || '')}</option>`)
            .join('');
        elSection.innerHTML = opts
            ? ('<option value="">— select section —</option>' + opts)
            : '<option value="">— no assigned sections —</option>';
    }
    if (elClass) elClass.innerHTML = '<option value="">— select section first —</option>';
    state.classOfferings = [];

    if (elPeriod) {
        const opts = (state.gradingPeriods || [])
            .filter(p => Number(p.is_deleted) !== 1)
            .filter(p => !p.school_year_id || Number(p.school_year_id) === syId)
            .map(p => `<option value="${Number(p.grading_period_id)}">${escapeHtml(p.period_name || '')}</option>`)
            .join('');
        elPeriod.innerHTML = '<option value="">— select period —</option>' + opts;
    }

    state.lastSel.syId = syId;
    state.lastSel.sectionId = 0;
    state.lastSel.classId = 0;
    state.lastSel.periodId = Number(elPeriod?.value || 0);

    resetAttendanceState();
    setSaved();
    updateInfoBar();
    renderTable();
}

async function loadClassOfferingsForSection() {
    const elClass = document.getElementById('attClass');
    const { syId, sectionId } = getSelected();
    const prevClassId = Number(state.lastSel.classId || 0);

    if (!elClass) return;

    if (!syId) {
        state.classOfferings = [];
        elClass.innerHTML = '<option value="">— select school year —</option>';
        state.lastSel.classId = 0;
        updateInfoBar();
        return;
    }

    if (!sectionId) {
        state.classOfferings = [];
        elClass.innerHTML = '<option value="">— select section first —</option>';
        state.lastSel.classId = 0;
        updateInfoBar();
        return;
    }

    elClass.innerHTML = '<option value="">Loading...</option>';

    let rows = [];
    try {
        rows = await classOfferingsApi.list();
    } catch (e) {
        state.classOfferings = [];
        elClass.innerHTML = '<option value="">— failed to load subjects —</option>';
        state.lastSel.classId = 0;
        updateInfoBar();
        await toast('error', e?.response?.data?.message || e?.message || 'Failed to load subjects.');
        return;
    }

    state.classOfferings = (Array.isArray(rows) ? rows : [])
        .filter((row) => Number(row.is_deleted) !== 1)
        .filter((row) => Number(row.section_id) === Number(sectionId))
        .filter((row) => Number(row.school_year_id) === Number(syId))
        .sort((a, b) => {
            const aName = `${a.subject_name || ''} ${a.subject_code || ''}`.trim();
            const bName = `${b.subject_name || ''} ${b.subject_code || ''}`.trim();
            return aName.localeCompare(bName);
        });

    const opts = state.classOfferings.map((row) => {
        const subjectLabel = [row.subject_name, row.subject_code ? `(${row.subject_code})` : ''].filter(Boolean).join(' ');
        return `<option value="${Number(row.class_id)}">${escapeHtml(subjectLabel || `Subject #${Number(row.subject_id || 0)}`)}</option>`;
    }).join('');

    if (!opts) {
        elClass.innerHTML = '<option value="">— no subject assigned —</option>';
        state.lastSel.classId = 0;
        updateInfoBar();
        return;
    }

    elClass.innerHTML = '<option value="">— select subject —</option>' + opts;

    const keepExisting = state.classOfferings.some((row) => Number(row.class_id) === prevClassId);
    if (keepExisting) {
        elClass.value = String(prevClassId);
    } else if (state.classOfferings.length === 1) {
        elClass.value = String(state.classOfferings[0].class_id);
    } else {
        elClass.value = '';
    }

    updateInfoBar();
}

async function loadDailyAttendance() {
    const { syId, sectionId, classId, periodId, date, session } = getSelected();
    updateInfoBar();

    if (!syId || !sectionId || !classId || !periodId || !date) {
        resetAttendanceState();
        renderTable();
        return;
    }

    const tbody = document.getElementById('attTbody');
    if (tbody) {
        tbody.innerHTML = `
            <tr>
                <td colspan="5" style="padding: 28px; color: var(--gray-600); text-align:center;">Loading learners...</td>
            </tr>
        `;
    }

    try {
        const roster = await attendanceApi.roster({ sectionId, schoolYearId: syId });
        state.roster = Array.isArray(roster) ? roster : [];
        state.att = new Map();
        state.roster.forEach(r => state.att.set(Number(r.enrollment_id), 'P'));

        const existing = await attendanceApi.day({ sectionId, schoolYearId: syId, gradingPeriodId: periodId, date, session, classId });
        (Array.isArray(existing) ? existing : []).forEach((a) => {
            const code = STATUS_TO_CODE[String(a.status || '').trim()] || 'P';
            state.att.set(Number(a.enrollment_id), code);
        });

        state.orig = new Map(state.att);
        state.lastSel = { syId, sectionId, classId, periodId, date, session };
        setSaved();
        renderTable();
    } catch (e) {
        const msg = e?.response?.data?.message || e?.message || 'Load failed';
        await toast('error', msg);

        // If schema doesn’t support AM/PM sessions, gracefully fall back to AM.
        if (session === 'PM' && /session|pm/i.test(String(msg))) {
            setSession('AM');
            state.lastSel.session = 'AM';
        }

        resetAttendanceState();
        renderTable();
    }
}

async function saveAll() {
    const { syId, sectionId, classId, periodId, date, session } = getSelected();
    if (!syId || !sectionId || !classId || !periodId || !date) {
        await toast('error', 'Select school year, section, subject, grading period, and date.');
        return;
    }

    const entries = [];
    for (const r of state.roster) {
        const eid = Number(r.enrollment_id);
        const cur = state.att.get(eid) || 'P';
        const prev = state.orig.get(eid) || 'P';
        if (cur === prev) continue;
        entries.push({
            enrollment_id: eid,
            status: CODE_TO_STATUS[cur] || 'Present',
            remarks: null,
        });
    }

    if (!entries.length) {
        await toast('info', 'No changes to save.');
        setSaved();
        return;
    }

    setSaving();
    try {
        const res = await attendanceApi.saveDay({
            sectionId,
            schoolYearId: syId,
            gradingPeriodId: periodId,
            date,
            session,
            classId,
            entries,
        });

        if (res?.success === false) {
            await toast('error', res?.message || 'Save failed');
            return;
        }

        state.orig = new Map(state.att);
        state.dirty = false;
        state.lastSel = { syId, sectionId, classId, periodId, date, session };
        await toast('success', `Saved ${Number(res?.saved || 0)} record(s).`);
        setSaved();
    } catch (e) {
        const msg = e?.response?.data?.message || e?.message || 'Save failed';
        await toast('error', msg);
    } finally {
        clearSaving();
    }
}

function resetChanges() {
    if (!hasUnsavedChanges()) return;
    state.att = new Map(state.orig);
    state.dirty = false;
    renderTable();
    setSaved();
}

function bindEvents() {
    const elSY = document.getElementById('attSchoolYear');
    const elSection = document.getElementById('attSection');
    const elClass = document.getElementById('attClass');
    const elPeriod = document.getElementById('attPeriod');
    const elDate = document.getElementById('attDate');

    if (elSY) elSY.addEventListener('change', async () => {
        const prev = String(state.lastSel.syId || '');
        const ok = await confirmDiscardIfDirty();
        if (!ok) {
            elSY.value = prev;
            return;
        }
        state.dirty = false;
        await loadSectionsAndPeriodsForSY().catch(() => {});
    });

    if (elSection) elSection.addEventListener('change', async () => {
        const prev = String(state.lastSel.sectionId || '');
        const ok = await confirmDiscardIfDirty();
        if (!ok) {
            elSection.value = prev;
            return;
        }
        state.dirty = false;
        state.lastSel.classId = 0;
        await loadClassOfferingsForSection().catch(() => {});
        await loadDailyAttendance().catch(() => {});
    });

    if (elClass) elClass.addEventListener('change', async () => {
        const prev = String(state.lastSel.classId || '');
        const ok = await confirmDiscardIfDirty();
        if (!ok) {
            elClass.value = prev;
            return;
        }
        state.dirty = false;
        await loadDailyAttendance().catch(() => {});
    });

    if (elPeriod) elPeriod.addEventListener('change', async () => {
        const prev = String(state.lastSel.periodId || '');
        const ok = await confirmDiscardIfDirty();
        if (!ok) {
            elPeriod.value = prev;
            return;
        }
        state.dirty = false;
        await loadDailyAttendance().catch(() => {});
    });

    if (elDate) elDate.addEventListener('change', async () => {
        const prev = String(state.lastSel.date || '');
        const ok = await confirmDiscardIfDirty();
        if (!ok) {
            elDate.value = prev;
            return;
        }
        state.dirty = false;
        await loadDailyAttendance().catch(() => {});
    });

    document.getElementById('btnSessAM')?.addEventListener('click', () => {
        (async () => {
            const ok = await confirmDiscardIfDirty();
            if (!ok) {
                setSession(state.lastSel.session);
                return;
            }
            state.dirty = false;
            setSession('AM');
            await loadDailyAttendance().catch(() => {});
        })();
    });

    document.getElementById('btnSessPM')?.addEventListener('click', () => {
        (async () => {
            const ok = await confirmDiscardIfDirty();
            if (!ok) {
                setSession(state.lastSel.session);
                return;
            }
            state.dirty = false;
            setSession('PM');
            await loadDailyAttendance().catch(() => {});
        })();
    });

    document.getElementById('attSearch')?.addEventListener('input', () => renderTable());

    document.getElementById('attTbody')?.addEventListener('change', (e) => {
        const sel = e.target.closest('select.att-select');
        if (!sel) return;
        const eid = Number(sel.dataset.eid || 0);
        const next = String(sel.value || 'P');
        if (!eid) return;

        state.att.set(eid, next);
        setDirty();

        const row = document.getElementById(`row-${eid}`);
        if (row) {
            const idxText = row.dataset.idx || '';
            const r = state.roster.find(x => Number(x.enrollment_id) === eid) || {};
            const sex = normalizeGender(r.gender);
            const sexShort = sex === 'Male' ? 'M' : sex === 'Female' ? 'F' : (sex ? 'O' : '—');
            row.innerHTML = `
                <td style="text-align:center; color: var(--gray-600);">${escapeHtml(idxText)}</td>
                <td><div class="att-name">${escapeHtml(fullName(r))}</div></td>
                <td><span class="att-lrn">${escapeHtml(r.lrn || '')}</span></td>
                <td><span class="att-sex">${escapeHtml(sexShort)}</span></td>
                <td style="text-align:right;">${buildToggle(eid, next)}</td>
            `;
        }
        renderStats();
    });

    document.getElementById('btnAttSaveTop')?.addEventListener('click', () => saveAll().catch(() => {}));
    document.getElementById('btnAttPrint')?.addEventListener('click', () => exportSf2().catch(() => {}));

    window.addEventListener('beforeunload', (e) => {
        if (hasUnsavedChanges()) {
            e.preventDefault();
            e.returnValue = '';
        }
    });
}

async function init() {
    setSaveIndicator('', 'All saved');
    setSession('AM');

    const elSY = document.getElementById('attSchoolYear');
    const elClass = document.getElementById('attClass');
    const elPeriod = document.getElementById('attPeriod');
    const elDate = document.getElementById('attDate');

    if (elDate && !elDate.value) elDate.value = todayStr();
    const date = String(elDate?.value || '').trim();
    state.lastSel.date = date;
    if (elSY) elSY.innerHTML = '<option value="">Loading...</option>';
    if (elClass) elClass.innerHTML = '<option value="">— select section first —</option>';
    if (elPeriod) elPeriod.innerHTML = '<option value="">Loading...</option>';

    const [schoolYears, periods] = await Promise.all([
        schoolYearsApi.list(),
        gradingPeriodsApi.list(),
    ]);

    state.schoolYears = Array.isArray(schoolYears) ? schoolYears : [];
    state.gradingPeriods = Array.isArray(periods) ? periods : [];

    if (elSY) {
        const opts = state.schoolYears.map((sy) => {
            const label = `${sy.year_label || ''}${Number(sy.is_active) === 1 ? ' (active)' : ''}`.trim();
            return `<option value="${Number(sy.school_year_id)}">${escapeHtml(label)}</option>`;
        }).join('');
        elSY.innerHTML = opts || '<option value="">No school years</option>';

        const activeSY = state.schoolYears.find(sy => Number(sy.is_active) === 1);
        if (activeSY) elSY.value = String(activeSY.school_year_id);
        state.lastSel.syId = Number(elSY.value || 0);
    }

    if (elPeriod) {
        const opts = state.gradingPeriods
            .filter(p => Number(p.is_deleted) !== 1)
            .map(p => `<option value="${Number(p.grading_period_id)}">${escapeHtml(p.period_name || '')}</option>`)
            .join('');
        elPeriod.innerHTML = '<option value="">— select period —</option>' + opts;
        state.lastSel.periodId = Number(elPeriod.value || 0);
    }

    await loadSectionsAndPeriodsForSY();
    updateInfoBar();
    renderStats();
    bindEvents();
}

function monthInfoFromDate(dateStr) {
    const d = String(dateStr || '').trim();
    if (!/^\d{4}-\d{2}-\d{2}$/.test(d)) return null;
    const ym = d.slice(0, 7);
    const year = Number(d.slice(0, 4));
    const month = Number(d.slice(5, 7));
    const lastDay = new Date(year, month, 0).getDate();
    const monthLabel = new Date(`${ym}-01T00:00:00`).toLocaleDateString('en-PH', { month: 'long' }).toUpperCase();
    return { ym, year, month, lastDay, monthLabel };
}

function dowShort(yyyyMmDd) {
    const d = new Date(`${yyyyMmDd}T00:00:00`);
    const dow = d.getDay();
    if (dow === 0) return 'SU';
    if (dow === 1) return 'M';
    if (dow === 2) return 'T';
    if (dow === 3) return 'W';
    if (dow === 4) return 'TH';
    if (dow === 5) return 'F';
    return 'S';
}

function isWeekend(yyyyMmDd) {
    const dow = new Date(`${yyyyMmDd}T00:00:00`).getDay();
    return dow === 0 || dow === 6;
}

function countSchoolDays(year, month) {
    const last = new Date(year, month, 0).getDate();
    let c = 0;
    for (let day = 1; day <= last; day++) {
        const dd = String(day).padStart(2, '0');
        const mm = String(month).padStart(2, '0');
        const date = `${year}-${mm}-${dd}`;
        if (!isWeekend(date)) c++;
    }
    return c;
}

function groupRosterByGender(rows) {
    const male = [];
    const female = [];
    const other = [];
    rows.forEach((r) => {
        const g = normalizeGender(r.gender);
        if (g === 'Male') male.push(r);
        else if (g === 'Female') female.push(r);
        else other.push(r);
    });
    const out = [];
    if (male.length) out.push({ key: 'male', label: 'MALE', rows: male });
    if (female.length) out.push({ key: 'female', label: 'FEMALE', rows: female });
    if (other.length) out.push({ key: 'other', label: 'OTHER / NOT SPECIFIED', rows: other });
    return out;
}

function markFromStatuses(statuses) {
    const s = statuses.map(x => String(x || '').trim());
    // Priority: Absent/Cutting > Late > Excused/OB > Present
    if (s.includes('Absent')) return 'X';
    if (s.includes('Cutting')) return 'C';
    if (s.includes('Late')) return 'L';
    if (s.includes('Official Business')) return 'O';
    if (s.includes('Excused')) return 'E';
    return 'P';
}

function isAbsentMark(m) {
    return m === 'X' || m === 'C';
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
        return await blobToDataUrl(await res.blob());
    } catch (_) {
        return null;
    }
}

async function resolveExportLogos() {
    const appBase = (typeof window !== 'undefined' && window.APP_BASE) ? String(window.APP_BASE) : '';
    const leftPath = `${appBase}/assets/img/logo/logo.jpg`;
    const rightPath = `${appBase}/assets/img/logo/pngegg.png`;
    const leftAbs = new URL(leftPath, window.location.origin).toString();
    const rightAbs = new URL(rightPath, window.location.origin).toString();

    const [leftDataUrl, rightDataUrl] = await Promise.all([
        tryFetchAsDataUrl(leftAbs),
        tryFetchAsDataUrl(rightAbs),
    ]);

    return {
        leftLogoUrl: leftDataUrl || leftAbs,
        rightLogoUrl: rightDataUrl || rightAbs,
    };
}

function fileSafe(value) {
    return String(value ?? '')
        .trim()
        .replace(/[\\/:*?"<>|]+/g, '-')
        .replace(/\s+/g, '_')
        .slice(0, 90);
}

async function exportSf2() {
    const { syId, sectionId, classId, periodId, date } = getSelected();
    if (!syId || !sectionId || !classId || !periodId || !date) {
        await toast('error', 'Select school year, section, subject, grading period, and date first.');
        return;
    }

    const mInfo = monthInfoFromDate(date);
    if (!mInfo) {
        await toast('error', 'Invalid date.');
        return;
    }

    const section = state.sections.find(s => Number(s.section_id) === Number(sectionId)) || {};
    const offering = state.classOfferings.find((row) => Number(row.class_id) === Number(classId)) || {};
    const schoolYear = state.schoolYears.find(sy => Number(sy.school_year_id) === Number(syId)) || {};
    const subjectLabel = [offering.subject_name, offering.subject_code ? `(${offering.subject_code})` : ''].filter(Boolean).join(' ') || 'Subject';

    let settingsMap = {};
    try {
        const settingsRes = await schoolSettingsApi.all();
        settingsMap = settingsRes?.map || {};
    } catch {
        settingsMap = {};
    }

    const [roster, monthRows] = await Promise.all([
        attendanceApi.roster({ sectionId, schoolYearId: syId }),
        attendanceApi.month({ sectionId, schoolYearId: syId, gradingPeriodId: periodId, month: mInfo.ym, classId }),
    ]);

    const rosterRows = Array.isArray(roster) ? roster : [];
    const attRows = Array.isArray(monthRows) ? monthRows : [];

    // Build { enrollment_id|date => [statuses...] }
    const key = (eid, d) => `${Number(eid)}|${d}`;
    const statusByKey = new Map();
    attRows.forEach((r) => {
        const k = key(r.enrollment_id, r.attendance_date);
        const arr = statusByKey.get(k) || [];
        arr.push(r.status);
        statusByKey.set(k, arr);
    });

    // Precompute per-day absent counts for summary
    const days = [];
    for (let day = 1; day <= mInfo.lastDay; day++) {
        const dd = String(day).padStart(2, '0');
        const mm = String(mInfo.month).padStart(2, '0');
        const d = `${mInfo.year}-${mm}-${dd}`;
        days.push({ day, date: d, dow: dowShort(d), weekend: isWeekend(d) });
    }

    const groups = groupRosterByGender(rosterRows);
    const allRows = groups.flatMap(g => g.rows);

    const schoolDays = countSchoolDays(mInfo.year, mInfo.month);
    const absentPerDay = (rows) => {
        const out = new Map();
        days.forEach(({ date, weekend }) => {
            if (weekend) {
                out.set(date, 0);
                return;
            }
            let c = 0;
            rows.forEach((lr) => {
                const statuses = statusByKey.get(key(lr.enrollment_id, date)) || [];
                const mark = markFromStatuses(statuses);
                if (isAbsentMark(mark)) c++;
            });
            out.set(date, c);
        });
        return out;
    };

    const absentAll = absentPerDay(allRows);
    const avgDailyAttendance = (() => {
        if (!schoolDays) return 0;
        let sum = 0;
        days.forEach(({ date, weekend }) => {
            if (weekend) return;
            const abs = absentAll.get(date) || 0;
            sum += Math.max(allRows.length - abs, 0);
        });
        return Math.round((sum / schoolDays) * 100) / 100;
    })();

    const pctAttendance = allRows.length ? Math.round(((avgDailyAttendance / allRows.length) * 100) * 100) / 100 : 0;
    const totalAbsentMarks = (() => {
        let t = 0;
        absentAll.forEach((v) => { t += Number(v || 0); });
        return t;
    })();

    // Render
    const schoolId = settingsMap.school_id || settingsMap.schoolId || '';
    const schoolName = settingsMap.school_name || settingsMap.schoolName || '';
    const schoolHead = settingsMap.school_head || settingsMap.school_head_name || settingsMap.principal_name || '';
    const logos = await resolveExportLogos();

    const headHtml = `
        <div class="sf2-header">
            <div class="sf2-logo-wrap">
                <img src="${logos.leftLogoUrl}" alt="DepEd Logo" class="sf2-logo" />
            </div>
            <div class="sf2-header-center">
                <div class="sf2-title">School Form 2 (SF2) Daily Attendance Report of Learners</div>
                <div class="sf2-subtitle">(This replaces Form 1, Form 2 & STS Form 4 - Attendance and Dropped Profile)</div>
            </div>
            <div class="sf2-logo-wrap sf2-logo-wrap-right">
                <img src="${logos.rightLogoUrl}" alt="DepEd Seal" class="sf2-logo" />
            </div>
        </div>

        <div class="sf2-head-grid">
            <div class="sf2-head-row"><span class="lbl">School ID</span><span class="box">${escapeHtml(schoolId)}</span></div>
            <div class="sf2-head-row"><span class="lbl">School Year</span><span class="box">${escapeHtml(schoolYear.year_label || '')}</span></div>
            <div class="sf2-head-row"><span class="lbl">Report for the Month of</span><span class="box">${escapeHtml(mInfo.monthLabel)}</span></div>
            <div class="sf2-head-row span-2"><span class="lbl">Name of School</span><span class="box">${escapeHtml(schoolName)}</span></div>
            <div class="sf2-head-row"><span class="lbl">Grade Level</span><span class="box">${escapeHtml(section.grade_name || '')}</span></div>
            <div class="sf2-head-row"><span class="lbl">Section</span><span class="box">${escapeHtml(section.section_name || '')}</span></div>
            <div class="sf2-head-row span-2"><span class="lbl">Subject</span><span class="box">${escapeHtml(subjectLabel)}</span></div>
        </div>
    `;

    const dayTh = days.map(({ day }) => `<th class="day">${day}</th>`).join('');
    const dowTh = days.map(({ dow, weekend }) => `<th class="dow ${weekend ? 'wk' : ''}">${escapeHtml(dow)}</th>`).join('');

    let idx = 0;
    const renderLearnerRow = (r) => {
        idx++;
        const eid = Number(r.enrollment_id);
        let absent = 0;
        const cells = days.map(({ date, weekend }) => {
            const statuses = statusByKey.get(key(eid, date)) || [];
            const rawMark = markFromStatuses(statuses);
            const mark = rawMark || '';
            if (!weekend && isAbsentMark(mark)) absent++;
            return `<td class="cell ${weekend ? 'wk' : ''}">${escapeHtml(mark)}</td>`;
        }).join('');
        const present = Math.max(schoolDays - absent, 0);
        return `
            <tr>
                <td class="no">${idx}</td>
                <td class="name">${escapeHtml(fullName(r))}</td>
                <td class="lrn">${escapeHtml(r.lrn || '')}</td>
                ${cells}
                <td class="tot">${absent}</td>
                <td class="tot">${present}</td>
                <td class="rem"></td>
            </tr>
        `;
    };

    const renderTotalPerDayRow = (label, rows) => {
        const absMap = absentPerDay(rows);
        const cells = days.map(({ date, weekend }) => {
            const v = weekend ? '' : (absMap.get(date) || 0);
            return `<td class="cell total ${weekend ? 'wk' : ''}">${escapeHtml(v)}</td>`;
        }).join('');
        return `
            <tr class="total-row">
                <td class="no"></td>
                <td class="name" colspan="2">${escapeHtml(label)}</td>
                ${cells}
                <td class="tot"></td>
                <td class="tot"></td>
                <td class="rem"></td>
            </tr>
        `;
    };

    const bodyRows = [];
    groups.forEach((g) => {
        bodyRows.push(`<tr class="group"><td colspan="${3 + days.length + 3}">${escapeHtml(g.label)}</td></tr>`);
        g.rows.forEach(r => bodyRows.push(renderLearnerRow(r)));
        bodyRows.push(renderTotalPerDayRow('TOTAL Per Day  ===>', g.rows));
    });
    if (groups.length) bodyRows.push(renderTotalPerDayRow('Combined Total Per Day', allRows));

    const sf2Html = `
<!doctype html>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>SF2 - ${escapeHtml(section.section_name || '')} - ${escapeHtml(subjectLabel)} - ${escapeHtml(mInfo.monthLabel)}</title>
    <style>
        :root { --b:#000; --g:#f2f2f2; }
        * { box-sizing: border-box; }
        html, body { width: 100%; min-height: 100%; }
        body { font-family: Arial, Helvetica, sans-serif; color:#000; margin: 0; padding: 0; }
        .sf2-sheet { width: 100%; max-width: 100%; min-height: 100%; padding: 4px 6px; }
        .sf2-header { display:flex; align-items:center; justify-content:space-between; gap:6px; margin-bottom: 5px; }
        .sf2-logo-wrap { width: 70px; display:flex; align-items:center; justify-content:flex-start; flex: 0 0 70px; }
        .sf2-logo-wrap-right { justify-content:flex-end; }
        .sf2-logo { height: 48px; width: auto; object-fit: contain; display:block; }
        .sf2-header-center { flex:1; text-align:center; min-width: 0; }
        .sf2-title { text-align:center; font-weight: 800; font-size: 12px; margin-bottom: 2px; line-height: 1.1; }
        .sf2-subtitle { text-align:center; font-size: 7px; margin-bottom: 0; line-height: 1.1; }
        .sf2-head-grid { display:grid; grid-template-columns: 1fr 1fr 1fr; gap: 3px 6px; margin-bottom: 5px; }
        .sf2-head-row { display:flex; align-items:center; gap:4px; font-size: 8px; min-width: 0; }
        .sf2-head-row .lbl { min-width: 82px; }
        .sf2-head-row .box { flex:1; min-width: 0; border:1px solid var(--b); padding: 2px 4px; font-weight: 700; line-height: 1.1; }
        .sf2-head-row.span-2 { grid-column: span 2; }

        .layout { display:grid; grid-template-columns: minmax(0, 1fr) 220px; gap: 6px; align-items:start; width: 100%; }
        table { border-collapse: collapse; width: 100%; table-layout: fixed; }
        th, td { border: 1px solid var(--b); font-size: 6.5px; padding: 1px; vertical-align: middle; line-height: 1.05; }
        th { font-weight: 800; }
        th.day { width: 12px; text-align:center; padding: 0; }
        th.dow { font-size: 6px; text-align:center; padding: 0; }
        td.no { width: 14px; text-align:center; }
        td.name { width: 124px; min-width: 124px; max-width: 124px; font-weight: 700; word-break: break-word; }
        td.lrn { width: 68px; min-width: 68px; max-width: 68px; word-break: break-word; }
        td.cell { width: 12px; height: 12px; text-align:center; padding: 0; font-size: 6px; font-weight: 700; }
        td.tot { width: 26px; text-align:center; font-weight: 800; }
        td.rem { width: 64px; }
        .wk { background: var(--g); }
        .group td { background: #fff; font-weight: 800; text-transform: uppercase; }
        .total-row td { font-weight: 800; }
        .total-row td.name { text-align:right; }

        .sidebox { border:1px solid var(--b); padding: 4px; page-break-inside: avoid; }
        .sidebox h4 { margin: 0 0 3px 0; font-size: 7px; line-height: 1.1; }
        .sidebox p, .sidebox li { margin: 0; font-size: 5.8px; line-height: 1.12; }
        .sidebox ul { padding-left: 10px; margin: 2px 0 0 0; }
        .mt8 { margin-top: 4px; }
        .summary table { width:100%; }
        .summary td, .summary th { font-size: 5.8px; }
        .sign { margin-top: 5px; font-size: 5.8px; }
        .sign .line { border-bottom: 1px solid var(--b); height: 10px; margin-top: 8px; }

        @page {
            size: 14in 8.5in;
            margin: 0.1in;
        }

        @media print {
            html, body { width: 100%; min-height: 100%; }
            body { margin: 0; padding: 0; }
            .sf2-sheet { width: 100%; min-height: 100%; padding: 0; }
        }
    </style>
</head>
<body>
    <div class="sf2-sheet">
    ${headHtml}
    <div class="layout">
        <div>
            <table>
                <thead>
                    <tr>
                        <th rowspan="2">No.</th>
                        <th rowspan="2">NAME<br/><span style="font-weight:600; font-size:9px;">(Last Name, First Name, Middle Name)</span></th>
                        <th rowspan="2">LRN</th>
                        ${dayTh}
                        <th colspan="2">Total for the Month</th>
                        <th rowspan="2">REMARKS</th>
                    </tr>
                    <tr>
                        ${dowTh}
                        <th>ABSENT</th>
                        <th>PRESENT</th>
                    </tr>
                </thead>
                <tbody>
                    ${bodyRows.join('')}
                </tbody>
            </table>
        </div>
        <div>
            <div class="sidebox">
                <h4>REMARKS</h4>
                <p>If NLS, late enrollees, please refer to legend below. If TRANSFERRED OUT, write the name of School.</p>
            </div>
            <div class="sidebox mt8">
                <h4>GUIDELINES</h4>
                <ul>
                    <li>The attendance shall be accomplished daily. Refer to the codes for checking learners' attendance.</li>
                    <li>Dates shall be written in the columns after learner's name.</li>
                    <li>Attendance performance shall be reflected in Form 137 and Form 138 every grading period.</li>
                </ul>
            </div>
	            <div class="sidebox mt8">
	                <h4>1. CODES FOR CHECKING ATTENDANCE</h4>
	                <ul>
	                    <li><b>(blank)</b> Present</li>
	                    <li><b>X</b> Absent</li>
	                    <li><b>L</b> Late</li>
	                    <li><b>C</b> Cutting Classes</li>
	                    <li><b>E</b> Excused</li>
	                    <li><b>O</b> Official Business</li>
	                </ul>
	            </div>
            <div class="sidebox mt8">
                <h4>2. REASONS/CAUSES FOR NLS</h4>
                <ul>
                    <li><b>a. Domestic-related factors</b></li>
                    <li>a.1 Had to take care of siblings</li>
                    <li>a.2 Early marriage/pregnancy</li>
                    <li>a.3 Parents' attitude toward schooling</li>
                    <li>a.4 Family problems</li>
                    <li><b>b. Individual-related factors</b></li>
                    <li>b.1 Illness</li>
                    <li>b.2 Overage</li>
                    <li>b.3 Death</li>
                    <li>b.4 Drug abuse</li>
                    <li>b.5 Poor academic performance</li>
                    <li>b.6 Lack of interest/distractions</li>
                    <li>b.7 Hunger/Malnutrition</li>
                </ul>
            </div>
            <div class="sidebox mt8">
                <h4>SUMMARY</h4>
                <div class="summary">
                    <table>
                        <tr><th style="text-align:left;">Month</th><th style="text-align:center;">No. of Days of School</th></tr>
                        <tr><td>${escapeHtml(mInfo.monthLabel)}</td><td style="text-align:center;">${schoolDays}</td></tr>
                    </table>
                    <table style="margin-top:6px;">
                        <tr><th style="text-align:left;">Summary</th><th style="text-align:center;">TOTAL</th></tr>
                        <tr><td>Enrollment (as of first Friday)</td><td style="text-align:center;">${allRows.length}</td></tr>
                        <tr><td>Late enrollees during the month</td><td style="text-align:center;">0</td></tr>
                        <tr><td>Registered learners as of end of month</td><td style="text-align:center;">${allRows.length}</td></tr>
                        <tr><td>Average Daily Attendance</td><td style="text-align:center;">${avgDailyAttendance}</td></tr>
                        <tr><td>Percentage of Attendance for the month</td><td style="text-align:center;">${pctAttendance}%</td></tr>
                        <tr><td>Number of days absent (total marks)</td><td style="text-align:center;">${totalAbsentMarks}</td></tr>
                        <tr><td>Transferred out</td><td style="text-align:center;">0</td></tr>
                        <tr><td>Transferred in</td><td style="text-align:center;">0</td></tr>
                    </table>
                </div>
                <div class="sign">
                    <div style="margin-top:8px;">I certify that this is a true and correct report.</div>
                    <div class="line"></div>
                    <div style="text-align:center; font-weight:800;">${escapeHtml(section.adviser_name || '')}</div>
                    <div style="text-align:center;">(Signature of Adviser over Printed Name)</div>
                    <div style="margin-top: 10px;">Attested by:</div>
                    <div class="line"></div>
                    <div style="text-align:center; font-weight:800;">${escapeHtml(schoolHead)}</div>
                    <div style="text-align:center;">(Signature of School Head over Printed Name)</div>
                    <div style="text-align:center; margin-top: 10px;">Generated thru LIS</div>
                </div>
            </div>
        </div>
    </div>
    </div>
</body>
</html>
    `;

    const filename = `SF2_${fileSafe(section.section_name || 'Section')}_${fileSafe(subjectLabel)}_${fileSafe(mInfo.monthLabel)}_${mInfo.year}.html`;
    const blob = new Blob([sf2Html], { type: 'text/html;charset=utf-8' });
    const url = URL.createObjectURL(blob);

    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);

    setTimeout(() => URL.revokeObjectURL(url), 1000);

    await toast('success', 'SF2 downloaded: ' + filename);
}

document.addEventListener('DOMContentLoaded', () => {
    init().catch((e) => toast('error', e?.message || 'Attendance init failed'));
});
