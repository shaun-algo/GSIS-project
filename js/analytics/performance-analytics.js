// ===========================
// Performance Analytics JavaScript
// ===========================

const API_BASE = window.API_BASE || `${window.location.protocol}//${window.location.host}/deped_capstone2/api`;

function escapeHtml(str) {
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

document.addEventListener('DOMContentLoaded', function() {
    loadPerformanceMetrics();
    initializeChart();
    loadAtRiskStudents();
});

// ===========================
// Load Performance Metrics
// ===========================

async function loadPerformanceMetrics() {
    try {
        const response = await axios.get(`${API_BASE}/dashboard/metrics.php`);

        if (response.data?.success && response.data.data.performance) {
            updatePerformanceChart(response.data.data.performance);
        }
    } catch (error) {
        console.error('Error loading performance metrics:', error);
    }
}

// ===========================
// Performance Chart
// ===========================

let performanceChart;

function initializeChart() {
    const ctx = document.getElementById('performanceChart');
    if (!ctx) return;

    performanceChart = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: [
                'Outstanding',
                'Very Satisfactory',
                'Satisfactory',
                'Fairly Satisfactory',
                'Did Not Meet Expectations'
            ],
            datasets: [{
                data: [0, 0, 0, 0, 0],
                backgroundColor: [
                    '#10B981',
                    '#3B82F6',
                    '#F59E0B',
                    '#A855F7',
                    '#EF4444'
                ],
                borderWidth: 2,
                borderColor: '#ffffff'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        padding: 15,
                        font: {
                            size: 12
                        }
                    }
                }
            }
        }
    });
}

function updatePerformanceChart(performanceData) {
    if (performanceChart && performanceData) {
        performanceChart.data.labels = performanceData.labels || performanceChart.data.labels;
        performanceChart.data.datasets[0].data = performanceData.data || [0, 0, 0, 0];
        performanceChart.update();
    }
}

// ===========================
// Load At-Risk Students
// ===========================

async function loadAtRiskStudents() {
    const alertsList = document.getElementById('alertsList');
    if (!alertsList) return;

    try {
        const response = await axios.get(`${API_BASE}/risk_assessments/risk_assessments.php`, {
            params: {
                operation: 'getAtRiskLearners',
                include_low: 0
            }
        });

        const records = response.data?.success ? (response.data?.data?.records || []) : [];

        if (!records.length) {
            alertsList.innerHTML = `
                <div class="alert-item">
                    <div class="alert-content">
                        <p class="alert-title">No at-risk learners</p>
                        <p class="alert-text">No at-risk learners were detected for the latest grading period.</p>
                    </div>
                </div>
            `;
            return;
        }

        const top = records.slice(0, 10);

        alertsList.innerHTML = top.map((r) => {
            const name = r.learner_name ? String(r.learner_name) : 'Learner';
            const grade = r.grade_name ? String(r.grade_name) : '';
            const section = r.section_name ? String(r.section_name) : '';

            const ga = r.general_average !== null && r.general_average !== undefined ? Number(r.general_average) : null;
            const pa = r.period_average !== null && r.period_average !== undefined ? Number(r.period_average) : null;
            const metricText = ga !== null && !Number.isNaN(ga)
                ? `GA: ${ga.toFixed(2)}`
                : (pa !== null && !Number.isNaN(pa) ? `Period Avg: ${pa.toFixed(2)}` : '');

            const detailsParts = [];
            if (grade || section) detailsParts.push([grade, section].filter(Boolean).join(' - '));
            if (metricText) detailsParts.push(metricText);

            const indicators = (r.indicators ? String(r.indicators) : '')
                .split('|')
                .map(s => s.trim())
                .filter(Boolean)
                .slice(0, 3);

            const riskName = r.risk_name ? String(r.risk_name) : 'At Risk';
            const rawRiskColor = r.color_code ? String(r.color_code) : '#F97316';
            const riskColor = /^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/.test(rawRiskColor)
                ? rawRiskColor
                : '#F97316';

            const safeName = escapeHtml(name);
            const safeDetails = escapeHtml(detailsParts.join(' | '));
            const safeRiskName = escapeHtml(riskName);

            return `
                <div class="alert-item">
                    <div class="student-avatar">
                        <i class="fas fa-user-circle"></i>
                    </div>
                    <div class="alert-content">
                        <p class="student-name">${safeName}</p>
                        <p class="student-details">${safeDetails}</p>
                        <div class="risk-indicators">
                            <span class="badge" style="background:${riskColor}; color:#fff;">${safeRiskName}</span>
                            ${indicators.map((i) => `<span class="badge badge-warning">${escapeHtml(i)}</span>`).join('')}
                        </div>
                    </div>
                </div>
            `;
        }).join('');
    } catch (error) {
        console.error('Error loading at-risk students:', error);
        alertsList.innerHTML = `
            <div class="alert-item">
                <div class="alert-content">
                    <p class="alert-title">At-risk list unavailable</p>
                    <p class="alert-text">Failed to load at-risk learners from the server.</p>
                </div>
            </div>
        `;
    }
}
