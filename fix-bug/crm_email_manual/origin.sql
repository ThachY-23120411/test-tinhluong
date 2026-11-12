USE [Vietinsoft_ForTest_Tai2]
GO

-- ===================================================================
-- STORED PROCEDURE 1: sp_KPIListEmailManual_html (MÃ£ nguá»“n giao diá»‡n)
-- ===================================================================

CREATE   PROCEDURE [dbo].[sp_KPIListEmailManual_html]
(
    @LoginID INT = 3,
    @LanguageID VARCHAR(2) = 'VN',
    @isWeb INT = 0
)
AS
BEGIN
    SET NOCOUNT ON;
 DECLARE @html NVARCHAR(MAX);
    SET @html = N'
<div id="sp_KPIListEmailManual">
    <style>
        @keyframes fadeIn {
            from {
                opacity: 0;
            }

            to {
                opacity: 1;
            }
        }

         #GridEmailKPI .dx-toolbar .dx-toolbar-items-container {
            height: auto !important;
            min-height: 40px;
        }

        #GridEmailKPI .dx-datagrid-table {
            width: 100% !important;
        }
        #GridEmailKPI .dx-datagrid-headers .dx-datagrid-table,
        #GridEmailKPI .dx-datagrid-rowsview .dx-datagrid-table {
            width: 100% !important;
        }

        #Outlook_emailPopup.show {
            display: block;
            position: fixed;
            z-index: 9999;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        #Outlook_emailPopup .modal-content {
            margin: 0;
            padding: 0;
            border: 1px solid #374151;
            border-radius: 8px;
            width: 90%;
            max-width: 1000px;
            height: 80vh;
            position: relative;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
            display: flex;
            flex-direction: column;
            color: inherit !important;
        }

        .close-button {
            position: absolute;
            top: 10px;
            right: 15px;
            color: #9ca3af;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            z-index: 10;
            transition: color 0.3s;
        }

        .close-button:hover,
        .close-button:focus {
            color: #fff;
        }

        #Outlook_email-body {
            flex: 1;
            border: none;
            border-radius: 0 0 8px 8px;
        }

        /* Email detail header styling */
        .email-detail-header {
            padding: 20px;
            border-bottom: 1px solid #374151;
            color: inherit !important;
        }

        .mail-title {
            font-size: 1.2rem;
            font-weight: 500;
            margin-bottom: 15px;
            color: inherit !important;
            padding-right: 30px;
        }

        .mail-info-row {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .mail-avatar {
            width: 45px;
            height: 45px;
            background-color: #2563eb;
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 1.1rem;
            flex-shrink: 0;
        }

        .mail-sender-recip {
            flex: 1;
            overflow: hidden;
        }

        .mail-sender-name {
            font-weight: 600;
            color: #60a5fa !important;
            font-size: 0.95rem;
            margin-bottom: 2px;
        }

        .mail-recipient {
            font-size: 0.85rem;
            color: #9ca3af !important;
            display: flex;
            flex-direction: column;
            gap: 2px;
        }

        .mail-time {
            font-size: 0.85rem;
            color: #9ca3af !important;
            text-align: right;
        }

        .attachment-icon {
            color: #9ca3af !important;
            margin-left: 10px;
            font-size: 1rem;
        }

        /* Table styles for transparent background */
        #Outlook_emailPopup .table {
            color: inherit !important;
        }

        #Outlook_emailPopup .table thead th {
            border-bottom: 2px solid #374151;
            color: inherit !important;
        }

        #Outlook_emailPopup .table tbody td {
            border-bottom: 1px solid #374151;
            color: inherit !important;
        }

        #Outlook_emailPopup .table-hover tbody tr:hover {
color: inherit !important;
        }

        /* Email Tags Styles */
        .email-tags-container {
            min-height: 40px;
            border: 1px solid #ddd;
            border-radius: 6px;
            padding: 5px;
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 5px;
            cursor: text;
            background-color: white;
        }

        .email-tags-container:focus-within {
            border-color: #198754;
            outline: none;
            box-shadow: 0 0 0 2px rgba(25, 135, 84, 0.2);
        }

        .email-tag {
            background-color: #e3f2fd;
            color: #1976d2;
            border: 1px solid #90caf9;
            border-radius: 16px;
            padding: 4px 12px 4px 8px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 13px;
            position: relative;
            cursor: pointer;
            user-select: none;
        }

        .email-tag:hover {
            background-color: #bbdefb;
        }

        .email-tag.invalid {
            background-color: #ffebee;
            color: #d32f2f;
            border-color: #f48fb1;
            animation: shake 0.5s ease-in-out;
        }

        .email-tag.invalid:hover {
            background-color: #ffcdd2;
        }

        @keyframes shake {

            0%,
            20%,
            40%,
            60%,
            80% {
                transform: translateX(0);
            }

            10%,
            30%,
            50%,
            70% {
                transform: translateX(-3px);
            }

            90% {
                transform: translateX(3px);
            }

            100% {
                transform: translateX(0);
            }
        }

        .submit-disabled {
            background-color: #9ca3af !important;
            cursor: not-allowed !important;
            opacity: 0.6;
        }

        .validation-message {
            color: #d32f2f;
            font-size: 12px;
            margin-top: 5px;
            display: none;
        }

        .validation-message.show {
            display: block;
        }

        .email-tag .email-text {
            cursor: pointer;
        }

        .email-tag .remove-tag {
            cursor: pointer;
            color: #666;
            font-weight: bold;
            font-size: 14px;
            line-height: 1;
            padding: 2px 4px;
            border-radius: 50%;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            min-width: 18px;
            height: 18px;
        }

        .email-tag .remove-tag:hover {
            background-color: rgba(0, 0, 0, 0.2);
            color: #fff;
        }

        .email-input {
            border: none;
            outline: none;
            flex: 1;
            min-width: 100px;
            padding: 4px;
            font-size: 14px;
        }

        /* Responsive CSS only - KPIListEmailManual 2026-07-01 */
        #sp_KPIListEmailManual,
        #sp_KPIListEmailManual * { box-sizing: border-box; }
        #sp_KPIListEmailManual { width: 100%; max-width: 100%; min-width: 0; min-height: 0; overflow: hidden; }
        #sp_KPIListEmailManual #GridEmailKPI { width: 100%; max-width: 100%; min-width: 0; overflow: hidden; container-type: inline-size; }

        /* Grid Toolbar: Đảm bảo toàn bộ filter bên trái và search panel bên phải thẳng hàng trên 1 dòng */
        #sp_KPIListEmailManual #GridEmailKPI .dx-datagrid-header-panel {
            padding: 4px 0 !important;
            margin-bottom: 12px !important;
            overflow: visible !important;
        }
        #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar {
            height: auto !important;
            min-height: 40px !important;
            overflow: visible !important;
        }
        #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-items-container {
            display: flex !important;
            flex-direction: row !important;
            flex-wrap: nowrap !important;
            align-items: center !important;
            justify-content: space-between !important;
            gap: 8px !important;
            height: auto !important;
            min-height: 40px !important;
            overflow: visible !important;
            width: 100% !important;
        }
        #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-before {
            display: flex !important;
            flex-direction: row !important;
            align-items: center !important;
            flex: 1 1 auto !important;
            max-width: calc(100% - 280px) !important;
            position: static !important;
            transform: none !important;
            left: auto !important;
            float: none !important;
            height: auto !important;
            min-width: 0 !important;
        }
        #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-before .dx-toolbar-item {
            display: flex !important;
            align-items: center !important;
            max-width: 100% !important;
            height: auto !important;
        }
        #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-before .dx-toolbar-item-content {
            display: flex !important;
            align-items: center !important;
            max-width: 100% !important;
            height: auto !important;
        }
        #sp_KPIListEmailManual #GridEmailKPI .data-filter-email-view {
            width: auto !important;
            max-width: 100%;
            min-width: 0;
            display: flex !important;
            flex-direction: row !important;
            flex-wrap: nowrap !important;
            align-items: center !important;
            gap: 8px !important;
            overflow-x: auto !important;
            overflow-y: hidden !important;
            scrollbar-width: none !important;
        }
        #sp_KPIListEmailManual #GridEmailKPI .data-filter-email-view::-webkit-scrollbar {
            display: none !important;
        }
        #sp_KPIListEmailManual #GridEmailKPI .data-filter-email-view > * {
            flex: 0 0 auto !important;
            min-width: 0;
        }
        #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-center {
            display: none !important;
        }
        #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-after {
            display: flex !important;
            flex-direction: row !important;
            align-items: center !important;
            justify-content: flex-end !important;
            flex: 0 0 auto !important;
            margin-left: auto !important;
            position: static !important;
            transform: none !important;
            right: auto !important;
            float: none !important;
            height: auto !important;
            gap: 8px !important;
        }
        #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-after .dx-toolbar-item {
            display: flex !important;
            align-items: center !important;
            flex: 0 0 auto !important;
            height: auto !important;
        }
        #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-after .dx-toolbar-item:has(.dx-searchbox),
        #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-after .dx-toolbar-item:has(.dx-datagrid-search-panel) {
            flex: 0 0 220px !important;
            width: 220px !important;
            max-width: 220px !important;
        }
        #sp_KPIListEmailManual #GridEmailKPI .dx-searchbox,
        #sp_KPIListEmailManual #GridEmailKPI .dx-datagrid-search-panel {
            width: 220px !important;
            min-width: 180px !important;
            max-width: 220px !important;
            height: 32px !important;
        }
        #sp_KPIListEmailManual #GridEmailKPI .dx-datagrid-column-chooser-button {
            height: 32px !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
        }
        #sp_KPIListEmailManual #GridEmailKPI .dx-datagrid,
        #sp_KPIListEmailManual #GridEmailKPI .dx-datagrid-headers,
        #sp_KPIListEmailManual #GridEmailKPI .dx-datagrid-rowsview { max-width: 100%; }
        #sp_KPIListEmailManual #GridEmailKPI .dx-datagrid-headers,
        #sp_KPIListEmailManual #GridEmailKPI .dx-datagrid-rowsview { overflow-x: auto !important; -webkit-overflow-scrolling: touch; }
        #sp_KPIListEmailManual #GridEmailKPI .dx-datagrid-table { min-width: 920px; }
        #sp_KPIListEmailManual #GridEmailKPI .dx-datagrid-table th,
        #sp_KPIListEmailManual #GridEmailKPI .dx-datagrid-table td,
        #sp_KPIListEmailManual #GridEmailKPI .dx-header-row td { white-space: nowrap; }
        #sp_KPIListEmailManual #GridEmailKPI .dx-scrollable-container,
        #sp_KPIListEmailManual #GridEmailKPI .dx-scrollable-content { min-width: 0; }
        @media (max-width: 1349px) {
            #sp_KPIListEmailManual { height: auto !important; min-height: 100dvh; overflow-y: auto !important; overflow-x: hidden !important; }
            #sp_KPIListEmailManual #GridEmailKPI { overflow: visible !important; }
            #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-items-container {
                display: flex !important;
                flex-wrap: wrap !important;
                align-items: center !important;
                justify-content: space-between !important;
                row-gap: 8px !important;
                column-gap: 12px !important;
                height: auto !important;
                min-height: 44px !important;
                width: 100% !important;
                padding: 4px 0 !important;
            }
            #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-before {
                max-width: 100% !important;
                flex: 1 1 auto !important;
                display: flex !important;
                align-items: center !important;
                width: auto !important;
            }
            #sp_KPIListEmailManual #GridEmailKPI .data-filter-email-view {
                display: flex !important;
                flex-wrap: wrap !important;
                align-items: center !important;
                row-gap: 8px !important;
                column-gap: 10px !important;
                width: 100% !important;
                max-width: 100% !important;
                overflow: visible !important;
            }
            #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-after {
                margin-left: auto !important;
                flex: 0 0 auto !important;
                display: flex !important;
                align-items: center !important;
            }
            #sp_KPIListEmailManual #GridEmailKPI .dx-datagrid-header-panel {
                padding-bottom: 8px !important;
                margin-bottom: 12px !important;
            }
        }

        @container (max-width: 1250px) {
            #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-items-container {
                display: flex !important;
                flex-wrap: wrap !important;
                align-items: center !important;
                justify-content: space-between !important;
                row-gap: 8px !important;
                column-gap: 12px !important;
                height: auto !important;
                width: 100% !important;
            }
            #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-before {
                max-width: 100% !important;
                flex: 1 1 auto !important;
                width: auto !important;
            }
            #sp_KPIListEmailManual #GridEmailKPI .data-filter-email-view {
                display: flex !important;
                flex-wrap: wrap !important;
                align-items: center !important;
                row-gap: 8px !important;
                column-gap: 10px !important;
                width: 100% !important;
                overflow: visible !important;
            }
        }
        @media (max-width: 768px) {
            #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-items-container { flex-direction: column !important; align-items: stretch !important; }
            #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-after { width: 100% !important; justify-content: space-between !important; }
            #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-after .dx-toolbar-item:has(.dx-searchbox),
            #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-after .dx-toolbar-item:has(.dx-datagrid-search-panel) { flex: 1 1 auto !important; width: auto !important; max-width: 100% !important; }
            #sp_KPIListEmailManual #GridEmailKPI .dx-searchbox,
            #sp_KPIListEmailManual #GridEmailKPI .dx-datagrid-search-panel { flex: 1 1 auto; width: 100% !important; min-width: 200px; max-width: 100%; }
            #sp_KPIListEmailManual #GridEmailKPI .dx-button { flex: 0 0 auto; }
            #sp_KPIListEmailManual #GridEmailKPI .dx-datebox,
            #sp_KPIListEmailManual #GridEmailKPI .dx-texteditor { max-width: 100%; }
            #sp_KPIListEmailManual #GridEmailKPI .dx-datagrid-table { min-width: 860px; }
        }
        @media (max-width: 480px) {
            #sp_KPIListEmailManual #GridEmailKPI .data-filter-email-view { gap: 6px !important; padding: 4px !important; }
            #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-items-container { gap: 6px !important; }
            #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-after { width: 100%; margin-left: 0 !important; justify-content: flex-start; }
            #sp_KPIListEmailManual #GridEmailKPI .dx-toolbar-after .dx-toolbar-item:has(.dx-searchbox) { flex: 1 1 180px; max-width: 100%; }
            #sp_KPIListEmailManual #GridEmailKPI .dx-searchbox { width: 100% !important; min-width: 180px; max-width: 100%; }
            #sp_KPIListEmailManual #GridEmailKPI .dx-datagrid-table { min-width: 780px; }
            #sp_KPIListEmailManual #GridEmailKPI .dx-datagrid-headers .dx-datagrid-text-content,
            #sp_KPIListEmailManual #GridEmailKPI .dx-datagrid-rowsview td { font-size: 12px; line-height: 1.25; }
        }
    </style>

    <!-- Modal Soạn Thư -->
    <div id="composeEmailModal"
        style="display: none !important; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.5); align-items: center; justify-content: center;">
        <div
            style="background-color: white; border-radius: 8px; width: 90%; max-width: 800px; max-height: 80vh; overflow-y: auto; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3); padding: 20px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h3 style="margin: 0; font-size: 18px; font-weight: 600;">Soạn thư mới</h3>
                <button onclick="closeComposeEmail()"
                    style="background: none; border: none; font-size: 24px; cursor: pointer; color: #666;">×</button>
            </div>

            <form id="composeEmailForm" style="display: flex; flex-direction: column; gap: 12px;">
                <div style="display: flex; gap: 12px; align-items: flex-start;">
                    <label style="font-weight: 600; white-space: nowrap; padding-top: 8px; min-width: 60px;">Gửi
                        đến:</label>
                    <div style="flex: 1;">
                        <div class="email-tags-container" data-field="to">
                            <input type="email" class="email-input" placeholder="Nhập email và nhấn Enter">
                        </div>
                        <div class="validation-message" data-field="to-error">Có email không hợp lệ trong danh sách Gửi
                            đến</div>
                    </div>
                </div>

                <div style="display: flex; gap: 12px; align-items: flex-start;">
                    <label style="font-weight: 600; white-space: nowrap; padding-top: 8px; min-width: 60px;">Cc:</label>
                    <div style="flex: 1;">
                        <div class="email-tags-container" data-field="cc">
                            <input type="email" class="email-input" placeholder="Nhập email và nhấn Enter">
                        </div>
                        <div class="validation-message" data-field="cc-error">Có email không hợp lệ trong danh sách Cc
                        </div>
                    </div>
                </div>

                <div style="display: flex; gap: 12px; align-items: flex-start;">
                    <label
                        style="font-weight: 600; white-space: nowrap; padding-top: 8px; min-width: 60px;">Bcc:</label>
                    <div style="flex: 1;">
                        <div class="email-tags-container" data-field="bcc">
                            <input type="email" class="email-input" placeholder="Nhập email và nhấn Enter">
                        </div>
                        <div class="validation-message" data-field="bcc-error">Có email không hợp lệ trong danh sách Bcc
                        </div>
                    </div>
                </div>

                <div style="display: flex; gap: 12px; align-items: center;">
                    <label style="font-weight: 600; white-space: nowrap; min-width: 60px;">Chủ đề:</label>
                    <input type="text" id="composeSubject" placeholder="Chủ đề email"
                        style="flex: 1; padding: 8px 12px; border: 1px solid #ddd; border-radius: 6px; font-size: 14px;">
                </div>

                <div>
                    <label style="display: block; margin-bottom: 5px; font-weight: 600;">Nội dung:</label>
                    <div id="P963341F870E84D3AB81AE2C3FC6AAC20"></div>
                </div>

                <div style="display: flex; gap: 10px; justify-content: flex-end; margin-top: 10px;">
                    <button class="btn" type="button" onclick="closeComposeEmail()"
                        style="padding: 8px 16px; background-color: #e5e7eb; color: #333; border: none; border-radius: 6px; cursor: pointer; font-weight: 500;">Hủy</button>
                    <button class="btn btn-success" type="submit" id="submitEmailBtn"
                        style="padding: 8px 16px; color: white; border: none; border-radius: 6px; cursor: pointer; font-weight: 500;">Gửi</button>
                </div>
            </form>
        </div>
    </div>

    <div id="Outlook_emailPopup" class="modal">
        <div class="modal-content">
            <span class="close-button" onclick="closeMail()" title="Đóng">×</span>

            <div class="email-detail-header">
                <div class="d-flex justify-content-between align-items-start">
                    <div id="mailSubject" class="mail-title"></div>
                    <div id="mailAttachment" class="attachment-icon" style="display:none;">📎</div>
                </div>
                <div class="mail-info-row">
                    <div class="mail-avatar" id="mailAvatar">?</div>
                    <div class="mail-sender-recip">
                        <div id="mailSender" class="mail-sender-name"></div>
                        <div id="mailRecipientList" class="mail-recipient">
                            <div id="mailTo"></div>
                            <div id="mailCc" style="display:none;"></div>
                        </div>
                    </div>
                    <div id="mailTime" class="mail-time"></div>
                </div>
            </div>

            <iframe id="Outlook_email-body"></iframe>
        </div>
    </div>

    <!-- Email List -->
    <div class="email-list-container" style="margin-top: 20px;">

        <div style="overflow-x: auto;">
            <!-- <table class="table table-striped table-hover" id="emailListTable">
                <thead>
                    <tr>
                        <th>STT</th>
                        <th>Ngày gửi</th>
                        <th>Người gửi</th>
                        <th>Nội dung</th>
                        <th>Thời gian gửi</th>
                    </tr>
                </thead>
                <tbody id="emailListBody">
                </tbody>
            </table> -->
            <div id="GridEmailKPI" style="height: 100%;"></div>
        </div>
    </div>

    <div class="d-none">
        <div id="PADC1EFA724A840A7B3489F9AC789B53E"></div>
    </div>

    <script>
        (() => {
            let dataStore_GridEmailKPI;
            let _pageCache = {};
            let dataEmailKPI = [];

            async function loadPermission() {
                return new Promise((resolve, reject) => {
                    AjaxHPAParadise({
                        data: {
                            name: "sp_Common_GetUserPermissions",
                            param: ["LoginID", window.UserID]
                        },
                        success: function (data) {
                            if (typeof data == "string" && !IsNullOrEmpty(data)) {
                                data = data.includes("{") ? data : EncryptionStringDecryption(data);
                            }
                            let dataObject = JSON.parse(data);
                            let permissionData = dataObject.data?.[0];
                            if (permissionData && permissionData.length > 0) {
                                const perm = permissionData[0];
                                if (perm.HasFullAccess) {
                                    AccessKey = ''FULLACCESS'';
                                } else if (perm.HasManagerAccess) {
                                    AccessKey = ''MANAGER'';
                                } else if (perm.HasUsersAccess) {
                                    AccessKey = ''USER'';
                                } else if (perm.HasCustomerAccess) {
                                    AccessKey = ''CUSTOMER'';
                                }
                            }
                            resolve();
                        },
                        error: reject
                    })
                })
            }
            let AccessKey = '''';

            async function loadPermission() {
                return new Promise((resolve, reject) => {
                    AjaxHPAParadise({
                        data: {
                            name: "sp_Common_GetUserPermissions",
                            param: ["LoginID", window.UserID]
                        },
                        success: function (data) {
                            if (typeof data == "string" && !IsNullOrEmpty(data)) {
data = data.includes("{") ? data : EncryptionStringDecryption(data);
             }
                            let dataObject = JSON.parse(data);
        let permissionData = dataObject.data?.[0];
                            if (permissionData && permissionData.length > 0) {
                                const perm = permissionData[0];
                                if (perm.HasFullAccess) {
                                    AccessKey = ''FULLACCESS'';
                                } else if (perm.HasManagerAccess) {
                                    AccessKey = ''MANAGER'';
                                } else if (perm.HasUsersAccess) {
                                    AccessKey = ''USER'';
                                } else if (perm.HasCustomerAccess) {
                                    AccessKey = ''CUSTOMER'';
                                }
                            }
                            resolve();
                        },
                        error: reject
                    })
                })
            }

            '
                + (select loadUI from tblCommonControlType_Signed where UID = 'PB3F89D2E684947F38EAF2B16BE44999F')
            +(select loadUI from tblCommonControlType_Signed where UID = 'P963341F870E84D3AB81AE2C3FC6AAC20')
            +(select loadUI from tblCommonControlType_Signed where UID = 'PADC1EFA724A840A7B3489F9AC789B53E')
            +N'

            let IsloadFilter = false;
            window.currentRecordID_EmailKPIID = null;

             function configureGridToolbar() {
                if (IsloadFilter) return;
                const gridInstance = InstanceGridEmailKPIPB3F89D2E684947F38EAF2B16BE44999F;
                if (gridInstance) {
                    IsloadFilter = true;
                    gridInstance.option("toolbar", {
                        items: [
                            {
                                location: "before",
                                template: function (data, index, element) {
                                    const $container = $(''<div class="data-filter-email-view" style="display: flex; flex-direction: row; align-items: center; box-sizing: border-box; padding: 0; gap: 8px; flex-wrap: nowrap;">'');

                                    // Employee filter
                                    let $employeeDiv;
                                    if (window.EmployeeID_Login) {
                                        $employeeDiv = $(''<div style="display: flex; align-items: center; gap: 4px; min-width: 150px; flex-shrink: 0;">'');
                                        $employeeDiv.append(''<label style="font-size: 11px; color: #64748b; white-space: nowrap; margin: 0;">Nhân viên:</label>'');
                                        $employeeDiv.append($(''<div id="emailFilterEmployeeToolbar" style="width: 150px;"></div>''));
                                    }

                                    // From Date
                                    const $fromDiv = $(''<div style="display: flex; align-items: center; gap: 4px; min-width: 115px; flex-shrink: 0;">'');
                                    $fromDiv.append(''<label style="font-size: 11px; color: #64748b; white-space: nowrap; margin: 0;">Từ:</label>'');
                                    $fromDiv.append(''<input type="date" id="toolbarFilterFromDate" style="padding: 4px 6px; border: 1px solid #ccc; border-radius: 4px; font-size: 12px; width: 125px; height: 32px; box-sizing: border-box;">'');

                                    // To Date
                                    const $toDiv = $(''<div style="display: flex; align-items: center; gap: 4px; min-width: 115px; flex-shrink: 0;">'');
                                    $toDiv.append(''<label style="font-size: 11px; color: #64748b; white-space: nowrap; margin: 0;">Đến:</label>'');
                                    $toDiv.append(''<input type="date" id="toolbarFilterToDate" style="padding: 4px 6px; border: 1px solid #ccc; border-radius: 4px; font-size: 12px; width: 125px; height: 32px; box-sizing: border-box;">'');

                                    // Filter Button (Làm mới)
                                    const $filterBtn = $(''<button class="btn btn-success" style="padding: 0 10px; height: 32px; line-height: 32px; color: white; border: none; border-radius: 4px; font-size: 12px; cursor: pointer; white-space: nowrap; flex-shrink: 0; display: inline-flex; align-items: center; gap: 4px;"><i class="bi bi-filter"></i> Làm mới</button>'');
                                    $filterBtn.on(''click'', function () {
                                        const fromDate = $(''#toolbarFilterFromDate'').val();
                                        const toDate = $(''#toolbarFilterToDate'').val();
                                        reloadData(fromDate, toDate);
                                    });

                                    // Reset Button (Hidden)
                                    const $resetBtn = $(''<button class="d-none btn btn-outline-success" style="border:1px solid #198754; padding: 0 10px; height: 32px; font-size: 12px; cursor: pointer; white-space: nowrap;"><i class="bi bi-arrow-clockwise"></i> Làm mới</button>'');
                                    $resetBtn.on(''click'', function () {
                                        const today = new Date();
                                        const thirtyDaysAgo = new Date(today.getTime() - (30 * 24 * 60 * 60 * 1000));
                                        $(''#toolbarFilterFromDate'').val(thirtyDaysAgo.toISOString().split(''T'')[0]).prop(''disabled'', false).css(''opacity'', ''1'');
                                        $(''#toolbarFilterToDate'').val(today.toISOString().split(''T'')[0]).prop(''disabled'', false).css(''opacity'', ''1'');
                                        $fromDiv.css(''opacity'', ''1'');
                                        $toDiv.css(''opacity'', ''1'');
                                        $(''#toolbarFilterViewAll'').prop(''checked'', false);
                                        $(''#toolbarFilterMyData'').prop(''checked'', false);
                                        if (window.EmployeeID_Login) {
                                            InstanceEmployeeIDPADC1EFA724A840A7B3489F9AC789B53E.option(''value'', null);
                                        }
                                        reloadData(thirtyDaysAgo.toISOString().split(''T'')[0], today.toISOString().split(''T'')[0]);
                                    });

                                    // Compose Button (Soạn thư)
                                    const $composeBtn = $(''<button class="btn btn-success" style="padding: 0 10px; height: 32px; line-height: 32px; color: white; border: none; border-radius: 4px; font-size: 12px; cursor: pointer; white-space: nowrap; flex-shrink: 0; display: inline-flex; align-items: center; gap: 4px;"><i class="bi bi-envelope-fill"></i> Soạn thư</button>'');
                                    $composeBtn.on(''click'', function () {
                                        openComposeEmail();
                                    });

                                    // Checkboxes: "Xem tất cả các ngày" & "Chỉ xem của tôi" đặt ngang hàng ngay bên phải button Soạn thư
                                    const $checkboxRow = $(''<div style="display: inline-flex; align-items: center; gap: 10px; margin-left: 4px; flex-shrink: 0;">'');
                                    $checkboxRow.append(''<input type="checkbox" id="toolbarFilterViewAll" style="width: 15px; height: 15px; cursor: pointer; accent-color: #198754; margin: 0;">'');
                                    $checkboxRow.append(''<label for="toolbarFilterViewAll" style="font-size: 11px; color: #64748b; white-space: nowrap; cursor: pointer; margin: 0; font-weight: 500;">%ViewAllDays%</label>'');

                                    // "Only My Data" checkbox
                                    if (window.EmployeeID_Login || window.UserID) {
                                        $checkboxRow.append(''<input type="checkbox" id="toolbarFilterMyData" style="width: 15px; height: 15px; cursor: pointer; accent-color: #198754; margin: 0;">'');
                                        $checkboxRow.append(''<label for="toolbarFilterMyData" style="font-size: 11px; color: #64748b; white-space: nowrap; cursor: pointer; margin: 0; font-weight: 500;">Chỉ xem của tôi</label>'');
                                    }

                                    // Toggle when "View All" changes
                                    $checkboxRow.find(''#toolbarFilterViewAll'').on(''change'', function () {
                                        const checked = $(this).is('':checked'');
                                        $fromDiv.find(''input'').prop(''disabled'', checked);
                                        $toDiv.find(''input'').prop(''disabled'', checked);
                                        $fromDiv.css(''opacity'', checked ? ''0.4'' : ''1'');
                                        $toDiv.css(''opacity'', checked ? ''0.4'' : ''1'');
                                        reloadData();
                                    });

                                    // Toggle when "My Data" changes
                                    $checkboxRow.find(''#toolbarFilterMyData'').on(''change'', function () {
                                        const checked = $(this).is('':checked'');
                                        if (checked) {
                                            InstanceEmployeeIDPADC1EFA724A840A7B3489F9AC789B53E.option(''value'', window.EmployeeID_Login || window.UserID);
                                        } else {
                                            InstanceEmployeeIDPADC1EFA724A840A7B3489F9AC789B53E.option(''value'', null);
                                        }
                                        reloadData();
                                    });

                                    // Single Row layout: Append all controls inline to $container
                                    if ($employeeDiv) {
                                        $container.append($employeeDiv);
                                    }
                                    $container.append($fromDiv, $toDiv, $filterBtn, $resetBtn, $composeBtn, $checkboxRow);

                                    $(element).append($container);

                                    // Move employee filter to toolbar
                                    setTimeout(() => {
                                        const employeeFilterWrapper = document.getElementById("emailFilterEmployeeToolbar");
                                        if (employeeFilterWrapper && employeeFilterWrapper.children.length === 0) {
                                            const originalEmployee = document.getElementById("PADC1EFA724A840A7B3489F9AC789B53E");
                                            if (originalEmployee && originalEmployee.parentElement) {
                                                const employeeDiv = originalEmployee.parentElement.querySelector(''div'');
                                                if (employeeDiv) {
                                                    employeeFilterWrapper.appendChild(employeeDiv);
                                                }
                                            }
                                        }
                                    }, 300);

                                     // Initialize default dates
                                        setTimeout(() => {
let fromDate, toDate;

               if (window.FromDateKPI && window.ToDateKPI) {

                                                fromDate = window.FromDateKPI;
                                                toDate = window.ToDateKPI;
                                                        InstanceEmployeeIDPADC1EFA724A840A7B3489F9AC789B53E.option(''value'', window.EmployeeIDsKPI);
                                                $(''.toolbarFilterViewAll'').prop(''checked'', false);
                                            } else {
                                                const today = new Date();
                                                const firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
                                                fromDate = firstDayOfMonth.toISOString().split(''T'')[0];
                                                toDate = today.toISOString().split(''T'')[0];
                                                 $(''.toolbarFilterViewAll'').prop(''checked'', true);
                                            }
                                            $(''#toolbarFilterFromDate'').val(fromDate);
                                            $(''#toolbarFilterToDate'').val(toDate);
                                            let checked = $(''#toolbarFilterViewAll'').is('':checked'');
                                            $fromDiv.find(''input'').prop(''disabled'', checked);
                                            $toDiv.find(''input'').prop(''disabled'', checked);
                                            $fromDiv.css(''opacity'', checked ? ''0.4'' : ''1'');
                                            $toDiv.css(''opacity'', checked ? ''0.4'' : ''1'');

                                        }, 500);
                                }
                            },
                            "columnChooserButton",
                            "searchPanel"

                        ]
                    });

                }
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

                AjaxHPAParadise({
                    data: {
                        name: dataSourceSP,
                        param: ["LoginID", LoginID, "LanguageID", LanguageID]
                    },
                    success: function (res) {
                        const json = typeof res === "string" ? JSON.parse(res) : res;
                        window[dataSourceKey] = (json.data && json.data[0]) || [];


                        window[loadedKey] = true;

                        // Gọi callback nếu có
                 if (typeof onSuccessCallback === "function") {
                       onSuccessCallback(window[dataSourceKey]);
                        }

                        // Tự động cập nhật control nếu có method setDataSource hoặc option
                        // Thử nhiều format tên instance để tương thích
                        const instanceVariants = [
                            "Instance" + columnName.charAt(0).toUpperCase() + columnName.slice(1) + "PB3F89D2E684947F38EAF2B16BE44999F",
                         "Instance" + columnName + "PB3F89D2E684947F38EAF2B16BE44999F",
                            "instance" + columnName.charAt(0).toUpperCase() + columnName.slice(1) + "PB3F89D2E684947F38EAF2B16BE44999F"
                        ];

                        for (let i = 0; i < instanceVariants.length; i++) {
                            const instanceKey = instanceVariants[i];

                            if (window[instanceKey] || instanceKey) {
const instanceObj = window[instanceKey] || instanceKey;



                                // Kiểm tra nếu đây là dxDataGrid
                                if (typeof instanceObj.dxDataGrid === "function" || instanceObj.option && instanceObj.option("dataSource") !== undefined) {
                                    try {
                                        // Nếu là Grid, apply dynamic config
                                        const gridConfigFn = window["getGridConfig_" + columnName.charAt(0).toUpperCase() + columnName.slice(1)];
                                        if (typeof gridConfigFn === "function") {
                                            const gridConfig = gridConfigFn(window[dataSourceKey]);
                                            instanceObj.option("remoteOperations", gridConfig.remoteOperations);
                                            instanceObj.option("paging.pageSize", gridConfig.pageSize);
                                            instanceObj.option("pager.allowedPageSizes", gridConfig.allowedPageSizes);
                                        }

                                        instanceObj.option("dataSource", window[dataSourceKey]);
                                        break;
                                    } catch (e) {
                                        console.warn("[LoadDataSourceCommon] Grid config error:", e);
                                        // Fallback: just set data source
                                        instanceObj.option("dataSource", window[dataSourceKey]);
                                        break;
                                    }
                                } else if (typeof instanceObj.setDataSource === "function") {
                                    instanceObj.setDataSource(window[dataSourceKey]);
                                    break;
                                } else if (typeof instanceObj.option === "function") {
                                    try {
                                        instanceObj.option("dataSource", window[dataSourceKey]);
                                        break;
                                    } catch (e) {
                                        // Continue to next variant
                                    }
                                }
                            }
                        }
                    },
                    error: function (err) {
                        console.error("[loadDataSourceCommon] Failed to load datasource for", columnName, ":", err);
                        window[loadedKey] = false;
                        if (typeof onSuccessCallback === "function") {
                            onSuccessCallback([]);
                        }
                    }
                });
            }

            function clearPageCache() {
                _pageCache = {};
            }

            function getGridHeight() {
                const gridEl = InstanceGridEmailKPIPB3F89D2E684947F38EAF2B16BE44999F.element();
                const domElement = gridEl.jquery ? gridEl[0] : gridEl;
                const top = domElement.getBoundingClientRect().top;
                return window.innerHeight - top - 20;
            }

            function reloadData(fromDate = '''', toDate = '''',employeeID = '''',isViewAll = null, keyword = null) {

                _pageCache = {};

                let _currentKeyword = String(
                    keyword != null
                        ? keyword
                        : (InstanceGridEmailKPIPB3F89D2E684947F38EAF2B16BE44999F.option("searchPanel.text") || "")
                ).trim();

                function _applyRecord(results) {
                    window.syncSharedGridData("GridEmailKPI");

                    if (typeof configureGridToolbar === ''function'') {
                        configureGridToolbar();
                    }
                }

                dataStore_GridEmailKPI = new DevExpress.data.CustomStore({
                    key: "EmailKPIID",
                    load: function (loadOptions) {
                        const deferred = $.Deferred();

                        let params = [];

                        // SP nghiệp vụ
                        params.push("@ProcName", "sp_MailListSenderOrigin");

                        // Tham số riêng của sp_MailListSenderOrigin
                        let procParam = "";
                        isViewAll = isViewAll == null ? ($(''#toolbarFilterViewAll'').is('':checked'') ? 1 : 0) : isViewAll;
                        const fallbackFrom = $(''#toolbarFilterFromDate'').val();
                        const fallbackTo = $(''#toolbarFilterToDate'').val();

                        procParam += `@LoginID=${window.UserID}`;
                        procParam += `,@isViewAll=${isViewAll}`;

                        if (!isViewAll) {
                            const effectiveFrom = fromDate || fallbackFrom;
                            const effectiveTo = toDate || fallbackTo;
                            if (effectiveFrom && effectiveTo) {
                                procParam += `,@FromDate=''${effectiveFrom}''`;
                                procParam += `,@ToDate=''${effectiveTo}''`;
                            }
                        }

                        procParam += `,@EmployeeID=''${InstanceEmployeeIDPADC1EFA724A840A7B3489F9AC789B53E.option(''value'') || ''''}''`;

                        params.push("@ProcParam", procParam);

                        // Phân trang
                        params.push("@Take", loadOptions.take || 50);
                        params.push("@Skip", loadOptions.skip || 0);

                        // TotalCount
                        if (loadOptions.requireTotalCount) {
                            params.push("@RequireTotalCount", 1);
                        }

                        // Sort
                        const sort = loadOptions.sort
                            ? loadOptions.sort.map(s => s.selector + (s.desc ? " DESC" : " ASC")).join(",")
                            : "ReceivedTime DESC"; // này cho mặc định. tự chỉnh theo menu mỗi người

                        params.push("@Sort", "ORDER BY " + sort);

                        // Search
                        if (_currentKeyword) {
                            params.push("@SearchValue", _currentKeyword);
                            params.push("@ColumnSearch", "ReceivedTime,SenderEmail,Subject,FullName");
                        }

                        // Filter
                        if (loadOptions.filter) {
                            // Kiểm tra filter item có phải function không
                            const isJSFunction = (item) => typeof item === ''function'';

           const hasFunction = JSON.stringify(loadOptions.filter, (key, val) => {
        if (typeof val === ''function'') return ''FUNCTION'';
          return val;
                            }).includes(''FUNCTION'');

                            if (!hasFunction) {
                                params.push("@Filters", createConditionQuery(loadOptions.filter));
                            }
                        }
                        // Filter
                        // if (loadOptions.filter) {
                        //     params.push("@Filters", createConditionQuery(loadOptions.filter));
                        // }

                        // Group
                        if (loadOptions.group) {
                            let selectGroup = "", groupBy = "GROUP BY ";
                            loadOptions.group.forEach((item, index) => {
                                if (selectGroup) selectGroup += ", ";
                                if (groupBy !== "GROUP BY ") groupBy += ", ";
                                if (item.groupInterval) {
                                    selectGroup += `${item.groupInterval.toUpperCase()}(${item.selector}) as col${index}`;
                                    groupBy += `${item.groupInterval.toUpperCase()}(${item.selector})`;
                                } else {
                                    selectGroup += `${item.selector} as col${index}`;
                                    groupBy += `${item.selector}`;
                                }
                            });
                            selectGroup += `, Count(*) as totalCount`;
                            params.push("@SelectGroup", selectGroup);
                            params.push("@GroupBy", groupBy);
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
                      console.log(params)
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
                                dataEmailKPI = results;
                                _applyRecord(results);

           deferred.resolve(result);
                            },
                            error: function (err) {
                           deferred.reject("Data Loading Error");
     }
                        });

                        return deferred.promise();
                    }
                });

                // Gán store vào grid để kích hoạt load
                const gridInstance = InstanceGridEmailKPIPB3F89D2E684947F38EAF2B16BE44999F;
                gridInstance.beginUpdate();
                gridInstance.option("remoteOperations", {
                    paging: true,
                    filtering: true,
                    sorting: true,
                    searching: true
                });

                // scroll
                gridInstance.option("scrolling.mode", "infinite");
                gridInstance.option("scrolling.rowRenderingMode", "virtual");
                gridInstance.option("scrolling.preloadEnabled", false);

                gridInstance.option("paging.enabled", true);
                gridInstance.option("paging.pageSize", 50);
                gridInstance.option("pager.visible", false);
                gridInstance.option("pager.allowedPageSizes", [50]);
                gridInstance.option("searchPanel.highlightSearchText", false);
                gridInstance.option("dataSource", dataStore_GridEmailKPI);
                gridInstance.option("height", getGridHeight());
                gridInstance.option("onOptionChanged", function (e) {
                    if (e.name === "searchPanel" && e.fullName === "searchPanel.text") {
                        const raw = e.value || "";
                        let t = String(raw);
                        _currentKeyword = t.trim();
                        _pageCache = {};
                    }
                });
                
                // Tối ưu hóa Responsive toàn diện cho DataGrid
                gridInstance.option("columnAutoWidth", false);
                gridInstance.option("allowColumnResizing", true);
                gridInstance.option("columnResizingMode", "widget");

                // Cấu hình linh hoạt các cột: Subject tự do dãn nở hấp thụ toàn bộ bề ngang
                gridInstance.columnOption("FullName", {
                    width: 220,
                    minWidth: 180,
                    maxWidth: undefined
                });
                gridInstance.columnOption("Subject", {
                    width: undefined, // Flex Auto-fill: Dãn nở tự do không bị bóp nghẹt dấu ...
                    minWidth: 260,
                    maxWidth: undefined
                });
                gridInstance.columnOption("ReceivedTime", {
                    width: 160,
                    minWidth: 140,
                    maxWidth: undefined,
                    alignment: "center"
                });
                gridInstance.columnOption("SenderEmail", {
                    width: 260,
                    minWidth: 200,
                    maxWidth: undefined
                });
                gridInstance.endUpdate();
            }


        function openDetailEmailKPIID(detail) {
            const obj = dataEmailKPI.find(e => e.EmailKPIID == detail.EmailKPIID);

            if (!obj) {
                uiManager.showAlert({ type: "error", message: "Không tìm thấy email chi tiết." });
                return;
            }
            AjaxHPAParadise({
                data: {
                    name: "sp_GetEmailDetail",
                    param: [
                        ''MailID'', obj.MailId,
                        ''ReceivedTime'', obj.ReceivedTimeOutLook,
                        ''EmailKPIID'', obj.EmailKPIID
                    ]
                },
                success: function (data) {
                    if (typeof data == "string" && !IsNullOrEmpty(data)) {
                        data = data.includes("{") ? data : EncryptionStringDecryption(data);
                    }
                    let dataObj = JSON.parse(data);

                    let emailData, recipientData = [], attachmentData = [];

                    // Check if response has nested structure (sp_GetEmailDetail with MailID)
                    // or flat structure (direct query when MailID is null)
                    if (dataObj.data && Array.isArray(dataObj.data[0]) && dataObj.data.length >= 2) {
   // Case 1: Normal sp_GetEmailDetail response with nested arrays
        emailData = dataObj.data[0];
                        recipientData = dataObj.data[1] || [];
                        attachmentData = dataObj.data[2] || [];
                    } else if (dataObj.data && Array.isArray(dataObj.data) && dataObj.data.length > 0) {
                        // Case 2: Flat response from CRM tables (when MailID is null or ViewHTML = 1)
                        const rows = dataObj.data[0];

                        // Extract email data from first row (email info is same across all rows)
                        emailData = [{
                            Subject: rows[0].Subject,
       SenderEmail: rows[0].SenderEmail,
                            SenderName: rows[0].SenderEmail, // Use email as name since we don''t have separate name field
           ReceivedTime: rows[0].ReceivedTime,
                       BodyContent: rows[0].Body,
                Body: rows[0].Body,
                            OutlookLink: ''#'' // No Outlook link for CRM emails
                        }];

                        // Extract and group recipients by type
                        recipientData = rows
                            .filter(row => row.RecipientType && row.EmailAddress) // Only rows with recipient data
                            .map(row => ({
                                RecipientType: row.RecipientType,
                                Name: row.EmailAddress,
                                Address: row.EmailAddress
                            }));

                        attachmentData = []; // No attachments for CRM emails
                    }

                    if (emailData && emailData.length > 0) {
                        const mail = emailData[0];
                        let bodyContent = mail.BodyContent;
                        const outlookLink = mail.OutlookLink;

                        const inlineImages = attachmentData.filter(f => f.AttachmentType === ''Ảnh nhúng'');
                        const realFiles = attachmentData.filter(f => f.AttachmentType === ''File đính kèm'');
                        if (mail.OutlookLink != ''#'') {
                            bodyContent = cleanEmailBody(bodyContent, inlineImages.length);
                        }

                        $(''#mailSubject'').text(mail.Subject || ''(Không có tiêu đề)'');

                        const senderDisplayName = mail.SenderName || mail.SenderEmail || ''Người gửi không xác định'';
                        $(''#mailSender'').text(senderDisplayName);
                        console.log(recipientData.filter(r => r.RecipientType.toUpperCase().trim() == ''TO''))
                        let nameForAvatar = mail.SenderName || mail.SenderEmail || ''?'';
                        let initials = nameForAvatar.split('' '')
                            .map(n => n[0])
                            .filter(c => c && c !== ''@'')
                            .join('''')
                            .toUpperCase()
                            .substring(0, 2);
                        if (!initials) initials = nameForAvatar[0].toUpperCase();
                        $(''#mailAvatar'').text(initials);

                        let toList = recipientData
                            .filter(r => r.RecipientType.toUpperCase().trim() == ''TO'')
                            .map(r => r.Name || r.Address)
                            .join(''; '');
                        let ccList = recipientData
                            .filter(r => r.RecipientType.toUpperCase().trim() == ''CC'')
                            .map(r => r.Name || r.Address)
                            .join(''; '');

                        $(''#mailTo'').text(''To: '' + (toList || ''(không có người nhận)''));
                        if (ccList) {
                            $(''#mailCc'').text(''Cc: '' + ccList).show();
                        } else {
       $(''#mailCc'').hide();
                        }

                        if (mail.ReceivedTime) {
                            const date = new Date(mail.ReceivedTime);
                            const options = {
                                weekday: ''short'',
                                year: ''numeric'',
                           month: ''numeric'',
                                day: ''numeric'',
                                hour: ''2-digit'',
                                minute: ''2-digit'',
                                hour12: true
                            };
                            $(''#mailTime'').text(date.toLocaleString(''en-US'', options));
                        }

                        let attachmentFooter = buildAttachmentFooter(inlineImages, realFiles, outlookLink);

               const totalAttachments = attachmentData.length;
                if (totalAttachments > 0) {
                            $(''#mailAttachment'').text(`📎 ${totalAttachments}`).show();
                        } else {
                            $(''#mailAttachment'').hide();
                        }

                        const frame = document.getElementById(''Outlook_email-body'');

                        const parentHtml = document.documentElement;
                        const parentBody = document.body;
                        const isEmailPreviewDark = parentHtml.classList.contains(''dark-mode'') ||
                            parentBody.classList.contains(''dark-mode'') ||
                            parentHtml.getAttribute(''data-bs-theme'') === ''dark'' ||
                            parentBody.getAttribute(''data-bs-theme'') === ''dark'';
                        const emailPreviewBg = isEmailPreviewDark ? ''#18212f'' : ''#ffffff'';
                        const emailPreviewSurface = isEmailPreviewDark ? ''#202b3a'' : ''#ffffff'';
                        const emailPreviewSurfaceSoft = isEmailPreviewDark ? ''#263344'' : ''#f8fafc'';
                        const emailPreviewText = isEmailPreviewDark ? ''#e5e7eb'' : ''#1f2937'';
                        const emailPreviewMuted = isEmailPreviewDark ? ''#aeb8c6'' : ''#6b7280'';
                        const emailPreviewBorder = isEmailPreviewDark ? ''rgba(255,255,255,0.14)'' : ''#d1d5db'';
                        const emailPreviewLink = isEmailPreviewDark ? ''#93c5fd'' : ''#2563eb'';
                        const darkModeCss = isEmailPreviewDark ? `
                        .email-content,
                        .email-content table,
                        .email-content tbody,
                        .email-content thead,
                        .email-content tr,
                        .email-content td,
                        .email-content th,
                        .email-content div,
                        .email-content p,
                        .email-content section,
                        .email-content article {
                            background-color: ${emailPreviewSurface} !important;
                            color: ${emailPreviewText} !important;
                            border-color: ${emailPreviewBorder} !important;
                        }
                        .email-content * {
                            color: ${emailPreviewText} !important;
                            border-color: ${emailPreviewBorder} !important;
                        }
                        .email-content [style*="background"],
                        .email-content [bgcolor] {
                            background: ${emailPreviewSurface} !important;
                            background-color: ${emailPreviewSurface} !important;
                        }
                        .email-content [style*="background-color: #003"],
                        .email-content [style*="background:#003"],
                        .email-content [style*="background: #003"],
                        .email-content [style*="background-color:#003"],
                        .email-content [style*="background-color: rgb(0"],
                        .email-content [style*="background: rgb(0"] {
                            background: #07364a !important;
                            background-color: #07364a !important;
                        }
                        .email-content a,
                        .email-content a * {
                            color: ${emailPreviewLink} !important;
                        }
                        .email-content a[style*="background"],
                        .email-content a[style*="background"] * {
                            color: #ffffff !important;
                        }
                        .email-content [style*="background-color: #2"],
                        .email-content [style*="background:#2"],
                        .email-content [style*="background: #2"],
                        .email-content [style*="background-color:#2"],
                        .email-content [style*="background-color: #3"],
                        .email-content [style*="background:#3"],
                        .email-content [style*="background: #3"],
                        .email-content [style*="background-color:#3"],
                        .email-content [style*="background-color: #e"],
                        .email-content [style*="background:#e"],
                        .email-content [style*="background: #e"],
                        .email-content [style*="background-color:#e"] {
                            color: #ffffff !important;
                        }
                        ` : '''';

                        const styleWrapper = `
                    <style>
                        * {
                            box-sizing: border-box;
                        }
                        html,
                        body {
                            color: ${emailPreviewText} !important;
                            font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif;
                            padding: 0;
                            margin: 0;
                            background-color: ${emailPreviewBg} !important;
                        }
                        .email-content {
                            padding: 20px;
                            line-height: 1.6;
                            color: ${emailPreviewText} !important;
                            background-color: ${emailPreviewSurface} !important;
                        }
                        .email-content table,
                        .email-content tbody,
                        .email-content thead,
                        .email-content tr,
                        .email-content td,
                        .email-content th {
                            color: inherit;
                            border-color: ${emailPreviewBorder} !important;
                        }
                        .email-content p,
                        .email-content li,
                        .email-content font,
                        .email-content span,
                        .email-content div {
                            color: ${emailPreviewText} !important;
                        }
                        .email-content a:not([style*="background"]) {
                            color: ${emailPreviewLink} !important;
                        }
                        .image-placeholder {
                            background-color: ${emailPreviewSurfaceSoft};
                            border: 1px dashed ${emailPreviewBorder};
                            padding: 12px;
                            margin: 10px 0;
                            border-radius: 5px;
                            color: ${emailPreviewMuted} !important;
                            text-align: center;
                            font-style: italic;
                            font-size: 0.9rem;
                        }
                        ${darkModeCss}
                    </style>
                    `;
                        const fullContent = `
                    ${styleWrapper}
                    <div class="email-content">
                        ${bodyContent}
                    </div>
                    ${attachmentFooter}
                       `;

        frame.srcdoc = fullContent;
           $(''#Outlook_emailPopup'').addClass(''show'');
                    }
                },
 error: function (error) {
                    console.error(''Error loading email:'', error);
              alert(''Không thể tải email. Vui lòng thử lại.'');
                }
            });
        }

        function cleanEmailBody(html, inlineImageCount) {
            if (!html) return '''';

            const parser = new DOMParser();
            const doc = parser.parseFromString(html, ''text/html'');
            const images = doc.querySelectorAll(''img'');

            let imageIndex = 1;
            images.forEach(img => {
                const placeholder = doc.createElement(''div'');
                placeholder.className = ''image-placeholder'';

                const altText = img.getAttribute(''alt'') || '''';
                const size = img.getAttribute(''size'') || '''';

                if (altText) {
                    placeholder.textContent = `🖼️ [Ảnh ${imageIndex}: ${altText}]`;
                } else if (size) {
                    placeholder.textContent = `🖼️ [Ảnh ${imageIndex} - ${formatFileSize(size)}]`;
                } else {
                    placeholder.textContent = `🖼️ [Ảnh nhúng ${imageIndex}]`;
                }

                img.parentNode.replaceChild(placeholder, img);
                imageIndex++;
            });

            // Remove inline color styles từ Outlook để dùng CSS color-scheme
            const allElements = doc.querySelectorAll(''[style*="color"]'');
            allElements.forEach(el => {
                let style = el.getAttribute(''style'') || '''';
                // Loại bỏ inline color definitions
                style = style.replace(/color\s*:\s*black\s*;?/gi, '''');
                style = style.replace(/color\s*:\s*#000000\s*;?/gi, '''');
                style = style.replace(/color\s*:\s*#000\s*;?/gi, '''');
                style = style.replace(/color\s*:\s*rgb\(0\s*,\s*0\s*,\s*0\)\s*;?/gi, '''');
                // Xoá attribute nếu style rỗng
                if (style.trim() === '''') {
                    el.removeAttribute(''style'');
                } else {
                    el.setAttribute(''style'', style);
                }
            });

            return doc.body.innerHTML;
        }

        function buildAttachmentFooter(inlineImages, realFiles, outlookLink) {
            let html = '''';

            const hasInlineImages = inlineImages.length > 0;
            const hasRealFiles = realFiles.length > 0;
            const hasOutlookLink = outlookLink && outlookLink !== ''#'';

            if (!hasInlineImages && !hasRealFiles && !hasOutlookLink) {
                return '''';
            }

            html += `<div style="padding: 20px; border-top: 1px solid #e5e7eb; background-color: #f9fafb;">`;

            if (hasRealFiles) {
                html += `
            <div style="margin-bottom: 15px;">
                <h4 style="margin: 0 0 10px 0; font-size: 1rem; color: #374151;">
                    📎 File đính kèm (${realFiles.length})
             </h4>
              <ul style="list-style: none; padding: 0; margin: 0;">
        `;

                realFiles.forEach(file => {
                    const icon = getFileIcon(file.ContentType);
                    html += `
                <li style="padding: 8px 12px; margin-bottom: 5px; background-color: white;
                  border: 1px solid #e5e7eb; border-radius: 4px; display: flex;
                           align-items: center; justify-content: space-between;">
                    <div style="display: flex; align-items: center; gap: 10px;">
                        <span style="font-size: 1.2rem;">${icon}</span>
                        <div>
                            <div style="font-weight: 500; color: #111827;">${file.FileName}</div>
<div style="font-size: 0.85rem; color: #6b7280;">${file.FileSizeFormatted}</div>
                        </div>
       </div>
      </li>
    `;
                });

                html += `
                </ul>
            </div>
        `;
            }

            // Only show Outlook link if it exists and is not ''#''
            if (hasOutlookLink) {
                html += `
        <div style="text-align: center;">
            <a href="${outlookLink}" target="_blank"
               style="display: inline-block; padding: 12px 24px; background-color: #2563eb;
                      color: white; text-decoration: none; border-radius: 6px; font-weight: 500;
                      box-shadow: 0 1px 3px rgba(0,0,0,0.1);">
                🔗 Mở trong Outlook để ${hasRealFiles ? ''tải file'' : ''xem ảnh gốc''}
            </a>
        </div>
    `;
            }

            html += `</div>`;

            return html;
        }

        function getFileIcon(contentType) {
            if (!contentType) return ''📄'';

            if (contentType.includes(''spreadsheet'') || contentType.includes(''excel'')) {
                return ''📊'';
            }
            if (contentType.includes(''word'') || contentType.includes(''document'')) {
                return ''📝'';
            }
            if (contentType.includes(''pdf'')) {
                return ''📕'';
            }
            if (contentType.includes(''presentation'') || contentType.includes(''powerpoint'')) {
                return ''📊'';
            }
            if (contentType.includes(''zip'') || contentType.includes(''rar'') || contentType.includes(''compressed'')) {
                return ''📦'';
            }
            if (contentType.includes(''image'')) {
                return ''🖼️'';
            }
            if (contentType.includes(''video'')) {
                return ''🎥'';
            }
            if (contentType.includes(''audio'')) {
                return ''🎵'';
            }

            return ''📄'';
        }

        function formatFileSize(bytes) {
            if (!bytes) return '''';
            bytes = parseInt(bytes, 10);
            if (bytes < 1024) return bytes + '' B'';
            if (bytes < 1048576) return Math.round(bytes / 1024) + '' KB'';
            return Math.round(bytes / 1048576) + '' MB'';
        }

        function closeMail() {
            const frame = document.getElementById(''Outlook_email-body'');
            frame.srcdoc = '''';
            $(''#Outlook_emailPopup'').removeClass(''show'');
        }

        function openComposeEmail() {
            document.getElementById(''composeEmailModal'').style.display = ''flex'';
            document.getElementById(''composeEmailForm'').reset();
            // Clear all email tags
            document.querySelectorAll(''.email-tags-container'').forEach(container => {
                container.querySelectorAll(''.email-tag'').forEach(tag => tag.remove());
            });
            // Hide all validation messages
            document.querySelectorAll(''.validation-message'').forEach(msg => {
  msg.classList.remove(''show'');
            });
            // Reset submit button state
            const submitBtn = document.getElementById(''submitEmailBtn'');
            if (submitBtn) {
                submitBtn.classList.remove(''submit-disabled'');
                submitBtn.disabled = false;
            }
            initEmailTagsHandlers();
        }

        function closeComposeEmail() {
            document.getElementById(''composeEmailModal'').style.display = ''none'';
        }

        // Email tags functionality
        function initEmailTagsHandlers() {
            document.querySelectorAll(''.email-tags-container'').forEach(container => {
                const input = container.querySelector(''.email-input'');

   // Click container to focus input
container.addEventListener(''click'', (e) => {
                    if (e.target === container) {
                      input.focus();
        }
                });

                // Handle remove tag click
                container.addEventListener(''click'', (e) => {
                    if (e.target.classList.contains(''remove-tag'')) {
                        e.stopPropagation();
                        e.target.parentElement.remove();
                        // Trigger validation after removing tag
                        setTimeout(() => validateAllEmails(), 100);
                    }
                });

                // Handle tag click for editing
                container.addEventListener(''click'', (e) => {
                    if (e.target.classList.contains(''email-text'') || (e.target.classList.contains(''email-tag'') && !e.target.classList.contains(''remove-tag''))) {
                        e.stopPropagation();
                        const tag = e.target.classList.contains(''email-tag'') ? e.target : e.target.parentElement;
                        const email = tag.dataset.email;

                        // Remove the tag and put email back in input for editing
                        tag.remove();
                        input.value = email;
                        input.focus();
                        // Trigger validation after removing tag
                        setTimeout(() => validateAllEmails(), 100);
                    }
                });

                // Handle input events
                input.addEventListener(''keydown'', (e) => {
                    const value = input.value.trim();

                    if ((e.key === ''Enter'' || e.key === '','' || e.key === '';'' || e.key === '' '') && value) {
                        e.preventDefault();
                        addEmailTag(container, value);
                        input.value = '''';
                    }

                    if (e.key === ''Backspace'' && !value) {
                        const lastTag = container.querySelector(''.email-tag:last-of-type'');
                        if (lastTag) {
                            lastTag.remove();
                        }
                    }
                });

                input.addEventListener(''blur'', () => {
                    const value = input.value.trim();
                    if (value) {
                        addEmailTag(container, value);
                        input.value = '''';
                    }
                });
            });
        }

        function addEmailTag(container, email) {
            email = email.replace(/[,;]+$/, '''').trim();
            if (!email) return;

            // Check if email already exists
            const existingEmails = Array.from(container.querySelectorAll(''.email-tag''))
                .map(tag => tag.dataset.email);
            if (existingEmails.includes(email)) return;

            const isValid = validateEmail(email);

 const tag = document.createElement(''div'');
            tag.className = `email-tag ${isValid ? '''' : ''invalid''}`;
     tag.dataset.email = email;
            tag.innerHTML = `
                <span class="email-text">${email}</span>
                <span class="remove-tag">×</span>
            `;

            const input = container.querySelector(''.email-input'');
            container.insertBefore(tag, input);

            // Trigger validation after adding tag
            setTimeout(() => validateAllEmails(), 100);
        }

        // Real-time validation function
        function validateAllEmails() {
            const containers = [''to'', ''cc'', ''bcc''];
            let hasInvalidEmails = false;

            containers.forEach(field => {
     const container = document.querySelector(`[data-field="${field}"]`);
                const errorMsg = document.querySelector(`[data-field="${field}-error"]`);
                const invalidTags = container.querySelectorAll(''.email-tag.invalid'');

                if (invalidTags.length > 0) {
                    hasInvalidEmails = true;
                    errorMsg.classList.add(''show'');
 } else {
                    errorMsg.classList.remove(''show'');
                }
            });

            // Update submit button state
            const submitBtn = document.getElementById(''submitEmailBtn'');
            if (hasInvalidEmails) {
                submitBtn.classList.add(''submit-disabled'');
                submitBtn.disabled = true;
            } else {
                submitBtn.classList.remove(''submit-disabled'');
                submitBtn.disabled = false;
            }

            return !hasInvalidEmails;
        }

        function validateEmail(email) {
            const pattern = /^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            return pattern.test(email);
        }

        function getEmailsFromContainer(container) {
            return Array.from(container.querySelectorAll(''.email-tag''))
                .map(tag => tag.dataset.email)
                .join('';'');
        }

        $(document).on(''click'', function (event) {
            const modal = $(''#Outlook_emailPopup'');
            if ($(event.target).is(''#Outlook_emailPopup'')) {
                closeMail();
            }
        });

        $(document).on(''keydown'', function (event) {
            if (event.key === ''Escape'') {
                closeMail();
            }
        });

        function initializeFilters() {
            let fromDate;
            let toDate;
            let viewall = 1;

            if (window.FromDateKPI && window.ToDateKPI) {
                fromDate = window.FromDateKPI;
                toDate = window.ToDateKPI;
                viewall = 0;
            } else {
                const today = new Date();
                const thirtyDaysAgo = new Date(today.getTime() - (30 * 24 * 60 * 60 * 1000));

                fromDate = thirtyDaysAgo.toISOString().split(''T'')[0];
                toDate = today.toISOString().split(''T'')[0];
            }

            $(''#filterFromDate'').val(fromDate);
            $(''#filterToDate'').val(toDate);

            reloadData(fromDate, toDate,window.EmployeeIDsKPI ? window.EmployeeIDsKPI : '''',viewall);

            $(''#filterBtn'').on(''click'', function () {
                const selectedFrom = $(''#filterFromDate'').val();
                const selectedTo = $(''#filterToDate'').val();

                if (!selectedFrom || !selectedTo) {
                    alert(''Vui lòng chọn cả từ ngày và đến ngày'');
                    return;
                }

                if (selectedFrom > selectedTo) {
                    alert(''Từ ngày phải nhỏ hơn hoặc bằng đến ngày'');
                    return;
                }

                // window.FromDateKPI = selectedFrom;
  // window.ToDateKPI = selectedTo;

                reloadData(selectedFrom, selectedTo);
            });

            $(''#resetBtn'').on(''click'', function () {
                const today = new Date();
                const thirtyDaysAgo = new Date(today.getTime() - (30 * 24 * 60 * 60 * 1000));

                const defaultFrom = thirtyDaysAgo.toISOString().split(''T'')[0];
                const defaultTo = today.toISOString().split(''T'')[0];

                $(''#filterFromDate'').val(defaultFrom);
                $(''#filterToDate'').val(defaultTo);

                // window.FromDateKPI = defaultFrom;
                // window.ToDateKPI = defaultTo;

                reloadData(defaultFrom, defaultTo,'''',1);
            });
        }

        $(document).ready(function() {
            loadPermission().then(() => {
                initializeFilters();
      // Initialize toolbar configuration after permission loaded
      setTimeout(function () {
                    if (typeof configureGridToolbar === ''function'') {
                        configureGridToolbar();

                    }

                }, 1500);
            }).catch((error) => {
      console.error(''Error loading permission:'', error);
                initializeFilters();
            });
        });

        // Event listener cho nút Soạn thư
        $(''#composeBtn'').on(''click'', function () {
            openComposeEmail();
        });

        // Handle form submit
        $(''#composeEmailForm'').on(''submit'', function (e) {
        console.log("hi")
            e.preventDefault();

            // Validate all emails before proceeding
            if (!validateAllEmails()) {
                uiManager.showAlert({
                    type: "error",
                    message: "Vui lòng sửa các email không hợp lệ trước khi gửi"
                });
                return;
            }

            const toContainer = document.querySelector(''[data-field="to"]'');
            const ccContainer = document.querySelector(''[data-field="cc"]'');
            const bccContainer = document.querySelector(''[data-field="bcc"]'');

            const to = getEmailsFromContainer(toContainer);
            const cc = getEmailsFromContainer(ccContainer);
            const bcc = getEmailsFromContainer(bccContainer);
            const subject = document.getElementById(''composeSubject'').value.trim();
             let currentHtml = InstanceBodyP963341F870E84D3AB81AE2C3FC6AAC20?.value;
            let standardHtml = getStandardHtml_BodyP963341F870E84D3AB81AE2C3FC6AAC20(currentHtml);

             let base64Html = utf16_le_to_b64_BodyP963341F870E84D3AB81AE2C3FC6AAC20(standardHtml);

            //let body = InstanceBodyP963341F870E84D3AB81AE2C3FC6AAC20?.value;


            if (!to) {
                uiManager.showAlert({ type: "error", message: "Vui lòng nhập ít nhất một địa chỉ email người nhận" });
                return;
            }

            // Double check for invalid emails (additional safety)
            const invalidEmails = document.querySelectorAll(''.email-tag.invalid'');
            if (invalidEmails.length > 0) {
                uiManager.showAlert({
                    type: "error",
                    message: "Có email không hợp lệ, vui lòng kiểm tra lại các email được đánh dấu màu đỏ"
                });
                return;
            }

            AjaxHPAParadise({
                data: {
                    name: "sp_SendEmailCRM",
                    param: [
                        ''EmployeeID'', window.EmployeeID_Login,
                        ''ToEmails'', to,
                        ''CcEmails'', cc,
                        ''BccEmails'', bcc,
                        ''Subject'', subject,
                        ''BodyContent'', base64Html
                    ]
                },
                success: function (data) {
        if (typeof data == "string" && !IsNullOrEmpty(data)) {
                        data = data.includes("{") ? data : EncryptionStringDecryption(data);
                    }
                    const json = typeof data === "string" ? JSON.parse(data) : data;
                    let newData = json.data[0];
                    if (newData && newData.length > 0) {
                        newData = newData[0].Result;
                         if (newData && (newData == "ERROR" || newData == "FAILED")) {
                            uiManager.showAlert({ type: "error", message: "Gửi email thất bại" });
                            return;
                        }
                    }
                    uiManager.showAlert({ type: "success", message: "Gửi email thành công" });
                    closeComposeEmail();
                },
                error: function (error) {
    console.error(''Error sending email:'', error);
                    uiManager.showAlert({ type: "error", message: "Gửi email thất bại" });
                }
         });

  });

        window.closeMail = closeMail;
        window.openComposeEmail = openComposeEmail;
        window.closeComposeEmail = closeComposeEmail;
        }) ();
    </script>
</div>
	'

    SELECT @html AS html;
	--  exec sptblCommonControlType_Signed_Duc 'sp_KPIListEmailManual_html'
    -- EXEC sp_GenerateHTMLScript_new 'sp_KPIListEmailManual_html'

END




GO

-- ===================================================================
-- STORED PROCEDURE 2: sp_KPIListEmailManual (Äiá»u phá»‘i cache)
-- ===================================================================
create   PROCEDURE [dbo].[sp_KPIListEmailManual](
@LoginID int,
@languageID varchar(5) = 'VN'
)
as
begin
	select top 1 html from tblHtmlScriptCache where TableName = 'sp_KPIListEmailManual_html' and ScreenType = -1 and LanguageID = @LanguageID;
end

GO