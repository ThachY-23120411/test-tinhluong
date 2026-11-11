CREATE PROCEDURE [dbo].[sp_LockSalary_CheckStatus_html]
    @LoginID int = null,
    @LanguageID varchar(2) = 'VN'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CurrentMonth INT, @CurrentYear INT;
    SELECT TOP 1 @CurrentMonth = [Month], @CurrentYear = [Year] FROM tblCurrentWorkingMonth;
    IF @CurrentMonth IS NULL
        SELECT TOP 1 @CurrentMonth = [Month], @CurrentYear = [Year] FROM dbo.fn_Get_Sal_Month_Year(GETDATE());
    SET @CurrentMonth = ISNULL(@CurrentMonth, MONTH(GETDATE()));
    SET @CurrentYear = ISNULL(@CurrentYear, YEAR(GETDATE()));
    DECLARE @html nvarchar(max) = N'';
    SET @html = N'
<style>
    #LockSalaryContainer {
        height: calc(100vh - 110px) !important;
        max-height: calc(100vh - 110px) !important;
        width: 100% !important;
        display: flex;
        flex-direction: column;
        border-top: none !important;
        overflow: hidden !important;
    }
    /* Reset padding/margin on DevExpress form elements containing this form */
    .dx-form:has(#LockSalaryContainer),
    .dx-form:has(#LockSalaryContainer) .dx-field-item,
    .dx-form:has(#LockSalaryContainer) .dx-field-item-content,
    .dx-form:has(#LockSalaryContainer) .dx-form-group-content {
        padding: 0 !important;
        margin: 0 !important;
    }
    /* ===== TOOLBAR CUSTOM STYLES ===== */
    #hidden-toolbar-items-lock {
        position: absolute;
        left: -9999px;
    }
    .toolbar-filters-wrap {
        display: flex;
        align-items: center;
        gap: 15px;
    }
    .toolbar-filter-item {
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .toolbar-filter-item span {
        font-weight: 600;
        white-space: nowrap;
        font-size: 13px;
        transition: color 0.3s ease;
    }
    .toolbar-filter-item .dx-texteditor-input,
    .toolbar-filter-item .dx-dropdowneditor-icon {
        transition: color 0.3s ease;
    }
    .grid-container {
        flex: 1;
        background: transparent;
        border-radius: 0px;
        box-shadow: none;
        padding: 0px;
        overflow: hidden;
        transition: background 0.3s ease, box-shadow 0.3s ease;
        container-type: inline-size;
    }
    #LockSalaryContainer .dx-datagrid-header-panel
        .dx-button .dx-icon-add {
            display: none !important;
        }
    #LockSalaryContainer .dx-datagrid-header-panel
        .dx-button:has(.dx-icon-add) {
            display: none !important;
        }
    #LockSalaryContainer { transition: background 0.3s ease; }
    .dark-mode #LockSalaryContainer {
        background: var(--paradise-bg-0, #0b0e11);
    }
    .dark-mode #LockSalaryContainer .grid-container {
        background: var(--paradise-bg-1, #1e2329);
        box-shadow: var(--paradise-shadow-sm, 0 2px 4px rgba(0,0,0,0.5));
        border: 1px solid var(--paradise-border-color, #2b3139);
    }
    .dark-mode .toolbar-filter-item span {
        color: var(--paradise-fg-0, #eaecef);
    }
    .dark-mode .toolbar-filter-item .dx-texteditor-input,
    .dark-mode .toolbar-filter-item .dx-dropdowneditor-icon {
        color: var(--paradise-fg-0, #eaecef) !important;
    }
    .dark-mode #LockSalaryContainer .dx-datagrid {
        background-color: var(--paradise-bg-1, #1e2329);
        color: var(--paradise-fg-0, #eaecef);
    }
    .dark-mode #LockSalaryContainer .dx-datagrid-headers {
        background-color: var(--paradise-bg-1, #1e2329);
        color: var(--paradise-fg-0, #eaecef);
        border-bottom: 1px solid var(--paradise-border-color, #2b3139);
    }
    .dark-mode #LockSalaryContainer .dx-datagrid-content .dx-datagrid-table .dx-row > td {
        border-bottom: 1px solid var(--paradise-border-color, #2b3139);
    }
    .dark-mode #LockSalaryContainer .dx-datagrid-borders > .dx-datagrid-headers,
    .dark-mode #LockSalaryContainer .dx-datagrid-borders > .dx-datagrid-filter-panel {
        border-top: 1px solid var(--paradise-border-color, #2b3139);
    }
    .dark-mode #LockSalaryContainer .dx-row-alt > td {
        background-color: var(--paradise-bg-2, #2b3139);
    }
    .dark-mode #LockSalaryContainer .dx-datagrid-bottom-load-panel {
        background-color: var(--paradise-bg-1, #1e2329);
    }
    /* ===== FIX SEARCH PANEL OVERLAP ===== */
    #LockSalaryContainer .dx-datagrid-search-panel {
        width: 230px !important;
        min-width: 230px !important;
        max-width: 260px !important;
    }
    #LockSalaryContainer .dx-datagrid-search-panel .dx-texteditor-input {
        padding-left: 34px !important;
        padding-right: 12px !important;
        text-overflow: ellipsis !important;
    }
    #LockSalaryContainer .dx-datagrid-search-panel .dx-placeholder {
        left: 34px !important;
        right: 12px !important;
        max-width: calc(100% - 46px) !important;
        overflow: hidden !important;
        white-space: nowrap !important;
        text-overflow: ellipsis !important;
    }
    #LockSalaryContainer .dx-datagrid-search-panel .dx-placeholder::before {
        padding-left: 0 !important;
        padding-right: 0 !important;
        overflow: hidden !important;
        white-space: nowrap !important;
        text-overflow: ellipsis !important;
    }
    /* ===== HIDE DUPLICATE SEARCH PLACEHOLDER ===== */
    #LockSalaryContainer .dx-datagrid-search-panel .dx-placeholder,
    #LockSalaryContainer .dx-datagrid-search-panel .dx-placeholder::before {
        display: none !important;
        content: "" !important;
    }
    /* Split toolbar before its two sides collide. */
    @container (max-width: 1150px) {
        #LockSalaryContainer .dx-datagrid-header-panel .dx-toolbar-items-container {
            height: auto !important;
            min-height: 80px !important;
            display: flex !important;
            flex-direction: column !important;
            gap: 4px !important;
        }
        #LockSalaryContainer .dx-datagrid-header-panel .dx-toolbar-before,
        #LockSalaryContainer .dx-datagrid-header-panel .dx-toolbar-after {
            position: static !important;
            width: 100% !important;
            height: 36px !important;
            display: flex !important;
            align-items: center !important;
        }
        #LockSalaryContainer .dx-datagrid-header-panel .dx-toolbar-before {
            justify-content: flex-start !important;
        }
        #LockSalaryContainer .dx-datagrid-header-panel .dx-toolbar-after {
            justify-content: flex-end !important;
        }
        #LockSalaryContainer .dx-datagrid-header-panel .dx-toolbar-center {
            display: none !important;
        }
        #LockSalaryContainer #lock-status-badge-wrap {
            margin-right: 4px !important;
        }
    }
    @container (max-width: 700px) {
        #LockSalaryContainer #lock-status-badge-wrap > span:first-child {
            display: block !important;
            width: 80px !important;
            flex: 0 0 80px !important;
            margin-right: 4px !important;
            white-space: normal !important;
            font-size: 12px !important;
            line-height: 18px !important;
        }
        #LockSalaryContainer #lock-status-badge-wrap {
            align-items: center !important;
            white-space: nowrap !important;
        }
        #LockSalaryContainer .dx-datagrid-search-panel {
            width: 140px !important;
            min-width: 140px !important;
            max-width: 140px !important;
        }
        #LockSalaryContainer .dx-datagrid-header-panel .dx-toolbar-after {
            gap: 3px !important;
        }
    }
    /* ===== TOAST NOTIFICATION STYLES ===== */
    .dx-toast-success .dx-toast-content {
        background-color: #28a745 !important; /* Green */
        color: #ffffff !important;
        font-weight: 500;
        border-radius: 6px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    }
    /* ===== PREMIUM TOOLBAR LOCK BUTTONS ===== */
    .btn-lock-toolbar.active, .btn-unlock-toolbar.active {
        background: #d93025 !important;
        color: #ffffff !important;
        border-radius: 20px !important;
        border: none !important;
        padding: 4px 16px !important;
        font-weight: 600 !important;
        box-shadow: 0 2px 6px rgba(217, 48, 37, 0.2) !important;
        transition: all 0.3s ease !important;
    }
    .btn-lock-toolbar.active .dx-icon, .btn-unlock-toolbar.active .dx-icon {
        color: #ffffff !important;
    }
    .btn-lock-toolbar.active:hover, .btn-unlock-toolbar.active:hover {
        background: #c5221f !important;
        transform: translateY(-1px);
        box-shadow: 0 4px 8px rgba(217, 48, 37, 0.3) !important;
    }
    .btn-lock-toolbar.disabled, .btn-unlock-toolbar.disabled,
    .btn-lock-toolbar:disabled, .btn-unlock-toolbar:disabled {
        background: #f1f3f4 !important;
        color: #9699a2 !important;
        border-radius: 20px !important;
        border: none !important;
        padding: 4px 16px !important;
        font-weight: 600 !important;
        box-shadow: none !important;
        pointer-events: none !important;
        opacity: 0.9;
    }
    .btn-lock-toolbar.disabled .dx-icon, .btn-unlock-toolbar.disabled .dx-icon {
        color: #9699a2 !important;
    }
    .dark-mode .btn-lock-toolbar.disabled, .dark-mode .btn-unlock-toolbar.disabled {
        background: var(--paradise-bg-2, #2b3139) !important;
        color: var(--paradise-fg-2, #848e9c) !important;
    }
    .dark-mode .btn-lock-toolbar.disabled .dx-icon, .dark-mode .btn-unlock-toolbar.disabled .dx-icon {
        color: var(--paradise-fg-2, #848e9c) !important;
    }
    .status-badge {
        background: #e8eaed;
        color: #5f6368;
        padding: 2px 8px;
        border-radius: 12px;
        font-weight: 600;
        font-size: 11px;
    }
    .dark-mode .status-badge {
        background: var(--paradise-bg-2, #2b3139);
        color: var(--paradise-fg-1, #b7bdc6);
    }
    #lblStatusText.text-green {
        color: #2e7d32;
    }
    #lblStatusText.text-orange {
        color: #ed8000;
    }
</style>
<div id="hidden-toolbar-items-lock">
    <div class="toolbar-filters-wrap" id="lock-toolbar-filters">
        <div class="toolbar-filter-item">
            <span>%lock_salary_month%</span>
            <div id="P682FA188ED5B4BD38C89E22CD6E72646" style="width:120px;"></div>
        </div>
        <div class="toolbar-filter-item">
            <span>%lock_salary_year%</span>
            <div id="P911AA562E7AC44CEBC3FC7FAB611E906" style="width:120px;"></div>
        </div>
    </div>
</div>
<div id="LockSalaryContainer" style="height: 100%; display: flex; flex-direction: column; background: var(--bs-body-bg); opacity: 0; transition: opacity 0.15s ease-in-out;">
    <!-- Grid Container -->
    <div class="grid-container" style="flex: 1; background: transparent; border-radius: 0px; box-shadow: none; padding: 0px; overflow: hidden; display: flex; flex-direction: column;">
        <div id="gridLockSalary" style="height: 100%;"></div>
    </div>
</div>
<script>
    (() => {
        window["_hideID_P682FA188ED5B4BD38C89E22CD6E72646"] = true;
        window["_hideID_P911AA562E7AC44CEBC3FC7FAB611E906"] = true;
        let _showtoolbarGrid_PF9DC07333E264FD0A04FC1BA1BF84270 = true;
        '
        + (select  loadUI from tblCommonControlType_Signed where UID = 'P682FA188ED5B4BD38C89E22CD6E72646')
        + (select  loadUI from tblCommonControlType_Signed where UID = 'P911AA562E7AC44CEBC3FC7FAB611E906')
        + (select  loadUI from tblCommonControlType_Signed where UID = 'PF9DC07333E264FD0A04FC1BA1BF84270')
        + N'
        function hpaLockSalaryAlert(message, type, duration) {
            var mgr = (window.parent && window.parent.uiManager) || window.uiManager;
            if (!mgr || typeof mgr.showAlert !== "function") {
                console.error("uiManager.showAlert is not available", { message, type });
                return;
            }
            mgr.showAlert({ type: type || "info", message: message || "", duration: duration || 3000 });
        }
        async function hpaLockSalaryConfirm(message, title) {
            return await new Promise(function(resolve) {
                const onConfirm = function() { resolve(true); };
                const onCancel = function() { resolve(false); };
                if (typeof showConfirmPopup === "function") {
                    showConfirmPopup({
                        title: title || "X�c nh?n",
                        message: message || "",
                        onYes: onConfirm,
                        onNo: onCancel
                    });
                    return;
                }
                if (typeof uiManager !== "undefined" && uiManager.showConfirmPopup) {
                    uiManager.showConfirmPopup({
                        title: title || "X�c nh?n",
                        content: message || "",
                        onConfirm: onConfirm,
                        onCancel: onCancel
                    });
                    return;
                }
                console.error("showConfirmPopup/uiManager.showConfirmPopup is not available", { message, title });
                resolve(false);
            });
        }
        // --- 1. KH?I T?O CAC CONTROL BEN TRONG CONTAINER ---
        window.currentRecordID_MonthID = null;
        window.currentRecordID_YearID = null;
        let dataParams = {
            get month() {
                let inst = $("#P682FA188ED5B4BD38C89E22CD6E72646").dxSelectBox("instance");
                return inst ? inst.option("value") : currentMonth;
            },
            get year() {
                let inst = $("#P911AA562E7AC44CEBC3FC7FAB611E906").dxSelectBox("instance");
                return inst ? inst.option("value") : currentYearObj;
            },
        };
        // Kh?i t?o cA�c SelectBox
        let currentMonth = (typeof window.CurrentWorkingMonth !== "undefined" && window.CurrentWorkingMonth) ? Number(window.CurrentWorkingMonth) : ' + CAST(@CurrentMonth AS NVARCHAR(10)) + N';
        let currentYearObj = (typeof window.CurrentWorkingYear !== "undefined" && window.CurrentWorkingYear) ? Number(window.CurrentWorkingYear) : ' + CAST(@CurrentYear AS NVARCHAR(10)) + N';
        let monthList = Array.from({length: 12}, (_, i) => ({ ID: i + 1, Name: (i + 1).toString() }));
        let yearList = Array.from({length: 16}, (_, i) => ({ ID: currentYearObj - 5 + i, Name: (currentYearObj - 5 + i).toString() }));
        let mInst = $("#P682FA188ED5B4BD38C89E22CD6E72646").dxSelectBox("instance");
        if (mInst) {
            mInst.option({
                dataSource: monthList,
                valueExpr: "ID",
                displayExpr: "Name",
                value: currentMonth,
                onValueChanged: function() {
                    ReloadData();
                    fetchLockStatus();
                }
            });
        }
        let yInst = $("#P911AA562E7AC44CEBC3FC7FAB611E906").dxSelectBox("instance");
        if (yInst) {
            yInst.option({
                dataSource: yearList,
                valueExpr: "ID",
                displayExpr: "Name",
                value: currentYearObj,
                onValueChanged: function() {
                    ReloadData();
                    fetchLockStatus();
                }
            });
        }
            let api = true;
            let DataSource = [];
            let _pageCache = {};
            let _currentKeyword = "";
            let dataStore_ = null;
            // ============================================================
            // 1. KH?I T?O DATASTORE DUY NH?T M?T L?N
            // ============================================================
            dataStore_ = new DevExpress.data.CustomStore({
                key: "EmployeeID",
                load: function(loadOptions) {
                    const deferred = $.Deferred();
                        if (!api) {
                        const results = DataSource || [];
                        const skip = loadOptions.skip || 0;
                        const take = loadOptions.take || 50;
                        const pageData = results.slice(skip, skip + take);
                        deferred.resolve({
                            data: pageData,
                            totalCount: results.length
                        });
                        api = true;
                        return deferred.promise();
                    }
                    let params = [];
                    // SP nghi?p v?
                    params.push("@ProcName", "sp_LockSalary_CheckStatus");
                    // Tham s? c?a tA�n th? t?c load Data
                    let procParam = `@Month=${dataParams.month},@Year=${dataParams.year},@LoginID=${window.UserID || window.LoginID},@LanguageID=''${window.LanguageID || ''VN''}''`;
                    params.push("@ProcParam", procParam);
                    // PhA�n trang
                    params.push("@Take", loadOptions.take || 50);
                    params.push("@Skip", loadOptions.skip || 0);
                    // TotalCount
                    if (loadOptions.requireTotalCount) {
                        params.push("@RequireTotalCount", 1);
                    }
                    // Sort
                    const sort = loadOptions.sort
                        ? loadOptions.sort.map(s => s.selector + (s.desc ? " DESC" : " ASC")).join(",")
                        : "EmployeeID ASC";
                    params.push("@Sort", "ORDER BY " + sort);
                    // Search
                    if (_currentKeyword) {
                        params.push("@SearchValue", _currentKeyword);
                        params.push("@ColumnSearch", "EmployeeID,FullName,Year,Month");
                    }
                    // Filter
                    if (loadOptions.filter) {
                          // Ki?m tra filter item cA3 ph?i function khong
                          const isJSFunction = (item) => typeof item === ''function'';
                          const hasFunction = JSON.stringify(loadOptions.filter, (key, val) => {
                        if (typeof val === "function") return "FUNCTION";
                              return val;
                    }).includes("FUNCTION");
              if (!hasFunction) {
             params.push("@Filters", createConditionQuery(loadOptions.filter));
                          }
                      }
               // Summary
                    if (loadOptions.totalSummary) {
                        const summary = loadOptions.totalSummary.map(item => {
                            const type = item.summaryType === "custom"
                                ? `count(CASE WHEN [${item.selector}] = 1 THEN 1 END) as ${item.selector}_COUNT`
                                : `${item.summaryType}([${item.selector}]) as ${item.selector}_${item.summaryType.toUpperCase()}`;
                            return type;
                        });
                        params.push("@TotalSummary", summary.join(", "));
                    }
                    AjaxHPAParadise({
                        data: {
                            name: "sp_LoadGridUsingAPI",
                            param: params
                        },
                        success: function (res) {
                            const json = typeof res === "string" ? JSON.parse(res) : res;
                            const results = Array.isArray(json?.data?.[0]) ? json.data[0] : [];
                            let result = { data: results };
                            if (loadOptions.requireTotalCount) {
                                result.totalCount = json?.data?.[1]?.[0]?.TotalCount ?? 0;
                                if (loadOptions.totalSummary) {
                                    result.summary = Object.values(json?.data?.[2]?.[0] ?? {});
                                }
                            } else {
                                if (loadOptions.totalSummary) {
                                    result.summary = Object.values(json?.data?.[1]?.[0] ?? {});
                                }
                            }
                            DataSource = results;
                            if (typeof window.syncSharedGridData === ''function'') window.syncSharedGridData("");
                            deferred.resolve(result);
                        },
                        error: function (err) {
                            deferred.reject("Data Loading Error");
                        }
                    });
                    return deferred.promise();
                }
            });
            ' + N'
             function ReloadData(){
                  if (typeof InstancegridLockSalaryPF9DC07333E264FD0A04FC1BA1BF84270 !== "undefined") {
                      InstancegridLockSalaryPF9DC07333E264FD0A04FC1BA1BF84270.refresh();
                  }
             }
            function clearPageCache() {
                _pageCache = {};
            }
            function getGridHeight() {
                const gridEl = InstancegridLockSalaryPF9DC07333E264FD0A04FC1BA1BF84270.element();
                const domElement = gridEl.jquery ? gridEl[0] : gridEl;
                const top = domElement.getBoundingClientRect().top;
                return window.innerHeight - top - 20;
            }
            // ============================================================
            // 2. KH?I T?O GRID LAYOUT M?T L?N DUY NH?T
            // ============================================================
            $(document).ready(function() {
                const initGrid = () => {
                    const gridInstance = window.InstancegridLockSalaryPF9DC07333E264FD0A04FC1BA1BF84270;
                    if (gridInstance) {
                        gridInstance.beginUpdate();
            let oldOnToolbarPreparing = gridInstance.option("onToolbarPreparing");
            gridInstance.option("onToolbarPreparing", function(e) {
                if (typeof oldOnToolbarPreparing === "function") {
                    oldOnToolbarPreparing(e);
                }
                // PLACEHOLDER BEN TRAI (dA1ng �`��� ch��ca ThA�ng/N��m)
                e.toolbarOptions.items.unshift({
                    location: "before",
                    locateInMenu: "never",
                    template: function() {
                        return $("<div id=''lock-filters-placeholder'' style=''display:flex; align-items:center; gap:15px;''>");
                    }
                });
                // STATUS LABEL (Hi���n th��< Tr���ng thA�i khA3a l����ng)
                let statusLabel = {
                    location: "after",
                    locateInMenu: "never",
                    template: function() {
                        return $("<div id=''lock-status-badge-wrap'' style=''display:flex; align-items:center; margin-right:15px; font-size:13px; font-weight:600; color:#5f6368;''>")
                            .append($("<span style=''margin-right:8px; color:#7e8299; font-weight:500;''>").text("%lock_salary_status_label%"))
                            .append($("<span id=''lblStatusText'' style=''margin-right:5px;''>").text("%lock_salary_status_opening%"))
                            .append($("<span id=''lblQuantity'' class=''status-badge''>").text("0/0"));
                    }
                };
                // NUT KHOA TOOLBAR (d���ng pill)
                let lockBtn = {
                    location: "after",
                    locateInMenu: "never",
                    widget: "dxButton",
                    options: {
                        text: "%lock_salary_button_lock%",
                        icon: "lock",
                        hint: "%newdashboard_locksalary%",
                        elementAttr: { id: "btnLockToolbar", class: "btn-lock-toolbar active" },
                        onClick: async function() {
                            if ($("#btnLockToolbar").hasClass("disabled")) return;
                            let result = await hpaLockSalaryConfirm("%newdashboard_confirm_lock_attendance%", "%ACComfirm%");
                            if (!result) return;
                            let divisionIds = window.DivisionID || window.DivisionIDS || 1;
                            await AjaxHPAParadiseAsync({
                                data: {
                                    name: "PR_Sal_Lock_Update",
                                    param: [
                                        "@Month", dataParams.month,
                                        "@Year", dataParams.year,
                                        "@LoginID", window.UserID || window.LoginID || 3,
                                        "@PeriodID", 0,
                                        "@DivisionIDS", divisionIds
                                    ]
                                },
                                success: async function (resultData) {
                                    try {
                                        let jsonData = typeof resultData === "string" ? JSON.parse(resultData) : resultData;
                                        if(jsonData.result == "error") {
                                            hpaLockSalaryAlert(jsonData.reason || "Error", "error", 2500);
                                            return;
                                        }
                                        hpaLockSalaryAlert("%LockSalarySuccess%", "success", 2000);
                                        ReloadData();
                                        fetchLockStatus();
                                    } catch(e) {}
                                }
                            });
                        }
                    }
                };
                // NUT MO KHOA TOOLBAR (d���ng pill)
                let unlockBtn = {
                    location: "after",
                    locateInMenu: "never",
                    widget: "dxButton",
                    options: {
                        text: "%lock_salary_button_unlock%",
                        icon: "unlock",
                        hint: "%Unlocksalary1%",
                        elementAttr: { id: "btnUnlockToolbar", class: "btn-unlock-toolbar disabled" },
                        disabled: true,
                        onClick: async function() {
                            if ($("#btnUnlockToolbar").hasClass("disabled")) return;
                            let result = await hpaLockSalaryConfirm("%newdashboard_confirm_unlock_attendance%", "%ACComfirm%");
                            if (!result) return;
                            let divisionIds = window.DivisionID || window.DivisionIDS || null;
                            await AjaxHPAParadiseAsync({
                                data: {
                                    name: "PR_Sal_Lock_Delete",
                                    param: [
                                        "@Month", dataParams.month,
                                        "@Year", dataParams.year,
                                        "@LoginID", window.UserID || window.LoginID || 3,
                                        "@DivisionIDS", divisionIds
                                    ]
                                },
                                success: async function (resultData) {
                                    try {
                                        let jsonData = typeof resultData === "string" ? JSON.parse(resultData) : resultData;
                                        if(jsonData.result == "error") {
                                            hpaLockSalaryAlert(jsonData.reason || "%UnlockSalaryError%", "error", 2500);
                                            return;
                                        }
                                        hpaLockSalaryAlert("%SAL_UNLOCK_SUCCESSFULLY%", "success", 2000);
                                        ReloadData();
                                        fetchLockStatus();
                                    } catch(e) {}
                                }
                            });
                        }
                    }
                };
                let insertIdx = e.toolbarOptions.items.findIndex(x => x.location === "after" || x.name === "searchPanel" || x.icon === "refresh");
                if (insertIdx >= 0) {
                    e.toolbarOptions.items.splice(insertIdx, 0, statusLabel, lockBtn, unlockBtn);
                } else {
                    e.toolbarOptions.items.push(statusLabel, lockBtn, unlockBtn);
                }
            });
            // G?p DOM
            gridInstance.option("onContentReady", function(e) {
                let placeholder = $("#lock-filters-placeholder");
                if (placeholder.length > 0 && placeholder.children().length === 0) {
                    let filters = $("#lock-toolbar-filters");
                    if (filters.length > 0) {
                        placeholder.append(filters);
                    }
                }
            });
            gridInstance.option("remoteOperations", {
                paging: true, filtering: true, sorting: true, searching: true
            });
            gridInstance.option({
                "scrolling.mode": "infinite",
                "scrolling.rowRenderingMode": "virtual",
                "scrolling.preloadEnabled": false,
                "paging.enabled": true,
                "paging.pageSize": 50,
                "pager.visible": false,
                "searchPanel.highlightSearchText": false,
                "searchPanel.placeholder": "%lock_salary_search_placeholder%",
                "dataSource": dataStore_,
                "height": "100%"
            });
            gridInstance.option("onOptionChanged", function (e) {
                if (e.name === "searchPanel" && e.fullName === "searchPanel.text") {
                    _currentKeyword = (e.value || "").trim();
                    _pageCache = {};
                }
            });
            gridInstance.endUpdate();
            $("#LockSalaryContainer").css("opacity", 1);
            // ============================================================
            // 3. HAM STATUS CARD & BUTTON ACTIONS
            // ============================================================
            async function fetchLockStatus() {
                try {
                    let month = dataParams.month;
                    let year = dataParams.year;
                    let loginId = window.UserID || window.LoginID || 3;
                    let divisionIds = window.DivisionID || window.DivisionIDS || 1;
                    let res = await AjaxHPAParadiseAsync({
                        data: {
                            name: "sp_QuantityLockSalaryReload",
                            param: [
                                "@Month", month,
                                "@Year", year,
                                "@LoginID", loginId,
                                "@DivisionIDS", divisionIds
                            ]
                        }
                    });
                    let data = typeof res === "string" ? JSON.parse(res) : res;
                    let statusInfo = data?.data?.[0]?.[0];
                    let quantity = "0/0";
                    let lockedCount = 0;
                    let totalCount = 0;
                    if (statusInfo) {
                        quantity = statusInfo.Quantity || "0/0";
                        lockedCount = statusInfo.Lock || 0;
                        totalCount = statusInfo.UnLock || 0;
                    }
                    $("#lblQuantity").text(quantity);
                    let isLocked = (lockedCount === totalCount && totalCount > 0);
                    let btnLock = $("#btnLockToolbar").dxButton("instance");
                    let btnUnlock = $("#btnUnlockToolbar").dxButton("instance");
                    if (isLocked) {
                        $("#lblStatusText").text("%lock_salary_status_locked%").removeClass("text-orange").addClass("text-green");
                        if (btnLock) {
                            btnLock.option("disabled", true);
                            $("#btnLockToolbar").addClass("disabled").removeClass("active");
                        }
                        if (btnUnlock) {
                            btnUnlock.option("disabled", false);
                            $("#btnUnlockToolbar").removeClass("disabled").addClass("active");
                        }
                    } else {
                        $("#lblStatusText").text("%lock_salary_status_opening%").removeClass("text-green").addClass("text-orange");
                        if (btnLock) {
                            btnLock.option("disabled", false);
                            $("#btnLockToolbar").removeClass("disabled").addClass("active");
                        }
                        if (btnUnlock) {
                            btnUnlock.option("disabled", true);
                            $("#btnUnlockToolbar").addClass("disabled").removeClass("active");
                        }
                    }
                } catch (err) {
                    console.error("Error fetching lock status:", err);
                }
            }
            ReloadData();
            fetchLockStatus();
                        return true;
                    }
                    return false;
                };
                if (!initGrid()) {
                    let attempts = 0;
                    const interval = setInterval(() => {
                        attempts++;
                        if (initGrid() || attempts > 10) {
                            clearInterval(interval);
                            $("#LockSalaryContainer").css("opacity", 1);
                        }
                    }, 50);
                }
            });
    })();
</script>
';
    SELECT @html as HTML;
    /*
    EXEC sptblCommonControlType_Signed_DUC 'sp_MachineList_html'
EXEC sp_GenerateHTMLScript_new 'sp_MachineList_html'
    */
END
