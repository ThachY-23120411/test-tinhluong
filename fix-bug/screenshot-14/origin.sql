/***************************************************************************************************
  DATABASE NGUỒN GỐC : [Vietinsoft_ForTest_Tai] (Chưa qua chỉnh sửa)
  SCREENSHOT         : SCREENSHOT-14
  MÀN HÌNH / MENU    : CRM/KPI -> Các email theo dõi KPI (MnuKPI010)
  MỤC ĐÍCH           : Lưu trữ nguyên trạng mã nguồn Stored Procedure gốc để Sếp đối chiếu (COMPARE)
                       trước và sau khi áp dụng bản vá trong file patch tương ứng.
***************************************************************************************************/

USE [Vietinsoft_ForTest_Tai];
GO

/*--------------------------------------------------------------------------------------------------
  THỦ TỤC GỐC [1/2]: [dbo].[sp_CRM_EmailKPIFollow_html]
--------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[sp_CRM_EmailKPIFollow_html]
(
    @LoginID INT = 3,
    @LanguageID VARCHAR(2) = 'EN',
    @isWeb INT = 0
)
AS
BEGIN
    SET NOCOUNT ON;
 DECLARE @html NVARCHAR(MAX);
    SET @html = N'
<div id="sp_CRM_EmailKPIFollow_html">
    <style>
        .email-container {
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            padding: 20px;
            margin-bottom: 20px;
        }

        .email-header-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #e9ecef;
        }

        .email-header-section h2 {
            margin: 0;
        }

        .email-filter {
            display: flex;
            gap: 15px;
            align-items: flex-end;
            flex-wrap: wrap;
            margin-bottom: 20px;
        }

        .email-filter>div {
            display: flex;
            flex-direction: column;
        }

        .email-filter label {
            display: block;
            margin-bottom: 5px;
            font-weight: 600;
            color: #64748b;
            font-size: 13px;
        }

        .email-filter button {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 500;
            font-size: 14px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
        }

        .btn-filter {
            background-color: #198754;
            color: white;
        }

        .btn-filter:hover {
            background-color: #157347;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(25, 135, 84, 0.4);
        }

        .btn-reset {
            background-color: transparent;
            color: #198754;
            border: 2px solid #198754 !important;
        }

        .btn-reset:hover {
            background-color: #198754;
            color: white;
        }

        .btn-add {
            margin-left: auto;
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 500;
            font-size: 14px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
            background-color: #198754;
            color: white;
        }

        .btn-add:hover {
            background-color: #157347;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(25, 135, 84, 0.4);
        }

        #emailModal.show {
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            position: fixed !important;
            top: 0 !important;
            left: 0 !important;
            width: 100% !important;
            height: 100% !important;
            z-index: 1050 !important;
            background: rgba(0, 0, 0, 0.5) !important;
        }

        .modal-backdrop.show {
            background: rgba(0, 0, 0, 0.65);
            backdrop-filter: blur(1px);
        }

        #emailModal .modal-dialog {
            margin: 0 !important;
            max-width: 500px;
        }

        .modal-content {
            border: none !important;
            box-shadow: none !important;
            max-height: 80vh;
            overflow-y: auto;
        }

        .modal-footer {
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }

        .email-table tbody tr:hover {
            background-color: rgba(255, 255, 255, 0.05) !important;
        }
    </style>

    <div class="email-container">

 <!-- <div class="email-filter">
            <div>
                <label for="emailFilterFromDate"><span data-message-id="FromDate">%FromDate%</span>:</label>
                <input type="date" id="emailFilterFromDate" style="
                    padding: 9px;
                    border-radius: 10px;
                    border: 0.5px solid #ebebeb;
                ">
            </div>
            <div>
                <label for="emailFilterToDate"><span data-message-id="ToDate">%ToDate%</span>:</label>
                <input type="date" id="emailFilterToDate" style="
                    padding: 9px;
                    border-radius: 10px;
                    border: 0.5px solid #ebebeb;
                ">
            </div>
            <button class="btn-filter" id="btnEmailFilter">
                <i class="bi bi-filter"></i> %Search%
            </button>
            <button class="btn-reset" id="btnEmailReset">
                <i class="bi bi-arrow-clockwise"></i> %Refresh%
            </button>

             <button class="btn-add" id="btnAddEmail">
                <i class="bi bi-plus-circle"></i> %AddNew%
            </button>
        </div> -->

        <div class="table-responsive">
            <div id="GridEmailKPIList" style="height: 100%;"></div>
        </div>
    </div>

    <!-- Email Modal -->
    <div class="modal fade" id="emailModal" tabindex="-1" data-bs-backdrop="static" data-bs-keyboard="false">
        <div class="modal-dialog modal-md">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="emailModalTitle" data-message-id="AddEmailNew">%AddEmailNew%</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="emailForm">
                        <div class="form-group mb-3">
                            <label for="email_fullname" class="form-label"><span data-message-id="EmployeeID">%EmployeeID%</span></label>
                            <div id="P2D9DF38DBC46406C8EC1686058288F56"></div>
                        </div>
                        <div class="form-group mb-3">
                            <label for="email_fullname" class="form-label"><span data-message-id="FullName">%FullName%</span></label>
                            <div id="PA7D7F5081185488CA62C1F211136902A"></div>
                        </div>
                        <div class="form-group mb-3">
                            <label for="email_email" class="form-label"><span data-message-id="Email">%Email%</span></label>
                            <div id="P3649C063B0674562BCCA3FB6B2F4DBF6"></div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" id="btnCloseEmail"
                        data-bs-dismiss="modal"><span data-message-id="Close">%Close%</span></button>
                    <button type="button" class="btn btn-primary" id="btnSaveEmail" data-message-id="Save">%Save%</button>
                </div>
            </div>
        </div>
    </div>

</div>
<script>
    (() => {
        let DataSource = []

        // Load DataSource: EmployeeListAll_DataSetting_Custom
        if ("EmployeeListAll_DataSetting_Custom" && "EmployeeListAll_DataSetting_Custom".trim() !== "") {
            loadDataSourceCommon("EmployeeID", "EmployeeListAll_DataSetting_Custom", function (data) {
                // Data được shared qua callback
            });
        }

        function loadDataSourceCommon(columnName, dataSourceSP, onSuccessCallback) {
            if (!columnName || !dataSourceSP || dataSourceSP.trim() === "") {
                console.warn("[loadDataSourceCommon] Missing columnName or dataSourceSP");
   return;
            }

            const dataSourceKey = "DataSource_" + columnName;
            // Sử dụng format: columnNameDataSourceLoaded để tương thích với code hiện tại
            const loadedKey = columnName + "DataSourceLoaded";

            // Kiểm tra nếu đã load rồi thì không load lại
            if (window[loadedKey] === true) {
                if (typeof onSuccessCallback === "function") {
                    onSuccessCallback(window[dataSourceKey] || []);
                }
                return;
            }

            // Kiểm tra nếu đang load thì đợi
            if (window[loadedKey] === "loading") {
                // Đợi một chút rồi thử lại
                setTimeout(function () {
                    loadDataSourceCommon(columnName, dataSourceSP, onSuccessCallback);
                }, 100);

                return;
            }


            // Đánh dấu đang load để tránh load trùng lặp
            window[loadedKey] = "loading";

            return new Promise((resolve, reject) => {
                AjaxHPAParadise({
                    data: {
                        name: dataSourceSP,
                        param: ["LoginID", LoginID, "LanguageID", LanguageID]
                    },
                    success: function (res) {
                        const json = typeof res === "string" ? JSON.parse(res) : res;

                        window[dataSourceKey] = (json.data && json.data[0]) || [];
                        window[loadedKey] = true;

                        // Ưu tiên lấy từ json response (nếu API trả về explicit)
                        // Sau đó mới fallback query dataSchema
                        let idField = json.valueExpr;
                        let nameField = json.displayExpr;

                        if (!idField || !nameField) {
                            if (json.dataSchema && json.dataSchema[0]) {
                                const schema = json.dataSchema[0];
                                if (!idField) idField = schema[0]?.name;
                                if (!nameField) nameField = schema[1]?.name;
                            }
                        }

                        window["DataSourceIDField_" + columnName] = idField || "ID";
                        window["DataSourceNameField_" + columnName] = nameField || "Name";

                        const data = window[dataSourceKey];

                        // callback trước
                        if (typeof onSuccessCallback === "function") {
                            onSuccessCallback(data, json);
                        }

                        // resolve sau
                        resolve(data);
                    },
                    error: function (err) {
                        console.error("[loadDataSourceCommon] Failed to load datasource for", columnName, ":", err);
                        window[loadedKey] = false;

                        if (typeof onSuccessCallback === "function") {
                            onSuccessCallback([]);
                        }

                        reject(err);
                    }
                });
            });
        }

        //InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56
        //FullNamePA7D7F5081185488CA62C1F211136902ARealInstance
        //EmailP3649C063B0674562BCCA3FB6B2F4DBF6RealInstance
        if (!document.getElementById("hpa-central-styles")) {
            $("<style>")
                .attr("id", "hpa-central-styles")
                .text(`
                    /* --- Base Styles --- */
                    .dx-widget { font-size:inherit!important; font-weight:inherit!important; line-height:inherit!important; border-radius:inherit!important; }
                    .dx-texteditor, .dx-texteditor-input { font-size:inherit!important; font-weight:inherit!important; line-height:inherit!important; box-sizing:border-box!important; }

                  /* --- Responsive & Popup Styles --- */
                    .hpa-responsive { max-width: 98vw !important; max-height: 98vh !important; }
                    .hpa-responsive .dx-popup-content { padding: 8px !important; display: flex !important; flex-direction: column !important; }
                    .hpa-responsive .dx-popup-content-scrollable { flex: 1 !important; min-height: 0 !important; overflow: auto !important; }

                    /* --- Grid Customizations --- */
                    .dx-datagrid-headers { white-space: normal; word-break: break-word; }
                    .dx-datagrid-header-panel { padding: 8px; }
                    .dx-datagrid .dx-row > td { padding: 8px !important; vertical-align: middle !important; }
                    .dx-datagrid-rowsview .dx-row > td > div { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; line-height: 1.4 !important; }

                    /* --- Search Styles --- */
                    .dx-datagrid-search-panel .dx-placeholder { display: none !important; }
                    .dx-datagrid-search-panel input:not(:placeholder-shown) { color: #000 !important; }

                  /* --- Avatar & Chip Styles --- */
                    .hpa-avatar-group { display: flex; alignItems: center; }
                    .hpa-avatar { border: 2px solid #fff; box-shadow: 0 2px 4px rgba(0,0,0,0.1); object-fit: cover; }
                `)
                .appendTo("head");
        }

        window.hpaUtils = window.hpaUtils || {
            removeToneMarks: function (str) {
                if (!str) return "";
                return RemoveToneMarks_Js(str);
            },
            highlightText: function (text, search) {
                if (!search || !text) return text;
                const regex = new RegExp("(" + search.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + ")", "gi");
                return text.replace(regex, "<mark class=\"bg-warning fw-bold px-1 rounded\">$1</mark>");
            },
            getInitials: function (name) {
                if (!name) return "?";
                const words = name.trim().split(/\s+/);
                if (words.length >= 2) return (words[0][0] + words[words.length - 1][0]).toUpperCase();

                return name.substring(0, 2).toUpperCase();
            },
            getColorForId: function (id) {
                const colors = [
                    { bg: "#e3f2fd", text: "#1976d2" },
                    { bg: "#f3e5f5", text: "#7b1fa2" },
                    { bg: "#e8f5e9", text: "#388e3c" },
                    { bg: "#fff3e0", text: "#f57c00" },
                    { bg: "#fce4ec", text: "#c2185b" }
                ];
                return colors[Math.abs(id) % colors.length];
            },
            loadAvatar: function (employeeId, storeImgName, paramImg, callbackFn) {
                window.GlobalEmployeeAvatarCache = window.GlobalEmployeeAvatarCache || {};
                window.GlobalEmployeeAvatarLoading = window.GlobalEmployeeAvatarLoading || {};

                const idStr = String(employeeId);
                if (window.GlobalEmployeeAvatarCache[idStr]) {
                    if (callbackFn) callbackFn(window.GlobalEmployeeAvatarCache[idStr]);
                    return window.GlobalEmployeeAvatarCache[idStr];
                }

                if (window.GlobalEmployeeAvatarLoading[idStr]) {
                    if (callbackFn) {
                        window.GlobalEmployeeAvatarLoading[idStr].callbacks = window.GlobalEmployeeAvatarLoading[idStr].callbacks || [];
                        window.GlobalEmployeeAvatarLoading[idStr].callbacks.push(callbackFn);
                    }
                    return null;
                }

                if (!storeImgName) return null;

                window.GlobalEmployeeAvatarLoading[idStr] = { loading: true, callbacks: callbackFn ? [callbackFn] : [] };

                let paramArray = [];
                if (paramImg) {
                    try { paramArray = JSON.parse(decodeURIComponent(paramImg)); } catch (e) { paramArray = []; }
                }

                AjaxHPAParadise({
                    data: { name: storeImgName, param: paramArray },
                    xhrFields: { responseType: "blob" },
                    cache: true,
                    success: function (blob) {
                        const callbacks = window.GlobalEmployeeAvatarLoading[idStr]?.callbacks || [];
                        delete window.GlobalEmployeeAvatarLoading[idStr];
                        if (blob && blob.size > 0) {
                            const url = URL.createObjectURL(blob);
                            window.GlobalEmployeeAvatarCache[idStr] = url;
                            callbacks.forEach(cb => { try { cb(url); } catch (e) { } });
                        } else {
                            callbacks.forEach(cb => { try { cb(null); } catch (e) { } });
                        }
                    },
                    error: function () {
                        const callbacks = window.GlobalEmployeeAvatarLoading[idStr]?.callbacks || [];
                        delete window.GlobalEmployeeAvatarLoading[idStr];
                        callbacks.forEach(cb => { try { cb(null); } catch (e) { } });
                    }
                });
                return null;
            }
        };
      
        '
            + (select loadUI from tblCommonControlType_Signed where UID = 'P82897F00F2844F529066CF6F15D3170B')
        +(select loadUI from tblCommonControlType_Signed where UID = 'P2D9DF38DBC46406C8EC1686058288F56')
        +(select loadUI from tblCommonControlType_Signed where UID = 'PA7D7F5081185488CA62C1F211136902A')
        +(select loadUI from tblCommonControlType_Signed where UID = 'P3649C063B0674562BCCA3FB6B2F4DBF6') +N'
        window.currentRecordID_EmployeeID = null;

        // =============== GRID COLUMN CONFIG PERSISTENCE ===============
        function saveGridColumnConfig(gridId, columns) {
            const menuId = getActiveMenuId();
            if (!menuId) {
                console.warn("Không lấy được menuId");
                return;
            }

            if (!gridId) {
                console.warn("gridId không hợp lệ");
                return;
            }

            const visibleColumns = columns
                .filter(col =>
                    col.visible !== false &&
                    col.dataField &&
                    col.dataField !== "rowIndex" &&
                    typeof col.dataField === "string"
                )
                .map(col => col.dataField);

            const columnOrder = columns
                .filter(col =>
                    col.dataField &&
                    col.dataField !== "rowIndex" &&
                    typeof col.dataField === "string"
                )
                .map(col => col.dataField);

            const config = { visibleColumns, columnOrder };

            console.log("[SaveConfig]", {
                menuId,
                gridId,
                config
            });

            AjaxHPAParadise({
                data: {
                    name: "sp_SaveGridColumnConfig",
                    param: [
                        "LoginID", LoginID,
                        "MenuID", menuId,
                        "GridID", gridId,
                        "ColumnConfigJson", JSON.stringify(config)
                    ]
                }
            });
        }

        function getActiveMenuId() {
            const activeTab = $(".nav-link.active");
            const tabId = activeTab.filter("button").attr("id");
            return tabId ? tabId.split("-").pop() : null;
        }

        function loadGridColumnConfig(gridId, callback) {
            const menuId = getActiveMenuId();
            if (!menuId) {
                console.warn("Không lấy được menuId");
                if (typeof callback === "function") callback({});
                return;
            }

            AjaxHPAParadise({
                data: {
                    name: "sp_GetGridColumnConfig",
                    param: [
                        "LoginID", LoginID,
                        "MenuID", menuId,
                        "GridID", gridId
                    ]
                },
                async: false,
                success: function (res) {
                    let config = {};

                    const json = typeof res === "string" ? JSON.parse(res) : res;

                    if (
                        json &&
                        json.data &&
                        json.data[0] &&
                        json.data[0][0] &&
                        json.data[0][0].ColumnConfigJson
                    ) {
                        const raw = json.data[0][0].ColumnConfigJson;
                        config = typeof raw === "string" ? JSON.parse(raw) : raw;
                    }

                    if (typeof callback === "function") {
                        callback(config);
                    }
                }
            });
        }

        // =============== FILTER STATE - LOCALSTORAGE ONLY ===============
        function saveGridFilterState(tableName, gridInstance) {
            try {
                const filterValue = gridInstance.getCombinedFilter();
                const searchValue = gridInstance.option("searchPanel.text") || "";

                // Lấy filter của từng cột
                const columnFilters = {};
                const columns = gridInstance.option("columns");

                columns.forEach(col => {
                    if (col.dataField && col.filterValue !== undefined) {
                        columnFilters[col.dataField] = {
                            filterValue: col.filterValue,
                            filterType: col.filterType || "include",
                            selectedFilterOperation: col.selectedFilterOperation
                        };
                    }
                });

                const filterState = {
                    combinedFilter: filterValue,
                    searchText: searchValue,
                    columnFilters: columnFilters,
                    timestamp: new Date().getTime()
                };

                // CHỈ LƯU VÀO LOCALSTORAGE
                localStorage.setItem("GridFilter_" + tableName + "_" + LoginID, JSON.stringify(filterState));
            } catch (e) {
                console.error("[SaveFilterState] Error:", e);
            }
        }

        function loadGridFilterState(tableName, gridInstance) {
            try {
                const storageKey = "GridFilter_" + tableName + "_" + LoginID;
                const savedState = localStorage.getItem(storageKey);

                if (!savedState) {
                    return null;
                }

                const filterState = JSON.parse(savedState);

                return filterState;
            } catch (e) {
                console.error("[LoadFilterState] Error:", e);
                return null;
            }
        }

        function applyGridFilterState(gridInstance, filterState) {

            if (!filterState) return;

            try {
                gridInstance.beginUpdate();

                // 1. Apply search text
                if (filterState.searchText) {
                    gridInstance.option("searchPanel.text", filterState.searchText);
                }

                // 2. Apply column filters
     if (filterState.columnFilters) {
                    Object.keys(filterState.columnFilters).forEach(dataField => {
                        const colFilter = filterState.columnFilters[dataField];
                        const colIndex = gridInstance.columnOption(dataField, "index");


                        if (colIndex !== undefined) {
                            gridInstance.columnOption(dataField, "filterValue", colFilter.filterValue);
                            if (colFilter.filterType) {
                                gridInstance.columnOption(dataField, "filterType", colFilter.filterType);
                            }
                            if (colFilter.selectedFilterOperation) {
                                gridInstance.columnOption(dataField, "selectedFilterOperation", colFilter.selectedFilterOperation);
                            }
                        }
                    });
                }

                // 3. Apply combined filter (fallback)
                if (filterState.combinedFilter && !filterState.columnFilters) {
                    gridInstance.option("filterValue", filterState.combinedFilter);
                }

                gridInstance.endUpdate();

            } catch (e) {
                console.error("[ApplyFilterState] Error:", e);
            }
        }

        function clearGridFilterState(tableName) {
            try {
                const storageKey = "GridFilter_" + tableName + "_" + LoginID;
                localStorage.removeItem(storageKey);
            } catch (e) {
                console.error("[ClearFilterState] Error:", e);
            }
        }

        // =============== ROW ORDER PERSISTENCE ===============
        function saveGridRowOrder(gridInstance, tableName, pkColumn) {
            const dataSource = gridInstance.option("dataSource");
            const rowOrderArray = dataSource.map(item => item[pkColumn]);

            AjaxHPAParadise({
                data: {
                    name: "sp_SaveGridRowOrder",
                    param: [
                        "LoginID", LoginID,
                        "TableName", tableName,
                        "RowOrderJson", JSON.stringify(rowOrderArray)
                    ]
                },
                success: function (res) { },
                error: function (err) {
                    console.error("[SaveRowOrder] Error:", err);
                }
            });
        }

        function loadGridRowOrder(tableName, dataSource, pkColumn, callback) {
            AjaxHPAParadise({
                data: {
                    name: "sp_GetGridRowOrder",
                    param: ["LoginID", LoginID, "TableName", tableName]
                },
                async: false,
                success: function (res) {
                    try {
                        const json = typeof res === "string" ? JSON.parse(res) : res;
                        const rowOrderJson = json.data[0][0].RowOrderJson;

                        if (rowOrderJson && rowOrderJson !== "[]") {
                            const savedOrder = JSON.parse(rowOrderJson);

                            const dataMap = {};
                            dataSource.forEach(item => {
                                dataMap[item[pkColumn]] = item;
                            });

                            const sortedData = [];
                            savedOrder.forEach(id => {
                                if (dataMap[id]) {
                                    sortedData.push(dataMap[id]);
                                    delete dataMap[id];
                                }
                            });

                            Object.values(dataMap).forEach(item => {
                                sortedData.push(item);
                            });

                            if (typeof callback === "function") {
                           callback(sortedData);
                            }
                        } else {
                            if (typeof callback === "function") {
                                callback(dataSource);
                            }
                        }
                    } catch (e) {
                        if (typeof callback === "function") {
                            callback(dataSource);
                        }
                    }
                },
                error: function (err) {
                    console.error("[LoadRowOrder] Error:", err);
                    if (typeof callback === "function") {
                        callback(dataSource);
                    }
                }
            });
        }

        // =============== MYWORK FILTER STATE PERSISTENCE ===============
        function saveFilterState(filterType) {
            try {
                localStorage.setItem("MyWork_Filter_" + LoginID, filterType);
            } catch (e) {
                console.error("[SaveFilterState] Error:", e);
            }
        }

        function loadFilterState() {
            try {
                const saved = localStorage.getItem("MyWork_Filter_" + LoginID);
                if (saved) {
                    return saved;
                }
            } catch (e) {
                console.error("[LoadFilterState] Error:", e);
            }
            return "all";
        }

        function applyFilter(filterType) {
            currentFilter = filterType;
            const gridInstance = "" // Instance%ColumnName%P82897F00F2844F529066CF6F15D3170B;

            if (!gridInstance) return;

            let filteredData = DataSource;

            if (filterType === "todo") {
                filteredData = DataSource.filter(data => data.Status === 1);
            } else if (filterType === "doing") {
                filteredData = DataSource.filter(data => data.Status === 2);
            } else if (filterType === "overdue") {
                const today = new Date();
                today.setHours(0, 0, 0, 0);
                filteredData = DataSource.filter(data => {
                    if (data.Status === 3) return false; // Exclude done datas
                    const deadlineDate = new Date(data.DeadlineDate);
                    return deadlineDate < today;
                });
            }
            // else filterType === "all" -> show all datas

            gridInstance.option("dataSource", filteredData);

            // Lưu filter vào localStorage
            saveFilterState(filterType);
        }

        function restoreFilterState() {
            const savedFilter = loadFilterState();
            currentFilter = savedFilter;

            // Cập nhật UI button
            $(".filter-btn").removeClass("active");
            $(`.filter-btn[data-filter="${savedFilter}"]`).addClass("active");

            // Áp dụng filter
            applyFilter(savedFilter);
        }


        window.currentRecordID_EmployeeID = null;

        function ReloadData(fromDate = null, toDate = null) {
            // Nếu không truyền tham số, lấy từ input filter
            // if (!fromDate) {
            //     fromDate = document.getElementById("emailFilterFromDate")?.value || "";
            // }
            // if (!toDate) {
            //     toDate = document.getElementById("emailFilterToDate")?.value || "";
            // }

            const employeeId = InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56?.option("value");

            AjaxHPAParadise({
                data: {
                    name: "sp_CRMListEmployeeEmailFollowKPI",
                    param: []
                },
                success: function (res) {
                    const json = typeof res === "string" ? JSON.parse(res) : res;
                    const results = Array.isArray(json?.data?.[0])
                        ? json.data[0]
                        : (json?.data?.[0] ? [json.data[0]] : []);

                    const obj = results.length === 1 ? results[0] : (results[0] || null);


                    const gridInstanceGridEmailKPIList = InstanceGridEmailKPIListP82897F00F2844F529066CF6F15D3170B;
                    const gridConfigGridEmailKPIList = window.getGridConfig_GridEmailKPIList(results);

                    loadGridRowOrder(
                        "sp_CRM_EmailKPIFollow_html",
                        results,
                        "EmployeeID",
                        function (sortedData) {
                            // Clear search panel khi reload
                            gridInstanceGridEmailKPIList.option("searchPanel.text", "");

                            gridInstanceGridEmailKPIList.beginUpdate();
                            gridInstanceGridEmailKPIList.option("scrolling", {
                                mode: "standard",
                                showScrollbar: "onHover"
                            });
                            gridInstanceGridEmailKPIList.option("remoteOperations", false);
                            gridInstanceGridEmailKPIList.option("paging.enabled", true);
                            gridInstanceGridEmailKPIList.option("paging.pageSize", gridConfigGridEmailKPIList.pageSize);
                            gridInstanceGridEmailKPIList.option("pager.allowedPageSizes", gridConfigGridEmailKPIList.allowedPageSizes);
                            gridInstanceGridEmailKPIList.pageIndex(0);
                            gridInstanceGridEmailKPIList.option("dataSource", sortedData);

                            gridInstanceGridEmailKPIList.endUpdate();

                            // RESTORE FILTER STATE T? LOCALSTORAGE (n?u không skip)
                            setTimeout(function () {
                                if (window._SkipRestoreFilter) {
                                    window._SkipRestoreFilter = false;
                                    return;
                                }
                                const savedFilter = loadGridFilterState("sp_CRM_EmailKPIFollow_html", gridInstanceGridEmailKPIList);
                                if (savedFilter) {
                                    applyGridFilterState(gridInstanceGridEmailKPIList, savedFilter);
                                }
                            }, 100);
                        }
                    );

                    if (obj) { window.currentRecordID_EmployeeID = (obj.EmployeeID !== undefined && obj.EmployeeID !== null) ? obj.EmployeeID : window.currentRecordID_EmployeeID; }
                    DataSource = results;
                    '
                        + (select loadData from tblCommonControlType_Signed where UID = 'P82897F00F2844F529066CF6F15D3170B')
                + N'
            if (typeof restoreFilterState === "function") {
                restoreFilterState();
            }
        }
    })
            }

    ReloadData();

    // Set default dates (today and 30 days ago)
    // function setDefaultDates() {
    //     const today = new Date();
    //     const thirtyDaysAgo = new Date(today.getTime() - (30 * 24 * 60 * 60 * 1000));

    //     const formatDate = (date) => {
    //         const year = date.getFullYear();
    //         const month = String(date.getMonth() + 1).padStart(2, ''0'');
    //         const day = String(date.getDate()).padStart(2, ''0'');
    //         return `${year}-${month}-${day}`;
    //     };

    //     document.getElementById("emailFilterFromDate").value = formatDate(thirtyDaysAgo);
    //     document.getElementById("emailFilterToDate").value = formatDate(today);
    // }
    // setDefaultDates();

    // Event listeners for filter buttons
    document.getElementById("btnEmailFilter")?.addEventListener("click", function () {
 ReloadData();
    });

    document.getElementById("btnEmailReset")?.addEventListener("click", function () {
        setDefaultDates();
        if (InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56) {
            InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56.option("value", null);
        }
        ReloadData();
    });

    // Event listener for Add button
    //document.getElementById("btnAddEmail")?.addEventListener("click", function () {
    //  openDetailEmployeeID(null);
    //});

    // Global function to open email modal
    function openDetailEmployeeID(obj) {
        const modalTitle = document.getElementById("emailModalTitle");

        if (obj) {
            InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56.option("disabled", true);
            // Edit mode
            if (modalTitle) {
                modalTitle.textContent = "Chỉnh sửa Email";
            }

            //_autoSaveFullNamePA7D7F5081185488CA62C1F211136902A = true;
            //_autoSaveEmailP3649C063B0674562BCCA3FB6B2F4DBF6 = true;

            // Load data into form controls
            if (InstanceFullNamePA7D7F5081185488CA62C1F211136902A) {
                InstanceFullNamePA7D7F5081185488CA62C1F211136902A.option("value", obj.FullName || "");
            }
            if (InstanceEmailP3649C063B0674562BCCA3FB6B2F4DBF6) {
                InstanceEmailP3649C063B0674562BCCA3FB6B2F4DBF6.option("value", obj.Email || "");
            }

            window.currentRecordID_EmployeeID = obj.EmployeeID;

            '+ (select loadData from tblCommonControlType_Signed where UID = 'P2D9DF38DBC46406C8EC1686058288F56')
                + (select loadData from tblCommonControlType_Signed where UID = 'PA7D7F5081185488CA62C1F211136902A')
            +(select loadData from tblCommonControlType_Signed where UID = 'P3649C063B0674562BCCA3FB6B2F4DBF6') + N'
        } else {
            InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56.option("disabled", false);
            // Add mode
            if (modalTitle) {
                modalTitle.textContent = "Thêm Email mới";
            }

            //_autoSaveFullNamePA7D7F5081185488CA62C1F211136902A = false;
            //_autoSaveEmailP3649C063B0674562BCCA3FB6B2F4DBF6 = false;

            // Clear form controls
            if (InstanceFullNamePA7D7F5081185488CA62C1F211136902A) {
                InstanceFullNamePA7D7F5081185488CA62C1F211136902A.option("value", "");
            }
            if (InstanceEmailP3649C063B0674562BCCA3FB6B2F4DBF6) {
                InstanceEmailP3649C063B0674562BCCA3FB6B2F4DBF6.option("value", "");
            }

            window.currentRecordID_EmployeeID = null;
        }

        // Open modal
        const emailModal = document.getElementById("emailModal");
        if (emailModal) {
            if (typeof bootstrap !== ''undefined'' && bootstrap.Modal) {
                const modal = new bootstrap.Modal(emailModal);
                modal.show();
            } else {
                emailModal.classList.add(''show'');
                emailModal.style.display = ''block'';
                document.body.classList.add(''modal-open'');
            }
        }
    };

    // Event listener for Save button
    document.getElementById("btnSaveEmail")?.addEventListener("click", function () {
        const fullName = InstanceFullNamePA7D7F5081185488CA62C1F211136902A?.option("value");
        const email = InstanceEmailP3649C063B0674562BCCA3FB6B2F4DBF6?.option("value");
        const employeeId = InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56?.option("value");

        if (!fullName) {
            uiManager.showAlert({ type: "error", message: "%RequiredFieldsError%", messageId: "RequiredFieldsError" });
            return;
        }
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

const normalizedEmail = email
    ?.replace(/\u00A0/g, '''')   // bỏ space đặc biệt khi copy
    .replace(/\s+/g, '''')      // bỏ mọi khoảng trắng
    .trim();

if (normalizedEmail && !emailRegex.test(normalizedEmail)) {
    uiManager.showAlert({
        type: "error",
        message: "%InvalidEmailFormat%",
        messageId: "InvalidEmailFormat"
    });
    return;
}


        AjaxHPAParadise({
            data: {
                name: "sp_AddEmailProperty",
                param: [
                    "EmployeeEmail", email || "",
                    "EmployeeID", employeeId,
                    "FullName", fullName || "",
                ]
            },
            success: function (data) {
                if (typeof data == "string" && !IsNullOrEmpty(data)) {
                    data = data.includes("{") ? data : EncryptionStringDecryption(data);
                }
                let dataObj = JSON.parse(data);
                let newData = dataObj.data[0];
                if (newData && newData.length > 0) {
                    let results = newData[0].Result;
                    if (results == ''SUCCESS'') {
                        ReloadData();
                        uiManager.showAlert({ type: "success", message: "%SaveEmailSuccess%", messageId: "SaveEmailSuccess" });
                        // Close modal
                        const emailModal = document.getElementById("emailModal");
                        if (emailModal) {
                            if (typeof bootstrap !== ''undefined'' && bootstrap.Modal) {
                                const modal = bootstrap.Modal.getInstance(emailModal);
                                if (modal) {
                                    modal.hide();
                                }
                            } else {
                                emailModal.classList.remove(''show'');
                                emailModal.style.display = ''none'';
                                document.body.classList.remove(''modal-open'');
                            }
                        }
                    } else {
                        uiManager.showAlert({ type: "error", message: "%SaveEmailFailed%", messageId: "SaveEmailFailed" });
                    }
                }
            }
        })
    });

        }) ();
</script>
	'

    SELECT @html AS html;
	-- exec sptblCommonControlType_Signed_Duc 'sp_CRM_EmailKPIFollow_html'
    -- EXEC sp_GenerateHTMLScript_new 'sp_CRM_EmailKPIFollow_html'
    -- EXEC sp_GenerateHTMLScript 'sp_Dashboard_Mobile_beta'
END
GO

/*--------------------------------------------------------------------------------------------------
  THỦ TỤC GỐC [2/2]: [dbo].[sp_CRM_EmailKPIFollow]
--------------------------------------------------------------------------------------------------*/
create   PROCEDURE [dbo].[sp_CRM_EmailKPIFollow](
@LoginID int,
@LanguageID varchar(5) = 'VN'
)
as
begin
	select top 1 html from tblHtmlScriptCache where TableName = 'sp_CRM_EmailKPIFollow_html' and ScreenType = -1 and LanguageID = @LanguageID;
end
GO

