// ===========================
// Dashboard Main JavaScript
// ===========================

// API base (same-origin by default; avoids hard-coded localhost issues)
(function initAppAndApiBase() {
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

    const isApacheServed = String(window.location.pathname || '').includes('/deped_capstone2/');

    if (!window.APP_BASE) {
        window.APP_BASE = appPrefix;
    }

    if (!window.API_BASE) {
        // If running on Live Server (or any non-Apache port), call the PHP API on Apache.
        // Assumes XAMPP Apache serves this project at /deped_capstone2.
        window.API_BASE = isApacheServed
            ? `${appPrefix}/api`
            : `${window.location.protocol}//${window.location.hostname}/deped_capstone2/api`;
    }

    // If the page is opened via file://, API calls will fail.
    if (window.location.protocol === 'file:') {
            let msg = status ? `Error loading dashboard data (HTTP ${status})` : 'Error loading dashboard data';
            if (status === 404 || status === 405) {
                msg += ' — open via http://localhost/deped_capstone2/ (Apache/PHP), not Live Server.';
            }
    }
})();

// Default to compact form density to reduce scrolling on heavy forms.
(function initDensity() {
    const root = document.documentElement;
    if (root && !root.dataset.density) {
        root.dataset.density = 'compact';
    }
})();

// Subtle click-spark effect for empty-space clicks
(function initClickSparks() {
    if (window.__clickSparksInitialized) return;
    window.__clickSparksInitialized = true;

    try {
        if (window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
            return;
        }
    } catch (_) {
        // ignore
    }

    const ensureLayer = () => {
        let layer = document.getElementById('clickSparkLayer');
        if (layer) return layer;
        layer = document.createElement('div');
        layer.id = 'clickSparkLayer';
        document.body.appendChild(layer);
        return layer;
    };

    const isInteractive = (el) => {
        if (!el) return false;
        if (el.closest('a, button, input, select, textarea, label')) return true;
        if (el.closest('[role="button"], [role="link"], [contenteditable="true"]')) return true;
        if (el.closest('.btn, .action-btn, .choices, .choices__inner')) return true;
        return false;
    };

    const isEmptySpaceClick = (target) => {
        // “Empty” means not an interactive/control element.
        return !isInteractive(target);
    };

    const createSpark = (x, y) => {
        const layer = ensureLayer();
        const wrap = document.createElement('div');
        wrap.className = 'click-spark';
        wrap.style.setProperty('--x', `${x}px`);
        wrap.style.setProperty('--y', `${y}px`);

        // Subtle intensity: 6 sparks
        const count = 6;
        for (let i = 0; i < count; i++) {
            const spark = document.createElement('span');
            spark.className = 'spark';
            const angle = (Math.random() * 120 - 60) + (i * (360 / count));
            const dist = 10 + Math.random() * 14;
            spark.style.setProperty('--rot', `${angle}deg`);
            spark.style.setProperty('--dist', `${dist}px`);
            spark.style.animationDelay = `${Math.random() * 45}ms`;
            wrap.appendChild(spark);
        }

        layer.appendChild(wrap);
        // Cleanup after animation
        setTimeout(() => {
            try { wrap.remove(); } catch (_) { /* ignore */ }
        }, 650);
    };

    document.addEventListener('click', (e) => {
        if (!e || e.defaultPrevented) return;
        if (!document.body) return;
        if (!isEmptySpaceClick(e.target)) return;
        // Don’t trigger on text selection
        try {
            const sel = window.getSelection && window.getSelection();
            if (sel && String(sel.toString() || '').trim()) return;
        } catch (_) {
            // ignore
        }
        createSpark(e.clientX, e.clientY);
    }, { passive: true });
})();

// Axios fallback: if CDN fails, provide a minimal wrapper using fetch.
(function ensureAxios() {
    if (window.axios) {
        try {
            // Keep PHP sessions working when API_BASE is absolute.
            window.axios.defaults.withCredentials = true;
        } catch (_) {
            // ignore
        }
        return;
    }

    const buildUrl = (url, config) => {
        const params = config?.params;
        if (!params || typeof params !== 'object') return url;
        const u = new URL(url, window.location.origin);
        Object.entries(params).forEach(([k, v]) => {
            if (v === undefined || v === null) return;
            u.searchParams.set(k, String(v));
        });
        return u.toString();
    };

    const parseResponse = async (res) => {
        const contentType = res.headers.get('content-type') || '';
        const isJson = contentType.includes('application/json');
        const data = isJson ? await res.json().catch(() => null) : await res.text().catch(() => null);
        const response = { status: res.status, data, headers: res.headers };
        if (!res.ok) {
            const err = new Error((data && data.message) ? data.message : `Request failed with status ${res.status}`);
            err.response = response;
            throw err;
        }
        return response;
    };

    const request = async (method, url, data, config) => {
        const finalUrl = buildUrl(url, config);
        const headers = { ...(config?.headers || {}) };

        const isForm = (typeof FormData !== 'undefined') && (data instanceof FormData);
        const body = (method === 'GET' || method === 'HEAD') ? undefined : (isForm ? data : (data === undefined ? undefined : JSON.stringify(data)));
        if (!isForm && body !== undefined && !headers['Content-Type']) {
            headers['Content-Type'] = 'application/json';
        }

        const res = await fetch(finalUrl, {
            method,
            headers,
            body,
            credentials: 'include'
        });
        return parseResponse(res);
    };

    window.axios = {
        get: (url, config) => request('GET', url, undefined, config),
        post: (url, data, config) => request('POST', url, data, config),
        put: (url, data, config) => request('PUT', url, data, config),
        delete: (url, config) => request('DELETE', url, undefined, config),
        defaults: { withCredentials: true },
        create: () => window.axios
    };
})();

function initializeSessionBackGuard() {
    const pathname = String(window.location.pathname || '');
    const isLoginPage = pathname.endsWith('/index.html') || pathname === '/' || pathname.endsWith('/deped_capstone2/');
    const loginTarget = `${window.APP_BASE || ''}/index.html`;

    const markLoggedOut = () => {
        try {
            sessionStorage.setItem('sessionEnded', '1');
        } catch (_) {
            // ignore storage errors
        }
    };

    const isMarkedLoggedOut = () => {
        try {
            return sessionStorage.getItem('sessionEnded') === '1';
        } catch (_) {
            return false;
        }
    };

    const redirectToLogin = () => {
        markLoggedOut();
        window.location.replace(loginTarget);
    };

    const verifySession = async () => {
        try {
            const res = await fetch(`${window.API_BASE}/auth/me.php`, {
                credentials: 'include',
                cache: 'no-store',
                headers: { 'Cache-Control': 'no-store' }
            });
            if (!res.ok) {
                redirectToLogin();
            }
        } catch (_) {
            redirectToLogin();
        }
    };

    if (isLoginPage) {
        return;
    }

    window.addEventListener('pageshow', (event) => {
        if (event.persisted || isMarkedLoggedOut()) {
            verifySession();
        }
    });

    window.addEventListener('popstate', () => {
        if (isMarkedLoggedOut()) {
            verifySession();
        }
    });
}

// Wait for DOM to load
document.addEventListener('DOMContentLoaded', function() {
    // Remove breadcrumb paths globally (Home / ...)
    document.querySelectorAll('.breadcrumb').forEach((el) => {
        try {
            el.remove();
        } catch (_) {
            // ignore
        }
    });

    initializeDashboard();
    initializeSessionBackGuard();
    initNotifications();
    removeDeprecatedMasterfileLinks();
    ensureTopbarCenterNav();
    removeSettingsFromSidebar();
});

function initNotifications() {
    const btn = document.getElementById('notificationBtn');
    if (!btn) return;

    // Wrap to anchor the dropdown like the user menu.
    let wrapper = btn.closest('.notification-menu');
    if (!wrapper) {
        wrapper = document.createElement('div');
        wrapper.className = 'notification-menu';
        const parent = btn.parentNode;
        if (!parent) return;
        parent.insertBefore(wrapper, btn);
        wrapper.appendChild(btn);
    }

    let badge = btn.querySelector('.notification-badge');
    if (!badge) {
        badge = document.createElement('span');
        badge.className = 'notification-badge';
        badge.id = 'notificationCount';
        btn.appendChild(badge);
    }

    let dropdown = wrapper.querySelector('.notification-dropdown');
    if (!dropdown) {
        dropdown = document.createElement('div');
        dropdown.className = 'notification-dropdown';
        dropdown.id = 'notificationDropdown';
        wrapper.appendChild(dropdown);
    }

    const close = () => dropdown.classList.remove('show');
    const open = () => {
        dropdown.classList.add('show');
        refreshNotifications({ render: true });
    };

    btn.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        if (dropdown.classList.contains('show')) {
            close();
        } else {
            open();
        }
    });

    document.addEventListener('click', (e) => {
        if (!wrapper.contains(e.target)) {
            close();
        }
    });

    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') close();
    });

    async function refreshNotifications({ render } = { render: false }) {
        try {
            const res = await axios.get(`${window.API_BASE}/notifications/notifications.php`, {
                params: { operation: 'getNotifications', limit: 12, _: Date.now() }
            });
            if (!res.data?.success) throw new Error(res.data?.message || 'Failed to load notifications');
            const unread = res.data.data?.unread_count ?? 0;
            const items = res.data.data?.notifications ?? [];
            updateBadge(badge, unread);
            if (render) {
                renderDropdown(dropdown, items);
            }
        } catch (err) {
            // If user isn't logged in on this page, keep the bell quiet.
            const status = err?.response?.status;
            if (status !== 401 && status !== 403) {
                console.warn('Notifications refresh failed:', err);
            }
            updateBadge(badge, 0);
            if (render) {
                dropdown.innerHTML = `
                    <div class="notification-dropdown-header">
                        <span class="title">Notifications</span>
                    </div>
                    <div class="notification-item">
                        <p class="notification-title">Unable to load notifications</p>
                        <p class="notification-message">Please try again later.</p>
                    </div>
                `;
            }
        }
    }

    // Initial load + light polling
    refreshNotifications({ render: false });
    window.setInterval(() => refreshNotifications({ render: false }), 30000);

    // Expose for other modules (optional)
    window.refreshNotifications = refreshNotifications;
}

function updateBadge(badgeEl, count) {
    const n = Number(count) || 0;
    badgeEl.textContent = String(n);
    badgeEl.style.display = n > 0 ? 'inline-block' : 'none';
}

function parseMysqlDateTime(value) {
    if (!value || typeof value !== 'string') return null;
    // "YYYY-MM-DD HH:MM:SS" -> ISO-ish
    const iso = value.replace(' ', 'T');
    const d = new Date(iso);
    return isNaN(d.getTime()) ? null : d;
}

function formatNotificationTime(createdAt) {
    const d = parseMysqlDateTime(createdAt);
    if (!d) return '';

    const diffMs = Date.now() - d.getTime();
    if (!Number.isFinite(diffMs) || diffMs < 0) return '';

    const sec = Math.floor(diffMs / 1000);
    if (sec < 60) return 'now';

    const min = Math.floor(sec / 60);
    if (min < 60) return `${min}m`;

    const hr = Math.floor(min / 60);
    if (hr < 24) return `${hr}h`;

    const day = Math.floor(hr / 24);
    if (day < 7) return `${day}d`;

    const week = Math.floor(day / 7);
    if (week < 5) return `${week}w`;

    const month = Math.floor(day / 30);
    if (month < 12) return `${month}mo`;

    const year = Math.floor(day / 365);
    return `${year}y`;
}

function getNotificationLink(n) {
    const ref = String(n?.reference_table || '').toLowerCase();
    const type = String(n?.notification_type || '').toLowerCase();
    const title = String(n?.title || '').toLowerCase();
    const message = String(n?.message || '').toLowerCase();
    const app = window.APP_BASE || '';

    // Announcements are shown inline (popup) from the notification dropdown.
    if (ref === 'announcements') return null;

    if (ref === 'enrollments') return `${app}/pages/enrollments.html`;
    if (ref === 'risk_assessment' || ref === 'risk_assessments') return `${app}/pages/risk-assessment.html`;
    if (ref === 'interventions') return `${app}/pages/interventions.html`;
    if (ref === 'dashboard_alerts') return null;

    // Fallback for older/missing reference_table rows related to early-risk alerts.
    const looksRiskRelated = type.includes('risk')
        || title.includes('at-risk learner')
        || message.includes('flagged as')
        || message.includes('at risk');
    if (looksRiskRelated) return `${app}/pages/risk-assessment.html`;

    return null;
}

function focusAnnouncementInFeedNow(announcementId) {
    const id = Number(announcementId || 0);
    if (!Number.isFinite(id) || id <= 0) return false;

    const feed = document.getElementById('announcementsFeed');
    if (!feed) return false;

    // `id` is numeric; avoid relying on `CSS.escape()`.
    const card = feed.querySelector(`.announcement-card[data-id="${String(id)}"]`);
    if (!card) return false;

    // Expand long content if collapsed.
    try {
        const content = card.querySelector('.announcement-content[data-expanded]');
        const btn = card.querySelector('button.announcement-readmore');
        if (content && btn) {
            content.dataset.expanded = 'true';
            btn.textContent = 'Read less';
        }
    } catch (_) {
        // ignore
    }

    // Scroll so the card is as centered as possible (accounting for fixed header).
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

    const prevOutline = card.style.outline;
    const prevShadow = card.style.boxShadow;
    card.style.outline = '3px solid rgba(59, 130, 246, 0.8)';
    card.style.boxShadow = '0 0 0 6px rgba(59, 130, 246, 0.15)';

    window.setTimeout(() => {
        card.style.outline = prevOutline;
        card.style.boxShadow = prevShadow;
    }, 2200);

    return true;
}

function requestFocusAnnouncement(announcementId) {
    const id = Number(announcementId || 0);
    if (!Number.isFinite(id) || id <= 0) return;

    // Persist across navigation so the dashboard feed can focus after it loads.
    try {
        sessionStorage.setItem('focusAnnouncementId', String(id));
    } catch (_) {
        // ignore
    }
}

function requestFocusRiskAssessment(riskAssessmentId) {
    const id = Number(riskAssessmentId || 0);
    if (!Number.isFinite(id) || id <= 0) return;

    try {
        sessionStorage.setItem('focusRiskAssessmentId', String(id));
    } catch (_) {
        // ignore
    }
}

function requestFocusRiskAssessmentContext(notification) {
    if (!notification || typeof notification !== 'object') return;

    const payload = {
        notification_id: Number(notification.notification_id || 0) || null,
        reference_table: String(notification.reference_table || ''),
        reference_id: Number(notification.reference_id || 0) || null,
        notification_type: String(notification.notification_type || ''),
        title: String(notification.title || ''),
        message: String(notification.message || ''),
        created_at: String(notification.created_at || '')
    };

    try {
        sessionStorage.setItem('focusRiskAssessmentContext', JSON.stringify(payload));
    } catch (_) {
        // ignore
    }
}

function getNotificationActorName(n) {
    const currentId = Number(window.CURRENT_USER_ID || 0);
    const actorId = Number(n?.actor_user_id || 0);
    if (currentId > 0 && actorId > 0 && currentId === actorId) {
        return 'You';
    }

    const first = String(n?.actor_first_name || '').trim();
    const last = String(n?.actor_last_name || '').trim();
    const full = `${first} ${last}`.trim();
    if (full) return full;

    const username = String(n?.actor_username || '').trim();
    return username || '';
}

function renderDropdown(dropdownEl, items) {
    const list = Array.isArray(items) ? items : [];

    const header = `
        <div class="notification-dropdown-header">
            <span class="title">Notifications</span>
        </div>
    `;

    if (list.length === 0) {
        dropdownEl.innerHTML = header + `
            <div class="notification-item">
                <p class="notification-title">No notifications</p>
                <p class="notification-message">You're all caught up.</p>
            </div>
        `;
        return;
    }

    dropdownEl.innerHTML = header;

    list.forEach((n) => {
        const id = Number(n.notification_id || 0);
        const isRead = Number(n.is_read || 0) === 1;

        const ref = String(n?.reference_table || '').toLowerCase();
        const refId = Number(n?.reference_id || 0);
        const actor = getNotificationActorName(n);

        const rawTitle = String(n.title || 'Notification');
        const rawMessage = String(n.message || '');

        let displayTitle = rawTitle;
        let displayMessage = rawMessage;

        if (ref === 'announcements' && actor) {
            displayTitle = `${actor} posted an announcement`;
            displayMessage = rawTitle || rawMessage;
        }

        const title = truncateText(displayTitle, 48);
        const message = truncateText(displayMessage, 90);
        const when = formatNotificationTime(n.created_at);
        const href = getNotificationLink(n);

        const a = document.createElement('a');
        a.className = `notification-item${isRead ? '' : ' unread'}`;
        a.href = href || '#';
        a.dataset.notificationId = String(id);
        a.innerHTML = `
            <p class="notification-title">${escapeHtml(title)}</p>
            <p class="notification-message">${escapeHtml(message)}</p>
            ${when ? `<div class="notification-meta">${escapeHtml(when)}</div>` : ''}
        `;

        a.addEventListener('click', async (e) => {
            e.preventDefault();
            if (!id) return;

            try {
                await axios.post(`${window.API_BASE}/notifications/notifications.php?operation=markRead`, {
                    notification_id: id
                });
            } catch (_) {
                // ignore
            }

            // Refresh badge quickly
            try {
                if (typeof window.refreshNotifications === 'function') {
                    await window.refreshNotifications({ render: false });
                }
            } catch (_) {
                // ignore
            }

            if (ref === 'announcements') {
                if (Number.isFinite(refId) && refId > 0) {
                    requestFocusAnnouncement(refId);

                    // Try focusing immediately if we're already on a dashboard page.
                    const focusedNow = focusAnnouncementInFeedNow(refId);
                    if (!focusedNow) {
                        // Not on a dashboard page (or feed not loaded yet): go to the role dashboard,
                        // then the dashboard announcements script will focus it once rendered.
                        const target = getDashboardHrefForRole(window.CURRENT_ROLE_NAME, window.CURRENT_ROLE_ID);
                        window.location.href = target;
                    }
                }

                dropdownEl.classList.remove('show');
                a.classList.remove('unread');
                return;
            }

            if (href && href !== '#') {
                window.location.href = href;
            } else {
                // Marked read; close dropdown.
                dropdownEl.classList.remove('show');
                a.classList.remove('unread');
            }
        });

        dropdownEl.appendChild(a);
    });
}

function truncateText(value, maxLen) {
    const s = String(value ?? '').replace(/\s+/g, ' ').trim();
    const n = Number(maxLen) || 0;
    if (n <= 0 || s.length <= n) return s;
    if (n === 1) return s.slice(0, 1);
    return s.slice(0, n - 1) + '…';
}

function escapeHtml(str) {
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

function removeDeprecatedMasterfileLinks() {
    // Previously used to prune deprecated masterfile links.
    // Keep as a no-op for now to avoid hiding valid pages.
    return;
}

function ensureTopbarCenterNav() {
    const topbar = document.querySelector('.topbar');
    if (!topbar) return;
    if (topbar.querySelector('.topbar-center-nav')) return;

    const app = getAppPathPrefix();

    // Keep the Home button pointing at the current role dashboard.
    // Default to admin dashboard if we're not on a role dashboard page.
    const currentPath = String(window.location.pathname || '');
    let homeRoute = 'dashboard/admin_dashboard.html';
    if (/\/dashboard\/teacher_dashboard\.html$/.test(currentPath)) {
        homeRoute = 'dashboard/teacher_dashboard.html';
    } else if (/\/dashboard\/learner_dashboard\.html$/.test(currentPath)) {
        homeRoute = 'dashboard/learner_dashboard.html';
    }
    const homeHref = `${app}/${homeRoute}`.replace(/\/\/+/, '/');

    const container = document.createElement('div');
    container.className = 'topbar-center-nav';
    container.innerHTML = `
        <a class="topbar-nav-link" data-topbar-nav="home" href="${homeHref}" aria-label="Home" title="Home">
            <i class="fas fa-home" aria-hidden="true"></i>
            <span>Home</span>
        </a>

        <div class="topbar-nav-group">
            <button type="button" class="topbar-nav-toggle" data-topbar-nav="analytics" data-topbar-menu-toggle="analytics" aria-haspopup="true" aria-expanded="false" aria-label="Analytics" title="Analytics">
                <i class="fas fa-chart-line" aria-hidden="true"></i>
                <span>Analytics</span>
                <i class="fas fa-caret-down" aria-hidden="true"></i>
            </button>
            <div class="topbar-nav-menu" data-topbar-menu="analytics" role="menu">
                <a href="${app}/pages/analytics/dashboard-overview.html" role="menuitem">
                    <i class="fas fa-tachometer-alt" aria-hidden="true"></i>
                    <span>Dashboard Overview</span>
                </a>
                <a href="${app}/pages/analytics/enrollment-analytics.html" role="menuitem">
                    <i class="fas fa-user-graduate" aria-hidden="true"></i>
                    <span>Enrollment Trends</span>
                </a>
                <a href="${app}/pages/analytics/performance-analytics.html" role="menuitem">
                    <i class="fas fa-chart-bar" aria-hidden="true"></i>
                    <span>Performance Analytics</span>
                </a>
                <a href="${app}/pages/analytics/grade-distribution.html" role="menuitem">
                    <i class="fas fa-chart-pie" aria-hidden="true"></i>
                    <span>Grade Distribution</span>
                </a>
            </div>
        </div>
    `;

    topbar.appendChild(container);
    wireTopbarCenterNav(container);
    setTopbarCenterNavActive(container);
}

function setTopbarCenterNavActive(container) {
    const pathname = String(window.location.pathname || '').replace(/\/+$/, '');

    const home = container.querySelector('[data-topbar-nav="home"]');
    const analytics = container.querySelector('[data-topbar-nav="analytics"]');

    [home, analytics].forEach(el => {
        if (!el) return;
        el.classList.remove('active');
        el.removeAttribute('aria-current');
    });

    // Highlight based on current page
    if (/\/pages\/analytics\//.test(pathname)) {
        analytics?.classList.add('active');
        analytics?.setAttribute('aria-current', 'page');
        return;
    }

    if (/\/dashboard\/(admin_dashboard|teacher_dashboard|learner_dashboard)\.html$/.test(pathname)) {
        home?.classList.add('active');
        home?.setAttribute('aria-current', 'page');
    }
}

function removeSettingsFromSidebar() {
    const sidebar = document.getElementById('sidebar');
    if (!sidebar) return;

    const anchors = Array.from(sidebar.querySelectorAll('a[href]'));
    anchors.forEach((a) => {
        const href = String(a.getAttribute('href') || '');
        const text = String(a.textContent || '');
        if (!/settings\.html(\?|#|$)/i.test(href)) return;
        if (!/\bsettings\b/i.test(text)) return;

        const li = a.closest('li');
        if (li) {
            li.remove();
            return;
        }
        a.remove();
    });
}

function wireTopbarCenterNav(container) {
    const toggles = Array.from(container.querySelectorAll('[data-topbar-menu-toggle]'));
    const menus = Array.from(container.querySelectorAll('[data-topbar-menu]'));

    const closeAll = () => {
        menus.forEach(m => m.classList.remove('show'));
        toggles.forEach(t => t.setAttribute('aria-expanded', 'false'));
    };

    toggles.forEach(toggle => {
        toggle.addEventListener('click', (e) => {
            e.preventDefault();
            e.stopPropagation();

            const key = toggle.getAttribute('data-topbar-menu-toggle');
            const menu = container.querySelector(`[data-topbar-menu="${key}"]`);
            if (!menu) return;

            const isOpen = menu.classList.contains('show');
            closeAll();
            if (!isOpen) {
                menu.classList.add('show');
                toggle.setAttribute('aria-expanded', 'true');
            }
        });
    });

    document.addEventListener('click', (e) => {
        if (!container.contains(e.target)) closeAll();
    });

    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') closeAll();
    });
}

// ===========================
// UI Scale (Small/Medium/Large)
// ===========================

const UI_SCALE_STORAGE_KEY = 'deped_ui_scale';

function normalizeUiScale(value) {
    const v = String(value || '').toLowerCase().trim();
    return v === 'small' || v === 'medium' || v === 'large' ? v : null;
}

function applyUiScale(scale) {
    const normalized = normalizeUiScale(scale) || 'small';
    document.documentElement.setAttribute('data-ui-scale', normalized);
    try {
        localStorage.setItem(UI_SCALE_STORAGE_KEY, normalized);
    } catch {
        // ignore storage errors
    }
}

function initializeUiScaleSetting() {
    let stored = null;
    try {
        stored = localStorage.getItem(UI_SCALE_STORAGE_KEY);
    } catch {
        stored = null;
    }

    applyUiScale(stored);

    const select = document.getElementById('uiScaleSelect');
    if (!select) return;

    const current = document.documentElement.getAttribute('data-ui-scale') || 'small';
    select.value = current;
    select.addEventListener('change', () => {
        applyUiScale(select.value);
    });
}

// ===========================
// Theme (Light/Dark)
// ===========================

const THEME_STORAGE_KEY = 'deped_theme';

function normalizeTheme(value) {
    const v = String(value || '').toLowerCase().trim();
    return v === 'dark' || v === 'light' ? v : null;
}

function applyTheme(theme, { persist = true } = {}) {
    const normalized = normalizeTheme(theme) || 'light';
    document.documentElement.setAttribute('data-theme', normalized);

    if (persist) {
        try {
            localStorage.setItem(THEME_STORAGE_KEY, normalized);
        } catch {
            // ignore storage errors
        }
    }
}

function initializeThemeSetting() {
    let stored = null;
    try {
        stored = localStorage.getItem(THEME_STORAGE_KEY);
    } catch {
        stored = null;
    }

    const initial = normalizeTheme(stored)
        || (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');

    applyTheme(initial, { persist: !!normalizeTheme(stored) });

    const btn = document.getElementById('darkModeBtn');
    const status = document.getElementById('themeStatus');
    if (!btn) return;

    const syncButton = () => {
        const current = document.documentElement.getAttribute('data-theme') || 'light';
        const isDark = current === 'dark';
        btn.setAttribute('aria-pressed', isDark ? 'true' : 'false');
        const label = btn.querySelector('span');
        if (label) label.textContent = isDark ? 'Disable Dark Mode' : 'Enable Dark Mode';
        const icon = btn.querySelector('i');
        if (icon) icon.className = isDark ? 'fas fa-sun' : 'fas fa-moon';
        if (status) status.textContent = `Current: ${isDark ? 'Dark' : 'Light'}`;
    };

    syncButton();
    btn.addEventListener('click', () => {
        const current = document.documentElement.getAttribute('data-theme') || 'light';
        const next = current === 'dark' ? 'light' : 'dark';
        applyTheme(next, { persist: true });
        syncButton();
    });
}

// Initialize Dashboard
function initializeDashboard() {
    // Prevent role-restricted sidebar links from flashing before session loads.
    setSidebarRoleLoading(true);

    // Apply UI scale as early as possible
    initializeUiScaleSetting();

    // Apply theme as early as possible
    initializeThemeSetting();

    // Add a text-logo at the top of the sidebar (global)
    ensureSidebarBranding();

    // Initialize navigation
    initializeNavigation();

    // Initialize user menu
    initializeUserMenu();

    // Load user session (also enforces dashboard role); once we know the role,
    // render role-appropriate sidebar nav.
    loadUserSession();

    // Load dashboard data
    loadDashboardData();

    // Initialize sidebar toggle
    initializeSidebarToggle();

    // Initialize scroll animations
    initializeScrollAnimations();

    // Enhance selects + date/time pickers (custom popups for Safari/Chrome)
    initializeEnhancedControls().catch((error) => {
        console.warn('Enhanced controls unavailable:', error);
    });
}

// ===========================
// Enhanced Controls (Choices.js + Flatpickr)
// ===========================

function loadCssOnce(id, href) {
    if (document.getElementById(id)) return;
    const link = document.createElement('link');
    link.id = id;
    link.rel = 'stylesheet';
    link.href = href;
    document.head.appendChild(link);
}

function loadScriptOnce(id, src) {
    return new Promise((resolve, reject) => {
        const existing = document.getElementById(id);
        if (existing) {
            resolve();
            return;
        }

        const script = document.createElement('script');
        script.id = id;
        script.src = src;
        script.async = true;
        script.onload = () => resolve();
        script.onerror = () => reject(new Error(`Failed to load ${src}`));
        document.head.appendChild(script);
    });
}

async function initializeEnhancedControls() {
    // Prefer local vendored assets (offline-safe), fallback to CDN if needed
    const app = getAppPathPrefix();

    const local = {
        CHOICES_CSS: `${app}/assets/vendor/choices/choices.min.css`,
        CHOICES_JS: `${app}/assets/vendor/choices/choices.min.js`,
        FLATPICKR_CSS: `${app}/assets/vendor/flatpickr/flatpickr.min.css`,
        FLATPICKR_JS: `${app}/assets/vendor/flatpickr/flatpickr.min.js`
    };

    const cdn = {
        CHOICES_CSS: 'https://cdn.jsdelivr.net/npm/choices.js/public/assets/styles/choices.min.css',
        CHOICES_JS: 'https://cdn.jsdelivr.net/npm/choices.js/public/assets/scripts/choices.min.js',
        FLATPICKR_CSS: 'https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css',
        FLATPICKR_JS: 'https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.js'
    };

    // CSS: load local first; if it 404s, browser just won't apply it (that's fine)
    loadCssOnce('choices-css', local.CHOICES_CSS);
    loadCssOnce('flatpickr-css', local.FLATPICKR_CSS);

    // JS: try local; if it fails, try CDN
    try {
        await Promise.all([
            loadScriptOnce('choices-js', local.CHOICES_JS),
            loadScriptOnce('flatpickr-js', local.FLATPICKR_JS)
        ]);
    } catch {
        await Promise.all([
            loadScriptOnce('choices-js-cdn', cdn.CHOICES_JS),
            loadScriptOnce('flatpickr-js-cdn', cdn.FLATPICKR_JS)
        ]);
        // If CDN is used, ensure CSS is also available
        loadCssOnce('choices-css-cdn', cdn.CHOICES_CSS);
        loadCssOnce('flatpickr-css-cdn', cdn.FLATPICKR_CSS);
    }

    // Vendor CSS is injected after dashboard.css, so we must override it after load
    ensureEnhancedPopupThemeOverrides();

    enhanceSelectDropdowns();
    enhanceDateTimePickers();

    // Allow other scripts (that add dynamic fields later) to re-run safely
    window.enhanceControls = () => {
        enhanceSelectDropdowns();
        enhanceDateTimePickers();
    };

    // Auto-enhance controls added later (e.g., dynamic modals/forms)
    if (!window.__enhanceControlsObserver && document.body) {
        let timer = null;
        window.__enhanceControlsObserver = new MutationObserver(() => {
            if (timer) window.clearTimeout(timer);
            timer = window.setTimeout(() => {
                try {
                    window.enhanceControls?.();
                } catch {
                    // ignore
                }
            }, 50);
        });

        window.__enhanceControlsObserver.observe(document.body, {
            childList: true,
            subtree: true
        });
    }
}

function ensureEnhancedPopupThemeOverrides() {
        if (document.getElementById('enhancedPopupThemeOverrides')) return;

        const style = document.createElement('style');
        style.id = 'enhancedPopupThemeOverrides';
        style.textContent = `
/* Theme overrides for Choices.js + Flatpickr (must load after vendor CSS) */

/* Choices.js */
.choices.is-open{
    z-index: 10050 !important;
}
.choices__inner{
    background: var(--surface-0) !important;
    border-color: var(--gray-300) !important;
    color: var(--gray-900) !important;
    min-height: var(--control-min-height) !important;
    font-size: var(--control-font-size) !important;
}
.choices__list--dropdown,.choices__list[aria-expanded]{
    background: var(--surface-0) !important;
    border-color: var(--gray-300) !important;
    box-shadow: var(--shadow-md) !important;
    z-index: 10050 !important;
}
.choices__list--dropdown .choices__item--selectable,
.choices__list[aria-expanded] .choices__item--selectable{
    color: var(--gray-900) !important;
}
.choices__list--dropdown .choices__item--selectable.is-highlighted,
.choices__list[aria-expanded] .choices__item--selectable.is-highlighted{
    background: var(--gray-100) !important;
}
.choices__input{
    background: transparent !important;
    color: var(--gray-900) !important;
}
.choices__list--multiple .choices__item{
    background: var(--gray-100) !important;
    border: 1px solid var(--gray-200) !important;
    color: var(--gray-900) !important;
}
.choices__list--multiple .choices__item .choices__button{
    filter: none !important;
    opacity: 0.85 !important;
}
.choices[data-type*="select-one"]::after{
    border-color: var(--gray-500) transparent transparent transparent !important;
}

/* Flatpickr */
.flatpickr-calendar{
    background: var(--surface-0) !important;
    border-color: var(--gray-300) !important;
    box-shadow: var(--shadow-lg) !important;
    z-index: 10050 !important;
}
.flatpickr-months,.flatpickr-weekdays,.flatpickr-days{
    background: var(--surface-0) !important;
}
.flatpickr-current-month,
.flatpickr-monthDropdown-months,
.flatpickr-weekday,
.flatpickr-day,
.flatpickr-time input,
.flatpickr-time .flatpickr-am-pm{
    color: var(--gray-900) !important;
}
.flatpickr-monthDropdown-months,
.flatpickr-monthDropdown-months .flatpickr-monthDropdown-month{
    background: var(--surface-0) !important;
}
.flatpickr-monthDropdown-months .flatpickr-monthDropdown-month:hover,
.flatpickr-monthDropdown-months .flatpickr-monthDropdown-month:focus{
    background: var(--gray-100) !important;
}
.flatpickr-day{
    border-radius: 0.5rem !important;
}
.flatpickr-day:hover{
    background: var(--gray-100) !important;
    border-color: var(--gray-100) !important;
}
.flatpickr-day.today{
    border-color: var(--deped-blue) !important;
}
.flatpickr-day.selected,.flatpickr-day.startRange,.flatpickr-day.endRange{
    background: var(--deped-blue) !important;
    border-color: var(--deped-blue) !important;
    color: #fff !important;
}
.flatpickr-day.flatpickr-disabled,
.flatpickr-day.prevMonthDay,
.flatpickr-day.nextMonthDay{
    color: var(--gray-500) !important;
}
.flatpickr-time{
    border-top: 1px solid var(--gray-200) !important;
}
.flatpickr-time input,
.flatpickr-time .flatpickr-am-pm{
    background: transparent !important;
}
.flatpickr-months .flatpickr-prev-month,
.flatpickr-months .flatpickr-next-month{
    color: var(--gray-900) !important;
    fill: var(--gray-900) !important;
}
.flatpickr-months .flatpickr-prev-month svg path,
.flatpickr-months .flatpickr-next-month svg path{
    fill: var(--gray-900) !important;
}
`;
        document.head.appendChild(style);
}

function enhanceSelectDropdowns() {
    const ChoicesCtor = window.Choices;
    if (!ChoicesCtor) return;

    const selects = Array.from(document.querySelectorAll('select'));

    selects.forEach((selectEl) => {
        if (!selectEl || selectEl.dataset.native === 'true') return;
        if (selectEl.dataset.enhanced === 'choices') return;

        // Avoid enhancing hidden/disabled placeholders used only as templates
        if (selectEl.closest('[aria-hidden="true"]')) return;

        const optionCount = selectEl.options?.length || 0;
        const searchEnabled = optionCount > 8;

        const instance = new ChoicesCtor(selectEl, {
            allowHTML: false,
            shouldSort: false,
            searchEnabled,
            searchResultLimit: 50,
            itemSelectText: '',
            removeItemButton: !!selectEl.multiple,
            placeholder: true,
            placeholderValue: selectEl.getAttribute('placeholder') || ''
        });

        selectEl.dataset.enhanced = 'choices';
        selectEl._choicesInstance = instance;

        // Keep in sync for dynamically populated selects (e.g., roles loaded via axios)
        let refreshTimer = null;
        const observer = new MutationObserver(() => {
            if (refreshTimer) window.clearTimeout(refreshTimer);
            refreshTimer = window.setTimeout(() => {
                try {
                    instance.refresh();
                } catch {
                    // ignore refresh errors
                }
            }, 50);
        });

        observer.observe(selectEl, { childList: true, subtree: true });
        selectEl._choicesObserver = observer;
    });
}

function enhanceDateTimePickers() {
    const flatpickr = window.flatpickr;
    if (!flatpickr) return;

    const inputs = Array.from(document.querySelectorAll('input[type="date"], input[type="datetime-local"], input[type="time"]'));

    inputs.forEach((inputEl) => {
        if (!inputEl || inputEl.dataset.native === 'true') return;
        if (inputEl.dataset.enhanced === 'flatpickr') return;

        const originalType = inputEl.getAttribute('type');
        inputEl.dataset.originalType = originalType;

        // Force consistent custom popup across Safari/Chrome
        inputEl.type = 'text';

        const base = {
            allowInput: true,
            disableMobile: true
        };

        let config = base;
        if (originalType === 'datetime-local') {
            config = {
                ...base,
                enableTime: true,
                time_24hr: true,
                dateFormat: 'Y-m-d\\TH:i'
            };
        } else if (originalType === 'time') {
            config = {
                ...base,
                enableTime: true,
                noCalendar: true,
                time_24hr: true,
                dateFormat: 'H:i'
            };
        } else {
            // date
            config = {
                ...base,
                dateFormat: 'Y-m-d'
            };
        }

        flatpickr(inputEl, config);
        inputEl.dataset.enhanced = 'flatpickr';
    });
}

function ensureSidebarBranding() {
    const sidebar = document.getElementById('sidebar');
    if (!sidebar) return;

    if (sidebar.querySelector('.sidebar-branding')) return;

    const app = getAppPathPrefix();
    const branding = document.createElement('div');
    branding.className = 'sidebar-branding';
    branding.innerHTML = `<img src="${app}/assets/img/logo/pngegg.png" alt="System Logo">`;

    sidebar.insertBefore(branding, sidebar.firstChild);
}

function setSidebarRoleLoading(isLoading) {
    const sidebar = document.getElementById('sidebar');
    if (!sidebar) return;
    sidebar.classList.toggle('is-role-loading', !!isLoading);
}

// ===========================
// Canonical Sidebar Navigation
// ===========================

function getAppPathPrefix() {
    // Prefer initAppAndApiBase-derived base (works for /deped_capstone2 and Live Server).
    // Important: empty string is a valid app base when the site is served from the domain root.
    const hasBase = (typeof window.APP_BASE === 'string');
    if (hasBase) {
        const base = String(window.APP_BASE);
        return base === '/' ? '' : base;
    }

    // Fallback: first path segment.
    const parts = String(window.location.pathname || '/').split('/').filter(Boolean);
    return parts.length ? `/${parts[0]}` : '';
}

function normalizeRoleName(roleName) {
    return String(roleName || '').trim().toLowerCase();
}

function getDashboardHrefForRole(roleName, roleId) {
    const app = getAppPathPrefix();
    const rid = Number(roleId);
    const normalized = normalizeRoleName(roleName);

    if (Number.isFinite(rid)) {
        if (rid === 10) return `${app}/dashboard/learner_dashboard.html`;
        if (rid === 9) return `${app}/dashboard/teacher_dashboard.html`;
        if (rid === 8) return `${app}/dashboard/admin_dashboard.html`;
    }

    if (normalized.includes('learner') || normalized.includes('student')) {
        return `${app}/dashboard/learner_dashboard.html`;
    }
    if (normalized.includes('teacher')) {
        return `${app}/dashboard/teacher_dashboard.html`;
    }
    if (normalized.includes('admin')) {
        return `${app}/dashboard/admin_dashboard.html`;
    }

    return `${app}/dashboard/admin_dashboard.html`;
}

function getCurrentDashboardKind() {
    const path = String(window.location.pathname || '').toLowerCase();
    if (path.endsWith('/dashboard/admin_dashboard.html') || path.endsWith('admin_dashboard.html')) return 'admin';
    if (path.endsWith('/dashboard/teacher_dashboard.html') || path.endsWith('teacher_dashboard.html')) return 'teacher';
    if (path.endsWith('/dashboard/learner_dashboard.html') || path.endsWith('learner_dashboard.html')) return 'learner';
    return null;
}

function enforceDashboardForRole(user) {
    const current = getCurrentDashboardKind();
    if (!current) return;

    const target = getDashboardHrefForRole(user?.role_name, user?.role_id);
    const targetKind = String(target).toLowerCase().includes('learner_dashboard')
        ? 'learner'
        : String(target).toLowerCase().includes('teacher_dashboard')
            ? 'teacher'
            : 'admin';

    if (current !== targetKind) {
        window.location.href = target;
    }
}

function enforcePageAccessForRole(roleKey) {
    const rk = String(roleKey || '').toLowerCase();
    if (!rk) return;

    // Admin can access everything.
    if (rk === 'admin') return;

    const path = String(window.location.pathname || '').toLowerCase().replace(/\/+$/, '');
    const targetDashboard = getDashboardHrefForRole(window.CURRENT_ROLE_NAME, window.CURRENT_ROLE_ID);

    // Guard a few known admin-only pages (regardless of role).
    const isAdminOnlyPage = /\/pages\/masterfiles\/(users|roles)\.html$/.test(path);
    if (isAdminOnlyPage && rk !== 'admin') {
        window.location.replace(targetDashboard);
        return;
    }

    // Learners should not access admin/teacher operational modules.
    if (rk === 'learners') {
        const isLearnerAllowedPage = (
            /\/dashboard\/learner_dashboard\.html$/.test(path)
            || /\/pages\/(profile|profile-security|settings)\.html$/.test(path)
            || /\/pages\/(announcements|notifications)\.html$/.test(path)
        );

        // Any other /pages/* route is treated as not-for-learners.
        if (/\/pages\//.test(path) && !isLearnerAllowedPage) {
            window.location.replace(targetDashboard);
        }
    }

    // Teachers should only access teacher-allowed modules (UI gating; backend remains authoritative).
    if (rk === 'teacher') {
        const isTeacherAllowedPage = (
            /\/dashboard\/teacher_dashboard\.html$/.test(path)
            || /\/pages\/(profile|profile-security|settings)\.html$/.test(path)
            || /\/pages\/(announcements|notifications)\.html$/.test(path)
            || /\/pages\/(class-offerings|class-records|grades|attendance|risk-assessment)\.html$/.test(path)
            || /\/pages\/masterfiles\/learners\.html$/.test(path)
        );

        if (/\/pages\//.test(path) && !isTeacherAllowedPage) {
            window.location.replace(targetDashboard);
        }
    }

    // Registrar: allow monitoring/reporting modules without granting full admin access.
    if (rk === 'registrar') {
        const isRegistrarAllowedPage = (
            /\/dashboard\/(admin|teacher)_dashboard\.html$/.test(path)
            || /\/pages\/(profile|profile-security|settings)\.html$/.test(path)
            || /\/pages\/(announcements|notifications)\.html$/.test(path)
            || /\/pages\/enrollments\.html$/.test(path)
            || /\/pages\/family-members\.html$/.test(path)
            || /\/pages\/emergency-contacts\.html$/.test(path)
            || /\/pages\/masterfiles\/learners\.html$/.test(path)
            || /\/pages\/masterfiles\/employees\.html$/.test(path)
            || /\/pages\/analytics\/.+\.html$/.test(path)
            || /\/pages\/report-cards\.html$/.test(path)
        );

        if (/\/pages\//.test(path) && !isRegistrarAllowedPage) {
            window.location.replace(targetDashboard);
        }
    }
}

function ensureCanonicalSidebarNav({ roleKey } = {}) {
    const sidebar = document.getElementById('sidebar');
    if (!sidebar) return;

    const nav = sidebar.querySelector('.sidebar-nav');
    if (!nav) return;

    const list = nav.querySelector('.nav-list');
    if (!list) return;

    // Avoid re-rendering if already generated
    if (list.dataset.canonicalNav === '1') return;

    const app = getAppPathPrefix();
    const rk = String(roleKey || '').toLowerCase();

    const isAdmin = rk === 'admin';
    const isTeacher = rk === 'teacher';
    const isLearner = rk === 'learners';
    const isRegistrar = rk === 'registrar';

    const analyticsItems = (isAdmin || isRegistrar)
        ? [
            { href: `${app}/pages/analytics/dashboard-overview.html`, icon: 'fa-tachometer-alt', label: 'Dashboard Overview' },
            { href: `${app}/pages/analytics/enrollment-analytics.html`, icon: 'fa-user-graduate', label: 'Enrollment Trends' },
            { href: `${app}/pages/analytics/performance-analytics.html`, icon: 'fa-chart-bar', label: 'Performance Analytics' },
            { href: `${app}/pages/analytics/grade-distribution.html`, icon: 'fa-chart-pie', label: 'Grade Distribution' }
        ]
        : [];

    // Masterfiles should match the original schema in api/database/thepelaezdraftrev.sql.
    // Learners should not see masterfiles; teachers should only see limited learner listing/view.
    const masterfilesItems = (isLearner)
        ? []
        : (isTeacher)
            ? [
                { href: `${app}/pages/masterfiles/learners.html`, icon: 'fa-user-graduate', label: 'Learners', key: 'learner_registration' }
            ]
            : (isRegistrar)
                ? [
                    { href: `${app}/pages/masterfiles/learners.html`, icon: 'fa-user-graduate', label: 'Learners', key: 'learner_registration' },
                    { href: `${app}/pages/masterfiles/employees.html`, icon: 'fa-briefcase', label: 'Employees', key: 'employees' }
                ]
                : [
        ...(isAdmin ? [{ href: `${app}/pages/masterfiles/users.html`, icon: 'fa-users', label: 'Users', key: 'users' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/masterfiles/roles.html`, icon: 'fa-user-tag', label: 'Roles', key: 'roles' }] : []),
        { href: `${app}/pages/masterfiles/curricula.html`, icon: 'fa-book', label: 'Curricula', key: 'curricula' },
        { href: `${app}/pages/masterfiles/curriculum-components.html`, icon: 'fa-sitemap', label: 'Curriculum Components', key: 'curriculum_components' },
        { href: `${app}/pages/masterfiles/citizenships.html`, icon: 'fa-flag', label: 'Citizenships', key: 'citizenships' },
        ...(isAdmin ? [{ href: `${app}/pages/masterfiles/school-settings.html`, icon: 'fa-cog', label: 'School Settings', key: 'school_settings' }] : []),
        { href: `${app}/pages/masterfiles/learners.html`, icon: 'fa-user-graduate', label: 'Learners', key: 'learner_registration' },
        ...(isAdmin ? [{ href: `${app}/pages/masterfiles/employees.html`, icon: 'fa-briefcase', label: 'Employees', key: 'employees' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/masterfiles/positions.html`, icon: 'fa-sitemap', label: 'Positions', key: 'positions' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/masterfiles/education-levels.html`, icon: 'fa-graduation-cap', label: 'Education Levels', key: 'education_levels' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/masterfiles/grade-levels.html`, icon: 'fa-layer-group', label: 'Grade Levels', key: 'grade_levels' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/masterfiles/school-years.html`, icon: 'fa-calendar', label: 'School Years', key: 'school_years' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/masterfiles/sections.html`, icon: 'fa-school', label: 'Sections', key: 'sections' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/masterfiles/subjects.html`, icon: 'fa-book', label: 'Subjects', key: 'subjects' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/masterfiles/document-types.html`, icon: 'fa-file', label: 'Document Types', key: 'document_types' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/masterfiles/enrollment-requirements.html`, icon: 'fa-clipboard-check', label: 'Enrollment Requirements', key: 'enrollment_requirements' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/masterfiles/enrollment-types.html`, icon: 'fa-list', label: 'Enrollment Types', key: 'enrollment_types' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/masterfiles/learning-modalities.html`, icon: 'fa-chalkboard', label: 'Learning Modalities', key: 'learning_modalities' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/masterfiles/risk-levels.html`, icon: 'fa-exclamation-circle', label: 'Risk Levels', key: 'risk_levels' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/masterfiles/honor-levels.html`, icon: 'fa-award', label: 'Honor Levels', key: 'honor_levels' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/masterfiles/grade-remarks.html`, icon: 'fa-comment-dots', label: 'Grade Remarks', key: 'grade_remarks' }] : [])
    ];

    const transactionItems = [
        // Admin-only transactions
        ...(isAdmin || isRegistrar ? [{ href: `${app}/pages/enrollments.html`, icon: 'fa-user-plus', label: 'Enrollments', key: 'enrollments' }] : []),

        // Teacher core academic role (also visible to admin)
        ...(isAdmin || isTeacher ? [{ href: `${app}/pages/class-offerings.html`, icon: 'fa-clipboard-list', label: 'Class Offerings', key: 'class_offerings' }] : []),
        ...(isAdmin || isTeacher ? [{ href: `${app}/pages/class-records.html`, icon: 'fa-book', label: 'Class Records', key: 'class_records' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/grades.html`, icon: 'fa-chart-bar', label: 'Grades', key: 'grades' }] : []),
        ...(isAdmin || isTeacher ? [{ href: `${app}/pages/attendance.html`, icon: 'fa-user-check', label: 'Learner Attendance', key: 'attendance' }] : []),

        // Admin-only / extended modules (hide from teacher)
        ...(isAdmin ? [{ href: `${app}/pages/grading-periods.html`, icon: 'fa-calendar-alt', label: 'Grading Periods', key: 'grading_periods' }] : []),
        ...(isAdmin || isRegistrar ? [{ href: `${app}/pages/report-cards.html`, icon: 'fa-file-alt', label: 'Report Cards', key: 'report_cards' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/final-grades.html`, icon: 'fa-certificate', label: 'Final Grades', key: 'final_grades' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/general-averages.html`, icon: 'fa-percentage', label: 'General Averages', key: 'general_averages' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/section-rankings.html`, icon: 'fa-ranking-star', label: 'Section Rankings', key: 'section_rankings' }] : []),
        ...(isAdmin || isTeacher ? [{ href: `${app}/pages/risk-assessment.html`, icon: 'fa-exclamation-triangle', label: 'Risk Assessment', key: 'risk_assessments' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/risk-indicators.html`, icon: 'fa-heartbeat', label: 'Risk Indicators', key: 'risk_indicators' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/interventions.html`, icon: 'fa-hands-helping', label: 'Interventions', key: 'interventions' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/family-members.html`, icon: 'fa-home', label: 'Family Members', key: 'family_members' }] : []),
        ...(isAdmin ? [{ href: `${app}/pages/emergency-contacts.html`, icon: 'fa-phone-alt', label: 'Emergency Contacts', key: 'emergency_contacts' }] : []),
        ...(isAdmin || isLearner ? [{ href: `${app}/pages/announcements.html`, icon: 'fa-bullhorn', label: 'Announcements', key: 'announcements' }] : [])
    ];

    const renderItems = (items, dataAttr) => items.map((it) => {
        const data = dataAttr ? ` ${dataAttr}="${it.key}"` : '';
        return `<li><a href="${it.href}"${data}><i class="fas ${it.icon}"></i> ${it.label}</a></li>`;
    }).join('');

    const homeHref = (() => {
        try {
            return getDashboardHrefForRole(window.CURRENT_ROLE_NAME, window.CURRENT_ROLE_ID);
        } catch (_) {
            return `${app}/dashboard/admin_dashboard.html`;
        }
    })();

    const hasAnalytics = analyticsItems.length > 0;
    const hasMasterfiles = masterfilesItems.length > 0;
    const hasTransactions = transactionItems.length > 0;

    list.innerHTML = `
        <li class="nav-item">
            <a href="${homeHref}" class="nav-link">
                <i class="fas fa-home"></i>
                <span>Home</span>
            </a>
        </li>

        ${hasAnalytics ? `
        <li class="nav-item has-submenu">
            <a href="#" class="nav-link" id="analyticsToggle">
                <i class="fas fa-chart-line"></i>
                <span>Analytics</span>
                <i class="fas fa-chevron-down submenu-icon"></i>
            </a>
            <ul class="submenu" id="analyticsSubmenu">
                ${renderItems(analyticsItems, null)}
            </ul>
        </li>
        ` : ''}

        ${hasMasterfiles ? `
        <li class="nav-item has-submenu">
            <a href="#" class="nav-link" id="masterfilesToggle">
                <i class="fas fa-folder"></i>
                <span>Masterfiles</span>
                <i class="fas fa-chevron-down submenu-icon"></i>
            </a>
            <ul class="submenu" id="masterfilesSubmenu">
                ${renderItems(masterfilesItems, 'data-masterfile-link')}
            </ul>
        </li>
        ` : ''}

        ${hasTransactions ? `
        <li class="nav-item has-submenu">
            <a href="#" class="nav-link" id="transactionsToggle">
                <i class="fas fa-exchange-alt"></i>
                <span>Transactions</span>
                <i class="fas fa-chevron-down submenu-icon"></i>
            </a>
            <ul class="submenu" id="transactionsSubmenu">
                ${renderItems(transactionItems, 'data-transaction-link')}
            </ul>
        </li>
        ` : ''}
    `;

    list.dataset.canonicalNav = '1';

    // Re-bind submenu toggle handlers because we replaced the sidebar DOM.
    initializeNavigation();

    // Remove any hardcoded Settings entries that some pages ship with.
    removeSettingsFromSidebar();

    // Role-based navigation is now ready; show the sidebar.
    setSidebarRoleLoading(false);
}

// ===========================
// Navigation Functions
// ===========================

function initializeNavigation() {
    // Analytics submenu toggle
    const analyticsToggle = document.getElementById('analyticsToggle');
    const analyticsSubmenu = document.getElementById('analyticsSubmenu');

    if (analyticsToggle) {
        analyticsToggle.addEventListener('click', function(e) {
            e.preventDefault();
            const parentItem = this.closest('.nav-item');
            parentItem.classList.toggle('open');
            analyticsSubmenu.classList.toggle('open');
        });
    }

    // Masterfiles submenu toggle
    const masterfilesToggle = document.getElementById('masterfilesToggle');
    const masterfilesSubmenu = document.getElementById('masterfilesSubmenu');

    if (masterfilesToggle) {
        masterfilesToggle.addEventListener('click', function(e) {
            e.preventDefault();
            const parentItem = this.closest('.nav-item');
            parentItem.classList.toggle('open');
            masterfilesSubmenu.classList.toggle('open');
        });
    }

    // Transactions submenu toggle
    const transactionsToggle = document.getElementById('transactionsToggle');
    const transactionsSubmenu = document.getElementById('transactionsSubmenu');

    if (transactionsToggle) {
        transactionsToggle.addEventListener('click', function(e) {
            e.preventDefault();
            const parentItem = this.closest('.nav-item');
            parentItem.classList.toggle('open');
            transactionsSubmenu.classList.toggle('open');
        });
    }

    // Set active link based on current page
    setActiveNavLink();
}

function setActiveNavLink() {
    const currentPath = window.location.pathname;
    const navLinks = document.querySelectorAll('.nav-link, .submenu a');

    navLinks.forEach(link => {
        if (link.getAttribute('href') && currentPath.includes(link.getAttribute('href'))) {
            link.classList.add('active');
            // If submenu item, open parent
            if (link.closest('.submenu')) {
                const parentItem = link.closest('.has-submenu');
                if (parentItem) {
                    parentItem.classList.add('open');
                    const submenu = parentItem.querySelector('.submenu');
                    if (submenu) submenu.classList.add('open');
                }
            }
        }
    });
}

// ===========================
// User Menu Functions
// ===========================

function initializeUserMenu() {
    const userMenuBtn = document.getElementById('userMenuBtn');
    const userDropdown = document.getElementById('userDropdown');

    if (userMenuBtn && userDropdown) {
        userMenuBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            userDropdown.classList.toggle('show');
        });

        // Close dropdown when clicking outside
        document.addEventListener('click', function(e) {
            if (!userMenuBtn.contains(e.target) && !userDropdown.contains(e.target)) {
                userDropdown.classList.remove('show');
            }
        });
    }

    document.querySelectorAll('a.logout').forEach(link => {
        link.addEventListener('click', async (e) => {
            e.preventDefault();
            try {
                await axios.post(`${window.API_BASE}/auth/logout.php`);
            } catch (error) {
                console.error('Logout error', error);
            } finally {
                try {
                    sessionStorage.setItem('sessionEnded', '1');
                } catch (_) {
                    // ignore storage errors
                }
                window.location.replace(`${window.APP_BASE}/index.html`);
            }
        });
    });
}

async function loadUserSession() {
    try {
        const response = await axios.get(`${window.API_BASE}/auth/me.php`);
        if (!response.data?.success) {
            return;
        }

        const user = response.data.data || {};

        // Expose session info for UI helpers.
        window.CURRENT_USER_ID = Number(user.user_id || 0);
        window.CURRENT_ROLE_ID = Number(user.role_id || 0);
        window.CURRENT_ROLE_NAME = String(user.role_name || '');

        // Ensure the correct dashboard for the current role.
        enforceDashboardForRole(user);

        const nameEl = document.querySelector('.user-name');
        const roleEl = document.querySelector('.user-role');
        const fullName = user.full_name || `${user.first_name || ''} ${user.last_name || ''}`.trim();
        if (nameEl) nameEl.textContent = fullName || user.username || 'User';
        if (roleEl) roleEl.textContent = user.role_name || 'Role';

        // Render role-appropriate sidebar navigation after we know the role.
        // Clear canonical flag so it re-renders once.
        try {
            const list = document.querySelector('#sidebar .sidebar-nav .nav-list');
            if (list) {
                delete list.dataset.canonicalNav;
            }
        } catch (_) {
            // ignore
        }

        const serverRoleKey = String(user?.role_key || '').trim().toLowerCase();

        let roleKey = serverRoleKey;
        if (!roleKey) {
            roleKey = normalizeRoleName(user?.role_name).includes('admin')
                ? 'admin'
                : normalizeRoleName(user?.role_name).includes('teacher')
                    ? 'teacher'
                    : (Number(user?.role_id) === 10 || normalizeRoleName(user?.role_name).includes('learner') || normalizeRoleName(user?.role_name).includes('student'))
                        ? 'learners'
                        : (Number(user?.role_id) === 9 ? 'teacher' : (Number(user?.role_id) === 8 ? 'admin' : ''));
        }

        if (!roleKey) {
            const rn = normalizeRoleName(user?.role_name);
            if (rn && rn.includes('registrar')) {
                roleKey = 'registrar';
            }
        }

        // Enforce page access rules (e.g., prevent learners from opening admin modules by URL).
        enforcePageAccessForRole(roleKey);

        ensureCanonicalSidebarNav({ roleKey });
    } catch (error) {
        if (error?.response?.status === 401) {
            window.location.href = `${window.APP_BASE}/index.html`;
            return;
        }
        console.warn('Session check failed', error);
    }
}

// ===========================
// Sidebar Toggle Functions
// ===========================

function initializeSidebarToggle() {
    const menuToggle = document.getElementById('menuToggle');
    const sidebar = document.getElementById('sidebar');
    let overlay = document.getElementById('sidebarOverlay');

    // Ensure overlay exists on all pages (e.g., masterfiles)
    if (!overlay) {
        overlay = document.createElement('div');
        overlay.id = 'sidebarOverlay';
        overlay.className = 'sidebar-overlay';
        document.body.appendChild(overlay);
    }

    if (!menuToggle || !sidebar) return;

    const openSidebar = () => {
        sidebar.classList.add('show');
        document.body.classList.add('sidebar-open');
    };

    const closeSidebar = () => {
        sidebar.classList.remove('show');
        document.body.classList.remove('sidebar-open');
    };

    const toggleSidebar = () => {
        if (sidebar.classList.contains('show')) {
            closeSidebar();
        } else {
            openSidebar();
        }
    };

    menuToggle.addEventListener('click', toggleSidebar);

    if (overlay) {
        overlay.addEventListener('click', closeSidebar);
    }

    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape') {
            closeSidebar();
        }
    });
}

// ===========================
// Dashboard Data Loading
// ===========================

async function loadDashboardData() {
    const dashboardKind = getCurrentDashboardKind();
    if (dashboardKind !== 'admin' && dashboardKind !== 'teacher') {
        // Metrics endpoint is for admin/teacher dashboard analytics.
        // Skip on learner dashboards and generic pages that also include dashboard.js.
        return;
    }

    try {
        const metrics = await fetchMetrics();

        // Cache and broadcast metrics so charts can reuse them
        window.dashboardMetrics = metrics;
        document.dispatchEvent(new CustomEvent('dashboard:metrics', { detail: metrics }));

        // Load summary statistics
        loadSummaryStats(metrics.stats);

        // Load alerts (still using sample data unless an alerts API is added)
        await loadAlerts();

        // Charts are initialized in dashboard-charts.js; they listen for dashboard:metrics
    } catch (error) {
        console.error('Error loading dashboard data:', error);

        if (window.location.protocol === 'file:') {
            showNotification('Dashboard cannot load via file://. Open using http://localhost/...', 'error');
            return;
        }

        const status = error?.response?.status;
        const msg = status ? `Error loading dashboard data (HTTP ${status})` : 'Error loading dashboard data';
        showNotification(msg, 'error');
    }
}

async function fetchMetrics() {
    const response = await axios.get(`${window.API_BASE}/dashboard/metrics.php`);
    if (!response.data?.success) {
        throw new Error(response.data?.message || 'Failed to load metrics');
    }
    return response.data.data;
}

function loadSummaryStats(stats) {
    if (!stats) return;
    updateElement('totalStudents', stats.totalStudents ?? 0);
    updateElement('totalTeachers', stats.totalTeachers ?? 0);
    updateElement('totalClasses', stats.totalClasses ?? 0);
    updateElement('schoolYearLabel', stats.schoolYear ?? '');
}

async function loadAlerts() {
    try {
        // Fetch real alerts from API
        const response = await axios.get(`${window.API_BASE}/dashboard/alerts.php`);

        if (response.data?.success && response.data?.data) {
            const alerts = response.data.data;
            displayAlerts(alerts);
        } else {
            // Fallback to computed alerts if API returns no data
            const computedAlerts = generateAlerts();
            displayAlerts(computedAlerts);
        }
    } catch (error) {
        console.warn('Error loading alerts from API, generating computed alerts:', error);
        // Generate alerts based on current metrics
        const computedAlerts = generateAlerts();
        displayAlerts(computedAlerts);
    }
}

function generateAlerts() {
    const alerts = [];
    const metrics = window.dashboardMetrics;

    if (!metrics) return [];

    // Alert 1: At-risk students
    const atRiskCount = metrics.performance?.data?.[0] ?? 0;
    if (atRiskCount > 0) {
        alerts.push({
            id: 1,
            message: `${atRiskCount} students identified as at-risk`,
            severity: atRiskCount > 10 ? 'high' : 'medium',
            time: 'Just now'
        });
    }

    // Alert 2: Enrollment stats
    const totalStudents = metrics.stats?.totalStudents ?? 0;
    if (totalStudents > 0) {
        alerts.push({
            id: 2,
            message: `Total enrolled students: ${totalStudents}`,
            severity: 'info',
            time: 'Current S.Y.'
        });
    }

    // Alert 3: Classes
    const totalClasses = metrics.stats?.totalClasses ?? 0;
    if (totalClasses > 0) {
        alerts.push({
            id: 3,
            message: `${totalClasses} active classes this school year`,
            severity: 'info',
            time: 'Current S.Y.'
        });
    }

    // Alert 4: Teachers
    const totalTeachers = metrics.stats?.totalTeachers ?? 0;
    if (totalTeachers > 0) {
        alerts.push({
            id: 4,
            message: `${totalTeachers} instructors assigned`,
            severity: 'info',
            time: 'Current S.Y.'
        });
    }

    return alerts.length > 0 ? alerts : [
        {
            id: 1,
            message: 'Dashboard system initialized and running',
            severity: 'info',
            time: 'Now'
        }
    ];
}

function displayAlerts(alerts) {
    const alertsList = document.getElementById('alertsList');
    if (!alertsList) return;

    alertsList.innerHTML = '';

    if (!alerts || alerts.length === 0) {
        const noAlertsItem = document.createElement('div');
        noAlertsItem.className = 'alert-item info';
        noAlertsItem.innerHTML = `
            <div class="alert-message">
                <i class="fas fa-check-circle"></i>
                All systems operating normally
            </div>
        `;
        alertsList.appendChild(noAlertsItem);
        return;
    }

    alerts.forEach(alert => {
        const alertItem = document.createElement('div');
        alertItem.className = `alert-item ${alert.severity || 'info'}`;
        const iconClass = alert.icon || 'fa-info-circle';
        const timeStr = alert.time ? `<span class="alert-time">${alert.time}</span>` : '';

        alertItem.innerHTML = `
            <div class="alert-icon">
                <i class="fas ${iconClass}"></i>
            </div>
            <div class="alert-content">
                <div class="alert-message">${alert.message}</div>
                ${timeStr}
            </div>
        `;
        alertsList.appendChild(alertItem);
    });
}

// ===========================
// Utility Functions
// ===========================

function updateElement(id, value) {
    const element = document.getElementById(id);
    if (element) {
        // Animate number changes
        if (typeof value === 'number') {
            animateValue(element, 0, value, 1000);
        } else {
            element.textContent = value;
        }
    }
}

function animateValue(element, start, end, duration) {
    const range = end - start;
    const increment = range / (duration / 16);
    let current = start;

    const timer = setInterval(() => {
        current += increment;
        if ((increment > 0 && current >= end) || (increment < 0 && current <= end)) {
            current = end;
            clearInterval(timer);
        }
        element.textContent = Math.round(current);
    }, 16);
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
// Scroll Animation Functions
// ===========================

function initializeScrollAnimations() {
    const animatedElements = document.querySelectorAll('[data-animate]');
    if (!animatedElements.length) return;

    const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
    if (prefersReducedMotion.matches) {
        animatedElements.forEach((element) => element.classList.add('is-visible'));
        return;
    }

    const observer = new IntersectionObserver((entries, obs) => {
        entries.forEach((entry) => {
            if (entry.isIntersecting) {
                const element = entry.target;
                if (element.dataset.animateDelay) {
                    element.style.transitionDelay = element.dataset.animateDelay;
                }
                element.classList.add('is-visible');
                obs.unobserve(element);
            }
        });
    }, {
        threshold: 0.2,
        rootMargin: '0px 0px -5% 0px'
    });

    animatedElements.forEach((element) => observer.observe(element));
}

// ===========================
// Export functions for use in other files
// ===========================
window.dashboardUtils = {
    updateElement,
    showNotification,
    loadDashboardData
};
