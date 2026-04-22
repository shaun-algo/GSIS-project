function coAppBase() {
    if (typeof window.APP_BASE === 'string' && window.APP_BASE !== '') return window.APP_BASE;

    const pathname = String(window.location.pathname || '/');
    let appPrefix = '';
    if (pathname.includes('/dashboard/')) appPrefix = pathname.split('/dashboard/')[0] || '';
    else if (pathname.includes('/pages/')) appPrefix = pathname.split('/pages/')[0] || '';
    else if (pathname.includes('/api/')) appPrefix = pathname.split('/api/')[0] || '';
    else {
        const parts = pathname.split('/').filter(Boolean);
        appPrefix = parts.length ? `/${parts[0]}` : '';
    }
    if (appPrefix === '/') appPrefix = '';

    window.APP_BASE = appPrefix;
    return appPrefix;
}

function coApiBase() {
    return window.API_BASE || `${window.location.origin}${coAppBase()}/api`;
}

function coEscapeHtml(s) {
    return String(s ?? '')
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

function coNotify(message, type = 'info') {
    if (typeof window.showNotification === 'function') {
        window.showNotification(String(message || ''), type);
        return;
    }
    if (typeof window.alert === 'function') {
        window.alert(String(message || ''));
    }
}

const CO_AXIOS = { withCredentials: true };

const classOfferingsApi = {
    getAllClassOfferings: async (params) => axios.get(
        `${coApiBase()}/class_offerings/class_offerings.php`,
        { ...CO_AXIOS, params: { operation: 'getAllClassOfferings', _: Date.now(), ...(params || {}) } }
    ).then(r => r.data),
    getClassOfferingRoster: async (classId) => axios.get(
        `${coApiBase()}/class_offerings/class_offerings.php`,
        { ...CO_AXIOS, params: { operation: 'getClassOfferingRoster', class_id: Number(classId) || 0, _: Date.now() } }
    ).then(r => r.data),
    createClassOffering: async (data) => axios.post(
        `${coApiBase()}/class_offerings/class_offerings.php?operation=createClassOffering`,
        data,
        CO_AXIOS
    ).then(r => r.data),
    deleteClassOffering: async (data) => axios.post(
        `${coApiBase()}/class_offerings/class_offerings.php?operation=deleteClassOffering`,
        data,
        CO_AXIOS
    ).then(r => r.data),
    updateClassOffering: async (data) => axios.post(
        `${coApiBase()}/class_offerings/class_offerings.php?operation=updateClassOffering`,
        data,
        CO_AXIOS
    ).then(r => r.data)
};

const subjectsApi = {
    list: async () => axios.get(
        `${coApiBase()}/subjects/subjects.php`,
        { ...CO_AXIOS, params: { operation: 'getAllSubjects', _: Date.now() } }
    ).then(r => r.data)
};

const gradeLevelsApi = {
    list: async () => axios.get(
        `${coApiBase()}/grade_levels/grade_levels.php`,
        { ...CO_AXIOS, params: { operation: 'getAllGradeLevels', _: Date.now() } }
    ).then(r => r.data)
};

const sectionsApi = {
    listAll: async () => axios.get(
        `${coApiBase()}/sections/sections.php`,
        { ...CO_AXIOS, params: { operation: 'getAllSections', include_all: 1, _: Date.now() } }
    ).then(r => r.data),
    listBySchoolYear: async (schoolYearId) => axios.get(
        `${coApiBase()}/sections/sections.php`,
        { ...CO_AXIOS, params: { operation: 'getAllSections', school_year_id: Number(schoolYearId) || 0, _: Date.now() } }
    ).then(r => r.data)
};

const employeesApi = {
    list: async () => axios.get(
        `${coApiBase()}/employees/employees.php`,
        { ...CO_AXIOS, params: { operation: 'getAllEmployees', _: Date.now() } }
    ).then(r => r.data)
};

const schoolYearsApi = {
    list: async () => axios.get(
        `${coApiBase()}/school_years/school_years.php`,
        { ...CO_AXIOS, params: { operation: 'getAllSchoolYears', _: Date.now() } }
    ).then(r => r.data)
};

const curriculaApi = {
    list: async () => axios.get(
        `${coApiBase()}/curricula/curricula.php`,
        { ...CO_AXIOS, params: { operation: 'getAllCurricula', _: Date.now() } }
    ).then(r => r.data),
    getPrimaryForSchoolYear: async (schoolYearId) => axios.get(
        `${coApiBase()}/curricula/curricula.php`,
        { ...CO_AXIOS, params: { operation: 'getPrimaryCurriculumForSchoolYear', school_year_id: Number(schoolYearId) || 0, _: Date.now() } }
    ).then(r => r.data),
    getSubjects: async (curriculumId) => axios.get(
        `${coApiBase()}/curricula/curricula.php`,
        { ...CO_AXIOS, params: { operation: 'getCurriculumSubjects', curriculum_id: Number(curriculumId) || 0, _: Date.now() } }
    ).then(r => r.data)
};

const authApi = {
    me: async () => axios.get(
        `${coApiBase()}/auth/me.php`,
        { ...CO_AXIOS, params: { _: Date.now() } }
    ).then(r => r.data)
};

document.addEventListener('DOMContentLoaded', () => {
    initTeacherAssignment();
});

function initTeacherAssignment() {
    const pageSubtitle = document.getElementById('pageSubtitle');
    if (pageSubtitle) pageSubtitle.textContent = '';

    const openOverviewBtn = document.getElementById('co-open-overview');
    const openAssignmentBtn = document.getElementById('co-open-assignment');
    const openManagementBtn = document.getElementById('co-open-management');
    const overviewPanel = document.getElementById('coOverviewPanel');
    const assignmentPanel = document.getElementById('coManagePanel');

    const mgrSY = document.getElementById('co-mgr-school-year');
    const mgrSection = document.getElementById('co-mgr-section');
    const mgrGrade = document.getElementById('co-mgr-grade');
    const mgrAdviser = document.getElementById('co-mgr-adviser');
    const mgrStudents = document.getElementById('co-mgr-students');
    const mgrTeacher = document.getElementById('co-mgr-teacher');
    const mgrSubject = document.getElementById('co-mgr-subject');
    const mgrAdd = document.getElementById('co-mgr-add');
    const mgrPendingBody = document.getElementById('co-mgr-pending-body');
    const mgrFinalize = document.getElementById('co-mgr-finalize');

    // Overview elements (optional)
    const ovSY = document.getElementById('co-ov-school-year');
    const ovGrade = document.getElementById('co-ov-grade');
    const ovStatus = document.getElementById('co-ov-status');
    const ovSearch = document.getElementById('co-ov-search');
    const ovGrid = document.getElementById('co-ov-grid');

    const statOfferings = document.getElementById('co-stat-offerings');
    const statSections = document.getElementById('co-stat-sections');
    const statStudents = document.getElementById('co-stat-students');
    const statFull = document.getElementById('co-stat-full');

    const ovKvSubject = document.getElementById('co-ov-kv-subject');
    const ovKvTeacher = document.getElementById('co-ov-kv-teacher');
    const ovKvSection = document.getElementById('co-ov-kv-section');
    const ovKvSy = document.getElementById('co-ov-kv-sy');
    const ovKvCapacity = document.getElementById('co-ov-kv-capacity');
    const ovRosterTitle = document.getElementById('co-ov-roster-title');
    const ovRoster = document.getElementById('co-ov-roster');
    const ovActions = document.getElementById('co-ov-actions');
    const ovDeleteBtn = document.getElementById('co-ov-delete');
    const ovReassignTeacher = document.getElementById('co-ov-reassign-teacher');
    const ovReassignBtn = document.getElementById('co-ov-reassign');

    if (!mgrSY || !mgrSection || !mgrTeacher || !mgrSubject || !mgrPendingBody || !mgrFinalize) return;

    const state = {
        isAdmin: false,
        schoolYears: [],
        sectionsById: new Map(),
        sectionsAllById: new Map(),
        gradeLevelsById: new Map(),
        teachers: [],
        allSubjects: [],
        curricula: [],
        activeCurriculumId: null,
        curriculumSubjects: [],
        subjectOptions: [],
        draft: [],
        requests: [],

        overviewOfferings: [],
        overviewSelectedClassId: 0,
    };

    const setView = (view) => {
        if (!assignmentPanel) return;

        const normalized = (view === 'overview' || view === 'assignment') ? view : 'assignment';
        const canShowOverview = !!overviewPanel;
        const actualView = (normalized === 'overview' && !canShowOverview) ? 'assignment' : normalized;

        const showOverview = actualView === 'overview';
        const showManagement = false;
        const showAssignment = actualView === 'assignment';

        if (overviewPanel) overviewPanel.style.display = showOverview ? '' : 'none';
        assignmentPanel.style.display = showAssignment ? '' : 'none';
        // Request/approval workflow panels were removed.

        const setBtnActive = (btn, active) => {
            if (!btn) return;
            btn.classList.toggle('btn-primary', !!active);
            btn.classList.toggle('btn-outline', !active);
        };

        setBtnActive(openOverviewBtn, showOverview);
        setBtnActive(openAssignmentBtn, showAssignment);
        setBtnActive(openManagementBtn, false);

        if (pageSubtitle) {
            pageSubtitle.textContent = '';
        }
    };

    const overviewHasDom = !!(overviewPanel && ovSY && ovGrade && ovStatus && ovSearch && ovGrid);

    const getSectionMeta = (sectionId) => {
        const sid = Number(sectionId || 0);
        if (!sid) return null;
        return state.sectionsAllById.get(sid) || state.sectionsById.get(sid) || null;
    };

    const offeringSearchText = (off) => {
        const sec = getSectionMeta(off?.section_id);
        const parts = [
            sec?.section_name,
            sec?.grade_name,
            off?.subject_name,
            off?.subject_code,
            off?.teacher_name,
            off?.year_label,
        ].filter(Boolean);
        return parts.join(' ').toLowerCase();
    };

    const applyOverviewFilters = () => {
        const syId = Number(ovSY?.value || 0);
        const gradeId = Number(ovGrade?.value || 0);
        const status = String(ovStatus?.value || '').trim();
        const q = String(ovSearch?.value || '').trim().toLowerCase();

        const list = Array.isArray(state.overviewOfferings) ? state.overviewOfferings : [];
        return list.filter((o) => {
            if (syId && Number(o.school_year_id || 0) !== syId) return false;

            const sec = getSectionMeta(o.section_id);
            if (gradeId && Number(sec?.grade_level_id || 0) !== gradeId) return false;

            const isFull = Number(sec?.is_full || 0) === 1;
            if (status === 'with_slots' && isFull) return false;
            if (status === 'full' && !isFull) return false;

            if (q) {
                if (!offeringSearchText(o).includes(q)) return false;
            }
            return true;
        });
    };

    const renderOverviewStats = (rows) => {
        if (!statOfferings || !statSections || !statStudents || !statFull) return;
        const list = Array.isArray(rows) ? rows : [];

        const sectionIds = new Set();
        list.forEach((o) => {
            const sid = Number(o.section_id || 0);
            if (sid) sectionIds.add(sid);
        });

        let studentSum = 0;
        let fullCount = 0;
        sectionIds.forEach((sid) => {
            const sec = getSectionMeta(sid);
            const enrolled = Number(sec?.enrolled_count ?? sec?.students_count ?? 0) || 0;
            studentSum += enrolled;
            if (Number(sec?.is_full || 0) === 1) fullCount += 1;
        });

        statOfferings.textContent = String(list.length);
        statSections.textContent = String(sectionIds.size);
        statStudents.textContent = String(studentSum);
        statFull.textContent = String(fullCount);
    };

    const pillHtmlForSection = (sec) => {
        if (!sec) return '<span class="co-pill warning">Unknown</span>';
        const isFull = Number(sec.is_full || 0) === 1;
        if (isFull) return '<span class="co-pill warning">Full</span>';
        return '<span class="co-pill success">With slots</span>';
    };

    const setOverviewSelectedCard = (classId) => {
        const cid = Number(classId || 0);
        state.overviewSelectedClassId = cid;
        if (!ovGrid) return;
        ovGrid.querySelectorAll('.co-card').forEach((el) => {
            const elId = Number(el.getAttribute('data-class-id') || 0);
            el.classList.toggle('selected', elId === cid);
        });
    };

    const renderOverviewGrid = (rows) => {
        if (!ovGrid) return;
        const list = Array.isArray(rows) ? rows : [];

        if (!list.length) {
            ovGrid.innerHTML = '<div class="co-card" style="cursor:default;"><div style="color:var(--gray-600); font-weight:800;">No offerings found.</div><div class="co-meta">Try adjusting filters or search terms.</div></div>';
            return;
        }

        ovGrid.innerHTML = list.map((o) => {
            const sec = getSectionMeta(o.section_id);
            const subjectName = String(o.subject_name || '—');
            const subjectCode = String(o.subject_code || '').trim();
            const teacherName = String(o.teacher_name || '—');
            const yearLabel = String(o.year_label || '—');
            const sectionName = sec?.section_name || o.section_name || '—';
            const gradeName = sec?.grade_name || '—';

            const maxCap = Number(sec?.max_capacity ?? 0) || 0;
            const enrolled = Number(sec?.enrolled_count ?? sec?.students_count ?? 0) || 0;
            const pct = maxCap > 0 ? Math.max(0, Math.min(100, Math.round((enrolled / maxCap) * 100))) : 0;

            const title = subjectCode ? `${subjectName} (${subjectCode})` : subjectName;
            const capacityText = (maxCap > 0) ? `${enrolled}/${maxCap} (${pct}%)` : (enrolled ? `${enrolled} enrolled` : '—');

            return `
                <div class="co-card" data-class-id="${Number(o.class_id || 0)}">
                    <div class="co-card-top">
                        <div>
                            <p class="co-subject">${coEscapeHtml(title)}</p>
                            <div class="co-meta">${coEscapeHtml(`${gradeName} • ${sectionName}`)}</div>
                            <div class="co-meta">${coEscapeHtml(teacherName)} • ${coEscapeHtml(yearLabel)}</div>
                        </div>
                        <div>${pillHtmlForSection(sec)}</div>
                    </div>

                    <div class="co-progress">
                        <div class="co-progress-row">
                            <span>Capacity</span>
                            <span>${coEscapeHtml(capacityText)}</span>
                        </div>
                        <div class="co-bar"><div style="width:${pct}%;"></div></div>
                    </div>
                </div>
            `;
        }).join('');

        if (state.overviewSelectedClassId) {
            setOverviewSelectedCard(state.overviewSelectedClassId);
        }
    };

    const setOverviewDetail = (off) => {
        const o = off || null;
        const sec = o ? getSectionMeta(o.section_id) : null;

        if (ovKvSubject) {
            const sn = String(o?.subject_name || '—');
            const sc = String(o?.subject_code || '').trim();
            ovKvSubject.textContent = sc ? `${sn} (${sc})` : sn;
        }
        if (ovKvTeacher) ovKvTeacher.textContent = String(o?.teacher_name || '—');
        if (ovKvSection) {
            const gradeName = String(sec?.grade_name || '—');
            const sectionName = String(sec?.section_name || o?.section_name || '—');
            ovKvSection.textContent = `${gradeName} • ${sectionName}`;
        }
        if (ovKvSy) ovKvSy.textContent = String(o?.year_label || '—');

        if (ovKvCapacity) {
            const maxCap = Number(sec?.max_capacity ?? 0) || 0;
            const enrolled = Number(sec?.enrolled_count ?? 0) || 0;
            ovKvCapacity.textContent = maxCap > 0 ? `${enrolled}/${maxCap}` : '—';
        }

        if (ovActions) {
            ovActions.style.display = (state.isAdmin && !!o) ? '' : 'none';
        }

        if (ovReassignTeacher) {
            if (!state.isAdmin || !o) {
                ovReassignTeacher.innerHTML = '<option value="">—</option>';
            } else {
                ovReassignTeacher.innerHTML = teacherOptionsHtml(Number(o.teacher_id || 0));
            }
        }

        if (ovRosterTitle) ovRosterTitle.textContent = 'Section roster (0)';
        if (ovRoster) {
            ovRoster.innerHTML = '<div class="co-roster-item" style="color:var(--gray-600); font-weight:700;">Select an offering to load roster.</div>';
        }
    };

    const deleteSelectedOffering = async () => {
        if (!state.isAdmin) {
            coNotify('Only admins can delete offerings.', 'error');
            return;
        }

        const classId = Number(state.overviewSelectedClassId || 0);
        if (!classId) {
            coNotify('Select an offering first.', 'info');
            return;
        }

        if (typeof Swal !== 'undefined' && Swal && typeof Swal.fire === 'function') {
            const confirm = await Swal.fire({
                title: 'Delete this offering?',
                text: 'This will remove the assigned offering. You can re-encode it afterward if needed.',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Delete',
            });
            if (!confirm.isConfirmed) return;
        } else {
            const ok = window.confirm('Delete this offering?');
            if (!ok) return;
        }

        if (ovDeleteBtn) ovDeleteBtn.disabled = true;
        try {
            const res = await classOfferingsApi.deleteClassOffering({ class_id: classId });
            if (res?.success === false) {
                coNotify(res?.message || 'Unable to delete offering.', 'error');
                return;
            }

            coNotify(res?.message || 'Offering deleted.', 'success');

            try {
                const rows = await classOfferingsApi.getAllClassOfferings();
                state.overviewOfferings = Array.isArray(rows) ? rows : [];
            } catch {
                // ignore refresh errors
            }

            state.overviewSelectedClassId = 0;
            setOverviewSelectedCard(0);
            setOverviewDetail(null);
            refreshOverview();
        } catch (e) {
            const msg = e?.response?.data?.message || e?.message || 'Unable to delete offering.';
            coNotify(msg, 'error');
        } finally {
            if (ovDeleteBtn) ovDeleteBtn.disabled = false;
        }
    };

    const reassignSelectedOfferingTeacher = async () => {
        if (!state.isAdmin) {
            coNotify('Only admins can reassign offerings.', 'error');
            return;
        }

        const classId = Number(state.overviewSelectedClassId || 0);
        if (!classId) {
            coNotify('Select an offering first.', 'info');
            return;
        }

        const offering = (Array.isArray(state.overviewOfferings) ? state.overviewOfferings : [])
            .find(o => Number(o.class_id || 0) === classId);
        if (!offering) {
            coNotify('Unable to find selected offering.', 'error');
            return;
        }

        const teacherId = Number(ovReassignTeacher?.value || 0);
        if (!teacherId) {
            coNotify('Select a teacher first.', 'error');
            return;
        }

        if (teacherId === Number(offering.teacher_id || 0)) {
            coNotify('Teacher is unchanged.', 'info');
            return;
        }

        if (typeof Swal !== 'undefined' && Swal && typeof Swal.fire === 'function') {
            const confirm = await Swal.fire({
                title: 'Save new teacher?',
                text: 'This updates the existing offering and keeps related grades/schedules intact.',
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Save',
            });
            if (!confirm.isConfirmed) return;
        }

        if (ovReassignBtn) ovReassignBtn.disabled = true;
        try {
            const payload = {
                class_id: Number(offering.class_id || 0),
                subject_id: Number(offering.subject_id || 0),
                section_id: Number(offering.section_id || 0),
                school_year_id: Number(offering.school_year_id || 0),
                teacher_id: teacherId,
            };

            const res = await classOfferingsApi.updateClassOffering(payload);
            if (res?.success === false) {
                coNotify(res?.message || 'Unable to update offering teacher.', 'error');
                return;
            }

            coNotify(res?.message || 'Offering updated.', 'success');

            try {
                const rows = await classOfferingsApi.getAllClassOfferings();
                state.overviewOfferings = Array.isArray(rows) ? rows : [];
            } catch {
                // ignore refresh errors
            }

            const updated = (Array.isArray(state.overviewOfferings) ? state.overviewOfferings : [])
                .find(o => Number(o.class_id || 0) === classId);
            setOverviewSelectedCard(classId);
            setOverviewDetail(updated || null);
            refreshOverview();
        } catch (e) {
            const msg = e?.response?.data?.message || e?.message || 'Unable to update offering teacher.';
            coNotify(msg, 'error');
        } finally {
            if (ovReassignBtn) ovReassignBtn.disabled = false;
        }
    };

    const renderRoster = (rosterRows) => {
        const list = Array.isArray(rosterRows) ? rosterRows : [];
        if (ovRosterTitle) ovRosterTitle.textContent = `Section roster (${list.length})`;
        if (!ovRoster) return;

        if (!list.length) {
            ovRoster.innerHTML = '<div class="co-roster-item" style="color:var(--gray-600); font-weight:700;">No enrolled learners found in this section.</div>';
            return;
        }

        ovRoster.innerHTML = list.map((r) => {
            const name = String(r.learner_name || '—');
            const lrn = String(r.lrn || '').trim();
            return `
                <div class="co-roster-item">
                    <div class="co-roster-name">${coEscapeHtml(name)}</div>
                    <div class="co-roster-lrn">${coEscapeHtml(lrn ? `LRN: ${lrn}` : '')}</div>
                </div>
            `;
        }).join('');
    };

    const loadRosterForOffering = async (classId) => {
        const cid = Number(classId || 0);
        if (!cid) return;

        if (ovRosterTitle) ovRosterTitle.textContent = 'Section roster (loading...)';
        if (ovRoster) {
            ovRoster.innerHTML = '<div class="co-roster-item" style="color:var(--gray-600); font-weight:700;">Loading roster...</div>';
        }

        try {
            const res = await classOfferingsApi.getClassOfferingRoster(cid);
            if (res?.success === false) {
                const msg = String(res?.message || 'Unable to load roster.');
                if (ovRosterTitle) ovRosterTitle.textContent = 'Section roster (error)';
                if (ovRoster) ovRoster.innerHTML = `<div class="co-roster-item" style="color:var(--gray-600); font-weight:700;">${coEscapeHtml(msg)}</div>`;
                return;
            }

            renderRoster(res?.roster);
        } catch (e) {
            const msg = e?.response?.data?.message || e?.message || 'Unable to load roster.';
            if (ovRosterTitle) ovRosterTitle.textContent = 'Section roster (error)';
            if (ovRoster) ovRoster.innerHTML = `<div class="co-roster-item" style="color:var(--gray-600); font-weight:700;">${coEscapeHtml(msg)}</div>`;
        }
    };

    const refreshOverview = () => {
        if (!overviewHasDom) return;
        const filtered = applyOverviewFilters();
        renderOverviewStats(filtered);
        renderOverviewGrid(filtered);
    };

    const pickActiveCurriculumId = () => {
        const active = (state.curricula || []).find(c => Number(c.is_active) === 1);
        return Number((active || state.curricula[0] || {}).curriculum_id || 0) || null;
    };

    const teacherOptionsHtml = (selectedTeacherId = 0) => {
        const opts = ['<option value="">— select teacher —</option>'];
        (state.teachers || []).forEach((e) => {
            const id = Number(e.employee_id || 0);
            const name = `${e.last_name || ''}, ${e.first_name || ''}`.replace(/^,\s*/, '').trim();
            const pos = String(e.position_name || '').trim();
            const label = pos ? `${name} (${pos})` : name;
            const selected = id === Number(selectedTeacherId || 0) ? ' selected' : '';
            opts.push(`<option value="${id}"${selected}>${coEscapeHtml(label)}</option>`);
        });
        return opts.join('');
    };

    const subjectOptionsHtml = (selectedSubjectId = 0) => {
        const opts = ['<option value="">— select subject —</option>'];
        (state.subjectOptions || []).forEach((s) => {
            const sid = Number(s.subject_id || 0);
            const code = String(s.subject_code || '').trim();
            const name = String(s.subject_name || '').trim();
            const label = code ? `${name} (${code})` : name;
            const selected = sid === Number(selectedSubjectId || 0) ? ' selected' : '';
            opts.push(`<option value="${sid}"${selected}>${coEscapeHtml(label)}</option>`);
        });
        return opts.join('');
    };

    const setContextEmpty = (msg) => {
        if (mgrGrade) mgrGrade.textContent = '—';
        if (mgrAdviser) mgrAdviser.textContent = '—';
        if (mgrStudents) mgrStudents.textContent = '—';
        state.subjectOptions = [];
        mgrSubject.innerHTML = `<option value="">${coEscapeHtml(msg || 'Select school year and section first.')}</option>`;
    };

    const renderDraft = () => {
        if (!state.draft.length) {
            mgrPendingBody.innerHTML = '<tr><td colspan="4" style="color:var(--gray-600)">No queued assignments yet.</td></tr>';
            return;
        }

        mgrPendingBody.innerHTML = state.draft.map((r, idx) => {
            const subject = (state.subjectOptions || []).find(s => Number(s.subject_id) === Number(r.subject_id)) || {};
            const teacher = (state.teachers || []).find(t => Number(t.employee_id) === Number(r.teacher_id)) || {};
            const teacherName = `${teacher.last_name || ''}, ${teacher.first_name || ''}`.replace(/^,\s*/, '').trim() || '—';
            const subjectLabel = `${subject.subject_name || `Subject #${Number(r.subject_id)}`}${subject.subject_code ? ` (${subject.subject_code})` : ''}`;

            return `
                <tr>
                    <td style="color:var(--gray-600); font-weight:700;">${idx + 1}</td>
                    <td>${coEscapeHtml(subjectLabel)}</td>
                    <td>${coEscapeHtml(teacherName)}</td>
                    <td>
                        <button type="button" class="btn btn-outline" data-action="remove" data-idx="${idx}">Remove</button>
                    </td>
                </tr>
            `;
        }).join('');
    };

    const resetDraft = () => {
        state.draft = [];
        renderDraft();
    };

    const refreshSectionContext = () => {
        const sectionId = Number(mgrSection.value || 0);
        const section = state.sectionsById.get(sectionId) || null;
        const glId = Number(section?.grade_level_id || 0);
        const gradeName = section?.grade_name || state.gradeLevelsById.get(glId)?.grade_name || '—';
        const adviserName = section?.adviser_name || section?.section_adviser || '—';
        const students = section?.enrolled_count ?? section?.students_count ?? section?.student_count ?? section?.enrollment_count;

        if (mgrGrade) mgrGrade.textContent = String(gradeName || '—');
        if (mgrAdviser) mgrAdviser.textContent = String(adviserName || '—');
        if (mgrStudents) mgrStudents.textContent = (students === undefined || students === null || students === '') ? '—' : String(students);

        return section;
    };

    const ensureCurriculumForSchoolYear = async (schoolYearId) => {
        const syId = Number(schoolYearId || 0);
        if (!syId) {
            state.activeCurriculumId = pickActiveCurriculumId();
            return;
        }

        try {
            const res = await curriculaApi.getPrimaryForSchoolYear(syId);
            const mapped = Number(res?.data?.curriculum_id || 0);
            state.activeCurriculumId = mapped || pickActiveCurriculumId();
        } catch {
            state.activeCurriculumId = pickActiveCurriculumId();
        }
    };

    const loadSections = async () => {
        const syId = Number(mgrSY.value || 0);
        if (!syId) {
            mgrSection.innerHTML = '<option value="">— select school year first —</option>';
            setContextEmpty('Select school year first.');
            resetDraft();
            return;
        }

        mgrSection.innerHTML = '<option value="">Loading sections...</option>';
        try {
            const rows = await sectionsApi.listBySchoolYear(syId);
            const list = (Array.isArray(rows) ? rows : [])
                .filter(r => Number(r.is_deleted) !== 1)
                .sort((a, b) => String(a.section_name || '').localeCompare(String(b.section_name || '')));

            state.sectionsById = new Map();
            list.forEach((r) => state.sectionsById.set(Number(r.section_id), r));

            if (!list.length) {
                mgrSection.innerHTML = '<option value="">No sections found</option>';
                setContextEmpty('No sections found for this school year.');
                resetDraft();
                return;
            }

            mgrSection.innerHTML = '<option value="">— select section —</option>' + list
                .map(r => `<option value="${Number(r.section_id)}">${coEscapeHtml(r.section_name || '')}</option>`)
                .join('');

            setContextEmpty('Select section to load subjects.');
            resetDraft();
        } catch {
            mgrSection.innerHTML = '<option value="">Unable to load sections</option>';
            setContextEmpty('Unable to load sections.');
            resetDraft();
        }
    };

    const loadSubjectsForSection = async () => {
        const section = refreshSectionContext();
        const gradeId = Number(section?.grade_level_id || 0);
        if (!gradeId) {
            setContextEmpty('No grade mapping found for this section.');
            resetDraft();
            return;
        }

        try {
            const curriculumId = Number(state.activeCurriculumId || 0);
            let curriculumRows = [];
            if (curriculumId > 0) {
                const rows = await curriculaApi.getSubjects(curriculumId);
                curriculumRows = Array.isArray(rows) ? rows : [];
            }

            state.curriculumSubjects = curriculumRows;
            const subjectIds = curriculumRows
                .filter(r => Number(r.grade_level_id) === gradeId)
                .map(r => Number(r.subject_id))
                .filter(id => Number.isFinite(id) && id > 0);

            const subjectById = new Map((state.allSubjects || []).map(s => [Number(s.subject_id), s]));
            const unique = Array.from(new Set(subjectIds));
            state.subjectOptions = unique
                .map((sid) => {
                    const s = subjectById.get(Number(sid)) || {};
                    return {
                        subject_id: Number(sid),
                        subject_name: s.subject_name || `Subject #${sid}`,
                        subject_code: s.subject_code || '',
                    };
                })
                .sort((a, b) => String(a.subject_name || '').localeCompare(String(b.subject_name || '')));

            if (!state.subjectOptions.length) {
                setContextEmpty('No curriculum subjects found for this section grade.');
                resetDraft();
                return;
            }

            mgrSubject.innerHTML = subjectOptionsHtml(0);
            resetDraft();
        } catch (e) {
            const msg = e?.response?.data?.message || e?.message || 'Unable to load subjects for this section.';
            setContextEmpty(msg);
            resetDraft();
            coNotify(msg, 'error');
        }
    };

    const addDraftItem = () => {
        const sectionId = Number(mgrSection.value || 0);
        const teacherId = Number(mgrTeacher.value || 0);
        const subjectId = Number(mgrSubject.value || 0);
        if (!sectionId) {
            coNotify('Select section first.', 'error');
            return;
        }
        if (!teacherId || !subjectId) {
            coNotify('Select teacher and subject first.', 'error');
            return;
        }

        const idx = state.draft.findIndex(x => Number(x.subject_id) === subjectId);
        if (idx >= 0) {
            state.draft[idx].teacher_id = teacherId;
            renderDraft();
            coNotify('Queued assignment updated for selected subject.', 'info');
            return;
        }

        state.draft.push({ subject_id: subjectId, teacher_id: teacherId });
        renderDraft();
        coNotify('Added to queue.', 'success');
    };

    const finalizeDraft = async () => {
        const sectionId = Number(mgrSection.value || 0);
        const schoolYearId = Number(mgrSY.value || 0);
        if (!schoolYearId || !sectionId) {
            coNotify('Select school year and section first.', 'error');
            return;
        }
        if (!state.draft.length) {
            coNotify('No queued assignments to save.', 'info');
            return;
        }

        mgrFinalize.disabled = true;
        mgrFinalize.textContent = 'Saving...';
        try {
            const results = [];
            for (const row of state.draft) {
                const payload = {
                    section_id: sectionId,
                    school_year_id: schoolYearId,
                    subject_id: Number(row.subject_id),
                    teacher_id: Number(row.teacher_id),
                };

                try {
                    const res = await classOfferingsApi.createClassOffering(payload);
                    if (res?.success === false) {
                        results.push({ ok: false, message: String(res?.message || 'Unable to save assignment.') });
                    } else {
                        results.push({ ok: true, message: String(res?.message || 'Saved') });
                    }
                } catch (e) {
                    const msg = e?.response?.data?.message || e?.message || 'Unable to save assignment.';
                    results.push({ ok: false, message: String(msg) });
                }
            }

            const okCount = results.filter(r => r.ok).length;
            const failCount = results.length - okCount;

            if (typeof Swal !== 'undefined' && Swal && typeof Swal.fire === 'function') {
                if (failCount === 0) {
                    await Swal.fire({
                        icon: 'success',
                        title: 'Saved',
                        text: 'Assignments were saved successfully.',
                        confirmButtonText: 'OK',
                    });
                } else {
                    const firstErr = results.find(r => !r.ok)?.message || 'Some rows failed.';
                    await Swal.fire({
                        icon: 'warning',
                        title: 'Partially Saved',
                        text: `${okCount} saved, ${failCount} failed. ${firstErr}`,
                        confirmButtonText: 'OK',
                    });
                }
            } else {
                coNotify(
                    failCount === 0 ? 'Assignments saved.' : `${okCount} saved, ${failCount} failed.`,
                    failCount === 0 ? 'success' : 'warning'
                );
            }

            resetDraft();

            if (overviewHasDom) {
                try {
                    const rows = await classOfferingsApi.getAllClassOfferings();
                    state.overviewOfferings = Array.isArray(rows) ? rows : [];
                    refreshOverview();
                } catch {
                    // ignore refresh errors
                }
            }
        } catch (e) {
            const msg = e?.response?.data?.message || e?.message || 'Failed to save assignments.';
            coNotify(msg, 'error');
        } finally {
            mgrFinalize.disabled = false;
            mgrFinalize.textContent = 'Save assignments';
        }
    };

    const loadInitialData = async () => {
        try {
            try {
                const me = await authApi.me();
                const roleId = Number(me?.data?.role_id || 0);
                state.isAdmin = roleId === 8;
            } catch {
                state.isAdmin = false;
            }

            if (!state.isAdmin) {
                if (openAssignmentBtn) openAssignmentBtn.style.display = 'none';
                if (assignmentPanel) assignmentPanel.style.display = 'none';
                setView('overview');
            }

            mgrSY.innerHTML = '<option value="">Loading...</option>';
            mgrTeacher.innerHTML = '<option value="">Loading...</option>';
            mgrSubject.innerHTML = '<option value="">Loading...</option>';

            const [schoolYears, sectionsDummy, gradeLevels, teachers, subjects, curricula] = await Promise.all([
                schoolYearsApi.list(),
                Promise.resolve([]),
                gradeLevelsApi.list(),
                employeesApi.list(),
                subjectsApi.list(),
                curriculaApi.list(),
            ]);
            void sectionsDummy;

            state.schoolYears = Array.isArray(schoolYears) ? schoolYears : [];
            state.gradeLevelsById = new Map((Array.isArray(gradeLevels) ? gradeLevels : []).map(gl => [Number(gl.grade_level_id), gl]));
            state.teachers = Array.isArray(teachers) ? teachers : [];
            state.allSubjects = Array.isArray(subjects) ? subjects : [];
            state.curricula = Array.isArray(curricula) ? curricula : [];
            state.activeCurriculumId = pickActiveCurriculumId();

            const syOpts = state.schoolYears.map((sy) => {
                const label = `${sy.year_label || ''}${Number(sy.is_active) === 1 ? ' (active)' : ''}`.trim();
                return `<option value="${Number(sy.school_year_id)}">${coEscapeHtml(label)}</option>`;
            }).join('');
            mgrSY.innerHTML = '<option value="">— select school year —</option>' + syOpts;

            if (overviewHasDom && ovSY) {
                ovSY.innerHTML = '<option value="">All school years</option>' + syOpts;
            }

            if (overviewHasDom && ovGrade) {
                const gradeOpts = Array.from(state.gradeLevelsById.values())
                    .sort((a, b) => String(a.grade_name || '').localeCompare(String(b.grade_name || '')))
                    .map((gl) => `<option value="${Number(gl.grade_level_id)}">${coEscapeHtml(gl.grade_name || '')}</option>`)
                    .join('');
                ovGrade.innerHTML = '<option value="">All grade levels</option>' + gradeOpts;
            }

            const activeSY = state.schoolYears.find(sy => Number(sy.is_active) === 1);
            if (activeSY) mgrSY.value = String(activeSY.school_year_id);
            if (overviewHasDom && activeSY && ovSY) ovSY.value = String(activeSY.school_year_id);

            mgrTeacher.innerHTML = teacherOptionsHtml(0);
            setContextEmpty('Select school year and section first.');
            renderDraft();

            await ensureCurriculumForSchoolYear(Number(mgrSY.value || 0));
            await loadSections();

            if (overviewHasDom) {
                const extras = await Promise.allSettled([
                    classOfferingsApi.getAllClassOfferings(),
                    sectionsApi.listAll(),
                ]);

                const offeringsRes = extras[0];
                const sectionsRes = extras[1];

                state.overviewOfferings = (offeringsRes.status === 'fulfilled' && Array.isArray(offeringsRes.value)) ? offeringsRes.value : [];
                const allSections = (sectionsRes.status === 'fulfilled' && Array.isArray(sectionsRes.value)) ? sectionsRes.value : [];
                state.sectionsAllById = new Map(allSections
                    .filter(r => Number(r.is_deleted) !== 1)
                    .map(r => [Number(r.section_id), r]));

                setOverviewDetail(null);
                refreshOverview();
            }
        } catch (e) {
            const msg = e?.response?.data?.message || e?.message || 'Unable to load teacher assignment data.';
            coNotify(msg, 'error');
        }
    };

    mgrSY.addEventListener('change', async () => {
        await ensureCurriculumForSchoolYear(Number(mgrSY.value || 0));
        await loadSections();
    });

    mgrSection.addEventListener('change', () => {
        void loadSubjectsForSection();
    });

    mgrAdd.addEventListener('click', addDraftItem);

    mgrPendingBody.addEventListener('click', (e) => {
        const btn = e.target.closest('button[data-action="remove"]');
        if (!btn) return;
        const idx = Number(btn.dataset.idx || -1);
        if (idx < 0 || idx >= state.draft.length) return;
        state.draft.splice(idx, 1);
        renderDraft();
    });

    mgrFinalize.addEventListener('click', () => {
        void finalizeDraft();
    });

    if (openOverviewBtn) {
        openOverviewBtn.addEventListener('click', () => {
            setView('overview');
            refreshOverview();
        });
    }

    if (openAssignmentBtn) {
        openAssignmentBtn.addEventListener('click', () => setView('assignment'));
    }

    if (overviewHasDom) {
        setView('overview');
    } else {
        setView('assignment');
    }

    if (overviewHasDom) {
        const onOverviewFilterChange = () => refreshOverview();
        ovSY?.addEventListener('change', onOverviewFilterChange);
        ovGrade?.addEventListener('change', onOverviewFilterChange);
        ovStatus?.addEventListener('change', onOverviewFilterChange);
        ovSearch?.addEventListener('input', onOverviewFilterChange);

        ovGrid.addEventListener('click', (evt) => {
            const card = evt.target.closest('.co-card');
            if (!card) return;
            const cid = Number(card.getAttribute('data-class-id') || 0);
            if (!cid) return;

            const offering = (Array.isArray(state.overviewOfferings) ? state.overviewOfferings : [])
                .find(o => Number(o.class_id || 0) === cid);

            setOverviewSelectedCard(cid);
            setOverviewDetail(offering || null);
            void loadRosterForOffering(cid);
        });
    }

    if (ovDeleteBtn) {
        ovDeleteBtn.addEventListener('click', () => {
            void deleteSelectedOffering();
        });
    }

    if (ovReassignBtn) {
        ovReassignBtn.addEventListener('click', () => {
            void reassignSelectedOfferingTeacher();
        });
    }

    void loadInitialData();
}
