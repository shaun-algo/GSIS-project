// Grade Remarks reference (read-only)

(function () {
    const apiUrl = () => `${window.API_BASE}/grade_remarks/grade_remarks.php`;

    initializeMasterfile({
        pageTitle: 'Grade Remarks',
        subtitle: 'Reference list (read-only)',
        breadcrumb: 'Grade Remarks',
        entity: 'Grade Remark',
        navKey: 'grade_remarks',
        primaryKey: 'grade_remark_id',
        readOnly: true,
        columns: [
            { key: 'remark_name', label: 'Remark', sortable: true },
            { key: 'description', label: 'Description', sortable: false }
        ],
        fields: [],
        api: {
            list: async () => {
                const res = await axios.get(apiUrl(), {
                    params: { operation: 'getAllGradeRemarks', _: Date.now() }
                });
                return res.data;
            },
            create: async () => { throw new Error('Read-only'); },
            update: async () => { throw new Error('Read-only'); },
            remove: async () => { throw new Error('Read-only'); }
        }
    });
})();
