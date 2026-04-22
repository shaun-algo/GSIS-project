// ===========================
// Enrollment Analytics JavaScript
// ===========================

const API_BASE = window.API_BASE || `${window.location.protocol}//${window.location.host}/deped_capstone2/api`;

document.addEventListener('DOMContentLoaded', function() {
    loadEnrollmentMetrics();
    initializeCharts();
});

// ===========================
// Load Enrollment Metrics
// ===========================

async function loadEnrollmentMetrics() {
    try {
        const response = await axios.get(`${API_BASE}/dashboard/metrics.php`);

        if (response.data?.success) {
            const metrics = response.data.data;
            updateEnrollmentKPIs(metrics);
            updateEnrollmentCharts(metrics);
        }
    } catch (error) {
        console.error('Error loading enrollment metrics:', error);
        loadFallbackData();
    }
}

function updateEnrollmentKPIs(metrics) {
    // Total Students
    if (metrics.stats?.totalStudents !== undefined) {
        document.getElementById('totalStudents').textContent = metrics.stats.totalStudents;
    }

    // New Enrollments
    if (metrics.enrollmentStats?.newEnrollments !== undefined) {
        document.getElementById('newEnrollments').textContent = metrics.enrollmentStats.newEnrollments;
    } else if (metrics.stats?.totalStudents) {
        // Estimate based on total students
        document.getElementById('newEnrollments').textContent = Math.floor(metrics.stats.totalStudents * 0.1);
    }

    // Dropout Rate
    if (metrics.enrollmentStats?.dropoutRate !== undefined) {
        document.getElementById('dropoutRate').textContent = metrics.enrollmentStats.dropoutRate + '%';
    }
}

function loadFallbackData() {
    document.getElementById('totalStudents').textContent = '0';
    document.getElementById('newEnrollments').textContent = '0';
    document.getElementById('dropoutRate').textContent = '0%';
}

// ===========================
// Charts
// ===========================

let enrollmentChart, gradeDistributionChart;

function initializeCharts() {
    createEnrollmentChart();
    createGradeDistributionChart();
}

function updateEnrollmentCharts(metrics) {
    if (metrics.enrollmentTrend && enrollmentChart) {
        enrollmentChart.data.labels = metrics.enrollmentTrend.labels || [];
        enrollmentChart.data.datasets[0].data = metrics.enrollmentTrend.data || [];
        enrollmentChart.update();
    }

    if (metrics.gradeDistribution && gradeDistributionChart) {
        gradeDistributionChart.data.labels = metrics.gradeDistribution.labels || [];
        gradeDistributionChart.data.datasets[0].data = metrics.gradeDistribution.data || [];
        gradeDistributionChart.update();
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
                    beginAtZero: true,
                    ticks: {
                        stepSize: 10
                    }
                }
            }
        }
    });
}
