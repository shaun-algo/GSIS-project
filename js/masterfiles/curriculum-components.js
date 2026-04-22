// Curriculum Components page controller

(function () {
    const els = {
        curriculumSelect: () => document.getElementById('curriculumSelect'),
        statusText: () => document.getElementById('statusText'),
        reloadBtn: () => document.getElementById('reloadBtn'),

        gradeLevelsBody: () => document.getElementById('gradeLevelsBody'),
        subjectsBody: () => document.getElementById('subjectsBody'),
        componentsBody: () => document.getElementById('componentsBody'),
        marksBody: () => document.getElementById('marksBody'),
        mapBody: () => document.getElementById('mapBody'),

        addGradeLevelRowBtn: () => document.getElementById('addGradeLevelRowBtn'),
        saveGradeLevelsBtn: () => document.getElementById('saveGradeLevelsBtn'),

        addSubjectRowBtn: () => document.getElementById('addSubjectRowBtn'),
        saveSubjectsBtn: () => document.getElementById('saveSubjectsBtn'),

        addComponentRowBtn: () => document.getElementById('addComponentRowBtn'),
        saveComponentsBtn: () => document.getElementById('saveComponentsBtn'),

        addMarkRowBtn: () => document.getElementById('addMarkRowBtn'),
        saveMarksBtn: () => document.getElementById('saveMarksBtn'),

        addMapRowBtn: () => document.getElementById('addMapRowBtn'),
        saveMapBtn: () => document.getElementById('saveMapBtn')
    };

    const state = {
        curriculumId: null,
        refs: {
            curricula: [],
            gradeLevels: [],
            subjects: [],
            schoolYears: []
        },
        gradeLevelRows: [],
        subjectRows: [],
        componentRows: [],
        markRows: [],
        mapRows: []
    };

    const api = {
        curricula: () => `${window.API_BASE}/curricula/curricula.php`,
        gradeLevels: () => `${window.API_BASE}/grade_levels/grade_levels.php`,
        subjects: () => `${window.API_BASE}/subjects/subjects.php`,
        schoolYears: () => `${window.API_BASE}/school_years/school_years.php`
    };

    function toast(message, type = 'success') {
        if (window.Swal) {
            Swal.fire({
                toast: true,
                position: 'bottom-end',
                icon: type === 'error' ? 'error' : 'success',
                title: message,
                showConfirmButton: false,
                timer: 2500,
                timerProgressBar: true
            });
            return;
        }
        if (type === 'error') {
            alert(message);
        } else {
            console.log(message);
        }
    }

    function setStatus(text) {
        const el = els.statusText();
        if (el) el.textContent = text || '';
    }

    function escapeHtml(str) {
        return String(str ?? '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }

    function optList(list, { valueKey, labelKey, includeBlank = true, blankLabel = '—' } = {}) {
        const rows = Array.isArray(list) ? list : [];
        const blank = includeBlank ? `<option value="">${escapeHtml(blankLabel)}</option>` : '';
        return blank + rows.map(r => `<option value="${escapeHtml(r[valueKey])}">${escapeHtml(r[labelKey])}</option>`).join('');
    }

    function newKey(prefix) {
        return `${prefix}_${Date.now()}_${Math.random().toString(16).slice(2)}`;
    }

    async function loadRefs() {
        setStatus('Loading references...');
        const [curriculaRes, glRes, subjRes, syRes] = await Promise.all([
            axios.get(api.curricula(), { params: { operation: 'getAllCurricula', _: Date.now() } }),
            axios.get(api.gradeLevels(), { params: { operation: 'getAllGradeLevels', _: Date.now() } }),
            axios.get(api.subjects(), { params: { operation: 'getAllSubjects', _: Date.now() } }),
            axios.get(api.schoolYears(), { params: { operation: 'getAllSchoolYears', _: Date.now() } })
        ]);

        state.refs.curricula = Array.isArray(curriculaRes.data) ? curriculaRes.data : (curriculaRes.data?.data || []);
        state.refs.gradeLevels = Array.isArray(glRes.data) ? glRes.data : (glRes.data?.data || []);
        state.refs.subjects = Array.isArray(subjRes.data) ? subjRes.data : (subjRes.data?.data || []);
        state.refs.schoolYears = Array.isArray(syRes.data) ? syRes.data : (syRes.data?.data || []);

        populateCurriculumSelect();
        setStatus('');
    }

    function populateCurriculumSelect() {
        const select = els.curriculumSelect();
        if (!select) return;

        const list = state.refs.curricula;
        select.innerHTML = `<option value="">Select curriculum...</option>` + list.map(c => {
            const id = c.curriculum_id;
            const label = `${c.curriculum_code || ''} - ${c.curriculum_name || ''}`.trim();
            return `<option value="${escapeHtml(id)}">${escapeHtml(label)}</option>`;
        }).join('');

        if (state.curriculumId) {
            select.value = String(state.curriculumId);
        }
    }

    async function loadForCurriculum(curriculumId) {
        state.curriculumId = curriculumId ? Number(curriculumId) : null;
        if (!state.curriculumId) {
            clearTables();
            return;
        }

        setStatus('Loading components...');

        const params = (operation) => ({ operation, curriculum_id: state.curriculumId, _: Date.now() });
        const [cglRes, csRes, cgcRes, cpmRes, mapRes] = await Promise.all([
            axios.get(api.curricula(), { params: params('getCurriculumGradeLevels') }),
            axios.get(api.curricula(), { params: params('getCurriculumSubjects') }),
            axios.get(api.curricula(), { params: params('getGradingComponents') }),
            axios.get(api.curricula(), { params: params('getPassingMarks') }),
            axios.get(api.curricula(), { params: params('getSchoolYearMap') })
        ]);

        state.gradeLevelRows = (Array.isArray(cglRes.data) ? cglRes.data : []).map(r => ({
            _key: newKey('cgl'),
            grade_level_id: r.grade_level_id ?? '',
            sort_order: r.sort_order ?? ''
        }));

        state.subjectRows = (Array.isArray(csRes.data) ? csRes.data : []).map(r => ({
            _key: newKey('cs'),
            grade_level_id: r.grade_level_id ?? '',
            subject_id: r.subject_id ?? '',
            is_required: Number(r.is_required || 0) === 1 ? 1 : 0,
            weekly_minutes: r.weekly_minutes ?? '',
            sort_order: r.sort_order ?? '',
            notes: r.notes ?? ''
        }));

        state.componentRows = (Array.isArray(cgcRes.data) ? cgcRes.data : []).map(r => ({
            _key: newKey('cgc'),
            grade_level_id: r.grade_level_id ?? '',
            component_code: r.component_code ?? '',
            component_name: r.component_name ?? '',
            weight_percent: r.weight_percent ?? '',
            sort_order: r.sort_order ?? ''
        }));

        state.markRows = (Array.isArray(cpmRes.data) ? cpmRes.data : []).map(r => ({
            _key: newKey('cpm'),
            grade_level_id: r.grade_level_id ?? '',
            subject_id: r.subject_id ?? '',
            passing_mark: r.passing_mark ?? 60,
            notes: r.notes ?? ''
        }));

        state.mapRows = (Array.isArray(mapRes.data) ? mapRes.data : []).map(r => ({
            _key: newKey('map'),
            school_year_id: r.school_year_id ?? '',
            is_primary: Number(r.is_primary || 0) === 1 ? 1 : 0
        }));

        if (!state.gradeLevelRows.length) state.gradeLevelRows.push(blankGradeLevelRow());
        if (!state.subjectRows.length) state.subjectRows.push(blankSubjectRow());
        if (!state.componentRows.length) state.componentRows.push(blankComponentRow());
        if (!state.markRows.length) state.markRows.push(blankMarkRow());
        if (!state.mapRows.length) state.mapRows.push(blankMapRow());

        renderAll();
        setStatus('');
    }

    function clearTables() {
        state.gradeLevelRows = [];
        state.subjectRows = [];
        state.componentRows = [];
        state.markRows = [];
        state.mapRows = [];
        renderAll();
    }

    function blankGradeLevelRow() {
        return { _key: newKey('cgl'), grade_level_id: '', sort_order: '' };
    }

    function blankSubjectRow() {
        return { _key: newKey('cs'), grade_level_id: '', subject_id: '', is_required: 1, weekly_minutes: '', sort_order: '', notes: '' };
    }

    function blankComponentRow() {
        return { _key: newKey('cgc'), grade_level_id: '', component_code: '', component_name: '', weight_percent: '', sort_order: '' };
    }

    function blankMarkRow() {
        return { _key: newKey('cpm'), grade_level_id: '', subject_id: '', passing_mark: 60, notes: '' };
    }

    function blankMapRow() {
        return { _key: newKey('map'), school_year_id: '', is_primary: 1 };
    }

    function renderAll() {
        renderGradeLevels();
        renderSubjects();
        renderComponents();
        renderMarks();
        renderMap();
    }

    function renderGradeLevels() {
        const body = els.gradeLevelsBody();
        if (!body) return;

        const glOptions = optList(state.refs.gradeLevels, { valueKey: 'grade_level_id', labelKey: 'grade_name', blankLabel: 'Select grade...' });

        if (!state.curriculumId) {
            body.innerHTML = `<tr><td colspan="3" class="text-center">Select a curriculum first.</td></tr>`;
            return;
        }

        const rows = state.gradeLevelRows;
        body.innerHTML = rows.map(r => `
            <tr data-row-key="${r._key}">
                <td>
                    <select class="form-control" data-field="grade_level_id">${glOptions}</select>
                </td>
                <td><input class="form-control" data-field="sort_order" type="number" min="1" value="${escapeHtml(r.sort_order)}"></td>
                <td class="text-center">
                    <button class="action-btn delete" data-action="removeGradeLevel" title="Remove"><i class="fas fa-trash"></i></button>
                </td>
            </tr>
        `).join('');

        rows.forEach(r => {
            const tr = body.querySelector(`tr[data-row-key="${CSS.escape(r._key)}"]`);
            if (!tr) return;
            tr.querySelector('[data-field="grade_level_id"]').value = String(r.grade_level_id ?? '');
        });
    }

    function renderSubjects() {
        const body = els.subjectsBody();
        if (!body) return;

        const glOptions = optList(state.refs.gradeLevels, { valueKey: 'grade_level_id', labelKey: 'grade_name', blankLabel: 'Select grade...' });
        const subjOptions = optList(state.refs.subjects, { valueKey: 'subject_id', labelKey: 'subject_name', blankLabel: 'Select subject...' });

        if (!state.curriculumId) {
            body.innerHTML = `<tr><td colspan="7" class="text-center">Select a curriculum first.</td></tr>`;
            return;
        }

        body.innerHTML = state.subjectRows.map(r => `
            <tr data-row-key="${r._key}">
                <td><select class="form-control" data-field="grade_level_id">${glOptions}</select></td>
                <td><select class="form-control" data-field="subject_id">${subjOptions}</select></td>
                <td>
                    <label class="checkbox-label" style="display:flex;align-items:center;gap:.5rem;">
                        <input type="checkbox" data-field="is_required" ${Number(r.is_required) === 1 ? 'checked' : ''}>
                        Required
                    </label>
                </td>
                <td><input class="form-control" data-field="weekly_minutes" type="number" min="0" value="${escapeHtml(r.weekly_minutes)}"></td>
                <td><input class="form-control" data-field="sort_order" type="number" min="1" value="${escapeHtml(r.sort_order)}"></td>
                <td><input class="form-control" data-field="notes" type="text" value="${escapeHtml(r.notes)}"></td>
                <td class="text-center">
                    <button class="action-btn delete" data-action="removeSubject" title="Remove"><i class="fas fa-trash"></i></button>
                </td>
            </tr>
        `).join('');

        state.subjectRows.forEach(r => {
            const tr = body.querySelector(`tr[data-row-key="${CSS.escape(r._key)}"]`);
            if (!tr) return;
            tr.querySelector('[data-field="grade_level_id"]').value = String(r.grade_level_id ?? '');
            tr.querySelector('[data-field="subject_id"]').value = String(r.subject_id ?? '');
        });
    }

    function renderComponents() {
        const body = els.componentsBody();
        if (!body) return;

        const glOptions = optList(state.refs.gradeLevels, { valueKey: 'grade_level_id', labelKey: 'grade_name', blankLabel: 'All grades' });

        if (!state.curriculumId) {
            body.innerHTML = `<tr><td colspan="6" class="text-center">Select a curriculum first.</td></tr>`;
            return;
        }

        body.innerHTML = state.componentRows.map(r => `
            <tr data-row-key="${r._key}">
                <td><select class="form-control" data-field="grade_level_id">${glOptions}</select></td>
                <td><input class="form-control" data-field="component_code" type="text" value="${escapeHtml(r.component_code)}"></td>
                <td><input class="form-control" data-field="component_name" type="text" value="${escapeHtml(r.component_name)}"></td>
                <td><input class="form-control" data-field="weight_percent" type="number" min="0" max="100" step="0.01" value="${escapeHtml(r.weight_percent)}"></td>
                <td><input class="form-control" data-field="sort_order" type="number" min="1" value="${escapeHtml(r.sort_order)}"></td>
                <td class="text-center">
                    <button class="action-btn delete" data-action="removeComponent" title="Remove"><i class="fas fa-trash"></i></button>
                </td>
            </tr>
        `).join('');

        state.componentRows.forEach(r => {
            const tr = body.querySelector(`tr[data-row-key="${CSS.escape(r._key)}"]`);
            if (!tr) return;
            tr.querySelector('[data-field="grade_level_id"]').value = String(r.grade_level_id ?? '');
        });
    }

    function renderMarks() {
        const body = els.marksBody();
        if (!body) return;

        const glOptions = optList(state.refs.gradeLevels, { valueKey: 'grade_level_id', labelKey: 'grade_name', blankLabel: 'All grades' });
        const subjOptions = optList(state.refs.subjects, { valueKey: 'subject_id', labelKey: 'subject_name', blankLabel: 'All subjects' });

        if (!state.curriculumId) {
            body.innerHTML = `<tr><td colspan="5" class="text-center">Select a curriculum first.</td></tr>`;
            return;
        }

        body.innerHTML = state.markRows.map(r => `
            <tr data-row-key="${r._key}">
                <td><select class="form-control" data-field="grade_level_id">${glOptions}</select></td>
                <td><select class="form-control" data-field="subject_id">${subjOptions}</select></td>
                <td><input class="form-control" data-field="passing_mark" type="number" min="0" max="100" step="0.01" value="${escapeHtml(r.passing_mark)}"></td>
                <td><input class="form-control" data-field="notes" type="text" value="${escapeHtml(r.notes)}"></td>
                <td class="text-center">
                    <button class="action-btn delete" data-action="removeMark" title="Remove"><i class="fas fa-trash"></i></button>
                </td>
            </tr>
        `).join('');

        state.markRows.forEach(r => {
            const tr = body.querySelector(`tr[data-row-key="${CSS.escape(r._key)}"]`);
            if (!tr) return;
            tr.querySelector('[data-field="grade_level_id"]').value = String(r.grade_level_id ?? '');
            tr.querySelector('[data-field="subject_id"]').value = String(r.subject_id ?? '');
        });
    }

    function renderMap() {
        const body = els.mapBody();
        if (!body) return;

        const syOptions = optList(state.refs.schoolYears, { valueKey: 'school_year_id', labelKey: 'year_label', blankLabel: 'Select school year...' });

        if (!state.curriculumId) {
            body.innerHTML = `<tr><td colspan="2" class="text-center">Select a curriculum first.</td></tr>`;
            return;
        }

        body.innerHTML = state.mapRows.map(r => `
            <tr data-row-key="${r._key}">
                <td><select class="form-control" data-field="school_year_id">${syOptions}</select></td>
                <td>
                    <label class="checkbox-label" style="display:flex;align-items:center;gap:.5rem;">
                        <input type="checkbox" data-field="is_primary" ${Number(r.is_primary) === 1 ? 'checked' : ''}>
                        Primary
                    </label>
                </td>
            </tr>
        `).join('');

        state.mapRows.forEach(r => {
            const tr = body.querySelector(`tr[data-row-key="${CSS.escape(r._key)}"]`);
            if (!tr) return;
            tr.querySelector('[data-field="school_year_id"]').value = String(r.school_year_id ?? '');
        });
    }

    function readRows(tbody, { fields }) {
        const body = tbody();
        if (!body) return [];
        const rows = Array.from(body.querySelectorAll('tr[data-row-key]'));
        return rows.map(tr => {
            const obj = {};
            fields.forEach(f => {
                const el = tr.querySelector(`[data-field="${f}"]`);
                if (!el) return;
                if (el.type === 'checkbox') {
                    obj[f] = el.checked ? 1 : 0;
                } else {
                    obj[f] = el.value;
                }
            });
            return obj;
        });
    }

    async function saveGradeLevels() {
        if (!state.curriculumId) return;
        const rows = readRows(els.gradeLevelsBody, { fields: ['grade_level_id', 'sort_order'] });
        const cleaned = rows
            .filter(r => String(r.grade_level_id || '').trim() !== '')
            .map((r, i) => ({
                grade_level_id: Number(r.grade_level_id),
                sort_order: r.sort_order === '' ? (i + 1) : Number(r.sort_order)
            }))
            .sort((a, b) => (a.sort_order || 0) - (b.sort_order || 0));

        const grade_level_ids = cleaned.map(r => r.grade_level_id);
        await axios.post(`${api.curricula()}?operation=saveCurriculumGradeLevels`, {
            curriculum_id: state.curriculumId,
            grade_level_ids
        });
        toast('Grade levels saved.');
        await loadForCurriculum(state.curriculumId);
    }

    async function saveSubjects() {
        if (!state.curriculumId) return;
        const rows = readRows(els.subjectsBody, { fields: ['grade_level_id', 'subject_id', 'is_required', 'weekly_minutes', 'sort_order', 'notes'] });
        const cleaned = rows
            .filter(r => String(r.grade_level_id || '').trim() !== '' && String(r.subject_id || '').trim() !== '')
            .map((r, i) => ({
                grade_level_id: Number(r.grade_level_id),
                subject_id: Number(r.subject_id),
                is_required: Number(r.is_required) === 1 ? 1 : 0,
                weekly_minutes: r.weekly_minutes === '' ? null : Number(r.weekly_minutes),
                sort_order: r.sort_order === '' ? (i + 1) : Number(r.sort_order),
                notes: String(r.notes || '').trim() || null
            }));

        const res = await axios.post(`${api.curricula()}?operation=saveCurriculumSubjects`, {
            curriculum_id: state.curriculumId,
            subjects: cleaned
        });
        if (res.data?.success === false) throw new Error(res.data?.message || 'Save failed');
        toast('Curriculum subjects saved.');
        await loadForCurriculum(state.curriculumId);
    }

    async function saveComponents() {
        if (!state.curriculumId) return;
        const rows = readRows(els.componentsBody, { fields: ['grade_level_id', 'component_code', 'component_name', 'weight_percent', 'sort_order'] });
        const cleaned = rows
            .filter(r => String(r.component_code || '').trim() !== '' && String(r.component_name || '').trim() !== '' && String(r.weight_percent || '').trim() !== '')
            .map((r, i) => ({
                grade_level_id: String(r.grade_level_id || '').trim() === '' ? null : Number(r.grade_level_id),
                component_code: String(r.component_code || '').trim(),
                component_name: String(r.component_name || '').trim(),
                weight_percent: Number(r.weight_percent),
                sort_order: r.sort_order === '' ? (i + 1) : Number(r.sort_order)
            }));

        const res = await axios.post(`${api.curricula()}?operation=saveGradingComponents`, {
            curriculum_id: state.curriculumId,
            components: cleaned
        });
        if (res.data?.success === false) throw new Error(res.data?.message || 'Save failed');
        toast('Grading components saved.');
        await loadForCurriculum(state.curriculumId);
    }

    async function saveMarks() {
        if (!state.curriculumId) return;
        const rows = readRows(els.marksBody, { fields: ['grade_level_id', 'subject_id', 'passing_mark', 'notes'] });
        const cleaned = rows
            .filter(r => String(r.passing_mark || '').trim() !== '')
            .map((r) => ({
                grade_level_id: String(r.grade_level_id || '').trim() === '' ? null : Number(r.grade_level_id),
                subject_id: String(r.subject_id || '').trim() === '' ? null : Number(r.subject_id),
                passing_mark: Number(r.passing_mark),
                notes: String(r.notes || '').trim() || null
            }));

        const res = await axios.post(`${api.curricula()}?operation=savePassingMarks`, {
            curriculum_id: state.curriculumId,
            marks: cleaned
        });
        if (res.data?.success === false) throw new Error(res.data?.message || 'Save failed');
        toast('Passing marks saved.');
        await loadForCurriculum(state.curriculumId);
    }

    async function saveMap() {
        if (!state.curriculumId) return;
        const rows = readRows(els.mapBody, { fields: ['school_year_id', 'is_primary'] })
            .filter(r => String(r.school_year_id || '').trim() !== '')
            .map(r => ({
                school_year_id: Number(r.school_year_id),
                is_primary: Number(r.is_primary) === 1 ? 1 : 0
            }));

        for (const row of rows) {
            const res = await axios.post(`${api.curricula()}?operation=saveSchoolYearMap`, {
                curriculum_id: state.curriculumId,
                school_year_id: row.school_year_id,
                is_primary: row.is_primary
            });
            if (res.data?.success === false) throw new Error(res.data?.message || 'Save failed');
        }

        toast('School year mapping saved.');
        await loadForCurriculum(state.curriculumId);
    }

    function wireRemovals() {
        els.gradeLevelsBody()?.addEventListener('click', (e) => {
            const btn = e.target.closest('button[data-action]');
            if (!btn) return;
            if (btn.dataset.action === 'removeGradeLevel') {
                const tr = btn.closest('tr[data-row-key]');
                if (!tr) return;
                const key = tr.dataset.rowKey;
                state.gradeLevelRows = state.gradeLevelRows.filter(r => r._key !== key);
                if (!state.gradeLevelRows.length) state.gradeLevelRows.push(blankGradeLevelRow());
                renderGradeLevels();
            }
        });

        els.subjectsBody()?.addEventListener('click', (e) => {
            const btn = e.target.closest('button[data-action]');
            if (!btn) return;
            if (btn.dataset.action === 'removeSubject') {
                const tr = btn.closest('tr[data-row-key]');
                if (!tr) return;
                const key = tr.dataset.rowKey;
                state.subjectRows = state.subjectRows.filter(r => r._key !== key);
                if (!state.subjectRows.length) state.subjectRows.push(blankSubjectRow());
                renderSubjects();
            }
        });

        els.componentsBody()?.addEventListener('click', (e) => {
            const btn = e.target.closest('button[data-action]');
            if (!btn) return;
            if (btn.dataset.action === 'removeComponent') {
                const tr = btn.closest('tr[data-row-key]');
                if (!tr) return;
                const key = tr.dataset.rowKey;
                state.componentRows = state.componentRows.filter(r => r._key !== key);
                if (!state.componentRows.length) state.componentRows.push(blankComponentRow());
                renderComponents();
            }
        });

        els.marksBody()?.addEventListener('click', (e) => {
            const btn = e.target.closest('button[data-action]');
            if (!btn) return;
            if (btn.dataset.action === 'removeMark') {
                const tr = btn.closest('tr[data-row-key]');
                if (!tr) return;
                const key = tr.dataset.rowKey;
                state.markRows = state.markRows.filter(r => r._key !== key);
                if (!state.markRows.length) state.markRows.push(blankMarkRow());
                renderMarks();
            }
        });
    }

    function wireButtons() {
        els.curriculumSelect()?.addEventListener('change', async (e) => {
            try {
                await loadForCurriculum(e.target.value);
            } catch (err) {
                console.error(err);
                toast(err?.response?.data?.message || err?.message || 'Failed to load curriculum components', 'error');
            }
        });

        els.reloadBtn()?.addEventListener('click', async () => {
            try {
                await loadForCurriculum(state.curriculumId);
            } catch (err) {
                console.error(err);
                toast(err?.response?.data?.message || err?.message || 'Reload failed', 'error');
            }
        });

        els.addGradeLevelRowBtn()?.addEventListener('click', () => {
            state.gradeLevelRows.push(blankGradeLevelRow());
            renderGradeLevels();
        });
        els.addSubjectRowBtn()?.addEventListener('click', () => {
            state.subjectRows.push(blankSubjectRow());
            renderSubjects();
        });
        els.addComponentRowBtn()?.addEventListener('click', () => {
            state.componentRows.push(blankComponentRow());
            renderComponents();
        });
        els.addMarkRowBtn()?.addEventListener('click', () => {
            state.markRows.push(blankMarkRow());
            renderMarks();
        });
        els.addMapRowBtn()?.addEventListener('click', () => {
            state.mapRows.push(blankMapRow());
            renderMap();
        });

        els.saveGradeLevelsBtn()?.addEventListener('click', async () => {
            try {
                await saveGradeLevels();
            } catch (err) {
                console.error(err);
                toast(err?.response?.data?.message || err?.message || 'Save failed', 'error');
            }
        });
        els.saveSubjectsBtn()?.addEventListener('click', async () => {
            try {
                await saveSubjects();
            } catch (err) {
                console.error(err);
                toast(err?.response?.data?.message || err?.message || 'Save failed', 'error');
            }
        });
        els.saveComponentsBtn()?.addEventListener('click', async () => {
            try {
                await saveComponents();
            } catch (err) {
                console.error(err);
                toast(err?.response?.data?.message || err?.message || 'Save failed', 'error');
            }
        });
        els.saveMarksBtn()?.addEventListener('click', async () => {
            try {
                await saveMarks();
            } catch (err) {
                console.error(err);
                toast(err?.response?.data?.message || err?.message || 'Save failed', 'error');
            }
        });
        els.saveMapBtn()?.addEventListener('click', async () => {
            try {
                await saveMap();
            } catch (err) {
                console.error(err);
                toast(err?.response?.data?.message || err?.message || 'Save failed', 'error');
            }
        });
    }

    function installDropdownOverflowFix() {
        const containerOpenCounts = new WeakMap();
        const containerPrevStyles = new WeakMap();

        function setContainerOverflowVisible(container) {
            const count = containerOpenCounts.get(container) || 0;
            if (count === 0) {
                containerPrevStyles.set(container, {
                    overflow: container.style.overflow,
                    overflowX: container.style.overflowX,
                    overflowY: container.style.overflowY
                });
                container.style.overflow = 'visible';
                container.style.overflowX = 'visible';
                container.style.overflowY = 'visible';
            }
            containerOpenCounts.set(container, count + 1);
        }

        function restoreContainerOverflow(container) {
            const count = containerOpenCounts.get(container) || 0;
            if (count <= 1) {
                const prev = containerPrevStyles.get(container);
                if (prev) {
                    container.style.overflow = prev.overflow;
                    container.style.overflowX = prev.overflowX;
                    container.style.overflowY = prev.overflowY;
                } else {
                    container.style.overflow = '';
                    container.style.overflowX = '';
                    container.style.overflowY = '';
                }
                containerOpenCounts.delete(container);
                containerPrevStyles.delete(container);
                return;
            }
            containerOpenCounts.set(container, count - 1);
        }

        // Choices.js emits `showDropdown` / `hideDropdown` CustomEvents on the original <select>
        document.addEventListener('showDropdown', (e) => {
            const selectEl = e.target;
            if (!(selectEl instanceof HTMLSelectElement)) return;
            const container = selectEl.closest('.table-container');
            if (!container) return;
            setContainerOverflowVisible(container);
        }, true);

        document.addEventListener('hideDropdown', (e) => {
            const selectEl = e.target;
            if (!(selectEl instanceof HTMLSelectElement)) return;
            const container = selectEl.closest('.table-container');
            if (!container) return;
            restoreContainerOverflow(container);
        }, true);
    }

    document.addEventListener('DOMContentLoaded', async () => {
        wireButtons();
        wireRemovals();
        installDropdownOverflowFix();

        try {
            await loadRefs();
        } catch (err) {
            console.error(err);
            toast(err?.response?.data?.message || err?.message || 'Failed to load reference data', 'error');
        }
    });
})();
