const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const riskState = {
    schoolYears: [],
    gradingPeriods: [],
    gradeLevels: [],
    sections: [],
    selectedSchoolYearId: null,
    selectedGradingPeriodId: 'latest',
    selectedScope: 'school_year',
    selectedGradeLevelId: null,
    selectedSectionId: null,
    includeLow: false,
    lastLoadedRows: [],
    lastSummary: {
        total_records: 0,
        critical: 0,
        high: 0,
        moderate: 0,
        low: 0
    },
    lastPeriodMode: 'latest'
};

const riskAssessmentsApi = {
    list: async () => {
        const pendingFocusId = getPendingRiskFocusId();
        const params = {
            operation: 'getAtRiskLearners',
            include_low: riskState.includeLow ? 1 : 0
        };
        if (pendingFocusId) {
            params.risk_assessment_id = pendingFocusId;
        }
        if (riskState.selectedSchoolYearId) {
            params.school_year_id = riskState.selectedSchoolYearId;
        }
        if (riskState.selectedGradingPeriodId && riskState.selectedGradingPeriodId !== 'latest') {
            params.grading_period_id = riskState.selectedGradingPeriodId;
        }
        if (riskState.selectedScope === 'year_level' && riskState.selectedGradeLevelId) {
            params.grade_level_id = riskState.selectedGradeLevelId;
        }
        if (riskState.selectedScope === 'section' && riskState.selectedSectionId) {
            params.section_id = riskState.selectedSectionId;
        }

        const res = await axios.get(`${API_BASE_URL}/risk_assessments/risk_assessments.php`, { params });
        const payload = res.data;
        if (!payload?.success) {
            throw new Error(payload?.message || 'Failed to load at-risk learners');
        }

        const apiData = payload?.data || {};
        const rows = Array.isArray(apiData?.records) ? apiData.records : [];
        riskState.lastLoadedRows = rows;
        riskState.lastSummary = normalizeSummary(apiData?.summary, rows);
        riskState.lastPeriodMode = String(apiData?.period_mode || (riskState.selectedGradingPeriodId === 'latest' ? 'latest' : 'selected'));
        renderRiskDashboard();
        return rows;
    },
    automate: async () => {
        const params = { operation: 'computeAutomatedAssessments' };
        if (riskState.selectedSchoolYearId) {
            params.school_year_id = riskState.selectedSchoolYearId;
        }
        const res = await axios.post(`${API_BASE_URL}/risk_assessments/risk_assessments.php`, {}, { params });
        return res.data;
    }
};

function emptySummary() {
    return {
        total_records: 0,
        critical: 0,
        high: 0,
        moderate: 0,
        low: 0
    };
}

function normalizeSummary(summary, rows = []) {
    const src = summary && typeof summary === 'object' ? summary : {};
    const normalized = {
        total_records: Number(src.total_records || 0),
        critical: Number(src.critical || 0),
        high: Number(src.high || 0),
        moderate: Number(src.moderate || 0),
        low: Number(src.low || 0)
    };

    const invalid = Object.values(normalized).some((v) => Number.isNaN(v));
    if (!invalid && normalized.total_records > 0) {
        return normalized;
    }

    const inferred = emptySummary();
    const items = Array.isArray(rows) ? rows : [];
    inferred.total_records = items.length;
    items.forEach((row) => {
        const label = String(row?.risk_name || '').toLowerCase();
        if (label.includes('critical')) inferred.critical += 1;
        else if (label.includes('high')) inferred.high += 1;
        else if (label.includes('moderate')) inferred.moderate += 1;
        else inferred.low += 1;
    });
    return inferred;
}

const schoolYearsApi = {
    list: async () => axios.get(`${API_BASE_URL}/school_years/school_years.php`, { params: { operation: 'getAllSchoolYears' } }).then((r) => r.data)
};

const gradingPeriodsApi = {
    list: async () => axios.get(`${API_BASE_URL}/grading_periods/grading_periods.php`, { params: { operation: 'getAllGradingPeriods' } }).then((r) => r.data)
};

const gradeLevelsApi = {
    list: async () => axios.get(`${API_BASE_URL}/grade_levels/grade_levels.php`, { params: { operation: 'getAllGradeLevels' } }).then((r) => r.data)
};

const sectionsApi = {
    list: async (schoolYearId) => axios.get(`${API_BASE_URL}/sections/sections.php`, {
        params: {
            operation: 'getAllSections',
            ...(schoolYearId ? { school_year_id: schoolYearId } : {})
        }
    }).then((r) => r.data)
};

function notify(type, message) {
    const normalized = (type === 'success' || type === 'error' || type === 'info') ? type : 'info';
    if (typeof window.showNotification === 'function') {
        window.showNotification(message, normalized);
        return;
    }
    if (typeof Swal !== 'undefined' && typeof Swal.fire === 'function') {
        Swal.fire({
            toast: true,
            position: 'bottom-end',
            showConfirmButton: false,
            timer: normalized === 'error' ? 4500 : 2600,
            timerProgressBar: true,
            icon: normalized,
            title: message,
            customClass: {
                popup: `deped-toast deped-toast--${normalized}`
            }
        });
        return;
    }
    if (typeof window.alert === 'function') {
        window.alert(message);
    }
}

function escapeHtml(value) {
    return String(value ?? '')
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

function fmt2(value) {
    if (value === null || value === undefined || value === '' || Number.isNaN(Number(value))) return '—';
    return Number(value).toFixed(2);
}

function fmtPercent(value) {
    if (value === null || value === undefined || value === '' || Number.isNaN(Number(value))) return '—';
    return `${Number(value).toFixed(2)}%`;
}

function slugify(value) {
    return String(value ?? '')
        .trim()
        .replace(/[\\/:*?"<>|]+/g, '-')
        .replace(/\s+/g, '_')
        .replace(/_+/g, '_')
        .slice(0, 90);
}

function csvCell(value) {
    const text = String(value ?? '');
    return `"${text.replace(/"/g, '""')}"`;
}

function downloadFile(filename, content, mimeType) {
    const blob = new Blob([content], { type: mimeType });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    a.remove();
    URL.revokeObjectURL(url);
}

function getCurrentSchoolYearLabel() {
    const syId = Number(riskState.selectedSchoolYearId || 0);
    const row = riskState.schoolYears.find((x) => Number(x.school_year_id) === syId);
    return row?.year_label || '';
}

function getCurrentPeriodLabel() {
    if (riskState.selectedGradingPeriodId === 'latest') return 'Latest per learner';
    const gpId = Number(riskState.selectedGradingPeriodId || 0);
    const row = riskState.gradingPeriods.find((x) => Number(x.grading_period_id) === gpId);
    return row?.period_name || '';
}

function buildDepEdRiskAdvisory(summary) {
    const critical = Number(summary?.critical || 0);
    const high = Number(summary?.high || 0);
    const moderate = Number(summary?.moderate || 0);
    const atRiskTotal = critical + high + moderate;

    if (atRiskTotal <= 0) {
        return 'No learners are currently classified under Moderate, High, or Critical risk for the selected scope and period.';
    }

    return `${atRiskTotal} learner(s) are currently flagged for intervention support under Moderate (${moderate}), High (${high}), and Critical (${critical}) risk classifications based on available academic and attendance indicators.`;
}

function buildRiskTotalsLine(summary) {
    const totalShown = Number(summary?.total_records || 0);
    const critical = Number(summary?.critical || 0);
    const high = Number(summary?.high || 0);
    const moderate = Number(summary?.moderate || 0);
    const low = Number(summary?.low || 0);
    return `Total learners shown in this report: ${totalShown} | Critical: ${critical} | High: ${high} | Moderate: ${moderate} | Low: ${low}`;
}

function renderRiskDashboard() {
    const summary = normalizeSummary(riskState.lastSummary, riskState.lastLoadedRows);
    riskState.lastSummary = summary;

    const contextEl = document.getElementById('riskContextLine');
    if (contextEl) {
        const sy = getCurrentSchoolYearLabel() || 'N/A';
        const period = getCurrentPeriodLabel() || (riskState.lastPeriodMode === 'latest' ? 'Latest per learner' : 'Selected period');
        const lowFlag = riskState.includeLow ? 'Included' : 'Excluded';
        const atRiskTotal = summary.critical + summary.high + summary.moderate;

        let scopeLabel = 'Whole School Year';
        if (riskState.selectedScope === 'year_level') {
            const gl = riskState.gradeLevels.find((g) => Number(g.grade_level_id) === Number(riskState.selectedGradeLevelId));
            scopeLabel = gl?.grade_name ? `Year Level: ${gl.grade_name}` : 'Year Level';
        } else if (riskState.selectedScope === 'section') {
            const sec = riskState.sections.find((s) => Number(s.section_id) === Number(riskState.selectedSectionId));
            scopeLabel = sec?.section_name ? `Section: ${sec.section_name}` : 'Section';
        }

        contextEl.textContent = `DepEd Context: SY ${sy} | ${scopeLabel} | Period: ${period} | At-Risk Learners: ${atRiskTotal} | Low Risk: ${lowFlag}`;
    }

}

let riskTableObserver = null;
let riskFocusApplied = false;
let riskFocusJumpAttempted = false;
const RISK_FOCUS_STORAGE_KEY = 'focusRiskAssessmentId';
const RISK_FOCUS_CONTEXT_STORAGE_KEY = 'focusRiskAssessmentContext';

function getPendingRiskFocusId() {
    try {
        const raw = sessionStorage.getItem(RISK_FOCUS_STORAGE_KEY);
        const id = Number(raw || 0);
        return Number.isFinite(id) && id > 0 ? id : null;
    } catch (_) {
        return null;
    }
}

function clearPendingRiskFocusId() {
    try {
        sessionStorage.removeItem(RISK_FOCUS_STORAGE_KEY);
    } catch (_) {
        // ignore
    }

    riskFocusJumpAttempted = false;
}

function getPendingRiskFocusContext() {
    try {
        const raw = sessionStorage.getItem(RISK_FOCUS_CONTEXT_STORAGE_KEY);
        if (!raw) return null;
        const parsed = JSON.parse(raw);
        return parsed && typeof parsed === 'object' ? parsed : null;
    } catch (_) {
        return null;
    }
}

function clearPendingRiskFocusContext() {
    try {
        sessionStorage.removeItem(RISK_FOCUS_CONTEXT_STORAGE_KEY);
    } catch (_) {
        // ignore
    }
}

function normalizeMatchText(value) {
    return String(value ?? '')
        .toLowerCase()
        .replace(/\s+/g, ' ')
        .trim();
}

function extractLearnerHintFromContext(context) {
    const msg = String(context?.message || '').trim();
    const title = String(context?.title || '').trim();
    const src = msg || title;
    if (!src) return '';

    // Example message pattern: "Lastname, Firstname (Grade Section) flagged as High ..."
    const match = src.match(/^(.+?)(?:\s*\(|\s+flagged\s+as\b)/i);
    const candidate = (match && match[1]) ? match[1] : src;
    return String(candidate).replace(/\s+/g, ' ').trim();
}

function getRiskColumnsFromNotification(rowData, context) {
    const fallback = ['learner_name', 'risk_name', 'indicators'];
    if (!rowData || typeof rowData !== 'object') return fallback;

    const sourceText = normalizeMatchText(`${context?.title || ''} ${context?.message || ''}`);
    const candidates = [
        'learner_name',
        'lrn',
        'section_name',
        'grade_name',
        'period_name',
        'risk_name',
        'indicators'
    ];

    const matched = candidates.filter((key) => {
        const val = normalizeMatchText(rowData[key]);
        return val !== '' && sourceText.includes(val);
    });

    if (!matched.includes('learner_name')) matched.unshift('learner_name');
    if (!matched.includes('risk_name')) matched.push('risk_name');

    const unique = Array.from(new Set(matched));
    return unique.length ? unique : fallback;
}

function highlightRiskRowCells(rowEl, columnKeys, outlineColor) {
    if (!rowEl) return;

    rowEl.classList.add('notif-focus-row');
    rowEl.style.outline = `3px solid ${outlineColor}`;
    rowEl.style.outlineOffset = '-2px';

    const keys = Array.isArray(columnKeys) ? columnKeys : [];
    keys.forEach((key) => {
        const td = rowEl.querySelector(`td[data-col-key="${String(key)}"]`);
        if (!td) return;
        td.classList.add('notif-focus-cell');
    });
}

function clearRiskRowCellHighlight(rowEl) {
    if (!rowEl) return;
    rowEl.classList.remove('notif-focus-row');
    rowEl.style.outline = '';
    rowEl.style.outlineOffset = '';
    rowEl.querySelectorAll('td.notif-focus-cell').forEach((td) => td.classList.remove('notif-focus-cell'));
}

function applyPendingRiskNotificationFocus() {
    if (riskFocusApplied) return;

    const focusId = getPendingRiskFocusId();
    if (!focusId) return;

    const tbody = document.getElementById('dataTableBody');
    if (!tbody) return;

    let rowEl = tbody.querySelector(`tr[data-row-id="${String(focusId)}"]`);
    const context = getPendingRiskFocusContext();

    if (!rowEl && !riskFocusJumpAttempted) {
        let jumped = false;

        if (typeof window.masterfileGoToRowById === 'function') {
            jumped = Boolean(window.masterfileGoToRowById(focusId));
        }

        if (!jumped && typeof window.masterfileFindRowIdByPredicate === 'function' && typeof window.masterfileGoToRowById === 'function') {
            const learnerHint = extractLearnerHintFromContext(context);
            if (learnerHint) {
                const resolvedId = window.masterfileFindRowIdByPredicate((row) => normalizeMatchText(row?.learner_name).includes(normalizeMatchText(learnerHint)));
                if (resolvedId !== null && resolvedId !== undefined && resolvedId !== '') {
                    jumped = Boolean(window.masterfileGoToRowById(resolvedId));
                }
            }
        }

        riskFocusJumpAttempted = true;
        if (jumped) {
            rowEl = tbody.querySelector(`tr[data-row-id="${String(focusId)}"]`)
                || tbody.querySelector('tr[data-row-id]');
        }
        if (!rowEl) return;
    }

    if (!rowEl) {
        if (riskFocusJumpAttempted) {
            const hasRenderedRows = tbody.querySelectorAll('tr[data-row-id]').length > 0;
            const hasEmptyState = Boolean(tbody.querySelector('.empty-state'));
            if (hasRenderedRows || hasEmptyState) {
                clearPendingRiskFocusId();
                clearPendingRiskFocusContext();
                riskFocusApplied = true;
            }
        }
        return;
    }

    const rowData = riskState.lastLoadedRows.find((r) => Number(r?.risk_assessment_id) === focusId) || null;
    const outlineColor = String(rowData?.color_code || '#2563eb');
    const resolvedRowId = Number(rowEl?.getAttribute('data-row-id') || 0);
    const effectiveRowData = riskState.lastLoadedRows.find((r) => Number(r?.risk_assessment_id) === resolvedRowId)
        || rowData
        || null;
    const columnKeys = getRiskColumnsFromNotification(effectiveRowData, context);

    highlightRiskRowCells(rowEl, columnKeys, outlineColor);

    try {
        rowEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
    } catch (_) {
        rowEl.scrollIntoView(true);
    }

    window.setTimeout(() => {
        clearRiskRowCellHighlight(rowEl);
    }, 7000);

    riskFocusApplied = true;
    clearPendingRiskFocusId();
    clearPendingRiskFocusContext();
}

function animateRiskTableRows() {
    // Animations intentionally disabled to avoid interference with notification focus highlighting.
}

function installRiskTableAnimationObserver() {
    const tbody = document.getElementById('dataTableBody');
    if (!tbody || riskTableObserver) return;

    riskTableObserver = new MutationObserver(() => {
        animateRiskTableRows();
        applyPendingRiskNotificationFocus();
    });

    riskTableObserver.observe(tbody, { childList: true });
    animateRiskTableRows();
    applyPendingRiskNotificationFocus();
}

function buildCsv(rows) {
    const headers = [
        'Learner',
        'LRN',
        'Section',
        'Grade Level',
        'School Year',
        'Period',
        'Risk Level',
        'General Average',
        'Period Average',
        'Absence Rate',
        'Indicators',
        'Notes'
    ];

    const lines = [headers.map(csvCell).join(',')];
    rows.forEach((row) => {
        lines.push([
            row.learner_name,
            row.lrn,
            row.section_name,
            row.grade_name,
            row.year_label,
            row.period_name,
            row.risk_name,
            fmt2(row.general_average),
            fmt2(row.period_average),
            fmtPercent(row.attendance_rate),
            row.indicators,
            row.notes
        ].map(csvCell).join(','));
    });

    return `\uFEFF${lines.join('\n')}`;
}

function buildRiskTemplateContent(rows, options = {}) {
    const generatedDate = new Date().toLocaleDateString('en-PH', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });

    const summary = normalizeSummary(riskState.lastSummary, rows);
    const syLabel = escapeHtml(getCurrentSchoolYearLabel() || 'N/A');
    const periodLabel = escapeHtml(getCurrentPeriodLabel() || 'Latest per learner');
    const includeLow = riskState.includeLow ? 'Included' : 'Excluded';

    let scopeLabel = 'Whole School Year';
    if (riskState.selectedScope === 'year_level') {
        const gl = riskState.gradeLevels.find((g) => Number(g.grade_level_id) === Number(riskState.selectedGradeLevelId));
        scopeLabel = gl?.grade_name ? `Year Level: ${gl.grade_name}` : 'Year Level';
    } else if (riskState.selectedScope === 'section') {
        const sec = riskState.sections.find((s) => Number(s.section_id) === Number(riskState.selectedSectionId));
        scopeLabel = sec?.section_name ? `Section: ${sec.section_name}` : 'Section';
    }

    const appBase = (typeof window !== 'undefined' && window.APP_BASE) ? String(window.APP_BASE) : '';
    const leftLogoUrl = options.leftLogoUrl || `${appBase}/assets/img/logo/logo.jpg`;
    const rightLogoUrl = options.rightLogoUrl || `${appBase}/assets/img/logo/pngegg.png`;

    const tableHtml = (() => {
        if (!rows.length) {
            return '<p class="empty-note">No at-risk learners found for the selected filters.</p>';
        }

        const body = rows.map((row, idx) => {
            const riskClass = String(row.risk_name || '')
                .toLowerCase()
                .replace(/[^a-z0-9]+/g, '-')
                .replace(/^-+|-+$/g, '');

            return `
                <tr>
                    <td class="ta-center fw-700">${idx + 1}</td>
                    <td class="fw-700">${escapeHtml(row.learner_name)}</td>
                    <td class="ta-center">${escapeHtml(row.lrn)}</td>
                    <td>${escapeHtml(`${row.section_name || ''} · ${row.grade_name || ''}`)}</td>
                    <td class="ta-center">${escapeHtml(row.period_name || '')}</td>
                    <td class="ta-center"><span class="risk-pill risk-pill--${riskClass}">${escapeHtml(row.risk_name || '')}</span></td>
                    <td class="ta-center fw-700">${escapeHtml(fmt2(row.general_average))}</td>
                    <td class="ta-center fw-700">${escapeHtml(fmt2(row.period_average))}</td>
                    <td class="ta-center fw-700">${escapeHtml(fmtPercent(row.attendance_rate))}</td>
                    <td>${escapeHtml(row.indicators || row.notes || '—')}</td>
                </tr>`;
        }).join('');

        return `
            <table class="risk-table">
                <thead>
                    <tr>
                        <th class="w-rank">#</th>
                        <th>Learner</th>
                        <th class="w-lrn">LRN</th>
                        <th class="w-section">Section / Grade</th>
                        <th class="w-period">Period</th>
                        <th class="w-risk">Risk</th>
                        <th class="w-score">Gen. Avg.</th>
                        <th class="w-score">Period Avg.</th>
                        <th class="w-score">Absence %</th>
                        <th>Indicators / Notes</th>
                    </tr>
                </thead>
                <tbody>${body}</tbody>
            </table>`;
    })();

    return `
        <div class="risk-sheet">
            <div class="sheet-head">
                <div class="logo-wrap"><img src="${leftLogoUrl}" alt="DepEd Logo" /></div>
                <div class="head-center">
                    <div class="line1">Republic of the Philippines</div>
                    <div class="line2">Department of Education</div>
                    <div class="line3">DepEd Academic Monitoring System</div>
                    <div class="title">Learner Risk Monitoring Report</div>
                    <div class="subtitle">${escapeHtml(scopeLabel)} · ${periodLabel} · SY ${syLabel}</div>
                </div>
                <div class="logo-wrap logo-wrap-right"><img src="${rightLogoUrl}" alt="DepEd Seal" /></div>
            </div>

            <div class="meta-row">
                <div><b>School Year:</b> ${syLabel}</div>
                <div><b>Scope:</b> ${escapeHtml(scopeLabel)}</div>
                <div><b>Period:</b> ${periodLabel}</div>
                <div><b>Low Risk:</b> ${escapeHtml(includeLow)}</div>
                <div><b>Date:</b> ${escapeHtml(generatedDate)}</div>
            </div>

            <div class="table-wrap">${tableHtml}</div>

            <div class="sheet-foot">Generated by SIAS · DepEd Academic Monitoring System</div>
        </div>`;
}

function getRiskTemplateCss() {
    return `
:root{--gray-900:#111827;--gray-600:#4B5563;--critical:#b91c1c;--high:#c2410c;--moderate:#a16207;--low:#166534}
*{box-sizing:border-box}
body{margin:0;padding:0;background:#fff;color:var(--gray-900);font-family:Arial,Helvetica,sans-serif;-webkit-print-color-adjust:exact;print-color-adjust:exact}
img{display:block}
.risk-sheet{padding:18px 22px;color:var(--gray-900)}
.sheet-head{border-bottom:2px solid var(--gray-900);padding-bottom:14px;margin-bottom:16px}
.sheet-head{display:flex;align-items:center;justify-content:space-between;gap:12px}
.logo-wrap{width:140px;display:flex;align-items:center;justify-content:flex-start}
.logo-wrap-right{justify-content:flex-end}
.logo-wrap img{height:92px;width:auto;object-fit:contain}
.head-center{text-align:center;flex:1}
.line1{font-size:12px;font-weight:700;text-transform:uppercase}
.line2{font-size:13px;font-weight:900;text-transform:uppercase}
.line3{font-size:11px;margin-top:2px}
.title{font-size:15px;font-weight:900;text-transform:uppercase;margin-top:8px}
.subtitle{font-size:12px;color:var(--gray-600);margin-top:4px}
.meta-row{display:flex;justify-content:space-between;gap:12px;flex-wrap:wrap;font-size:12px;margin-bottom:12px}
.table-wrap{margin-top:12px}
.risk-table{width:100%;border-collapse:collapse;font-size:11px;color:var(--gray-900)}
.risk-table th,.risk-table td{border:1px solid var(--gray-900);padding:6px;vertical-align:top}
.risk-table th{font-weight:700;text-align:center;background:#fff}
.w-rank{width:42px}
.w-lrn{width:136px}
.w-section{width:148px}
.w-period{width:88px}
.w-risk{width:96px}
.w-score{width:72px}
.ta-center{text-align:center}
.fw-700{font-weight:700}
.risk-pill{display:inline-block;border:1px solid #334155;border-radius:999px;padding:2px 8px;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.3px;white-space:nowrap}
.risk-pill--critical{border-color:var(--critical);color:var(--critical)}
.risk-pill--high{border-color:var(--high);color:var(--high)}
.risk-pill--moderate{border-color:var(--moderate);color:var(--moderate)}
.risk-pill--low{border-color:var(--low);color:var(--low)}
.empty-note{text-align:center;font-style:italic;padding:18px}
.sheet-foot{margin-top:18px;font-size:11px;text-align:center;color:var(--gray-600)}
@media print{
  @page{size:A4;margin:10mm}
  body{margin:0}
  .risk-sheet{padding:0}
}
`;
}

function buildHtml(rows, options = {}) {
    const content = buildRiskTemplateContent(rows, options);
    return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>Learner Risk Monitoring Report</title>
<style>${getRiskTemplateCss()}</style>
</head>
<body>${content}</body>
</html>`;
}

async function ensureHtml2Pdf() {
    if (window.html2pdf) return window.html2pdf;

    await new Promise((resolve, reject) => {
        const existing = document.querySelector('script[data-risk-html2pdf="1"]');
        if (existing) {
            existing.addEventListener('load', resolve, { once: true });
            existing.addEventListener('error', () => reject(new Error('Failed to load PDF library')), { once: true });
            return;
        }

        const script = document.createElement('script');
        script.src = 'https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js';
        script.async = true;
        script.dataset.riskHtml2pdf = '1';
        script.onload = resolve;
        script.onerror = () => reject(new Error('Failed to load PDF library'));
        document.head.appendChild(script);
    });

    if (!window.html2pdf) {
        throw new Error('PDF library is unavailable');
    }
    return window.html2pdf;
}

function mountRiskTemplate(rows, logos) {
    const mount = document.createElement('div');
    mount.style.position = 'fixed';
    mount.style.left = '-99999px';
    mount.style.top = '0';
    mount.style.width = '210mm';
    mount.style.background = '#fff';
    mount.style.zIndex = '-1';
    mount.innerHTML = `<style>${getRiskTemplateCss()}</style>${buildRiskTemplateContent(rows, logos)}`;
    document.body.appendChild(mount);
    return mount;
}

async function exportRiskPdf(rows, logos) {
    const html2pdfLib = await ensureHtml2Pdf();
    const mount = mountRiskTemplate(rows, logos);
    const sheet = mount.querySelector('.risk-sheet') || mount;
    const sy = slugify(getCurrentSchoolYearLabel() || 'school_year');
    const period = slugify(getCurrentPeriodLabel() || 'latest');

    try {
        await html2pdfLib()
            .set({
                filename: `at_risk_learners_${sy}_${period}.pdf`,
                margin: [8, 8, 8, 8],
                image: { type: 'png', quality: 1 },
                html2canvas: { scale: 3, useCORS: true, backgroundColor: '#ffffff', logging: false, letterRendering: true },
                jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' },
                pagebreak: { mode: ['css', 'legacy'] }
            })
            .from(sheet)
            .save();
    } finally {
        mount.remove();
    }
}

function printRiskTemplate(rows, logos) {
    return new Promise((resolve, reject) => {
        const iframe = document.createElement('iframe');
        iframe.style.position = 'fixed';
        iframe.style.right = '0';
        iframe.style.bottom = '0';
        iframe.style.width = '0';
        iframe.style.height = '0';
        iframe.style.border = '0';
        iframe.style.opacity = '0';

        const html = buildHtml(rows, logos);
        const cleanup = () => {
            setTimeout(() => {
                iframe.remove();
                resolve();
            }, 100);
        };

        iframe.onload = () => {
            const win = iframe.contentWindow;
            if (!win) {
                iframe.remove();
                reject(new Error('Unable to open print context'));
                return;
            }

            win.onafterprint = cleanup;
            setTimeout(() => {
                try {
                    win.focus();
                    win.print();
                    setTimeout(cleanup, 1200);
                } catch (error) {
                    iframe.remove();
                    reject(error);
                }
            }, 320);
        };

        document.body.appendChild(iframe);
        iframe.srcdoc = html;
    });
}

function blobToDataUrl(blob) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onerror = () => reject(new Error('Failed to read logo blob'));
        reader.onload = () => resolve(String(reader.result || ''));
        reader.readAsDataURL(blob);
    });
}

async function tryFetchAsDataUrl(url) {
    try {
        const res = await fetch(url, { credentials: 'include' });
        if (!res.ok) return null;
        return blobToDataUrl(await res.blob());
    } catch (_) {
        return null;
    }
}

async function resolveTemplateLogos() {
    const appBase = (typeof window !== 'undefined' && window.APP_BASE) ? String(window.APP_BASE) : '';
    const leftPath = `${appBase}/assets/img/logo/logo.jpg`;
    const rightPath = `${appBase}/assets/img/logo/pngegg.png`;
    const leftAbs = new URL(leftPath, window.location.origin).toString();
    const rightAbs = new URL(rightPath, window.location.origin).toString();

    const [leftDataUrl, rightDataUrl] = await Promise.all([
        tryFetchAsDataUrl(leftAbs),
        tryFetchAsDataUrl(rightAbs)
    ]);

    return {
        leftLogoUrl: leftDataUrl || leftAbs,
        rightLogoUrl: rightDataUrl || rightAbs
    };
}

async function reloadRecords() {
    if (typeof window.reloadMasterfileRecords === 'function') {
        await window.reloadMasterfileRecords();
        return;
    }
    window.location.reload();
}

async function runAutomation(options = {}) {
    const silent = Boolean(options.silent);
    const payload = await riskAssessmentsApi.automate();
    if (!payload?.success) {
        throw new Error(payload?.message || 'Automation failed');
    }

    if (!silent) {
        const d = payload.data || {};
        notify('success', `Automation complete: ${d.risk_assessments_upserted || 0} assessments, ${d.risk_indicators_upserted || 0} indicators.`);
    }
}

function fillSchoolYearFilter() {
    const sel = document.getElementById('filterSchoolYear');
    if (!sel) return;

    sel.innerHTML = '';
    riskState.schoolYears.forEach((row) => {
        const opt = document.createElement('option');
        opt.value = String(row.school_year_id);
        opt.textContent = row.year_label || `${row.year_start}-${row.year_end}`;
        if (Number(row.school_year_id) === Number(riskState.selectedSchoolYearId)) {
            opt.selected = true;
        }
        sel.appendChild(opt);
    });
}

function fillPeriodFilter() {
    const sel = document.getElementById('filterPeriod');
    if (!sel) return;

    const syId = Number(riskState.selectedSchoolYearId || 0);
    const periods = riskState.gradingPeriods.filter((p) => Number(p.school_year_id) === syId);

    sel.innerHTML = '';

    const latestOpt = document.createElement('option');
    latestOpt.value = 'latest';
    latestOpt.textContent = 'Latest per learner';
    sel.appendChild(latestOpt);

    periods
        .sort((a, b) => Number(a.grading_period_id) - Number(b.grading_period_id))
        .forEach((p) => {
            const opt = document.createElement('option');
            opt.value = String(p.grading_period_id);
            opt.textContent = p.period_name;
            sel.appendChild(opt);
        });

    const stillExists = Array.from(sel.options).some((o) => o.value === String(riskState.selectedGradingPeriodId));
    if (!stillExists) {
        riskState.selectedGradingPeriodId = 'latest';
    }
    sel.value = String(riskState.selectedGradingPeriodId);
}

function populateFilterSelect(selectEl, items, valueKey, labelKey, placeholder) {
    if (!selectEl) return;

    selectEl.innerHTML = '';
    if (placeholder) {
        const opt = document.createElement('option');
        opt.value = '';
        opt.textContent = placeholder;
        selectEl.appendChild(opt);
    }

    items.forEach((item) => {
        const opt = document.createElement('option');
        opt.value = String(item[valueKey]);
        opt.textContent = String(item[labelKey] || '');
        selectEl.appendChild(opt);
    });
}

function fillGradeLevelFilter() {
    const sel = document.getElementById('filterGradeLevel');
    if (!sel) return;

    const items = [...riskState.gradeLevels].sort((a, b) => String(a.grade_name || '').localeCompare(String(b.grade_name || '')));
    populateFilterSelect(sel, items, 'grade_level_id', 'grade_name', 'All Year Levels');

    if (riskState.selectedGradeLevelId) {
        sel.value = String(riskState.selectedGradeLevelId);
    } else {
        sel.value = '';
    }
}

function fillSectionFilter() {
    const sel = document.getElementById('filterSection');
    if (!sel) return;

    const items = [...riskState.sections].sort((a, b) => String(a.section_name || '').localeCompare(String(b.section_name || '')));
    populateFilterSelect(sel, items, 'section_id', 'section_name', 'All Sections');

    const exists = items.some((s) => Number(s.section_id) === Number(riskState.selectedSectionId));
    if (!exists) {
        riskState.selectedSectionId = null;
    }

    sel.value = riskState.selectedSectionId ? String(riskState.selectedSectionId) : '';
}

function updateScopeUI() {
    const scope = riskState.selectedScope || 'school_year';
    const glWrap = document.getElementById('filterGradeLevelWrap');
    const secWrap = document.getElementById('filterSectionWrap');
    if (glWrap) glWrap.style.display = scope === 'year_level' ? 'block' : 'none';
    if (secWrap) secWrap.style.display = scope === 'section' ? 'block' : 'none';
}

async function loadSectionsForSelectedSchoolYear() {
    const rows = await sectionsApi.list(riskState.selectedSchoolYearId);
    riskState.sections = Array.isArray(rows) ? rows : [];
    fillSectionFilter();
}

async function loadFilters() {
    const [schoolYears, periods, gradeLevels] = await Promise.all([
        schoolYearsApi.list(),
        gradingPeriodsApi.list(),
        gradeLevelsApi.list()
    ]);

    riskState.schoolYears = Array.isArray(schoolYears) ? schoolYears : [];
    riskState.gradingPeriods = Array.isArray(periods) ? periods : [];
    riskState.gradeLevels = Array.isArray(gradeLevels) ? gradeLevels : [];

    const active = riskState.schoolYears.find((x) => Number(x.is_active) === 1);
    if (active) {
        riskState.selectedSchoolYearId = Number(active.school_year_id);
    } else if (riskState.schoolYears.length > 0) {
        riskState.selectedSchoolYearId = Number(riskState.schoolYears[0].school_year_id);
    }

    await loadSectionsForSelectedSchoolYear();

    fillSchoolYearFilter();
    fillPeriodFilter();
    fillGradeLevelFilter();
    fillSectionFilter();
    updateScopeUI();

    const includeLow = document.getElementById('filterIncludeLow');
    if (includeLow) {
        includeLow.checked = riskState.includeLow;
    }

    const scopeSel = document.getElementById('filterScope');
    if (scopeSel) {
        scopeSel.value = riskState.selectedScope;
    }

    renderRiskDashboard();
}

function wireFilters() {
    const sySel = document.getElementById('filterSchoolYear');
    const gpSel = document.getElementById('filterPeriod');
    const scopeSel = document.getElementById('filterScope');
    const gradeSel = document.getElementById('filterGradeLevel');
    const sectionSel = document.getElementById('filterSection');
    const includeLow = document.getElementById('filterIncludeLow');

    sySel?.addEventListener('change', async () => {
        riskState.selectedSchoolYearId = Number(sySel.value || 0) || null;
        fillPeriodFilter();
        await loadSectionsForSelectedSchoolYear();
        renderRiskDashboard();
        try {
            await runAutomation({ silent: true });
        } catch (e) {
            console.error(e);
            notify('error', e.message || 'Automatic refresh failed');
        }
        await reloadRecords();
    });

    gpSel?.addEventListener('change', async () => {
        riskState.selectedGradingPeriodId = gpSel.value || 'latest';
        renderRiskDashboard();
        await reloadRecords();
    });

    scopeSel?.addEventListener('change', async () => {
        riskState.selectedScope = scopeSel.value || 'school_year';
        updateScopeUI();
        renderRiskDashboard();
        await reloadRecords();
    });

    gradeSel?.addEventListener('change', async () => {
        riskState.selectedGradeLevelId = Number(gradeSel.value || 0) || null;
        renderRiskDashboard();
        if (riskState.selectedScope === 'year_level') {
            await reloadRecords();
        }
    });

    sectionSel?.addEventListener('change', async () => {
        riskState.selectedSectionId = Number(sectionSel.value || 0) || null;
        renderRiskDashboard();
        if (riskState.selectedScope === 'section') {
            await reloadRecords();
        }
    });

    includeLow?.addEventListener('change', async () => {
        riskState.includeLow = Boolean(includeLow.checked);
        renderRiskDashboard();
        await reloadRecords();
    });
}

function wireActionButtons() {
    const exportPanel = document.getElementById('riskExportPanel');
    const exportToggle = document.getElementById('btnRiskExportToggle');
    if (exportPanel && exportToggle) {
        const setExportOpen = (isOpen) => {
            exportPanel.classList.toggle('open', isOpen);
            exportToggle.classList.toggle('is-open', isOpen);
            exportToggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
        };

        setExportOpen(false);

        exportToggle.addEventListener('click', (event) => {
            event.preventDefault();
            event.stopPropagation();
            const isExpanded = exportToggle.getAttribute('aria-expanded') === 'true';
            setExportOpen(!isExpanded);
        });

        document.addEventListener('click', (event) => {
            const target = event.target;
            const clickedToggle = exportToggle.contains(target);
            const clickedPanel = exportPanel.contains(target);
            if (!clickedToggle && !clickedPanel) {
                setExportOpen(false);
            }
        });

        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape') {
                setExportOpen(false);
            }
        });
    }

    const exportCsvBtn = document.getElementById('btnRiskExportCsv');
    exportCsvBtn?.addEventListener('click', () => {
        const rows = Array.isArray(riskState.lastLoadedRows) ? riskState.lastLoadedRows : [];
        if (!rows.length) {
            notify('info', 'No records to export');
            return;
        }
        const sy = slugify(getCurrentSchoolYearLabel() || 'school_year');
        const period = slugify(getCurrentPeriodLabel() || 'latest');
        downloadFile(`at_risk_learners_${sy}_${period}.csv`, buildCsv(rows), 'text/csv;charset=utf-8;');
        exportPanel?.classList.remove('open');
        exportToggle?.classList.remove('is-open');
        exportToggle?.setAttribute('aria-expanded', 'false');
    });

    const exportPdfBtn = document.getElementById('btnRiskExportPdf');
    exportPdfBtn?.addEventListener('click', async () => {
        const rows = Array.isArray(riskState.lastLoadedRows) ? riskState.lastLoadedRows : [];
        if (!rows.length) {
            notify('info', 'No records to export');
            return;
        }

        try {
            const logos = await resolveTemplateLogos();
            await exportRiskPdf(rows, logos);
            exportPanel?.classList.remove('open');
            exportToggle?.classList.remove('is-open');
            exportToggle?.setAttribute('aria-expanded', 'false');
        } catch (error) {
            console.error(error);
            notify('error', 'Unable to export PDF');
        }
    });

    const printBtn = document.getElementById('btnRiskPrint');
    printBtn?.addEventListener('click', async () => {
        const rows = Array.isArray(riskState.lastLoadedRows) ? riskState.lastLoadedRows : [];
        if (!rows.length) {
            notify('info', 'No records to print');
            return;
        }

        try {
            const logos = await resolveTemplateLogos();
            await printRiskTemplate(rows, logos);
            exportPanel?.classList.remove('open');
            exportToggle?.classList.remove('is-open');
            exportToggle?.setAttribute('aria-expanded', 'false');
        } catch (error) {
            console.error(error);
            notify('error', 'Unable to render print template');
        }
    });
}

function buildMasterfileConfig() {
    return {
        key: 'risk_assessments',
        navKey: 'risk_assessment',
        entity: 'At-Risk Learner',
        pageTitle: 'Risk Assessments',
        subtitle: '',
        breadcrumb: 'Risk Assessments',
        addLabel: 'Run Auto Flag',
        primaryKey: 'risk_assessment_id',
        readOnly: true,
        columns: [
            { key: 'learner_name', label: 'Learner' },
            { key: 'lrn', label: 'LRN' },
            { key: 'section_name', label: 'Section' },
            { key: 'grade_name', label: 'Grade' },
            { key: 'period_name', label: 'Period' },
            {
                key: 'risk_name',
                label: 'Risk Level',
                formatter: (value, row) => {
                    const color = row?.color_code || '#4B5563';
                    const text = escapeHtml(value || 'Unknown');
                    return `<span class="tx-badge" style="border-color:${escapeHtml(color)}; color:${escapeHtml(color)};">${text}</span>`;
                }
            },
            { key: 'general_average', label: 'Gen. Avg.', formatter: (v) => fmt2(v) },
            { key: 'attendance_rate', label: 'Absence %', formatter: (v) => fmtPercent(v) },
            {
                key: 'indicators',
                label: 'Indicators',
                formatter: (v) => {
                    const text = String(v || '').trim();
                    if (!text) return '<span style="color: var(--gray-500);">None</span>';
                    const short = text.length > 90 ? `${text.slice(0, 90)}...` : text;
                    return `<span title="${escapeHtml(text)}">${escapeHtml(short)}</span>`;
                }
            }
        ],
        fields: [],
        api: {
            list: riskAssessmentsApi.list,
            create: async () => ({ success: false, message: 'Manual edit is disabled for automated risk module.' }),
            update: async () => ({ success: false, message: 'Manual edit is disabled for automated risk module.' }),
            remove: async () => ({ success: false, message: 'Manual edit is disabled for automated risk module.' })
        }
    };
}

document.addEventListener('DOMContentLoaded', async () => {
    try {
        // Keep notification click behavior simple: open page without targeted row/column focus.
        clearPendingRiskFocusId();
        clearPendingRiskFocusContext();

        installRiskTableAnimationObserver();

        await loadFilters();

        try {
            await runAutomation({ silent: true });
        } catch (e) {
            // Keep module usable even if automation call fails.
            console.error('Initial automation failed:', e);
        }

        initializeMasterfile(buildMasterfileConfig());
        wireActionButtons();
        wireFilters();
    } catch (error) {
        console.error(error);
        notify('error', error?.message || 'Failed to initialize risk module');
    }
});
