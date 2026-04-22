// ===========================
// Dashboard Overview JavaScript
// ===========================

const API_BASE = window.API_BASE || `${window.location.protocol}//${window.location.host}/deped_capstone2/api`;

document.addEventListener('DOMContentLoaded', function() {
    loadDashboardMetrics();
    initializeCharts();
});

// ===========================
// Load Dashboard Metrics from API
// ===========================

async function loadDashboardMetrics() {
    try {
        const response = await axios.get(`${API_BASE}/dashboard/metrics.php`);

        if (response.data?.success) {
            const metrics = response.data.data;
            updateKPICards(metrics);
            updateCharts(metrics);
        } else {
            console.error('Failed to load metrics:', response.data);
        }
    } catch (error) {
        console.error('Error loading dashboard metrics:', error);
        // Load with fallback data
        loadFallbackData();
    }
}

function updateKPICards(metrics) {
    // Total Students
    if (metrics.stats?.totalStudents !== undefined) {
        document.getElementById('totalStudents').textContent = metrics.stats.totalStudents;
    }

    // Total Teachers
    if (metrics.stats?.totalTeachers !== undefined) {
        document.getElementById('totalTeachers').textContent = metrics.stats.totalTeachers;
    }

    // Active Classes
    if (metrics.stats?.totalClasses !== undefined) {
        document.getElementById('totalClasses').textContent = metrics.stats.totalClasses;
    }

    // School Year
    if (metrics.stats?.schoolYear) {
        document.getElementById('currentSchoolYear').textContent = metrics.stats.schoolYear;
    }
}

function loadFallbackData() {
    // Load sample data if API fails
    const fallbackMetrics = {
        stats: {
            totalStudents: 0,
            totalTeachers: 0,
            totalClasses: 0,
            schoolYear: '2025-2026'
        }
    };
    updateKPICards(fallbackMetrics);
}

// ===========================
// Charts Initialization
// ===========================

let enrollmentChart, gradeDistributionChart, performanceChart, quarterlyTrendChart;

function initializeCharts() {
    createEnrollmentChart();
    createGradeDistributionChart();
    createPerformanceChart();
    createQuarterlyTrendChart();
}

function updateCharts(metrics) {
    // Update enrollment chart if data available
    if (metrics.enrollmentTrend && enrollmentChart) {
        enrollmentChart.data.labels = metrics.enrollmentTrend.labels || [];
        enrollmentChart.data.datasets[0].data = metrics.enrollmentTrend.data || [];
        enrollmentChart.update();
    }

    // Update quarterly trend chart if data available
    if (metrics.quarterlyTrend && quarterlyTrendChart) {
        quarterlyTrendChart.data.labels = metrics.quarterlyTrend.labels || [];
        quarterlyTrendChart.data.datasets[0].data = metrics.quarterlyTrend.data || [];
        quarterlyTrendChart.update();
    }

    // Update grade distribution chart if data available
    if (metrics.gradeDistribution && gradeDistributionChart) {
        gradeDistributionChart.data.labels = metrics.gradeDistribution.labels || [];
        gradeDistributionChart.data.datasets[0].data = metrics.gradeDistribution.data || [];
        gradeDistributionChart.update();
    }

    // Update performance chart if data available
    if (metrics.performance && performanceChart) {
        performanceChart.data.labels = metrics.performance.labels || [];
        performanceChart.data.datasets[0].data = metrics.performance.data || [];
        performanceChart.update();
    }
}

function createEnrollmentChart() {
    const ctx = document.getElementById('enrollmentChart');
    if (!ctx) return;

    enrollmentChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'],
            datasets: [{
                label: 'Enrolled Students',
                data: [0, 0, 0, 0, 0, 0],
                borderColor: 'rgb(0, 85, 164)',
                backgroundColor: 'rgba(0, 85, 164, 0.1)',
                tension: 0.4,
                fill: true,
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: true,
                    position: 'top'
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
}

function createQuarterlyTrendChart() {
    const ctx = document.getElementById('quarterlyTrendChart');
    if (!ctx) return;

    quarterlyTrendChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: [],
            datasets: [{
                label: 'Average Quarterly Grade',
                data: [],
                borderColor: 'rgb(16, 185, 129)',
                backgroundColor: 'rgba(16, 185, 129, 0.12)',
                tension: 0.35,
                fill: true,
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: true,
                    position: 'top'
                }
            },
            scales: {
                y: {
                    beginAtZero: false,
                    suggestedMin: 60,
                    suggestedMax: 100
                }
            }
        }
    });
}

function createGradeDistributionChart() {
    const ctx = document.getElementById('gradeDistributionChart');
    if (!ctx) return;

    gradeDistributionChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: ['Grade 7', 'Grade 8', 'Grade 9', 'Grade 10'],
            datasets: [{
                label: 'Students',
                data: [0, 0, 0, 0],
                backgroundColor: [
                    '#0055A4',
                    '#A4D65E',
                    '#8B5CF6',
                    '#F97316'
                ]
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
}

function createPerformanceChart() {
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
                ]
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom'
                }
            }
        }
    });
}
