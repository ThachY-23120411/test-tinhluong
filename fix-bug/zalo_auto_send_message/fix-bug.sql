USE [Vietinsoft_ForTest_Tai2];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*-------------------------------------------------------------------
 BƯỚC 1: CẬP NHẬT MÃ NGUỒN GIAO DIỆN SP_ZALO_AUTOSENDMESSAGE_HTML
 (Chứa toàn bộ mã nguồn HTML/CSS/JS đã sửa lỗi hiển thị màu chữ ô tìm kiếm)
--------------------------------------------------------------------*/
ALTER PROCEDURE [dbo].[sp_zalo_autoSendMessage_html]
    @LoginID INT = 3,
    @LanguageID VARCHAR(2) = 'VN',
    @isWeb int = 0
AS
-- taidang
BEGIN
    SET NOCOUNT ON;
    DECLARE @limitUnknown INT = ISNULL((SELECT CAST(Value AS INT) FROM tblParameter WHERE Code = 'zaloMaxSpamRequest_UnknownGuest'), 30);
    DECLARE @limitFriend INT = ISNULL((SELECT CAST(Value AS INT) FROM tblParameter WHERE Code = 'zaloMaxSpamRequest_friendAndGroup'), 50);
    DECLARE @msgsPerDayText NVARCHAR(50) = ISNULL(dbo.fn_GetMessage('zalo_msgs_per_day', @LanguageID, ''), N'');
    DECLARE @limitTitle NVARCHAR(100) = ISNULL(dbo.fn_GetMessage('zalo_auto_send_limit', @LanguageID, ''), N'');
    DECLARE @html nvarchar(max)
    SET @html = N'
        <style>
            @import url(''https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap'');
            .sp_zalo_autoSendMessage {
                font-family: ''Inter'', sans-serif !important;
                display: flex;
                flex-direction: column;
                gap: 20px;
                height: 88vh;
                box-sizing: border-box;
            }
            .zalo-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            .zalo-title h1 {
                margin: 0;
                font-size: 24px;
                font-weight: 700;
            }
            .zalo-title p {
                margin: 4px 0 0 0;
                font-size: 14px;
            }
            .zalo-export-btn {
                display: flex;
                align-items: center;
                gap: 8px;
                padding: 8px 16px;
                border-radius: 8px;
                color: #334155;
                font-size: 14px;
                font-weight: 500;
                cursor: pointer;
                box-shadow: 0 1px 2px rgba(0,0,0,0.05);
                transition: all 0.2s;
            }
            .zalo-export-btn:hover {
                background: #f8fafc;
                border-color: #cbd5e1;
            }
            /* Custom Tabs */
            .zalo-tabs {
                display: flex;
                justify-content: space-between;
                align-items: flex-end;
                border-bottom: 1px solid #e2e8f0;
                padding-bottom: 0px;
                margin-top: 10px;
            }
            .zalo-tab-item {
                font-size: 15px;
                font-weight: 500;
                padding-bottom: 12px;
                cursor: pointer;
                position: relative;
                display: flex;
                align-items: center;
                gap: 8px;
                transition: color 0.2s;
            }
            .zalo-tab-item:hover {
            }
            .zalo-tab-item.active {
                color: var(--bs-success);
                font-weight: 600;
            }
            .zalo-tab-item.active::after {
                content: '''';
                position: absolute;
                bottom: 0;
                left: 0;
                right: 0;
                height: 2px;
                background: var(--bs-success);
                border-radius: 2px;
            }
            .zalo-tab-badge {
                background: var(--bs-secondary-bg);
                color: var(--bs-secondary-color);
                padding: 1px 6px;
                border-radius: 10px;
                font-size: 11px;
                font-weight: 600;
            }
            .zalo-tab-item.active .zalo-tab-badge {
                background: var(--bs-success);
                color: var(--bs-body-bg);
            }
            /* Grid Styling overrides */
            #GridZalo {
                /* background: #ffffff; */
                border-radius: 12px;
             /* border: 1px solid #e2e8f0; */
                box-shadow: 0 1px 3px rgba(0,0,0,0.02);
                overflow: hidden;
            }
            /* ====== Header: chống wrap và ẩn filter icon khi chưa dùng ====== */
            #GridZalo .dx-header-row > td {
                vertical-align: middle !important;
                font-size: 12px !important;
                padding: 14px 16px !important; /* Đồng bộ padding ngang với body để không bị lệch cột */
                white-space: nowrap !important;
            }

            /* Text content: cho phép co lại nhưng không phá vỡ layout gốc của grid */
            #GridZalo .dx-header-row > td .dx-datagrid-text-content {
                white-space: nowrap !important;
                overflow: hidden !important;
                text-overflow: ellipsis !important;
                min-width: 0 !important;
            }

            /* Ẩn icon filter nếu chưa lọc (empty), chỉ hiện khi hover chuột vào ô header */
            #GridZalo .dx-header-row > td .dx-header-filter-empty {
                opacity: 0 !important;
                pointer-events: none !important;
                transition: opacity 0.2s ease !important;
            }

            #GridZalo .dx-header-row > td:hover .dx-header-filter-empty {
                opacity: 1 !important;
                pointer-events: auto !important;
            }
            /* ====== End Header fix ====== */
            #GridZalo .dx-datagrid-table .dx-row > td {
                vertical-align: middle !important;
                border-bottom: 1px solid #f1f5f9 !important;
                padding: 14px 16px !important;
            }
            #GridZalo .dx-data-row {
                height: 64px !important;
            }
            #GridZalo .dx-data-row:hover {
                background-color: #f8fafc !important;
            }
            #GridZalo .dx-selection {
                background-color: #eff6ff !important;
            }
            /* Status Badges */
            .badge-status {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 4px 10px;
                border-radius: 9999px;
                font-size: 12px;
                font-weight: 500;
            }
            .badge-status.active {
                background-color: #ecfdf5;
                color: #047857;
            }
            .badge-status.offline {
                background-color: #f1f5f9;
            }
            .badge-status.busy {
                background-color: #fffbeb;
                color: #b45309;
            }
            /* Platform Badges */
            .badge-platform {
                display: inline-flex;
                align-items: center;
                padding: 2px 8px;
                border-radius: 4px;
                font-size: 11px;
                font-weight: 600;
                background-color: #e0f2fe;
                color: #0369a1;
            }
            .badge-platform.facebook {
                background-color: #eff6ff;
                color: #1d4ed8;
            }
            /* ====== FIX SEARCH FILTER CONTRAST & PADDING (TC-01, SCREENSHOT 25 & RESPONSIVE) ====== */
            .sp_zalo_autoSendMessage .dx-datagrid-search-panel,
            .dx-datagrid-search-panel {
                margin-right: 0px !important;
                background-color: #1e293b !important;
                border: 1px solid #334155 !important;
                border-radius: 6px !important;
                width: 240px !important;
                min-width: 200px !important;
            }
            .sp_zalo_autoSendMessage .dx-datagrid-search-panel.dx-state-focused,
            .dx-datagrid-search-panel.dx-state-focused {
                border-color: #3b82f6 !important;
                box-shadow: 0 0 0 1px #3b82f6 !important;
            }
            /* Cố định padding-left 34px chống lỗi icon kính lúp đè lên text khi màn hình co nhỏ (<= 768px) */
            .sp_zalo_autoSendMessage .dx-datagrid-search-panel .dx-texteditor-input,
            .sp_zalo_autoSendMessage #GridZalo .dx-searchbox .dx-texteditor-input,
            .dx-datagrid-search-panel .dx-texteditor-input {
                color: #ffffff !important;
                -webkit-text-fill-color: #ffffff !important;
                background-color: transparent !important;
                font-size: 13px !important;
                padding-left: 34px !important;
                padding-inline-start: 34px !important;
                padding-right: 30px !important;
            }
            .sp_zalo_autoSendMessage .dx-datagrid-search-panel .dx-texteditor-input:focus,
            .dx-datagrid-search-panel .dx-texteditor-input:focus {
                color: #ffffff !important;
                -webkit-text-fill-color: #ffffff !important;
                background-color: transparent !important;
            }
            .sp_zalo_autoSendMessage .dx-datagrid-search-panel .dx-placeholder,
            .sp_zalo_autoSendMessage .dx-datagrid-search-panel .dx-placeholder::before,
            .sp_zalo_autoSendMessage #GridZalo .dx-searchbox .dx-placeholder::before,
            .dx-datagrid-search-panel .dx-placeholder,
            .dx-datagrid-search-panel .dx-placeholder::before {
                color: #94a3b8 !important;
                padding-left: 34px !important;
                padding-inline-start: 34px !important;
            }
            .sp_zalo_autoSendMessage .dx-datagrid-search-panel .dx-icon-search,
            .sp_zalo_autoSendMessage .dx-datagrid-search-panel .dx-clear-button-area .dx-icon-clear,
            .dx-datagrid-search-panel .dx-icon-search,
            .dx-datagrid-search-panel .dx-clear-button-area .dx-icon-clear {
                color: #94a3b8 !important;
            }
            .dx-tabpanel .dx-inkripple {
                display: none !important;
            }
            #GridZalo .dx-datagrid-rowsview .dx-row > td > div {
                display: flex;
                justify-content: start;
                align-items: center;
                gap: 1rem;
            }
            /* Hỗ trợ align center cho div bên trong khi cột được cấu hình alignment: center */
            #GridZalo .dx-datagrid-rowsview .dx-row > td[style*="text-align: center"] > div,
            #GridZalo .dx-datagrid-rowsview .dx-row > td[style*="text-align: center;"] > div {
                justify-content: center !important;
                width: 100%;
            }
        
            /* ====== RESPONSIVE RULES (CHUẨN 9 QUY TẮC CỐT LÕI) ====== */
            /* 1. Khung chứa chính: Khóa biên khung nhìn (Quy tắc 8) */
            .sp_zalo_autoSendMessage {
                min-width: 0 !important;
                max-width: 100% !important;
                overflow-x: hidden !important;
                height: calc(100vh - 110px) !important;
            }

            /* 2. Tabs Bar: Tự thích ứng rớt dòng khi màn hình co hẹp (Quy tắc 3 & 6) */
            .sp_zalo_autoSendMessage .zalo-tabs {
                display: flex !important;
                flex-wrap: wrap !important;
                align-items: center !important;
                justify-content: space-between !important;
                row-gap: 8px !important;
                column-gap: 12px !important;
                padding-bottom: 8px !important;
                border-bottom: 1px solid var(--bs-border-color, #334155) !important;
            }
            .sp_zalo_autoSendMessage .zalo-tabs > div:first-child {
                display: flex !important;
                flex-wrap: wrap !important;
                gap: 16px !important;
                flex: 0 0 auto !important;
            }
            .sp_zalo_autoSendMessage .zalo-tab-item {
                flex-shrink: 0 !important;
                white-space: nowrap !important;
                padding-bottom: 4px !important;
            }
            .sp_zalo_autoSendMessage .zalo-tabs > div:last-child {
                margin-left: auto !important;
                flex-shrink: 0 !important;
                white-space: nowrap !important;
                padding-bottom: 4px !important;
            }

            /* 3. Toolbar Header Panel: Tự co giãn theo dòng (Quy tắc 11 - Không che khuất DataGrid) */
            #GridZalo .dx-datagrid-header-panel {
                height: auto !important;
                min-height: 48px !important;
                padding: 4px 0 !important;
                overflow: visible !important;
            }
            #GridZalo .dx-datagrid-header-panel .dx-toolbar {
                height: auto !important;
                min-height: 48px !important;
                background: transparent !important;
            }
            #GridZalo .dx-toolbar-items-container {
                height: auto !important;
                min-height: 48px !important;
                display: flex !important;
                flex-wrap: wrap !important;
                align-items: center !important;
                row-gap: 8px !important;
                column-gap: 8px !important;
                width: 100% !important;
                padding: 0 !important;
            }

            /* 4. Đưa dx-toolbar-before và dx-toolbar-after về Normal Flow (Đánh sập position: absolute ngầm) */
            #GridZalo .dx-toolbar-before {
                position: static !important;
                display: flex !important;
                flex-wrap: wrap !important;
                align-items: center !important;
                gap: 8px !important;
                height: auto !important;
                width: auto !important;
                max-width: 100% !important;
                float: none !important;
                padding: 0 !important;
                margin: 0 !important;
            }
            #GridZalo .dx-toolbar-before .d-flex {
                flex-wrap: wrap !important;
                gap: 8px !important;
                margin-right: 0 !important;
                padding-bottom: 0 !important;
            }

            /* 5. Khóa nguyên tử các dropdown trong toolbar (Quy tắc 7) */
            #GridZalo #Toolbar_SelectBox_Placeholder {
                width: 200px !important;
                flex: 0 0 auto !important;
                flex-shrink: 0 !important;
            }
            #GridZalo #Toolbar_Quantity_Placeholder {
                width: 100px !important;
                flex: 0 0 auto !important;
                flex-shrink: 0 !important;
            }
            #GridZalo #Toolbar_AIMenu_Placeholder {
                width: 170px !important;
                flex: 0 0 auto !important;
                flex-shrink: 0 !important;
            }

            /* 6. Cụm Action & Tìm kiếm bên phải: bám sát lề phải & gộp dòng khi co màn hình (Quy tắc 6) */
            /* Khóa hiển thị nút Chọn cột hiển thị (Column Chooser), chống bị DevExtreme ẩn vào menu 3 chấm (locateInMenu: never) */
            #GridZalo .dx-toolbar .dx-toolbar-item.dx-toolbar-item-auto-hide,
            #GridZalo .dx-toolbar .dx-toolbar-item.dx-toolbar-item-invisible,
            #GridZalo .dx-toolbar .dx-datagrid-column-chooser-button {
                display: inline-flex !important;
                visibility: visible !important;
            }
            #GridZalo .dx-toolbar .dx-toolbar-item-invisible .dx-item-content {
                display: inline-flex !important;
                visibility: visible !important;
            }
            /* Ẩn nút 3 chấm menu overflow không cần thiết */
            #GridZalo .dx-toolbar-menu-container {
                display: none !important;
            }
            #GridZalo .dx-toolbar-after {
                position: static !important;
                display: flex !important;
                align-items: center !important;
                gap: 8px !important;
                margin-left: auto !important;
                margin-right: 0 !important;
                height: auto !important;
                width: auto !important;
                float: none !important;
                padding: 0 !important;
            }
            #GridZalo .dx-toolbar-after .dx-toolbar-item {
                flex: 0 0 auto !important;
            }

            /* 7. Cô lập cuộn Bảng dữ liệu lớn (Quy tắc 9) */
            #GridZalo {
                width: 100% !important;
                max-width: 100% !important;
                min-width: 0 !important;
            }
            #GridZalo .dx-datagrid-rowsview {
                width: 100% !important;
                max-width: 100% !important;
                overflow-x: auto !important;
                -webkit-overflow-scrolling: touch !important;
            }
        </style>
        <div class="sp_zalo_autoSendMessage">
            <!-- Header section -->
            <div class="zalo-header" style="display: none !important;">
                <div class="zalo-title">
                    <h1>%zalo_title%</h1>
                    <p>%zalo_subtitle%</p>
                </div>
                <button class="zalo-export-btn" id="btnExportZalo">
                    <i class="dx-icon dx-icon-export"></i> Export
                </button>
            </div>
            <!-- Tabs section -->
            <div class="zalo-tabs">
                <div style="display: flex; gap: 24px;">
                    <div class="zalo-tab-item active" id="tab-friends">
                        %zalo_tab_friends% <span class="zalo-tab-badge" id="badge-friends-count">0</span>
                    </div>
                    <div class="zalo-tab-item" id="tab-groups">
                        %zalo_tab_groups% <span class="zalo-tab-badge" id="badge-groups-count">0</span>
                    </div>
                    <div class="zalo-tab-item" id="tab-invites">
                        %zalo_tab_strangers% <span class="zalo-tab-badge" id="badge-invites-count">0</span>
                    </div>
                </div>
                <div style="font-size: 13px; color: var(--bs-warning); padding-bottom: 12px; display: flex; align-items: center; gap: 6px; cursor: help;" title="' + @limitTitle + '">
                    <i class="dx-icon dx-icon-warning" style="font-size: 16px;"></i>
                    <span>%zalo_tab_friends%/%zalo_tab_groups%: <b style="color: #f97316;">' + CAST(@limitFriend AS NVARCHAR) + ' ' + @msgsPerDayText + '</b>, %zalo_tab_strangers%: <b style="color: #f97316;">' + CAST(@limitUnknown AS NVARCHAR) + ' ' + @msgsPerDayText + '</b></span>
                </div>
            </div>
            <!-- Grid view -->
            <div id="GridZalo" style="flex: 1;"></div>
            <!-- Hidden controls for temp templates -->
            <div id="SelectBoxContainer_Temp" style="display:none">
                <div id="P36EB8FEA286C46F7A109BD6404CA9BAA"></div>
                <div id="PC3ECBD81231B40B294775F6A0D74C861"></div>
                <div id="PBE6706C7F3944933A71F067C581E0677"></div>
            </div>
        </div>
    '
    SET @html = @html + N'
    <script>
      (async () => {
            let api = true;
            let DataSource = [];
            let _pageCache = {};
            let _currentKeyword = "";
            let dataStore_GridZalo = null;
            let obj = null;
            let friendAvatarMap = {};
            let globalZaloNameMap = {};
            let P36EB8FEA286C46F7A109BD6404CA9BAA_data = []; // Chọn phần mềm (Tag)
            let PC3ECBD81231B40B294775F6A0D74C861_data = []; // Số luợng
            let PBE6706C7F3944933A71F067C581E0677_data = []; // AI Menu
            // Biến quản lý trạng thái chọn dòng thủ công (Custom Selection)
            let customSelectedKeys_GridZalo = [];
            window.customSelectedKeys_GridZalo = customSelectedKeys_GridZalo;
            function setCustomSelectedKeys_GridZalo(keys) {
                customSelectedKeys_GridZalo = Array.isArray(keys) ? keys : [];
                window.customSelectedKeys_GridZalo = customSelectedKeys_GridZalo;
            }
            function getZaloRowKey(rowData, fallbackKey) {
                let rawKey = rowData ? (rowData.zaloID || rowData.ZaloID || rowData.uid || rowData.ID || "") : "";
                if (!rawKey && fallbackKey && typeof fallbackKey !== "object") rawKey = fallbackKey;
                return rawKey ? rawKey.toString() : "";
            }
            let isSelectAllActive_GridZalo = false;
            let _currentTagID = "";
            // Lưu trữ ID phần mềm đang chọn lọc
            // Biến quản lý lịch sử các lượt test AI
            let aiHistory_Log = []; // Array of { timestamp: "HH:mm:ss", prompt: "...", results: {...} }
            '
                +ISNULL((select loadUI from tblCommonControlType_Signed where UID = 'P573D5BF0C93B424BA49F7C7FE5871D8B'), '')
                +ISNULL((select loadUI from tblCommonControlType_Signed where UID = 'P36EB8FEA286C46F7A109BD6404CA9BAA'), '')
                +ISNULL((select loadUI from tblCommonControlType_Signed where UID = 'PC3ECBD81231B40B294775F6A0D74C861'), '')
                +ISNULL((select loadUI from tblCommonControlType_Signed where UID = 'PBE6706C7F3944933A71F067C581E0677'), '')
            +N'

            function openAutoSpamConfigPopup() {
                let $popup = $("<div />").appendTo("body");
                $popup.dxPopup({
                    title: "%zalo_config_auto_spam_title%",
                    width: 400,
                    height: "auto",
                    dragEnabled: true,
                    closeOnOutsideClick: true,
                    showCloseButton: true,
                    onHidden: function() { $popup.remove(); },
                    contentTemplate: function(contentElement) {
                        let $wrap = $("<div style=''padding: 10px; display: flex; flex-direction: column; gap: 15px;'' />").appendTo(contentElement);

                        let $form = $("<div>").appendTo($wrap);
                        $form.dxForm({
                            formData: { GroupInterval: 240, FriendInterval: 1 },
                            items: [
                                {
                                    dataField: "GroupInterval",
                                    editorType: "dxNumberBox",
                                    label: { text: "%zalo_config_group_interval%" },
                                    editorOptions: { min: 1, showSpinButtons: true }
                                },
                                {
                                    dataField: "FriendInterval",
                                    editorType: "dxNumberBox",
                                    label: { text: "%zalo_config_personal_interval%" },
                                    editorOptions: { min: 1, showSpinButtons: true }
                                }
                            ]
                        });

                        AjaxHPAParadise({
                            data: {
                                name: "sp_zalo_getAutoSpamConfig",
                                param: ["LoginID", UserID]
                            },
                            success: function(res) {
                                let json = typeof res === "string" ? JSON.parse(res) : res;
                                if (json && json.data && json.data[0] && json.data[0][0]) {
                                    $form.dxForm("instance").option("formData", {
                                        GroupInterval: json.data[0][0].GroupInterval || 240,
                                        FriendInterval: json.data[0][0].FriendInterval || 1
                                    });
                                }
                            }
                        });

                        $("<div style=''display: flex; justify-content: flex-end;'' />")
                            .append(
                                $("<div />").dxButton({
                                    text: "%zalo_config_save%",
                                    type: "success",
                                    icon: "save",
                                    onClick: function() {
                                        let data = $form.dxForm("instance").option("formData");
                                        AjaxHPAParadise({
                                            data: {
                                                name: "sp_zalo_saveAutoSpamConfig",
                                                param: ["LoginID", UserID, "GroupInterval", data.GroupInterval, "FriendInterval", data.FriendInterval]
                                            },
                                            success: function(res) {
                                                if (window.uiManager) uiManager.showAlert({ type: "success", message: "%zalo_config_save_success%" });
                                                $popup.dxPopup("instance").hide();
                                            }
                                        });
                                    }
                                })
                            ).appendTo($wrap);
                    }
                }).dxPopup("instance").show();
            }

            function openSetAutoPopup() {
                let $popup = $("<div />").appendTo("body");
                let $innerWrap = $("<div style=''height:100%; display:flex; flex-direction:column; gap:10px;'' />");
                // ====== Nút Thêm lịch mới ======
                let $topBar = $("<div style=''display:flex; justify-content:flex-end;'' />").appendTo($innerWrap);
                let $listWrap = $("<div style=''flex:1; overflow:auto;'' />").appendTo($innerWrap);
                let $dxList = $("<div />").appendTo($listWrap);
                // ====== Load danh sách lịch đã tạo ======
                function loadScheduleList() {
                    AjaxHPAParadise({
                        data: {
                            name: "sp_zalo_createAI_TaskSchedule",
                            param: ["LoginID", UserID, "LanguageID", LanguageID, "ActionType", "SELECT"]
                        },
                        success: function(res) {
                            let json = typeof res === "string" ? JSON.parse(res) : res;
                            let data = (json.data && json.data[0]) ? json.data[0] : [];
                            $dxList.empty();
                            if (data.length === 0) {
                                $dxList.html("<div style=''color:var(--bs-secondary-color); text-align:center; padding:30px;''>%zalo_schedule_empty%</div>");
                                return;
                            }
                            data.forEach(function(row) {
                                let statusIcon = row.IsActive ? "&#9989;" : "&#9898;";
                                let nextRunDisplay = row.NextRunDate ? row.NextRunDate.replace("T", " ").substring(0, 16) : "";
         let taskNameDisplay = row.TaskName || row.TaskScheduleName || "";
                                let productBadge = row.ProductName ? " <span style=''background:rgba(var(--bs-success-rgb), 0.15); color:var(--bs-success); border-radius:4px; padding:1px 7px; font-size:11px; margin-left:4px;''>" + row.ProductName + "</span>" : "";
                                let recipientCount = row.Param ? row.Param.split(",").length : 0;
                                let recipientBadge = "<span style=''color:var(--bs-secondary-color); font-size:11px; margin-left:6px;''>&#128101; " + recipientCount + " %zalo_schedule_recipient_members%</span>";
                                let $item = $("<div style=''padding:10px 5px; border-bottom:1px solid var(--bs-border-color);'' />");
                                let $left = $("<div style=''display:flex; flex-direction:column; gap:3px;'' />");
                                let statusText = row.IsActive ? "%zalo_schedule_status_on%" : "%zalo_schedule_status_off%";
                                let statusBg = row.IsActive ? "rgba(var(--bs-success-rgb), 0.15)" : "var(--bs-secondary-bg)";
                                let statusColor = row.IsActive ? "var(--bs-success)" : "var(--bs-secondary-color)";
                                let $statusBtn = $("<div style=''cursor:pointer; border-radius:20px; padding:4px 10px; font-size:11px; font-weight:bold; background:" + statusBg + "; color:" + statusColor + "; display:flex; align-items:center; gap:4px;'' title=''" + (row.IsActive ? "%zalo_schedule_toggle_on%" : "%zalo_schedule_toggle_off%") + "''>" + statusText + "</div>");
                                $statusBtn.click(function() {
                                    AjaxHPAParadise({
                                        data: {
                                            name: "sp_zalo_createAI_TaskSchedule",
                                            param: ["LoginID", UserID, "LanguageID", LanguageID, "ActionType", "TOGGLE_ACTIVE", "TaskScheduleID", row.IDTask || ""]
                                        },
                                        success: function() { loadScheduleList(); },
                                        error: function() { if (window.uiManager) uiManager.showAlert({ type: "error", message: "%zalo_schedule_toggle_error%" }); }
                                    });
                                });
                                let $titleLine = $("<div style=''display:flex; align-items:center;'' />").append($("<b>" + taskNameDisplay + "</b>" + productBadge + recipientBadge));
                                $left.append($titleLine);
                                let typeMap = { "0": "%zalo_schedule_once%", "1": "%zalo_schedule_hour%", "2": "%zalo_schedule_day%", "3": "%zalo_schedule_week%", "4": "%zalo_schedule_month%", "5": "%zalo_schedule_year%" };
                                let typeDisplay = typeMap[row.TaskType] || row.TaskType || "";
                                $left.append($("<div />").html("<span style=''color:var(--bs-secondary-color); font-size:11px;''>" + typeDisplay + " &bull; %zalo_schedule_next_run%: " + nextRunDisplay + "</span>"));
                                let $rightWrap = $("<div style=''display:flex; align-items:center; gap:6px;'' />");
                                $item.append($("<div style=''display:flex; justify-content:space-between; align-items:center;'' />").append($left).append($rightWrap));
                                let $edit = $("<div />").dxButton({
                                    icon: "edit", type: "normal", stylingMode: "outlined", hint: "%zalo_schedule_edit_hint%",
                                    onClick: function() {
                                        openAddForm(row);
                                    }
                                });
                                let $del = $("<div />").dxButton({
         icon: "trash", type: "danger", stylingMode: "outlined", hint: "%zalo_schedule_delete_hint%",
                                    onClick: function() {
                                        DevExpress.ui.dialog.confirm("<i>%zalo_schedule_delete_confirm_msg%</i>", "%zalo_schedule_delete_confirm_title%").done(function(ok) {
                                            if (!ok) return;
                                            AjaxHPAParadise({
                                                data: {
                                                    name: "sp_zalo_createAI_TaskSchedule",
                                                    param: ["LoginID", UserID, "LanguageID", LanguageID, "ActionType", "DELETE", "TaskScheduleID", row.IDTask || ""]
                                                },
                                                success: function() { loadScheduleList(); },
                                                error: function() { if (window.uiManager) uiManager.showAlert({ type: "error", message: "%zalo_schedule_delete_error%" }); }
                                            });
                                        });
                                    }
                                });
                                $rightWrap.append($statusBtn).append($edit).append($del);
                                $dxList.append($item);
                            });
                        },
                        error: function() {
                            $dxList.html("<div style=''color:#f66; text-align:center; padding:20px;''>%zalo_schedule_load_error%</div>");
                        }
                    });
                }
                // ====== Form thêm mới ======
                function openAddForm(editData) {
                    let $addPopup = $("<div />").appendTo("body");
                    let $form = $("<div style=''padding:10px; display:flex; flex-direction:column; gap:14px; overflow:auto;'' />");
                    let isEdit = !!(editData && editData.IDTask);
                    let preSelected = isEdit && editData.Param ? editData.Param.split(",") : (customSelectedKeys_GridZalo || []).slice();
                    let initialTaskName = isEdit ? (editData.TaskName || editData.TaskScheduleName || "") : "";
                    let initialDate = isEdit && editData.NextRunDate ? new Date(editData.NextRunDate.replace("T", " ")) : new Date(new Date().getTime() + 10 * 60000);
                    let initialRunType = isEdit ? (editData.TaskType || "2") : "2";
                    let initialProductID = isEdit ? editData.ProductID : null;
                    let editTaskID = isEdit ? editData.IDTask : "";
                    // --- Tên lịch ---
                    let $nameWrap = $("<div />").appendTo($form);
                    $("<label style=''font-size:12px; color:#aaa; margin-bottom:4px; display:block;''>%zalo_schedule_name% <span style=''color:red''>*</span></label>").appendTo($nameWrap);
                    let $nameBox = $("<div />").appendTo($nameWrap);
                    $nameBox.dxTextBox({ value: initialTaskName, placeholder: "%zalo_schedule_name_placeholder%" });
                    // --- Thời gian chạy ---
                    let $dateWrap = $("<div />").appendTo($form);
                    $("<label style=''font-size:12px; color:#aaa; margin-bottom:4px; display:block;''>%zalo_schedule_run_time% <span style=''color:red''>*</span></label>").appendTo($dateWrap);
                    let $timeRow = $("<div style=''display:flex; gap:10px;'' />").appendTo($dateWrap);
                    let $hourBox = $("<div style=''flex:1;'' />").appendTo($timeRow);
                    $hourBox.dxNumberBox({
                        min: 0, max: 23,
                        showSpinButtons: true,
                        value: initialDate.getHours(),
                        placeholder: "%zalo_schedule_hour_label%"
                    });
                    let $minuteBox = $("<div style=''flex:1;'' />").appendTo($timeRow);
                    $minuteBox.dxNumberBox({
                        min: 0, max: 59,
                        showSpinButtons: true,
                        value: initialDate.getMinutes(),
                        placeholder: "%zalo_schedule_minute_label%"
                    });
                    // --- Kiểu chạy ---
                    let $typeWrap = $("<div />").appendTo($form);
                    $("<label style=''font-size:12px; color:#aaa; margin-bottom:4px; display:block;''>%zalo_schedule_run_count% <span style=''color:red''>*</span></label>").appendTo($typeWrap);
                    let $typeBox = $("<div />").appendTo($typeWrap);
                    $typeBox.dxSelectBox({
                        items: [
                            { ID: "1", Name: "%zalo_schedule_hour%" },
                            { ID: "2", Name: "%zalo_schedule_day%" },
                            { ID: "3", Name: "%zalo_schedule_week%" },
                            { ID: "4", Name: "%zalo_schedule_month%" },
                            { ID: "5", Name: "%zalo_schedule_year%" }
                        ],
                        displayExpr: "Name", valueExpr: "ID",
                        value: initialRunType
                    });
                    // --- Phần mềm ---
                    let $swWrap = $("<div />").appendTo($form);
                    $("<label style=''font-size:12px; color:#aaa; margin-bottom:4px; display:block;''>%zalo_schedule_software% <span style=''color:red''>*</span></label>").appendTo($swWrap);
                    let $swBox = $("<div />").appendTo($swWrap);
                    // Giá trị mặc định lấy từ toolbar hiện tại
                    let defaultProductID = initialProductID;
                    let productDataSource = (typeof P36EB8FEA286C46F7A109BD6404CA9BAA_data !== "undefined") ? P36EB8FEA286C46F7A109BD6404CA9BAA_data : [];
                    try {
                        let inst = $("#P36EB8FEA286C46F7A109BD6404CA9BAA").dxSelectBox("instance");
                        if (inst) {
                            if (!isEdit) defaultProductID = inst.option("value");
                            let instItems = inst.option("items");
                            if (instItems && instItems.length > 0) productDataSource = instItems;
                        }
                    } catch(ex) {}
                    // --- Chạy theo ---
                    let $sampleWrap = $("<div />").appendTo($form);
                    $("<label style=''font-size:12px; color:#aaa; margin-bottom:4px; display:block;''>%zalo_schedule_run_by% <span style=''color:red''>*</span></label>").appendTo($sampleWrap);
                    let $sampleBox = $("<div />").appendTo($sampleWrap);
                    let initialSample = isEdit ? (editData.IsSample == 0 ? 0 : 1) : 1;
                    let sampleItems = [
                        { ID: 1, Name: "%zalo_schedule_run_system%", disabled: false },
                        { ID: 0, Name: "%zalo_schedule_run_personal%", disabled: (!isEdit && !defaultProductID) }
                    ];
                    $sampleBox.dxSelectBox({
                        items: sampleItems,
                        displayExpr: "Name", valueExpr: "ID",
                        value: initialSample
                    });
                    // --- Người nhận ---
                    let $tagWrap = $("<div />").appendTo($form);
                    $("<label style=''font-size:12px; color:#aaa; margin-bottom:4px; display:block;''>%zalo_schedule_recipient% <span style=''color:red''>*</span></label>").appendTo($tagWrap);
                    let $tagBox = $("<div />").appendTo($tagWrap);
                    let contactDS = preSelected.map(id => ({ ID: id, Name: id }));
                    function loadContactList(prodID) {
              try {
                            let tagInst = $tagBox.dxTagBox("instance");
                            tagInst.option("placeholder", "%zalo_schedule_recipient_loading%");
                            AjaxHPAParadise({
                                data: {
                                    name: "sp_zalo_Grid",
                                    param: ["LoginID", UserID, "tagID", prodID || ""]
                                },
                                success: function(res) {
                                     let json = typeof res === "string" ? JSON.parse(res) : res;
                                     let items = (json.data && json.data[0]) ? json.data[0] : [];
                                     let finalDS = [];
                                     let mapUnique = {};

                                     // Xác định tab đang active để lọc loại liên hệ tương ứng
                                     let activeIsGroup = 0; // 0: Bạn bè, 1: Nhóm, -1: Người lạ
                                     if ($("#tab-groups").hasClass("active")) {
                                         activeIsGroup = 1;
                                     } else if ($("#tab-invites").hasClass("active")) {
                                         activeIsGroup = -1;
                                     }

                                     if (items && items.length > 0) {
                                         items.forEach(it => {
                                             if (!it) return;
                                             // Lọc chỉ lấy các liên hệ khớp với Tab hiện tại
                                             if (it.isGroup !== activeIsGroup) return;

                                             let id = it.ZaloID || it.zaloID || it.ID || it.Id || it.id || it.UserID || it.userID || it.ContactID || it.Phone;
                                             let name = it.FullName || it.fullName || it.ZaloName || it.zaloName || it.Name || it.name || id;
                                             let avatar = it.Avatar || it.avatar || it.UrlAvatar || it.avatarUrl || it.Image || it.image || "";
                                             if (id && !mapUnique[id]) {
                                                 mapUnique[id] = true;
                                                 finalDS.push({ ID: id, Name: name, Avatar: avatar });
                                             }
                                         });
                                     }
                                     tagInst.option("dataSource", finalDS);
                                     tagInst.option("placeholder", finalDS.length > 0 ? "%zalo_schedule_recipient_placeholder%" : "%zalo_schedule_recipient_empty%");
                                },
                                error: function() {
                                    tagInst.option("placeholder", "%zalo_schedule_load_error%");
                                }
                            });
                        } catch(e) {}
                    }
                    $swBox.dxSelectBox({
                        dataSource: productDataSource,
                        displayExpr: "Name", valueExpr: "ID",
                        placeholder: "%zalo_schedule_software_placeholder%",
                        value: defaultProductID || null,
                        searchEnabled: true,
                        onValueChanged: function(e) {
                            try {
                                let tagInst = $tagBox.dxTagBox("instance");
                                if (e.value) {
                                    tagInst.option("disabled", false);
                                    loadContactList(e.value);
                                    // Check if user has personal prompt
                                    AjaxHPAParadise({
                                        data: {
                                            name: "sp_zalo_createAI_TaskSchedule",
                                            param: ["LoginID", UserID, "LanguageID", LanguageID, "ActionType", "CHECK_RULE", "ProductID", e.value]
                                        },
                                        success: function(res) {
                                            let json = typeof res === "string" ? JSON.parse(res) : res;
                                            let hasRule = (json.data && json.data[0] && json.data[0][0]) ? json.data[0][0].HasRule : 0;
                                let smBox = $sampleBox.dxSelectBox("instance");
                                            let newItems = [
                                                { ID: 1, Name: "%zalo_schedule_run_system%", disabled: false },
                                                { ID: 0, Name: "%zalo_schedule_run_personal%", disabled: (hasRule != 1) }
                                            ];
                                            smBox.option("items", newItems);
                                            if (hasRule == 1) {
                                                if (!isEdit) smBox.option("value", 0);
                                            } else {
                                                if (!isEdit || smBox.option("value") == 0) smBox.option("value", 1);
                                            }
                                        }
                                    });
                                } else {
                                    tagInst.option("disabled", true);
                                    tagInst.option("placeholder", "%zalo_schedule_recipient_require_sw%");
                                }
                            } catch(ex) {}
                        }
                    });
                    $tagBox.dxTagBox({
                        dataSource: contactDS,
                        displayExpr: "Name", valueExpr: "ID",
                        value: preSelected,
                        disabled: !defaultProductID, // Bắt buộc chọn phần mềm trước
                        acceptCustomValue: true,
                        searchEnabled: true,
                        searchExpr: ["Name", "ID"],
                        showSelectionControls: true,
                        applyValueMode: "useButtons",
                        placeholder: defaultProductID ? "%zalo_schedule_recipient_loading%" : "%zalo_schedule_recipient_require_sw%",
                        dropDownOptions: { height: 300 },
                        itemTemplate: function(data) {
                            let img = data.Avatar ? data.Avatar : "https://ui-avatars.com/api/?name=" + encodeURIComponent(data.Name || "Z") + "&background=random";
                            return $("<div style=''display:flex; align-items:center; gap:8px;''><img src=''"+img+"'' style=''width:24px; height:24px; border-radius:50%; object-fit:cover;'' /><span>"+data.Name+"</span></div>");
                        },
                        onCustomItemCreating: function(args) {
                            if (!args.text || !args.text.trim()) { args.customItem = null; return; }
                            args.customItem = { ID: args.text.trim(), Name: args.text.trim() };
                        },
                        noDataText: "%zalo_schedule_recipient_empty%"
                    });
                    if (defaultProductID) {
                        setTimeout(function() { loadContactList(defaultProductID); }, 100);
                    }
                    // --- Nút xác nhận ---
                    let $btnRow = $("<div style=''display:flex; gap:8px; justify-content:flex-end; margin-top:6px;'' />").appendTo($form);
                    $btnRow.dxButton({
                        text: isEdit ? "%zalo_schedule_btn_update%" : "%zalo_schedule_btn_create%", icon: "check",
                        elementAttr: { class: "btn-success-paradise" },
                        onClick: function(e) {
                            let btnInst = e.component;
                            btnInst.option("disabled", true);
                            setTimeout(() => btnInst.option("disabled", false), 2000);
                            let hourVal       = $hourBox.dxNumberBox("instance").option("value");
                            let minVal        = $minuteBox.dxNumberBox("instance").option("value");
                            let taskName   = $nameBox.dxTextBox("instance").option("value");
                            let runType       = $typeBox.dxSelectBox("instance").option("value");
                            let chosenProduct = $swBox.dxSelectBox("instance").option("value");
                            let sampleVal     = $sampleBox.dxSelectBox("instance").option("value");
                            let chosenIDs     = $tagBox.dxTagBox("instance").option("value") || [];
                            if (!chosenProduct || chosenProduct == 0) {
                                if (window.uiManager) uiManager.showAlert({ type: "warning", message: "%zalo_warn_select_software%" });
                                return;
                            }
                            if (!chosenIDs || chosenIDs.length === 0) {
                                if (window.uiManager) uiManager.showAlert({ type: "warning", message: "%zalo_warn_select_recipient%" });
                                return;
                            }
                            if (hourVal == null || minVal == null) {
                                if (window.uiManager) uiManager.showAlert({ type: "warning", message: "%zalo_warn_select_time%" });
                                return;
                            }
                            let d = new Date();
                            d.setHours(hourVal, minVal, 0, 0);
                            let hour = hourVal;
                            let minute = minVal;
                            let nextRunStr = DevExpress.localization.formatDate(d, "yyyy-MM-dd HH:mm:ss");
                            let paramStr = chosenIDs.join(",");
                            AjaxHPAParadise({
                                data: {
                                    name: "sp_zalo_createAI_TaskSchedule",
                                    param: [
                                        "LoginID", UserID,
                                        "LanguageID", LanguageID,
                                        "ActionType", isEdit ? "UPDATE" : "INSERT",
                                        "TaskName", taskName,
                                        "TaskType", runType,
                                        "Hour", hour,
                                        "Minute", minute,
                                        "NextRun", nextRunStr,
                                        "Params", paramStr,
                                        "ProductID", chosenProduct,
                                        "IsSample", sampleVal,
                                        "TaskScheduleID", editTaskID || ""
                                    ]
                                },
                                success: function() {
                                    $addPopup.dxPopup("instance").hide();
                                    if (window.uiManager) uiManager.showAlert({ type: "success", message: isEdit ? "%zalo_schedule_update_success%" : "%zalo_schedule_create_success%" });
                                    loadScheduleList();
                                },
                                error: function() {
                                    if (window.uiManager) uiManager.showAlert({ type: "error", message: "%zalo_schedule_save_error%" });
                                }
                            });
                        }
                    });
                    $addPopup.dxPopup({
                        title: isEdit ? "%zalo_schedule_title_edit%" : "%zalo_schedule_title_add%",
                        width: Math.min($(window).width() * 0.9, 500),
                        height: Math.min($(window).height() * 0.9, 580),
                        visible: true,
                        showCloseButton: true,
                        hideOnOutsideClick: true,
                        contentTemplate: function(c) { c.css({padding:"10px", overflowY:"auto"}).append($form); },
                        onHidden: function() { $addPopup.remove(); }
                    });
                }
                // Nút thêm mới
                $topBar.dxButton({
                    text: "%zalo_schedule_add_new%",
                    icon: "plus",
                    elementAttr: { class: "btn-success-paradise" },
                    onClick: openAddForm
                });
                $popup.dxPopup({
                    title: "%zalo_schedule_title_main%",
                    width: Math.min($(window).width() * 0.9, 600),
                    height: Math.min($(window).height() * 0.85, 480),
                    visible: true,
                    showCloseButton: true,
                    hideOnOutsideClick: true,
                    contentTemplate: function(contentElement) {
                        contentElement.css({ padding: "14px" }).append($innerWrap);
                    },
                    onShown: function() { loadScheduleList(); },
                    onHidden: function() { $popup.remove(); }
                });
            }
            function updateAIDebugIcon() {
                let $fab = $("#AI_Debug_FAB");
                if (!$fab.length) {
                    $fab = $("<div id=''AI_Debug_FAB'' title=''%zalo_auto_history_title%'' style=''position:absolute; bottom:30px; right:30px; width:50px; height:50px; border-radius:12px; background:var(--paradise-color-logo-main); color:white; display:flex; align-items:center; justify-content:center; cursor:pointer; box-shadow: 0 4px 12px rgba(0,0,0,0.3); z-index:9000; transition: all 0.3s; opacity:0; transform: scale(0);''><i class=''dx-icon dx-icon-box''></i></div>").appendTo($(".sp_zalo_autoSendMessage"));
                    $fab.on("click", function() {
                        showAIHistoryList();
                    });
                }
                if (aiHistory_Log.length > 0) {
                    $fab.css({ "opacity": "1", "transform": "scale(1)" });
                } else {
                    $fab.css({ "opacity": "0", "transform": "scale(0)" });
                }
            }
            function showAIHistoryList() {
                if (aiHistory_Log.length === 0) return;
                $("#Popup_AIHistory").remove();
                let $container = $("<div style=''padding:10px;'' />");
                let $list = $("<div />").appendTo($container);
                $list.dxList({
                    dataSource: aiHistory_Log,
                    scrollByContent: false, // Để ScrollView bên ngoài xử lý cuộn toàn bộ
                    itemTemplate: function(data) {
                        return $("<div style=''padding:8px;'' />").append(
                            $("<span style=''font-weight:bold; color:var(--paradise-color-logo-main); margin-right:5px;'' />").text("[" + data.timestamp + "]"),
                            $("<span style=''color:var(--paradise-color-header1);'' />").text("%zalo_auto_test_count% " + (data.id || "-"))
                        );
                    },
                    onItemClick: function(e) {
                        showAIHistoryDetail(e.itemData);
                    }
                });
                // Nút Xóa Lịch sử đặt ở cuối danh sách
                let $btnGroup = $("<div style=''display:flex; justify-content:flex-end; gap:10px; margin-top:20px; padding-bottom:10px;'' />");
                $("<div />").dxButton({
                    text: "%zalo_auto_delete_history%",
                    icon: "trash",
                    type: "danger",
                    stylingMode: "contained",
                    onClick: function() {
                        DevExpress.ui.dialog.confirm("%zalo_auto_confirm_delete_history%", "%Confirm%").done(function(result) {
                            if (result) {
                                aiHistory_Log = [];
                                updateAIDebugIcon();
                                $("#Popup_AIHistory").dxPopup("instance").hide();
                                if (window.uiManager) uiManager.showAlert({ type: "success", message: "%zalo_auto_delete_history_success%" });
                            }
                        });
                    }
                }).appendTo($btnGroup);
                $container.append($btnGroup);
                let $popupContainer = $("<div id=''Popup_AIHistory'' />").appendTo("body");
                $popupContainer.dxPopup({
                    title: "%zalo_auto_history_title%",
                    width: 400,
                    height: 500,
                    visible: true,
                    dragEnabled: true,
                    showCloseButton: true,
                    closeOnOutsideClick: true,
                    contentTemplate: function(contentElement) {
                        let scrollView = $("<div />").dxScrollView({ width: "100%", height: "100%", direction: "vertical" });
                        scrollView.dxScrollView("instance").content().append($container);
                        contentElement.append(scrollView);
                    },
                    onHidden: function() { $popupContainer.remove(); }
                });
            }
            function showAIHistoryDetail(historyItem) {
                let $popupDetail = $("<div />").appendTo("body");
                const popupHeight = Math.min($(window).height() * 0.9, 650);
                $popupDetail.dxPopup({
                    title: "%zalo_auto_detail_title%" + historyItem.timestamp,
                    width: Math.min($(window).width() * 0.9, 850),
                    height: popupHeight,
                    visible: true,
                    dragEnabled: true,
                    showCloseButton: true,
                    closeOnOutsideClick: true,
                    contentTemplate: function(contentElement) {
                        $(contentElement).css("padding", "0");
                        let $tabPanel = $("<div />").css("height", "100%").appendTo(contentElement);
                        $tabPanel.dxTabPanel({
                            height: "100%",
                            dataSource: [
                                { title: "%zalo_auto_result%", icon: "box", type: "result" },
                                { title: "%zalo_auto_rule%", icon: "info", type: "prompt" }
                            ],
                            selectedIndex: 0,
                            itemTemplate: function(data, index, element) {
                                $(element).css("height", "100%");
                                let $container = $("<div style=''height:100%; position:relative; overflow:hidden;'' />");
                                let $scrollView = $("<div />").appendTo($container).dxScrollView({
                                    height: "100%",
                                    width: "100%",
                                    direction: "both",
                                    showScrollbar: "always",
                                    useNative: false
                                });
                                if (data.type === "result") {
                                    let results = historyItem.results || {};
                                    let keys = Object.keys(results);
                                    let fullData = [];
                                    try {
                                        fullData = window.gridInstance.getDataSource().items() || [];
                                        if (fullData.length === 0 && window.gridInstance.getDataSource().store()._array) {
                                            fullData = window.gridInstance.getDataSource().store()._array;
                                        }
                                    } catch(e) {}
         let $listContainer = $("<div style=''padding:15px;'' />").appendTo($scrollView.dxScrollView("instance").content());
                                    if (keys.length > 1) {
                                        let selectorData = keys.map(function(k) {
                                            let n = globalZaloNameMap[k.toString()];
                                            return { id: k, name: n ? n : ("%zalo_schedule_customer% " + k) };
                                        });
                                        $("<div style=''font-weight:bold; color:var(--paradise-color-header1); margin-bottom:5px; font-size:12px;'' />").text("%zalo_auto_select_customer%").appendTo($listContainer);
                                        $("<div style=''margin-bottom:20px;'' />").appendTo($listContainer).dxSelectBox({
                                            dataSource: selectorData,
                                            displayExpr: "name",
                                            valueExpr: "id",
                                            value: keys[0],
                                            onValueChanged: function(e) { renderSingleResult(e.value, true); }
                                        });
                                    }
                                    let $resultContent = $("<div />").appendTo($listContainer);
                                    function renderSingleResult(zaloID, hideName) {
                                        $resultContent.empty();
                                        if (!zaloID) return;
                                        let msg = results[zaloID.toString()] || results[zaloID];
                                        let $item = $("<div style=''padding:10px 0; border-left:4px solid var(--paradise-color-logo-main); padding-left:15px;'' />");
                                        if (!hideName) {
                                            let n = globalZaloNameMap[zaloID.toString()];
                                            let name = n ? n : ("%zalo_schedule_customer% " + zaloID);
                                            $("<div style=''font-weight:bold; font-size:16px; color:var(--paradise-color-header1); margin-bottom:8px; border-bottom: 1px dashed #ccc; padding-bottom: 8px;'' />").text(name).appendTo($item);
                                        }
                                        $("<div style=''font-size:14px; white-space:pre-wrap; color:var(--paradise-color-brown); line-height: 1.6;'' />").text(msg || "%zalo_auto_no_msg%").appendTo($item);
                                        $item.appendTo($resultContent);
                                    }
                                    if (keys.length > 0) renderSingleResult(keys[0], keys.length > 1);
                                    else $listContainer.append($("<div style=''text-align:center; padding:20px; color:#999;'' />").text("%zalo_auto_no_data%"));
                                } else {
                                    // Nút Copy
                                    let $copyBtn = $("<div style=''position:absolute; top:5px; right:15px; z-index:10;'' />").appendTo($container);
                                    $copyBtn.dxButton({
                                        icon: "copy",
                                        hint: "%zalo_auto_copy_prompt%",
                                        type: "default",
                                        stylingMode: "text",
                                        onClick: function() {
                                            let textToCopy = typeof historyItem.prompt === "string" ? historyItem.prompt : JSON.stringify(historyItem.prompt, null, 2);
                                            if (navigator.clipboard) {
                                                navigator.clipboard.writeText(textToCopy).then(function() {
                           if (window.uiManager) uiManager.showAlert({ type: "success", message: "%zalo_auto_copy_success%" });
                                                });
                                            }
                                        }
                                    });
                                    let prompts = historyItem.prompt || {};
                                    let isObj = typeof prompts === "object" && prompts !== null;
                                    let keys = isObj ? Object.keys(prompts) : [];
                                    let $listContainer = $("<div style=''padding:15px;'' />").appendTo($scrollView.dxScrollView("instance").content());
                                    if (isObj && keys.length > 1) {
                                        let selectorData = keys.map(function(k) {
                                            let n = globalZaloNameMap[k.toString()];
                                            return { id: k, name: n ? n : ("%zalo_schedule_customer% " + k) };
                                        });
                                        $("<div style=''font-weight:bold; color:var(--paradise-color-header1); margin-bottom:5px; font-size:12px;'' />").text("%zalo_auto_select_customer%").appendTo($listContainer);
                                        $("<div style=''margin-bottom:20px;'' />").appendTo($listContainer).dxSelectBox({
                                            dataSource: selectorData,
                                            displayExpr: "name",
                                            valueExpr: "id",
                                            value: keys[0],
                                            onValueChanged: function(e) { renderSinglePrompt(e.value); }
                                        });
                                    }
                                    let $promptContentWrapper = $("<div />").appendTo($listContainer);
                                    function renderSinglePrompt(zaloID) {
                                        $promptContentWrapper.empty();
                                        let promptText = "";
                                        if (isObj) {
                                            promptText = prompts[zaloID] || "%zalo_no_prompt_data%";
                                        } else {
                                            promptText = prompts || "%zalo_no_prompt_data%";
                                        }
                                        let $promptContent = $("<div class=''markdown-body'' style=''font-size:13px; color:var(--paradise-color-brown); line-height: 1.6;'' />");
                                        if (typeof marked !== "undefined") {
                                            $promptContent.html(marked.parse(promptText));
                                        } else {
                                            let htmlText = promptText.replace(/</g, "&lt;").replace(/>/g, "&gt;");
                                            htmlText = htmlText.replace(/```([\s\S]*?)```/g, function(match, code) {
                                                return "<pre style=''background:#282c34; color:#abb2bf; padding:10px; border-radius:5px; margin:10px 0; white-space:pre-wrap; overflow-x:auto; font-family:Consolas, monospace;''>" + code.trim() + "</pre>";
                                            });
                                            htmlText = htmlText.replace(/\n/g, "<br/>");
                                            $promptContent.html(htmlText);
                                        }
                                        $promptContentWrapper.append($promptContent);
                                    }
                                    if (isObj && keys.length > 0) renderSinglePrompt(keys[0]);
                                    else if (!isObj) renderSinglePrompt(null);
                                    else $listContainer.append($("<div style=''text-align:center; padding:20px; color:#999;'' />").text("%zalo_auto_no_data%"));
                                }
                                element.append($container);
                            },
                            onSelectionChanged: function() {
                                setTimeout(function() { $(".dx-scrollview").dxScrollView("instance").update(); }, 150);
                            }
                        });
                    },
                    onHidden: function() { $popupDetail.remove(); }
                });
            }
            // Kiểm tra trạng thái đăng nhập ngay khi load
            checkZaloStatus();
            function open_zaloLogin(LoginID) {
                if (typeof openFormParam === "function") {
                    openFormParam(`sp_zalo`, { LoginID: LoginID, LanguageID: LanguageID, isWeb: window.isWeb });
                }
            }
            async function checkZaloStatus() {
                let res = await AjaxHPAParadiseAsync({
                    data: {
                        name: "sp_ViewZaloClient",
                        param: ["LoginID", UserID]
                    }
                });
                if(!res){
                    uiManager.showAlert({ type: "error", message: "%Error%" });
                    return;
                }
                let jsonRes = (typeof res === "string") ? JSON.parse(res) : res;
                if (jsonRes.data[0][0].status === "haveLogout") {
                    if (typeof showConfirmPopup === "function") {
                        showConfirmPopup({
                            title: "%Confirm%",
                            message: "%zalo_logout_confirm%",
                            YesText: "%Agree%",
                            NoText: "%Cancel%",
                            onYes: () => {
                                open_zaloLogin(UserID);
                            }
                        });
                    }
                }
            }
            function loadFriendAvatars() {
                AjaxHPAParadise({
                    data: {
                        name: "sp_zalo_getFriendAvatar",
                        param: ["LoginID", UserID]
                    },
                    success: function (res) {
                        let json = typeof res === "string" ? JSON.parse(res) : res;
                        let data = json.data?.[0] || [];
                        data.forEach(function(item) {
                            if (item.zaloID) friendAvatarMap[item.zaloID] = item.avatar;
                        });
                        // Sau khi load xong ảnh bạn bè   repaint grid để hiện ảnh ghép group
                        if (window.gridInstance) {
                            window.gridInstance.repaint();
                        }
                    }
                });
            }
            loadFriendAvatars();
            // ============================================================
            // 1. KHỞI TẠO DATASTORE DUY NHẤT MỘT LẦN
            // ============================================================
            dataStore_GridZalo = new DevExpress.data.CustomStore({
                key: "zaloID",
                byKey: function(key) {
                    let d = new $.Deferred();
                    d.resolve({ zaloID: key });
                    return d.promise();
                },
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
                    // SP nghiệp vụ
                    params.push("@ProcName", "sp_zalo_Grid");
                    // Lấy giá trị tag đã chọn trực tiếp từ control hoặc biến state
                    let tagVal = "";
                    try {
                        let tagBox = $("#P36EB8FEA286C46F7A109BD6404CA9BAA").dxSelectBox("instance");
                        if (tagBox) tagVal = tagBox.option("value") || "";
                    } catch(ex) {}
                    if (!tagVal) tagVal = _currentTagID || "";
                                        // 2. Tinh toan Sort (Uu tien phan mem & thoi gian gui cu nhat)
                    let sortRaw = loadOptions.sort
                        ? loadOptions.sort.map(s => s.selector + (s.desc ? " DESC" : " ASC")).join(",")
                        : "";
                    let finalSort = "";
if (sortRaw) {
    if (tagVal && sortRaw.indexOf("hasProductTag") === -1) {
        finalSort = "hasProductTag DESC, " + sortRaw;
    } else {
        finalSort = sortRaw;
    }
} else {
    if (tagVal) {
        finalSort = "hasProductTag DESC, aiLastTime DESC, lastActionTime DESC";
    } else {
        finalSort = "lastActionTime DESC";
    }
}
                    // 3. Kiem tra Cache
                    const cacheKey = JSON.stringify({
                        skip: loadOptions.skip,
                        take: loadOptions.take,
                        keyword: _currentKeyword,
                        tag: tagVal,
                        sort: finalSort,
                        filter: loadOptions.filter
                    });
                    if (_pageCache[cacheKey]) {
                        deferred.resolve(_pageCache[cacheKey]);
                        return deferred.promise();
                    }
                    // 4. Chuẩn bị Parameters
                    let procParam = "@LoginID = " + (window.UserID || window.LoginID) + ", @LanguageID = " + window.LanguageID
                        + ", @tagID = N''" + tagVal + "''"
                        + ", @SearchValue = N''" + (_currentKeyword || "") + "''";
                    console.log("?? Grid Load Params:", { tagVal, _currentKeyword, procParam });
                    params.push("@ProcParam", procParam);
                    params.push("@tagID", tagVal);
                    // Phân trang
                    params.push("@Take", loadOptions.take || 50);
                    params.push("@Skip", loadOptions.skip || 0);
                    // TotalCount
                    if (loadOptions.requireTotalCount) {
                        params.push("@RequireTotalCount", 1);
                    }
                    params.push("@Sort", "ORDER BY " + finalSort);
                    // Search
                    if (_currentKeyword) {
                        params.push("@SearchValue", _currentKeyword);
                        params.push("@ColumnSearch", "");
                    }
                    // Filter
                    if (loadOptions.filter) {
                        const hasFunction = JSON.stringify(loadOptions.filter).includes(''FUNCTION'');
                        if (!hasFunction) {
                            let isGroupVal = 0; if ($("#tab-groups").hasClass("active")) isGroupVal = 1; if ($("#tab-invites").hasClass("active")) isGroupVal = -1; params.push("@Filters", "isGroup = " + isGroupVal);
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
                            results.forEach(function(row) {
                                let id = (row.zaloID || row.ZaloID || "").toString();
                                if (id) globalZaloNameMap[id] = row.zaloName || row.Name || row.ZaloName || row.FullName || "";
                            });
                            let result = { data: results };
                            if (loadOptions.requireTotalCount) {
                                let tc = json?.data?.[1]?.[0]?.TotalCount;
                                if (tc === undefined || tc === null) tc = json?.data?.[1]?.[0]?.totalCount;
                                if (tc === undefined || tc === null) tc = results.length;
                                result.totalCount = tc;
                                if (loadOptions.totalSummary) {
                                    result.summary = Object.values(json?.data?.[2]?.[0] ?? {});
                                }
                            } else {
                                if (loadOptions.totalSummary) {
                                    result.summary = Object.values(json?.data?.[1]?.[0] ?? {});
                                }
                            }
                            DataSource = results;
                            // Luu vào cache
                            _pageCache[cacheKey] = result;
                            deferred.resolve(result);
                            if (window._pendingSelectionCheck) {
                                setTimeout(function() {
                                    if (typeof applySelectionLogic === "function") applySelectionLogic(window._pendingMenuID);
                                }, 300);
                            }
                        },
                    });
                    return deferred.promise();
                }
            });
            // Khi SelectBox thay đổi   reload grid với tagID mới hoặc xử lý chọn số lượng
            window["onSelectBoxChanged_P36EB8FEA286C46F7A109BD6404CA9BAA"] = function(value, instance, e) {
                console.log("Zalo Grid Filter Changed (HPA Event):", value);
                if (window.clearZaloSelectionFull) window.clearZaloSelectionFull(value);
                customSelectedKeys_GridZalo = [];
                // Thực hiện refresh grid
                try {
                    let grid = $("#GridZalo").dxDataGrid("instance");
                    if (grid) {
                        grid.refresh();
                    } else if (window.gridInstance) {
                        window.gridInstance.refresh();
                    }
                } catch(ex) {
                    console.error("Refresh grid error:", ex);
                }
            };
            // getCurrentMenuID: Segmented Control đã bị xóa, mặc định = 1 (Đoạn đầu)
            function getCurrentMenuID() { return 1; }
            // Helper: Lấy numVal từ SelectBox Số lượng
            // Centralized function to force clear selection & quantity across all closures
            window.clearZaloSelectionFull = function(newTagID) {
                console.log("🚀taidang~ [clearZaloSelectionFull] Clearing all selection & quantity for tag:", newTagID);
                if (newTagID !== undefined) {
                    _currentTagID = (newTagID != null && newTagID !== "" && newTagID != 0) ? newTagID.toString() : "";
                }
                _pageCache = {};
                window._forceZeroQuantity = true;
                if (typeof customSelectedKeys_GridZalo !== "undefined" && Array.isArray(customSelectedKeys_GridZalo)) {
                    customSelectedKeys_GridZalo.length = 0;
                }
                try {
                    let numInst = $("#PC3ECBD81231B40B294775F6A0D74C861").dxSelectBox("instance");
                    if (numInst) {
                        numInst.reset();
                        numInst.option("value", null);
                    }
                } catch(ex) {}
                let grid = $("#GridZalo").dxDataGrid("instance") || window.gridInstance;
                if (grid) {
                    try { safeRepaintGrid(grid, true); } catch(e) { grid.refresh(); }
                }
            };

            function getCurrentNumVal() {
                if (window._forceZeroQuantity) {
                    console.log("🚀taidang~ [getCurrentNumVal] _forceZeroQuantity is TRUE -> return 0");
                    return 0;
                }
                let numVal = 10;
                try {
                    let numInst = $("#PC3ECBD81231B40B294775F6A0D74C861").dxSelectBox("instance");
                    if (numInst) {
                        let numBoxID = numInst.option("value");
                        if (numBoxID === null || numBoxID === undefined || numBoxID === "") {
                            return 0;
                        }
                                                if (typeof numBoxID === "string" && numBoxID.indexOf("custom_") === 0) {
                            return parseInt(numBoxID.replace("custom_", ""), 10);
                        }
                        // Do NOT return parseInt(numBoxID) directly because DB IDs are 1, 2, 3 but represent 10, 20, 50!
                        // Let it fall through to parsing text/Name below.
                        let rawText = numInst.option("text");
                        if (rawText && rawText.trim() !== "" && !isNaN(rawText.trim())) {
                            return parseInt(rawText.trim());
                        }
                        let item = numInst.option("selectedItem");
                        if (item && item.Name) {
                            let matches = item.Name.toString().match(/\d+/g);
                            if (matches) numVal = parseInt(matches[matches.length - 1]);
                        }
                    }
                } catch(ex) {}
                return numVal;
            }
            // Hàm repaint/refresh an toàn: cất các control đi trước khi Grid xóa DOM của toolbar
            function safeRepaintGrid(gridObj, isRefresh) {
                if (!gridObj) return;
                $("#P36EB8FEA286C46F7A109BD6404CA9BAA").appendTo("#SelectBoxContainer_Temp");
                $("#PC3ECBD81231B40B294775F6A0D74C861").appendTo("#SelectBoxContainer_Temp");
                $("#PBE6706C7F3944933A71F067C581E0677").appendTo("#SelectBoxContainer_Temp");
                if (isRefresh) gridObj.refresh();
                else gridObj.repaint();
            }
            async function applySelectionLogic(menuID) {
                let skel = null;
                try {
                    let grid = $("#GridZalo").dxDataGrid("instance");
                    if (!grid) { console.log("🚀taidang~ [applySelectionLogic] EARLY EXIT: grid not found"); return; }
                    // Tự đọc menuID nếu không truyền vào
                    if (menuID === undefined) menuID = getCurrentMenuID();
                    if (menuID === undefined || menuID === null) menuID = 1;
                    let numVal = getCurrentNumVal();
                    console.log("🚀taidang~ [applySelectionLogic] START:", { menuID: menuID, numVal: numVal });
                    // Cập nhật trạng thái Chọn Tất Cả
                    if (menuID == -1) isSelectAllActive_GridZalo = true;
                    else isSelectAllActive_GridZalo = false;
                    if (numVal <= 0 && menuID != -1 && menuID != 3) {
                        console.log("🚀taidang~ [applySelectionLogic] EARLY EXIT: numVal=0 -> CLEAR GRID");
                        if (typeof setCustomSelectedKeys_GridZalo === "function") setCustomSelectedKeys_GridZalo([]);
                        if (typeof safeRepaintGrid === "function") {
                            let g = $("#GridZalo").dxDataGrid("instance");
                            if (g) safeRepaintGrid(g, true);
                        }
                        return;
                    }
                    // Hiện thị Skeleton Screen chuẩn hệ thống
                    if (window.uiManager && uiManager.showSkeleton) {
                        skel = uiManager.showSkeleton({ target: "#GridZalo", type: "list" });
                    }
                    // Lấy Filter hiện tại
                    let tagID = "";
                    try {
                        let tagBox = $("#P36EB8FEA286C46F7A109BD6404CA9BAA").dxSelectBox("instance");
                        if (tagBox) tagID = tagBox.option("value") || "";
                    } catch(ex) {}
                    // Lấy allData từ grid hiện tại
let allData = [];
                    let ds = grid.getDataSource();
                    if (ds) {
                        let items = ds.items();
                        // Deep clone to avoid mutating the grid data directly when sorting
                        allData = JSON.parse(JSON.stringify(items));
                    }
                    console.log("🚀taidang~ [applySelectionLogic] allData.length:", allData.length, "| isGroup filter:", $("#tab-groups").hasClass("active") ? "groups(1)" : ($("#tab-invites").hasClass("active") ? "invites(-1)" : "friends(0)"));
                    allData.forEach(function(row) {
                        let id = (row.zaloID || row.ZaloID || "").toString();
                        if (id) globalZaloNameMap[id] = row.zaloName || row.Name || row.ZaloName || row.FullName || "";
                    });
                    // Lọc dữ liệu theo Tab hiện tại để tránh lấy nhầm khách hàng từ Tab khác (Bạn bè / Nhóm / Người lạ)
                    let isGroupVal = 0;
                    if ($("#tab-groups").hasClass("active")) isGroupVal = 1;
                    if ($("#tab-invites").hasClass("active")) isGroupVal = -1;
                    allData = allData.filter(function(r) { return r.isGroup == isGroupVal; });
                    console.log("🚀taidang~ [applySelectionLogic] allData after isGroup filter:", allData.length);
                    let selectedData = [];
                    if (menuID == -1) {
                        // Tất cả
                        selectedData = allData;
                    } else if (menuID == 1) {
                        // Đoạn đầu (đã sort DESC từ DB)
                        selectedData = allData.slice(0, numVal);
                    } else if (menuID == 2) {
                        // Đặc biệt: N dòng có lastActionTime cũ nhất (ASC)
                        let sorted = allData.slice().sort(function(a, b) {
                            let ta = a.lastActionTime ? new Date(a.lastActionTime).getTime() : 0;
                            let tb = b.lastActionTime ? new Date(b.lastActionTime).getTime() : 0;
                            return ta - tb;
                        });
                        selectedData = sorted.slice(0, numVal);
                    } else if (menuID == 3) {
                        // Gần đây: Lấy lịch sử từ bảng tblZalo_AdvertisingHistory
                        if (!tagID || tagID == 0) {
                            if (window.uiManager) uiManager.showAlert({ type: "warning", message: "%zalo_auto_select_software_first%" });
                            return;
                        }
                        let historyRes = await AjaxHPAParadiseAsync({
                            data: {
                                name: "sp_zalo_getAdHistory",
                                param: ["ProductID", tagID, "LanguageID", LanguageID]
                            }
                        });
                        let historyJson = typeof historyRes === "string" ? JSON.parse(historyRes) : historyRes;
                        let historyIDs = (historyJson.data && historyJson.data[0]) ? historyJson.data[0].map(function(x) { return (x.zaloID || "").toString(); }) : [];
                        // Lọc những ID có trong lịch sử và đang hiển thị trong grid hiện tại
                        selectedData = allData.filter(function(r) {
                            return historyIDs.includes((r.zaloID || "").toString());
                        });
                    }
                    let keys = selectedData.map(function(r) { return r.zaloID || r.ZaloID || r.userId || r.groupId || r.uid; });
                    customSelectedKeys_GridZalo = keys;
                    console.log("🚀taidang~ [applySelectionLogic] selectedData.length:", selectedData.length, "keys:", keys.slice(0, 5), "...");
                    console.log("🚀taidang~ [applySelectionLogic] sample allData[0]:", allData[0] ? { zaloID: allData[0].zaloID, ZaloID: allData[0].ZaloID, isGroup: allData[0].isGroup } : "EMPTY");
                    safeRepaintGrid(grid);
                } catch(ex) {
                    console.error("applySelectionLogic error:", ex);
                } finally {
                    if (skel && window.uiManager && uiManager.hideSkeleton) uiManager.hideSkeleton();
                    else if (skel && typeof skel.remove === "function") skel.remove();
                }
            }
            function loadDataSourceCommon(columnName, dataSourceSP, onSuccessCallback) {
                if (!columnName || !dataSourceSP || dataSourceSP.trim() === "") return;
                const dataSourceKey = "DataSource_" + dataSourceSP;
                const loadedKey = dataSourceSP + "DataSourceLoaded";
                if (window[loadedKey] === true) {
                    let data = window[dataSourceKey] || [];
                    if (dataSourceSP === "sp_zalo_getMarketingProduction") {
                        P36EB8FEA286C46F7A109BD6404CA9BAA_data = data;
                        if (window.gridInstance) window.gridInstance.repaint();
                    } else if (dataSourceSP === "sp_zalo_get_autoSendMessage_numberSelection") {
                        PC3ECBD81231B40B294775F6A0D74C861_data = data;
                    } else if (dataSourceSP === "sp_zalo_get_autoSendMessage_AI_Menu") {
                        PBE6706C7F3944933A71F067C581E0677_data = data;
                    }
                    if (typeof onSuccessCallback === "function") onSuccessCallback(data);
                    return Promise.resolve(data);
                }
                if (window[loadedKey] === "loading") {
                    setTimeout(function() { loadDataSourceCommon(columnName, dataSourceSP, onSuccessCallback); }, 100);
                    return;
                }
                window[loadedKey] = "loading";
                return new Promise((resolve, reject) => {
                    AjaxHPAParadise({
                        data: {
                            name: dataSourceSP,
                            param: ["LoginID", UserID, "LanguageID", LanguageID]
                        },
                        success: function (res) {
                            const json = typeof res === "string" ? JSON.parse(res) : res;
                            const data = (json.data && json.data[0]) || [];
                            window[dataSourceKey] = data;
                            window[loadedKey] = true;
                            // Gán vào biến let theo yêu cầu của người dùng
                            if (dataSourceSP === "sp_zalo_getMarketingProduction") {
                                P36EB8FEA286C46F7A109BD6404CA9BAA_data = data;
                                if (window.gridInstance) window.gridInstance.repaint();
                            } else if (dataSourceSP === "sp_zalo_get_autoSendMessage_numberSelection") {
                                PC3ECBD81231B40B294775F6A0D74C861_data = data;
                            } else if (dataSourceSP === "sp_zalo_get_autoSendMessage_AI_Menu") {
                                PBE6706C7F3944933A71F067C581E0677_data = data;
                            }
                            if (typeof onSuccessCallback === "function") onSuccessCallback(data);
                            resolve(data);
                        },
                        error: function (err) {
                            window[loadedKey] = false;
                            reject(err);
                        }
                    });
                });
            }
            window.currentRecordID_ID = null; window.currentRecordID_zaloID = null;
            function clearPageCache() {
                _pageCache = {};
            }
            function getGridHeight() {
                let gridEl = $("#GridZalo");
                if ((!gridEl || !gridEl.length) && typeof window.InstanceGridZaloP573D5BF0C93B424BA49F7C7FE5871D8B !== "undefined" && window.InstanceGridZaloP573D5BF0C93B424BA49F7C7FE5871D8B) {
                    gridEl = window.InstanceGridZaloP573D5BF0C93B424BA49F7C7FE5871D8B.element();
                }
                if (!gridEl || !gridEl.length) return 500;
                const domElement = gridEl.jquery ? gridEl[0] : gridEl;
                const top = domElement ? domElement.getBoundingClientRect().top : 100;
                return window.innerHeight - top - 20;
            }
            // ============================================================
            // 2. KHỞI TẠO GRID LAYOUT MỘT LẦN DUY NHẤT
            // ============================================================
            let gridInstance = null;
            try {
                gridInstance = $("#GridZalo").dxDataGrid("instance");
            } catch(ex) {
                // Fallback nếu chưa có instance
                gridInstance = (typeof window.InstanceGridZaloP573D5BF0C93B424BA49F7C7FE5871D8B !== "undefined") ? window.InstanceGridZaloP573D5BF0C93B424BA49F7C7FE5871D8B : null;
            }
            if (!gridInstance) {
                $("#GridZalo").dxDataGrid({});
                gridInstance = $("#GridZalo").dxDataGrid("instance");
            }
            window.gridInstance = gridInstance;
            if (!gridInstance) return;
          gridInstance.beginUpdate();
            gridInstance.option("remoteOperations", {
                paging: true, filtering: true, sorting: true, searching: true
            });
            gridInstance.option({
                columnChooser: {
                    title: "%zalo_column_chooser_title%"
                },
                selection: {
                    mode: "none"
                },
                onCellClick: function(e) {
                    if (e.rowType !== "data") return;
                    // Chỉ xử lý mở Detail khi click vào ảnh hoặc Tên Zalo
                    if (e.column && (e.column.dataField === "zaloName" || e.column.dataField === "avatar")) {
                        openDetailzaloID(e.data);
                    }
                },
                "scrolling.mode": "infinite",
                "scrolling.rowRenderingMode": "virtual",
                "scrolling.preloadEnabled": false,
                "paging.enabled": true,
                "paging.pageSize": 50,
                "pager.visible": false,
                "columnAutoWidth": false,
                "searchPanel.highlightSearchText": false,
                "dataSource": dataStore_GridZalo,
                "height": getGridHeight(),
                "width": "100%",
                onToolbarPreparing: function(e) {
                    try {
                        if (e && e.toolbarOptions && Array.isArray(e.toolbarOptions.items)) {
                            let colChooser = e.toolbarOptions.items.find(function(item) { return item.name === "columnChooserButton"; });
                            if (colChooser) {
                                colChooser.locateInMenu = "never";
                            }
                        }
                    } catch(err) {}
                    e.toolbarOptions.items.unshift({
                        location: "before",
                        template: function() {
                            return $("<div class=''d-flex align-items-center flex-nowrap'' style=''gap: 10px; margin-right: 15px; padding-bottom: 5px;''>" +
                                        "<div id=''Toolbar_SelectBox_Placeholder'' style=''width: 220px;''></div>" +
                                        "<div id=''Toolbar_Quantity_Placeholder'' style=''width: 110px;''></div>" +
                                        "<div id=''Toolbar_AIMenu_Placeholder'' style=''width: 180px;''></div>" +
                                    "</div>");
                        }
                    });
                },
                onContentReady: function(e) {
                    // Di chuyển SelectBox Chọn phần mềm thực vào placeholder trong toolbar
                    let $placeholder = $("#Toolbar_SelectBox_Placeholder");
                    let $sb = $("#P36EB8FEA286C46F7A109BD6404CA9BAA");
                    if ($placeholder.length && $sb.length) {
                         if ($sb.parent()[0] !== $placeholder[0]) {
                             $sb.appendTo($placeholder);
                         }
                         // Thiết lập placeholder và xử lý giá trị 0
                         try {
                             let inst = $sb.dxSelectBox("instance");
                             if (inst) {
                                 inst.option("placeholder", "%zalo_auto_software%");
                                 inst.option("dropDownOptions", { container: $("body") });
                                 if (P36EB8FEA286C46F7A109BD6404CA9BAA_data.length > 0) {
                                     inst.option("dataSource", P36EB8FEA286C46F7A109BD6404CA9BAA_data);
                                 }
                                 let val = inst.option("value");
                                 if (val === 0 || val === "0") inst.option("value", null);
                                 // Backup listener để đảm bảo luôn refresh grid
                                 inst.off("valueChanged").on("valueChanged", function(ev) {
                                     console.log("Zalo Grid Filter Changed (inst Event):", ev.value);
                                     if (window.clearZaloSelectionFull) window.clearZaloSelectionFull(ev.value);
                                 });
                             }
                         } catch(ex) {}
                    }
                    // Di chuyển Quantity SelectBox vào placeholder
                    let $qtyPlaceholder = $("#Toolbar_Quantity_Placeholder");
                    if ($qtyPlaceholder.length && $("#PC3ECBD81231B40B294775F6A0D74C861").parent().attr("id") !== "Toolbar_Quantity_Placeholder") {
                        let $qtySb = $("#PC3ECBD81231B40B294775F6A0D74C861");
                        $qtySb.appendTo($qtyPlaceholder);
                        try {
                            let inst = $qtySb.dxSelectBox("instance");
                            if (inst) {
                                inst.option("placeholder", "%zalo_auto_quantity%");
                                inst.option("dropDownOptions", { container: $("body") });
                                inst.option("acceptCustomValue", true); // Bật tính năng cho phép nhập số tự do
                                inst.option("onCustomItemCreating", function(args) {
                                    if (!args.text) {
                                        args.customItem = null;
                                        return;
                                    }
                                                                        let val = parseInt(args.text);
                                    if (isNaN(val) || val <= 0) {
                                        args.customItem = null;
                                        return;
                                    }
                                    let customId = "custom_" + val;
                                    let newItem = { ID: customId, Name: val.toString() };
                                    let ds = inst.option("dataSource");
                                    if (Array.isArray(ds)) {
                                        let exists = ds.find(function(x) { return x.ID === customId; });
                                        if (!exists) {
                                            ds.push(newItem);
                                            inst.option("dataSource", ds);
                                        }
                                    }
                                    args.customItem = newItem;
                                    return newItem;
                                });
                                if (PC3ECBD81231B40B294775F6A0D74C861_data.length > 0) {
                                    inst.option("dataSource", PC3ECBD81231B40B294775F6A0D74C861_data);
                                }
                            }
                        } catch(ex) {}
                    }
                    // Di chuyển AI Menu SelectBox vào placeholder
                    let $aiPlaceholder = $("#Toolbar_AIMenu_Placeholder");
                    if ($aiPlaceholder.length && $("#PBE6706C7F3944933A71F067C581E0677").parent().attr("id") !== "Toolbar_AIMenu_Placeholder") {
                        let $aiSb = $("#PBE6706C7F3944933A71F067C581E0677");
                        $aiSb.appendTo($aiPlaceholder);
                        let inst = $aiSb.dxSelectBox("instance");
                        if (inst) {
                            inst.option("placeholder", "%zalo_auto_ai_tasks%");
                            inst.option("dropDownOptions", { width: "auto", container: $("body") });
                            inst.option("displayExpr", "Name");
                            inst.option("itemTemplate", function(data) {
                                 let $div = $("<div style=''display:flex; align-items:center; gap:6px;''></div>");
                                 if (data) {
                                     if (data.Code === "AutoSpam") {
                                         let textOn = "%zalo_auto_on%";
                                         let textOff = "%zalo_auto_off%";
                                         let statusVal = data.StatusValue;
                                         let displayName = (data.Name || "").split(" (")[0];
                                         if (statusVal == 1) {
                                             $div.css({ "color": "#22c55e", "font-weight": "600" });
                                             $div.html(displayName + " (" + textOn + ") <i class=''bi bi-check-circle-fill''></i>");
                                         } else {
                                             $div.css({ "color": "#ef4444", "font-weight": "600" });
                                             $div.html(displayName + " (" + textOff + ") <i class=''bi bi-x-circle-fill''></i>");
                                         }
                                     } else {
                                         $div.html(data.Name);
                                     }
                                 }
                                 return $div;
                             });
                            if (PBE6706C7F3944933A71F067C581E0677_data.length > 0) {
                                inst.option("dataSource", PBE6706C7F3944933A71F067C581E0677_data);
                            }
                            inst.option("onItemClick", function(e) {
                                if (!e.itemData) return;
                                let menuID = e.itemData.ID;
                                // ID = 3: Sửa rule (Sửa prompt)
                                if (menuID == 3) {
                                    let productID = "";
                                    try {
                                        let selProduct = $("#P36EB8FEA286C46F7A109BD6404CA9BAA").dxSelectBox("instance");
                                        if (selProduct) productID = selProduct.option("value");
                                    } catch(ex) {}
                                    if (!productID) {
                                        if (window.uiManager) uiManager.showAlert({ type: "warning", message: "%zalo_auto_select_software_warn%" });
                                        setTimeout(() => inst.option("value", null), 100);
                                        return;
                                    }
                                    if (typeof openFormParam === "function") {
                                        openFormParam("sp_zalo_sale_prompt");
                                    }
                                    setTimeout(() => inst.option("value", null), 100);
                                    return;
                                }
                                // ID = 4: Nút cài đặt thời gian chạy tự động từ AI Menu
                                if (menuID == 4) {
   openSetAutoPopup();
                                    setTimeout(() => inst.option("value", null), 100);
                                    return;
                                }
                                // ID = 5: Tác vụ Auto Spam (Toggle AllowAutoSpam)
                                if (menuID == 5) {
                                    AjaxHPAParadise({
                                        data: { name: "sp_zalo_toggleAllowAutoSpam", param: ["LoginID", UserID] },
                                        success: function(res) {
                                            try {
                                                let responseObj = typeof res === ''string'' ? JSON.parse(res) : res;
                                                let dataRes = null;
                                                if (responseObj && responseObj.data && responseObj.data[0] && responseObj.data[0][0]) {
                                                    dataRes = responseObj.data[0][0];
                                                } else if (Array.isArray(responseObj) && responseObj[0]) {
                                                    dataRes = responseObj[0];
                                                }
                                                if (dataRes && dataRes.hasOwnProperty("Result")) {
                                                    let newVal = dataRes.Result;
                                                    let alertMsg = dataRes.Msg;
                                                    if (!alertMsg) {
                                                        alertMsg = newVal == 1 ? "%zalo_ai_spam_enabled%" : "%zalo_ai_spam_disabled%";
                                                    }
                                                    if (window.uiManager) {
                                                        uiManager.showAlert({ type: newVal == 1 ? "success" : "info", message: alertMsg });
                                                    } else {
                                                        alert(alertMsg);
                                                    }

                                                    // Cập nhật lại dataSource tại chỗ để đổi trạng thái UI lập tức
                                                    let ds = inst.option("dataSource") || [];
                                                    let itemAnti = ds.find(i => i.Code === "AutoSpam");
                                                    if (itemAnti) {
                                                        itemAnti.StatusValue = newVal;
                                                        itemAnti.Name = (itemAnti.Name || "").split(" (")[0]; // Làm sạch Name để tránh dính dấu ngoặc cũ
                                                        inst.option("dataSource", ds); // refresh datasource
                                                    }
                                                }
                                            } catch(ex) {
                                                console.error("Toggle AutoSpam error:", ex);
                                            }
                                            setTimeout(() => inst.option("value", null), 100);
                                        },
                                        error: function() {
                                            setTimeout(() => inst.option("value", null), 100);
                                        }
                                    });
                                    return;
                                }
                                // Các tác vụ còn lại (ID = 1 hoặc 2) yêu cầu chọn người nhận
                                if (menuID == 6) {
                                    openAutoSpamConfigPopup();
                                    setTimeout(() => inst.option("value", null), 100);
                                    return;
                                }

                                let selectedIDs = customSelectedKeys_GridZalo.join(",");
                                console.log("?? taidang~ [call AI API] :", customSelectedKeys_GridZalo);
                                if (!selectedIDs) {
                                    if (window.uiManager) uiManager.showAlert({ type: "warning", message: "%zalo_warn_select_recipient_ai%" });
                                    setTimeout(() => inst.option("value", null), 100);
                                    return;
                                }
                                // ID = 2: Thử nghiệm (isTest = 1), ID = 1: Bắt đầu gửi (isTest = 0)
      let isTest = (menuID == 2 ? 1 : 0);
                                let category = e.itemData ? (e.itemData.ID || e.itemData.Code) : "";
                                // --- LOGIC XỬ LÝ AI ---
                                let productID = "";
                                try {
                                    let selProduct = $("#P36EB8FEA286C46F7A109BD6404CA9BAA").dxSelectBox("instance");
                                    if (selProduct) productID = selProduct.option("value");
                                } catch(ex) {}
                                const startAIExecution = async (isSampleVal, promptRuleText) => {
                                    window.zaloAIIsRunning = true;
                                    window.zaloAI_ActiveRequests = window.zaloAI_ActiveRequests || [];
                                    window._zaloAI_CurrentViewID = window._zaloAI_CurrentViewID || null;

                                    let isMinimized = false;
                                    let sharedTaskScheduleID = "TASK_" + Math.random().toString(36).substr(2, 9) + "_" + Date.now();
                                    let reqID = window.zaloAI_ActiveRequests.length > 0 ? (Math.max(...window.zaloAI_ActiveRequests.map(r => r.id)) + 1) : 1;
                                    let softwareName = "";
                                    try {
                                        softwareName = $("#P36EB8FEA286C46F7A109BD6404CA9BAA").find(".dx-texteditor-input").val() || "";
                                    } catch(e) {}
                                    let templateName = isSampleVal === 1 ? "%zalo_prompt_system_sample%" : "%zalo_prompt_personal_sample%";
                                    let newReq = {
                                        id: reqID,
                                        title: "Lượt yêu cầu " + reqID,
                                        softwareName: softwareName,
                                        templateName: templateName,
                                        taskScheduleID: sharedTaskScheduleID,
                                        startTime: Date.now(),
                                        total: 0,
                                        pending: 0,
                                        done: 0,
                                        isCancelled: false,
                                        isCompleted: false,
                                        hasError: false,
                                        timerInterval: null,
                                        pollInterval: null,
                                        finalHistoryData: null,
                                        finalResults: {},
                                        finalAiDebug: {},
                                        idArray: customSelectedKeys_GridZalo || [],
                                        isTest: isTest,
                                        productID: (function() {
                                            let sel = $("#P36EB8FEA286C46F7A109BD6404CA9BAA").dxSelectBox("instance");
                                            return sel ? sel.option("value") : null;
                                        })()
                                    };
                                    newReq.total = newReq.idArray.length;
                                    newReq.pending = newReq.idArray.length;

                                    window._currentTaskScheduleID = sharedTaskScheduleID;
                                    window._zaloAI_CurrentViewID = reqID;

                                    let $loadingPopup = $("#zalo-ai-loading-popup");
                                    if ($loadingPopup.length === 0) {
                                        $loadingPopup = $("<div id=''zalo-ai-loading-popup'' />").appendTo("body");
                                        $loadingPopup.dxPopup({
                                            title: "%zalo_ai_title_processing%",
                                            width: 350,
                                            height: "auto",
                                            visible: true,
                                            closeOnOutsideClick: false,
                                            showCloseButton: false,
                                            shading: false,
                                            toolbarItems: [{
                                                widget: "dxButton",
                                                toolbar: "top",
                                                location: "after",
                                                options: {
                                                    icon: "minus",
                                                    stylingMode: "text",
                                                    onClick: function() {
                                                        isMinimized = true;
                                                        $("#zalo-ai-loading-popup").dxPopup("instance").hide();
                                                        showZaloAIFab();
                                                    }
                                                }
                                            }],
                                            contentTemplate: function(content) {
                                                let $cont = $("<div style=''text-align:center; padding:10px 20px 20px 20px;'' />").appendTo(content);

                                                $("<div id=''ai-popup-task-selector-wrapper'' style=''margin-bottom:15px; display:none; text-align:left;'' />")
                                                    .append($("<label style=''font-size:12px; color:#aaa; margin-bottom:4px; display:block;''>Tiến trình đang chạy:</label>"))
                                                    .append($("<div id=''ai-popup-task-selector'' />"))
                                                    .appendTo($cont);

                                                $("<div style=''color:var(--paradise-color-header1); font-weight:bold; font-size:16px; margin-top:10px;'' />").text("%zalo_ai_processing%").appendTo($cont);
                                                $("<div id=''ai-popup-timer'' style=''font-size:24px; font-weight:bold; color:var(--paradise-color-logo-main); margin:15px 0;'' />").text("00:00").appendTo($cont);
                                                $("<div style=''margin-bottom:15px; font-size:13px; color:#666;'' />").text("%zalo_ai_estimated%").appendTo($cont);
                                                $("<div id=''ai-popup-progressbar'' />").dxProgressBar({
                                                    min: 0, max: 100, value: 0, statusFormat: () => "%zalo_ai_running%"
                                                }).appendTo($cont);

                                                $("<div style=''margin-top:20px;'' />").dxButton({
                                                    text: "%zalo_ai_cancel%", type: "danger", stylingMode: "outlined",
                                                    onClick: function() {
                                                        let viewReq = window.zaloAI_ActiveRequests.find(r => r.id === window._zaloAI_CurrentViewID);
                                                        if (!viewReq) return;

                                                        viewReq.isCancelled = true;
                                                        if (viewReq.timerInterval) clearInterval(viewReq.timerInterval);
                                                        if (viewReq.pollInterval) clearInterval(viewReq.pollInterval);

                                                        AjaxHPAParadise({
                                                            data: { name: "sp_AI_zalo_cancelRequest", param: ["TaskScheduleID", viewReq.taskScheduleID] }
                                                        });

                                                        if (window.uiManager) uiManager.showAlert({ type: "info", message: "Đã hủy " + viewReq.title });

                                                        window.zaloAI_ActiveRequests = window.zaloAI_ActiveRequests.filter(r => r.id !== viewReq.id);
                                                        refreshAIPopupUI();

                                                        if (window.zaloAI_ActiveRequests.length === 0) {
                                                            window.zaloAIIsRunning = false;
                                                            $("#zalo-ai-loading-popup").dxPopup("instance").hide();
                                                            removeZaloAIFab();
                                                            if (typeof hideLoading === ''function'') hideLoading();
                                                            if (typeof HPA !== "undefined" && HPA.hideLoading) HPA.hideLoading();
                                                            if (window.uiManager && window.uiManager.hideLoading) window.uiManager.hideLoading();
                                                        }
                                                    }
                                                }).appendTo($cont);
                                            }
                                        });
                                    } else {
                                        $loadingPopup.dxPopup("instance").show();
                                    }

                                    if (!newReq.productID || newReq.productID == 0) {
                                        if (window.zaloAI_ActiveRequests.length === 0) $loadingPopup.dxPopup("instance").hide();
                                        if (window.uiManager) uiManager.showAlert({ type: "warning", message: "%zalo_warn_no_software_ai%" });
                                        return;
                                    }

                                    window.zaloAI_ActiveRequests.push(newReq);

                                    for (let i = 0; i < newReq.idArray.length; i++) {
                                        newReq.finalAiDebug[newReq.idArray[i]] = promptRuleText || "";
                                    }

                                    refreshAIPopupUI();

                                    function refreshAIPopupUI() {
                                        let activeReqs = window.zaloAI_ActiveRequests;
                                        if (activeReqs.length === 0) return;

                                        let $wrap = $("#ai-popup-task-selector-wrapper");
                                        if (activeReqs.length > 1) {
                                            $wrap.show();
                                            let ds = activeReqs.map(r => ({ id: r.id, name: r.title + " (Đang xử lý: " + r.done + "/" + r.total + ")" }));
                                            let isInit = $("#ai-popup-task-selector").hasClass("dx-selectbox");
                                            if (!isInit) {
                                                $("#ai-popup-task-selector").dxSelectBox({
                                                    dataSource: ds,
                                                    displayExpr: "name",
                                                    valueExpr: "id",
                                                    value: window._zaloAI_CurrentViewID,
                                                    onValueChanged: function(e) {
                                                        window._zaloAI_CurrentViewID = e.value;
                                                        updatePopupProgressView();
                                                    }
                                                });
                                            } else {
                                                let selector = $("#ai-popup-task-selector").dxSelectBox("instance");
                                                selector.option("dataSource", ds);
                                                selector.option("value", window._zaloAI_CurrentViewID);
                                            }
                                        } else {
                                            $wrap.hide();
                                            window._zaloAI_CurrentViewID = activeReqs[0].id;
                                        }
                                        updatePopupProgressView();
                                    }

                                    function updatePopupProgressView() {
                                        let req = window.zaloAI_ActiveRequests.find(r => r.id === window._zaloAI_CurrentViewID);
                                        if (!req) return;

                                        let progress = req.total > 0 ? Math.round((req.done / req.total) * 100) : 0;
                                        let statusText = req.done + "/" + req.total;

                                        $("#ai-popup-info-box").show();
                                        $("#ai-popup-info-software").text((req.softwareName || "Chưa xác định"));
                                        $("#ai-popup-info-template").text((req.templateName || ""));

                                        let pBar = $("#ai-popup-progressbar").dxProgressBar("instance");
                                        if (pBar) {
                                            pBar.option("value", req.isCompleted ? 100 : progress);
                                            pBar.option("statusFormat", () => (req.isCompleted ? "Hoàn thành " : "%zalo_ai_processing_progress% ") + statusText);
                                        }
                                        if (req.isCompleted && $("#zalo-ai-loading-popup").is(":visible")) {
                                            $("#zalo-ai-loading-popup").find("div[style*=''color: #22c55e'']").text("%zalo_ai_completed_status%");
                                        }

                                        if (!req.isCompleted && req.startTime) {
                                            let diff = Math.floor((Date.now() - req.startTime) / 1000);
                                            let m = Math.floor(diff / 60).toString().padStart(2, ''0'');
                                            let s = (diff % 60).toString().padStart(2, ''0'');
                                            $("#ai-popup-timer").text(m + ":" + s);
                                        }
                                    }

                                    newReq.timerInterval = setInterval(function() {
                                        if (newReq.isCancelled || newReq.isCompleted) {
                                            clearInterval(newReq.timerInterval);
                                            return;
                                        }
                                        if (window._zaloAI_CurrentViewID === newReq.id) {
                                            let diff = Math.floor((Date.now() - newReq.startTime) / 1000);
                                            let m = Math.floor(diff / 60).toString().padStart(2, ''0'');
                                            let s = (diff % 60).toString().padStart(2, ''0'');
                                            let timeStr = m + ":" + s;
                                            $("#ai-popup-timer").text(timeStr);
                                            let $fab = $("#zalo-ai-fab-loading");
                                            if ($fab.length && isMinimized) $fab.find(".toast-time").text(timeStr);
                                        }
                                    }, 1000);

                                    function showZaloAIFab() {
                                        $("#zalo-ai-fab-loading").remove();
                                        let $fab = $("<div id=''zalo-ai-fab-loading'' style=''position:absolute; bottom:30px; left:50%; transform:translateX(-50%); z-index:9999; background-color:var(--bs-body-bg); border-left:4px solid var(--paradise-color-logo-main); box-shadow:0 4px 15px rgba(0,0,0,0.3); border-radius:8px; width:280px; padding:15px; cursor:pointer; transition:all 0.3s ease; display:flex; flex-direction:column; gap:8px;'' />").appendTo($(".sp_zalo_autoSendMessage"));
                                        $("<div style=''display:flex; justify-content:space-between; align-items:center;''><span style=''font-weight:bold; color:var(--paradise-color-header1, #fff);''>%zalo_ai_processing%</span><i class=''dx-icon-chevronsup'' style=''font-size:18px; color:#aaa;''></i></div>").appendTo($fab);
                                        $("<div style=''display:flex; justify-content:space-between; align-items:center;''><span class=''toast-progress'' style=''font-size:13px; color:var(--paradise-color-brown, #bbb);''></span><span class=''toast-time'' style=''font-size:14px; font-weight:bold; color:var(--paradise-color-logo-main);''>00:00</span></div>").appendTo($fab);
                                        $fab.on("click", function() {
                                            $fab.remove();
                                            isMinimized = false;
                                            let req = window.zaloAI_ActiveRequests.find(r => r.id === window._zaloAI_CurrentViewID);
                                            if (req && req.isCompleted && req.finalHistoryData) {
                                                $("#zalo-ai-loading-popup").dxPopup("instance").hide();
                                                showAIHistoryDetail(req.finalHistoryData);
                                            } else {
                                                $("#zalo-ai-loading-popup").dxPopup("instance").show();
                                            }
                                        });
                                    }
                                    function updateZaloAIFab(text, isDone) {
                                        let $fab = $("#zalo-ai-fab-loading");
                                        if ($fab.length > 0) {
                                            $fab.find(".toast-progress").text(isDone ? "%zalo_ai_done_send%" : text).css(isDone ? {color: "var(--paradise-color-logo-main)", fontWeight: "bold"} : {});
                                        }
                                    }
                                    function removeZaloAIFab() {
                                        if (window.zaloAI_ActiveRequests.length === 0) $("#zalo-ai-fab-loading").remove();
                                    }

                                    let processSingleId = function(singleID, currentIndex) {
                                        return new Promise((resolve) => {
                                            if (newReq.isCancelled) { resolve("CANCELLED"); return; }
                                            if (isMinimized && window._zaloAI_CurrentViewID === newReq.id) {
                                                updateZaloAIFab((currentIndex + 1) + "/" + newReq.total, false);
                                            }
                                            AjaxHPAParadise({
                                                data: {
                                                    name: "sp_AI_zalo_createManualRequest",
                                                    param: [
                                                        "LoginID", UserID,
                                                        "ZaloID", singleID,
                                                        "ProductID", newReq.productID,
                                                        "MessageContent", "",
                                                        "SourceType", newReq.isTest ? "UI_Test" : "Manual",
                                                        "IsAutoSpamCheck", 0,
                                                        "TaskScheduleID", newReq.taskScheduleID,
                                                        "typeMessage", ($(''#tab-groups'').hasClass(''active'') ? 1 : 0),
                                                        "clientID", (typeof connection !== "undefined" && connection && connection.id) ? connection.id : '''',
                                                        "IsSample", isSampleVal
                                                    ]
                                                },
                                                isShowLoading: false, showLoading: false, global: false,
                                                success: function(res) { if (newReq.isCancelled) resolve("CANCELLED"); else resolve("OK"); },
                                                error: function(err) { newReq.hasError = true; resolve("ERROR"); }
                                            });
                                        });
                                    };

                                    let promises = [];
                                    for (let i = 0; i < newReq.idArray.length; i++) {
                                        if (newReq.isCancelled || newReq.hasError) break;
                                        promises.push(processSingleId(newReq.idArray[i], i));
                                    }
                                    await Promise.all(promises);

                                    if (newReq.isCancelled) return;
                                    if (newReq.hasError) {
                                        clearInterval(newReq.timerInterval);
                                        window.zaloAI_ActiveRequests = window.zaloAI_ActiveRequests.filter(r => r.id !== newReq.id);
                                        refreshAIPopupUI();
                                        if (window.zaloAI_ActiveRequests.length === 0) {
                                            $("#zalo-ai-loading-popup").dxPopup("instance").hide();
                                            removeZaloAIFab();
                                            window.zaloAIIsRunning = false;
                                        }
                                        if (window.uiManager) uiManager.showAlert({ type: "error", message: "%zalo_ai_error_system%" });
                                        return;
                                    }

                                   
                                     if (newReq.pollInterval) clearInterval(newReq.pollInterval);
                                     newReq.pollInterval = setInterval(() => checkProgressLogicForReq(newReq), 3000);

                                    function checkProgressLogicForReq(req) {
                                        if (!req || req.isCancelled || req.isCompleted) {
                                            if (req && req.pollInterval) { clearInterval(req.pollInterval); req.pollInterval = null; }
                                            if (req && req.timerInterval) { clearInterval(req.timerInterval); req.timerInterval = null; }
                                            return;
                                        }
                                        AjaxHPAParadise({
                                            data: { name: "sp_AI_zalo_checkProgress", param: ["TaskScheduleID", req.taskScheduleID] },
                                            isShowLoading: false, showLoading: false, global: false,
                                            success: function(progressRes) {
                                                if (!req || req.isCancelled || req.isCompleted) {
                                                    if (req && req.pollInterval) { clearInterval(req.pollInterval); req.pollInterval = null; }
                                                    if (req && req.timerInterval) { clearInterval(req.timerInterval); req.timerInterval = null; }
                                                    return;
                                                }
                                                let progJson = typeof progressRes === ''string'' ? JSON.parse(progressRes) : progressRes;
                                                let summary = (progJson && progJson.data && progJson.data[0] && progJson.data[0][0]) ? progJson.data[0][0] : null;
                                                if (summary) {
                                                    req.pending = summary.PendingCount || 0;
                                                    req.done = summary.DoneCount || 0;
                                                    req.total = req.pending + req.done;
                                                    refreshAIPopupUI();

                                                    if (req.pending === 0) {
                                                        req.isCompleted = true;
                                                        if (req.pollInterval) { clearInterval(req.pollInterval); req.pollInterval = null; }
                                                        if (req.timerInterval) { clearInterval(req.timerInterval); req.timerInterval = null; }
                                                        updatePopupProgressView();

                                                        setTimeout(function() {
                                                            let rawItems = (progJson && progJson.data && progJson.data[1]) ? progJson.data[1] : [];
                                                            if (req.isTest) {
                                                                let testResults = {};
                                                                rawItems.forEach(item => {
                                                                    testResults[item.ZaloID] = item.AI_Message;
                                                                    if (item.GeneratedMessage) req.finalAiDebug[item.ZaloID] = item.GeneratedMessage;
                                                                });
                                                                let now = new Date();
                                                                let timeStr = now.getHours().toString().padStart(2, ''0'') + ":" + now.getMinutes().toString().padStart(2, ''0'') + ":" + now.getSeconds().toString().padStart(2, ''0'');
                                                                let historyItem = { id: aiHistory_Log.length + 1, timestamp: timeStr, prompt: req.finalAiDebug || "", results: testResults };
                                                                aiHistory_Log.unshift(historyItem);
                                                                updateAIDebugIcon();
                                                                req.finalHistoryData = historyItem;

                                                                window.zaloAI_ActiveRequests = window.zaloAI_ActiveRequests.filter(r => r.id !== req.id);
                                                                refreshAIPopupUI();
                                                                if (window.zaloAI_ActiveRequests.length === 0) {
                                                                    window.zaloAIIsRunning = false;
                                                                    try { $("#zalo-ai-loading-popup").dxPopup("instance").hide(); } catch(e){}
                                                                    removeZaloAIFab();
                                                                }
                                                                showAIHistoryDetail(historyItem);
                                                                if (window.uiManager) uiManager.showAlert({ type: "success", message: "%zalo_ai_done_test%" });
                                                            } else {
                                                                if (window.uiManager) uiManager.showAlert({ type: "success", message: "%zalo_ai_done_send%" });
                                                                if (window.gridInstance) {
                                                                    setCustomSelectedKeys_GridZalo([]);
                                                                    safeRepaintGrid(gridInstance, true);
                                                                }
                                                                window.zaloAI_ActiveRequests = window.zaloAI_ActiveRequests.filter(r => r.id !== req.id);
                                                                refreshAIPopupUI();
                                                                if (window.zaloAI_ActiveRequests.length === 0) {
                                                                    window.zaloAIIsRunning = false;
                                                                    try { $("#zalo-ai-loading-popup").dxPopup("instance").hide(); } catch(e){}
                                                                    removeZaloAIFab();
                                                                }
                                                            }
                                                        }, 1500);
                                                    }
                                                }
                                            }
                                        });
                                    }

                                    // Removed duplicate 120s interval
                                };
                                // Kiểm tra Prompt cá nhân trước khi thực hiện
                                if (productID) {
                                    AjaxHPAParadise({
                                        data: {
                                            name: "sp_zalo_sale_rule_crud",
                                            param: ["LoginID", UserID, "ActionType", "SELECT", "productID", productID]
                                        },
                                        success: function(res) {
                                            let jsonRes = typeof res === "string" ? JSON.parse(res) : res;
                                            let personalData = (jsonRes && jsonRes.data && jsonRes.data[0]) ? jsonRes.data[0] : [];
                                            let systemData = (jsonRes && jsonRes.data && jsonRes.data[1]) ? jsonRes.data[1] : [];
                                            let hasPersonal = personalData.length > 0 && personalData[0].Rule;

                                            // Tạo popup động cho người dùng chọn
                                            let $promptPopup = $("<div id=''zalo-prompt-choice-popup'' />").appendTo("body");
                                            let promptPopupInst = $promptPopup.dxPopup({
                                                title: "%zalo_prompt_select_title%",
                                                width: 420,
                                                height: "auto",
                                                visible: true,
                                                showCloseButton: true,
                                                closeOnOutsideClick: true,
                                                onHidden: function() {
                                                    // Hủy bỏ: reset SelectBox nếu tắt popup mà chưa chọn gì
                                                    setTimeout(function() { inst.option("value", null); }, 100);
                                                    $promptPopup.remove();
                                                },
                                                contentTemplate: function(contentElement) {
                                                    let $cont = $("<div style=''padding:15px; font-size:14px; line-height:1.6; text-align:center;'' />").appendTo(contentElement);
                                                    $("<div style=''margin-bottom:20px; font-weight:bold; color:var(--paradise-color-header1);'' />")
                                                        .html("%zalo_prompt_select_desc%")
                                                        .appendTo($cont);

                                                    let $btnGroup = $("<div style=''display:flex; justify-content:center; gap:15px; margin-top:20px;'' />").appendTo($cont);

                                                    // Nút "Mẫu cá nhân"
                                                    $("<div />").dxButton({
                                                        text: "%zalo_prompt_personal_sample%",
                                                        type: "default",
                                                        stylingMode: "contained",
                                                        onClick: function() {
                                                            if (!hasPersonal) {
                                                                if (window.uiManager) {
                                                                    uiManager.showAlert({ type: "warning", message: "%zalo_warn_no_personal_prompt%" });
                                                                } else {
                                                                    alert("%zalo_warn_no_personal_prompt%");
                                                                }
                                                                promptPopupInst.hide();
                                                            } else {
                                                                promptPopupInst.hide();
                                                                startAIExecution(0, personalData[0] ? personalData[0].Rule : ""); // Mẫu riêng (IsSample = 0)
                                                            }
                                                        }
                                                    }).appendTo($btnGroup);

                                                    // Nút "Mẫu hệ thống"
                                                    $("<div />").dxButton({
                                                        text: "%zalo_prompt_system_sample%",
                                                        type: "normal",
                                                        stylingMode: "contained",
                                                        onClick: function() {
                                                            promptPopupInst.hide();
                                                            startAIExecution(1, systemData[0] ? systemData[0].Rule : ""); // Mẫu hệ thống (IsSample = 1)
                                                        }
                                                    }).appendTo($btnGroup);
                                                }
                                            }).dxPopup("instance");
                                        },
                                        error: function() { startAIExecution(1, ""); }
                                    });
                                } else {
                                    startAIExecution(1, "");
                                }
                                // Reset SelectBox về null sau khi click
                                setTimeout(function() {
                                    inst.option("value", null);
                                }, 100);
                            });
                        }
                    }
                    // Nút Clock đã được chuyển vào AI Menu
                    // Gán sự kiện click cho Checkbox header (Select All)
                    $(document).off("change", "#chk_select_all_zalo").on("change", "#chk_select_all_zalo", function() {
                        // Lưu ý: với dxCheckBox thì dùng onValueChanged bên trong template sẽ tốt hơn
                        // nhưng ở đây ta dùng DOM event cho gọn vì template đang dùng dxCheckBox
                    });
                },
                onRowPrepared: function(e) {
                    if (e.rowType === "data") {
                        const rowKey = getZaloRowKey(e.data, e.key);
                        const isSelected = customSelectedKeys_GridZalo.some(function(k) { return k.toString() === rowKey; });
                        if (isSelected) {
                            $(e.rowElement).addClass("dx-selection");
                        } else {
                            $(e.rowElement).removeClass("dx-selection");
                        }
                        if (e.data && (e.data.isHide === 1 || e.data.isHide === "1")) {
                            $(e.rowElement).hide();
                        } else {
                            $(e.rowElement).show();
                            $(e.rowElement).css("visibility", "visible");
                        }
                    }
                },
                "customizeColumns": function (columns) {
                    let hasCustomCol = columns.some(function(c) { return c.name === "ChonCustom"; });
                    if (!hasCustomCol) {
                        columns.unshift({
                            name: "ChonCustom",
                            caption: "",
                            width: 50,
                            alignment: "center",
                            fixed: true,
                            fixedPosition: "left",
                            cssClass: "dx-command-select",
                            headerCellTemplate: function(container) {
                                $("<div>").attr("id", "chk_select_all_zalo").appendTo(container).dxCheckBox({
                                    value: isSelectAllActive_GridZalo,
                                    onValueChanged: function(args) {
                                        if (args.event) {
                                            if (args.value) {
                                                applySelectionLogic(-1);
                                            } else {
                                                setCustomSelectedKeys_GridZalo([]);
                                                isSelectAllActive_GridZalo = false;
                                                safeRepaintGrid(window.gridInstance);
                                            }
                                        }
                                    }
                                });
                            },
                            cellTemplate: function(container, options) {
                                let rowKey = getZaloRowKey(options.data, options.key);
                                let isChecked = customSelectedKeys_GridZalo.some(function(k) { return k.toString() === rowKey; });
                                $("<div>").dxCheckBox({
                                    value: isChecked,
                                    onValueChanged: function(e) {
                                         // Chỉ xử lý khi người dùng click thủ công
                                        const index = customSelectedKeys_GridZalo.findIndex(function(k) { return k.toString() === rowKey; });
                                        if (e.value && index === -1) {
                                            customSelectedKeys_GridZalo.push(rowKey);
                                            //console.log("?? taidang~ [Checkbox TICK] :", customSelectedKeys_GridZalo);
                                        } else if (!e.value && index > -1) {
                                            customSelectedKeys_GridZalo.splice(index, 1);
                                            //console.log("?? taidang~ [Checkbox UNTICK] :", customSelectedKeys_GridZalo);
                                        }
                                        // Thêm/Xóa class dx-selection ngay lập tức để đổi màu nền không cần reload Grid
              let $row = container.closest(".dx-row");
                                        if (e.value) {
                                            $row.addClass("dx-selection");
                                        } else {
                                            $row.removeClass("dx-selection");
                                        }
                                    }
                                }).appendTo(container);
                            }
                        });
                    }
                    // 1. Column: ZaloName (Combines Avatar, Name, and ZaloID)
                    columns.forEach(function (column) {
                        if (column.command === "select") {
                            column.width = 50;
                        }
                        if (column.dataField === "zaloID") {
                            column.visible = false;
                        }
                        if (column.dataField === "memVerList") {
                            column.visible = false;
                        }
                        if (column.dataField === "avatar") {
                            column.visible = false; // Hidden as it is merged with ZaloName
                        }
                        if (column.dataField === "zaloName") {
                            column.caption = "%zalo_grid_friends%";
                            column.visibleIndex = 1;
                            column.width = "auto";
                            column.minWidth = 250;
                            column.cellTemplate = function(container, options) {
                                let val = options.value || "";
                                let isGroup = options.data.isGroup;
                                let zaloID = options.data.zaloID;
                                let $cell = $("<div style=''display: flex; align-items: center; gap: 12px; padding: 4px 0;'' />");
                                // Render Avatar
                                let $avatar = $("<div />").css({
                                    "width": "40px",
                                    "height": "40px",
                                    "border-radius": "50%",
                                    "overflow": "hidden",
                                    "flex-shrink": 0,
                                    "display": "flex",
                                    "align-items": "center",
                                    "justify-content": "center",
                                    "background": "#f1f5f9"
                                });
                                let avatarUrl = options.data.avatar;
                                if (avatarUrl) {
                                    let $img = $("<img />").attr("src", avatarUrl).css({ "width": "100%", "height": "100%", "object-fit": "cover" });
                                    $img.on("error", function() {
                                        $(this).hide();
                                        if ($(this).parent().find("i.dx-icon").length === 0) {
                                            $(this).parent().append("<i class=''dx-icon " + (options.data.isGroup == 1 ? "dx-icon-group" : "dx-icon-user") + "'' style=''color:#94a3b8; font-size: 20px;''></i>");
                                        }
                                        if (!window._avatarRetryRequested) window._avatarRetryRequested = {};
                                        let uid = options.data.zaloID;
                                        if (!uid || window._avatarRetryRequested[uid]) return;
                                        window._avatarRetryRequested[uid] = true;
                                        let isGroup = options.data.isGroup;
                                        let phone = options.data.PhoneNumber;
                                        if (isGroup == 1) {
                                            AjaxHPAParadise({
                                                data: { name: "sp_CallAPIZalo", param: ["LoginID", UserID, "CallFunction", "getGroupInfo", "uid", uid] },
                                                success: function(r) {
                                                    try {
                                                        let resData = typeof r === "string" ? JSON.parse(r) : r;
                                                        if (resData.result === "success" && resData.data) {
                                                            let rawData = typeof resData.data === "string" ? JSON.parse(resData.data) : resData.data;
                                                            let groupInfo = Array.isArray(rawData) ? (rawData.length > 0 ? (Array.isArray(rawData[0]) ? rawData[0][0] : rawData[0]) : null) : rawData;
                                                            if (groupInfo && groupInfo.avatar) {
                                                                let newAvatar = groupInfo.avatar;
                                                                let newUid = groupInfo.groupId || uid;
                                                                $img.attr("src", newAvatar).show();
                                                                $img.parent().find("i.dx-icon").hide();

                                                                AjaxHPAParadise({ data: { name: "sp_zalo_updateAvatar", param: ["LoginID", UserID, "ZaloID", newUid, "AvatarUrl", newAvatar, "IsGroup", 1] }});
                                                            }
                                                        }
                                                    } catch(err) { console.error("Parse getGroupInfo error:", err); }
                                                },
                                            });
                                        } else if (phone && phone.trim() !== "") {
                                            let paramData = { phones: [phone.trim()] };
                                            AjaxHPAParadise({
                                                data: { name: "sp_CallAPIZalo", param: ["LoginID", UserID, "CallFunction", "getMultiUsersByPhones", "DataNeed", JSON.stringify(paramData)] },
                                                success: function(r) {
                                                    try {
                                                        let resData = typeof r === "string" ? JSON.parse(r) : r;
                                                        if (resData.result === "success" && resData.data) {
                                                            let rawData = typeof resData.data === "string" ? JSON.parse(resData.data) : resData.data;
                                                            let userInfo = Array.isArray(rawData) ? (rawData.length > 0 ? (Array.isArray(rawData[0]) ? rawData[0][0] : rawData[0]) : null) : rawData;
                                                            if (userInfo && userInfo.avatar) {
                                                                let newAvatar = userInfo.avatar;
                                                                let newUid = userInfo.uid || uid;
                                                                $img.attr("src", newAvatar).show();
                                                                $img.parent().find("i.dx-icon").hide();
                                                                AjaxHPAParadise({ data: { name: "sp_zalo_updateAvatar", param: ["LoginID", UserID, "ZaloID", newUid, "AvatarUrl", newAvatar, "IsGroup", 0] }});
                                                            }
                                                        }
                                                    } catch(err) { console.error("Parse getMultiUsersByPhones error:", err); }
                                                },
                                            });
                                        } else {
                                            AjaxHPAParadise({
                                                data: { name: "sp_CallAPIZalo", param: ["LoginID", UserID, "CallFunction", "getUserInfo", "uid", uid] },
                                                success: function(r) {
                                                    try {
                                                        let resData = typeof r === "string" ? JSON.parse(r) : r;
                                                        if (resData.result === "success" && resData.data) {
                                                            let rawData = typeof resData.data === "string" ? JSON.parse(resData.data) : resData.data;
                                                            let userInfo = Array.isArray(rawData) ? (rawData.length > 0 ? (Array.isArray(rawData[0]) ? rawData[0][0] : rawData[0]) : null) : rawData;
                                                            if (userInfo && userInfo.avatar) {
                                                                let newAvatar = userInfo.avatar;
                                                                let newUid = userInfo.uid || uid;
                                                                $img.attr("src", newAvatar).show();
                                                                $img.parent().find("i.dx-icon").hide();
                                                                AjaxHPAParadise({ data: { name: "sp_zalo_updateAvatar", param: ["LoginID", UserID, "ZaloID", newUid, "AvatarUrl", newAvatar, "IsGroup", 0] }});
                                                            }
                                                        }
                                                    } catch(err) { console.error("Parse getUserInfo error:", err); }
                                                },
                                            });
                                        }
                                    });
                                    $img.appendTo($avatar);
                                } else if (isGroup == 1) {
                                    // Group Avatar members
                                    let memData = options.data.memVerList;
                                    let avatars = [];
                                    try {
                                        let members = [];
                                        if (typeof memData === "string") {
                                            if (memData.trim().startsWith("[")) members = JSON.parse(memData);
                                            else members = memData.split(",").map(s => s.trim());
                                        }
                                        for(let i = 0; i < members.length; i++) {
                                            let id = members[i].split("_")[0];
                                            if (friendAvatarMap[id]) {
                                                avatars.push(friendAvatarMap[id]);
                                                if (avatars.length >= 4) break;
                                            }
                                        }
                                    } catch(e) {}
                                    if (avatars.length > 0) {
                                        $avatar.css({ "flex-wrap": "wrap", "background": "#e2e8f0" });
                                        let size = avatars.length >= 3 ? "50%" : (avatars.length == 2 ? "50%" : "100%");
                                        avatars.forEach(function(url) {
                                            $("<img />").attr("src", url).css({ "width": size, "height": (avatars.length == 2) ? "100%" : size, "object-fit": "cover" }).appendTo($avatar);
                                        });
                                    } else {
                                        $avatar.html("<i class=''dx-icon dx-icon-group'' style=''color:#94a3b8; font-size: 20px;''></i>");
                                    }
                                } else {
                                    $avatar.html("<i class=''dx-icon dx-icon-user'' style=''color:#94a3b8; font-size: 20px;''></i>");
                                }
                                $avatar.appendTo($cell);
                                // Render Text Name and Email/ID
                                let $text = $("<div style=''display: flex; flex-direction: column; gap: 2px; min-width: 0;'' />"); $("<span style=''font-weight: 600;  font-size: 14px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;'' />").text(val).appendTo($text);
                                $text.appendTo($cell);
                                $cell.appendTo(container);
                            };
                        }
                    });
                                        // 5. Custom NotSpam column (Cá nhân / Bạn bè / Khách hàng)
                    let hasNotSpamCol = columns.some(function(c) { return c.name === "notSpamCol"; });
                    if (!hasNotSpamCol) {
                        columns.splice(2, 0, {
                            name: "notSpamCol", dataField: "notSpam", dataType: "boolean",
                            caption: "%zalo_notSpam%",
                            visible: true,
                            width: 100,
                            alignment: "center",
                            cellTemplate: function(container, options) {
                                let val = options.data.notSpam;
                                let isChecked = (val == 1 || val == true);
                                let isGroup = options.data.isGroup == 1 ? 1 : 0;
                                $("<div>").dxCheckBox({
                                    value: isChecked,
                                    onValueChanged: function(e) {
                                        let newVal = e.value ? 1 : 0;
                                        options.data.notSpam = newVal;
                                        let targetID = options.data.zaloID || options.data.userId || options.data.uid || options.data.groupId || options.data.ZaloID;
                                        AjaxHPAParadise({
                                            data: {
                                                name: "sp_zalo_updateNotSpam",
                                                param: ["LoginID", UserID, "ZaloID", targetID, "notSpam", newVal, "IsGroup", isGroup]
                                            }
                                        });
                                    }
                                }).appendTo(container);
                            }
                        });
                    }
                    /* Removed Status Column */
                    // 5. Custom AutoSpam column
                    let hasCheckSpamCol = columns.some(function(c) { return c.name === "checkSpamCol"; });
                    if (!hasCheckSpamCol) {
                        columns.splice(2, 0, {
                            name: "checkSpamCol", dataField: "AllowCheckSpam", dataType: "boolean",
                            caption: "%zalo_check_spam%",
                            visible: true,
                            width: 80,
                            alignment: "center",
                            cellTemplate: function(container, options) {
                                let val = options.data.AllowCheckSpam;
                                let isChecked = (val == 1 || val == true);
                                let isGroup = options.data.isGroup == 1 ? 1 : 0;
                                $("<div>").dxCheckBox({
                                    value: isChecked,
                                    onValueChanged: function(e) {
                                        let newVal = e.value ? 1 : 0;
                                        options.data.AllowCheckSpam = newVal;
                                        let targetID = options.data.zaloID || options.data.userId || options.data.uid || options.data.groupId || options.data.ZaloID;
                                        AjaxHPAParadise({
                                            data: {
                                                name: "sp_zalo_updateAllowCheckSpam",
                                                param: ["LoginID", UserID, "ZaloID", targetID, "AllowCheckSpam", newVal, "IsGroup", isGroup]
                                            }
                                        });
                                    }
                                }).appendTo(container);
                            }
                        });
                    }
                    // 3. Custom tag list column
                    columns.forEach(function (column) {
                        if (column.dataField === "tag") {
                            column.caption = "%zalo_grid_category%";
                            column.visibleIndex = 3;
                            column.minWidth = 160;
                            column.allowFiltering = false;
                            column.headerFilter = { visible: false };
                            column.cellTemplate = function (container, options) {
                                let val = options.data.tag || "";
                                let ids = val ? val.split(/[ ,]+/).filter(function(x) { return x.trim(); }) : [];
                                let tagList = P36EB8FEA286C46F7A109BD6404CA9BAA_data || [];
                                let $div = $("<div style=''display:flex; align-items:center; flex-wrap:wrap; gap:4px; cursor:pointer;'' />");
                                if (ids.length === 0) {
                                    $("<span style=''color: #94a3b8; font-size: 12px; font-style: italic; border: 1px dashed #cbd5e1; padding: 2px 8px; border-radius: 4px; display: inline-block;'' />")
                                        .text("+ Tag")
                                        .on("click", function(e) {
                                            e.stopPropagation();
                                            openTagMenu(e.currentTarget, options.data);
                                        })
                                        .appendTo(container);
                                } else {
                                    let colors = [
                                        { bg: "#dcfce7", text: "#15803d" }, // Khách VIP / Đã chốt
                                        { bg: "#eff6ff", text: "#1d4ed8" }, // Khách mới
                                        { bg: "#fef3c7", text: "#b45309" }, // Quan tâm cao
                                        { bg: "#fef2f2", text: "#b91c1c" }  // Chỉ báo giá
                                    ];
                                    ids.forEach(function(id, idx) {
                                        let cleanId = id.replace("#", "").trim();
                                        let tag = tagList.find(function(x) { return x.ID.toString() === cleanId; });
                                        let displayText = tag ? tag.Name : id.trim();
                                        // Specific tags assignment matching design image
                                        let colorPair = colors[idx % colors.length];
                                        if (displayText.includes("VIP") || displayText.includes("ch?t")) {
                                            colorPair = colors[0];
                                        } else if (displayText.includes("m?i")) {
                                            colorPair = colors[1];
                                        } else if (displayText.includes("cao")) {
                                            colorPair = colors[2];
                                        } else if (displayText.includes("giá")) {
                                            colorPair = colors[3];
                                        }
                                        $("<span></span>")
                                            .text(displayText)
                                            .css({
                                                "background-color": colorPair.bg,
                                                "color": colorPair.text,
                                                "padding": "2px 8px",
                                                "border-radius": "12px",
                                                "font-size": "11px",
                                                "font-weight": "500",
                                                "white-space": "nowrap",
                                                "display": "inline-block"
                                            })
                                            .appendTo($div);
                                    });
                                    $div.on("click", function(e) {
                                        e.stopPropagation();
                                        openTagMenu(e.currentTarget, options.data);
                                    });
                                    $div.appendTo(container);
                                }
                            };
                        }
                    });
                    // 4. Custom Phone Column
                    let hasPhoneCol = columns.some(function(c) { return c.name === "PhoneCustom"; });
                    if (!hasPhoneCol) {
                        columns.splice(4, 0, {
                            name: "PhoneCustom", dataField: "PhoneNumber", dataType: "string",
                            caption: "%zalo_grid_phone%",
                            width: 130,
                            alignment: "center",
                            cellTemplate: function(container, options) {
                                let phone = (options.data.PhoneNumber || "").toString().trim();

                                if (phone) {
                                    $("<span title=''%zalo_click_to_copy%'' style=''color: var(--bs-primary); font-size: 13px; font-weight: 500; cursor: pointer; text-decoration: underline;'' />")
                                        .text(phone)
                                        .on(''click'', function() {
                                            navigator.clipboard.writeText(phone);
                                            DevExpress.ui.notify("%zalo_copied% " + phone, "success", 1500);
                                        })
                                        .appendTo(container);
                                }
                            }
                        });
                    }
/* Removed Platform Column */
/* Removed Details Column */
/* Removed Actions Column */
                }
            });
            gridInstance.option("onOptionChanged", function (e) {
                if (e.name === "searchPanel" && e.fullName === "searchPanel.text") {
                    _currentKeyword = (e.value || "").trim();
                    _pageCache = {};
                }
          });
            gridInstance.endUpdate();
            // Bind Custom Tabs Click events to filter Grid data
            $("#tab-friends").on("click", function() {
                $(".zalo-tab-item").removeClass("active");
                $(this).addClass("active");
                if (window.clearZaloSelectionFull) window.clearZaloSelectionFull();
                let grid = $("#GridZalo").dxDataGrid("instance");
                if (grid) {
                    try { grid.beginUpdate(); } catch(e){}
                    grid.filter(["isGroup", "=", 0]);
                    grid.columnOption("tag", "width", "18%");
                    grid.columnOption("PhoneCustom", "visible", true);
                    grid.columnOption("notSpamCol", "visible", true);
                    grid.columnOption("checkSpamCol", "visible", false);
                    grid.clearSorting();
                    grid.columnOption("notSpamCol", "sortOrder", "asc");
                    try { grid.endUpdate(); } catch(e){}
                    grid.refresh();
                }
            });
            $("#tab-groups").on("click", function() {
                $(".zalo-tab-item").removeClass("active");
                $(this).addClass("active");
                if (window.clearZaloSelectionFull) window.clearZaloSelectionFull();
                let grid = $("#GridZalo").dxDataGrid("instance");
                if (grid) {
                    try { grid.beginUpdate(); } catch(e){}
                    grid.filter(["isGroup", "=", 1]);
                    grid.columnOption("tag", "width", "34%");
                    grid.columnOption("PhoneCustom", "visible", false);
                    grid.columnOption("notSpamCol", "visible", false);
                    grid.columnOption("checkSpamCol", "visible", true);
                    grid.clearSorting();
                    grid.columnOption("checkSpamCol", "sortOrder", "desc");
                    try { grid.endUpdate(); } catch(e){}
                    grid.refresh();
                }
            });
            $("#tab-invites").on("click", function() {
                $(".zalo-tab-item").removeClass("active");
                $(this).addClass("active");
                if (window.clearZaloSelectionFull) window.clearZaloSelectionFull();
                let grid = $("#GridZalo").dxDataGrid("instance");
                if (grid) {
                    try { grid.beginUpdate(); } catch(e){}
                    grid.filter(["isGroup", "=", -1]);
                    grid.columnOption("tag", "width", "18%");
                    grid.columnOption("PhoneCustom", "visible", true);
                    grid.columnOption("notSpamCol", "visible", true);
                    grid.columnOption("checkSpamCol", "visible", false);
                    grid.clearSorting();
                    grid.columnOption("notSpamCol", "sortOrder", "asc");
                    try { grid.endUpdate(); } catch(e){}
                    grid.refresh();
                }
            });
            // Set default filter to show Friends on load
            setTimeout(function() {
                let grid = $("#GridZalo").dxDataGrid("instance");
                if (grid) {
                    try { grid.beginUpdate(); } catch(e){}
                    grid.filter(["isGroup", "=", 0]);
                    grid.columnOption("notSpamCol", "visible", true);
                    grid.columnOption("checkSpamCol", "visible", false);
                    grid.clearSorting();
                    grid.columnOption("notSpamCol", "sortOrder", "asc");
                    try { grid.endUpdate(); } catch(e){}
                }
                // Fetch and update Badge Counts dynamically
                AjaxHPAParadise({
                    data: {
                        name: "sp_zalo_Grid",
                        param: ["LoginID", UserID]
                    },
                    success: function (res) {
                        const json = typeof res === "string" ? JSON.parse(res) : res;
                        const results = Array.isArray(json?.data?.[0]) ? json.data[0] : [];
                        let friends = results.filter(x => x.isGroup == 0).length;
                        let groups = results.filter(x => x.isGroup == 1).length;
                        let invites = results.filter(x => x.isGroup == -1).length;
                        $("#badge-friends-count").text(friends);
                        $("#badge-groups-count").text(groups);
                        $("#badge-invites-count").text(invites);
                    }
                });
            }, 300);
            // ============================================================
            // 3. HÀM RELOAD DATA TỐI GIẢN VÀ XỬ LÝ POPUP
            // ============================================================
            window.zalo_chat_openSalutationPopup = function(rowData) {
                if (!rowData || !rowData.zaloID) return;
                var receiver = {
                    uid: rowData.zaloID,
                    isGroup: rowData.isGroup,
                    name: rowData.zaloName,
                    salutation: rowData.salutation
                };
                var currentSal = receiver.salutation || "";
                var isGroup = receiver.isGroup;
                var $container = $("#zalo-salutation-popup-host");
                if ($container.length > 0) {
                    try { $container.dxPopup("instance").dispose(); } catch(e) {}
                    $container.remove();
                }
                $("body").append(''<div id="zalo-salutation-popup-host"></div>'');
                $container = $("#zalo-salutation-popup-host");
                var popupHtml =
                    ''<div style="padding: 20px 24px 16px;">'' +
                        ''<div style="font-size:0.92rem; margin-bottom:12px; font-weight:500;">'';
                if (isGroup == 1) {
                    popupHtml += ''<div id="zalo-sal-member-list" style="max-height:340px; overflow-y:auto;"></div>'';
                } else {
                    popupHtml +=
                        ''<div style="margin-bottom:8px;">%zalo_chat_salutation_label%: <strong>'' + (receiver.name ? receiver.name.replace(/[&<>"'']/g, function(m){return m==="&"?"&amp;":m==="<"?"&lt;":m===">"?"&gt;":m==="\""?"&quot;":"&apos;"}) : "") + ''</strong></div>'' +
                        ''<div id="zalo-sal-single"></div>'';
                }
                popupHtml +=
                        ''</div>'' +
                        ''<div style="display:flex; justify-content:flex-end; gap:8px; margin-top:16px;">'' +
                            ''<div id="zalo-sal-save-btn"></div>'' +
                            ''<div id="zalo-sal-cancel-btn"></div>'' +
                        ''</div>'' +
                    ''</div>'';
                $container.dxPopup({
                    title: "%zalo_chat_salutation_popup_title%",
                    width: isGroup == 1 ? 520 : 360,
                    height: "auto",
                    contentTemplate: function() { return popupHtml; },
                    showTitle: true,
                    dragEnabled: true,
                    closeOnOutsideClick: false,
                    visible: true,
                    onShown: function() {
                        if (isGroup == 1) {
                            var $list = $("#zalo-sal-member-list");
                            $list.html(''<div style="text-align:center; padding:20px; opacity:0.6;"><i class="fas fa-spinner fa-spin"></i> %zalo_loading_text%</div>'');
                            AjaxHPAParadiseAsync({
                                data: { name: "sp_zalo_getGroupMembers", param: ["LoginID", UserID, "GroupID", receiver.uid] }
                            }).then(function(res) {
                                var json = typeof res === "string" ? JSON.parse(res) : res;
                                var data = (json && json.data && json.data[0]) ? json.data[0] : [];
                                $list.empty();
                                if (!data || data.length === 0) {
                                    $list.html(''<div style="text-align:center; padding:20px; opacity:0.5; font-size:0.88rem;">%zalo_chat_salutation_no_member%</div>'');
                                    return;
                                }
                                $list.append(
                                    ''<div style="display:flex; font-weight:600; font-size:0.85rem; color:var(--paradise-color-text-main); border-bottom:1px solid var(--paradise-color-decor-main); padding-bottom:6px; margin-bottom:8px;">'' +
                                        ''<div style="flex:1;">%zalo_chat_salutation_col_name%</div>'' +
                                        ''<div style="width:130px;">%zalo_chat_salutation_col_salutation%</div>'' +
                                    ''</div>''
                                );
                                window._zaloSalMembers = data;
                                data.forEach(function(m, idx) {
                                    $list.append(
                                        ''<div style="display:flex; align-items:center; gap:10px; padding:6px 0; border-bottom:1px solid var(--paradise-color-decor-bg2);">'' +
                                            ''<div style="width:28px; height:28px; border-radius:50%; background:var(--paradise-color-decor-bg1); display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.8rem; flex-shrink:0;">'' +
                                                (m.avatar ? ''<img src="'' + m.avatar + ''" style="width:100%; height:100%; border-radius:50%; object-fit:cover;">'' : (m.displayName||"?").charAt(0)) +
                                            ''</div>'' +
                                            ''<div style="flex:1; min-width:0;">'' +
                                                ''<div style="font-size:0.88rem; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">'' + (m.displayName||m.userId).replace(/[&<>"'']/g, function(match){return match==="&"?"&amp;":match==="<"?"&lt;":match===">"?"&gt;":match==="\""?"&quot;":"&apos;"}) + ''</div>'' +
                                                ''<div style="font-size:0.75rem; opacity:0.5;">'' + (m.gender === ''1'' ? ''%zalo_chat_salutation_gender_male%'' : m.gender === ''0'' ? ''%zalo_chat_salutation_gender_female%'' : '''') + ''</div>'' +
                                            ''</div>'' +
                                            ''<div id="zalo-sal-sel-'' + idx + ''" style="width:130px; flex-shrink:0;"></div>'' +
                                        ''</div>''
                                    );
                                    (function(member, i) {
                                        setTimeout(function() {
                                            $("#zalo-sal-sel-" + i).dxSelectBox({
                                                items: ["%zalo_chat_salutation_anh%", "%zalo_chat_salutation_chi%", "%zalo_chat_salutation_ban%", "%zalo_chat_salutation_em%"],
                                                value: member.salutation || (member.gender === ''1'' ? ''%zalo_chat_salutation_anh%'' : member.gender === ''0'' ? ''%zalo_chat_salutation_chi%'' : null),
                                                placeholder: "%zalo_chat_salutation_select%",
                                                acceptCustomValue: true,
                                                showClearButton: true,
                                                width: 130,
                                                onValueChanged: function(e) { window._zaloSalMembers[i]._newSal = e.value; },
                                                onCustomItemCreating: function(e) { e.customItem = e.text; }
                                            });
                                        }, 0);
                                    })(m, idx);
                                });
                            });
                        } else {
                            $("#zalo-sal-single").dxSelectBox({
                                items: ["%zalo_chat_salutation_anh%", "%zalo_chat_salutation_chi%", "%zalo_chat_salutation_ban%", "%zalo_chat_salutation_em%"],
                                value: currentSal || null,
                                placeholder: "%zalo_chat_salutation_select%",
                                acceptCustomValue: true,
                                showClearButton: true,
                                width: "100%",
                                onValueChanged: function(e) { window._zaloNewSalutation = e.value; },
                                onCustomItemCreating: function(e) { e.customItem = e.text; }
                            });
                            window._zaloNewSalutation = currentSal;
                        }
                        $("#zalo-sal-save-btn").dxButton({
                            text: "%zalo_chat_save%",
                            type: "success",
                            onClick: function() {
                                if (isGroup == 1) {
                                    var tasks = (window._zaloSalMembers || []).filter(function(m) { return m._newSal !== undefined; }).map(function(m) {
                                        return AjaxHPAParadiseAsync({
                                            data: { name: "sp_zalo_setSalutation", param: ["LoginID", LoginID, "UserID", m.userId, "GroupID", receiver.uid, "Salutation", m._newSal || ""] }
                                        });
                                    });
                                    Promise.all(tasks).then(function() {
                                        uiManager.showAlert({ type: "success", message: "%zalo_chat_salutation_saved%" });
                                        $container.dxPopup("instance").hide();
                                    }).catch(function() {
                                        uiManager.showAlert({ type: "error", message: "%zalo_chat_salutation_saved%" });
                                    });
                                } else {
                                    AjaxHPAParadiseAsync({
                                        data: { name: "sp_zalo_setSalutation", param: ["LoginID", LoginID, "UserID", receiver.uid, "GroupID", "", "Salutation", window._zaloNewSalutation || ""] }
                                    }).then(function() {
                                        uiManager.showAlert({ type: "success", message: "%zalo_chat_salutation_saved%" });
                                        $container.dxPopup("instance").hide();
                                        rowData.salutation = window._zaloNewSalutation;
                                        if(window.gridInstance) window.gridInstance.refresh();
                                    }).catch(function() {
                                        uiManager.showAlert({ type: "error", message: "%zalo_chat_salutation_saved%" });
                                    });
                                }
                            }
                        });
                        $("#zalo-sal-cancel-btn").dxButton({
                            text: "%zalo_chat_cancel%",
                            stylingMode: "outlined",
                           onClick: function() { $container.dxPopup("instance").hide(); }
                        });
                    }
                });
            };
            function openTagMenu(target, rowData) {
                let tagList = P36EB8FEA286C46F7A109BD6404CA9BAA_data || [];
                if (tagList.length === 0) {
                    uiManager.showAlert({ type: "warning", message: "%zalo_tag_not_found%" });
                    return;
                }
                // Lấy các tag ID hiện tại của row, lọc bỏ các ID không phải là số nếu cần hoặc giữ lại để hiển thị
                let currentTagIDs = rowData.tag ? rowData.tag.split(",").filter(x => x.trim()).map(x => isNaN(x) ? x : parseInt(x)) : [];
                let $wrapper = $("<div></div>").appendTo("body");
                let popoverInstance = $wrapper.dxPopover({
                    target: target,
                    width: 280,
                    height: "auto",
                    showTitle: true,
                    title: "%zalo_tag_select_title%",
                    contentTemplate: function(contentEl) {
                        $("<div></div>").dxTagBox({
                            dataSource: tagList,
                            displayExpr: "Name",
                            valueExpr: "ID",
                            value: currentTagIDs,
                            searchEnabled: true,
                            showSelectionControls: true,
                            selectAllText: "%zalo_tag_select_all%",
                            maxDisplayedTags: 5,
                            placeholder: "%zalo_tag_placeholder%",
                            onValueChanged: function(e) {
                                // Chỉ gửi update khi thực sự có sự thay đổi từ người dùng

                                let newIDs = (e.value || []).join(",");
                                updateRowTag(rowData, newIDs, popoverInstance);
                            }
                        }).appendTo(contentEl);
                    },
                    onHidden: function() {
                        $wrapper.remove();
                    }
                }).dxPopover("instance");
                popoverInstance.show();
            }
            function updateRowTag(rowData, newTagStr, popoverInstance) {
                AjaxHPAParadise({
                    data: {
                        name: "sp_zalo_UpdateTag",
                        param: [
                            "LoginID", UserID,
                            "zaloID", rowData.zaloID,
                            "isGroup", rowData.isGroup === -1 ? 0 : rowData.isGroup,
                            "tagIDs", newTagStr
                        ]
                    },
                    success: function() {
                        if (popoverInstance) popoverInstance.hide();
                        uiManager.showAlert({ type: "success", message: "%zalo_tag_updated%" });
                        // Cập nhật dữ liệu tại chỗ (local) trước khi refresh để UI mượt mà hơn
                        rowData.tag = newTagStr;
                        if (window.gridInstance) {
                            window.gridInstance.refresh();
                        }
                    }
                });
            }
            // Load DataSource: Segmented Menu
            // Load DataSource: Phần mềm
            loadDataSourceCommon("SelectBoxCustom", "sp_zalo_getMarketingProduction", function(data) {
                 try {
                     let sb = $("#P36EB8FEA286C46F7A109BD6404CA9BAA").dxSelectBox("instance");
                     if (sb) {
                         sb.option("dataSource", data);
                         sb.on("valueChanged", function(e) {
                             //console.log("Zalo Grid Filter Changed (sb Event):", e.value);
                             if (window.clearZaloSelectionFull) window.clearZaloSelectionFull(e.value);
                         });
                     }
                 } catch(ex) {}
            });
            // Load DataSource: AI Menu
            loadDataSourceCommon("AIMenuCustom", "sp_zalo_get_autoSendMessage_AI_Menu", function(data) {
                 try {
                     let aiSb = $("#PBE6706C7F3944933A71F067C581E0677").dxSelectBox("instance");
                     if (aiSb) aiSb.option("dataSource", data);
                 } catch(ex) {}
            });
            let _isOpeningDetail = false;
            function openDetailzaloID(rowData) {
                if (_isOpeningDetail) return;
                if (rowData && rowData.zaloID) {
                    _isOpeningDetail = true;
                    window.currentRecordID_zaloID = rowData.zaloID;
                    openFormParam(`sp_zalo_chat`, {LoginID:UserID, LanguageID: LanguageID})
                    // Reset cờ sau 1 giây để cho phép các lần click tiếp theo
                    setTimeout(function() { _isOpeningDetail = false; }, 1000)
                }
            }
            // Sửa lại hiển thị danh sách phần mềm ở ô Số lượng (do cấu hình hệ thống bị đè nhầm)
            loadDataSourceCommon("QuantityBoxCustom", "sp_zalo_get_autoSendMessage_numberSelection", function(data) {
                let numBox = $("#PC3ECBD81231B40B294775F6A0D74C861").dxSelectBox("instance");
                if (numBox) {
                    numBox.option("dataSource", data);
                    numBox.option("displayExpr", "Name");
                    numBox.option("valueExpr", "ID");
                    numBox.option("acceptCustomValue", true);
                    numBox.option("itemTemplate", function(data) {
                        return data ? (data.Name || data.ID || "").toString() : "";
                    });
                    numBox.option("onCustomItemCreating", function(args) {
                        if (!args.text) {
                            args.customItem = null;
                            return;
                        }
                        let val = parseInt(args.text);
                        if (isNaN(val) || val <= 0) {
                            args.customItem = null;
                            return;
                        }
                        let newItem = { ID: val, Name: val.toString() };
                        let ds = numBox.option("dataSource");
                        if (Array.isArray(ds)) {
                            let exists = ds.find(function(x) { return x.ID == val; });
                            if (!exists) {
                                ds.push(newItem);
                                ds.sort(function(a, b) { return a.ID - b.ID; });
                                numBox.option("dataSource", ds);
                            }
                        }
                        args.customItem = newItem;
                        return newItem;
                    });

                    numBox.on("valueChanged", function(e) {
                        //console.log("🚀taidang~ [Manual Binding Số lượng] value=", e.value);
                        if (e.value === null || e.value === "" || e.value == 0) {
                            window._forceZeroQuantity = true;
                        } else {
                            window._forceZeroQuantity = false;
                        }
                        if (typeof applySelectionLogic === "function") applySelectionLogic();
                    });
                }
            });
            // Không được loại bỏ ReloadData
            function ReloadData(pageNumber, pageSize, keyword = null) {
                if (keyword !== null) _currentKeyword = keyword.trim();
                _pageCache = {};
                gridInstance.refresh();
            }
                        // [CUSTOM OVERRIDE] Bat dau ghi de giao dien
            try {
                // Ensure avatar remains hidden
                gridInstance.columnOption(''avatar'', ''visible'', false);
                // Ensure isGroup is hidden as requested
                gridInstance.columnOption(''isGroup'', ''visible'', false);
                let cols = gridInstance.option(''columns'') || [];
                let hasSalutation = false;
                for(let i=0; i<cols.length; i++) {
                    if(cols[i].dataField === ''salutation'') hasSalutation = true;
                }
                if (!hasSalutation) {
                    gridInstance.addColumn({
                        dataField: ''salutation'',
                        caption: ''%zalo_chat_salutation_col_salutation%'',
                        visibleIndex: 4,
                        width: 90,
                        cellTemplate: function(container, options) {
                            let text = options.data.salutation || ''%zalo_chat_salutation_col_salutation%'';
                            $(''<div class="btn-salutation" style="cursor:pointer; color: #a1a1aa; border: 1px solid #4b5563; padding: 2px 8px; border-radius: 4px; font-size: 11px; display:inline-block;"></div>'')
                                .text(text)
                                .on(''click'', function() {
                                    if(typeof window.zalo_chat_openSalutationPopup === ''function'') window.zalo_chat_openSalutationPopup(options.data);
                                })
                                .appendTo(container);
                        }
                    });
                } else {
                    gridInstance.columnOption(''salutation'', ''visible'', true);
                    gridInstance.columnOption(''salutation'', ''caption'', ''%zalo_chat_salutation_col_salutation%'');
                    gridInstance.columnOption(''salutation'', ''width'', 90);
                    gridInstance.columnOption(''salutation'', ''cellTemplate'', function(container, options) {
                        let text = options.data.salutation || ''%zalo_chat_salutation_col_salutation%'';
                        $(''<div class="btn-salutation" style="cursor:pointer; color: #a1a1aa; border: 1px solid #4b5563; padding: 2px 8px; border-radius: 4px; font-size: 11px; display:inline-block;"></div>'')
                            .text(text)
                            .on(''click'', function() {
                                    if(typeof window.zalo_chat_openSalutationPopup === ''function'') window.zalo_chat_openSalutationPopup(options.data);
                            })
                            .appendTo(container);
                    });
                }
                gridInstance.columnOption(''lastActionTime'', ''cellTemplate'', function(container, options) {
                    let aiTime = options.data.aiLastTime;
                    let isGrp = (options.data.isGroup == 1 || options.data.isGroup == true);
                    if (!aiTime) {
                        let msg = isGrp ? ''%zalo_ban_chua_nhan_nhom_nay%'' : ''%zalo_ban_chua_nhan_nguoi_nay%'';
                        $(''<div title="%zalo_theo_lich_su_ai%"></div>'').text(msg)
                            .css({color: "#ef4444", fontStyle: "italic", fontSize: "12px", fontWeight: "500"})
                            .appendTo(container);
                    } else {
                        let days = Math.floor((new Date() - new Date(aiTime)) / (1000 * 60 * 60 * 24));
                        if (days >= 7) {
                            let msg = ''%zalo_da_x_ngay_chua_nhan%''.replace(''{0}'', days);
                            $(''<div title="%zalo_theo_lich_su_ai%"></div>'').text(msg)
                                .css({color: "#f97316", fontStyle: "italic", fontSize: "12px", fontWeight: "500"})
                                .appendTo(container);
                        } else {
                            if(options.data.lastActionTime) {
                                container.text(DevExpress.localization.formatDate(new Date(options.data.lastActionTime), ''HH:mm dd/MM/yyyy''));
                            }
                        }
                    }
                });
                gridInstance.columnOption(''tag'', ''cellTemplate'', function(container, options) {
                    let hasTag = !!options.data.tag;
                    let color = hasTag ? ''var(--bs-success)'' : ''#a1a1aa'';
                    let size = hasTag ? ''12px'' : ''11px'';
                    let style = hasTag ? ''normal'' : ''italic'';
                    let text = hasTag ? options.data.tag : ''%zalo_click_to_tag%'';
                    $(''<div style="cursor:pointer;"></div>'').css({color: color, fontSize: size, fontStyle: style}).text(text)
                        .on(''click'', function() { if(typeof openTagMenu === ''function'') openTagMenu(this, options.data); })
                        .appendTo(container);
                });
                // ====================================================
                // Column sizing: Tỷ lệ % theo chuẩn đã thống nhất
                // Cá nhân/Khách hàng: TÊN 25% | GỬI 12% | PHÂN LOẠI 18% | XƯNG HÔ 16% | SĐT 16% | KHÔNG SPAM 13%
                // Nhóm:               TÊN 25% | GỬI 12% | PHÂN LOẠI 34% | XƯNG HÔ 16% |          SPAM 13%
                // ====================================================
                gridInstance.columnOption(''zaloName'',      ''width'',    ''25%'');
                gridInstance.columnOption(''zaloName'',      ''minWidth'', 150);
                gridInstance.columnOption(''lastActionTime'',''width'',    ''12%'');
                gridInstance.columnOption(''lastActionTime'',''minWidth'', 90);
                gridInstance.columnOption(''lastActionTime'',''alignment'',''center'');
                gridInstance.columnOption(''tag'',           ''width'',    ''18%'');
                gridInstance.columnOption(''tag'',           ''minWidth'', 120);
                gridInstance.columnOption(''salutation'',    ''width'',    ''16%'');
                gridInstance.columnOption(''salutation'',    ''minWidth'', 100);
                gridInstance.columnOption(''salutation'',    ''alignment'',''center'');
                gridInstance.columnOption(''PhoneCustom'',   ''width'',    ''16%'');
                gridInstance.columnOption(''PhoneCustom'',   ''minWidth'', 100);
                gridInstance.columnOption(''PhoneCustom'',   ''alignment'',''center'');
                gridInstance.columnOption(''notSpamCol'',    ''width'',    ''13%'');
                gridInstance.columnOption(''notSpamCol'',    ''minWidth'', 90);
                gridInstance.columnOption(''notSpamCol'',    ''alignment'',''center'');
                gridInstance.columnOption(''checkSpamCol'',  ''width'',    ''13%'');
                gridInstance.columnOption(''checkSpamCol'',  ''minWidth'', 90);
                gridInstance.columnOption(''checkSpamCol'',  ''alignment'',''center'');
                // VisibleIndex order: ChonCustom(0) | TÊN(1) | GỬI(2) | PHÂN LOẠI(3) | XƯNG HÔ(4) | SĐT(5) | SPAM(6)
                gridInstance.columnOption(''zaloName'',      ''visibleIndex'', 1);
                gridInstance.columnOption(''lastActionTime'',''visibleIndex'', 2);
                gridInstance.columnOption(''tag'',           ''visibleIndex'', 3);
                gridInstance.columnOption(''salutation'',    ''visibleIndex'', 4);
                gridInstance.columnOption(''PhoneCustom'',   ''visibleIndex'', 5);
                gridInstance.columnOption(''notSpamCol'',    ''visibleIndex'', 6);
                gridInstance.columnOption(''checkSpamCol'',  ''visibleIndex'', 6);
            } catch(e) { console.error(''Override grid error: '', e); }
            // [CUSTOM OVERRIDE] Ket thuc ghi de giao dien
            // HPA tu dong goi window.zalo_ai_complete(taskScheduleID) khi nhan SignalR
            window.zalo_ai_complete = function(taskScheduleID) {
                console.log(''[ZaloAI] SignalR received zalo_ai_complete for taskID:'', taskScheduleID);
                if (window.zaloAI_ActiveRequests && window.zaloAI_ActiveRequests.length > 0) {
                    let req = window.zaloAI_ActiveRequests.find(r => r.taskScheduleID === taskScheduleID);
                    if (req && !req.isCompleted && !req.isCancelled) {
                        checkProgressLogicForReq(req);
                    }
                }
            };
            window.signal_AI_request = window.zalo_ai_complete;
            window._legacy_signal_AI_request = function(taskScheduleID) {
                console.log(''[ZaloAI] zalo_ai_complete fired, taskID:'', taskScheduleID, ''expected:'', window._currentTaskScheduleID);
                
                // Chi xu ly dung task nay, bo qua cac task khac
                if (taskScheduleID && window._currentTaskScheduleID && taskScheduleID !== window._currentTaskScheduleID) return;
                // Giam pending count
                if (typeof window._zaloAIPendingCount === ''number'' && window._zaloAIPendingCount > 0) {
                    window._zaloAIPendingCount--;
                }
                // Reload grid
                if (typeof ReloadData === ''function'') ReloadData();
                // Khi het pending -> goi callback hoan thanh
                if ((window._zaloAIPendingCount || 0) <= 0) {
                    window._currentTaskScheduleID = null;
                    if (typeof window._zaloAIOnComplete === ''function'') {
                        window._zaloAIOnComplete();
                    } else if (window.zaloAIIsRunning) {
                        window.zaloAIIsRunning = false;
                        if (typeof removeZaloAIFab === ''function'') removeZaloAIFab();
                        $(''.zalo-ai-loading-popup'').each(function() {
                            try { $(this).dxPopup(''instance'').hide(); } catch(e) {}
                        });
                    }
                }
            };
            ReloadData();
        })();
    </script>
';
    SELECT @html as html
END
/*=====
SELECT * FROM tblCommonControlType_Signed where TableName = 'sp_zalo_autoSendMessage_html'
EXEC sptblCommonControlType_Signed_DUC 'sp_zalo_autoSendMessage_html'
EXEC sp_GenerateHTMLScript_new 'sp_zalo_autoSendMessage_html'
=====*/

GO

/*-------------------------------------------------------------------
 BƯỚC 2: CHUẨN HÓA STORED PROCEDURE ĐIỀU PHỐI SP_ZALO_AUTOSENDMESSAGE
 (Trỏ về đúng key chuẩn quy ước hệ thống 'sp_zalo_autoSendMessage' - Không dùng code chắp vá)
--------------------------------------------------------------------*/
ALTER PROCEDURE [dbo].[sp_zalo_autoSendMessage](
    @LoginID INT = NULL,
    @LanguageID VARCHAR(5) = 'VN'
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @LanguageID IS NULL OR LTRIM(RTRIM(@LanguageID)) = ''
        SET @LanguageID = 'VN';

    -- Đọc chuẩn xác theo tên màn hình quy ước của Paradise HRM (Không DELETE bất kỳ dữ liệu nào trong DB)
    SELECT TOP 1 html
    FROM tblHtmlScriptCache
    WHERE TableName = 'sp_zalo_autoSendMessage'
      AND ScreenType = -1
      AND LanguageID = @LanguageID;
END
GO

/*-------------------------------------------------------------------
 BƯỚC 3: BIÊN DỊCH MÃ NGUỒN GIAO DIỆN VÀO BẢNG CACHE VÀ CẬP NHẬT VERSION
 (Hệ thống tự động biên dịch, sinh Version mới và nạp đè sạch sẽ vào tblHtmlScriptCache)
--------------------------------------------------------------------*/
PRINT N'===> Đang biên dịch cache qua sp_GenerateHTMLScript_new...';
IF OBJECT_ID('dbo.sp_GenerateHTMLScript_new', 'P') IS NOT NULL
BEGIN
    EXEC sp_GenerateHTMLScript_new 'sp_zalo_autoSendMessage_html', 'VN', 'sp_zalo_autoSendMessage';
    EXEC sp_GenerateHTMLScript_new 'sp_zalo_autoSendMessage_html', 'EN', 'sp_zalo_autoSendMessage';
END
ELSE
BEGIN
    EXEC sp_GenerateHTMLScript 'sp_zalo_autoSendMessage_html';
END
GO

PRINT N'===================================================================';
PRINT N'===> HOÀN TẤT CẬP NHẬT BẢN VÁ! MỞ TAB VÀ BẤM CTRL + F5 ĐỂ KIỂM TRA.';
PRINT N'===================================================================';
GO
