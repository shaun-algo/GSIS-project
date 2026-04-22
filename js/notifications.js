// Notifications page controller

(function () {
    const apiUrl = () => `${window.API_BASE}/notifications/notifications.php`;

    const els = {
        tbody: () => document.getElementById('dataTableBody'),
        search: () => document.getElementById('searchInput'),
        refresh: () => document.getElementById('refreshBtn'),
        markAll: () => document.getElementById('markAllReadBtn'),
        count: () => document.getElementById('countInfo')
    };

    let all = [];
    let filtered = [];

    function escapeHtml(str) {
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }

    function parseMysqlDateTime(value) {
        if (!value || typeof value !== 'string') return null;
        const iso = value.replace(' ', 'T');
        const d = new Date(iso);
        return isNaN(d.getTime()) ? null : d;
    }

    function formatWhen(createdAt) {
        const d = parseMysqlDateTime(createdAt);
        return d ? d.toLocaleString() : '';
    }

    function getNotificationLink(n) {
        const ref = String(n?.reference_table || '').toLowerCase();
        const app = window.APP_BASE || '';
        if (ref === 'announcements') return `${app}/pages/announcements.html`;
        if (ref === 'enrollments') return `${app}/pages/enrollments.html`;
        if (ref === 'risk_assessments') return `${app}/pages/risk-assessment.html`;
        if (ref === 'interventions') return `${app}/pages/interventions.html`;
        return null;
    }

    function setCount() {
        const el = els.count();
        if (!el) return;
        const unread = filtered.filter(n => Number(n.is_read || 0) !== 1).length;
        el.textContent = `${filtered.length} notifications (${unread} unread)`;
    }

    function render() {
        const tbody = els.tbody();
        if (!tbody) return;

        setCount();

        if (!filtered.length) {
            tbody.innerHTML = `<tr><td colspan="5" class="text-center"><div class="empty-state"><i class="fas fa-inbox"></i><h3>No notifications</h3><p>You're all caught up.</p></div></td></tr>`;
            return;
        }

        tbody.innerHTML = filtered.map((n) => {
            const id = Number(n.notification_id || 0);
            const isRead = Number(n.is_read || 0) === 1;
            const title = escapeHtml(n.title || 'Notification');
            const message = escapeHtml(n.message || '');
            const when = escapeHtml(formatWhen(n.created_at));
            const status = isRead ? 'Read' : 'Unread';

            const href = getNotificationLink(n);
            const titleCell = href
                ? `<a href="${href}" class="notification-title-link" data-notification-link="1" data-notification-id="${id}">${title}</a>`
                : `<span>${title}</span>`;

            const actionBtn = isRead
                ? ''
                : `<button class="action-btn edit" data-action="markRead" data-id="${id}" title="Mark as read"><i class="fas fa-check"></i></button>`;

            return `
                <tr${isRead ? '' : ' class="unread"'}>
                    <td>${titleCell}</td>
                    <td>${message}</td>
                    <td>${when}</td>
                    <td>${status}</td>
                    <td class="text-center"><div class="action-buttons">${actionBtn}</div></td>
                </tr>
            `;
        }).join('');
    }

    function applyFilter(term) {
        const lower = String(term || '').toLowerCase().trim();
        if (!lower) {
            filtered = [...all];
        } else {
            filtered = all.filter((n) => {
                const hay = `${n.title || ''} ${n.message || ''} ${n.reference_table || ''}`.toLowerCase();
                return hay.includes(lower);
            });
        }
        render();
    }

    async function load() {
        const tbody = els.tbody();
        if (tbody) {
            tbody.innerHTML = `<tr><td colspan="5" class="text-center"><div class="empty-state"><i class="fas fa-spinner fa-spin"></i><h3>Loading notifications</h3><p>Please wait...</p></div></td></tr>`;
        }

        const res = await axios.get(apiUrl(), {
            params: { operation: 'getNotifications', limit: 50, _: Date.now() }
        });
        if (!res.data?.success) {
            throw new Error(res.data?.message || 'Failed to load notifications');
        }

        all = Array.isArray(res.data?.data?.notifications) ? res.data.data.notifications : [];
        applyFilter(els.search()?.value || '');

        try {
            if (typeof window.refreshNotifications === 'function') {
                await window.refreshNotifications({ render: false });
            }
        } catch {
            // ignore
        }
    }

    async function markRead(id) {
        await axios.post(`${apiUrl()}?operation=markRead`, { notification_id: Number(id) });
        all = all.map(n => (Number(n.notification_id) === Number(id) ? { ...n, is_read: 1 } : n));
        applyFilter(els.search()?.value || '');

        try {
            if (typeof window.refreshNotifications === 'function') {
                await window.refreshNotifications({ render: false });
            }
        } catch {
            // ignore
        }
    }

    async function markAllRead() {
        await axios.post(`${apiUrl()}?operation=markAllRead`, {});
        all = all.map(n => ({ ...n, is_read: 1 }));
        applyFilter(els.search()?.value || '');

        try {
            if (typeof window.refreshNotifications === 'function') {
                await window.refreshNotifications({ render: false });
            }
        } catch {
            // ignore
        }
    }

    function wire() {
        els.search()?.addEventListener('input', (e) => applyFilter(e.target.value));
        els.refresh()?.addEventListener('click', async () => {
            try {
                await load();
            } catch (err) {
                console.error(err);
                alert(err?.message || 'Failed to refresh notifications');
            }
        });
        els.markAll()?.addEventListener('click', async () => {
            try {
                await markAllRead();
            } catch (err) {
                console.error(err);
                alert(err?.message || 'Failed to mark all as read');
            }
        });

        els.tbody()?.addEventListener('click', async (e) => {
            const btn = e.target.closest('button[data-action]');
            if (!btn) return;
            if (btn.dataset.action === 'markRead') {
                try {
                    await markRead(btn.dataset.id);
                } catch (err) {
                    console.error(err);
                    alert(err?.message || 'Failed to mark as read');
                }
            }
        });

        // If user clicks the title link, mark read first.
        document.addEventListener('click', async (e) => {
            const a = e.target.closest('a[data-notification-link="1"]');
            if (!a) return;
            const id = a.dataset.notificationId;
            if (!id) return;

            e.preventDefault();
            try {
                await markRead(id);
            } catch {
                // ignore
            }
            window.location.href = a.getAttribute('href');
        });
    }

    document.addEventListener('DOMContentLoaded', async () => {
        wire();
        try {
            await load();
        } catch (err) {
            console.error(err);
            const tbody = els.tbody();
            if (tbody) {
                const msg = err?.response?.data?.message || err?.message || 'Failed to load notifications.';
                tbody.innerHTML = `<tr><td colspan="5" class="text-center"><div class="empty-state"><i class="fas fa-circle-exclamation"></i><h3>Unable to load notifications</h3><p>${escapeHtml(msg)}</p></div></td></tr>`;
            }
            const count = els.count();
            if (count) count.textContent = 'Unable to load';
        }
    });
})();
