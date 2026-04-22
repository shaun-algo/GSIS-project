// Generic masterfile controller used across DepEd pages

let MF_CONFIG = null;
let MF_RECORDS = [];
let MF_FILTERED = [];
let MF_CURRENT_ID = null;
let MF_MODAL_MODE = 'add';
let MF_SORT_KEY = null;
let MF_SORT_DIR = 'asc';
let MF_CURRENT_PAGE = 1;
const MF_ITEMS_PER_PAGE = 10;
const MF_SELECT_OPTIONS = {};

function mfCanView() {
    return Boolean(MF_CONFIG?.enableView);
}

function mfHideActions() {
    return Boolean(MF_CONFIG?.readOnly || MF_CONFIG?.hideActions);
}

function mfTableColSpan() {
    return MF_CONFIG.columns.length + (mfHideActions() ? 0 : 1);
}

function mfEscapeAttr(value) {
    return String(value ?? '')
        .replace(/&/g, '&amp;')
        .replace(/"/g, '&quot;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;');
}

function initializeMasterfile(config) {
    MF_CONFIG = config;
    wireStaticText();
    buildFormFields();
    buildTableHead();
    wireEvents();
    loadReferenceData()
        .then(() => loadRecords())
        .catch(error => {
            console.error('Error loading reference data:', error);
            loadRecords();
        });
}

function wireStaticText() {
    setText('pageTitle', MF_CONFIG.pageTitle);
    const rawSubtitle = String(MF_CONFIG.subtitle || '').trim();
    const subtitle = /^manage\b/i.test(rawSubtitle) ? '' : rawSubtitle;
    setText('pageSubtitle', subtitle);
    setText('breadcrumbCurrent', MF_CONFIG.breadcrumb || MF_CONFIG.pageTitle);
    setText('addButtonLabel', MF_CONFIG.addLabel || `Add ${MF_CONFIG.entity}`);
    setText('modalTitle', `Add ${MF_CONFIG.entity}`);
    setText('saveButtonText', `Save ${MF_CONFIG.entity}`);

    document.querySelectorAll('[data-masterfile-link], [data-transaction-link]').forEach(link => {
        link.classList.remove('active');
        if ((link.dataset.masterfileLink === MF_CONFIG.navKey) || (link.dataset.transactionLink === MF_CONFIG.navKey)) {
            link.classList.add('active');
        }
    });
}

function buildFormFields() {
    const container = document.getElementById('dynamicFields');
    if (!container) return;

    // Check if fieldSections is defined (structured form with sections)
    if (MF_CONFIG.fieldSections && Array.isArray(MF_CONFIG.fieldSections)) {
        container.innerHTML = MF_CONFIG.fieldSections.map(section => {
            const fieldsHtml = section.fields.map(field => renderField(field)).join('\n');
            return `
                <div class="form-section">
                    <h3 class="section-title">${section.title}</h3>
                    <div class="section-fields">
                        ${fieldsHtml}
                    </div>
                </div>
            `;
        }).join('\n');
    } else if (MF_CONFIG.fields) {
        // Legacy: simple field array without sections
        container.innerHTML = MF_CONFIG.fields.map(field => renderField(field)).join('\n');
    }
}

function renderField(field) {
    const id = `field-${field.key}`;
    const required = field.required ? 'required' : '';
    const label = `<label for="${id}">${field.label}${field.required ? ' <span class="required">*</span>' : ''}</label>`;

    if (field.type === 'select') {
        return `<div class="form-group">${label}<select id="${id}" class="form-control" ${required}><option value="">Select ${field.label}</option></select><div class="error-message" aria-live="polite"></div></div>`;
    }

    if (field.type === 'checkbox') {
        const checked = field.defaultValue ? 'checked' : '';
        return `<div class="form-group checkbox-group"><label class="checkbox-label"><input type="checkbox" id="${id}" ${checked}> ${field.label}</label></div>`;
    }

    const inputType = field.type === 'number' ? 'number' : field.type === 'date' ? 'date' : 'text';
    return `<div class="form-group">${label}<input type="${inputType}" id="${id}" class="form-control" ${required} ${field.maxLength ? `maxlength="${field.maxLength}"` : ''}><div class="error-message" aria-live="polite"></div></div>`;
}

function mfSetFieldError(fieldKey, message) {
    const el = document.getElementById(`field-${fieldKey}`);
    if (!el) return;
    el.classList.add('error');

    const group = el.closest('.form-group');
    if (!group) return;

    let msgEl = group.querySelector('.error-message');
    if (!msgEl) {
        msgEl = document.createElement('div');
        msgEl.className = 'error-message';
        // Keep it adjacent to match CSS: .form-control.error + .error-message
        el.insertAdjacentElement('afterend', msgEl);
    }
    msgEl.textContent = message || 'This field is required.';
}

function mfClearFieldError(fieldKey) {
    const el = document.getElementById(`field-${fieldKey}`);
    if (!el) return;
    el.classList.remove('error');

    const group = el.closest('.form-group');
    const msgEl = group?.querySelector('.error-message');
    if (msgEl) msgEl.textContent = '';
}

function mfClearAllFieldErrors(allFields) {
    (allFields || []).forEach((field) => {
        if (!field?.key) return;
        mfClearFieldError(field.key);
    });
}

function buildTableHead() {
    const head = document.getElementById('dataTableHead');
    if (!head) return;
    const cols = MF_CONFIG.columns.map(col => `<th>${col.label}${col.sortable ? ' <i class="fas fa-sort"></i>' : ''}</th>`).join('');
    head.innerHTML = mfHideActions() ? cols : `${cols}<th class="text-center">Actions</th>`;
}

function wireEvents() {
    document.getElementById('addButton')?.addEventListener('click', openAddModal);
    document.getElementById('searchInput')?.addEventListener('input', (e) => {
        filterRecords(e.target.value);
    });
    document.getElementById('prevBtn')?.addEventListener('click', () => changePage(-1));
    document.getElementById('nextBtn')?.addEventListener('click', () => changePage(1));

    const tbody = document.getElementById('dataTableBody');
    if (tbody) {
        tbody.addEventListener('click', (e) => {
            const btn = e.target.closest('button[data-action]');
            if (!btn) return;
            const id = btn.dataset.id;
            const action = btn.dataset.action;
            if (action === 'view') startView(id);
            else if (action === 'edit') startEdit(id);
            else if (action === 'delete') deleteRecord(id);
            else if (typeof MF_CONFIG?.onAction === 'function') {
                const row = MF_RECORDS.find(r => String(r?.[MF_CONFIG.primaryKey]) === String(id))
                    || MF_FILTERED.find(r => String(r?.[MF_CONFIG.primaryKey]) === String(id));
                MF_CONFIG.onAction(action, id, row);
            }
        });
    }

    // Clear validation errors as the user edits
    const container = document.getElementById('dynamicFields');
    if (container) {
        const clearIfEditable = (target) => {
            if (!target) return;
            if (!target.classList?.contains('form-control')) return;
            if (target.disabled || target.readOnly) return;
            target.classList.remove('error');
            const group = target.closest('.form-group');
            const msgEl = group?.querySelector('.error-message');
            if (msgEl) msgEl.textContent = '';
        };
        container.addEventListener('input', (e) => clearIfEditable(e.target));
        container.addEventListener('change', (e) => clearIfEditable(e.target));
    }
}

async function loadReferenceData() {
    // Get all fields from either fieldSections or fields array
    const allFields = MF_CONFIG.fieldSections
        ? MF_CONFIG.fieldSections.flatMap(section => section.fields)
        : (MF_CONFIG.fields || []);

    const promises = allFields
        .filter(f => f.type === 'select' && typeof f.loadOptions === 'function')
        .map(async (field) => {
            try {
                const options = await field.loadOptions();
                MF_SELECT_OPTIONS[field.key] = options;
                populateSelect(field, options);
            } catch (error) {
                console.error(`Error loading options for ${field.key}:`, error);
                MF_SELECT_OPTIONS[field.key] = [];
            }
        });
    await Promise.all(promises);
}

async function loadRecords() {
    showLoading();
    try {
        const data = await MF_CONFIG.api.list();
        MF_RECORDS = Array.isArray(data)
            ? data
            : (Array.isArray(data?.rows) ? data.rows : (data?.data || []));
        MF_FILTERED = [...MF_RECORDS];
        MF_CURRENT_PAGE = 1;
        renderTable();
    } catch (error) {
        console.error('Load error', error);
        const serverMessage = error?.response?.data?.message;
        const fallback = error?.message || 'Failed to load records.';
        showError(serverMessage || fallback);
    }
}

function renderTable() {
    const tbody = document.getElementById('dataTableBody');
    if (!tbody) return;

    if (!MF_FILTERED.length) {
        tbody.innerHTML = `<tr><td colspan="${mfTableColSpan()}" class="text-center"><div class="empty-state"><i class="fas fa-inbox"></i><h3>No records</h3><p>No records match your criteria</p></div></td></tr>`;
        updatePaginationInfo(0, 0, 0);
        return;
    }

    let data = [...MF_FILTERED];
    if (MF_SORT_KEY) {
        data.sort((a, b) => {
            const aVal = a[MF_SORT_KEY] ?? '';
            const bVal = b[MF_SORT_KEY] ?? '';
            if (aVal === bVal) return 0;
            if (MF_SORT_DIR === 'asc') return aVal > bVal ? 1 : -1;
            return aVal < bVal ? 1 : -1;
        });
    }

    const totalPages = Math.max(1, Math.ceil(data.length / MF_ITEMS_PER_PAGE));
    if (MF_CURRENT_PAGE > totalPages) MF_CURRENT_PAGE = totalPages;
    const start = (MF_CURRENT_PAGE - 1) * MF_ITEMS_PER_PAGE;
    const end = Math.min(start + MF_ITEMS_PER_PAGE, data.length);
    const pageData = data.slice(start, end);

    tbody.innerHTML = pageData.map(row => renderRow(row)).join('');
    updatePaginationInfo(start + 1, end, data.length);
    updatePaginationButtons(MF_CURRENT_PAGE, totalPages);
}

function renderRow(row) {
    const id = row[MF_CONFIG.primaryKey];
    const rowAttr = (id === undefined || id === null || id === '')
        ? ''
        : ` data-row-id="${mfEscapeAttr(id)}"`;

    const cells = MF_CONFIG.columns.map(col => {
        const value = col.formatter ? col.formatter(row[col.key], row) : (row[col.key] ?? '');
        const colKey = mfEscapeAttr(col.key || '');
        return `<td data-col-key="${colKey}">${value}</td>`;
    }).join('');

    if (mfHideActions()) {
        return `<tr${rowAttr}>${cells}</tr>`;
    }

    const viewBtn = mfCanView()
        ? `<button class="action-btn view" data-action="view" data-id="${id}"><i class="fas fa-eye"></i></button>`
        : '';

    const extraActions = (() => {
        const ra = MF_CONFIG?.rowActions;
        if (!ra) return [];
        if (typeof ra === 'function') {
            try {
                const out = ra(row);
                return Array.isArray(out) ? out : [];
            } catch (_) {
                return [];
            }
        }
        return Array.isArray(ra) ? ra : [];
    })();

    const extraBtns = extraActions.map((a) => {
        const action = mfEscapeAttr(a?.action || '');
        if (!action) return '';
        const title = mfEscapeAttr(a?.title || a?.label || action);
        const icon = mfEscapeAttr(a?.iconClass || 'fa-file-lines');
        const variant = mfEscapeAttr(a?.variant || 'view');
        return `<button class="action-btn ${variant}" data-action="${action}" data-id="${id}" title="${title}"><i class="fas ${icon}"></i></button>`;
    }).join('');

    const editBtn = MF_CONFIG.disableEdit
        ? ''
        : `<button class="action-btn edit" data-action="edit" data-id="${id}"><i class="fas fa-edit"></i></button>`;
    const delBtn = MF_CONFIG.disableDelete
        ? ''
        : `<button class="action-btn delete" data-action="delete" data-id="${id}"><i class="fas fa-trash"></i></button>`;
    return `<tr${rowAttr}>${cells}<td class="text-center"><div class="action-buttons">${viewBtn}${extraBtns}${editBtn}${delBtn}</div></td></tr>`;
}

function showLoading() {
    const tbody = document.getElementById('dataTableBody');
    if (tbody) {
        tbody.innerHTML = `<tr><td colspan="${mfTableColSpan()}" class="text-center"><div class="empty-state"><i class="fas fa-spinner fa-spin"></i><h3>Loading records</h3><p>Please wait...</p></div></td></tr>`;
    }
}

function showError(message) {
    const tbody = document.getElementById('dataTableBody');
    if (tbody) {
        tbody.innerHTML = `<tr><td colspan="${mfTableColSpan()}" class="text-center"><div class="empty-state"><i class="fas fa-circle-exclamation"></i><h3>Unable to load records</h3><p>${message}</p></div></td></tr>`;
    }
}

function filterRecords(term) {
    const lower = (term || '').toLowerCase();
    MF_FILTERED = !lower ? [...MF_RECORDS] : MF_RECORDS.filter(row => Object.values(row).some(val => String(val || '').toLowerCase().includes(lower)));
    MF_CURRENT_PAGE = 1;
    renderTable();
}

function changePage(delta) {
    const totalPages = Math.max(1, Math.ceil(MF_FILTERED.length / MF_ITEMS_PER_PAGE));
    const next = MF_CURRENT_PAGE + delta;
    if (next >= 1 && next <= totalPages) {
        MF_CURRENT_PAGE = next;
        renderTable();
    }
}

    function mfGoToRowById(rowId) {
        if (!MF_CONFIG || !MF_CONFIG.primaryKey) return false;
        if (rowId === undefined || rowId === null || rowId === '') return false;

        const idx = MF_FILTERED.findIndex((row) => String(row?.[MF_CONFIG.primaryKey]) === String(rowId));
        if (idx < 0) return false;

        const targetPage = Math.floor(idx / MF_ITEMS_PER_PAGE) + 1;
        if (targetPage !== MF_CURRENT_PAGE) {
            MF_CURRENT_PAGE = targetPage;
            renderTable();
        }
        return true;
    }

    function mfFindRowIdByPredicate(predicateFn) {
        if (typeof predicateFn !== 'function' || !MF_CONFIG || !MF_CONFIG.primaryKey) return null;
        const hit = MF_FILTERED.find((row) => {
            try {
                return Boolean(predicateFn(row));
            } catch (_) {
                return false;
            }
        });
        return hit ? hit[MF_CONFIG.primaryKey] : null;
    }

function updatePaginationInfo(from, to, total) {
    setText('showingFrom', from);
    setText('showingTo', to);
    setText('totalRecords', total);
    setText('currentPage', MF_CURRENT_PAGE);
    setText('totalPages', Math.max(1, Math.ceil((total || 1) / MF_ITEMS_PER_PAGE)));
}

function updatePaginationButtons(current, total) {
    const prevBtn = document.getElementById('prevBtn');
    const nextBtn = document.getElementById('nextBtn');
    if (prevBtn) prevBtn.disabled = current <= 1;
    if (nextBtn) nextBtn.disabled = current >= total;
}

function openAddModal() {
    MF_MODAL_MODE = 'add';
    MF_CURRENT_ID = null;
    setText('modalTitle', `Add ${MF_CONFIG.entity}`);
    setText('saveButtonText', `Save ${MF_CONFIG.entity}`);
    setSaveButtonVisible(true);
    resetForm();
    openModal();
}

function startView(id) {
    const record = MF_RECORDS.find(r => String(r[MF_CONFIG.primaryKey]) === String(id));
    if (!record) return;

    MF_MODAL_MODE = 'view';
    MF_CURRENT_ID = record[MF_CONFIG.primaryKey];
    setText('modalTitle', `View ${MF_CONFIG.entity}`);

    // Get all fields from either fieldSections or fields array
    const allFields = MF_CONFIG.fieldSections
        ? MF_CONFIG.fieldSections.flatMap(section => section.fields)
        : (MF_CONFIG.fields || []);

    allFields.forEach(field => {
        const el = document.getElementById(`field-${field.key}`);
        if (!el) return;
        const value = record[field.key];
        if (field.type === 'checkbox') {
            el.checked = value === 1 || value === true || value === '1';
        } else {
            el.value = value ?? '';
        }
    });

    lockAllFields(allFields);
    setSaveButtonVisible(false);
    openModal();
}

function startEdit(id) {
    const record = MF_RECORDS.find(r => String(r[MF_CONFIG.primaryKey]) === String(id));
    if (!record) return;
    MF_MODAL_MODE = 'edit';
    MF_CURRENT_ID = record[MF_CONFIG.primaryKey];
    setText('modalTitle', `Edit ${MF_CONFIG.entity}`);
    setText('saveButtonText', `Update ${MF_CONFIG.entity}`);
    setSaveButtonVisible(true);

    // Get all fields from either fieldSections or fields array
    const allFields = MF_CONFIG.fieldSections
        ? MF_CONFIG.fieldSections.flatMap(section => section.fields)
        : (MF_CONFIG.fields || []);

    allFields.forEach(field => {
        const el = document.getElementById(`field-${field.key}`);
        if (!el) return;
        const value = record[field.key];
        if (field.type === 'checkbox') {
            el.checked = value === 1 || value === true || value === '1';
        } else {
            el.value = value ?? '';
        }
    });

    applyFieldEditability(allFields, true);

    openModal();
}

function resetForm() {
    // Get all fields from either fieldSections or fields array
    const allFields = MF_CONFIG.fieldSections
        ? MF_CONFIG.fieldSections.flatMap(section => section.fields)
        : (MF_CONFIG.fields || []);

    allFields.forEach(field => {
        const el = document.getElementById(`field-${field.key}`);
        if (!el) return;
        if (field.type === 'checkbox') {
            el.checked = Boolean(field.defaultValue);
        } else if (field.defaultValue !== undefined) {
            el.value = field.defaultValue;
        } else {
            el.value = '';
        }
    });

    applyFieldEditability(allFields, Boolean(MF_CURRENT_ID));
}

function applyFieldEditability(allFields, isEdit) {
    (allFields || []).forEach((field) => {
        const el = document.getElementById(`field-${field.key}`);
        if (!el) return;

        // Always clear view-mode disabling when leaving View.
        // (View uses disabled=true for all controls.)
        try {
            el.disabled = false;
        } catch (_) {
            // ignore
        }
        try {
            el.readOnly = false;
        } catch (_) {
            // ignore
        }

        const shouldLock = Boolean(
            field.readonly ||
            (isEdit ? field.readonlyOnEdit : field.readonlyOnAdd)
        );

        // For add/edit modes, we prefer readOnly for text-like inputs
        // and disabled for controls that don't support readOnly.
        if (field.type === 'checkbox' || field.type === 'select') {
            el.disabled = shouldLock;
            return;
        }

        // Some input types (e.g., date) still allow picker interaction when readOnly.
        // Only use disabled if explicitly requested by config; otherwise keep readOnly.
        el.readOnly = shouldLock;
    });
}

async function saveRecord() {
    if (MF_MODAL_MODE === 'view') {
        closeModal();
        return;
    }
    // Get all fields from either fieldSections or fields array
    const allFields = MF_CONFIG.fieldSections
        ? MF_CONFIG.fieldSections.flatMap(section => section.fields)
        : (MF_CONFIG.fields || []);

    const payload = {};
    const invalidFields = [];

    mfClearAllFieldErrors(allFields);
    for (const field of allFields) {
        const el = document.getElementById(`field-${field.key}`);
        if (!el) continue;
        let value;
        if (field.type === 'checkbox') {
            value = el.checked ? 1 : 0;
        } else {
            value = el.value?.trim();
            if (field.type === 'number' && value !== '') {
                value = Number(value);
            }
        }
        if (field.required && (value === '' || value === undefined || value === null)) {
            invalidFields.push(field);
            mfSetFieldError(field.key, 'This field is required.');
        }
        if (field.omitIfEmpty && (value === '' || value === undefined)) {
            continue;
        }
        payload[field.key] = value;
    }

    if (invalidFields.length) {
        const first = invalidFields[0];
        const firstEl = document.getElementById(`field-${first.key}`);
        try {
            firstEl?.focus?.();
            firstEl?.scrollIntoView?.({ behavior: 'smooth', block: 'center' });
        } catch (_) {
            // ignore
        }
        showNotification('Please correct the highlighted fields.', 'error');
        return;
    }

    try {
        if (MF_CURRENT_ID) {
            await MF_CONFIG.api.update(MF_CURRENT_ID, payload);
            showNotification(`${MF_CONFIG.entity} updated.`);
        } else {
            await MF_CONFIG.api.create(payload);
            showNotification(`${MF_CONFIG.entity} created.`);
        }
        closeModal();
        loadRecords();
    } catch (error) {
        console.error('Save error', error);
        const apiMessage = error?.response?.data?.message;
        showNotification(apiMessage || 'Unable to save. Please try again.', 'error');
    }
}

function lockAllFields(allFields) {
    (allFields || []).forEach((field) => {
        const el = document.getElementById(`field-${field.key}`);
        if (!el) return;

        // In View mode, fully disable all controls to avoid any interaction.
        try {
            el.disabled = true;
        } catch (_) {
            // ignore
        }
        try {
            el.readOnly = true;
        } catch (_) {
            // ignore
        }
    });
}

function setSaveButtonVisible(visible) {
    const saveText = document.getElementById('saveButtonText');
    const saveBtn = saveText?.closest('button');
    if (saveBtn) saveBtn.style.display = visible ? '' : 'none';
}

function showConfirmDialog(title, message) {
    return new Promise((resolve) => {
        // Create overlay
        const overlay = document.createElement('div');
        overlay.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.4);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 10000;
            animation: fadeIn 0.2s ease-out;
        `;

        // Create dialog box
        const dialog = document.createElement('div');
        dialog.style.cssText = `
            background-color: var(--surface-0);
            border-radius: 0.5rem;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            width: 90%;
            max-width: 420px;
            overflow: hidden;
            animation: slideUp 0.3s ease-out;
        `;

        // Header
        const header = document.createElement('div');
        header.style.cssText = `
            background-color: var(--gray-100);
            border-bottom: 1px solid var(--gray-200);
            padding: 1.25rem;
            border-radius: 0.5rem 0.5rem 0 0;
        `;
        header.innerHTML = `<h3 style="margin: 0; font-size: 1.125rem; font-weight: 600; color: var(--gray-900);">${title}</h3>`;

        // Body
        const body = document.createElement('div');
        body.style.cssText = `
            padding: 1.5rem;
            color: var(--gray-700);
            line-height: 1.5;
            font-size: 0.9375rem;
        `;
        body.textContent = message;

        // Footer
        const footer = document.createElement('div');
        footer.style.cssText = `
            display: flex;
            gap: 0.75rem;
            padding: 1rem 1.25rem;
            border-top: 1px solid var(--gray-200);
            background-color: var(--gray-50);
            justify-content: flex-end;
        `;

        // Cancel button
        const cancelBtn = document.createElement('button');
        cancelBtn.type = 'button';
        cancelBtn.textContent = 'Cancel';
        cancelBtn.style.cssText = `
            padding: 0.625rem 1.25rem;
            font-size: 0.9375rem;
            font-weight: 500;
            color: var(--gray-700);
            background-color: var(--surface-0);
            border: 1px solid var(--gray-300);
            border-radius: 0.375rem;
            cursor: pointer;
            transition: all 0.2s;
        `;
        cancelBtn.onmouseover = () => cancelBtn.style.backgroundColor = 'var(--gray-100)';
        cancelBtn.onmouseout = () => cancelBtn.style.backgroundColor = 'var(--surface-0)';
        cancelBtn.onclick = () => {
            overlay.style.animation = 'fadeOut 0.2s ease-out';
            setTimeout(() => overlay.remove(), 200);
            resolve(false);
        };

        // Confirm button
        const confirmBtn = document.createElement('button');
        confirmBtn.type = 'button';
        confirmBtn.textContent = 'Delete';
        confirmBtn.style.cssText = `
            padding: 0.625rem 1.25rem;
            font-size: 0.9375rem;
            font-weight: 500;
            color: white;
            background-color: var(--color-danger);
            border: none;
            border-radius: 0.375rem;
            cursor: pointer;
            transition: all 0.2s;
        `;
        confirmBtn.onmouseover = () => confirmBtn.style.backgroundColor = 'var(--color-danger)';
        confirmBtn.onmouseout = () => confirmBtn.style.backgroundColor = 'var(--color-danger)';
        confirmBtn.onclick = () => {
            overlay.style.animation = 'fadeOut 0.2s ease-out';
            setTimeout(() => overlay.remove(), 200);
            resolve(true);
        };

        footer.appendChild(cancelBtn);
        footer.appendChild(confirmBtn);

        dialog.appendChild(header);
        dialog.appendChild(body);
        dialog.appendChild(footer);
        overlay.appendChild(dialog);
        document.body.appendChild(overlay);

        // Add animations if not present
        if (!document.getElementById('confirmDialogStyles')) {
            const style = document.createElement('style');
            style.id = 'confirmDialogStyles';
            style.textContent = `
                @keyframes fadeIn {
                    from { opacity: 0; }
                    to { opacity: 1; }
                }
                @keyframes fadeOut {
                    from { opacity: 1; }
                    to { opacity: 0; }
                }
                @keyframes slideUp {
                    from {
                        opacity: 0;
                        transform: translateY(20px);
                    }
                    to {
                        opacity: 1;
                        transform: translateY(0);
                    }
                }
            `;
            document.head.appendChild(style);
        }

        // Focus on confirm button
        confirmBtn.focus();
    });
}

async function deleteRecord(id) {
    const confirmed = await showConfirmDialog(
        'Delete Record',
        `Are you sure you want to delete this ${MF_CONFIG.entity.toLowerCase()}? This action cannot be undone.`
    );
    if (!confirmed) return;
    try {
        await MF_CONFIG.api.remove(id);
        showNotification(`${MF_CONFIG.entity} deleted.`);
        loadRecords();
    } catch (error) {
        console.error('Delete error', error);
        showNotification('Unable to delete. Please try again.', 'error');
    }
}

function populateSelect(field, options = []) {
    const select = document.getElementById(`field-${field.key}`);
    if (!select) return;
    select.innerHTML = `<option value="">Select ${field.label}</option>` + options.map(opt => `<option value="${opt[field.valueKey]}"${field.defaultValue && field.defaultValue === opt[field.valueKey] ? ' selected' : ''}>${opt[field.labelKey]}</option>`).join('');
}

function setText(id, value) {
    const el = document.getElementById(id);
    if (el) el.textContent = value;
}

function openModal() {
    const modal = document.getElementById('recordModal');
    if (modal) {
        modal.classList.add('show');
        document.body.style.overflow = 'hidden';
    }
}

function closeModal() {
    const modal = document.getElementById('recordModal');
    if (modal) {
        modal.classList.remove('show');
        document.body.style.overflow = '';
    }
}

window.onclick = function(event) {
    const modal = document.getElementById('recordModal');
    if (event.target === modal) {
        closeModal();
    }
};

let MF_NOTIFICATION_EL = null;
let MF_NOTIFICATION_TIMER = null;

function showNotification(message, type = 'success') {
    if (MF_NOTIFICATION_EL) {
        MF_NOTIFICATION_EL.remove();
        MF_NOTIFICATION_EL = null;
    }
    if (MF_NOTIFICATION_TIMER) {
        clearTimeout(MF_NOTIFICATION_TIMER);
        MF_NOTIFICATION_TIMER = null;
    }

    const ensureGovToastStyles = () => {
        if (document.getElementById('govToastStyles')) return;
        const style = document.createElement('style');
        style.id = 'govToastStyles';
        style.textContent = `
            .gov-toast{position:fixed;bottom:80px;right:20px;background:var(--gray-50);border:1px solid var(--gray-200);box-shadow:var(--shadow-md);border-radius:6px;padding:.9rem 1rem;z-index:10001;min-width:320px;max-width:420px;opacity:0;transform:translateX(30px);transition:opacity .25s ease,transform .25s ease}
            .gov-toast.show{opacity:1;transform:translateX(0)}
            .gov-toast__content{display:flex;align-items:flex-start;gap:.75rem}
            .gov-toast__icon{font-size:1.1rem;margin-top:.05rem}
            .gov-toast__text{display:flex;flex-direction:column;gap:.15rem;min-width:0;flex:1}
            .gov-toast__title{font-size:.78rem;font-weight:700;letter-spacing:.04em;text-transform:uppercase;color:var(--gray-700);line-height:1.15}
            .gov-toast__message{font-size:.92rem;color:var(--gray-900);line-height:1.35;word-break:break-word}
            .gov-toast__dismiss{background:transparent;border:none;color:var(--gray-500);font-size:1rem;cursor:pointer;line-height:1}
            .gov-toast--success{border-left:4px solid var(--deped-blue)}
            .gov-toast--success .gov-toast__icon{color:var(--deped-blue)}
            .gov-toast--error{border-left:4px solid var(--color-danger)}
            .gov-toast--error .gov-toast__icon{color:var(--color-danger)}
            .gov-toast--info{border-left:4px solid var(--deped-blue)}
            .gov-toast--info .gov-toast__icon{color:var(--deped-blue)}
        `;
        document.head.appendChild(style);
    };

    ensureGovToastStyles();

    document.querySelectorAll('.gov-toast').forEach((el) => el.remove());

    const normalizedType = type === 'success' || type === 'error' || type === 'info' ? type : 'success';
    const title = normalizedType === 'success' ? 'Completed' : normalizedType === 'error' ? 'Action Required' : 'Notice';
    const iconClass = normalizedType === 'success' ? 'fa-circle-check' : normalizedType === 'error' ? 'fa-triangle-exclamation' : 'fa-circle-info';

    const toast = document.createElement('div');
    toast.className = `gov-toast gov-toast--${normalizedType}`;
    toast.innerHTML = `
        <div class="gov-toast__content">
            <i class="fas ${iconClass} gov-toast__icon"></i>
            <div class="gov-toast__text">
                <div class="gov-toast__title">${title}</div>
                <div class="gov-toast__message">${message}</div>
            </div>
            <button type="button" class="gov-toast__dismiss" aria-label="Dismiss">&times;</button>
        </div>
    `;

    document.body.appendChild(toast);
    MF_NOTIFICATION_EL = toast;

    requestAnimationFrame(() => toast.classList.add('show'));

    const timeoutMs = normalizedType === 'error' ? 9000 : 4500;

    const dismiss = () => {
        if (MF_NOTIFICATION_TIMER) {
            clearTimeout(MF_NOTIFICATION_TIMER);
            MF_NOTIFICATION_TIMER = null;
        }
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 250);
        MF_NOTIFICATION_EL = null;
    };

    const startTimer = () => {
        MF_NOTIFICATION_TIMER = setTimeout(dismiss, timeoutMs);
    };

    const dismissBtn = toast.querySelector('button[aria-label="Dismiss"]');
    if (dismissBtn) {
        dismissBtn.addEventListener('click', (e) => {
            e.preventDefault();
            e.stopPropagation();
            dismiss();
        });
    }
    toast.addEventListener('mouseenter', () => {
        if (MF_NOTIFICATION_TIMER) {
            clearTimeout(MF_NOTIFICATION_TIMER);
            MF_NOTIFICATION_TIMER = null;
        }
    });
    toast.addEventListener('mouseleave', () => {
        if (!MF_NOTIFICATION_TIMER) {
            startTimer();
        }
    });

    startTimer();
}

// Add animation styles if not already present
if (!document.getElementById('notificationStyles')) {
    const style = document.createElement('style');
    style.id = 'notificationStyles';
    style.textContent = `
        @keyframes slideInRight {
            from {
                opacity: 0;
                transform: translateX(100px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }
        @keyframes slideOutRight {
            from {
                opacity: 1;
                transform: translateX(0);
            }
            to {
                opacity: 0;
                transform: translateX(100px);
            }
        }
    `;
    document.head.appendChild(style);
}

window.openAddModal = openAddModal;
window.saveRecord = saveRecord;
window.masterfileGoToRowById = mfGoToRowById;
window.masterfileFindRowIdByPredicate = mfFindRowIdByPredicate;
window.closeModal = closeModal;
window.reloadMasterfileRecords = loadRecords;
