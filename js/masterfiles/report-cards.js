const API_BASE_URL = window.API_BASE || `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;
const noCache = () => Date.now();

const reportCardsApi = {
    list: async () => axios.get(`${API_BASE_URL}/report_cards/report_cards.php`, { params: { operation: 'getAllReportCards', _: noCache() } }).then(r => r.data),
    sf9: async (reportCardId) => axios.get(`${API_BASE_URL}/report_cards/report_cards.php`, { params: { operation: 'getSF9Data', report_card_id: reportCardId, _: noCache() } }).then(r => r.data),
    sf9ByEnrollment: async (enrollmentId) => axios.get(`${API_BASE_URL}/report_cards/report_cards.php`, { params: { operation: 'getSF9DataByEnrollment', enrollment_id: enrollmentId, _: noCache() } }).then(r => r.data),
    getRoster: async (sectionId, schoolYearId) => axios.get(`${API_BASE_URL}/report_cards/report_cards.php`, { params: { operation: 'getSF9Roster', section_id: sectionId, school_year_id: schoolYearId, _: noCache() } }).then(r => r.data),
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

        // Filter out the specific student 'Hagorn, Marya Pato' with LRN '128000000920'
        currentStudents = currentStudents.filter(student =>
            student.lrn !== '128000000920' || !student.name.includes('Hagorn')
        );

        console.log('Mapped students:', currentStudents); // Debug log
        renderStudentList();

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
        const isActive = student.enrollment_id === selectedStudentId;

        return `
            <div class="rc-student-item ${isActive ? 'active' : ''}" data-enrollment-id="${student.enrollment_id}">
                <div class="rc-student-avatar ${getAvatarColor(student.enrollment_id)}">${getInitials(student.name)}</div>
                <div class="rc-student-info">
                    <div class="rc-student-name">${escapeHtml(student.name)}</div>
                </div>
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

        // Handle grades data
        const grades = sf9Data.grades || [];
        console.log('Grades:', grades); // Debug log

        detailContainer.innerHTML = `
            <div class="rc-student-header">
                <div class="rc-student-avatar-large ${getAvatarColor(student.enrollment_id)}">${getInitials(student.name)}</div>
                <div class="rc-student-info">
                    <div class="rc-student-name-large">${escapeHtml(student.name)}</div>
                    <div class="rc-student-section">${escapeHtml(student.section || '')}</div>
                </div>
                <div class="rc-student-actions">
                    <button class="btn btn-primary" onclick="openSf9Modal(${student.enrollment_id})">
                        <i class="fas fa-file-alt"></i> Generate SF9
                    </button>
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
                            const q1 = grade.q1 ?? grade.q1_grade ?? '';
                            const q2 = grade.q2 ?? grade.q2_grade ?? '';
                            const q3 = grade.q3 ?? grade.q3_grade ?? '';
                            const q4 = grade.q4 ?? grade.q4_grade ?? '';
                            const quartersComplete = hasAllQuarters({ q1, q2, q3, q4 });

                            let finalDisplay = '';
                            let remarkDisplay = '';
                            let remarkClass = '';
                            let rowOutcomeClass = '';

                            const partialQs = [q1, q2, q3, q4].filter((v) => hasQuarterGrade(v)).map((v) => Number(v));
                            const partialWorst = partialQs.length ? Math.min(...partialQs) : null;

                            if (quartersComplete) {
                                const explicitFinal = grade.final_grade ?? grade.final_rating;
                                const computedAvg = computeAverage([q1, q2, q3, q4]);
                                const finalNum = Number(
                                    explicitFinal !== null && explicitFinal !== undefined && explicitFinal !== ''
                                        ? explicitFinal
                                        : computedAvg
                                );

                                if (Number.isFinite(finalNum)) {
                                    finalDisplay = finalNum % 1 === 0 ? String(finalNum) : finalNum.toFixed(2);
                                    remarkDisplay = finalNum >= 75 ? 'Passed' : 'Failed';
                                    remarkClass = finalNum >= 75 ? 'pass' : 'fail';
                                    rowOutcomeClass = finalNum >= 75 ? 'grade-row-pass' : 'grade-row-fail';
                                }
                            } else if (partialWorst !== null) {
                                // Quarters not complete yet: still give a visual cue from entered quarter grades.
                                rowOutcomeClass = partialWorst >= 75 ? 'grade-row-pass-partial' : 'grade-row-fail-partial';
                            }

                            return `
                                <tr class="${rowOutcomeClass}">
                                    <td class="subject-name">${escapeHtml(grade.subject_name || grade.subject || '')}</td>
                                    <td class="grade-cell">${formatUiGradeCell(q1)}</td>
                                    <td class="grade-cell">${formatUiGradeCell(q2)}</td>
                                    <td class="grade-cell">${formatUiGradeCell(q3)}</td>
                                    <td class="grade-cell">${formatUiGradeCell(q4)}</td>
                                    <td class="grade-cell final">${finalDisplay ? formatUiGradeCell(finalDisplay) : ''}</td>
                                    <td class="remark-cell ${remarkClass}">
                                        ${remarkDisplay}
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

function gradeTextToneClass(value) {
    if (!hasQuarterGrade(value)) return '';
    const num = Number(value);
    if (!Number.isFinite(num)) return '';
    return num >= 75 ? 'grade-text-pass' : 'grade-text-fail';
}

function formatUiGradeCell(rawValue) {
    const text = String(rawValue ?? '').trim();
    if (!text || text === '--') {
        return '<span class="grade-text-empty">--</span>';
    }
    const tone = gradeTextToneClass(text);
    const cls = tone ? `grade-text ${tone}` : 'grade-text';
    return `<span class="${cls}">${escapeHtml(text)}</span>`;
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

function escapeHtml(value) {
    return String(value ?? '')
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

function openSf9Modal(enrollmentId) {
    reportCardsApi.sf9ByEnrollment(enrollmentId)
        .then((data) => {
            if (!data || data.success === false) {
                throw new Error(data?.message || 'Unable to load SF9 data.');
            }

            const iframe = document.getElementById('sf9Frame');
            if (!iframe) {
                throw new Error('SF9 preview frame is missing.');
            }

            const html = buildSf9DocumentHtml(ensureSf9Defaults(data));
            iframe.srcdoc = html;

            showSf9Modal();
        })
        .catch((err) => {
            if (window.Swal) {
                Swal.fire({ icon: 'error', title: 'SF9 Document', text: err?.response?.data?.message || err?.message || 'Unable to load SF9 data.' });
            }
        });
}

function showSf9Modal() {
    const modal = document.getElementById('sf9Modal');
    if (modal) {
        modal.classList.add('show');
        modal.style.display = 'flex';
    }
}

function closeSf9Modal() {
    const modal = document.getElementById('sf9Modal');
    if (modal) {
        modal.classList.remove('show');
        modal.style.display = '';
        const iframe = document.getElementById('sf9Frame');
        if (iframe) iframe.srcdoc = '';
    }
}

function printSf9() {
    const iframe = document.getElementById('sf9Frame');
    if (!iframe?.contentWindow) return;
    iframe.contentWindow.focus();
    iframe.contentWindow.print();
}

async function ensureHtml2Pdf() {
    if (window.html2pdf) return window.html2pdf;

    await new Promise((resolve, reject) => {
        const existing = document.querySelector('script[data-sf9-html2pdf="1"]');
        if (existing) {
            existing.addEventListener('load', resolve, { once: true });
            existing.addEventListener('error', () => reject(new Error('Failed to load PDF library')), { once: true });
            return;
        }

        const script = document.createElement('script');
        script.src = 'https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js';
        script.async = true;
        script.dataset.sf9Html2pdf = '1';
        script.onload = () => resolve();
        script.onerror = () => reject(new Error('Failed to load PDF library'));
        document.head.appendChild(script);
    });

    if (!window.html2pdf) throw new Error('PDF library is unavailable');
    return window.html2pdf;
}

function fileSafe(value) {
    return String(value ?? '')
        .trim()
        .replace(/[\\/:*?"<>|]+/g, '-')
        .replace(/\s+/g, '_')
        .slice(0, 90);
}

async function exportSf9Pdf() {
    const iframe = document.getElementById('sf9Frame');
    const srcdoc = String(iframe?.srcdoc || '').trim();
    if (!srcdoc) {
        if (window.Swal) Swal.fire('SF9 Export', 'Nothing to export yet. Open SF9 preview first.', 'info');
        return;
    }

    let mountInnerHtml = srcdoc;
    let titleText = '';
    try {
        const doc = new DOMParser().parseFromString(srcdoc, 'text/html');
        const inlineStyle = doc.querySelector('style')?.textContent || '';
        const bodyHtml = doc.body?.innerHTML || '';
        titleText = doc.querySelector('title')?.textContent || '';
        mountInnerHtml = `${inlineStyle ? `<style>${inlineStyle}</style>` : ''}${bodyHtml}`;
    } catch (_) {
        // fallback
    }

    const html2pdfLib = await ensureHtml2Pdf();
    const mount = document.createElement('div');
    mount.style.position = 'absolute';
    mount.style.left = '0';
    mount.style.top = '0';
    mount.style.transform = 'translateX(120vw)';
    mount.style.opacity = '1';
    mount.style.pointerEvents = 'none';
    mount.style.zIndex = '2147483647';
    mount.style.width = '1200px';
    mount.style.background = '#ffffff';
    mount.innerHTML = mountInnerHtml;
    document.body.appendChild(mount);

    const waitForImages = async (container, timeoutMs = 6000) => {
        const imgs = Array.from(container.querySelectorAll('img'));
        if (!imgs.length) return;
        const start = Date.now();
        await Promise.all(imgs.map((img) => {
            if (img.complete && img.naturalWidth > 0) return Promise.resolve();
            return new Promise((resolve) => {
                const done = () => resolve();
                img.addEventListener('load', done, { once: true });
                img.addEventListener('error', done, { once: true });
                const poll = () => {
                    if ((img.complete && img.naturalWidth > 0) || (Date.now() - start) > timeoutMs) resolve();
                    else setTimeout(poll, 150);
                };
                poll();
            });
        }));
    };

    const filename = `${['sf9', fileSafe(titleText)].filter(Boolean).join('_') || 'sf9'}.pdf`;
    try {
        await waitForImages(mount);
        await new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)));

        await html2pdfLib()
            .set({
                filename,
                margin: [0, 0, 0, 0],
                image: { type: 'jpeg', quality: 1 },
                html2canvas: { scale: 2, useCORS: true, allowTaint: true, backgroundColor: '#ffffff', scrollX: 0, scrollY: 0 },
                jsPDF: { unit: 'mm', format: 'a4', orientation: 'landscape' },
            })
            .from(mount)
            .save();
    } finally {
        mount.remove();
    }
}

function getSf9AppBase() {
    // Use existing APP_BASE if available
    if (typeof window.APP_BASE === 'string' && window.APP_BASE !== '') return window.APP_BASE;

    // Detect app base from current path (works for both localhost and Live Server)
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

    // Cache for future use
    window.APP_BASE = appPrefix;
    return appPrefix;
}

function ensureSf9Defaults(data) {
    const out = { ...(data || {}) };
    out.school = { ...(out.school || {}) };

    // Get the correct app base path
    const appBase = getSf9AppBase();

    // Always use the in-project school logo by default.
    const logoUrl = blankIfInvalid(out.school.logo_url);
    if (!logoUrl) {
        out.school.logo_url = `${window.location.origin}${appBase}/assets/img/logo/logo.jpg`;
    }

    // Ensure DepEd logo has proper fallback
    const depedLogoUrl = blankIfInvalid(out.school.deped_logo_url);
    if (!depedLogoUrl) {
        out.school.deped_logo_url = `${window.location.origin}${appBase}/assets/img/logo/pngegg.png`;
    }

    // Ensure core values exist (the API already provides a template for enrollment-based calls,
    // but keep this resilient).
    if (!out.core_values) {
        out.core_values = {};
    }

    return out;
}

function blankIfInvalid(value) {
    if (value === null || value === undefined) return '';
    const text = String(value).trim();
    if (!text || text.toLowerCase() === 'null' || text.toLowerCase() === 'undefined') return '';
    return text;
}

function normalizeCurriculumLevel(value) {
    const text = String(value || '').trim().toLowerCase();
    if (!text) return '';
    if (text.includes('senior') || text === 'shs') return 'shs';
    if (text.includes('junior') || text === 'jhs') return 'jhs';
    if (text.includes('elementary') || text === 'elem') return 'elementary';
    return '';
}

function inferCurriculumLevel(school, enrollment) {
    const direct = normalizeCurriculumLevel(school?.curriculum_level);
    if (direct) return direct;

    const education = normalizeCurriculumLevel(enrollment?.education_level);
    if (education) return education;

    const gradeText = String(enrollment?.grade_level || '');
    const gradeMatch = gradeText.match(/(\d+)/);
    const gradeNo = gradeMatch ? Number(gradeMatch[1]) : 0;
    if (gradeNo >= 11) return 'shs';
    if (gradeNo >= 7) return 'jhs';
    return 'elementary';
}

function parseLearnerName(fullName) {
    const name = blankIfInvalid(fullName);
    if (!name) return { lastName: '', firstName: '', middleName: '' };
    const [lastPart = '', givenPart = ''] = name.split(',');
    const tokens = givenPart.trim().split(/\s+/).filter(Boolean);
    return {
        lastName: lastPart.trim(),
        firstName: tokens[0] || '',
        middleName: tokens.slice(1).join(' ')
    };
}

function roundTo2(value) {
    const num = Number(value);
    if (!Number.isFinite(num)) return null;
    return Math.round(num * 100) / 100;
}

function computeAverage(values) {
    const nums = values
        .map((value) => Number(value))
        .filter((value) => Number.isFinite(value));
    if (!nums.length) return null;
    return roundTo2(nums.reduce((sum, value) => sum + value, 0) / nums.length);
}

function formatRating(value) {
    if (value === null || value === undefined || value === '') return '';
    if (value === '--') return '&ndash;';
    const num = Number(value);
    if (!Number.isFinite(num)) return escapeHtml(String(value));
    return escapeHtml(num % 1 === 0 ? String(num) : num.toFixed(2));
}

function descriptorFor(value) {
    const num = Number(value);
    if (!Number.isFinite(num)) return '';
    if (num >= 90) return 'Outstanding';
    if (num >= 85) return 'Very Satisfactory';
    if (num >= 80) return 'Satisfactory';
    if (num >= 75) return 'Fairly Satisfactory';
    return 'Did Not Meet Expectations';
}

function remarksFor(value) {
    const num = Number(value);
    if (!Number.isFinite(num)) return '';
    return num >= 75 ? 'Passed' : 'Failed';
}

function getFormCode(curriculumLevel) {
    if (curriculumLevel === 'shs') return 'SF9-SHS';
    if (curriculumLevel === 'jhs') return 'SF9-JHS';
    return 'SF9-Elem';
}

function getLogoMarkup(logoUrl) {
    const src = blankIfInvalid(logoUrl);
    if (src) {
        return `<img src="${escapeHtml(src)}" alt="DepEd Seal" class="seal-image">`;
    }
    return `<div class="seal-fallback">DepEd<br>Seal</div>`;
}

function getRightLogoMarkup(logoUrl) {
    const src = blankIfInvalid(logoUrl);
    if (src) {
        return `<img src="${escapeHtml(src)}" alt="DepEd Logo" class="seal-image">`;
    }
    return `<div class="seal-fallback">DepEd<br>Logo</div>`;
}

function buildLrnBoxes(lrn) {
    const digits = blankIfInvalid(lrn).replace(/\D/g, '').slice(0, 12).split('');
    const boxes = [];
    for (let index = 0; index < 12; index += 1) {
        boxes.push(`<span class="lrn-box">${escapeHtml(digits[index] || '')}</span>`);
    }
    return boxes.join('');
}

function buildAttendanceData(attendance) {
    const months = Array.isArray(attendance?.months) ? attendance.months : [];
    const mapped = months.map((item) => {
        const schoolDays = Number(item?.total_school_days) || 0;
        const present = Number(item?.days_present) || 0;
        const absent = Math.max(0, schoolDays - present);
        return {
            label: blankIfInvalid(item?.label),
            schoolDays,
            present,
            absent
        };
    });

    return {
        months: mapped,
        totals: {
            schoolDays: mapped.reduce((sum, item) => sum + item.schoolDays, 0),
            present: mapped.reduce((sum, item) => sum + item.present, 0),
            absent: mapped.reduce((sum, item) => sum + item.absent, 0)
        }
    };
}

function defaultObservedValues() {
    return [
        {
            coreValue: 'Maka-Diyos',
            statements: [
                "Expresses one's spiritual beliefs while respecting the spiritual beliefs of others",
                'Shows adherence to ethical principles by upholding truth in all undertakings'
            ]
        },
        {
            coreValue: 'Makatao',
            statements: [
                'Is sensitive to individual, social and cultural differences; resists stereotyping people',
                'Demonstrates contributions toward solidarity'
            ]
        },
        {
            coreValue: 'Makakalikasan',
            statements: [
                'Cares for the environment and utilizes resources wisely, judiciously and economically'
            ]
        },
        {
            coreValue: 'Makabansa',
            statements: [
                'Demonstrates pride in being a Filipino; exercises the rights and responsibilities of a Filipino citizen',
                'Demonstrates appropriate behavior in carrying out activities in the school, community and country'
            ]
        }
    ];
}

function buildObservedValuesRows(coreValues) {
    const values = coreValues && typeof coreValues === 'object' ? Object.entries(coreValues) : [];
    if (!values.length) {
        return defaultObservedValues().flatMap((group) => group.statements.map((statement, index) => ({
            coreValue: group.coreValue,
            behavior_statement: statement,
            q1: '', q2: '', q3: '', q4: '',
            rowspan: group.statements.length,
            showCoreValue: index === 0
        })));
    }

    const grouped = [];
    values.forEach(([, item]) => {
        const coreValue = blankIfInvalid(item?.core_value);
        const statement = blankIfInvalid(item?.behavior_statement);
        if (!coreValue || !statement) return;
        let group = grouped.find((entry) => entry.coreValue === coreValue);
        if (!group) {
            group = { coreValue, items: [] };
            grouped.push(group);
        }
        group.items.push(item);
    });

    return grouped.flatMap((group) => group.items.map((item, index) => ({
        coreValue: group.coreValue,
        behavior_statement: blankIfInvalid(item.behavior_statement),
        q1: blankIfInvalid(item.q1),
        q2: blankIfInvalid(item.q2),
        q3: blankIfInvalid(item.q3),
        q4: blankIfInvalid(item.q4),
        rowspan: group.items.length,
        showCoreValue: index === 0
    })));
}

function sanitizeGradeRow(row) {
    const q1 = row?.q1 ?? '';
    const q2 = row?.q2 ?? '';
    const q3 = row?.q3 ?? '';
    const q4 = row?.q4 ?? '';
    const finalRating = row?.final_rating ?? row?.final_grade ?? computeAverage([q1, q2, q3, q4]);
    return {
        subject: blankIfInvalid(row?.subject_name || row?.name || row?.subject),
        category: blankIfInvalid(row?.category) || 'Learning Areas',
        q1,
        q2,
        q3,
        q4,
        finalRating,
        remarks: blankIfInvalid(row?.remarks || row?.remark) || remarksFor(finalRating)
    };
}

function computeGeneralAverage(grades, suppliedAverage) {
    const explicit = roundTo2(suppliedAverage);
    if (explicit !== null) return explicit;
    const finals = grades.map((row) => Number(row.finalRating)).filter((value) => Number.isFinite(value));
    return computeAverage(finals);
}

function hasQuarterGrade(value) {
    const text = String(value ?? '').trim();
    if (!text || text === '--') return false;
    const num = Number(text);
    return Number.isFinite(num);
}

function hasAllQuarters(row) {
    return hasQuarterGrade(row?.q1) && hasQuarterGrade(row?.q2) && hasQuarterGrade(row?.q3) && hasQuarterGrade(row?.q4);
}

function buildElementaryGradesTable(grades, generalAverage, motherTongue) {
    const subjectLabel = motherTongue ? `Learning Areas${motherTongue ? ` / MTB-MLE (${escapeHtml(motherTongue)})` : ''}` : 'Learning Areas';
    const allComplete = grades.length > 0 && grades.every(hasAllQuarters);
    const rows = grades.length ? grades.map((row) => `
        <tr>
            <td class="subject-col text-left">${escapeHtml(row.subject)}</td>
            <td>${formatRating(row.q1)}</td>
            <td>${formatRating(row.q2)}</td>
            <td>${formatRating(row.q3)}</td>
            <td>${formatRating(row.q4)}</td>
            <td>${hasAllQuarters(row) ? formatRating(row.finalRating) : ''}</td>
            <td>${hasAllQuarters(row) ? escapeHtml(row.remarks) : ''}</td>
        </tr>
    `).join('') : `<tr><td colspan="7">&nbsp;</td></tr>`;

    return `
        <table class="sf9-table grades-table">
            <thead>
                <tr>
                    <th class="subject-col text-left">${subjectLabel}</th>
                    <th>Q1</th>
                    <th>Q2</th>
                    <th>Q3</th>
                    <th>Q4</th>
                    <th>Final Rating</th>
                    <th>Remarks</th>
                </tr>
            </thead>
            <tbody>${rows}</tbody>
            <tfoot>
                <tr>
                    <td class="text-left footer-label">General Average</td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td>${allComplete ? formatRating(generalAverage) : ''}</td>
                    <td>${allComplete ? escapeHtml(remarksFor(generalAverage)) : ''}</td>
                </tr>
            </tfoot>
        </table>
    `;
}

function buildJhsGradesTable(grades, generalAverage) {
    const allComplete = grades.length > 0 && grades.every(hasAllQuarters);
    const groups = grades.reduce((map, row) => {
        if (!map[row.category]) map[row.category] = [];
        map[row.category].push(row);
        return map;
    }, {});

    const body = Object.entries(groups).map(([category, items]) => `
        <tr class="category-row"><td colspan="7">${escapeHtml(category)}</td></tr>
        ${items.map((row) => `
            <tr>
                <td class="subject-col text-left">${escapeHtml(row.subject)}</td>
                <td>${formatRating(row.q1)}</td>
                <td>${formatRating(row.q2)}</td>
                <td>${formatRating(row.q3)}</td>
                <td>${formatRating(row.q4)}</td>
                <td>${hasAllQuarters(row) ? formatRating(row.finalRating) : ''}</td>
                <td>${hasAllQuarters(row) ? escapeHtml(row.remarks) : ''}</td>
            </tr>
        `).join('')}
    `).join('') || '<tr><td colspan="7">&nbsp;</td></tr>';

    return `
        <table class="sf9-table grades-table">
            <thead>
                <tr>
                    <th class="subject-col text-left">Subjects</th>
                    <th>Q1</th>
                    <th>Q2</th>
                    <th>Q3</th>
                    <th>Q4</th>
                    <th>Final Rating</th>
                    <th>Remarks</th>
                </tr>
            </thead>
            <tbody>${body}</tbody>
            <tfoot>
                <tr>
                    <td class="text-left footer-label">General Average for the Year</td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td>${allComplete ? formatRating(generalAverage) : ''}</td>
                    <td>${allComplete ? escapeHtml(remarksFor(generalAverage)) : ''}</td>
                </tr>
            </tfoot>
        </table>
    `;
}

function buildShsSemesterTable(title, grades, qAKey, qBKey) {
    const groups = grades.reduce((map, row) => {
        if (!map[row.category]) map[row.category] = [];
        map[row.category].push(row);
        return map;
    }, {});

    const semesterAverages = [];
    const body = Object.entries(groups).map(([category, items]) => `
        <tr class="category-row"><td colspan="4">${escapeHtml(category)}</td></tr>
        ${items.map((row) => {
            const hasBoth = hasQuarterGrade(row[qAKey]) && hasQuarterGrade(row[qBKey]);
            const semesterAverage = hasBoth ? computeAverage([row[qAKey], row[qBKey]]) : null;
            if (hasBoth && semesterAverage !== null) semesterAverages.push(semesterAverage);
            return `
                <tr>
                    <td class="subject-col text-left">${escapeHtml(row.subject)}</td>
                    <td>${formatRating(row[qAKey])}</td>
                    <td>${formatRating(row[qBKey])}</td>
                    <td>${hasBoth ? formatRating(semesterAverage) : ''}</td>
                </tr>
            `;
        }).join('')}
    `).join('') || '<tr><td colspan="4">&nbsp;</td></tr>';

    const allComplete = grades.length > 0 && grades.every((row) => hasQuarterGrade(row[qAKey]) && hasQuarterGrade(row[qBKey]));
    return `
        <div class="semester-block">
            <div class="subsection-title">${escapeHtml(title)}</div>
            <table class="sf9-table grades-table shs-table">
                <thead>
                    <tr>
                        <th class="subject-col text-left">Subjects</th>
                        <th>${escapeHtml(qAKey.toUpperCase())}</th>
                        <th>${escapeHtml(qBKey.toUpperCase())}</th>
                        <th>Semester Final Grade</th>
                    </tr>
                </thead>
                <tbody>${body}</tbody>
                <tfoot>
                    <tr>
                        <td class="text-left footer-label">General Average for the Semester</td>
                        <td></td>
                        <td></td>
                        <td>${allComplete ? formatRating(computeAverage(semesterAverages)) : ''}</td>
                    </tr>
                </tfoot>
            </table>
        </div>
    `;
}

function buildGradesSection(curriculumLevel, grades, generalAverage, motherTongue) {
    if (curriculumLevel === 'shs') {
        return `
            ${buildShsSemesterTable('FIRST SEMESTER', grades, 'q1', 'q2')}
            ${buildShsSemesterTable('SECOND SEMESTER', grades, 'q3', 'q4')}
            <div class="corrected-line">Iniwasto ni: ____________________</div>
        `;
    }
    if (curriculumLevel === 'jhs') {
        return buildJhsGradesTable(grades, generalAverage);
    }
    return buildElementaryGradesTable(grades, generalAverage, motherTongue);
}

function buildObservedValuesTable(rows) {
    const body = rows.map((row) => `
        <tr>
            ${row.showCoreValue ? `<td class="core-value-col" rowspan="${row.rowspan}">${escapeHtml(row.coreValue)}</td>` : ''}
            <td class="text-left behavior-col">${escapeHtml(row.behavior_statement)}</td>
            <td>${escapeHtml(row.q1)}</td>
            <td>${escapeHtml(row.q2)}</td>
            <td>${escapeHtml(row.q3)}</td>
            <td>${escapeHtml(row.q4)}</td>
        </tr>
    `).join('');

    return `
        <table class="sf9-table values-table">
            <thead>
                <tr>
                    <th class="core-value-col">Core Values</th>
                    <th class="behavior-col">Behavior Statements</th>
                    <th>Q1</th>
                    <th>Q2</th>
                    <th>Q3</th>
                    <th>Q4</th>
                </tr>
            </thead>
            <tbody>${body}</tbody>
        </table>
    `;
}

function buildLegends() {
    return `
        <div class="legend-row">
            <div class="legend-box">
                <div class="subsection-title">Observed Values</div>
                <table class="sf9-table legend-table">
                    <thead>
                        <tr>
                            <th>Marking</th>
                            <th>Non-numerical Rating</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr><td>AO</td><td class="text-left">Always Observed</td></tr>
                        <tr><td>SO</td><td class="text-left">Sometimes Observed</td></tr>
                        <tr><td>RO</td><td class="text-left">Rarely Observed</td></tr>
                        <tr><td>NO</td><td class="text-left">Not Observed</td></tr>
                    </tbody>
                </table>
            </div>
            <div class="legend-box">
                <div class="subsection-title">Learner Progress and Achievement</div>
                <table class="sf9-table legend-table">
                    <thead>
                        <tr>
                            <th>Descriptors</th>
                            <th>Grading Scale</th>
                            <th>Remarks</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr><td class="text-left">Outstanding</td><td>90-100</td><td>Passed</td></tr>
                        <tr><td class="text-left">Very Satisfactory</td><td>85-89</td><td>Passed</td></tr>
                        <tr><td class="text-left">Satisfactory</td><td>80-84</td><td>Passed</td></tr>
                        <tr><td class="text-left">Fairly Satisfactory</td><td>75-79</td><td>Passed</td></tr>
                        <tr><td class="text-left">Did Not Meet Expectation</td><td>Below 75</td><td>Failed</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    `;
}

function buildSf9DocumentHtml(data) {
    const school = data?.school || {};
    const enrollment = data?.enrollment || {};
    const learner = data?.learner || {};
    const adviser = data?.adviser || {};
    const curriculumLevel = inferCurriculumLevel(school, enrollment);
    const formCode = getFormCode(curriculumLevel);
    const formTitle = 'LEARNER\'S PROGRESS REPORT CARD';
    const learnerName = parseLearnerName(learner?.name);
    const grades = (Array.isArray(data?.grades) ? data.grades : []).map(sanitizeGradeRow);
    const generalAverage = computeGeneralAverage(grades, data?.general_average);
    const attendance = buildAttendanceData(data?.attendance);
    const observedValuesRows = buildObservedValuesRows(data?.core_values);
    const schoolName = blankIfInvalid(school?.name || school?.school_name);
    const principalTitle = blankIfInvalid(school?.principal_title || 'Principal');
    const trackStrand = blankIfInvalid(school?.track_strand);
    const schoolYear = blankIfInvalid(enrollment?.school_year);
    const region = blankIfInvalid(school?.region);
    const division = blankIfInvalid(school?.division);
    const section = blankIfInvalid(enrollment?.section);
    const gradeLevel = blankIfInvalid(enrollment?.grade_level);
    const adviserName = blankIfInvalid(adviser?.name);
    const age = blankIfInvalid(learner?.age);
    const sex = blankIfInvalid(learner?.sex || learner?.gender);
    const motherTongue = blankIfInvalid(learner?.mother_tongue);
    const logoMarkup = getLogoMarkup(school?.logo_url);
    const rightLogoMarkup = getRightLogoMarkup(school?.deped_logo_url);

    const attendanceHeader = attendance.months.map((item) => `<th>${escapeHtml(item.label)}</th>`).join('');
    const attendanceSchoolDays = attendance.months.map((item) => `<td>${item.schoolDays || ''}</td>`).join('');
    const attendancePresent = attendance.months.map((item) => `<td>${item.present || ''}</td>`).join('');
    const attendanceAbsent = attendance.months.map((item) => `<td>${item.absent || ''}</td>`).join('');

    return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${escapeHtml(blankIfInvalid(learner?.lrn) || '')}</title>
    <style>
        @page { size: A4 landscape; margin: 10mm; }
        * { box-sizing: border-box; }
        html, body { margin: 0; padding: 0; background: #fff; color: #000; font-family: "Times New Roman", serif; }
        body { padding: 8mm; display: flex; flex-wrap: wrap; justify-content: center; gap: 8mm; }
        .no-print { position: fixed; top: 10px; right: 10px; z-index: 10; background: #fff; color: #000; border: 0.5pt solid #000; padding: 6px 10px; font: 8pt "Times New Roman", serif; cursor: pointer; }
        .page { width: 277mm; height: 190mm; overflow: hidden; page-break-after: always; background: #fff; }
        .page:last-of-type { page-break-after: auto; }
        .two-col { display: grid; grid-template-columns: 1fr 1fr; gap: 4mm; width: 100%; height: 100%; }
        .panel { width: 100%; height: 100%; }
        .sf9-table { width: 100%; border-collapse: collapse; table-layout: fixed; }
        .sf9-table th, .sf9-table td { border: 0.5pt solid #000; padding: 1.2mm 1mm; font-size: 7.3pt; vertical-align: middle; text-align: center; }
        .sf9-table th { font-weight: 700; }
        .text-left { text-align: left !important; }
        .center { text-align: center; }
        .small { font-size: 7pt; }
        .tiny { font-size: 6.7pt; }
        .title { font-size: 10pt; font-weight: 700; letter-spacing: 0.2px; text-align: center; text-transform: uppercase; }
        .subsection-title { font-size: 8pt; font-weight: 700; text-align: center; margin-bottom: 1.2mm; text-transform: uppercase; }
        .top-id { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 2mm; font-size: 8pt; font-weight: 700; }
        .lrn-wrap { display: flex; align-items: center; gap: 1.2mm; }
        .lrn-boxes { display: flex; gap: 0.7mm; }
        .lrn-box { width: 5.5mm; height: 5.8mm; border: 0.5pt solid #000; display: inline-flex; align-items: center; justify-content: center; font-size: 7.5pt; }
        .header-block { border: 0.5pt solid #000; padding: 2.2mm; height: calc(100% - 7mm); }
        /* Keep logo at top-left, but center the header text on the full page width */
        .deped-head { position: relative; min-height: 28mm; margin-bottom: 3mm; }
        .deped-seal { position: absolute; left: 0; top: 0; width: 19mm; }
        .deped-seal-right { position: absolute; right: 0; top: 0; width: 24mm; display: flex; justify-content: flex-end; }
        .seal-image, .seal-fallback { width: 18mm; height: 18mm; }
        .deped-seal-right .seal-image, .deped-seal-right .seal-fallback { width: 23mm; height: 23mm; }
        .seal-image { object-fit: contain; display: block; }
        .seal-fallback { border: 1px solid #000; border-radius: 50%; display: flex; align-items: center; justify-content: center; text-align: center; font-size: 6.8pt; line-height: 1.05; }
        .deped-text { position: absolute; left: 50%; top: 0; transform: translateX(-50%); width: calc(100% - 50mm); text-align: center; line-height: 1.2; }
        .deped-text .gov { font-size: 8pt; }
        .deped-text .dept { font-size: 9.5pt; font-weight: 700; text-transform: uppercase; }
        .deped-text .region-line, .deped-text .division-line, .deped-text .school-line { font-size: 7.7pt; }
        .school-name { font-size: 9.5pt; font-weight: 700; text-decoration: underline; text-transform: uppercase; margin-top: 1mm; }
        .student-info { margin-top: 1.4mm; font-size: 8pt; }
        .student-row { display: flex; align-items: flex-end; gap: 2mm; margin-bottom: 1.4mm; }
        .field-group { display: flex; align-items: flex-end; gap: 1.2mm; flex: 1; }
        .field-group.fixed { flex: 0 0 auto; }
        .field-label { font-size: 8pt; white-space: nowrap; }
        .field-line { flex: 1; min-width: 0; border-bottom: 0.5pt solid #000; min-height: 4.5mm; padding: 0 1mm 0.4mm; display: flex; align-items: flex-end; justify-content: center; text-align: center; }
        .field-caption { display: flex; gap: 2mm; margin: -0.7mm 0 1.1mm 12mm; font-size: 6.8pt; text-align: center; }
        .field-caption span { flex: 1; }
        .message-block { margin: 3mm 0 4mm; font-size: 7.7pt; line-height: 1.3; }
        .message-block p { margin: 0 0 1.4mm; text-indent: 5mm; font-style: italic; }
        .signature-stack { margin-top: 3mm; }
        .signature-name { text-align: center; font-size: 8pt; font-weight: 700; }
        .signature-role { text-align: center; font-size: 7pt; }
        .signature-line { border-top: 0.5pt solid #000; width: 55mm; margin: 4.5mm auto 0.8mm; }
        .attendance-box, .transfer-box { border: 0.5pt solid #000; padding: 2mm; }
        .attendance-box { margin-bottom: 3mm; }
        .attendance-table th, .attendance-table td { height: 6mm; }
        .attendance-table .label-cell { width: 33mm; text-align: left; font-weight: 700; }
        .quarter-signatures { margin-top: 3mm; font-size: 7pt; }
        .quarter-signatures .row { display: flex; align-items: center; gap: 2mm; margin-bottom: 2.5mm; }
        .quarter-signatures .line { flex: 1; border-bottom: 0.5pt solid #000; height: 4mm; }
        .transfer-section-title { font-size: 8pt; font-weight: 700; text-align: center; margin: 1mm 0 2mm; }
        .transfer-line { display: flex; align-items: flex-end; gap: 2mm; margin-bottom: 2mm; font-size: 7.4pt; }
        .transfer-fill { flex: 1; border-bottom: 0.5pt solid #000; min-height: 4mm; }
        .transfer-signatures { display: grid; grid-template-columns: 1fr 1fr; gap: 6mm; margin-top: 3mm; }
        .transfer-signatures .sig { text-align: center; font-size: 7pt; }
        .transfer-signatures .sig .line, .cancel-line { border-bottom: 0.5pt solid #000; height: 5mm; margin-bottom: 1mm; }
        /* Back page: locked 50/50 split (no responsive reflow) */
        .back-grid { display: grid; grid-template-columns: calc(50% - 2mm) calc(50% - 2mm); gap: 4mm; width: 100%; height: 100%; }
        .grades-panel, .values-panel { height: 100%; display: flex; flex-direction: column; min-width: 0; }
        .grades-panel .title, .values-panel .title { margin-bottom: 2mm; }
        .table-block { flex: 1 1 auto; height: 118mm; overflow: hidden; }
        /* Slightly shorten the report card (grades) side so its bottom aligns with the values table end */
        .grades-panel .table-block { height: 112mm; }
        .table-block > table { height: 100%; }
        .subject-col { width: 55mm; }
        .grades-table th:nth-child(2), .grades-table th:nth-child(3), .grades-table th:nth-child(4), .grades-table th:nth-child(5) { width: 12mm; }
        .grades-table th:nth-child(6) { width: 18mm; }
        .grades-table th:nth-child(7) { width: 15mm; }
        .grades-table td, .grades-table th { font-size: 7.1pt; }
        .category-row td { font-weight: 700; text-align: left; background: #fff; }
        .footer-label { font-weight: 700; }
        .semester-block { margin-bottom: 3mm; }
        .corrected-line { margin-top: 4mm; font-size: 7.4pt; text-align: left; }
        .values-panel .title { margin-bottom: 2mm; }
        .core-value-col { width: 22mm; font-weight: 700; }
        .behavior-col { width: auto; }
        /* Legends live under Observed Values (right panel) */
        .legend-row { display: grid; grid-template-columns: 1fr 1fr; gap: 3mm; margin-top: 3mm; }
        .legend-box { width: 100%; }
        .legend-table th, .legend-table td { font-size: 6.9pt; }
        .summary-note { margin-top: 2mm; font-size: 7pt; text-align: left; }
        @media print {
            body { padding: 0; display: block; gap: 0; }
            .no-print { display: none; }
            .page { margin: 0; width: 277mm; height: 190mm; }
        }
    </style>
</head>
<body>
    <div class="page">
        <div class="two-col">
            <div class="panel">
                <div class="attendance-box">
                    <div class="subsection-title">REPORT ON ATTENDANCE</div>
                    <table class="sf9-table attendance-table">
                        <thead>
                            <tr>
                                <th class="label-cell"></th>
                                ${attendanceHeader}
                                <th>Total</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td class="label-cell">No. of School Days</td>
                                ${attendanceSchoolDays}
                                <td>${attendance.totals.schoolDays || ''}</td>
                            </tr>
                            <tr>
                                <td class="label-cell">No. of Days Present</td>
                                ${attendancePresent}
                                <td>${attendance.totals.present || ''}</td>
                            </tr>
                            <tr>
                                <td class="label-cell">No. of Days Absent</td>
                                ${attendanceAbsent}
                                <td>${attendance.totals.absent || ''}</td>
                            </tr>
                        </tbody>
                    </table>
                    <div class="quarter-signatures">
                        <div class="small" style="font-weight:700;">PARENT / GUARDIAN'S SIGNATURE</div>
                        <div class="row"><span>1st Quarter</span><span class="line"></span></div>
                        <div class="row"><span>2nd Quarter</span><span class="line"></span></div>
                        <div class="row"><span>3rd Quarter</span><span class="line"></span></div>
                        <div class="row"><span>4th Quarter</span><span class="line"></span></div>
                    </div>
                </div>
                <div class="transfer-box">
                    <div class="transfer-section-title">Certificate of Transfer</div>
                    <div class="transfer-line"><span>Admitted to Grade:</span><span class="transfer-fill"></span><span>Section:</span><span class="transfer-fill"></span></div>
                    <div class="transfer-line"><span>Eligibility for Admission to Grade:</span><span class="transfer-fill"></span></div>
                    <div class="transfer-signatures">
                        <div class="sig">
                            <div class="line"></div>
                            <div>School Head</div>
                        </div>
                        <div class="sig">
                            <div class="line"></div>
                            <div>Adviser</div>
                        </div>
                    </div>
                    <div class="transfer-section-title" style="margin-top:4mm;">Cancellation of Eligibility to Transfer</div>
                    <div class="transfer-line"><span>Admitted in:</span><span class="transfer-fill"></span></div>
                    <div class="transfer-line"><span>Date:</span><span class="transfer-fill"></span><span style="width:26mm;"></span></div>
                    <div class="cancel-line" style="width:54mm; margin:5mm auto 1mm;"></div>
                    <div class="center small">School Head</div>
                </div>
            </div>
            <div class="panel">
                <div class="top-id">
                    <div>${escapeHtml(formCode)}</div>
                    <div class="lrn-wrap">
                        <span>LRN</span>
                        <span class="lrn-boxes">${buildLrnBoxes(learner?.lrn)}</span>
                    </div>
                </div>
                <div class="header-block">
                    <div class="deped-head">
                        <div class="deped-seal">${logoMarkup}</div>
                        <div class="deped-seal-right">${rightLogoMarkup}</div>
                        <div class="deped-text">
                            <div class="gov">Republic of the Philippines</div>
                            <div class="dept">DEPARTMENT OF EDUCATION</div>
                            <div class="region-line">${escapeHtml(region)}</div>
                            <div class="region-line">Region</div>
                            <div class="division-line" style="margin-top:1.2mm;">DIVISION OF ${escapeHtml(division)}</div>
                            <div class="division-line">Division</div>
                            <div class="school-name" style="margin-top:1.5mm;">${escapeHtml(schoolName)}</div>
                            <div class="school-line">School</div>
                        </div>
                    </div>
                    <div class="student-info">
                        <div class="student-row">
                            <div class="field-group"><span class="field-label">Name:</span><span class="field-line">${escapeHtml(learnerName.lastName)}</span><span class="field-line">${escapeHtml(learnerName.firstName)}</span><span class="field-line">${escapeHtml(learnerName.middleName)}</span></div>
                        </div>
                        <div class="field-caption"><span>Last Name</span><span>First Name</span><span>Middle Name</span></div>
                        <div class="student-row">
                            <div class="field-group fixed" style="width:40%;">
                                <span class="field-label">Age:</span><span class="field-line">${escapeHtml(age)}</span>
                            </div>
                            <div class="field-group fixed" style="width:40%;">
                                <span class="field-label">Sex:</span><span class="field-line">${escapeHtml(sex)}</span>
                            </div>
                        </div>
                        <div class="student-row">
                            <div class="field-group"><span class="field-label">Grade:</span><span class="field-line">${escapeHtml(gradeLevel)}</span></div>
                            <div class="field-group"><span class="field-label">Section:</span><span class="field-line">${escapeHtml(section)}</span></div>
                        </div>
                        <div class="student-row">
                            <div class="field-group"><span class="field-label">Curriculum:</span><span class="field-line">K to 12 Basic Education Curriculum</span></div>
                        </div>
                        <div class="student-row">
                            <div class="field-group"><span class="field-label">School Year:</span><span class="field-line">${escapeHtml(schoolYear)}</span></div>
                        </div>
                        ${curriculumLevel === 'shs' ? `<div class="student-row"><div class="field-group"><span class="field-label">Track/Strand:</span><span class="field-line">${escapeHtml(trackStrand)}</span></div></div>` : ''}
                    </div>
                    <div class="message-block">
                        <p>Dear Parent/Guardian,</p>
                        <p>This report card shows the ability and progress your child has made in the different learning areas as well as his/her core values.</p>
                        <p>The school welcomes you should you desire to know more about your child's progress.</p>
                    </div>
                    <div class="signature-stack">
                        <div class="signature-name">${escapeHtml(adviserName)}</div>
                        <div class="signature-role">Adviser</div>
                        <div class="signature-line"></div>
                        <div class="signature-role">Principal ${escapeHtml(principalTitle)}</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="page">
        <div class="back-grid">
            <div class="grades-panel">
                <div class="title">${formTitle}</div>
                <div class="table-block">
                    ${buildGradesSection(curriculumLevel, grades, generalAverage, motherTongue)}
                </div>
            </div>
            <div class="values-panel">
                <div class="title">REPORT ON LEARNER'S OBSERVED VALUES</div>
                <div class="table-block">
                    ${buildObservedValuesTable(observedValuesRows)}
                </div>
                ${buildLegends()}
            </div>
        </div>
    </div>
</body>
</html>`;
}
