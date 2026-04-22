const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

const reportCardsApi = {
    list: async () => axios.get(`${API_BASE_URL}/report_cards/report_cards.php`, { params: { operation: 'getAllReportCards' } }).then(r => r.data),
    sf9: async (reportCardId) => axios.get(`${API_BASE_URL}/report_cards/report_cards.php`, { params: { operation: 'getSF9Data', report_card_id: reportCardId } }).then(r => r.data),
    sf9ByEnrollment: async (enrollmentId) => axios.get(`${API_BASE_URL}/report_cards/report_cards.php`, { params: { operation: 'getSF9DataByEnrollment', enrollment_id: enrollmentId } }).then(r => r.data),
    getRoster: async (sectionId, schoolYearId) => axios.get(`${API_BASE_URL}/report_cards/report_cards.php`, { params: { operation: 'getSF9Roster', section_id: sectionId, school_year_id: schoolYearId } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/report_cards/report_cards.php?operation=createReportCard`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/report_cards/report_cards.php?operation=updateReportCard`, { ...data, report_card_id: id }).then(r => r.data),
    remove: async (id) => axios.post(`${API_BASE_URL}/report_cards/report_cards.php?operation=deleteReportCard`, { report_card_id: id }).then(r => r.data)
};

const enrollmentsApi = {
    list: async () => {
        const enrollments = await axios.get(`${API_BASE_URL}/enrollments/enrollments.php`, { params: { operation: 'getAllEnrollments' } }).then(r => r.data);
        return enrollments.map(e => ({ ...e, display_name: `${e.learner_name} - ${e.year_label}` }));
    }
};

const gradingPeriodsApi = {
    list: async () => axios.get(`${API_BASE_URL}/grading_periods/grading_periods.php`, { params: { operation: 'getAllGradingPeriods' } }).then(r => r.data)
};

const usersApi = {
    list: async () => axios.get(`${API_BASE_URL}/users/users.php`, { params: { operation: 'getAllUsers' } }).then(r => r.data)
};

const sectionsApi = {
    list: async () => axios.get(`${API_BASE_URL}/sections/sections.php`, { params: { operation: 'getAllSections' } }).then(r => r.data)
};

const schoolYearsApi = {
    list: async () => axios.get(`${API_BASE_URL}/school_years/school_years.php`, { params: { operation: 'getAllSchoolYears' } }).then(r => r.data)
};

// Report Cards UI State
let currentSectionId = null;
let currentSchoolYearId = null;
let currentStudents = [];
let selectedStudentId = null;

// Initialize Report Cards Interface
document.addEventListener('DOMContentLoaded', async () => {
    await initializeReportCards();
});

async function initializeReportCards() {
    try {
        console.log('Initializing report cards...');

        // Load sections and school years
        const [sections, schoolYears] = await Promise.all([
            sectionsApi.list().catch(err => {
                console.error('Failed to load sections:', err);
                return [];
            }),
            schoolYearsApi.list().catch(err => {
                console.error('Failed to load school years:', err);
                return [];
            })
        ]);

        console.log('Sections:', sections);
        console.log('School Years:', schoolYears);

        // Populate section dropdown
        const sectionSelect = document.getElementById('rcSectionSelect');
        if (sectionSelect) {
            sectionSelect.innerHTML = '<option value="">Select Section</option>';
            sections.forEach(section => {
                sectionSelect.innerHTML += `<option value="${section.section_id}">${section.grade_level || 'Grade'} - ${section.section_name}</option>`;
            });
            sectionSelect.addEventListener('change', handleSectionChange);
        } else {
            console.error('Section select element not found');
        }

        // Set current school year (most recent)
        const currentYear = schoolYears.find(sy => sy.is_current || sy.is_active) || schoolYears[schoolYears.length - 1];
        if (currentYear) {
            currentSchoolYearId = currentYear.school_year_id;
            console.log('Set current school year ID:', currentSchoolYearId);
        } else {
            console.warn('No current school year found');
        }

        // Initialize event listeners
        const searchInput = document.getElementById('rcSearch');
        if (searchInput) {
            searchInput.addEventListener('input', handleStudentSearch);
        }

        // Load initial data if section is selected
        if (sections.length > 0 && currentSchoolYearId) {
            console.log('Auto-loading first section...');
            sectionSelect.value = sections[0].section_id;
            await handleSectionChange();
        } else {
            console.log('No sections or school year available, showing empty state');
            clearStudentList();
        }

    } catch (error) {
        console.error('Failed to initialize report cards:', error);
        const detailContainer = document.getElementById('rcStudentDetail');
        if (detailContainer) {
            detailContainer.innerHTML = '<div class="rc-error">Failed to initialize: ' + escapeHtml(error.message) + '</div>';
        }
        if (window.Swal) {
            Swal.fire('Error', 'Failed to load report cards interface', 'error');
        }
    }
}

async function handleSectionChange() {
    const sectionSelect = document.getElementById('rcSectionSelect');
    currentSectionId = sectionSelect.value;

    if (!currentSectionId) {
        clearStudentList();
        return;
    }

    try {
        // Load roster for selected section
        const roster = await reportCardsApi.getRoster(currentSectionId, currentSchoolYearId);
        console.log('Roster data:', roster); // Debug log

        // The API returns the array directly, not wrapped in a students property
        currentStudents = Array.isArray(roster) ? roster : (roster.students || []);

        // Map the data structure to match what the UI expects
        currentStudents = currentStudents.map(student => ({
            enrollment_id: student.enrollment_id,
            name: student.learner_name,
            lrn: student.lrn,
            gender: student.gender,
            grade_level: student.grade_name,
            section: student.section_name,
            school_year: student.year_label,
            general_average: student.general_average
        }));

        console.log('Mapped students:', currentStudents); // Debug log
        renderStudentList();
        updateStats();

    } catch (error) {
        console.error('Failed to load section roster:', error);
        currentStudents = [];
        renderStudentList();
    }
}

function handleStudentSearch() {
    const searchTerm = document.getElementById('rcSearch').value.toLowerCase();
    const filteredStudents = currentStudents.filter(student =>
        student.name.toLowerCase().includes(searchTerm) ||
        student.lrn.toLowerCase().includes(searchTerm)
    );
    renderStudentList(filteredStudents);
}

function renderStudentList(students = currentStudents) {
    const studentListContainer = document.getElementById('rcStudentList');
    if (!studentListContainer) return;

    if (students.length === 0) {
        studentListContainer.innerHTML = '<div class="rc-empty-message">No students found</div>';
        return;
    }

    const studentItems = students.map(student => {
        const gwa = student.general_average || '--';
        const gwaClass = getGWAClass(gwa);
        const isActive = student.enrollment_id === selectedStudentId;

        return `
            <div class="rc-student-item ${isActive ? 'active' : ''}" data-enrollment-id="${student.enrollment_id}">
                <div class="rc-student-avatar ${getAvatarColor(student.enrollment_id)}">${getInitials(student.name)}</div>
                <div class="rc-student-info">
                    <div class="rc-student-name">${escapeHtml(student.name)}</div>
                    <div class="rc-student-lrn">LRN: ${escapeHtml(student.lrn)}</div>
                </div>
                <div class="rc-student-gwa ${gwaClass}">${gwa}</div>
            </div>
        `;
    }).join('');

    studentListContainer.innerHTML = studentItems;

    // Add click handlers
    studentListContainer.querySelectorAll('.rc-student-item').forEach(item => {
        item.addEventListener('click', () => {
            const enrollmentId = parseInt(item.dataset.enrollmentId);
            selectStudent(enrollmentId);
        });
    });
}

function selectStudent(enrollmentId) {
    selectedStudentId = enrollmentId;

    // Update active state in list
    document.querySelectorAll('.rc-student-item').forEach(item => {
        const itemEnrollmentId = parseInt(item.dataset.enrollmentId);
        item.classList.toggle('active', itemEnrollmentId === enrollmentId);
    });

    // Load and display student details
    const student = currentStudents.find(s => s.enrollment_id === enrollmentId);
    if (student) {
        renderStudentDetail(student);
    }
}

async function renderStudentDetail(student) {
    const detailContainer = document.getElementById('rcStudentDetail');
    if (!detailContainer) return;

    try {
        // Load SF9 data for this student
        const sf9Data = await reportCardsApi.sf9ByEnrollment(student.enrollment_id);
        console.log('SF9 Data:', sf9Data); // Debug log

        const gwa = sf9Data.general_average || student.general_average || '--';
        const gwaNum = parseFloat(gwa);
        const gwaClass = getGWAClass(gwa);
        const description = getGWADescription(gwa);

        // Handle attendance data
        const attendance = sf9Data.attendance || {};
        const daysPresent = attendance.days_present || attendance.total_days_present || 0;

        // Handle grades data
        const grades = sf9Data.grades || [];
        console.log('Grades:', grades); // Debug log

        detailContainer.innerHTML = `
            <div class="rc-student-header">
                <div class="rc-student-avatar-large ${getAvatarColor(student.enrollment_id)}">${getInitials(student.name)}</div>
                <div class="rc-student-info">
                    <div class="rc-student-name-large">${escapeHtml(student.name)}</div>
                    <div class="rc-student-meta">
                        <span>LRN: ${escapeHtml(student.lrn)}</span>
                        <span>Grade ${escapeHtml(student.grade_level)} - ${escapeHtml(student.section)}</span>
                        <span>Gender: ${student.gender === 'F' ? 'Female' : 'Male'}</span>
                    </div>
                </div>
                <div class="rc-student-actions">
                    <button class="btn btn-primary" onclick="openSf9Modal(${student.enrollment_id})">
                        <i class="fas fa-file-alt"></i> Generate SF9
                    </button>
                </div>
            </div>

            <div class="rc-stats-grid">
                <div class="rc-stat-card">
                    <div class="rc-stat-label">General Average</div>
                    <div class="rc-stat-value ${gwaClass}">${gwa}</div>
                    <div class="rc-stat-desc">${description}</div>
                </div>
                <div class="rc-stat-card">
                    <div class="rc-stat-label">Status</div>
                    <div class="rc-stat-value ${gwaNum >= 75 ? 'status-pass' : 'status-fail'}">${gwaNum >= 75 ? 'Passing' : 'At Risk'}</div>
                    <div class="rc-stat-desc">${gwaNum >= 75 ? 'Meets expectations' : 'Needs improvement'}</div>
                </div>
                <div class="rc-stat-card">
                    <div class="rc-stat-label">Attendance</div>
                    <div class="rc-stat-value">${daysPresent}</div>
                    <div class="rc-stat-desc">Days present</div>
                </div>
            </div>

            <div class="rc-grades-section">
                <h3>Subject Grades</h3>
                <table class="rc-grades-table">
                    <thead>
                        <tr>
                            <th>Subject</th>
                            <th>Q1</th>
                            <th>Q2</th>
                            <th>Q3</th>
                            <th>Q4</th>
                            <th>Final</th>
                            <th>Remarks</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${grades.length > 0 ? grades.map(grade => {
                            const finalGrade = parseFloat(grade.final_grade);
                            return `
                                <tr>
                                    <td class="subject-name">${escapeHtml(grade.subject_name || grade.subject || '')}</td>
                                    <td class="grade-cell">${grade.q1 || grade.q1_grade || '--'}</td>
                                    <td class="grade-cell">${grade.q2 || grade.q2_grade || '--'}</td>
                                    <td class="grade-cell">${grade.q3 || grade.q3_grade || '--'}</td>
                                    <td class="grade-cell">${grade.q4 || grade.q4_grade || '--'}</td>
                                    <td class="grade-cell final">${grade.final_grade || '--'}</td>
                                    <td class="remark-cell ${finalGrade >= 75 ? 'pass' : 'fail'}">
                                        ${finalGrade >= 75 ? 'Passed' : 'Failed'}
                                    </td>
                                </tr>
                            `;
                        }).join('') : '<tr><td colspan="7" class="rc-error">No grades available for this student</td></tr>'}
                    </tbody>
                </table>
            </div>
        `;

    } catch (error) {
        console.error('Failed to load student details:', error);
        detailContainer.innerHTML = '<div class="rc-error">Failed to load student details: ' + escapeHtml(error.message) + '</div>';
    }
}

function clearStudentList() {
    const studentListContainer = document.getElementById('rcStudentList');
    if (studentListContainer) {
        studentListContainer.innerHTML = '<div class="rc-empty-message">Select a section to view students</div>';
    }

    const detailContainer = document.getElementById('rcStudentDetail');
    if (detailContainer) {
        detailContainer.innerHTML = '<div class="rc-empty">Select a learner from the list to view grades and generate SF9.</div>';
    }
}

function updateStats() {
    const passingCount = currentStudents.filter(s => (s.general_average || 0) >= 75).length;
    const atRiskCount = currentStudents.filter(s => {
        const gwa = s.general_average || 0;
        return gwa >= 70 && gwa < 75;
    }).length;
    const failingCount = currentStudents.filter(s => (s.general_average || 0) < 70).length;

    const classAverage = currentStudents.length > 0
        ? (currentStudents.reduce((sum, s) => sum + (s.general_average || 0), 0) / currentStudents.length).toFixed(1)
        : '--';

    // Update stats display
    updateStat('rcStatStudents', currentStudents.length);
    updateStat('rcStatPass', passingCount);
    updateStat('rcStatAtRisk', atRiskCount);
    updateStat('rcStatFail', failingCount);
    updateStat('rcStatAvg', classAverage);
}

function updateStat(elementId, value) {
    const element = document.getElementById(elementId);
    if (element) {
        element.textContent = value;
    }
}

// Utility functions
function getInitials(name) {
    const parts = name.replace(/,/g, '').split(' ');
    return parts.slice(0, 2).map(part => part.charAt(0).toUpperCase()).join('');
}

function getAvatarColor(id) {
    const colors = ['av-blue', 'av-green', 'av-amber', 'av-rose', 'av-purple', 'av-teal'];
    return colors[id % colors.length];
}

function getGWAClass(gwa) {
    const num = parseFloat(gwa);
    if (num >= 90) return 'gwa-outstanding';
    if (num >= 85) return 'gwa-very-satisfactory';
    if (num >= 80) return 'gwa-satisfactory';
    if (num >= 75) return 'gwa-fairly-satisfactory';
    return 'gwa-did-not-meet';
}

function getGWADescription(gwa) {
    const num = parseFloat(gwa);
    if (num >= 90) return 'Outstanding';
    if (num >= 85) return 'Very Satisfactory';
    if (num >= 80) return 'Satisfactory';
    if (num >= 75) return 'Fairly Satisfactory';
    return 'Did Not Meet Expectations';
}

function escapeHtml(value) {
    return String(value ?? '')
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

function openSf9Modal(enrollmentId) {
    const modal = document.getElementById('sf9Modal');
    const root = document.getElementById('sf9PrintRoot');
    if (!modal || !root) return;

    root.innerHTML = `<div style="padding:16px;font-family:Arial,Helvetica,sans-serif;">Loading SF9…</div>`;
    modal.classList.add('show');

    reportCardsApi.sf9ByEnrollment(enrollmentId)
        .then((data) => {
            if (!data || data.success === false) {
                const msg = data?.message || 'Unable to load SF9 data.';
                throw new Error(msg);
            }
            root.innerHTML = renderSf9Html(data);
        })
        .catch((err) => {
            const msg = err?.response?.data?.message || err?.message || 'Unable to load SF9 data.';
            root.innerHTML = `<div style="padding:16px;color:#991B1B;font-family:Arial,Helvetica,sans-serif;">${escapeHtml(msg)}</div>`;
            if (window.Swal) {
                Swal.fire({ icon: 'error', title: 'SF9 Preview', text: msg });
            }
        });
}

function closeSf9Modal() {
    document.getElementById('sf9Modal')?.classList.remove('show');
}

function printSf9() {
    window.print();
}

function renderSf9Html(data) {
    const school = data?.school || {};
    const enrollment = data?.enrollment || {};
    const learner = data?.learner || {};
    const adviser = data?.adviser || {};
    const attendance = data?.attendance || {};
    const grades = Array.isArray(data?.grades) ? data.grades : [];
    const ga = data?.general_average;
    const schoolLogoUrl = '../assets/img/logo/logo.jpg';

    // School information
    const schoolName = school.school_name || 'MABINI ELEMENTARY SCHOOL';
    const region = school.region || 'Region XI';
    const division = school.division || 'Davao City Division';
    const district = school.district || 'Davao City District';
    const schoolHead = school.school_head || 'Maria Santos';

    // Student information
    const studentName = learner.name || '';
    const studentLRN = learner.lrn || '';
    const studentGender = learner.sex || learner.gender || '';
    const studentAge = learner.age || '8';
    const gradeLevel = enrollment.grade_level || '3';
    const section = enrollment.section || 'Rizal';
    const schoolYear = enrollment.school_year || '2019-2020';

    // Parse name components
    const nameParts = studentName.split(', ');
    const lastName = nameParts[0] || '';
    const firstNameMiddle = nameParts[1] || '';
    const firstMiddleParts = firstNameMiddle.split(' ');
    const firstName = firstMiddleParts[0] || '';
    const middleName = firstMiddleParts.slice(1).join(' ') || '';

    // Generate LRN boxes
    const lrnBoxes = studentLRN.split('').map(digit =>
        `<div class="lrn-box">${digit}</div>`
    ).join('');

    // Attendance data (mock for now - should come from API)
    const attendanceData = [
        { month: 'Jun', schoolDays: 22, present: 20, absent: 2 },
        { month: 'Jul', schoolDays: 22, present: 21, absent: 1 },
        { month: 'Aug', schoolDays: 22, present: 22, absent: 0 },
        { month: 'Sep', schoolDays: 20, present: 19, absent: 1 },
        { month: 'Oct', schoolDays: 22, present: 20, absent: 2 },
        { month: 'Nov', schoolDays: 20, present: 18, absent: 2 },
        { month: 'Dec', schoolDays: 15, present: 14, absent: 1 },
        { month: 'Jan', schoolDays: 22, present: 21, absent: 1 },
        { month: 'Feb', schoolDays: 20, present: 19, absent: 1 },
        { month: 'Mar', schoolDays: 22, present: 20, absent: 2 },
        { month: 'Apr', schoolDays: 20, present: 19, absent: 1 }
    ];

    const attendanceHeaders = attendanceData.map(m => `<th>${m.month}</th>`).join('') + '<th>Total</th>';
    const schoolDaysRow = attendanceData.map(m => `<td>${m.schoolDays}</td>`).join('') +
        `<td class="total-cell">${attendanceData.reduce((sum, m) => sum + m.schoolDays, 0)}</td>`;
    const presentRow = attendanceData.map(m => `<td>${m.present}</td>`).join('') +
        `<td class="total-cell">${attendanceData.reduce((sum, m) => sum + m.present, 0)}</td>`;
    const absentRow = attendanceData.map(m => `<td>${m.absent}</td>`).join('') +
        `<td class="total-cell">${attendanceData.reduce((sum, m) => sum + m.absent, 0)}</td>`;

    // Generate grades table rows
    const gradesRows = grades.map((g) => {
        const q1 = g.q1 ?? g.first_quarter ?? '';
        const q2 = g.q2 ?? g.second_quarter ?? '';
        const q3 = g.q3 ?? g.third_quarter ?? '';
        const q4 = g.q4 ?? g.fourth_quarter ?? '';
        const finalGrade = g.final_grade || g.final || '';
        const remark = parseFloat(finalGrade) >= 75 ? 'Passed' : 'Failed';
        const remarkClass = parseFloat(finalGrade) >= 75 ? 'passed' : 'failed';

        return `
            <tr>
                <td class="subject-cell">${escapeHtml(g.subject_name || g.subject || '')}</td>
                <td>${q1}</td>
                <td>${q2}</td>
                <td>${q3}</td>
                <td>${q4}</td>
                <td class="final-grade">${finalGrade}</td>
                <td class="${remarkClass}">${remark}</td>
            </tr>
        `;
    }).join('');

    const generalAverage = ga || '88.5';
    const gwaNum = parseFloat(generalAverage);

    return `
        <div class="sf9-elementary-container">
            <!-- PAGE 1: Front Page -->
            <div class="sf9-elementary-page">
                <div class="sf9-elementary-layout">
                    <!-- Left Column -->
                    <div class="sf9-left-column">
                        <!-- Attendance Record Section -->
                        <div class="sf9-attendance-section">
                            <div class="sf9-attendance-title">Attendance Record</div>
                            <table class="sf9-attendance-table">
                                <thead>
                                    <tr>
                                        <th class="label-cell"></th>
                                        ${attendanceHeaders}
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td class="label-cell">No. of School Days</td>
                                        ${schoolDaysRow}
                                    </tr>
                                    <tr>
                                        <td class="label-cell">No. of Days Present</td>
                                        ${presentRow}
                                    </tr>
                                    <tr>
                                        <td class="label-cell">No. of Times Absent</td>
                                        ${absentRow}
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <!-- Parent/Guardian Signature Section -->
                        <div class="sf9-parent-signature-section">
                            <div class="sf9-parent-signature-title">PARENT/GUARDIAN'S SIGNATURE</div>
                            <div class="sf9-quarter-signatures">
                                <div class="sf9-quarter-signature">
                                    <div class="sf9-quarter-label">1st Quarter</div>
                                    <div class="sf9-quarter-line"></div>
                                </div>
                                <div class="sf9-quarter-signature">
                                    <div class="sf9-quarter-label">2nd Quarter</div>
                                    <div class="sf9-quarter-line"></div>
                                </div>
                                <div class="sf9-quarter-signature">
                                    <div class="sf9-quarter-label">3rd Quarter</div>
                                    <div class="sf9-quarter-line"></div>
                                </div>
                                <div class="sf9-quarter-signature">
                                    <div class="sf9-quarter-label">4th Quarter</div>
                                    <div class="sf9-quarter-line"></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Right Column -->
                    <div class="sf9-right-column">
                        <!-- DepEd Header -->
                        <div class="sf9-deped-header">
                            <div class="sf9-header-branding">
                                <img
                                    src="${schoolLogoUrl}"
                                    alt="School Logo"
                                    class="sf9-school-logo"
                                    onerror="this.style.display='none'"
                                />
                            </div>
                            <div class="republic">Republic of the Philippines</div>
                            <div class="department">DEPARTMENT OF EDUCATION</div>
                            <div class="region-field">
                                <span class="field-label">Region:</span>
                                <div class="field-value">${escapeHtml(region)}</div>
                            </div>
                            <div class="division-field">
                                <span class="field-label">Division:</span>
                                <div class="field-value">${escapeHtml(division)}</div>
                            </div>
                            <div class="district-field">
                                <span class="field-label">District:</span>
                                <div class="field-value">${escapeHtml(district)}</div>
                            </div>
                            <div class="school-field">
                                <span class="field-label">School:</span>
                                <div class="field-value">${escapeHtml(schoolName)}</div>
                            </div>
                        </div>

                        <!-- Report Card Title -->
                        <div class="sf9-report-card-title">
                            LEARNER'S PROGRESS REPORT CARD
                        </div>

                        <!-- School Year -->
                        <div class="sf9-school-year">
                            School Year ${escapeHtml(schoolYear)}
                        </div>

                        <!-- Student Information -->
                        <div class="sf9-student-info">
                            <div class="sf9-info-row">
                                <span class="sf9-info-label">Name:</span>
                                <div class="sf9-name-fields">
                                    <div class="sf9-name-field small">${escapeHtml(lastName)}</div>
                                    <div class="sf9-name-field">${escapeHtml(firstName)}</div>
                                    <div class="sf9-name-field">${escapeHtml(middleName)}</div>
                                </div>
                            </div>
                            <div class="sf9-info-row">
                                <span class="sf9-info-label">Age:</span>
                                <div class="sf9-info-field">${escapeHtml(studentAge)}</div>
                                <span class="sf9-info-label">Sex:</span>
                                <div class="sf9-info-field">${escapeHtml(studentGender === 'F' ? 'Female' : 'Male')}</div>
                            </div>
                            <div class="sf9-info-row">
                                <span class="sf9-info-label">Grade:</span>
                                <div class="sf9-info-field">${escapeHtml(gradeLevel)}</div>
                                <span class="sf9-info-label">Section:</span>
                                <div class="sf9-info-field">${escapeHtml(section)}</div>
                            </div>
                            <div class="sf9-info-row">
                                <span class="sf9-info-label">LRN:</span>
                                <div class="sf9-info-field" style="font-family: monospace;">${escapeHtml(studentLRN)}</div>
                            </div>
                        </div>

                        <!-- Parent Message -->
                        <div class="sf9-parent-message">
                            Dear Parent,
                            <br><br>
                            This report card shows the ability and progress your child has made in the different learning areas as well as his/her progress in core values. The school welcomes you should you desire to know more about your child's progress.
                        </div>

                        <!-- Signatures -->
                        <div class="sf9-signature-section">
                            <div class="sf9-signature-row">
                                <div class="sf9-signature-box">
                                    <div class="sf9-signature-line"></div>
                                    <div class="sf9-signature-name">${escapeHtml(adviser.name || 'Teacher Name')}</div>
                                    <div class="sf9-signature-title">Teacher</div>
                                </div>
                                <div class="sf9-signature-box">
                                    <div class="sf9-signature-line"></div>
                                    <div class="sf9-signature-name">${escapeHtml(schoolHead)}</div>
                                    <div class="sf9-signature-title">Head Teacher/Principal</div>
                                </div>
                            </div>
                        </div>

                        <!-- Certificate of Transfer Section -->
                        <div class="sf9-transfer-section">
                            <div class="sf9-transfer-title">Certificate of Transfer</div>
                            <div class="sf9-transfer-row">
                                <span class="sf9-transfer-label">Admitted to Grade</span>
                                <div class="sf9-transfer-field"></div>
                                <span class="sf9-transfer-label">Section</span>
                                <div class="sf9-transfer-field"></div>
                                <span class="sf9-transfer-label">Room</span>
                                <div class="sf9-transfer-field"></div>
                            </div>
                            <div class="sf9-transfer-row">
                                <span class="sf9-transfer-label">Eligible for Admission to Grade</span>
                                <div class="sf9-transfer-field"></div>
                            </div>
                            <div class="sf9-transfer-row">
                                <span class="sf9-transfer-label">Approved:</span>
                            </div>
                            <div class="sf9-transfer-signatures">
                                <div class="sf9-transfer-signature">
                                    <div class="sf9-transfer-line"></div>
                                    <div class="sf9-transfer-name">${escapeHtml(schoolHead)}</div>
                                    <div class="sf9-transfer-role">Head Teacher/Principal</div>
                                </div>
                                <div class="sf9-transfer-signature">
                                    <div class="sf9-transfer-line"></div>
                                    <div class="sf9-transfer-name">${escapeHtml(adviser.name || 'Teacher Name')}</div>
                                    <div class="sf9-transfer-role">Teacher</div>
                                </div>
                            </div>
                        </div>

                        <!-- Cancellation Section -->
                        <div class="sf9-cancellation-section">
                            <div class="sf9-cancellation-title">Cancellation of Eligibility to Transfer</div>
                            <div class="sf9-cancellation-row">
                                <span class="sf9-cancellation-label">Admitted in:</span>
                                <div class="sf9-cancellation-field"></div>
                            </div>
                            <div class="sf9-cancellation-row">
                                <span class="sf9-cancellation-label">Date:</span>
                                <div class="sf9-cancellation-field"></div>
                            </div>
                            <div class="sf9-cancellation-signature">
                                <div class="sf9-cancellation-line"></div>
                                <div class="sf9-cancellation-role">Principal</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- PAGE 2: Back Page with Learning Progress -->
            <div class="sf9-elementary-page">
                <div class="sf9-learning-progress-title">Report on Learning Progress and Achievement</div>

                <!-- Learning Areas Table -->
                <table class="sf9-learning-table">
                    <thead>
                        <tr>
                            <th class="subject-cell" rowspan="2">Learning Areas</th>
                            <th colspan="4" class="quarter-header">Quarter</th>
                            <th rowspan="2">Final Rating</th>
                            <th rowspan="2">Remarks</th>
                        </tr>
                        <tr>
                            <th class="quarter-header">1</th>
                            <th class="quarter-header">2</th>
                            <th class="quarter-header">3</th>
                            <th class="quarter-header">4</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${gradesRows || '<tr><td colspan="7" style="text-align:center;">No subjects found for this enrollment.</td></tr>'}
                    </tbody>
                    <tfoot>
                        <tr class="sf9-general-average-row">
                            <td class="subject-cell">General Average</td>
                            <td colspan="4"></td>
                            <td class="final-grade">${generalAverage}</td>
                            <td class="${gwaNum >= 75 ? 'passed' : 'failed'}">${gwaNum >= 75 ? 'Passed' : 'Failed'}</td>
                        </tr>
                    </tfoot>
                </table>

                <!-- Descriptors Section -->
                <div class="sf9-descriptors-section">
                    <div class="sf9-descriptor-column">
                        <div class="sf9-descriptor-title">Descriptors</div>
                        <table class="sf9-descriptor-table">
                            <thead>
                                <tr><th>Grading Scale</th><th>Remarks</th></tr>
                            </thead>
                            <tbody>
                                <tr><td>90-100</td><td class="left-align">Outstanding</td></tr>
                                <tr><td>85-89</td><td class="left-align">Very Satisfactory</td></tr>
                                <tr><td>80-84</td><td class="left-align">Satisfactory</td></tr>
                                <tr><td>75-79</td><td class="left-align">Fairly Satisfactory</td></tr>
                                <tr><td>Below 75</td><td class="left-align">Did Not Meet Expectations</td></tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="sf9-descriptor-column">
                        <div class="sf9-descriptor-title">Remarks</div>
                        <table class="sf9-descriptor-table">
                            <thead>
                                <tr><th>Final Rating</th><th>Remarks</th></tr>
                            </thead>
                            <tbody>
                                <tr><td>75 and above</td><td class="left-align">Passed</td></tr>
                                <tr><td>Below 75</td><td class="left-align">Failed</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Core Values Section -->
                <div class="sf9-core-values-section">
                    <div class="sf9-core-values-title">Core Values</div>
                    <table class="sf9-core-values-table">
                        <thead>
                            <tr>
                                <th class="core-value-cell">Core Values</th>
                                <th>Behavior Statements</th>
                                <th>1</th>
                                <th>2</th>
                                <th>3</th>
                                <th>4</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td class="core-value-cell">1. Maka-Diyos</td>
                                <td class="behavior-cell">Expresses one's spiritual beliefs while respecting the spiritual beliefs of others.</td>
                                <td></td><td></td><td></td><td></td>
                            </tr>
                            <tr>
                                <td class="core-value-cell">2. Makatao</td>
                                <td class="behavior-cell">Shows adherence to ethical principles by upholding truth.</td>
                                <td></td><td></td><td></td><td></td>
                            </tr>
                            <tr>
                                <td class="core-value-cell">3. Makakalikasan</td>
                                <td class="behavior-cell">Cares for the environment and utilizes resources wisely, judiciously, and economically.</td>
                                <td></td><td></td><td></td><td></td>
                            </tr>
                            <tr>
                                <td class="core-value-cell">4. Makabansa</td>
                                <td class="behavior-cell">Demonstrates pride in being a Filipino; exercises the rights and responsibilities of a Filipino citizen.</td>
                                <td></td><td></td><td></td><td></td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <!-- Behavior Descriptors Section -->
                <div class="sf9-behavior-section">
                    <div class="sf9-behavior-column">
                        <div class="sf9-behavior-title">Marking</div>
                        <table class="sf9-behavior-table">
                            <thead>
                                <tr><th>Mark</th><th class="left-align">Description</th></tr>
                            </thead>
                            <tbody>
                                <tr><td>AO</td><td class="left-align">Always Observed</td></tr>
                                <tr><td>SO</td><td class="left-align">Sometimes Observed</td></tr>
                                <tr><td>RO</td><td class="left-align">Rarely Observed</td></tr>
                                <tr><td>NO</td><td class="left-align">Not Observed</td></tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="sf9-behavior-column">
                        <div class="sf9-behavior-title">Non-numerical Rating</div>
                        <table class="sf9-behavior-table">
                            <thead>
                                <tr><th>Mark</th><th class="left-align">Description</th></tr>
                            </thead>
                            <tbody>
                                <tr><td>AO</td><td class="left-align">Always Observed</td></tr>
                                <tr><td>SO</td><td class="left-align">Sometimes Observed</td></tr>
                                <tr><td>RO</td><td class="left-align">Rarely Observed</td></tr>
                                <tr><td>NO</td><td class="left-align">Not Observed</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Final Signatures -->
                <div class="sf9-final-signatures">
                    <div class="sf9-final-signature">
                        <div class="sf9-final-line"></div>
                        <div class="sf9-final-name">${escapeHtml(adviser.name || 'Teacher Name')}</div>
                        <div class="sf9-final-role">Teacher</div>
                    </div>
                    <div class="sf9-final-signature">
                        <div class="sf9-final-line"></div>
                        <div class="sf9-final-name">${escapeHtml(schoolHead)}</div>
                        <div class="sf9-final-role">Head Teacher/Principal</div>
                    </div>
                    <div class="sf9-final-signature">
                        <div class="sf9-final-line"></div>
                        <div class="sf9-final-name">Parent / Guardian</div>
                        <div class="sf9-final-role">Signature over Printed Name</div>
                    </div>
                </div>
            </div>
        </div>
    `;
}
