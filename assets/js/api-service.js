// ===========================
// API Service using Axios
// Centralized API calls
// ===========================

function getAppPrefix() {
    const pathname = String(window.location.pathname || '/');
    let appPrefix = '';

    if (pathname.includes('/dashboard/')) {
        appPrefix = pathname.split('/dashboard/')[0] || '';
    } else if (pathname.includes('/pages/')) {
        appPrefix = pathname.split('/pages/')[0] || '';
    } else if (pathname.includes('/assets/')) {
        appPrefix = pathname.split('/assets/')[0] || '';
    } else if (pathname.includes('/api/')) {
        appPrefix = pathname.split('/api/')[0] || '';
    } else if (pathname.endsWith('.html')) {
        appPrefix = pathname.substring(0, pathname.lastIndexOf('/')) || '';
    } else {
        appPrefix = pathname.endsWith('/') ? pathname.slice(0, -1) : pathname;
    }

    if (appPrefix === '/') appPrefix = '';
    return appPrefix;
}

// Base URL for API (works from Apache or from VS Code Live Server)
// Important: avoid hard-coded localhost to keep PHP session cookies consistent
// when opened as 127.0.0.1 vs localhost.
// We detect Apache vs Live Server by URL path (ports can vary).
const isApacheServed = String(window.location.pathname || '').includes('/deped_capstone2/');
const API_BASE_URL = isApacheServed
    ? `${getAppPrefix()}/api`
    : `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;

// Axios configuration
axios.defaults.headers.common['Content-Type'] = 'application/json';
axios.defaults.headers.common['Accept'] = 'application/json';
axios.defaults.withCredentials = true;

// ===========================
// Dashboard APIs
// ===========================

const DashboardAPI = {
    // Get dashboard statistics
    getStats: async () => {
        try {
            const response = await axios.get(`${API_BASE_URL}/dashboard/stats.php`);
            return response.data;
        } catch (error) {
            console.error('Error fetching dashboard stats:', error);
            throw error;
        }
    },

    // Get enrollment trend
    getEnrollmentTrend: async () => {
        try {
            const response = await axios.get(`${API_BASE_URL}/dashboard/enrollment-trend.php`);
            return response.data;
        } catch (error) {
            console.error('Error fetching enrollment trend:', error);
            throw error;
        }
    },

    // Get grade distribution
    getGradeDistribution: async () => {
        try {
            const response = await axios.get(`${API_BASE_URL}/dashboard/grade-distribution.php`);
            return response.data;
        } catch (error) {
            console.error('Error fetching grade distribution:', error);
            throw error;
        }
    },

    // Get alerts
    getAlerts: async () => {
        try {
            const response = await axios.get(`${API_BASE_URL}/dashboard/alerts.php`);
            return response.data;
        } catch (error) {
            console.error('Error fetching alerts:', error);
            throw error;
        }
    }
};

// ===========================
// Students APIs
// ===========================

const StudentsAPI = {
    getAll: async () => axios.get(`${API_BASE_URL}/students/students.php`, { params: { operation: 'getAllStudents' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/students/students.php?operation=createStudent`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/students/students.php?operation=updateStudent`, { ...data, student_id: id }).then(r => r.data),
    delete: async (id) => axios.post(`${API_BASE_URL}/students/students.php?operation=deleteStudent`, { student_id: id }).then(r => r.data)
};

// ===========================
// Employees APIs
// ===========================

const EmployeesAPI = {
    getAll: async () => axios.get(`${API_BASE_URL}/employees/employees.php`, { params: { operation: 'getAllEmployees' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/employees/employees.php?operation=createEmployee`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/employees/employees.php?operation=updateEmployee`, { ...data, employee_id: id }).then(r => r.data),
    delete: async (id) => axios.post(`${API_BASE_URL}/employees/employees.php?operation=deleteEmployee`, { employee_id: id }).then(r => r.data)
};

// ===========================
// Subjects APIs
// ===========================

const SubjectsAPI = {
    getAll: async () => axios.get(`${API_BASE_URL}/subjects/subjects.php`, { params: { operation: 'getAllSubjects' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/subjects/subjects.php?operation=createSubject`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/subjects/subjects.php?operation=updateSubject`, { ...data, subject_id: id }).then(r => r.data),
    delete: async (id) => axios.post(`${API_BASE_URL}/subjects/subjects.php?operation=deleteSubject`, { subject_id: id }).then(r => r.data)
};

// ===========================
// Sections APIs
// ===========================

const SectionsAPI = {
    getAll: async () => axios.get(`${API_BASE_URL}/sections/sections.php`, { params: { operation: 'getAllSections' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/sections/sections.php?operation=createSection`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/sections/sections.php?operation=updateSection`, { ...data, section_id: id }).then(r => r.data),
    delete: async (id) => axios.post(`${API_BASE_URL}/sections/sections.php?operation=deleteSection`, { section_id: id }).then(r => r.data)
};

// ===========================
// Grade Levels APIs
// ===========================

const GradeLevelsAPI = {
    getAll: async () => axios.get(`${API_BASE_URL}/grade_levels/grade_levels.php`, { params: { operation: 'getAllGradeLevels' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/grade_levels/grade_levels.php?operation=createGradeLevel`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/grade_levels/grade_levels.php?operation=updateGradeLevel`, { ...data, grade_level_id: id }).then(r => r.data),
    delete: async (id) => axios.post(`${API_BASE_URL}/grade_levels/grade_levels.php?operation=deleteGradeLevel`, { grade_level_id: id }).then(r => r.data)
};

// ===========================
// School Years APIs
// ===========================

const SchoolYearsAPI = {
    getAll: async () => axios.get(`${API_BASE_URL}/school_years/school_years.php`, { params: { operation: 'getAllSchoolYears' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/school_years/school_years.php?operation=createSchoolYear`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/school_years/school_years.php?operation=updateSchoolYear`, { ...data, school_year_id: id }).then(r => r.data),
    delete: async (id) => axios.post(`${API_BASE_URL}/school_years/school_years.php?operation=deleteSchoolYear`, { school_year_id: id }).then(r => r.data)
};

// ===========================
// Users APIs
// ===========================

const UsersAPI = {
    getAll: async () => axios.get(`${API_BASE_URL}/users/users.php`, { params: { operation: 'getAllUsers' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/users/users.php?operation=createUser`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/users/users.php?operation=updateUser`, { ...data, user_id: id }).then(r => r.data),
    delete: async (id) => axios.post(`${API_BASE_URL}/users/users.php?operation=deleteUser`, { user_id: id }).then(r => r.data)
};

// ===========================
// Roles APIs
// ===========================

const RolesAPI = {
    getAll: async () => axios.get(`${API_BASE_URL}/roles/roles.php`, { params: { operation: 'getAllRoles' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/roles/roles.php?operation=createRole`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/roles/roles.php?operation=updateRole`, { ...data, role_id: id }).then(r => r.data),
    delete: async (id) => axios.post(`${API_BASE_URL}/roles/roles.php?operation=deleteRole`, { role_id: id }).then(r => r.data)
};

// Reference masterfiles
const SubjectCodesAPI = {
    getAll: async () => axios.get(`${API_BASE_URL}/subject_codes/subject_codes.php`, { params: { operation: 'getAllSubjectCodes' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/subject_codes/subject_codes.php?operation=createSubjectCode`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/subject_codes/subject_codes.php?operation=updateSubjectCode`, { ...data, subject_code_id: id }).then(r => r.data),
    delete: async (id) => axios.post(`${API_BASE_URL}/subject_codes/subject_codes.php?operation=deleteSubjectCode`, { subject_code_id: id }).then(r => r.data)
};

const EducationLevelsAPI = {
    getAll: async () => axios.get(`${API_BASE_URL}/education_levels/education_levels.php`, { params: { operation: 'getAllEducationLevels' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/education_levels/education_levels.php?operation=createEducationLevel`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/education_levels/education_levels.php?operation=updateEducationLevel`, { ...data, education_level_id: id }).then(r => r.data),
    delete: async (id) => axios.post(`${API_BASE_URL}/education_levels/education_levels.php?operation=deleteEducationLevel`, { education_level_id: id }).then(r => r.data)
};

const GradingSystemsAPI = {
    getAll: async () => axios.get(`${API_BASE_URL}/grading_system_types/grading_system_types.php`, { params: { operation: 'getAllGradingSystems' } }).then(r => r.data),
    create: async (data) => axios.post(`${API_BASE_URL}/grading_system_types/grading_system_types.php?operation=createGradingSystem`, data).then(r => r.data),
    update: async (id, data) => axios.post(`${API_BASE_URL}/grading_system_types/grading_system_types.php?operation=updateGradingSystem`, { ...data, grading_system_type_id: id }).then(r => r.data),
    delete: async (id) => axios.post(`${API_BASE_URL}/grading_system_types/grading_system_types.php?operation=deleteGradingSystem`, { grading_system_type_id: id }).then(r => r.data)
};

// ===========================
// Grades APIs
// ===========================

const GradesAPI = {
    getAll: async (filters = {}) => {
        try {
            const response = await axios.get(`${API_BASE_URL}/grades/index.php`, { params: filters });
            return response.data;
        } catch (error) {
            console.error('Error fetching grades:', error);
            throw error;
        }
    },

    create: async (data) => {
        try {
            const response = await axios.post(`${API_BASE_URL}/grades/create.php`, data);
            return response.data;
        } catch (error) {
            console.error('Error creating grade:', error);
            throw error;
        }
    },

    update: async (id, data) => {
        try {
            const response = await axios.put(`${API_BASE_URL}/grades/update.php?id=${id}`, data);
            return response.data;
        } catch (error) {
            console.error('Error updating grade:', error);
            throw error;
        }
    }
};

// Export all APIs
window.API = {
    Dashboard: DashboardAPI,
    Students: StudentsAPI,
    Employees: EmployeesAPI,
    Subjects: SubjectsAPI,
    Sections: SectionsAPI,
    GradeLevels: GradeLevelsAPI,
    SchoolYears: SchoolYearsAPI,
    Users: UsersAPI,
    Roles: RolesAPI,
    SubjectCodes: SubjectCodesAPI,
    EducationLevels: EducationLevelsAPI,
    GradingSystems: GradingSystemsAPI,
    Grades: GradesAPI
};
