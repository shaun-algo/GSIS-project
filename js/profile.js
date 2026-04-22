const API_BASE_URL = window.API_BASE || ((!!window.location.port && !['80', '443'].includes(String(window.location.port)))
    ? `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`
    : '/deped_capstone2/api');

// Keep session cookies when applicable.
axios.defaults.withCredentials = true;
let currentUser = null;
let editingAnnouncementId = null;
let profileAnnouncements = [];

function isLearnerRole(roleName) {
    const normalized = String(roleName || '').trim().toLowerCase();
    return normalized === 'learner' || normalized === 'student';
}

function canCurrentUserPostAnnouncements() {
    if (!currentUser) return false;
    return !isLearnerRole(currentUser.role_name);
}

function applyAnnouncementPostingPermissions() {
    if (!currentUser) return;
    if (canCurrentUserPostAnnouncements()) return;

    const composeCard = document.getElementById('composeCard');
    const modal = document.getElementById('createAnnouncementModal');
    const createBtn = document.getElementById('createAnnouncementBtn');
    if (composeCard) composeCard.style.display = 'none';
    if (createBtn) createBtn.style.display = 'none';
    if (modal) modal.classList.remove('active');

    const composerSection = document.querySelector('.announcement-composer-top');
    const postsSection = document.querySelector('.profile-posts');
    if (composerSection) composerSection.style.display = 'none';
    if (postsSection) postsSection.style.display = 'none';
}

document.addEventListener('DOMContentLoaded', () => {
    if (window.location.protocol === 'file:') {
        showNotification('Open this page via http://localhost/deped_capstone2/ so login/session works.', 'error');
        return;
    }

    initializeProfileTabs();
    initializeComposerFeatures();
    initializeComposeHandlers();
    initializeReadMoreToggle();
    loadCurrentUser();
    loadRoles();
});

function initializeProfileTabs() {
    const tabs = document.querySelectorAll('.profile-tab');
    tabs.forEach((tab) => {
        tab.addEventListener('click', (event) => {
            const link = tab.dataset.link;
            if (link) {
                event.preventDefault();
                window.location.href = link;
                return;
            }

            const target = tab.dataset.tab;
            if (!target) return;
            tabs.forEach((btn) => {
                btn.classList.toggle('active', btn === tab);
                btn.setAttribute('aria-selected', btn === tab ? 'true' : 'false');
            });
            document.querySelectorAll('.profile-tab-panel').forEach((panel) => {
                panel.classList.toggle('active', panel.id === `profile${capitalize(target)}`);
            });
        });
    });
}

function initializeComposerFeatures() {
    const titleInput = document.getElementById('announcementTitle');
    const bodyTextarea = document.getElementById('announcementBody');
    const titleCounter = document.getElementById('titleCounter');
    const contentCounter = document.getElementById('contentCounter');

    if (titleInput && titleCounter) {
        titleInput.addEventListener('input', (e) => {
            const length = e.target.value.length;
            titleCounter.textContent = length;
            titleCounter.classList.remove('warning', 'danger');
            if (length > 180) titleCounter.classList.add('warning');
            if (length > 195) titleCounter.classList.add('danger');
        });
    }

    if (bodyTextarea && contentCounter) {
        bodyTextarea.addEventListener('input', (e) => {
            contentCounter.textContent = e.target.value.length;
        });
    }

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

function initializeComposeHandlers() {
    const composeCard = document.getElementById('composeCard');
    const composeField = document.getElementById('composeField');
    const closeBtn = document.getElementById('closeAnnouncementModal');
    const cancelBtn = document.getElementById('cancelAnnouncementBtn');
    const modal = document.getElementById('createAnnouncementModal');
    const form = document.getElementById('createAnnouncementForm');

    if (composeCard) {
        composeCard.addEventListener('click', openComposeModal);
        composeCard.addEventListener('keydown', (event) => {
            if (event.key === 'Enter' || event.key === ' ') {
                event.preventDefault();
                openComposeModal();
            }
        });
    }

    if (composeField) {
        composeField.addEventListener('click', (event) => {
            event.stopPropagation();
            openComposeModal();
        });
    }

    if (closeBtn) {
        closeBtn.addEventListener('click', () => modal.classList.remove('active'));
    }

    if (cancelBtn) {
        cancelBtn.addEventListener('click', () => modal.classList.remove('active'));
    }

    if (modal) {
        modal.addEventListener('click', (event) => {
            if (event.target === modal) {
                modal.classList.remove('active');
            }
        });
    }

    if (form) {
        form.addEventListener('submit', handleAnnouncementSubmit);
    }
}

function initializeReadMoreToggle() {
    const feed = document.getElementById('profileAnnouncementsFeed');
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
    if (!modal || !form) return;

    editingAnnouncementId = null;
    modal.classList.add('active');
    form.reset();

    const titleCounter = document.getElementById('titleCounter');
    const contentCounter = document.getElementById('contentCounter');
    if (titleCounter) titleCounter.textContent = '0';
    if (contentCounter) contentCounter.textContent = '0';
}

async function loadCurrentUser() {
    try {
        const response = await axios.get(`${API_BASE_URL}/auth/me.php`);
        if (!response.data?.success) return;
        currentUser = response.data.data;

        const fullName = currentUser.full_name || `${currentUser.first_name || ''} ${currentUser.last_name || ''}`.trim() || currentUser.username;
        const roleName = currentUser.role_name || 'User';

        setText('profileName', fullName);
        setText('profileRole', roleName);
        setText('detailFullName', fullName);
        setText('detailRole', roleName);
        setText('detailUsername', currentUser.username || '-');
        setText('detailUserId', String(currentUser.user_id || '-'));
        setText('composerUserName', fullName);

        const initials = getInitials(fullName || currentUser.username || 'U');
        const avatar = document.getElementById('profileAvatar');
        if (avatar) avatar.textContent = initials;

        applyAnnouncementPostingPermissions();

        loadUserAnnouncements();
    } catch (error) {
        console.error('Error loading user:', error);
    }
}

async function loadRoles() {
    try {
        const response = await axios.get(`${API_BASE_URL}/roles/roles.php?operation=getAllRoles`);
        const roles = response.data;
        const select = document.getElementById('targetRole');
        if (!select || !roles || roles.length === 0) return;

        while (select.options.length > 1) {
            select.remove(1);
        }

        roles.forEach((role) => {
            const option = document.createElement('option');
            option.value = role.role_id;
            option.textContent = `👥 ${role.role_name}`;
            select.appendChild(option);
        });
    } catch (error) {
        console.error('Error loading roles:', error);
    }
}

async function loadUserAnnouncements() {
    const feed = document.getElementById('profileAnnouncementsFeed');
    if (!feed) return;
    if (!currentUser) return;

    if (!canCurrentUserPostAnnouncements()) {
        // Learners do not have a posting surface.
        feed.innerHTML = '';
        return;
    }

    try {
        const response = await axios.get(`${API_BASE_URL}/announcements/announcements.php?operation=getAllAnnouncements`);
        const announcements = Array.isArray(response.data) ? response.data : [];
        const userPosts = announcements.filter((item) => String(item.posted_by) === String(currentUser.user_id));
        profileAnnouncements = userPosts;

        setText('postCount', `${userPosts.length} announcements`);

        if (userPosts.length === 0) {
            feed.innerHTML = `
                <div class="empty-state">
                    <i class="fas fa-bullhorn"></i>
                    <h3>No posts yet</h3>
                    <p>Your announcements will appear here.</p>
                </div>
            `;
            return;
        }

        feed.innerHTML = userPosts.map((announcement) => createAnnouncementCard(announcement)).join('');
    } catch (error) {
        console.error('Error loading announcements:', error);
        feed.innerHTML = `
            <div class="empty-state">
                <i class="fas fa-circle-exclamation"></i>
                <h3>Unable to load posts</h3>
                <p>Please try again later.</p>
            </div>
        `;
    }
}

function createAnnouncementCard(announcement) {
    const publishedDate = new Date(announcement.published_at);
    const isExpired = announcement.expires_at && new Date(announcement.expires_at) < new Date();
    const isPinned = announcement.is_pinned == 1;
    const canManage = canCurrentUserManageAnnouncement(announcement);

    const timeLabel = announcement.seconds_ago !== undefined
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
                    <span class="announcement-time">${timeLabel}</span>
                    ${isExpired ? '<span class="expired-badge"><i class="fas fa-times-circle"></i> Expired</span>' : ''}
                </div>
            </div>
            <div class="announcement-body">
                <h3 class="announcement-title">${escapeHtml(announcement.title)}</h3>
                <div class="announcement-content" ${isLongContent ? 'data-expanded="false"' : ''}>
                    ${contentHtml}
                </div>
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

    // Prefer backend-provided ownership flag when available.
    if (String(announcement?.is_owner) === '1') return true;

    // Fallback for older payloads: compare IDs.
    return String(currentUser.user_id) === String(announcement?.posted_by);
}

async function handleAnnouncementSubmit(event) {
    event.preventDefault();

    if (!canCurrentUserPostAnnouncements()) {
        showNotification('Learners are not allowed to post announcements.', 'error');
        return;
    }

    const form = event.target;
    const formData = new FormData(form);
    const payload = {
        title: formData.get('title'),
        body: formData.get('body'),
        target_role_id: formData.get('target_role_id') || null,
        expires_at: formData.get('expires_at') || null,
        is_pinned: document.getElementById('isPinned').checked ? 1 : 0
    };

    if (!payload.title || !payload.body) {
        showNotification('Please fill in all required fields.', 'error');
        return;
    }

    const submitBtn = document.getElementById('submitAnnouncementBtn');
    submitBtn.disabled = true;
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Posting...';

    try {
        const isEditing = Boolean(editingAnnouncementId);
        const url = isEditing
            ? `${API_BASE_URL}/announcements/announcements.php?operation=updateAnnouncement`
            : `${API_BASE_URL}/announcements/announcements.php?operation=createAnnouncement`;
        const data = isEditing ? { ...payload, announcement_id: editingAnnouncementId } : payload;

        const response = await axios.post(url, data, { headers: { 'Content-Type': 'application/json' } });

        if (response.data?.success) {
            showNotification(isEditing ? 'Announcement updated.' : 'Announcement posted.', 'success');
            document.getElementById('createAnnouncementModal').classList.remove('active');
            form.reset();
            editingAnnouncementId = null;
            loadUserAnnouncements();
        } else {
            showNotification(response.data?.message || 'Failed to post announcement', 'error');
        }
    } catch (error) {
        const message = error.response?.data?.message || error.message || 'An error occurred while posting the announcement.';
        showNotification(message, 'error');
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-paper-plane"></i> Post';
    }
}

async function pinAnnouncement(announcementId, isPinned) {
    const announcement = profileAnnouncements.find((item) => String(item.announcement_id) === String(announcementId));
    if (!announcement || !canCurrentUserManageAnnouncement(announcement)) {
        showNotification('Not authorized to manage this announcement.', 'error');
        return;
    }
    try {
        const response = await axios.post(
            `${API_BASE_URL}/announcements/announcements.php?operation=pinAnnouncement`,
            { announcement_id: announcementId, is_pinned: isPinned },
            { headers: { 'Content-Type': 'application/json' } }
        );

        if (response.data?.success) {
            showNotification(response.data.message, 'success');
            loadUserAnnouncements();
        } else {
            showNotification(response.data?.message || 'Failed to update pin status', 'error');
        }
    } catch (error) {
        showNotification('An error occurred while updating pin status.', 'error');
    }
}

window.pinAnnouncement = pinAnnouncement;

async function deleteAnnouncement(announcementId) {
    const announcement = profileAnnouncements.find((item) => String(item.announcement_id) === String(announcementId));
    if (!announcement || !canCurrentUserManageAnnouncement(announcement)) {
        showNotification('Not authorized to manage this announcement.', 'error');
        return;
    }
    if (!confirm('Are you sure you want to delete this announcement? This action cannot be undone.')) {
        return;
    }

    try {
        const response = await axios.post(
            `${API_BASE_URL}/announcements/announcements.php?operation=deleteAnnouncement`,
            { announcement_id: announcementId },
            { headers: { 'Content-Type': 'application/json' } }
        );

        if (response.data?.success) {
            showNotification('Announcement deleted.', 'success');
            loadUserAnnouncements();
        } else {
            showNotification(response.data?.message || 'Failed to delete announcement', 'error');
        }
    } catch (error) {
        showNotification('An error occurred while deleting the announcement.', 'error');
    }
}

window.deleteAnnouncement = deleteAnnouncement;

async function editAnnouncement(announcementId) {
    const announcement = profileAnnouncements.find((item) => String(item.announcement_id) === String(announcementId));
    if (!announcement) {
        showNotification('Announcement not found.', 'error');
        return;
    }

    if (!canCurrentUserManageAnnouncement(announcement)) {
        showNotification('Not authorized to manage this announcement.', 'error');
        return;
    }

    const modal = document.getElementById('createAnnouncementModal');
    if (!modal) return;

    editingAnnouncementId = announcementId;
    modal.classList.add('active');

    setInputValue('announcementTitle', announcement.title);
    setInputValue('announcementBody', announcement.body);
    setInputValue('targetRole', announcement.target_role_id || '');
    setInputValue('expiresAt', formatDateTimeLocal(announcement.expires_at));
    const isPinned = document.getElementById('isPinned');
    if (isPinned) isPinned.checked = String(announcement.is_pinned) === '1';

    const titleCounter = document.getElementById('titleCounter');
    const contentCounter = document.getElementById('contentCounter');
    if (titleCounter) titleCounter.textContent = (announcement.title || '').length;
    if (contentCounter) contentCounter.textContent = (announcement.body || '').length;

    const advancedOptions = document.getElementById('advancedOptions');
    const advancedToggle = document.getElementById('advancedToggle');
    if (advancedOptions && advancedToggle) {
        advancedOptions.style.display = 'block';
        advancedToggle.classList.add('active');
    }
}

window.editAnnouncement = editAnnouncement;

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

function getInitials(name) {
    return name
        .split(' ')
        .filter(Boolean)
        .slice(0, 2)
        .map((part) => part[0].toUpperCase())
        .join('');
}

function setText(id, value) {
    const el = document.getElementById(id);
    if (el) el.textContent = value;
}

function setInputValue(id, value) {
    const el = document.getElementById(id);
    if (el) el.value = value ?? '';
}

function formatDateTimeLocal(value) {
    if (!value) return '';
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return '';

    const pad = (num) => String(num).padStart(2, '0');
    return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function capitalize(text) {
    if (!text) return '';
    return text.charAt(0).toUpperCase() + text.slice(1);
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

    const dismiss = toast.querySelector('.gov-toast__dismiss');
    if (dismiss) {
        dismiss.addEventListener('click', () => toast.remove());
    }

    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 250);
    }, 4000);
}
