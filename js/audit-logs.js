// ===========================
// Audit Logs Page Controller
// ===========================

const AL_API = `${window.API_BASE}/audit_logs/audit_logs.php`;
const AL_PER_PAGE = 20;
let alCurrentPage = 1;
let alTotalPages = 1;
let alTotalRecords = 0;

document.addEventListener('DOMContentLoaded', () => {
    loadFilterOptions();
    loadAuditLogs();
    wireEvents();
});

function wireEvents() {
    // Search
    const searchInput = document.getElementById('searchInput');
    let searchTimer;
    searchInput.addEventListener('input', () => {
        clearTimeout(searchTimer);
        searchTimer = setTimeout(() => {
            alCurrentPage = 1;
            loadAuditLogs();
        }, 400);
    });

    // Filters
    ['filterTable', 'filterAction', 'filterUser', 'filterDateFrom', 'filterDateTo'].forEach(id => {
        document.getElementById(id).addEventListener('change', () => {
            alCurrentPage = 1;
            loadAuditLogs();
        });
    });

    // Clear filters
    document.getElementById('btnClearFilters').addEventListener('click', clearFilters);

    // Refresh
    document.getElementById('btnRefresh').addEventListener('click', () => loadAuditLogs());

    // Pagination
    document.getElementById('prevBtn').addEventListener('click', () => {
        if (alCurrentPage > 1) {
            alCurrentPage--;
            loadAuditLogs();
        }
    });
    document.getElementById('nextBtn').addEventListener('click', () => {
        if (alCurrentPage < alTotalPages) {
            alCurrentPage++;
            loadAuditLogs();
        }
    });

    // Detail modal close on overlay click
    const detailModal = document.getElementById('detailModal');
    detailModal.addEventListener('click', (e) => {
        if (e.target === detailModal) closeDetailModal();
    });
}

function loadFilterOptions() {
    axios.get(`${AL_API}?operation=getAuditLogFilters`)
        .then(res => {
            const data = res.data;
            if (!data.success) return;

            // Populate table filter
            const tableSelect = document.getElementById('filterTable');
            data.tables.forEach(t => {
                const opt = document.createElement('option');
                opt.value = t;
                opt.textContent = t;
                tableSelect.appendChild(opt);
            });

            // Populate user filter
            const userSelect = document.getElementById('filterUser');
            data.users.forEach(u => {
                const opt = document.createElement('option');
                opt.value = u.user_id;
                opt.textContent = u.username || `User #${u.user_id}`;
                userSelect.appendChild(opt);
            });
        })
        .catch(err => console.error('Error loading filter options:', err));
}

function getFilterParams() {
    const params = {};
    const search = document.getElementById('searchInput').value.trim();
    const table = document.getElementById('filterTable').value;
    const action = document.getElementById('filterAction').value;
    const user = document.getElementById('filterUser').value;
    const dateFrom = document.getElementById('filterDateFrom').value;
    const dateTo = document.getElementById('filterDateTo').value;

    if (search) params.search = search;
    if (table) params.table_name = table;
    if (action) params.action = action;
    if (user) params.user_id = user;
    if (dateFrom) params.date_from = dateFrom;
    if (dateTo) params.date_to = dateTo;

    params.page = alCurrentPage;
    params.perPage = AL_PER_PAGE;

    return params;
}

function loadAuditLogs() {
    const params = getFilterParams();
    const tbody = document.getElementById('auditTableBody');

    tbody.innerHTML = `<tr><td colspan="10" class="text-center">
        <div class="loading"><i class="fas fa-spinner fa-spin"></i> Loading audit logs...</div>
    </td></tr>`;

    axios.get(AL_API, { params })
        .then(res => {
            const data = res.data;
            if (!data.success) {
                tbody.innerHTML = `<tr><td colspan="10" class="text-center" style="padding:2rem;color:var(--gray-500);">
                    <i class="fas fa-exclamation-circle"></i> ${data.message || 'Failed to load audit logs'}
                </td></tr>`;
                return;
            }

            const records = data.data || [];
            const pagination = data.pagination || {};

            alTotalRecords = pagination.totalRecords || 0;
            alTotalPages = pagination.totalPages || 1;
            alCurrentPage = pagination.page || 1;

            updatePaginationUI();

            if (records.length === 0) {
                tbody.innerHTML = `<tr><td colspan="10" class="text-center" style="padding:2rem;color:var(--gray-500);">
                    <i class="fas fa-clipboard-list" style="font-size:2rem;display:block;margin-bottom:0.5rem;"></i>
                    No audit logs found
                </td></tr>`;
                return;
            }

            tbody.innerHTML = records.map((r, i) => {
                const offset = (alCurrentPage - 1) * AL_PER_PAGE;
                const rowNum = offset + i + 1;
                const actionClass = (r.action || '').toLowerCase();
                const oldPreview = truncateJson(r.old_values);
                const newPreview = truncateJson(r.new_values);

                return `<tr>
                    <td>${rowNum}</td>
                    <td>${formatDate(r.action_time)}</td>
                    <td>${escapeHtml(r.username || '—')}</td>
                    <td><code>${escapeHtml(r.table_name)}</code></td>
                    <td>${r.record_id ?? '—'}</td>
                    <td><span class="action-badge ${actionClass}"><i class="fas fa-${actionIcon(r.action)}"></i> ${escapeHtml(r.action)}</span></td>
                    <td><span class="values-preview" title="Click to view details" onclick="viewDetail(${r.audit_id})">${oldPreview}</span></td>
                    <td><span class="values-preview" title="Click to view details" onclick="viewDetail(${r.audit_id})">${newPreview}</span></td>
                    <td>${escapeHtml(r.ip_address || '—')}</td>
                    <td><button class="btn btn-outline btn-sm" onclick="viewDetail(${r.audit_id})" title="View details"><i class="fas fa-eye"></i></button></td>
                </tr>`;
            }).join('');
        })
        .catch(err => {
            console.error('Error loading audit logs:', err);
            tbody.innerHTML = `<tr><td colspan="10" class="text-center" style="padding:2rem;color:#b91c1c;">
                <i class="fas fa-exclamation-triangle"></i> Error loading audit logs
            </td></tr>`;
        });
}

function updatePaginationUI() {
    const from = alTotalRecords === 0 ? 0 : (alCurrentPage - 1) * AL_PER_PAGE + 1;
    const to = Math.min(alCurrentPage * AL_PER_PAGE, alTotalRecords);

    document.getElementById('showingFrom').textContent = from;
    document.getElementById('showingTo').textContent = to;
    document.getElementById('totalRecords').textContent = alTotalRecords;
    document.getElementById('currentPage').textContent = alCurrentPage;
    document.getElementById('totalPages').textContent = alTotalPages;

    document.getElementById('prevBtn').disabled = alCurrentPage <= 1;
    document.getElementById('nextBtn').disabled = alCurrentPage >= alTotalPages;
}

function clearFilters() {
    document.getElementById('filterTable').value = '';
    document.getElementById('filterAction').value = '';
    document.getElementById('filterUser').value = '';
    document.getElementById('filterDateFrom').value = '';
    document.getElementById('filterDateTo').value = '';
    document.getElementById('searchInput').value = '';
    alCurrentPage = 1;
    loadAuditLogs();
}

function viewDetail(auditId) {
    axios.get(`${AL_API}?operation=getAuditLogById&audit_id=${auditId}`)
        .then(res => {
            const data = res.data;
            if (!data.success) {
                Swal.fire({ icon: 'error', title: 'Error', text: data.message || 'Failed to load detail' });
                return;
            }
            const r = data.data;
            const grid = document.getElementById('auditDetailGrid');
            grid.innerHTML = `
                <dt>Audit ID</dt><dd>${r.audit_id}</dd>
                <dt>Timestamp</dt><dd>${formatDate(r.action_time)}</dd>
                <dt>User</dt><dd>${escapeHtml(r.username || '—')} (ID: ${r.user_id ?? '—'})</dd>
                <dt>Table</dt><dd><code>${escapeHtml(r.table_name)}</code></dd>
                <dt>Record ID</dt><dd>${r.record_id ?? '—'}</dd>
                <dt>Action</dt><dd><span class="action-badge ${(r.action || '').toLowerCase()}">${escapeHtml(r.action)}</span></dd>
                <dt>IP Address</dt><dd>${escapeHtml(r.ip_address || '—')}</dd>
            `;

            document.getElementById('detailOldValues').textContent = formatJson(r.old_values);
            document.getElementById('detailNewValues').textContent = formatJson(r.new_values);

            document.getElementById('detailModal').classList.add('active');
        })
        .catch(err => {
            console.error('Error loading audit detail:', err);
            Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to load audit log detail' });
        });
}

function closeDetailModal() {
    document.getElementById('detailModal').classList.remove('active');
}

// Helpers
function escapeHtml(str) {
    const div = document.createElement('div');
    div.textContent = String(str ?? '');
    return div.innerHTML;
}

function formatDate(dateStr) {
    if (!dateStr) return '—';
    const d = new Date(dateStr);
    if (isNaN(d.getTime())) return dateStr;
    return d.toLocaleString('en-PH', {
        year: 'numeric', month: 'short', day: 'numeric',
        hour: '2-digit', minute: '2-digit', second: '2-digit'
    });
}

function actionIcon(action) {
    switch ((action || '').toUpperCase()) {
        case 'INSERT': return 'plus-circle';
        case 'UPDATE': return 'pen';
        case 'DELETE': return 'trash-alt';
        default: return 'circle';
    }
}

function truncateJson(jsonStr) {
    if (!jsonStr) return '—';
    try {
        const obj = JSON.parse(jsonStr);
        const str = JSON.stringify(obj);
        return str.length > 60 ? str.substring(0, 60) + '…' : str;
    } catch {
        const str = String(jsonStr);
        return str.length > 60 ? str.substring(0, 60) + '…' : str;
    }
}

function formatJson(jsonStr) {
    if (!jsonStr) return '—';
    try {
        return JSON.stringify(JSON.parse(jsonStr), null, 2);
    } catch {
        return String(jsonStr);
    }
}
