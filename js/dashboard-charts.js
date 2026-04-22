// ===========================
// Dashboard Charts JavaScript
// Using Chart.js
// ===========================

document.addEventListener('DOMContentLoaded', function() {
    wireDashboardButtons();

    // If metrics are already loaded by dashboard.js, use them; else fetch locally
    if (window.dashboardMetrics) {
        initializeCharts(window.dashboardMetrics);
    } else {
        fetchMetricsAndInit();
    }
});

function wireDashboardButtons() {
    // Admin dashboard embedded "Generate Report" button
    const overviewGenerateBtn = document.querySelector('#dashboard-overviewSection .page-header > button.btn.btn-primary');
    if (overviewGenerateBtn) {
        overviewGenerateBtn.addEventListener('click', () => {
            window.location.href = '../pages/analytics/dashboard-overview.html';
        });
    }

    // Admin dashboard embedded "View All Notifications" button
    const overviewViewAllBtn = document.querySelector('#dashboard-overviewSection .alerts-card .btn.btn-outline.btn-block');
    if (overviewViewAllBtn) {
        overviewViewAllBtn.addEventListener('click', () => {
            window.location.href = '../pages/notifications.html';
        });
    }

    // Admin dashboard embedded "Quick Actions"
    const quickActionButtons = Array.from(document.querySelectorAll('#dashboard-overviewSection .quick-actions-card .quick-actions > button'));
    if (quickActionButtons.length) {
        quickActionButtons.forEach((button) => {
            const label = String(button.textContent || '').trim().toLowerCase();
            button.addEventListener('click', () => {
                if (label.includes('learner') || label.includes('student')) {
                    window.location.href = '../pages/masterfiles/learners.html';
                    return;
                }
                if (label.includes('enrollment')) {
                    window.location.href = '../pages/enrollments.html';
                    return;
                }
                if (label.includes('report')) {
                    window.location.href = '../pages/analytics/dashboard-overview.html';
                    return;
                }
                if (label.includes('analytics')) {
                    window.location.href = '../pages/analytics/dashboard-overview.html';
                }
            });
        });
    }

}

// Listen for shared metrics from dashboard.js
document.addEventListener('dashboard:metrics', function(event) {
    initializeCharts(event.detail);
});

// ===========================
// Initialize All Charts
// ===========================

// Ensure API_BASE is set (same-origin)
if (!window.API_BASE) {
    const pathname = String(window.location.pathname || '/');
    let appPrefix = '';

    if (pathname.includes('/dashboard/')) {
        appPrefix = pathname.split('/dashboard/')[0] || '';
    } else if (pathname.includes('/pages/')) {
        appPrefix = pathname.split('/pages/')[0] || '';
    } else if (pathname.includes('/api/')) {
        appPrefix = pathname.split('/api/')[0] || '';
    } else {
        const parts = pathname.split('/').filter(Boolean);
        appPrefix = parts.length ? `/${parts[0]}` : '';
    }

    if (appPrefix === '/') appPrefix = '';

    const isApacheServed = pathname.includes('/deped_capstone2/');
    window.API_BASE = isApacheServed
        ? `${appPrefix}/api`
        : `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;
}

async function fetchMetricsAndInit() {
    try {
        const response = await axios.get(`${window.API_BASE}/dashboard/metrics.php`);
        if (response.data?.success) {
            initializeCharts(response.data.data);
        }
    } catch (err) {
        console.error('Unable to load metrics for charts', err);
    }
}

function initializeCharts(metrics) {
    createEnrollmentChart(metrics?.enrollmentTrend);
    createGradeDistributionChart(metrics?.gradeDistribution);
    createPerformanceChart(metrics?.performance);
}

function destroyChartIfExists(canvas) {
    if (!canvas || !window.Chart || typeof Chart.getChart !== 'function') {
        return;
    }
    const existing = Chart.getChart(canvas);
    if (existing) {
        existing.destroy();
    }
}

// ===========================
// Enrollment Trend Chart
// ===========================

function createEnrollmentChart(dataset) {
    const ctx = document.getElementById('enrollmentChart');
    if (!ctx) return;

    destroyChartIfExists(ctx);

    const labels = dataset?.labels?.length ? dataset.labels : ['June', 'July', 'August', 'September', 'October', 'November'];
    const dataPoints = dataset?.data?.length ? dataset.data : [420, 435, 448, 452, 450, 445];

    const data = {
        labels,
        datasets: [{
            label: 'Students Enrolled',
            data: dataPoints,
            borderColor: '#0055A4',
            backgroundColor: 'rgba(0, 85, 164, 0.1)',
            borderWidth: 2,
            tension: 0.4,
            fill: true,
            pointBackgroundColor: '#0055A4',
            pointBorderColor: '#fff',
            pointHoverBackgroundColor: '#fff',
            pointHoverBorderColor: '#0055A4',
            pointRadius: 4,
            pointHoverRadius: 6
        }]
    };

    new Chart(ctx, {
        type: 'line',
        data: data,
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    padding: 12,
                    titleFont: {
                        size: 14
                    },
                    bodyFont: {
                        size: 13
                    },
                    callbacks: {
                        label: function(context) {
                            return 'Enrolled: ' + context.parsed.y + ' students';
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: false,
                    grid: {
                        borderDash: [5, 5]
                    },
                    ticks: {
                        font: {
                            size: 12
                        }
                    }
                },
                x: {
                    grid: {
                        display: false
                    },
                    ticks: {
                        font: {
                            size: 12
                        }
                    }
                }
            }
        }
    });
}

// ===========================
// Grade Distribution Chart
// ===========================

function createGradeDistributionChart(dataset) {
    const ctx = document.getElementById('gradeDistributionChart');
    if (!ctx) return;

    destroyChartIfExists(ctx);

    const labels = dataset?.labels?.length ? dataset.labels : ['Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'];
    const dataPoints = dataset?.data?.length ? dataset.data : [120, 105, 98, 92, 65, 58];

    const data = {
        labels,
        datasets: [{
            label: 'Number of Students',
            data: dataPoints,
            backgroundColor: '#A4D65E',
            borderColor: '#8BC244',
            borderWidth: 1,
            borderRadius: 6,
            barThickness: 40
        }]
    };

    new Chart(ctx, {
        type: 'bar',
        data: data,
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    padding: 12,
                    titleFont: {
                        size: 14
                    },
                    bodyFont: {
                        size: 13
                    },
                    callbacks: {
                        label: function(context) {
                            return 'Students: ' + context.parsed.y;
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        borderDash: [5, 5]
                    },
                    ticks: {
                        font: {
                            size: 12
                        },
                        stepSize: 20
                    }
                },
                x: {
                    grid: {
                        display: false
                    },
                    ticks: {
                        font: {
                            size: 12
                        }
                    }
                }
            }
        }
    });
}

// ===========================
// Performance Distribution Chart
// ===========================

function createPerformanceChart(dataset) {
    const ctx = document.getElementById('performanceChart');
    if (!ctx) return;

    destroyChartIfExists(ctx);

    const labels = dataset?.labels?.length ? dataset.labels : ['Outstanding', 'Very Satisfactory', 'Satisfactory', 'Fairly Satisfactory', 'Did Not Meet'];
    const dataPoints = dataset?.data?.length ? dataset.data : [15, 35, 38, 10, 2];

    const data = {
        labels,
        datasets: [{
            data: dataPoints,
            backgroundColor: [
                '#0055A4', // Outstanding - DepEd Blue
                '#A4D65E', // Very Satisfactory - DepEd Green
                '#FFD700', // Satisfactory - Gold
                '#FFA500', // Fairly Satisfactory - Orange
                '#FF6B6B'  // Did Not Meet - Red
            ],
            borderWidth: 2,
            borderColor: '#fff'
        }]
    };

    new Chart(ctx, {
        type: 'pie',
        data: data,
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
                        },
                        generateLabels: function(chart) {
                            const data = chart.data;
                            if (data.labels.length && data.datasets.length) {
                                return data.labels.map((label, i) => {
                                    const value = data.datasets[0].data[i];
                                    const total = data.datasets[0].data.reduce((a, b) => a + b, 0);
                                    const percentage = ((value / total) * 100).toFixed(1);

                                    return {
                                        text: `${label}: ${percentage}%`,
                                        fillStyle: data.datasets[0].backgroundColor[i],
                                        hidden: false,
                                        index: i
                                    };
                                });
                            }
                            return [];
                        }
                    }
                },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    padding: 12,
                    titleFont: {
                        size: 14
                    },
                    bodyFont: {
                        size: 13
                    },
                    callbacks: {
                        label: function(context) {
                            const label = context.label || '';
                            const value = context.parsed;
                            const total = context.dataset.data.reduce((a, b) => a + b, 0);
                            const percentage = ((value / total) * 100).toFixed(1);
                            return `${label}: ${value} students (${percentage}%)`;
                        }
                    }
                }
            }
        }
    });
}

// ===========================
// API Data Loading Functions
// ===========================

async function loadEnrollmentData() {
    try {
        // API call to get enrollment trend data
        // const response = await axios.get('../api/dashboard/enrollment-trend.php');
        // return response.data;

        // Sample data for now
        return {
            labels: ['June', 'July', 'August', 'September', 'October', 'November'],
            data: [420, 435, 448, 452, 450, 445]
        };
    } catch (error) {
        console.error('Error loading enrollment data:', error);
        return null;
    }
}

async function loadGradeDistributionData() {
    try {
        // API call to get grade distribution data
        // const response = await axios.get('../api/dashboard/grade-distribution.php');
        // return response.data;

        // Sample data for now
        return {
            labels: ['Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'],
            data: [120, 105, 98, 92, 65, 58]
        };
    } catch (error) {
        console.error('Error loading grade distribution data:', error);
        return null;
    }
}

async function loadPerformanceData() {
    try {
        // const response = await axios.get('../api/dashboard/performance.php');
        // return response.data;

        // Sample data for now
        return {
            labels: ['Outstanding', 'Very Satisfactory', 'Satisfactory', 'Fairly Satisfactory', 'Did Not Meet'],
            data: [15, 35, 38, 10, 2]
        };
    } catch (error) {
        console.error('Error loading performance data:', error);
        return null;
    }
}

// Export functions
window.chartUtils = {
    loadEnrollmentData,
    loadGradeDistributionData,
    loadPerformanceData,
    createEnrollmentChart,
    createGradeDistributionChart,
    createPerformanceChart
};
