// School Settings masterfile controller

(function () {
    const apiUrl = () => `${window.API_BASE}/school_settings/school_settings.php`;

    initializeMasterfile({
        pageTitle: 'School Settings',
        subtitle: 'Manage school-level configuration values',
        breadcrumb: 'School Settings',
        entity: 'Setting',
        addLabel: 'Add Setting',
        navKey: 'school_settings',
        primaryKey: 'setting_id',
        disableDelete: true,
        columns: [
            { key: 'setting_key', label: 'Key', sortable: true },
            { key: 'setting_value', label: 'Value', sortable: true },
            { key: 'description', label: 'Description', sortable: false },
            
        ],
        fields: [
            {
                key: 'setting_key',
                label: 'Setting Key',
                required: true,
                readonlyOnEdit: true
            },
            {
                key: 'setting_value',
                label: 'Setting Value',
                required: true
            },
            {
                key: 'description',
                label: 'Description'
            }
        ],
        api: {
            list: async () => {
                const res = await axios.get(apiUrl(), {
                    params: { operation: 'getAllSettings', _: Date.now() }
                });
                if (Array.isArray(res.data)) return res.data;
                if (Array.isArray(res.data?.rows)) return res.data.rows;
                if (res.data?.success === false) throw new Error(res.data?.message || 'Failed to load settings');
                return res.data?.data || [];
            },
            create: async (payload) => {
                const res = await axios.post(`${apiUrl()}?operation=updateSetting`, payload);
                if (res.data?.success === false) throw new Error(res.data?.message || 'Unable to save setting');
                return res.data;
            },
            update: async (_id, payload) => {
                const res = await axios.post(`${apiUrl()}?operation=updateSetting`, payload);
                if (res.data?.success === false) throw new Error(res.data?.message || 'Unable to save setting');
                return res.data;
            },
            remove: async (_id) => {
                throw new Error('Delete is not supported for School Settings');
            }
        }
    });
})();
