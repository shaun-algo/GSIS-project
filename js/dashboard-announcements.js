// ===========================
// Dashboard Announcements
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

let currentUser = null;
let editingAnnouncementId = null;
let announcementsIndex = new Map();

function isLearnerRole(roleName) {
    const normalized = String(roleName || '').trim().toLowerCase();
    return normalized.includes('learner') || normalized.includes('student');
}

function isAdminRole(roleName) {
    const normalized = String(roleName || '').trim().toLowerCase();
    return normalized.includes('admin');
}

function isTeacherRole(roleName) {
    const normalized = String(roleName || '').trim().toLowerCase();
    return normalized.includes('teacher');
}

function canCurrentUserPostAnnouncements() {
    if (!currentUser) return false;
    return isAdminRole(currentUser.role_name) || isTeacherRole(currentUser.role_name);
}

function applyAnnouncementPostingPermissions() {
    if (!currentUser) return;
    if (canCurrentUserPostAnnouncements()) return;

    const createBtn = document.getElementById('createAnnouncementBtn');
    const composeField = document.getElementById('composeField');
    const composeCard = document.getElementById('composeCard');
    const modal = document.getElementById('createAnnouncementModal');

    if (createBtn) createBtn.style.display = 'none';
    if (composeField) composeField.style.display = 'none';
    if (composeCard) composeCard.style.display = 'none';
    if (modal) modal.classList.remove('active');
}

document.addEventListener('DOMContentLoaded', function() {
    if (window.axios) {
        try {
            window.axios.defaults.withCredentials = true;
        } catch (_) {
            // ignore
        }
    }
    console.log('🚀 Dashboard Announcements initialized');
    initializeAnnouncementNavigation();
    initializeAnnouncementModal();
    initializeComposerFeatures();
    initializeReadMoreToggle();
    loadCurrentUser();
    loadAnnouncements();
});

function initializeReadMoreToggle() {
    const feed = document.getElementById('announcementsFeed');
    if (!feed) return;

    feed.addEventListener('click', (event) => {
        const toggleBtn = event.target.closest('.announcement-readmore');
        if (!toggleBtn) return;

        const content = toggleBtn.closest('.announcement-content');
        if (!content) return;

        const isExpanded = content.dataset.expanded === 'true';
        content.dataset.expanded = isExpanded ? 'false' : 'true';
        toggleBtn.textContent = isExpanded ? 'Read more' : 'Read less';
    });
}

function openComposeModal() {
    const modal = document.getElementById('createAnnouncementModal');
    const form = document.getElementById('createAnnouncementForm');
    if (!modal || !form) {
        console.error('Compose modal elements not found.');
        return;
    }

    editingAnnouncementId = null;
    modal.classList.add('active');
    form.reset();

    setComposerMode('create');

    const titleCounter = document.getElementById('titleCounter');
    const contentCounter = document.getElementById('contentCounter');
    if (titleCounter) titleCounter.textContent = '0';
    if (contentCounter) contentCounter.textContent = '0';

    const attachmentPreview = document.getElementById('attachmentPreview');
    if (attachmentPreview) attachmentPreview.style.display = 'none';
}

window.openComposeModal = openComposeModal;

// ===========================
// Navigation Management
// ===========================

function initializeAnnouncementNavigation() {
    // Handle sidebar section navigation
    const navLinks = document.querySelectorAll('.nav-link[data-section]');
    const submenuLinks = document.querySelectorAll('.submenu a[data-section]');

    navLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const section = link.dataset.section;
            navigateToSection(section);

            // Update active state
            document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
            link.classList.add('active');
        });
    });

    submenuLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const section = link.dataset.section;
            navigateToSection(section);

            // Update active state
            document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
            document.querySelectorAll('.submenu a').forEach(l => l.classList.remove('active'));
            link.classList.add('active');
        });
    });

    // Handle hash navigation
    window.addEventListener('hashchange', handleHashChange);
    handleHashChange(); // Initial load
}

function handleHashChange() {
    const hash = window.location.hash.substring(1) || 'home';
    navigateToSection(hash);
}

function navigateToSection(sectionName) {
    // Hide all sections
    const sections = document.querySelectorAll('.content-section');
    sections.forEach(section => section.classList.remove('active'));

    // Show target section
    const targetSection = document.getElementById(`${sectionName}Section`);
    if (targetSection) {
        targetSection.classList.add('active');

        // Update URL hash without scrolling
        history.pushState(null, null, `#${sectionName}`);

        // Load section-specific data
        loadSectionData(sectionName);
    }
}

function loadSectionData(sectionName) {
    switch(sectionName) {
        case 'home':
            loadAnnouncements();
            break;
        case 'dashboard-overview':
        case 'enrollment-analytics':
        case 'performance-analytics':
        case 'grade-distribution':
            if (sectionName === 'dashboard-overview') {
                setTimeout(() => initializeDashboardOverviewCharts(), 100);
            }
            break;
    }
}

// ===========================
// User Management
// ===========================

async function loadCurrentUser() {
    try {
        const response = await axios.get(`${window.API_BASE}/auth/me.php`);
        if (!response.data?.success) {
            return;
        }

        currentUser = response.data.data;

        const composerUserName = document.getElementById('composerUserName');
        if (composerUserName) {
            const fullName = currentUser.full_name || `${currentUser.first_name || ''} ${currentUser.last_name || ''}`.trim();
            composerUserName.textContent = fullName || currentUser.username || 'User';
        }

        applyAnnouncementPostingPermissions();
        if (canCurrentUserPostAnnouncements()) {
            loadRoles();
        }
    } catch (error) {
        if (error?.response?.status === 401) {
            return;
        }
        console.error('Error loading user:', error);
    }
}

// ===========================
// Composer Features
// ===========================

function initializeComposerFeatures() {
    // Character counters
    const titleInput = document.getElementById('announcementTitle');
    const bodyTextarea = document.getElementById('announcementBody');
    const titleCounter = document.getElementById('titleCounter');
    const contentCounter = document.getElementById('contentCounter');

    if (titleInput && titleCounter) {
        titleInput.addEventListener('input', (e) => {
            const length = e.target.value.length;
            titleCounter.textContent = length;

            // Update counter color
            titleCounter.classList.remove('warning', 'danger');
            if (length > 180) titleCounter.classList.add('warning');
            if (length > 195) titleCounter.classList.add('danger');
        });
    }

    if (bodyTextarea && contentCounter) {
        bodyTextarea.addEventListener('input', (e) => {
            const length = e.target.value.length;
            contentCounter.textContent = length;
        });
    }

    // Advanced options toggle
    const advancedToggle = document.getElementById('advancedToggle');
    const advancedOptions = document.getElementById('advancedOptions');

    if (advancedToggle && advancedOptions) {
        advancedToggle.addEventListener('click', () => {
            const isVisible = advancedOptions.style.display === 'block';
            advancedOptions.style.display = isVisible ? 'none' : 'block';
            advancedToggle.classList.toggle('active');
        });
    }
}

// ===========================
// Announcements Management
// ===========================

function normalizeAnnouncementsPayload(payload) {
    if (!payload) return [];

    if (Array.isArray(payload)) {
        return payload;
    }

    if (typeof payload === 'string') {
        try {
            const parsed = JSON.parse(payload);
            return normalizeAnnouncementsPayload(parsed);
        } catch (_) {
            return [];
        }
    }

    if (typeof payload === 'object') {
        if (payload.success === false) {
            return [];
        }
        if (Array.isArray(payload.data)) {
            return payload.data;
        }
        if (Array.isArray(payload.announcements)) {
            return payload.announcements;
        }
    }

    return [];
}

async function loadAnnouncements() {
    console.log('🔄 Loading announcements...');
    try {
        const response = await axios.get(`${window.API_BASE}/announcements/announcements.php?operation=getAllAnnouncements`);
        const announcements = normalizeAnnouncementsPayload(response.data);
        console.log('✅ Announcements loaded:', announcements);

        displayAnnouncements(announcements);
    } catch (error) {
        console.error('❌ Error loading announcements:', error);
        const apiMessage = error?.response?.data?.message;
        const message = apiMessage || error?.message || 'Failed to load announcements';
        showNotification(message, 'error');

        // Show error in feed
        const feedContainer = document.getElementById('announcementsFeed');
        if (feedContainer) {
            feedContainer.innerHTML = `
                <div style="padding: 2rem; background: #fee; border: 2px solid #f00; border-radius: 8px;">
                    <strong>Error loading announcements:</strong> ${message}
                    <br><br>
                    <button onclick="loadAnnouncements()" class="btn btn-primary">
                        <i class="fas fa-sync"></i> Try Again
                    </button>
                </div>
            `;
        }
    }
}

window.loadAnnouncements = loadAnnouncements;

function tryFocusAnnouncementFromNotification() {
    let id = 0;
    try {
        id = Number(sessionStorage.getItem('focusAnnouncementId') || 0);
    } catch (_) {
        id = 0;
    }

    if (!Number.isFinite(id) || id <= 0) return;

    // Clear immediately to avoid repeated attempts.
    try {
        sessionStorage.removeItem('focusAnnouncementId');
    } catch (_) {
        // ignore
    }

    // Prefer the shared helper from dashboard.js if present.
    if (typeof window.focusAnnouncementInFeedNow === 'function') {
        const ok = window.focusAnnouncementInFeedNow(id);
        if (!ok) {
            showNotification('Announcement not found in the feed.', 'info');
        }
        return;
    }

    // Fallback: local focus.
    const feed = document.getElementById('announcementsFeed');
    const card = feed ? feed.querySelector(`.announcement-card[data-id="${String(id)}"]`) : null;
    if (!card) {
        showNotification('Announcement not found in the feed.', 'info');
        return;
    }

    const headerOffset = (() => {
        const candidates = [
            document.querySelector('.topbar'),
            document.querySelector('header'),
            document.querySelector('.header')
        ].filter(Boolean);

        for (const el of candidates) {
            try {
                const style = window.getComputedStyle(el);
                const pos = String(style.position || '').toLowerCase();
                const top = parseFloat(style.top || '0');
                if ((pos === 'fixed' || pos === 'sticky') && (Number.isFinite(top) ? top : 0) === 0) {
                    const h = el.getBoundingClientRect().height;
                    if (h > 0) return h;
                }
            } catch (_) {
                // ignore
            }
        }
        return 0;
    })();

    const viewportH = window.innerHeight || document.documentElement.clientHeight || 0;
    const rect = card.getBoundingClientRect();

    if (viewportH > 0) {
        const effectiveH = Math.max(0, viewportH - headerOffset);
        const desiredTopInViewport = headerOffset + Math.max(12, (effectiveH / 2) - (rect.height / 2));
        const targetTop = window.scrollY + rect.top - desiredTopInViewport;

        try {
            window.scrollTo({ top: Math.max(0, targetTop), behavior: 'smooth' });
        } catch (_) {
            window.scrollTo(0, Math.max(0, targetTop));
        }
    } else {
        try {
            card.scrollIntoView({ behavior: 'smooth', block: 'center' });
        } catch (_) {
            card.scrollIntoView(true);
        }
    }
}

function displayAnnouncements(announcements) {
    const feedContainer = document.getElementById('announcementsFeed');
    const safeAnnouncements = normalizeAnnouncementsPayload(announcements);
    console.log('📝 Displaying announcements:', safeAnnouncements?.length || 0, 'items');

    // Keep an index for edit lookups.
    announcementsIndex = new Map(
        (safeAnnouncements || []).map((a) => [String(a.announcement_id), a])
    );

    if (!feedContainer) {
        console.error('❌ announcementsFeed element not found!');
        return;
    }

    if (!safeAnnouncements || safeAnnouncements.length === 0) {
        feedContainer.innerHTML = `
            <div class="empty-state">
                <i class="fas fa-bullhorn"></i>
                <h3>No Announcements Yet</h3>
                <p>Be the first to post an announcement!</p>
            </div>
        `;

        // If we were trying to focus a specific announcement, it won't exist.
        tryFocusAnnouncementFromNotification();
        return;
    }

    try {
        feedContainer.innerHTML = safeAnnouncements.map(announcement => createAnnouncementCard(announcement)).join('');
        console.log('✅ Announcements displayed in feed');

        // If we navigated here from a notification, focus the matching post.
        tryFocusAnnouncementFromNotification();
    } catch (error) {
        console.error('❌ Error creating announcement cards:', error);
        feedContainer.innerHTML = `
            <div style="padding: 2rem; background: #fee; border: 2px solid #f00; border-radius: 8px;">
                <strong>Error displaying announcements:</strong> ${error.message}
            </div>
        `;
    }
}

window.displayAnnouncements = displayAnnouncements;

function createAnnouncementCard(announcement) {
    const publishedDate = new Date(announcement.published_at);
    const isExpired = announcement.expires_at && new Date(announcement.expires_at) < new Date();
    const isPinned = announcement.is_pinned == 1;
    const canManage = canCurrentUserManageAnnouncement(announcement);

    const postedAt = announcement.seconds_ago !== undefined
        ? formatTimeAgoFromSeconds(announcement.seconds_ago, publishedDate)
        : formatTimeAgo(publishedDate);

    const authorName = announcement.first_name && announcement.last_name
        ? `${announcement.first_name} ${announcement.last_name}`
        : announcement.posted_by_name || 'System';

    const targetAudience = announcement.target_role_name || 'Everyone';
    const bodyText = announcement.body || '';
    const maxLength = 280;
    const isLongContent = bodyText.length > maxLength;
    const shortContent = escapeHtml(bodyText.slice(0, maxLength)).replace(/\n/g, '<br>');
    const fullContent = escapeHtml(bodyText).replace(/\n/g, '<br>');
    const contentHtml = isLongContent
        ? `
            <span class="announcement-content-short">${shortContent}</span>
            <span class="announcement-content-ellipsis">...</span>
            <span class="announcement-content-full">${fullContent}</span>
            <button class="announcement-readmore" type="button">Read more</button>
        `
        : fullContent;

    return `
        <div class="announcement-card ${isExpired ? 'expired' : ''} ${isPinned ? 'pinned' : ''}" data-id="${announcement.announcement_id}">
            <div class="announcement-header">
                <div class="announcement-author">
                    <div class="author-avatar">
                        <i class="fas fa-user-circle"></i>
                    </div>
                    <div class="author-info">
                        <h4 class="author-name">${escapeHtml(authorName)}</h4>
                        <p class="author-role">
                            <i class="fas fa-${targetAudience === 'Everyone' ? 'globe' : 'users'}"></i>
                            ${escapeHtml(targetAudience)}
                            ${isPinned ? ' <span class="pin-badge"><i class="fas fa-thumbtack"></i>Pinned</span>' : ''}
                        </p>
                    </div>
                </div>
                <div class="announcement-meta">
                    <span class="announcement-time">${postedAt}</span>
                    ${isExpired ? '<span class="expired-badge"><i class="fas fa-times-circle"></i> Expired</span>' : ''}
                </div>
            </div>
            <div class="announcement-body">
                <h3 class="announcement-title">${escapeHtml(announcement.title)}</h3>
                <div class="announcement-content" ${isLongContent ? 'data-expanded="false"' : ''}>
                    ${contentHtml}
                </div>
                ${announcement.attachment_url ? `
                    <div class="announcement-attachment">
                        <i class="fas fa-paperclip"></i>
                        <div class="attachment-info">
                            <strong>Attachment</strong>
                            <small>${announcement.attachment_url.split('/').pop()}</small>
                        </div>
                        <a href="${announcement.attachment_url}" class="btn btn-sm btn-outline" download>
                            <i class="fas fa-download"></i>
                        </a>
                    </div>
                ` : ''}
            </div>
            <div class="announcement-footer">
                ${canManage ? `
                    <div class="announcement-actions">
                        ${!isPinned ? `
                            <button class="btn-icon" onclick="pinAnnouncement(${announcement.announcement_id}, 1)" title="Pin to top">
                                <i class="fas fa-thumbtack"></i>
                            </button>
                        ` : `
                            <button class="btn-icon" onclick="pinAnnouncement(${announcement.announcement_id}, 0)" title="Unpin">
                                <i class="fas fa-times"></i>
                            </button>
                        `}
                        <button class="btn-icon" onclick="editAnnouncement(${announcement.announcement_id})" title="Edit">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn-icon btn-danger" onclick="deleteAnnouncement(${announcement.announcement_id})" title="Delete">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                ` : ''}
                ${announcement.expires_at ? `
                    <div class="announcement-expiry">
                        <i class="fas fa-calendar-times"></i>
                        Expires: ${formatDate(new Date(announcement.expires_at))}
                    </div>
                ` : ''}
            </div>
        </div>
    `;
}

function canCurrentUserManageAnnouncement(announcement) {
    if (!currentUser) return false;

    // Prefer backend-provided ownership flag (returned by announcements API).
    if (String(announcement?.is_owner) === '1') return true;

    // Fallback for older payloads: compare IDs.
    return String(currentUser.user_id) === String(announcement?.posted_by);
}

// ===========================
// Pin/Unpin Announcement
// ===========================

async function pinAnnouncement(announcementId, isPinned) {
    const announcement = announcementsIndex?.get(String(announcementId));
    if (!announcement || !canCurrentUserManageAnnouncement(announcement)) {
        showNotification('Not authorized to manage this announcement.', 'error');
        return;
    }
    try {
        const response = await axios.post(
            `${window.API_BASE}/announcements/announcements.php?operation=pinAnnouncement`,
            {
                announcement_id: announcementId,
                is_pinned: isPinned
            },
            { headers: { 'Content-Type': 'application/json' } }
        );

        if (response.data.success) {
            showNotification(response.data.message, 'success');
            loadAnnouncements();
        } else {
            showNotification(response.data.message || 'Failed to update pin status', 'error');
        }
    } catch (error) {
        console.error('Error pinning announcement:', error);
        showNotification('An error occurred while updating pin status', 'error');
    }
}

// Make function globally accessible
window.pinAnnouncement = pinAnnouncement;

// ===========================
// Announcement Modal
// ===========================

function initializeAnnouncementModal() {
    const createBtn = document.getElementById('createAnnouncementBtn');
    const composeField = document.getElementById('composeField');
    const composeCard = document.getElementById('composeCard');
    const modal = document.getElementById('createAnnouncementModal');
    const closeBtn = document.getElementById('closeAnnouncementModal');
    const cancelBtn = document.getElementById('cancelAnnouncementBtn');
    const form = document.getElementById('createAnnouncementForm');

    // If this page doesn't include the compose modal UI, exit safely.
    if (!modal) {
        return;
    }

    if (createBtn) {
        createBtn.addEventListener('click', openComposeModal);
    }

    if (composeField) {
        composeField.addEventListener('click', openComposeModal);
    }

    if (composeCard) {
        composeCard.addEventListener('click', (event) => {
            if (event.target.closest('#composeField')) return;
            openComposeModal();
        });
        composeCard.addEventListener('keydown', (event) => {
            if (event.key === 'Enter' || event.key === ' ') {
                event.preventDefault();
                openComposeModal();
            }
        });
    }

    if (closeBtn) {
        closeBtn.addEventListener('click', () => {
            modal.classList.remove('active');
            editingAnnouncementId = null;
            setComposerMode('create');
        });
    }

    if (cancelBtn) {
        cancelBtn.addEventListener('click', () => {
            modal.classList.remove('active');
            editingAnnouncementId = null;
            setComposerMode('create');
        });
    }

    modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            modal.classList.remove('active');
            editingAnnouncementId = null;
            setComposerMode('create');
        }
    });

    if (form) {
        form.addEventListener('submit', handleAnnouncementSubmit);
    }
}

async function handleAnnouncementSubmit(e) {
    e.preventDefault();

    if (!canCurrentUserPostAnnouncements()) {
        showNotification('Learners are not allowed to post announcements.', 'error');
        return;
    }

    const formData = new FormData(e.target);
    const data = {
        title: formData.get('title'),
        body: formData.get('body'),
        target_role_id: formData.get('target_role_id') || null,
        expires_at: formData.get('expires_at') || null,
        is_pinned: document.getElementById('isPinned').checked ? 1 : 0
    };

    if (!data.title || !data.body) {
        showNotification('Please fill in all required fields', 'error');
        return;
    }

    const submitBtn = document.getElementById('submitAnnouncementBtn');
    const isEditing = !!editingAnnouncementId;
    submitBtn.disabled = true;
    submitBtn.innerHTML = isEditing
        ? '<i class="fas fa-spinner fa-spin"></i> Updating...'
        : '<i class="fas fa-spinner fa-spin"></i> Posting...';

    try {
        const operation = isEditing ? 'updateAnnouncement' : 'createAnnouncement';
        const payload = isEditing
            ? { ...data, announcement_id: editingAnnouncementId }
            : data;

        const response = await axios.post(
            `${window.API_BASE}/announcements/announcements.php?operation=${operation}`,
            payload,
            { headers: { 'Content-Type': 'application/json' } }
        );

        console.log('Create announcement response:', response.data);

        if (response.data && response.data.success) {
            showNotification(isEditing ? 'Announcement updated.' : 'Announcement posted.', 'success');
            document.getElementById('createAnnouncementModal').classList.remove('active');
            document.getElementById('createAnnouncementForm').reset();
            document.getElementById('titleCounter').textContent = '0';
            document.getElementById('contentCounter').textContent = '0';
            editingAnnouncementId = null;
            setComposerMode('create');
            loadAnnouncements();
        } else {
            showNotification(
                response.data?.message || (isEditing ? 'Failed to update announcement' : 'Failed to post announcement'),
                'error'
            );
        }
    } catch (error) {
        console.error('Error posting announcement:', error);
        const errorMessage = error.response?.data?.message || error.message || 'An error occurred while posting the announcement';
        showNotification(errorMessage, 'error');
    } finally {
        submitBtn.disabled = false;
        setComposerMode(isEditing ? 'edit' : 'create');
    }
}

// ===========================
// Load Roles for Dropdown
// ===========================

async function loadRoles() {
    try {
        const response = await axios.get(`${window.API_BASE}/roles/roles.php?operation=getAllRoles`);
        const roles = response.data;

        const select = document.getElementById('targetRole');
        if (select && roles && roles.length > 0) {
            // Clear existing options except first one
            while (select.options.length > 1) {
                select.remove(1);
            }

            roles.forEach(role => {
                const option = document.createElement('option');
                option.value = role.role_id;
                option.textContent = `👥 ${role.role_name}`;
                select.appendChild(option);
            });
        }
    } catch (error) {
        console.error('Error loading roles:', error);
    }
}

// ===========================
// Delete Announcement
// ===========================

async function deleteAnnouncement(announcementId) {
    const announcement = announcementsIndex?.get(String(announcementId));
    if (!announcement || !canCurrentUserManageAnnouncement(announcement)) {
        showNotification('Not authorized to manage this announcement.', 'error');
        return;
    }

    if (!confirm('Are you sure you want to delete this announcement? This action cannot be undone.')) {
        return;
    }
    try {
        const response = await axios.post(
            `${window.API_BASE}/announcements/announcements.php?operation=deleteAnnouncement`,
            { announcement_id: announcementId },
            { headers: { 'Content-Type': 'application/json' } }
        );

        if (response.data.success) {
            showNotification('Announcement deleted.', 'success');
            loadAnnouncements();
        } else {
            showNotification(response.data.message || 'Failed to delete announcement', 'error');
        }
    } catch (error) {
        console.error('Error deleting announcement:', error);
        const apiMessage = error?.response?.data?.message;
        showNotification(apiMessage || 'An error occurred while deleting the announcement', 'error');
    }
}

// Make function globally accessible
window.deleteAnnouncement = deleteAnnouncement;

// ===========================
// Edit Announcement
// ===========================

function setComposerMode(mode) {
    const modalTitle = document.querySelector('#createAnnouncementModal .modal-title');
    const submitBtn = document.getElementById('submitAnnouncementBtn');

    if (modalTitle) {
        modalTitle.innerHTML = mode === 'edit'
            ? '<i class="fas fa-edit"></i> Edit Announcement'
            : '<i class="fas fa-bullhorn"></i> Create Announcement';
    }

    if (submitBtn) {
        submitBtn.innerHTML = mode === 'edit'
            ? '<i class="fas fa-save"></i> Update'
            : '<i class="fas fa-paper-plane"></i> Post';
    }
}

function toDatetimeLocalValue(dateValue) {
    if (!dateValue) return '';

    // Handle common SQL datetime format: YYYY-MM-DD HH:MM:SS
    const raw = String(dateValue).trim();
    const sqlLike = raw.match(/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}(:\d{2})?$/);
    const normalized = sqlLike ? raw.replace(' ', 'T') : raw;

    const d = new Date(normalized);
    if (Number.isNaN(d.getTime())) return '';
    const pad = (n) => String(n).padStart(2, '0');
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

function editAnnouncement(announcementId) {
    const announcement = announcementsIndex.get(String(announcementId));
    if (!announcement) {
        showNotification('Announcement not found. Please refresh and try again.', 'error');
        return;
    }

    if (!canCurrentUserManageAnnouncement(announcement)) {
        showNotification('Not authorized to manage this announcement.', 'error');
        return;
    }

    const modal = document.getElementById('createAnnouncementModal');
    const form = document.getElementById('createAnnouncementForm');
    if (!modal || !form) {
        showNotification('Composer modal is not available on this page.', 'error');
        return;
    }

    editingAnnouncementId = announcementId;
    modal.classList.add('active');
    form.reset();

    setComposerMode('edit');

    const titleInput = document.getElementById('announcementTitle');
    const bodyTextarea = document.getElementById('announcementBody');
    const targetRole = document.getElementById('targetRole');
    const expiresAt = document.getElementById('expiresAt');
    const isPinned = document.getElementById('isPinned');

    if (titleInput) titleInput.value = announcement.title || '';
    if (bodyTextarea) bodyTextarea.value = announcement.body || '';
    if (targetRole) targetRole.value = announcement.target_role_id ? String(announcement.target_role_id) : '';
    if (expiresAt) expiresAt.value = toDatetimeLocalValue(announcement.expires_at);
    if (isPinned) {
        const pinned = announcement.is_pinned;
        isPinned.checked = pinned === true || pinned === 1 || String(pinned) === '1';
    }

    const titleCounter = document.getElementById('titleCounter');
    const contentCounter = document.getElementById('contentCounter');
    if (titleCounter) titleCounter.textContent = String((announcement.title || '').length);
    if (contentCounter) contentCounter.textContent = String((announcement.body || '').length);

    // If any advanced fields are set, show the advanced panel.
    const advancedOptions = document.getElementById('advancedOptions');
    if (advancedOptions && (announcement.expires_at || String(announcement.is_pinned) === '1')) {
        advancedOptions.style.display = 'block';
        document.getElementById('advancedToggle')?.classList.add('active');
    }
}

// Make function globally accessible
window.editAnnouncement = editAnnouncement;

// ===========================
// Utility Functions
// ===========================

function formatTimeAgoFromSeconds(seconds, fallbackDate) {
    if (seconds < 60) return 'Just now';

    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) return `${minutes} min ago`;

    const hours = Math.floor(seconds / 3600);
    if (hours < 24) return `${hours}h ago`;

    const days = Math.floor(seconds / 86400);
    if (days === 1) return 'Yesterday';
    if (days < 7) return `${days} days ago`;

    return fallbackDate ? formatDate(fallbackDate) : 'Earlier';
}

function formatTimeAgo(date) {
    const now = new Date();
    const diffMs = now - date;
    const diffSecs = Math.floor(diffMs / 1000);
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffSecs < 60) return 'Just now';
    if (diffMins < 60) return `${diffMins} min ago`;
    if (diffHours < 24) return `${diffHours}h ago`;
    if (diffDays === 1) return 'Yesterday';
    if (diffDays < 7) return `${diffDays} days ago`;

    return formatDate(date);
}

function formatDate(date) {
    return date.toLocaleString('en-US', {
        timeZone: 'Asia/Manila',
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function showNotification(message, type = 'info') {
    const ensureGovToastStyles = () => {
        if (document.getElementById('govToastStyles')) return;
        const style = document.createElement('style');
        style.id = 'govToastStyles';
        style.textContent = `
            .gov-toast{position:fixed;bottom:80px;right:20px;background:var(--gray-50);border:1px solid var(--gray-200);box-shadow:var(--shadow-md);border-radius:6px;padding:.9rem 1rem;z-index:10001;min-width:320px;max-width:420px;opacity:0;transform:translateX(30px);transition:opacity .25s ease,transform .25s ease}
            .gov-toast.show{opacity:1;transform:translateX(0)}
            .gov-toast__content{display:flex;align-items:flex-start;gap:.75rem}
            .gov-toast__icon{font-size:1.1rem;margin-top:.05rem}
            .gov-toast__text{display:flex;flex-direction:column;gap:.15rem;min-width:0;flex:1}
            .gov-toast__title{font-size:.78rem;font-weight:700;letter-spacing:.04em;text-transform:uppercase;color:var(--gray-700);line-height:1.15}
            .gov-toast__message{font-size:.92rem;color:var(--gray-900);line-height:1.35;word-break:break-word}
            .gov-toast__dismiss{background:transparent;border:none;color:var(--gray-500);font-size:1rem;cursor:pointer;line-height:1}
            .gov-toast--success{border-left:4px solid var(--deped-blue)}
            .gov-toast--success .gov-toast__icon{color:var(--deped-blue)}
            .gov-toast--error{border-left:4px solid var(--color-danger)}
            .gov-toast--error .gov-toast__icon{color:var(--color-danger)}
            .gov-toast--info{border-left:4px solid var(--deped-blue)}
            .gov-toast--info .gov-toast__icon{color:var(--deped-blue)}
        `;
        document.head.appendChild(style);
    };

    ensureGovToastStyles();
    document.querySelectorAll('.gov-toast').forEach((el) => el.remove());

    const normalizedType = type === 'success' || type === 'error' || type === 'info' ? type : 'info';
    const title = normalizedType === 'success' ? 'Completed' : normalizedType === 'error' ? 'Action Required' : 'Notice';
    const iconClass = normalizedType === 'success' ? 'fa-circle-check' : normalizedType === 'error' ? 'fa-triangle-exclamation' : 'fa-circle-info';

    const toast = document.createElement('div');
    toast.className = `gov-toast gov-toast--${normalizedType}`;
    toast.innerHTML = `
        <div class="gov-toast__content">
            <i class="fas ${iconClass} gov-toast__icon"></i>
            <div class="gov-toast__text">
                <div class="gov-toast__title">${title}</div>
                <div class="gov-toast__message">${message}</div>
            </div>
            <button type="button" class="gov-toast__dismiss" aria-label="Dismiss">&times;</button>
        </div>
    `;

    document.body.appendChild(toast);
    requestAnimationFrame(() => toast.classList.add('show'));

    const timeoutMs = normalizedType === 'error' ? 9000 : 4500;
    let timer = setTimeout(dismiss, timeoutMs);

    function dismiss() {
        if (timer) {
            clearTimeout(timer);
            timer = null;
        }
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 250);
    }

    const dismissBtn = toast.querySelector('button[aria-label="Dismiss"]');
    if (dismissBtn) dismissBtn.addEventListener('click', (e) => { e.preventDefault(); e.stopPropagation(); dismiss(); });
    toast.addEventListener('mouseenter', () => { if (timer) { clearTimeout(timer); timer = null; } });
    toast.addEventListener('mouseleave', () => { if (!timer) timer = setTimeout(dismiss, timeoutMs); });
}

// ===========================
// Dashboard Overview Charts
// ===========================

function initializeDashboardOverviewCharts() {
    // This function is called from dashboard-charts.js
    if (typeof window.initializeDashboardCharts === 'function') {
        window.initializeDashboardCharts();
    }
}
