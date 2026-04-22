// ===========================
// Grade Distribution JavaScript
// ===========================

const API_BASE = window.API_BASE || `${window.location.protocol}//${window.location.host}/deped_capstone2/api`;

document.addEventListener('DOMContentLoaded', function() {
    loadGradeDistribution();
    initializeChart();
});

// ===========================
// Load Grade Distribution
// ===========================

async function loadGradeDistribution() {
    try {
        const response = await axios.get(`${API_BASE}/dashboard/metrics.php`);

        if (response.data?.success && response.data.data.gradeDistribution) {
            updateGradeChart(response.data.data.gradeDistribution);
        }
    } catch (error) {
        console.error('Error loading grade distribution:', error);
    }
}

// ===========================
// Chart
// ===========================

let gradeChart;

function initializeChart() {
    const ctx = document.getElementById('gradeDistributionChart');
    if (!ctx) return;

    gradeChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: ['Grade 7', 'Grade 8', 'Grade 9', 'Grade 10'],
            datasets: [{
                label: 'Number of Students',
                data: [0, 0, 0, 0],
                backgroundColor: [
                    '#0055A4',
                    '#A4D65E',
                    '#8B5CF6',
                    '#F97316'
                ],
                borderWidth: 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: true,
                    position: 'top'
                },
                title: {
                    display: true,
                    text: 'Student Distribution by Grade Level'
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

function updateGradeChart(gradeData) {
    if (gradeChart && gradeData) {
        gradeChart.data.labels = gradeData.labels || gradeChart.data.labels;
        gradeChart.data.datasets[0].data = gradeData.data || [0, 0, 0, 0];
        gradeChart.update();
    }
}
