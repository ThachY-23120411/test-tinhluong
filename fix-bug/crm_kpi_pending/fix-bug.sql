ALTER PROCEDURE [dbo].[sp_CRM_KpiPending_html]
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
	<div id="sp_CRM_KpiPending_html">
    <style>
        .pending-container {
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            padding: 20px;
            margin-bottom: 20px;
        }

        .pending-header-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #e9ecef;
        }

        .pending-header-section h2 {
            margin: 0;
        }

        .pending-filter {
            display: flex;
            gap: 15px;
            align-items: flex-end;
            flex-wrap: wrap;
            margin-bottom: 20px;
        }

        .pending-filter>div {
            display: flex;
        }

        .pending-filter label {
            display: block;
            margin-bottom: 5px;
            font-weight: 600;
            color: #64748b;
            font-size: 13px;
        }

        .pending-filter button {
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
            border: 2px solid #198754;
        }

        .btn-reset:hover {
            background-color: #198754;
            color: white;
        }

        #pendingModal.show {
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            min-height: 100vh;
            background: rgba(19, 16, 16, .8) !important;
        }

        #rejectReasonModal.show {
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            min-height: 100vh;
            background: rgba(19, 16, 16, .8) !important;
        }

        .modal-backdrop.show {
            background: rgba(0, 0, 0, 0.65);
            backdrop-filter: blur(1px);
        }

        #pendingModal .modal-dialog {
            margin: 0 !important;
            max-width: 500px;
        }

        #rejectReasonModal .modal-dialog {
            margin: 0 !important;
            max-width: 400px;
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

        .pending-table tbody tr:hover {
            background-color: rgba(255, 255, 255, 0.05) !important;
        }

        .badge-view {
            display: inline-flex;
            align-items: center;
            padding: 6px 12px;
            border-radius: 20px;
            color: white;
            font-size: 12px;
            font-weight: 500;
        }

        .badge-view i {
            font-size: 14px;
        }

        .dx-placeholder {
            color: #999;
            font-style: italic;
        }

        /* Form group inline layout */
        #pendingModal .form-group {
display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 1rem !important;
        }

        #pendingModal .form-label {
            min-width: 140px;
            margin-bottom: 0 !important;
            font-weight: 600;
            color: #333;
        }

        #pendingModal .form-group>div:not(.form-label) {
            flex: 1;
            min-width: 0;
        }
    
        /* ============================================================================
           BỘ NGUYÊN TẮC FIX RESPONSIVE TOOLBAR THEO SKILL /RESPONSIVE-RULES
           ============================================================================ */

        /* Khóa biên khung nhìn & chống tràn toàn trang (Quy tắc 8) */
        #sp_CRM_KpiPending_html {
            min-width: 0 !important;
            max-width: 100% !important;
            overflow-x: hidden !important;
            box-sizing: border-box !important;
        }

        #sp_CRM_KpiPending_html .pending-container {
            min-width: 0 !important;
            max-width: 100% !important;
            box-sizing: border-box !important;
            padding: 16px !important;
        }

        /* 1. Header panel tự động co giãn theo chiều cao thực tế của Toolbar */
        #sp_CRM_KpiPending_html #GridPedingKC .dx-datagrid-header-panel {
            height: auto !important;
            min-height: auto !important;
            overflow: visible !important;
            padding: 4px 0 8px 0 !important;
        }

        /* 2. Toolbar & Container mở rộng tự do, không cố định pixel */
        #sp_CRM_KpiPending_html #GridPedingKC .dx-toolbar {
            height: auto !important;
            min-height: auto !important;
            overflow: visible !important;
            background: transparent !important;
        }

        #sp_CRM_KpiPending_html #GridPedingKC .dx-toolbar-items-container {
            height: auto !important;
            min-height: auto !important;
            display: flex !important;
            flex-direction: row !important;
            flex-wrap: wrap !important;
            align-items: center !important;
            justify-content: flex-start !important; /* Tuân thủ Quy tắc 6.5: Cấm space-between */
            row-gap: 8px !important;
            column-gap: 10px !important;
            width: 100% !important;
            max-width: 100% !important;
            padding: 0 !important;
            box-sizing: border-box !important;
        }

        /* 3. TRIỆT TIÊU BẪY THẺ BỌC TRUNG GIAN - ĐỒNG CẤP HÓA SIBLING (QUY TẮC 6.4 & 6.1) */
        #sp_CRM_KpiPending_html #GridPedingKC .dx-toolbar-before,
        #sp_CRM_KpiPending_html #GridPedingKC .dx-toolbar-before > .dx-toolbar-item,
        #sp_CRM_KpiPending_html #GridPedingKC .dx-toolbar-before > .dx-toolbar-item > .dx-toolbar-item-content,
        #sp_CRM_KpiPending_html #GridPedingKC .pending-toolbar-container {
            display: contents !important;
        }

        /* 4. ĐƯA DX-TOOLBAR-AFTER VỀ NORMAL FLOW & BÁM LỀ PHẢI (QUY TẮC 3 & 6.3) */
        #sp_CRM_KpiPending_html #GridPedingKC .dx-toolbar-after {
            position: static !important; /* Đánh sập position: absolute ngầm của DevExtreme */
            display: flex !important;
            align-items: center !important;
            gap: 8px !important;
            margin-left: auto !important; /* Bám lề phải cả ở Hàng 1 lẫn khi rớt Hàng 2 theo Quy tắc 6.3 & 3 */
            flex-shrink: 0 !important;
            height: auto !important;
            padding: 0 !important;
        }

        #sp_CRM_KpiPending_html #GridPedingKC .dx-toolbar-center {
            display: none !important;
        }

        /* 5. Khóa nguyên tử Widget chữ & cụm con (Quy tắc 2 & 7: Atomic Text & Non-shrink Lock) */
        #sp_CRM_KpiPending_html #GridPedingKC .pending-toolbar-item,
        #sp_CRM_KpiPending_html #GridPedingKC .pending-toolbar-btn {
            display: inline-flex !important;
            align-items: center !important;
            gap: 5px !important;
            flex: 0 0 auto !important;
            flex-shrink: 0 !important;
            white-space: nowrap !important;
        }

        #sp_CRM_KpiPending_html #GridPedingKC .pending-toolbar-item label {
            margin-bottom: 0 !important;
            white-space: nowrap !important;
            flex-shrink: 0 !important;
        }

        #sp_CRM_KpiPending_html #pendingFilterEmployeeToolbar {
            width: 160px !important;
            min-width: 140px !important;
            flex-shrink: 0 !important;
        }

        /* 6. Khóa nút Chọn cột hiển thị trực tiếp */
        #sp_CRM_KpiPending_html #GridPedingKC .dx-toolbar-item.dx-toolbar-button {
            flex-shrink: 0 !important;
        }

        /* 7. Ô tìm kiếm chuẩn sắc nét Dark Mode & chống icon kính lúp đè lên chữ */
        #sp_CRM_KpiPending_html #GridPedingKC .dx-datagrid-search-panel {
            min-width: 200px !important;
            max-width: 260px !important;
            flex-shrink: 0 !important;
        }

        #sp_CRM_KpiPending_html #GridPedingKC .dx-datagrid-search-panel .dx-texteditor-input {
            padding-left: 34px !important;
            box-sizing: border-box !important;
        }

        /* 8. Cô lập cuộn ngang cho DataGrid lớn (Quy tắc 9: Wide-Component Scroll Isolation) */
        #sp_CRM_KpiPending_html #GridPedingKC .dx-datagrid-rowsview {
            width: 100% !important;
            max-width: 100% !important;
            overflow-x: auto !important;
            -webkit-overflow-scrolling: touch !important;
        }
    </style>

    <div class="pending-container">
        <div class="pending-header-section">
            <h2>%PendingList%</h2>
            <div id="bulkActionButtons" style="display: none; gap: 10px;">
                <button class="btn btn-danger" id="btnBulkRejectHeader" style="padding: 8px 16px; display: none;">
                    <i class="bi bi-x-circle"></i> %Reject%
                </button>
                <button class="btn btn-success" id="btnBulkApproveHeader" style="padding: 8px 16px; display: none;">
                    <i class="bi bi-check-circle"></i> %Approve%
                </button>
            </div>
        </div>

        <div class="pending-filter" style="display: none;">
            <div id="pendingFilterEmployeeWrapper">
                <label for="pendingFilterEmployee">%Employee%:</label>
                <div id="P951B39C3CDA443E8B6757A85F3310863"></div>
            </div>
            <div>
                <label for="pendingFilterFromDate">%From%:</label>
                <input type="date" id="pendingFilterFromDate" style="
                    padding: 9px;
                    border-radius: 10px;
                    border: 0.5px solid #ebebeb;
                ">
            </div>
            <div>
                <label for="pendingFilterToDate">%To%:</label>
                <input type="date" id="pendingFilterToDate" style="
                    padding: 9px;
                    border-radius: 10px;
                    border: 0.5px solid #ebebeb;
                ">
            </div>
            <div>
                <label for="pendingFilterStatus">%Status%:</label>
                <select id="pendingFilterStatus" style="
                    padding: 9px;
                    border-radius: 10px;
                    border: 0.5px solid #ebebeb;
                    height: 36px;
                ">
                    <option value="0">%All%</option>
                    <option value="1">%Waiting%</option>
                    <option value="2">%Approved%</option>
                    <option value="3">%Rejected%</option>
                </select>
            </div>
            <button class="btn-filter" id="btnPendingFilter">
                <i class="bi bi-filter"></i> %Search%
            </button>
            <button class="btn-reset" id="btnPendingReset">
                <i class="bi bi-arrow-clockwise"></i> %Refresh%
            </button>
        </div>

          <div>
            <div id="GridPedingKC" style="height: 100%;"></div>
        </div>
    </div>

    <!-- Pending Modal -->
    <div class="modal fade" id="pendingModal" tabindex="-1" data-bs-backdrop="static" data-bs-keyboard="false">
        <div class="modal-dialog modal-md">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="pendingModalTitle">%AddNewData%</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="pendingForm">
                        <div class="form-group mb-3">
                            <label for="pending_createdDate" class="form-label">%CreatedDate%:</label>
                            <div id="P7235EDC20B924BC6AEEA0606CA3905B0"></div>
                        </div>
                        <div class="form-group mb-3">
                            <label for="pending_EmployeeID" class="form-label">%EmployeeID%:</label>
                            <div id="PC7C2C11BA1DD4EC3AFF6D836B67994A0"></div>
                        </div>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group mb-3">
                                    <label for="pending_company" class="form-label">%Company%:</label>
                                    <div id="P2CA05CCD700E4FB8A62C1D1108A6C237"></div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group mb-3">
                                    <label for="pending_taxCode" class="form-label">%TaxCode%:</label>
                                    <div id="P545B25A8C4F048D39964AA798B0CE115"></div>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group mb-3">
                                    <label for="pending_industry" class="form-label">%Industry%:</label>
                                    <div id="P1F778863ED7C41D08712A761CE9D64E3"></div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group mb-3">
                                    <label for="pending_address" class="form-label">%Address%:</label>
                                    <div id="PC0A728C3C79D4DB2B7004946CF08BF43"></div>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group mb-3">
                                    <label for="pending_contactPerson" class="form-label">%ContactPerson%:</label>
                                    <div id="P62444692C8CA4B92BF2D21E81DDB743C"></div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group mb-3">
                                    <label for="pending_phone" class="form-label">%Phone%:</label>
                                    <div id="PC3B74A7F9CB54913BBF84EA8D1BB8ECF"></div>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group mb-3">
                                    <label for="pending_email" class="form-label">%Email%:</label>
                                    <div id="PFD5D2756B322419EB79C8869BC0727C0"></div>
                                </div>

                            </div>
                            <div class="col-md-6">
                                <div class="form-group mb-3">
                                    <label for="pending_position" class="form-label">%JobPosition%:</label>
                                    <div id="P88755B14CC254990A88CFB4F671A691E"></div>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group mb-3">
                                    <label for="pending_companySize" class="form-label">%CompanySize%:</label>
                                    <div id="PD6C7ED44D4104996A84FD935D2111307"></div>
                                </div>
                            </div>
  <div class="col-md-6">
                          <div class="form-group mb-3">
                                    <label for="pending_source" class="form-label">%Source%:</label>
                                    <div id="PEEF7B29B28754A088C4DB26DB2C70411"></div>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-12">
                                <div class="form-group mb-3">
                                    <label for="pending_notes" class="form-label">%Notes%:</label>
                                    <div id="P4EC2172540704139A0E5FA01A7142944"></div>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-12">
                                <div class="form-group mb-3">
                                    <label for="pending_notes" class="form-label">%Status%:</label>\
                                    <div class="statusForm"></div>
                                </div>
                            </div>
                        </div>

                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" id="btnClosePending"
                        data-bs-dismiss="modal">%Close%</button>
                    <button type="button" class="btn btn-danger" id="btnRejectPending">%Reject%</button>
                    <button type="button" class="btn btn-primary" id="btnSavePending">%Agree%</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Reject Reason Modal -->
    <div class="modal fade" id="rejectReasonModal" tabindex="-1" data-bs-backdrop="static" data-bs-keyboard="false">
        <div class="modal-dialog modal-sm">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">%RejectReason%</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="form-group">
                        <label for="rejectReason" class="form-label">%EnterRejectReason%:</label>
                        <textarea class="form-control" id="rejectReason" rows="4"
                            placeholder="Nhập lý do..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">%Cancel%</button>
                    <button type="button" class="btn btn-primary" id="btnConfirmReject">%Agree%</button>
                </div>
            </div>
        </div>
    </div>

</div>
<script>
    (() => {         

        let isToolbarConfigured = false;

        let AccessKey = '''';
        let isManager = false;

        // Lưu trữ tham chiếu DOM node nhân viên bền vững vào biến toàn cục chống DevExtreme destroy
        window._persistedEmployeeDiv_P951 = window._persistedEmployeeDiv_P951 || null;

        function attachEmployeeFilterToToolbar() {
            if (!isManager) return;
            const toolbarWrapper = document.getElementById("pendingFilterEmployeeToolbar");
            if (!toolbarWrapper) return;

            // 1. Nắm giữ tham chiếu node gốc nếu chưa lưu
            if (!window._persistedEmployeeDiv_P951) {
                const orig = document.getElementById("P951B39C3CDA443E8B6757A85F3310863");
                if (orig) {
                    window._persistedEmployeeDiv_P951 = orig;
                }
            }

            // 2. Gắn node vào toolbar wrapper nếu wrapper đang rỗng
            if (window._persistedEmployeeDiv_P951 && toolbarWrapper.children.length === 0) {
                toolbarWrapper.appendChild(window._persistedEmployeeDiv_P951);
                window._persistedEmployeeDiv_P951.style.display = "block";
                window._persistedEmployeeDiv_P951.style.width = "100%";
                
                // Repaint display box nếu hàm tồn tại
                if (typeof renderDisplayBoxFullNameP951B39C3CDA443E8B6757A85F3310863 === "function") {
                    renderDisplayBoxFullNameP951B39C3CDA443E8B6757A85F3310863();
                }
            }
        }
        async function loadPermission() {
            return new Promise((resolve, reject) => {
                AjaxHPAParadise({
                    data: {
                        name: "sp_Common_GetUserPermissionDuc",
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
                            AccessKey = perm.AccessID || '''';
                        }
                        // Set isManager based on AccessKey
                        isManager = (AccessKey == ''-1'' || AccessKey == 1);
                        resolve();
                    },
                    error: reject
                })
            })
        }

        // window.InstanceGridPedingKCP7347CD0B4C364443AD716ADC3225C05C
        // InstanceCreatedDateP7235EDC20B924BC6AEEA0606CA3905B0
        // InstancecompanyP2CA05CCD700E4FB8A62C1D1108A6C237
        // InstancecompanySizePD6C7ED44D4104996A84FD935D2111307
        // InstanceindustryP1F778863ED7C41D08712A761CE9D64E3
        // InstanceaddressPC0A728C3C79D4DB2B7004946CF08BF43
        // InstancecontactPersonP62444692C8CA4B92BF2D21E81DDB743C
        // InstancephonePC3B74A7F9CB54913BBF84EA8D1BB8ECF
        // InstanceemailPFD5D2756B322419EB79C8869BC0727C0
        // InstancetaxCodeP545B25A8C4F048D39964AA798B0CE115
        // InstancesourcePEEF7B29B28754A088C4DB26DB2C70411
        // InstancePositionIDP88755B14CC254990A88CFB4F671A691E
        // Instancenegotiation1P4EC2172540704139A0E5FA01A7142944
        // InstanceEmployeeNamePC7C2C11BA1DD4EC3AFF6D836B67994A0
        // InstanceFullNameP951B39C3CDA443E8B6757A85F3310863 tagBox

        let DataSource = []

        // ================================= GRID PENDING KC =================================
        window.InstanceGridPedingKCP7347CD0B4C364443AD716ADC3225C05C = null;
        // Thêm responsive styles cho grid header
        const styleGridPedingKC = document.createElement("style");
          styleGridPedingKC.textContent = `
                            /* =============== RESPONSIVE POPUP STYLES =============== */
                            .dx-datagrid-search-panel .dx-placeholder {
                                display: none !important;
                            }

                            /* =============== FIX TEXTBOX TRONG GRID =============== */
                            .dx-datagrid .dx-texteditor {
                                width: 100% !important;
                                min-width: 0 !important;
                            }

   .dx-datagrid .dx-texteditor-input {
                                width: 100% !important;
                                min-width: 0 !important;
                                box-sizing: border-box !important;
                            }

                            .dx-datagrid-rowsview .dx-row > td > div {
                                white-space: nowrap;
                                overflow: hidden;
                                text-overflow: ellipsis;
                                word-break: break-word !important;
                                line-height: 1.4 !important;
                            }

                            .dx-popup.hpa-responsive {
                                max-width: 95vw !important;
                                max-height: 95vh !important;
                                width: 95vw !important;
                                left: 0 !important;
                                top: 0 !important;
                            }

                            .dx-popup.hpa-responsive .dx-popup-content {
                                height: calc(95vh - 120px) !important;
                                max-height: calc(95vh - 120px) !important;
                                overflow-y: auto !important;
            padding: 8px !important;
                                display: flex !important;
      flex-direction: column !important;
                            }

                 .dx-popup.hpa-responsive .dx-popup-content-scrollable {
                                flex: 1 !important;
                                min-height: 0 !important;
   overflow: auto !important;
                            }

                            .dx-popup-content.dx-popup-content-scrollable {
                  height: auto !important;
                            }

                            .dx-popup.hpa-responsive .dx-toolbar-items {
                                padding: 4px 0 !important;
                                flex-wrap: wrap;
                            }

                            .dx-popup.hpa-responsive .dx-toolbar-item {
                                margin: 2px 2px !important;
                            }

                            /* =============== GRID HEADER STYLES =============== */
                     .dx-datagrid {
                                font-size: 14px;
                                table-layout: fixed !important;
                            }

                            /* FIX COLUMN WIDTH ALIGNMENT */
                            .dx-datagrid-table {
                                table-layout: fixed !important;
                                width: 100% !important;
                            }

                            .dx-datagrid-headers .dx-datagrid-table {
                                table-layout: fixed !important;
                            }

                            .dx-datagrid-rowsview .dx-datagrid-table {
                                table-layout: fixed !important;
                            }

                            /* Ensure header and content cells have same width calculation */
                            .dx-datagrid .dx-header-row > td,
                            .dx-datagrid .dx-data-row > td {
                                box-sizing: border-box !important;
                                overflow: hidden !important;
                            }

                            .dx-datagrid-headers {
                                white-space: normal;
                                word-break: break-word;
                            }

                            .dx-datagrid-header-panel {
                                padding: 8px;
                            }

                            .dx-datagrid .dx-header-row {
     height: auto;
     min-height: 44px;
     }

                            .dx-datagrid .dx-row > td {
                                padding: 8px !important;
                                vertical-align: middle !important;
                            }

                            .dx-datagrid .dx-col-fixed {
                                z-index: 800 !important;
                            }

                            /* FORCE COLUMN WIDTH CONSISTENCY */
                            .dx-datagrid .dx-header-row > td,
                            .dx-datagrid .dx-data-row > td {
                                min-width: 0 !important;
                                width: auto !important;
                                max-width: none !important;
                            }

                            /* Prevent column width calculation conflicts */
                            .dx-datagrid-headers .dx-header-row td,
                            .dx-datagrid-rowsview .dx-data-row td {
                                position: relative !important;
                            }

                            /* Group row - sát mép */
                            .dx-datagrid .dx-group-row {

                             padding: 0 !important;
                          }

                            .dx-datagrid .dx-group-row > td {
                                padding: 8px !important;
                            }

                            .dx-datagrid .dx-group-row .dx-group-text {
                                padding: 0 !important;
                                margin: 0 !important;
                            }

                            /* Mobile responsive */
   @media (max-width: 1024px) {
                                .dx-popup.hpa-responsive {
                                    max-width: 90vw !important;
                                    max-height: 90vh !important;
                                    width: 90vw !important;
                                    left: 5vw !important;
                                }
                                .dx-overlay-content.dx-popup-normal.dx-popup-draggable.dx-resizable {
                                    width: 90vw !important;
                                    max-width: 90vw !important;
                                }
                                .dx-popup.hpa-responsive .dx-popup-content {
                                    max-height: calc(95vh - 120px) !important;
                                }

                                /* Fix grid width alignment on tablet */
                                .dx-datagrid-table {
                                    min-width: 100% !important;
                                }
                            }

                            @media (max-width: 768px) {
                                .dx-datagrid {
                                    font-size: 12px;
                                }

                                /* Maintain fixed table layout on mobile */
                                .dx-datagrid-table {
                                    table-layout: fixed !important;
                                    min-width: 100% !important;
                                }

                                .dx-datagrid-headers {
                                    padding: 4px !important;
                                }

                                .dx-datagrid .dx-header-row {
                                    height: auto;
                         min-height: 36px;
                                    padding: 0 !important;
                   }

                                .dx-datagrid-text-content {
                                    padding: 4px 2px !important;
                                    font-size: 11px !important;
     line-height: 1.3 !important;
       overflow: hidden !important;
                         white-space: nowrap !important;
                                    text-overflow: ellipsis !important;
                                    word-break: break-word !important;
                                }

                                .dx-datagrid-text-content.dx-header-filter {
                                    padding: 2px 1px !important;
                                }

                                .dx-checkbox {
                                    width: 24px !important;
                             height: 24px !important;
                  }

                                .dx-datagrid-rowsview {
                                    padding: 0 !important;
                                }

                                .dx-datagrid .dx-row {
                                    height: auto;
                                    min-height: 36px !important;
                                    padding: 0 !important;
                                }

                                .dx-datagrid .dx-data-row > td > div {
                                    padding: 4px 8px !important;

   white-space: nowrap !important;
                   text-overflow: ellipsis !important;
                                    word-break: break-word !important;
                                    vertical-align: middle !important;
                                    overflow: hidden !important;
                                    box-sizing: border-box !important;
                                }

                                .dx-datagrid .dx-group-row > td {
                                    padding: 4px 2px !important;
               }

              .dx-pager {
                                    padding: 4px 0 !important;
                                }

                                .dx-pager-page,
                                .dx-pager-navigation {
                                    padding: 2px 4px !important;
                                    font-size: 11px !important;
                                }

                                .dx-searchbox {
                                    width: 100% !important;
                                    max-width: none !important;
                                }

                                .dx-searchbox .dx-texteditor-input {
                                    padding: 4px !important;
                                    font-size: 12px !important;
                                    height: 32px !important;
                                }

                                .dx-popup.hpa-responsive {
                                    max-width: 95vw !important;
                                    max-height: 85vh !important;
                                    width: 95vw !important;
                                    left: 2.5vw !important;
                                    top: 5vh !important;
                                }
                                .dx-overlay-content.dx-popup-normal.dx-popup-draggable.dx-resizable {
                                    width: 95vw !important;
                                    max-width: 95vw !important;
                                    height: auto !important;
                                    max-height: 85vh !important;
                                }
                                .dx-popup.hpa-responsive .dx-overlay-wrapper {
                                    position: fixed !important;
                                }
       .dx-popup.hpa-responsive .dx-popup-content {
                                    height: calc(95vh - 120px) !important;
                                    max-height: calc(95vh - 120px) !important;
                            font-size: 13px !important;
                                    padding: 6px !important;
               display: flex !important;
    flex-direction: column !important;
                                }

                                .dx-popup.hpa-responsive .dx-popup-content-scrollable {
                                    flex: 1 !important;
                                    min-height: 0 !important;
                                    overflow: auto !important;
                                }

                                .dx-popup-content.dx-popup-content-scrollable {
                                    height: auto !important;
                                }

                     /* Toolbar buttons */
                                .dx-popup.hpa-responsive .dx-toolbar-item .dx-button {
                                    padding: 6px 12px !important;
                                    font-size: 12px !important;
                                    min-height: 36px !important;
                                width: auto !important;
                                }
                                .dx-popup.hpa-responsive .dx-toolbar-item .dx-button .dx-button-text {
                        font-size: 12px !important;
                    }
                                .dx-popup.hpa-responsive .dx-button {
                                    padding: 6px 12px !important;
                                    font-size: 12px !important;
                                    min-height: 36px !important;
                                    width: auto !important;
                                }
                                .dx-popup.hpa-responsive .dx-button .dx-button-text {
                                    font-size: 12px !important;
     }
     .dx-popup.hpa-responsive .dx-datagrid {
                                 font-size: 11px !important;
                                }
                                .dx-popup.hpa-responsive .dx-datagrid .dx-data-row td {
                                    padding: 4px 2px !important;
                                }
                            }

                            @media (max-width: 480px) {
                                .dx-datagrid {
                                    font-size: 12px;
                                }

                                .dx-datagrid-headers {
                                    padding: 2px !important;
                                }

                                .dx-datagrid .dx-header-row {
                                    min-height: 32px;
                                }

                                .dx-datagrid-text-content {
                                    padding: 2px 1px !important;
                                    font-size: 12px !important;
                                }

                                .dx-checkbox {
                                    width: 20px !important;
                                    height: 20px !important;
                                }

                                .dx-datagrid .dx-row {
                                    min-height: 32px;
                                }

                                .dx-datagrid .dx-data-row > td > div {
                                    padding: 8px !important;
                                    font-size: 12px !important;
                                }

                    .dx-pager-page,
                                .dx-pager-navigation {
            padding: 1px 2px !important;
                                    font-size: 12px !important;
                                }

                              .dx-popup.hpa-responsive {
                                    max-width: 98vw !important;
               max-height: 80vh !important;
                      width: 98vw !important;
                          left: 1vw !important;
                       top: 10vh !important;
                                }
                                .dx-overlay-content.dx-popup-normal.dx-popup-draggable.dx-resizable {
                                    width: 98vw !important;
                                    max-width: 98vw !important;
                                    height: auto !important;
                                    max-height: 80vh !important;
                                }
                                .dx-popup.hpa-responsive .dx-overlay-wrapper {

                                    position: fixed !important;
                    }
                                .dx-popup.hpa-responsive .dx-popup-content {
                                    height: calc(95vh - 120px) !important;
                                    max-height: calc(95vh - 120px) !important;
                                    font-size: 12px !important;
                                    padding: 4px !important;
                                    display: flex !important;
                                 flex-direction: column !important;
 }

                                .dx-popup.hpa-responsive .dx-popup-content-scrollable {
                                    flex: 1 !important;
                                    min-height: 0 !important;
                                    overflow: auto !important;
                                }

                                .dx-popup-content.dx-popup-content-scrollable {
                                    height: auto !important;
                                }
                                /* Toolbar buttons */
                                .dx-popup.hpa-responsive .dx-toolbar-item .dx-button {
      padding: 4px 8px !important;
          font-size: 11px !important;
                                min-height: 32px !important;
                                    width: auto !important;
                                }
                                .dx-popup.hpa-responsive .dx-toolbar-item .dx-button .dx-button-text {
                                    font-size: 11px !important;
                                }
                                .dx-popup.hpa-responsive .dx-button {
                                    padding: 4px 8px !important;
                                    font-size: 11px !important;
                                    min-height: 32px !important;
                                    width: auto !important;
                                }
                                .dx-popup.hpa-responsive .dx-button .dx-button-text {
                                    font-size: 11px !important;
                                }
                                .dx-popup.hpa-responsive .dx-datagrid {
                                    font-size: 10px !important;
                                }
                                .dx-popup.hpa-responsive .dx-datagrid .dx-data-row td {
                                    padding: 2px 1px !important;
                                    font-size: 10px !important;
                                }
                                .dx-popup.hpa-responsive .dx-datagrid .dx-header-row {
                                    min-height: 28px !important;
    }
                                .dx-popup.hpa-responsive .dx-checkbox {
                                   width: 18px !important;
                                    height: 18px !important;
       }
                            }
                        `;
        document.head.appendChild(styleGridPedingKC);

        // Helper normalize function: bỏ dấu - dùng chung cho search/grid
        window.normalizeVietnameseText = window.normalizeVietnameseText || function (value) {
            if (value === undefined || value === null) return "";
            let text = String(value);
            if (typeof RemoveToneMarks_Js === "function") {
                text = RemoveToneMarks_Js(text);
            } else if (text.normalize) {
                text = text.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
            }
            return text.replace(/đ/g, "d").replace(/Đ/g, "D").toLowerCase();
        };

        // ===== Column chooser persistence helpers (shared) =====
        const gridName = "GridPedingKC";
        window.hpaColumnChooser = window.hpaColumnChooser || { saveTimers: {} };
        const chooser = window.hpaColumnChooser;

        if (!chooser.normalize) {
            chooser.normalize = function (res) {
                if (typeof res === "string" && res.trim() !== "") {
                    return res.includes("{") ? JSON.parse(res) : JSON.parse(EncryptionStringDecryption(res));
                }
                return res;
            };
        }

        if (!chooser.load) {
            chooser.load = function (gridInstance, gridNameParam) {
                AjaxHPAParadise({
                    data: {
                        name: "sp_GridColumnChooser_Load",
                        param: [
                            "LoginID", window.UserID,
                            "GridName", gridNameParam
                        ]
                    },
                    success: function (res) {
                        const json = chooser.normalize(res);
                        const rows = (json?.data && json.data[0]) || [];
                        const settingsJson = rows[0]?.SettingsJson;
                        if (!settingsJson) return;
                        let arr = [];
                        try { arr = JSON.parse(settingsJson) || []; } catch (e) { arr = []; }
                        arr.forEach(r => {
                            if (!r.ColumnName) return;
                            const opts = {};
                            if (r.IsVisible !== undefined && r.IsVisible !== null) opts.visible = r.IsVisible === 1;
                            if (r.OrderIndex !== undefined && r.OrderIndex !== null) opts.visibleIndex = r.OrderIndex;
                            if (r.ColumnWidth !== undefined && r.ColumnWidth !== null) opts.width = r.ColumnWidth;
                            gridInstance.columnOption(r.ColumnName, opts);
                        });
                    }
                });
            };
        }

        if (!chooser.save) {
            chooser.save = function (gridInstance, gridNameParam) {
                const cols = (gridInstance.getColumns() || [])
                    .map(c => {
                        const name = c.dataField || c.name;
                        if (!name) return null;
                        return {
                            ColumnName: name,
                            IsVisible: c.visible !== false ? 1 : 0,
                            OrderIndex: c.visibleIndex,
                            ColumnWidth: c.width ? parseInt(c.width) : null
                        };
                    })
                    .filter(Boolean);

                AjaxHPAParadise({
                    data: {
                        name: "sp_GridColumnChooser_Save",
                        param: [
                            "LoginID", window.UserID,
               "GridName", gridNameParam,
       "Columns", JSON.stringify(cols)
                        ]
                 },
                    success: function (res) {
                        if (typeof res === "string" && res.trim() !== "") {
                            res = res.includes("{") ? res : EncryptionStringDecryption(res);
                        }
                    }
                });
            };
        }

        // =============== GRID CONFIG DYNAMIC BASED ON DATA SIZE ===============
        // Hàm tính remoteOperations dựa trên số lượng dòng
        window.getGridConfig_GridPedingKC = function (dataArray) {
            const dataSize = Array.isArray(dataArray) ? dataArray.length : 0;
            const isLargeDataset = dataSize > 1000;

            return {
                remoteOperations: isLargeDataset,
                pageSize: 50,
                allowedPageSizes: [5, 10, 50, 100]
            };
        };

        InstanceGridPedingKCP7347CD0B4C364443AD716ADC3225C05C = $("#GridPedingKC").dxDataGrid({
            dataSource: [],
            keyExpr: "ID",
            height: "100%",
            width: "100%",
            showBorders: true,
            showRowLines: true,
            rowAlternationEnabled: false,
            hoverStateEnabled: false,
            columnAutoWidth: true,
            allowColumnReordering: true,
            allowColumnResizing: true,
            columnResizingMode: "widget",
            columnMinWidth: 50,
            wordWrapEnabled: false,

           scrolling: {
                mode: "standard",
                showScrollbar: "always",
                useNative: false
            },

            paging: {
                enabled: true,
                pageSize: 10
            },

            pager: {
                visible: true,
                allowedPageSizes: [5, 10, 50, 100],
                showPageSizeSelector: true,
                showInfo: true,
                showNavigationButtons: true
            },

            selection: {
                mode: "multiple",
                showCheckBoxesMode: "always",
                allowSelectAll: true
            },

            searchPanel: {
                visible: true,
                width: 260,
                highlightSearchResults: false,
                highlightCaseSensitive: false,
                placeholder: "Tìm kiếm theo nội dung"
            },


            headerFilter: { visible: false },

            columnChooser: {
                enabled: true,
                mode: "select",
                title: "Chọn cột hiển thị",
                allowSearch: true
            },

            stateStoring: {
                enabled: false,
                type: "localStorage",
                storageKey: "gridState_GridPedingKC"
            },

            grouping: {
                autoExpandAll: false,
                contextMenuEnabled: false,
                allowCollapsing: false
            },

            groupPanel: { visible: false },
            columnFixing: { enabled: false },

            customizeColumns: function (columns) {
                const normalizeText = window.normalizeVietnameseText || function (val) {
                    if (val === undefined || val === null) return "";
                    return String(val).toLowerCase();
                };

                columns.forEach(function (column) {
                    if (column._hpaSearchNormalized) return;
                    column._hpaSearchNormalized = true;

                    const originalCalculate = column.calculateFilterExpression;
                    const dataFieldPath = column.dataField || column.name || "";
                    const getValue = column.calculateCellValue
                        ? column.calculateCellValue.bind(column)
                        : function (dataObj) {
if (!dataObj || !dataFieldPath) return null;
                            if (dataFieldPath.indexOf(".") === -1) {
                                return dataObj[dataFieldPath];
                            }
                            return dataFieldPath.split(".").reduce(function (acc, key) {
                                return acc && acc[key] !== undefined ? acc[key] : null;
                            }, dataObj);
                        };

                    column.calculateFilterExpression = function (filterValue, selectedFilterOperation, target) {
                        if (target === "search") {
                            const normalizedFilter = normalizeText(filterValue);
                            if (!normalizedFilter) {
                                if (originalCalculate) {
                                    return originalCalculate.call(this, filterValue, selectedFilterOperation, target);
                                }
                                if (this.defaultCalculateFilterExpression) {
                                    return this.defaultCalculateFilterExpression(filterValue, selectedFilterOperation, target);
                                }
                                return null;
                            }

                            return function (dataItem) {
                                const rawValue = getValue ? getValue(dataItem) : null;
                                const normalizedValue = normalizeText(rawValue);
                                return normalizedValue.indexOf(normalizedFilter) > -1;
                            };
                        }

                        if (originalCalculate) {
                            return originalCalculate.call(this, filterValue, selectedFilterOperation, target);
                        }

                        if (this.defaultCalculateFilterExpression) {
                            return this.defaultCalculateFilterExpression(filterValue, selectedFilterOperation, target);
                        }

                        return null;
                    };
                });
            },

            editing: {
                mode: "cell",
                allowUpdating: false
            },
            rowDragging: {
                allowReordering: false,
                showDragIcons: false
            }
            ,
            noDataText: "Không có dữ liệu",
            columns: [

               {
                    dataField: "_detailAction",
                    caption: "",
                    width: 50,
                    alignment: "center",
                    allowSorting: false,
                    allowFiltering: false,
                    allowReordering: false,
                    allowResizing: false,
                    fixed: false,
                    cellTemplate: function (container, options) {
                        $("<div>").addClass("detail-btn").html(''<i class="fa fa-eye" style="cursor: pointer; color: #007bff; font-size: 14px;"></i>'').appendTo(container);
                    }
                },
                {
                    dataField: "CreatedDate",
                    caption: "%TimeSend%",
                    width: 150,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function (cellElement, cellInfo) {
                        const val = cellInfo.value;
                        if (!val) {                           
                            return;
                        }

                        const d = new Date(val);
                        let text = "";


                        text = DevExpress.localization.formatDate(d, "dd/MM/yyyy HH:mm");


                        $("<div>").text(text).appendTo(cellElement);
                    },
                    allowEditing: true,
                editCellTemplate: function (cellElement, cellInfo) {
                        // Cập nhật record context ID cho row hiện tại
                        let rowID = null;
                        if (cellInfo.key !== undefined && cellInfo.key !== null) {
                            rowID = cellInfo.key;
                        } else if (cellInfo.data && cellInfo.data["ID"] !== undefined) {
                            rowID = cellInfo.data["ID"];
                        }

                        if (rowID !== null) {
                            currentRecordID_ID = rowID;
                        }

                        if ("" && "".trim() !== "" && cellInfo.data && cellInfo.data[""] !== undefined) {
                            currentRecordID_ = cellInfo.data[""];
                        }


                        let InstanceCreatedDateP7347CD0B4C364443AD716ADC3225C05C = null;
                        let CreatedDateTimeOut;
                        let _autoSaveCreatedDateP7347CD0B4C364443AD716ADC3225C05C = (typeof window["AutoSave_CreatedDate"] !== "undefined" ? window["AutoSave_CreatedDate"] : false);
                        let _readOnlyCreatedDateP7347CD0B4C364443AD716ADC3225C05C = (typeof window["ReadOnly_CreatedDate"] !== "undefined" ? window["ReadOnly_CreatedDate"] : false);

                        async function DateTimeBoxSaveLogicCreatedDate() {
                            let val = InstanceCreatedDateP7347CD0B4C364443AD716ADC3225C05C.option("value");
                            let valToSave = val ? DevExpress.localization.formatDate(new Date(val), "yyyy/MM/dd HH:mm") : null;
                            const dataJSON = JSON.stringify(["-1617191338", ["CreatedDate"], [valToSave]]);

                            // Context-aware record IDs
                            let id1 = currentRecordID_ID;
                            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                                id1 = cellInfo.data["ID"] || id1;
                            }
                            let currentRecordIDValue = [id1];
                            let currentRecordID = ["ID"];

                            if ("" && "".trim() !== "") {
                                let id2 = currentRecordID_;
                                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                                    id2 = cellInfo.data[""] || id2;
                                }
                                currentRecordIDValue.push(id2);
                                currentRecordID.push("");
                            }

                            const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);

                            try {
                                const json = await saveFunction(dataJSON, idValsJSON);
                                const dtError = json.data[json.data.length - 1] || [];
                                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                                    uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "%SaveErrorMessage%" });
                                } else {

                                    if (0 != 0 && 0 != null && 0 != "" && window.hpaSharedGridDataSources["0"]) {
                                        try {
                                            var updateData = {};
                                            updateData["ID"] = currentRecordIDValue[0];
                                            updateData["CreatedDate"] = InstanceCreatedDateP7347CD0B4C364443AD716ADC3225C05C.option("value");

                                            var id2FieldName = "";
                                            var hasKey2 = id2FieldName && id2FieldName !== "" && id2FieldName.indexOf("%") === -1;

                                            if (hasKey2) {
                                         if (currentRecordIDValue.length > 1 && currentRecordIDValue[1] !== undefined) {
                                            updateData[id2FieldName] = currentRecordIDValue[1];
                                               }
                                            }

                                            // Thực hiện update shared grid
                                            window.updateSharedGridRow("0", updateData);

                                            // Kiểm tra và cập nhật biến DataSource cục bộ
                                            if (typeof DataSource !== "undefined" && Array.isArray(DataSource)) {
                                                var ds;
                                                if (!hasKey2) {
                                                    // Trường hợp 1 khóa
                                                    ds = DataSource.filter(item => item["ID"] === updateData["ID"]);
                                                } else {
                                                    // Trường hợp 2 khóa
                                                    ds = DataSource.filter(item =>
                                                        item["ID"] === updateData["ID"] &&
                                                        item[id2FieldName] === updateData[id2FieldName]
                                                    );
                                                }

                                                if (ds && ds.length > 0) {
                                                    ds[0]["CreatedDate"] = updateData["CreatedDate"];
                                                }
                                            } // <-- Bạn thiếu dấu này
                                        } catch (dsErr) {
                                            console.warn("[Grid Sync] DateTimeBox CreatedDateP7347CD0B4C364443AD716ADC3225C05C: Không thể sync shared grid data source:", dsErr);
                                        }
                                    }
                                }

                                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                    try {
                                        const grid = cellInfo.component;
                                        grid.cellValue(cellInfo.rowIndex, "CreatedDate", val);
                                        grid.repaint();
                                    } catch (syncErr) {
                                        console.warn("[Grid Sync] DateTimeBox CreatedDateP7347CD0B4C364443AD716ADC3225C05C: Error", syncErr);
                                    }
                                }
                            } catch (err) {
                                console.error("DateTimeBox Save Error:", err);
                            }
                        }

                        InstanceCreatedDateP7347CD0B4C364443AD716ADC3225C05C = $(cellElement).dxDateBox({
                            type: "datetime",
                            displayFormat: "dd/MM/yyyy HH:mm",
                            useMaskBehavior: true,
                            openOnFieldClick: true,
                            showClearButton: false,
                            dateSerializationFormat: "yyyy-MM-ddTHH:mm:ss",
                            width: "100%",
                            elementAttr: { class: "hpa-dx-datebox-inline" },
                            readOnly: _readOnlyCreatedDateP7347CD0B4C364443AD716ADC3225C05C,
                            onValueChanged: async (e) => {
                                if (_autoSaveCreatedDateP7347CD0B4C364443AD716ADC3225C05C) {
                                    clearTimeout(CreatedDateTimeOut);
                                    e.event && await DateTimeBoxSaveLogicCreatedDate();
                                } else {
                                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                        const grid = cellInfo.component;
                                        grid.cellValue(cellInfo.rowIndex, "CreatedDate", e.value);
                                    }
                                }
                            },
                            onKeyUp: (e) => {
                                if (_autoSaveCreatedDateP7347CD0B4C364443AD716ADC3225C05C) {
                                    clearTimeout(CreatedDateTimeOut);
                                    CreatedDateTimeOut = setTimeout(async () => DateTimeBoxSaveLogicCreatedDate(), 1000);
                                }
                            }
                        }).dxDateBox("instance");

                        // Set initial value
                        if (cellInfo.value !== undefined && cellInfo.value !== null && InstanceCreatedDateP7347CD0B4C364443AD716ADC3225C05C) {
                            InstanceCreatedDateP7347CD0B4C364443AD716ADC3225C05C.option("value", cellInfo.value);
                        }
                    },
                },

                {
                    dataField: "EmployeeName",
                    caption: "%ACFullname%",
                    width: 150,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function (cellElement, cellInfo) {
                        const val = cellInfo.value;

                        if (val === undefined || val === null || val === "") {                           
                            return;
                        }

                        const ds = window["DataSource_EmployeeName"];
                        if (ds && Array.isArray(ds)) {
                            const f = ds.find(x => x.id == val || x.ID == val);
                            if (f) {
                                $("<div>").text(f.Text || f.Name || "").appendTo(cellElement);
                                return;
                            }
                        }

                        $("<div>").text(cellInfo.displayValue ?? val).appendTo(cellElement);
                    },
                    allowEditing: true,
                    editCellTemplate: function (cellElement, cellInfo) {
                        // Cập nhật record context ID cho row hiện tại
                        let rowID = null;
                        if (cellInfo.key !== undefined && cellInfo.key !== null) {
                            rowID = cellInfo.key;
                        } else if (cellInfo.data && cellInfo.data["ID"] !== undefined) {
                            rowID = cellInfo.data["ID"];
                        }

                        if (rowID !== null) {
                            currentRecordID_ID = rowID;
                        }

                        if ("" && "".trim() !== "" && cellInfo.data && cellInfo.data[""] !== undefined) {
                            currentRecordID_ = cellInfo.data[""];
                        }


                        // Set initial value
                        if (cellInfo.value !== undefined && cellInfo.value !== null && InstanceEmployeeNameP7347CD0B4C364443AD716ADC3225C05C) {
                            InstanceEmployeeNameP7347CD0B4C364443AD716ADC3225C05C.option("value", cellInfo.value);
                        }
                    },
                },

                {
                    dataField: "taxCode",
                    caption: "%lblTaxNo%",
                    width: 150,
                    allowSorting: true,
 allowFiltering: true,
                    cellTemplate: function (cellElement, cellInfo) {
 const val = cellInfo.value;

                        if (val === undefined || val === null || val === "") {                      
                            return;
                       }

                        const ds = window["DataSource_taxCode"];
                        if (ds && Array.isArray(ds)) {
                            const f = ds.find(x => x.id == val || x.ID == val);
                            if (f) {
                                $("<div>").text(f.Text || f.Name || "").appendTo(cellElement);
                                return;
                            }
                        }

                        $("<div>").text(cellInfo.displayValue ?? val).appendTo(cellElement);
                    },
                    allowEditing: true,
                    editCellTemplate: function (cellElement, cellInfo) {
                        // Cập nhật record context ID cho row hiện tại
                        let rowID = null;
                        if (cellInfo.key !== undefined && cellInfo.key !== null) {
                            rowID = cellInfo.key;
                        } else if (cellInfo.data && cellInfo.data["ID"] !== undefined) {
                            rowID = cellInfo.data["ID"];
                        }

                        if (rowID !== null) {
                            currentRecordID_ID = rowID;
                        }

                        if ("" && "".trim() !== "" && cellInfo.data && cellInfo.data[""] !== undefined) {
                            currentRecordID_ = cellInfo.data[""];
                        }


                        if (!window.__hpaTextBoxUnderlineStyleInjected) {
                            $("<style>")
                                .attr("id", "hpa-textbox-underline-style")
                                .text(`
                        .dx-texteditor.dx-editor-underlined::after {
                            border-bottom-color: #ddd !important;
                        }
                    `)
                                .appendTo("head");
                            window.__hpaTextBoxUnderlineStyleInjected = true;
                        }

                        let InstancetaxCodeP7347CD0B4C364443AD716ADC3225C05C = null;
                        let $containertaxCodeP7347CD0B4C364443AD716ADC3225C05C = $(cellElement);

                        let _autoSavetaxCodeP7347CD0B4C364443AD716ADC3225C05C = false;
                        let _readOnlytaxCodeP7347CD0B4C364443AD716ADC3225C05C = false;

                        let taxCodeP7347CD0B4C364443AD716ADC3225C05COriginalValue = "";
                        let _savingtaxCodeP7347CD0B4C364443AD716ADC3225C05C = false;
                        let taxCodeP7347CD0B4C364443AD716ADC3225C05CRealInstance = null;

                        /* =============== Helper Functions =============== */

                        function isValidCustomFunction(func) {
                            return func &&
                                func !== "" &&
                                func !== null &&
                                func !== undefined &&
                                typeof func === "function";
                        }

                        function showValidationErrortaxCodeP7347CD0B4C364443AD716ADC3225C05C(message) {
                            // Tô background đỏ nhạt và đổi màu underline
                            $containertaxCodeP7347CD0B4C364443AD716ADC3225C05C.find("input").css({
                                "background-color": "#ffe6e6"
                            });
                            // Bắn UI Alert
                            if (message && message != "" && typeof uiManager !== "undefined" && uiManager.showAlert) {
          uiManager.showAlert({ type: "error", message: message });
                     }
                        }

                        function hideValidationErrortaxCodeP7347CD0B4C364443AD716ADC3225C05C() {
                            $containertaxCodeP7347CD0B4C364443AD716ADC3225C05C.find("input").css({
   "background-color": ""
                            });
                        }

                        async function saveValuetaxCodeP7347CD0B4C364443AD716ADC3225C05C() {
                            if (_savingtaxCodeP7347CD0B4C364443AD716ADC3225C05C) return;

                            const newVal = taxCodeP7347CD0B4C364443AD716ADC3225C05CRealInstance.option("value");

                            if (newVal === taxCodeP7347CD0B4C364443AD716ADC3225C05COriginalValue) {
                                _savingtaxCodeP7347CD0B4C364443AD716ADC3225C05C = false;
                                return;
                            }

                            try {
                                _savingtaxCodeP7347CD0B4C364443AD716ADC3225C05C = true;

                                if (0 === 1) {
                                    if (!newVal || newVal.trim() === "") {
                                        const errorMsg = window.ValidationEngine && window.ValidationEngine.getRequiredMessage
                                            ? window.ValidationEngine.getRequiredMessage()
                                            : "Trường này là bắt buộc";

                                        showValidationErrortaxCodeP7347CD0B4C364443AD716ADC3225C05C(errorMsg);
                                        _savingtaxCodeP7347CD0B4C364443AD716ADC3225C05C = false;

                                        setTimeout(() => {
                                            $containertaxCodeP7347CD0B4C364443AD716ADC3225C05C.find("input").focus();
                                        }, 50);

                                        return;
                                    }
                                }

                                // Custom validation check
                                if (isValidCustomFunction(0)) {
                                    try {
                                        const validationResult = await 0(newVal);
                                        if (!validationResult) {
                                            showValidationErrortaxCodeP7347CD0B4C364443AD716ADC3225C05C();
                                            _savingtaxCodeP7347CD0B4C364443AD716ADC3225C05C = false;
                                            return;
                                        }
                                    } catch (validationError) {
                                        const errorMsg = typeof validationError === "string" ? validationError : "Validation failed";
                                        showValidationErrortaxCodeP7347CD0B4C364443AD716ADC3225C05C();
                                        _savingtaxCodeP7347CD0B4C364443AD716ADC3225C05C = false;
                                        return;
                                    }
                                }

                                console.log(_autoSavetaxCodeP7347CD0B4C364443AD716ADC3225C05C);
                                hideValidationErrortaxCodeP7347CD0B4C364443AD716ADC3225C05C();
                                if (_autoSavetaxCodeP7347CD0B4C364443AD716ADC3225C05C) {
                                    const dataJSON = JSON.stringify(["-1617191338", ["taxCode"], [newVal]]);

                                    let id1 = currentRecordID_ID;
                                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                                        id1 = cellInfo.data["ID"] || id1;
                                    }
                                let currentRecordIDValue = [id1];
                                    let currentRecordID = ["ID"];

                                    if ("" && "".trim() !== "") {
                                        let id2 = currentRecordID_;
         if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                                            id2 = cellInfo.data[""] || id2;
                                        }
                                        currentRecordIDValue.push(id2);
                                        currentRecordID.push("");
                                    }

                                    const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);

                                    const json = await saveFunction(dataJSON, idValsJSON);

                                    const dtError = json.data[json.data.length - 1] || [];
                                    if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                                        uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "%SaveErrorMessage%" });
                                        _savingtaxCodeP7347CD0B4C364443AD716ADC3225C05C = false;
                                        return;
                                    }

                                    if (0 != 0 && 0 != null && 0 != "" && window.hpaSharedGridDataSources["0"]) {
                                        try {
                                            let KeyRowTable = window.currentClicked_0;
                                            console.log("KeyRowTable:", KeyRowTable);
                                            if (KeyRowTable != null && KeyRowTable != undefined) {
                                                var updateData = {};
                                                updateData["0"] = KeyRowTable;
                                                updateData["taxCode"] = InstancetaxCodeP7347CD0B4C364443AD716ADC3225C05C.option("value");

                                                // 2. Thực hiện update Shared Grid
                                                // Vì dùng RowID, Grid sẽ tự tìm dòng cực nhanh
                                                window.updateSharedGridRow("0", updateData);

                                                // 3. Cập nhật biến DataSource cục bộ (Dùng RowID để tìm)
                                                if (typeof DataSource !== "undefined" && Array.isArray(DataSource)) {
                                                    // Chỉ cần 1 dòng filter duy nhất, không cần check hasKey2 rườm rà nữa
                                                    var ds = DataSource.filter(item => item.RowID === KeyRowTable);

                                                    if (ds && ds.length > 0) {
                                                        ds[0]["taxCode"] = updateData["taxCode"];

                                                        // Nếu bạn đang sửa chính là 1 trong các ID cấu thành RowID
                                                        // Cần cập nhật lại RowID mới nếu cần thiết (tùy logic nghiệp vụ)
                                                    }
                                                }
                                            }

                                            var updateData = {};
                                            updateData["ID"] = currentRecordIDValue[0];
                                            updateData["taxCode"] = InstancetaxCodeP7347CD0B4C364443AD716ADC3225C05C.option("value");

                                            var id2FieldName = "";
                                            var hasKey2 = id2FieldName && id2FieldName !== "" && id2FieldName.indexOf("%") === -1;

                                            if (hasKey2) {
  if (currentRecordIDValue.length > 1 && currentRecordIDValue[1] !== undefined) {
                                                    updateData[id2FieldName] = currentRecordIDValue[1];
                                                }
                                            }

                                   // Thực hiện update shared grid
                                            window.updateSharedGridRow("0", updateData);

                                            // Kiểm tra và cập nhật biến DataSource cục bộ
                                            if (typeof DataSource !== "undefined" && Array.isArray(DataSource)) {
                                                var ds;
                                                if (!hasKey2) {
                                                    // Trường hợp 1 khóa
                                                    ds = DataSource.filter(item => item["ID"] === updateData["ID"]);
                                                } else {
                                                    // Trường hợp 2 khóa
                                                    ds = DataSource.filter(item =>
                                                        item["ID"] === updateData["ID"] &&
                                                        item[id2FieldName] === updateData[id2FieldName]
                                                    );
                                                }

                                                if (ds && ds.length > 0) {
                                                    ds[0]["taxCode"] = updateData["taxCode"];
                                                }
                                            }
                                        } catch (dsErr) {
                                            console.warn("[Grid Sync] TextBox taxCodeP7347CD0B4C364443AD716ADC3225C05C: Không thể sync shared grid data source:", dsErr);
                                        }
                                    }
                                }

                                taxCodeP7347CD0B4C364443AD716ADC3225C05COriginalValue = newVal;

                                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                    try {
                                        const grid = cellInfo.component;
                                        grid.cellValue(cellInfo.rowIndex, "taxCode", newVal);
                                        grid.repaint();
                                    } catch (syncErr) {
                                        console.warn("[Grid Sync] Không thể sync grid:", syncErr);
                                    }
                                }

                            } catch (err) {
                                console.warn("[taxCodeP7347CD0B4C364443AD716ADC3225C05C] Có lỗi:", err);
                            } finally {
                                setTimeout(function () {
                                    _savingtaxCodeP7347CD0B4C364443AD716ADC3225C05C = false;
                                }, 100);
                            }
                        }

                        /* =============== Create UI =============== */

                        taxCodeP7347CD0B4C364443AD716ADC3225C05CRealInstance = $("<div>")
                            .appendTo($containertaxCodeP7347CD0B4C364443AD716ADC3225C05C)
                            .dxTextBox({
                                value: "",
                                width: "100%",
                                placeholder: "",
                                readOnly: _readOnlytaxCodeP7347CD0B4C364443AD716ADC3225C05C,
                                stylingMode: "underlined",
                                inputAttr: {
style: "font-size: inherit; font-weight: inherit; border-bottom-color: #ddd;"
                       },
                                onValueChanged: function (e) {
                                    if (e.value && e.value.trim() !== "") {
                                        hideValidationErrortaxCodeP7347CD0B4C364443AD716ADC3225C05C();
  }
                                },
                                onFocusOut: function (e) {
                                    if (_readOnlytaxCodeP7347CD0B4C364443AD716ADC3225C05C) return;

                                    const $input = $containertaxCodeP7347CD0B4C364443AD716ADC3225C05C.find("input");
                                    const currentValue = $input.val();

                                    // Validate required
                                    if (0 === 1) {
                                        if (!currentValue || currentValue.trim() === "") {
                                            const errorMsg = window.ValidationEngine && window.ValidationEngine.getRequiredMessage
                                                ? window.ValidationEngine.getRequiredMessage("%DisplayName%")
                                                : "%DisplayName% là bắt buộc";

                                            showValidationErrortaxCodeP7347CD0B4C364443AD716ADC3225C05C(errorMsg);
                                            return;
                                        }
                                    }

                                    hideValidationErrortaxCodeP7347CD0B4C364443AD716ADC3225C05C();
                                    // 👉 chỉ save khi value thay đổi
                                    if (currentValue !== taxCodeP7347CD0B4C364443AD716ADC3225C05COriginalValue) {
                                        taxCodeP7347CD0B4C364443AD716ADC3225C05CRealInstance.option("value", currentValue);
                                        saveValuetaxCodeP7347CD0B4C364443AD716ADC3225C05C();
                                        taxCodeP7347CD0B4C364443AD716ADC3225C05COriginalValue = currentValue;
                                    }
                                },
                                onKeyDown: function (e) {
                                    if (e.event.key === "Enter") {
                                        e.event.preventDefault();

                                        const currentValue = $containertaxCodeP7347CD0B4C364443AD716ADC3225C05C.find("input").val();

                                        if (0 === 1) {
                                            if (!currentValue || currentValue.trim() === "") {
                                                const errorMsg = window.ValidationEngine && window.ValidationEngine.getRequiredMessage
                                                    ? window.ValidationEngine.getRequiredMessage("%DisplayName%")
                                                    : "%DisplayName% là bắt buộc";

                                                showValidationErrortaxCodeP7347CD0B4C364443AD716ADC3225C05C(errorMsg);
                                                return;
                                            }
                                        }

                                        hideValidationErrortaxCodeP7347CD0B4C364443AD716ADC3225C05C();
                                        taxCodeP7347CD0B4C364443AD716ADC3225C05CRealInstance.option("value", currentValue);
                                        saveValuetaxCodeP7347CD0B4C364443AD716ADC3225C05C();
                                    }

                                    if (e.event.key === "Tab") {
                                        e.event.preventDefault();
                                        const $input = $containertaxCodeP7347CD0B4C364443AD716ADC3225C05C.find("input");
         const currentValue = $input.val();
                                        taxCodeP7347CD0B4C364443AD716ADC3225C05CRealInstance.option("value", currentValue);
                      saveValuetaxCodeP7347CD0B4C364443AD716ADC3225C05C();
                                    }

                                    if (e.event.key === "Escape") {
                                        e.event.preventDefault();
                                      taxCodeP7347CD0B4C364443AD716ADC3225C05CRealInstance.option("value", taxCodeP7347CD0B4C364443AD716ADC3225C05COriginalValue);
                              hideValidationErrortaxCodeP7347CD0B4C364443AD716ADC3225C05C();
                                        $containertaxCodeP7347CD0B4C364443AD716ADC3225C05C.find("input").blur();
                                    }
                                }
                            })
                            .dxTextBox("instance");

                        /* =============== Public API =============== */
                        InstancetaxCodeP7347CD0B4C364443AD716ADC3225C05C = {
                            setValue: function (val) {
                                const displayVal = (val == null || val === "") ? "" : String(val);
                                taxCodeP7347CD0B4C364443AD716ADC3225C05COriginalValue = displayVal;
                                taxCodeP7347CD0B4C364443AD716ADC3225C05CRealInstance.option("value", displayVal);
                            },
                            getValue: function () {
                                return taxCodeP7347CD0B4C364443AD716ADC3225C05CRealInstance.option("value");
                            },
                            option: function (name, value) {
                                if (value !== undefined) {
                                    taxCodeP7347CD0B4C364443AD716ADC3225C05CRealInstance.option(name, value);

                                    if (name === "value") {
                                        const val = value || "";
                                        taxCodeP7347CD0B4C364443AD716ADC3225C05COriginalValue = val;

                                        if (
                                            this.__cellInfo &&
                                            typeof this.__cellInfo.setValue === "function" &&
                                            this.__cellInfo.component
                                        ) {
                                            try {
                                                this.__cellInfo.setValue(val);
                                            } catch (e) {
                                                console.warn("[hpaControlText] Grid sync skipped", e);
                                            }
                                        }
                                    }
                                } else {
                                    return taxCodeP7347CD0B4C364443AD716ADC3225C05CRealInstance.option(name);
                                }
                            },
                            repaint: function () {
                                taxCodeP7347CD0B4C364443AD716ADC3225C05CRealInstance.repaint();
                            },
                            clearValidationError: function () {
                                hideValidationErrortaxCodeP7347CD0B4C364443AD716ADC3225C05C();
                            },
                            _suppressValueChangeAction: function () {
                                if (taxCodeP7347CD0B4C364443AD716ADC3225C05CRealInstance._suppressValueChangeAction) {
                                    taxCodeP7347CD0B4C364443AD716ADC3225C05CRealInstance._suppressValueChangeAction();
                                }
                            },
                            _resumeValueChangeAction: function () {
                    if (taxCodeP7347CD0B4C364443AD716ADC3225C05CRealInstance._resumeValueChangeAction) {
                                    taxCodeP7347CD0B4C364443AD716ADC3225C05CRealInstance._resumeValueChangeAction();
                                }
                            }
                        };

                        // Set initial value
                        if (cellInfo.value !== undefined && cellInfo.value !== null && InstancetaxCodeP7347CD0B4C364443AD716ADC3225C05C) {
                            InstancetaxCodeP7347CD0B4C364443AD716ADC3225C05C.option("value", cellInfo.value);
            }
                    },
                },

                {
                    dataField: "industry",
                    caption: "%Branch%",
                    width: 150,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function (cellElement, cellInfo) {
                        const val = cellInfo.value;

                        if (val === undefined || val === null || val === "") {                        
                            return;
                        }

                        const ds = window["DataSource_industry"];
                        if (ds && Array.isArray(ds)) {
                            const f = ds.find(x => x.id == val || x.ID == val);
                            if (f) {
                                $("<div>").text(f.Text || f.Name || "").appendTo(cellElement);
                                return;
                            }
                        }

                        $("<div>").text(cellInfo.displayValue ?? val).appendTo(cellElement);
                    },
                    allowEditing: true,
                    editCellTemplate: function (cellElement, cellInfo) {
                        // Cập nhật record context ID cho row hiện tại
                        let rowID = null;
                        if (cellInfo.key !== undefined && cellInfo.key !== null) {
                            rowID = cellInfo.key;
                        } else if (cellInfo.data && cellInfo.data["ID"] !== undefined) {
                            rowID = cellInfo.data["ID"];
                        }

                        if (rowID !== null) {
                            currentRecordID_ID = rowID;
                        }

                        if ("" && "".trim() !== "" && cellInfo.data && cellInfo.data[""] !== undefined) {
                            currentRecordID_ = cellInfo.data[""];
                        }


                        window["DataSource_industry"] = window["DataSource_industry"] || [];

                        let industryP7347CD0B4C364443AD716ADC3225C05CDataSourceSP = "";
                        let industryP7347CD0B4C364443AD716ADC3225C05CIsLoading = false;
                        let industryP7347CD0B4C364443AD716ADC3225C05CIsDataLoaded = false;
                        let _autoSaveindustryP7347CD0B4C364443AD716ADC3225C05C = false;
                        let _readOnlyindustryP7347CD0B4C364443AD716ADC3225C05C = false;
                        let industryP7347CD0B4C364443AD716ADC3225C05CTableAddNew = "";
                        let industryP7347CD0B4C364443AD716ADC3225C05CColumnAddNew = "";
                        let industryP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = "";
                        let industryP7347CD0B4C364443AD716ADC3225C05CLastSearchValue = "";
                        let InstanceindustryP7347CD0B4C364443AD716ADC3225C05C = null;
                        const industryP7347CD0B4C364443AD716ADC3225C05CLastSearchClass = "hpa-last-search-P7347CD0B4C364443AD716ADC3225C05C";

                        function getDataSourceConfigindustryP7347CD0B4C364443AD716ADC3225C05C(data) {
                            const idField = window["DataSourceIDField_industry"] || "ID";
                            return new DevExpress.data.DataSource({
  paginate: false,
 store: new DevExpress.data.CustomStore({
                                    key: idField,
                                    load: function (loadOptions) {
                                        let searchValue = industryP7347CD0B4C364443AD716ADC3225C05CCurrentSearch || "";

         if (!searchValue && loadOptions && loadOptions.searchValue) {
                                            searchValue = loadOptions.searchValue;
                                        }

                                    if (!searchValue && InstanceindustryP7347CD0B4C364443AD716ADC3225C05C && InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option) {
                                            searchValue = InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("searchValue") || "";
                                        }

                                        let result = data || [];

                                        if (searchValue && searchValue.trim()) {
                                            result = result.filter(item => customSearchindustry(item, searchValue));

                                            if (industryP7347CD0B4C364443AD716ADC3225C05CTableAddNew && industryP7347CD0B4C364443AD716ADC3225C05CTableAddNew.trim() !== "") {
                                                const nameField = window["DataSourceNameField_industry"] || "Name";
                                                const addNewItem = { IsAddNew: true };
                                                addNewItem[nameField] = searchValue.trim();
                                                result.push(addNewItem);
                                            }
                                        }

                                        return Promise.resolve(result);
                                    },
                                    byKey: function (key) {
                                        const idField = window["DataSourceIDField_industry"] || "ID";
                                        return Promise.resolve((data || []).find(i => i[idField] === key));
                                    }
                                })
                            });
                        }

                        async function processAddNewindustry(newValue) {
                            if (!newValue || !newValue.trim()) return;

                            InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("disabled", true);

                            const dataJSON = JSON.stringify([industryP7347CD0B4C364443AD716ADC3225C05CTableAddNew, [industryP7347CD0B4C364443AD716ADC3225C05CColumnAddNew], [newValue.trim()]]);

                            try {
                                console.log("dataJSON", dataJSON);
                                const json = await saveFunction(dataJSON);
                                const dtError = json.data[json.data.length - 1] || [];

                                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                                    uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lỗi thêm mới" });
                                } else {
                                    const newItemID = dtError[0]?.IDValue || null;

                                    if (newItemID) {
                                        const idField = window["DataSourceIDField_industry"] || "ID";
                                        const nameField = window["DataSourceNameField_industry"] || "Name";

                                        const newItem = {};
                                        newItem[idField] = newItemID;
           newItem[nameField] = newValue.trim();

                                        if (!window["DataSource_industry"]) {
                                            window["DataSource_industry"] = [];
                       }
                                        window["DataSource_industry"].push(newItem);

                                        InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("dataSource", getDataSourceConfigindustryP7347CD0B4C364443AD716ADC3225C05C(window["DataSource_industry"]));

                             InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("value", newItemID);
                                        InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("searchValue", "");
                                        industryP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = "";
                                    }
                                }
                            } catch (e) {
                                console.error(e);
                                uiManager.showAlert({ type: "error", message: "Có lỗi khi thêm mới" });
                            } finally {
                                InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("disabled", false);
                                InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.close();
                            }
                        }

                        function customSearchindustry(item, searchValue) {
                            if (!searchValue) return true;
                            const searchNormalized = hpaUtils.removeToneMarks(searchValue).toLowerCase();
                            const idField = window["DataSourceIDField_industry"] || "ID";
                            const nameField = window["DataSourceNameField_industry"] || "Name";
                            const fields = [idField, nameField, "Code", "Description"];

                            for (let i = 0; i < fields.length; i++) {
                                const fieldValue = item[fields[i]];
                                if (fieldValue) {
                                    const fieldNormalized = hpaUtils.removeToneMarks(String(fieldValue)).toLowerCase();
                                    if (fieldNormalized.indexOf(searchNormalized) !== -1) return true;
                                }
                            }
                            return false;
                        }

                        function renderLastSearchHintindustryP7347CD0B4C364443AD716ADC3225C05C($popupContent) {
                            if (!$popupContent || !$popupContent.length) return;

                            const lastSearch = (industryP7347CD0B4C364443AD716ADC3225C05CLastSearchValue || "").trim();
                            let $hint = $popupContent.find("." + industryP7347CD0B4C364443AD716ADC3225C05CLastSearchClass);

                            if (!lastSearch) {
                                if ($hint.length) {
                                    $hint.remove();
                                }
                                return;
                            }

                            if (!$hint.length) {
                                $hint = $("<div>")
                                    .addClass(industryP7347CD0B4C364443AD716ADC3225C05CLastSearchClass + " d-flex align-items-center justify-content-between gap-2 px-3 py-2 border-bottom")
                                    .css({
                                        fontSize: "12px",
                                        background: "#f8f9fa"
                                    })
                                    .prependTo($popupContent);

                                $("<span>")
                                    .addClass("flex-fill text-muted text-truncate")
                                    .appendTo($hint);


                                $("<button>")
                                    .attr("type", "button")
                                    .addClass("btn btn-link p-0 text-decoration-none fw-semibold")
   .text("Áp dụng lại")
                                    .on("dxclick", function (ev) {
                                        ev.preventDefault();
                                        ev.stopPropagation();
                                        if (!industryP7347CD0B4C364443AD716ADC3225C05CLastSearchValue) return;
                   industryP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = industryP7347CD0B4C364443AD716ADC3225C05CLastSearchValue;
                                        InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("searchValue", industryP7347CD0B4C364443AD716ADC3225C05CLastSearchValue);
                                        const $input = $(cellElement).find(".dx-texteditor-input");
                                        if ($input && $input.length) {
                                            setTimeout(function () { $input.focus(); }, 0);
                                        }
                                    })
                                    .appendTo($hint);
                            }

                            $hint.find("span").text("Lần tìm trước: \"" + lastSearch + "\"");
                        }

                        InstanceindustryP7347CD0B4C364443AD716ADC3225C05C = $(cellElement).dxSelectBox({
                            readOnly: _readOnlyindustryP7347CD0B4C364443AD716ADC3225C05C,
                            dataSource: getDataSourceConfigindustryP7347CD0B4C364443AD716ADC3225C05C(window["DataSource_industry"]),
                            valueExpr: window["DataSourceIDField_industry"] || "ID",
                            displayExpr: window["DataSourceNameField_industry"] || "Name",
                            onOptionChanged: function (e) {
                                if (!e || !e.component) return;
                                if (e.name === "searchValue") {
                                    const newVal = (e.value || "").toString();
                                    industryP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = newVal;
                                    if (newVal && newVal.trim()) {
                                        industryP7347CD0B4C364443AD716ADC3225C05CLastSearchValue = newVal;
                                    }

                                    if (e.component.option("opened") && e.component._popup) {
                                        renderLastSearchHintindustryP7347CD0B4C364443AD716ADC3225C05C($(e.component._popup.content()));
                                    }
                                }
                            },
                            onContentReady: function (e) { },
                            placeholder: "Tìm kiếm hoặc chọn...",
                            searchEnabled: true,
                            searchTimeout: 300,
                            minSearchLength: 0,
                            showDataBeforeSearch: true,
                            showClearButton: false,
                            stylingMode: "outlined",
                            dropDownOptions: {
                                showTitle: false,
                                closeOnOutsideClick: true,
                                height: "auto",
                                maxHeight: 400,
                                minWidth: 320,
                                onShowing: function (e) {
                                    if (InstanceindustryP7347CD0B4C364443AD716ADC3225C05C && InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option) {
                                        const pendingSearch = InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("searchValue") || "";
                                        if (pendingSearch && pendingSearch.trim()) {
                                            industryP7347CD0B4C364443AD716ADC3225C05CLastSearchValue = pendingSearch;
                  }
                        industryP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = "";
                                        InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("searchValue", "");
                                    }
                                },
                                onHidden: function () {
     industryP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = "";
                                    if (InstanceindustryP7347CD0B4C364443AD716ADC3225C05C && InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option) {
                                        InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("searchValue", "");
                                    }
                                }
                            },
                            itemTemplate: function (data, index) {
                                if (data.IsAddNew) {
                                    const nameField = window["DataSourceNameField_industry"] || "Name";
                                    const $item = $("<div>")
                                        .addClass("d-flex align-items-center gap-2 px-3 py-2 text-primary")
                                        .css({ cursor: "pointer", borderTop: "1px dashed #dee2e6", fontWeight: "600" });

                                    $("<i>").addClass("bi bi-plus-circle fs-6").appendTo($item);
                                    $("<span>").text("Thêm mới: \"" + data[nameField] + "\"").appendTo($item);

                                    $item.on("dxclick", async function (e) {
                                        e.stopPropagation();
                                        if (InstanceindustryP7347CD0B4C364443AD716ADC3225C05C && InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.blur) InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.blur();
                                        await processAddNewindustry(data[nameField]);
                                    });

                                    return $item;
                                }

                                const idField = window["DataSourceIDField_industry"] || "ID";
                                const nameField = window["DataSourceNameField_industry"] || "Name";
                                const searchValue = InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("searchValue") || "";

                                const $item = $("<div>")
                                    .addClass("d-flex align-items-center gap-2 px-3 py-2 border-bottom border-light")
                                    .css({ cursor: "pointer" });

                                const $content = $("<div>").addClass("flex-fill").css("minWidth", "0");

                                const displayName = (data[idField] !== undefined ? data[idField] + " - " : "") + (data[nameField] || "");
                                $("<div>")
                                    .addClass("fw-normal ")
                                    .css({
                                        fontSize: "13px",
                                        overflow: "hidden",
                                        textOverflow: "ellipsis",
                                        whiteSpace: "nowrap"
                                    })
                                    .html(hpaUtils.highlightText(displayName, searchValue))
                                    .appendTo($content);

                                if (data.Description || data.Code) {
                                    $("<div>")
                                        .addClass("text-muted")
               .css({
                                            fontSize: "11px",
                                            overflow: "hidden",
                                            textOverflow: "ellipsis",
              whiteSpace: "nowrap"
         })
                                        .text(data.Code || data.Description)
                                        .appendTo($content);
                                }

                                $content.appendTo($item);

                                if (data.Status) {
                                    const badgeClass = data.Status === "Active" ? "bg-success" : "bg-secondary";
                                    $("<span>")
                                        .addClass("badge " + badgeClass)
                                        .css({
                                            fontSize: "9px",
                            padding: "3px 6px",
                                            borderRadius: "4px",
                                            opacity: "0.8"
                                        })
                                        .text(data.Status)
                                        .appendTo($item);
                                }

                                return $item;
                            },
                            onOpened: function (e) {
                                const $popupContent = $(e.component._popup.content());
                                $popupContent.parent()
                                    .addClass("shadow-lg border rounded")
                                    .css({
                                        borderRadius: "8px",
                                        padding: "4px 0",
                                        borderColor: "#dee2e6"
                                    });

                                renderLastSearchHintindustryP7347CD0B4C364443AD716ADC3225C05C($popupContent);
                            },
                            onFocusIn: function (e) {
                                InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("showClearButton", true);
                            },
                            onFocusOut: function (e) {
                                InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("showClearButton", false);
                            },
                            onKeyDown: function (e) {
                                if (e.key === "Enter" || e.key === "Tab") {
                                    InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("showClearButton", false);
                                }
                            },
                            onValueChanged: async function (e) {
                                if (!e.event) return;

                                if (_autoSaveindustryP7347CD0B4C364443AD716ADC3225C05C) {
                                    if (e.value === "" || e.value == null || e.value === 0 || e.value === "0") {
                                        InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("value", _initialindustryP7347CD0B4C364443AD716ADC3225C05C);
                                        return;
                                    }

                                    $(cellElement).find(".dx-texteditor-input").blur();
                                    if (InstanceindustryP7347CD0B4C364443AD716ADC3225C05C && InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.blur) InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.blur();

                                    if (typeof window["onSelectBoxChanged_industry"] === "function") {
                                        window["onSelectBoxChanged_industry"](e.value, InstanceindustryP7347CD0B4C364443AD716ADC3225C05C, e);
              }

                                    const val = e.value;
                                    const dataJSON = JSON.stringify(["-1617191338", ["industry"], [val || ""]]);

                                    let id1 = currentRecordID_ID;
                      if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                                        id1 = cellInfo.data["ID"] || id1;
                                    }
                                    let currentRecordIDValue = [id1];
                                    let currentRecordID = ["ID"];

                                    if ("" && "".trim() !== "") {
                                        let id2 = currentRecordID_;
                                        if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                                            id2 = cellInfo.data[""] || id2;
                                        }
   currentRecordIDValue.push(id2);
                                        currentRecordID.push("");
                                    }
                                    const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);

                                    try {
                                        const json = await saveFunction(dataJSON, idValsJSON);
                                        const dtError = json.data[json.data.length - 1] || [];
                                        if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                                            uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                                            InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("value", _initialindustryP7347CD0B4C364443AD716ADC3225C05C);
                                        } else {
                                            if (0 != 0 && 0 != null && 0 != "" && window.hpaSharedGridDataSources["0"]) {
                                                try {

                                                    let KeyRowTable = window.currentClicked_0;
                                                    console.log("KeyRowTable:", KeyRowTable);
                                                    if (KeyRowTable != null && KeyRowTable != undefined) {
                                                        var updateData = {};
                                                        updateData["0"] = KeyRowTable;
                                                        updateData["industry"] = InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("value");

                                                        // 2. Thực hiện update Shared Grid
                                                        // Vì dùng RowID, Grid sẽ tự tìm dòng cực nhanh
                                                        window.updateSharedGridRow("0", updateData);

                                                        // 3. Cập nhật biến DataSource cục bộ (Dùng RowID để tìm)
                                                        if (typeof DataSource !== "undefined" && Array.isArray(DataSource)) {
                                                            // Chỉ cần 1 dòng filter duy nhất, không cần check hasKey2 rườm rà nữa
                                                            var ds = DataSource.filter(item => item.RowID === KeyRowTable);

                                                            if (ds && ds.length > 0) {
                                                                ds[0]["industry"] = updateData["industry"];

                                                                // Nếu bạn đang sửa chính là 1 trong các ID cấu thành RowID
                                                                // Cần cập nhật lại RowID mới nếu cần thiết (tùy logic nghiệp vụ)
                                                            }
                                                        }
                                                    }

                                                    var updateData = {};
                                           updateData["ID"] = currentRecordIDValue[0];
                                                  updateData["industry"] = InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("value");

                                                    var id2FieldName = "";
                                                    var hasKey2 = id2FieldName && id2FieldName !== "" && id2FieldName.indexOf("%") === -1;

               if (hasKey2) {
                                                        if (currentRecordIDValue.length > 1 && currentRecordIDValue[1] !== undefined) {
                                                            updateData[id2FieldName] = currentRecordIDValue[1];
                                }
                                                    }

                                                    window.updateSharedGridRow("0", updateData);

                                                    if (typeof DataSource !== "undefined" && Array.isArray(DataSource)) {
                                                        var ds;
                                                        if (!hasKey2) {
                                                            ds = DataSource.filter(item => item["ID"] === updateData["ID"]);
                                                        } else {
                                                            ds = DataSource.filter(item =>
                                                                item["ID"] === updateData["ID"] &&
                                                                item[id2FieldName] === updateData[id2FieldName]
                                                            );
                                                        }

                                                        if (ds && ds.length > 0) {
                                                            ds[0]["industry"] = updateData["industry"];
                                                        }
                                                    }
                                                } catch (dsErr) {
                                                    console.warn("[Grid Sync] SelectBox industryP7347CD0B4C364443AD716ADC3225C05C: Không thể sync shared grid data source:", dsErr);
                                                }
                                            }

                                            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                                try {
                                                    const grid = cellInfo.component;
                                                    grid.cellValue(cellInfo.rowIndex, "industry", val);
                                                    grid.repaint();
                                                } catch (syncErr) {
                                                    console.warn("[Grid Sync] SelectBox industryP7347CD0B4C364443AD716ADC3225C05C: Không thể sync grid:", syncErr);
                                                }
                                            }
                                            _initialindustryP7347CD0B4C364443AD716ADC3225C05C = val;
                                        }
                                    } catch (err) {
                                        uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                                        InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("value", _initialindustryP7347CD0B4C364443AD716ADC3225C05C);
                                        console.error("SelectBox Save Error:", err);
                                    }
                                    return;
                                }

                                // Manual mode - no save, just callbacks and grid sync
                                if (typeof window["onSelectBoxChanged_industry"] === "function") {
                                    window["onSelectBoxChanged_industry"](e.value, InstanceindustryP7347CD0B4C364443AD716ADC3225C05C, e);
                                }

                                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                    try {
                             const grid = cellInfo.component;
                                        grid.cellValue(cellInfo.rowIndex, "industry", e.value);
                                        grid.repaint();
                                    } catch (syncErr) {
                                        console.warn("[Grid Sync] Không thể sync grid:", syncErr);
                                    }
                                }
                            }
                        }).dxSelectBox("instance");

                        let _initialindustryP7347CD0B4C364443AD716ADC3225C05C = InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("value");

                        if (industryP7347CD0B4C364443AD716ADC3225C05CDataSourceSP && industryP7347CD0B4C364443AD716ADC3225C05CDataSourceSP !== "") {
                            loadDataSourceCommon("industry", industryP7347CD0B4C364443AD716ADC3225C05CDataSourceSP, function (data) {
                                industryP7347CD0B4C364443AD716ADC3225C05CIsDataLoaded = true;

                                const idField = window["DataSourceIDField_industry"] || "ID";
                                const nameField = window["DataSourceNameField_industry"] || "Name";

                                InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("valueExpr", idField);
                                InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("displayExpr", nameField);

                                InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("dataSource", getDataSourceConfigindustryP7347CD0B4C364443AD716ADC3225C05C(data));
                                InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.repaint();
                            });
                        }

                        // Set initial value
                        if (cellInfo.value !== undefined && cellInfo.value !== null && InstanceindustryP7347CD0B4C364443AD716ADC3225C05C) {
                            InstanceindustryP7347CD0B4C364443AD716ADC3225C05C.option("value", cellInfo.value);
                        }
                    },
                },

                {
                    dataField: "companySize",
                    caption: "%Company_size%",
                    width: 150,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function (cellElement, cellInfo) {
                        const val = cellInfo.value;

                        if (val === undefined || val === null || val === "") {
                            
                            return;
                        }

                        const ds = window["DataSource_companySize"];
                        if (ds && Array.isArray(ds)) {
                            const f = ds.find(x => x.id == val || x.ID == val);
                            if (f) {
                                $("<div>").text(f.Text || f.Name || "").appendTo(cellElement);
                                return;
                            }
 }

                        $("<div>").text(cellInfo.displayValue ?? val).appendTo(cellElement);
                    },
                    allowEditing: true,
                    editCellTemplate: function (cellElement, cellInfo) {
                        // Cập nhật record context ID cho row hiện tại
                        let rowID = null;
                        if (cellInfo.key !== undefined && cellInfo.key !== null) {
                            rowID = cellInfo.key;
                        } else if (cellInfo.data && cellInfo.data["ID"] !== undefined) {
                            rowID = cellInfo.data["ID"];
                        }

                        if (rowID !== null) {
                            currentRecordID_ID = rowID;
       }

                        if ("" && "".trim() !== "" && cellInfo.data && cellInfo.data[""] !== undefined) {
                            currentRecordID_ = cellInfo.data[""];
                        }


                        window["DataSource_companySize"] = window["DataSource_companySize"] || [];

          let companySizeP7347CD0B4C364443AD716ADC3225C05CDataSourceSP = "";
                        let companySizeP7347CD0B4C364443AD716ADC3225C05CIsLoading = false;
                        let companySizeP7347CD0B4C364443AD716ADC3225C05CIsDataLoaded = false;
                        let _autoSavecompanySizeP7347CD0B4C364443AD716ADC3225C05C = false;
                        let _readOnlycompanySizeP7347CD0B4C364443AD716ADC3225C05C = false;
                        let companySizeP7347CD0B4C364443AD716ADC3225C05CTableAddNew = "";
                        let companySizeP7347CD0B4C364443AD716ADC3225C05CColumnAddNew = "";
                        let companySizeP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = "";
                        let companySizeP7347CD0B4C364443AD716ADC3225C05CLastSearchValue = "";
                        let InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C = null;
                        const companySizeP7347CD0B4C364443AD716ADC3225C05CLastSearchClass = "hpa-last-search-P7347CD0B4C364443AD716ADC3225C05C";

                        function getDataSourceConfigcompanySizeP7347CD0B4C364443AD716ADC3225C05C(data) {
                            const idField = window["DataSourceIDField_companySize"] || "ID";
                            return new DevExpress.data.DataSource({
                                paginate: false,
                                store: new DevExpress.data.CustomStore({
                                    key: idField,
                                    load: function (loadOptions) {
                                        let searchValue = companySizeP7347CD0B4C364443AD716ADC3225C05CCurrentSearch || "";

                                        if (!searchValue && loadOptions && loadOptions.searchValue) {
                                            searchValue = loadOptions.searchValue;
                                        }

                                        if (!searchValue && InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C && InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option) {
                                            searchValue = InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("searchValue") || "";
                                        }

                                        let result = data || [];

                                        if (searchValue && searchValue.trim()) {
                                            result = result.filter(item => customSearchcompanySize(item, searchValue));

                                            if (companySizeP7347CD0B4C364443AD716ADC3225C05CTableAddNew && companySizeP7347CD0B4C364443AD716ADC3225C05CTableAddNew.trim() !== "") {
                                                const nameField = window["DataSourceNameField_companySize"] || "Name";
                                    const addNewItem = { IsAddNew: true };
                                                addNewItem[nameField] = searchValue.trim();
                                                result.push(addNewItem);
                                            }
                     }

                                        return Promise.resolve(result);
                          },
                                    byKey: function (key) {
                                        const idField = window["DataSourceIDField_companySize"] || "ID";
                                        return Promise.resolve((data || []).find(i => i[idField] === key));
                                    }
                                })
                            });
                        }

                        async function processAddNewcompanySize(newValue) {
                            if (!newValue || !newValue.trim()) return;

                            InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("disabled", true);

                            const dataJSON = JSON.stringify([companySizeP7347CD0B4C364443AD716ADC3225C05CTableAddNew, [companySizeP7347CD0B4C364443AD716ADC3225C05CColumnAddNew], [newValue.trim()]]);

                            try {
                                console.log("dataJSON", dataJSON);
                                const json = await saveFunction(dataJSON);
                                const dtError = json.data[json.data.length - 1] || [];

                                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                                    uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lỗi thêm mới" });
                                } else {
                                    const newItemID = dtError[0]?.IDValue || null;

                                    if (newItemID) {
                                        const idField = window["DataSourceIDField_companySize"] || "ID";
                                        const nameField = window["DataSourceNameField_companySize"] || "Name";

                                        const newItem = {};
                                        newItem[idField] = newItemID;
                                        newItem[nameField] = newValue.trim();

                                        if (!window["DataSource_companySize"]) {
                                            window["DataSource_companySize"] = [];
                                        }
                                        window["DataSource_companySize"].push(newItem);

                                        InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("dataSource", getDataSourceConfigcompanySizeP7347CD0B4C364443AD716ADC3225C05C(window["DataSource_companySize"]));

                                        InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("value", newItemID);
                                        InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("searchValue", "");
                                        companySizeP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = "";
                                    }
                                }
                            } catch (e) {
                                console.error(e);
                                uiManager.showAlert({ type: "error", message: "Có lỗi khi thêm mới" });
                            } finally {
                                InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("disabled", false);
                                InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.close();
                            }
                        }

                        function customSearchcompanySize(item, searchValue) {
                            if (!searchValue) return true;
                            const searchNormalized = hpaUtils.removeToneMarks(searchValue).toLowerCase();
                            const idField = window["DataSourceIDField_companySize"] || "ID";
                            const nameField = window["DataSourceNameField_companySize"] || "Name";
                            const fields = [idField, nameField, "Code", "Description"];

             for (let i = 0; i < fields.length; i++) {
                                const fieldValue = item[fields[i]];
                                if (fieldValue) {
                                    const fieldNormalized = hpaUtils.removeToneMarks(String(fieldValue)).toLowerCase();
                                    if (fieldNormalized.indexOf(searchNormalized) !== -1) return true;
        }
                            }
                            return false;
                        }

                        function renderLastSearchHintcompanySizeP7347CD0B4C364443AD716ADC3225C05C($popupContent) {
                            if (!$popupContent || !$popupContent.length) return;

                            const lastSearch = (companySizeP7347CD0B4C364443AD716ADC3225C05CLastSearchValue || "").trim();
                            let $hint = $popupContent.find("." + companySizeP7347CD0B4C364443AD716ADC3225C05CLastSearchClass);

                            if (!lastSearch) {
                                if ($hint.length) {
                                    $hint.remove();
                                }
                                return;
                            }

                            if (!$hint.length) {
                                $hint = $("<div>")
                                    .addClass(companySizeP7347CD0B4C364443AD716ADC3225C05CLastSearchClass + " d-flex align-items-center justify-content-between gap-2 px-3 py-2 border-bottom")
                                    .css({
                                        fontSize: "12px",
                                        background: "#f8f9fa"
                                    })
                                    .prependTo($popupContent);

                                $("<span>")
                                    .addClass("flex-fill text-muted text-truncate")
                                    .appendTo($hint);

                                $("<button>")
                                    .attr("type", "button")
                                    .addClass("btn btn-link p-0 text-decoration-none fw-semibold")
                                    .text("Áp dụng lại")
                                    .on("dxclick", function (ev) {
                                        ev.preventDefault();
                                        ev.stopPropagation();
                                        if (!companySizeP7347CD0B4C364443AD716ADC3225C05CLastSearchValue) return;
                                        companySizeP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = companySizeP7347CD0B4C364443AD716ADC3225C05CLastSearchValue;
                                        InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("searchValue", companySizeP7347CD0B4C364443AD716ADC3225C05CLastSearchValue);
                                        const $input = $(cellElement).find(".dx-texteditor-input");
                                        if ($input && $input.length) {
                                            setTimeout(function () { $input.focus(); }, 0);
                                        }
                                    })
                                    .appendTo($hint);
                            }

                            $hint.find("span").text("Lần tìm trước: \"" + lastSearch + "\"");
                        }

                        InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C = $(cellElement).dxSelectBox({
                            readOnly: _readOnlycompanySizeP7347CD0B4C364443AD716ADC3225C05C,
                            dataSource: getDataSourceConfigcompanySizeP7347CD0B4C364443AD716ADC3225C05C(window["DataSource_companySize"]),
                            valueExpr: window["DataSourceIDField_companySize"] || "ID",
                            displayExpr: window["DataSourceNameField_companySize"] || "Name",
                            onOptionChanged: function (e) {
                                if (!e || !e.component) return;
                                if (e.name === "searchValue") {
                                    const newVal = (e.value || "").toString();
                                    companySizeP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = newVal;
                                    if (newVal && newVal.trim()) {
                                        companySizeP7347CD0B4C364443AD716ADC3225C05CLastSearchValue = newVal;
                                    }

                                    if (e.component.option("opened") && e.component._popup) {
                                        renderLastSearchHintcompanySizeP7347CD0B4C364443AD716ADC3225C05C($(e.component._popup.content()));
                                    }
                                }
                            },
                            onContentReady: function (e) { },
                            placeholder: "Tìm kiếm hoặc chọn...",
                            searchEnabled: true,
                            searchTimeout: 300,
                            minSearchLength: 0,
                            showDataBeforeSearch: true,
                            showClearButton: false,
                            stylingMode: "outlined",
                            dropDownOptions: {
                                showTitle: false,
                                closeOnOutsideClick: true,
                                height: "auto",
                                maxHeight: 400,
                                minWidth: 320,
                                onShowing: function (e) {
                                    if (InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C && InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option) {
                                        const pendingSearch = InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("searchValue") || "";
                                        if (pendingSearch && pendingSearch.trim()) {
                                            companySizeP7347CD0B4C364443AD716ADC3225C05CLastSearchValue = pendingSearch;
                                        }
                                        companySizeP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = "";
                                        InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("searchValue", "");
                                    }
                                },
                                onHidden: function () {
                                    companySizeP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = "";
                                    if (InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C && InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option) {
                                        InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("searchValue", "");
                                    }
                                }
                            },
                            itemTemplate: function (data, index) {
                                if (data.IsAddNew) {
                                    const nameField = window["DataSourceNameField_companySize"] || "Name";
                                    const $item = $("<div>")
                                        .addClass("d-flex align-items-center gap-2 px-3 py-2 text-primary")
                .css({ cursor: "pointer", borderTop: "1px dashed #dee2e6", fontWeight: "600" });

                                    $("<i>").addClass("bi bi-plus-circle fs-6").appendTo($item);
                                    $("<span>").text("Thêm mới: \"" + data[nameField] + "\"").appendTo($item);

               $item.on("dxclick", async function (e) {
                                        e.stopPropagation();
                             if (InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C && InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.blur) InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.blur();
                                        await processAddNewcompanySize(data[nameField]);
                                    });

                                    return $item;
                                }

                           const idField = window["DataSourceIDField_companySize"] || "ID";
                                const nameField = window["DataSourceNameField_companySize"] || "Name";
                                const searchValue = InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("searchValue") || "";

    const $item = $("<div>")
                                    .addClass("d-flex align-items-center gap-2 px-3 py-2 border-bottom border-light")
                                    .css({ cursor: "pointer" });

                                const $content = $("<div>").addClass("flex-fill").css("minWidth", "0");

                                const displayName = (data[idField] !== undefined ? data[idField] + " - " : "") + (data[nameField] || "");
                                $("<div>")
                                    .addClass("fw-normal ")
                                    .css({
                                        fontSize: "13px",
                                        overflow: "hidden",
                                        textOverflow: "ellipsis",
                                        whiteSpace: "nowrap"
                                    })
                                    .html(hpaUtils.highlightText(displayName, searchValue))
                                    .appendTo($content);

                                if (data.Description || data.Code) {
                                    $("<div>")
                                        .addClass("text-muted")
                                        .css({
                                            fontSize: "11px",
                                            overflow: "hidden",
                                            textOverflow: "ellipsis",
                                            whiteSpace: "nowrap"
                                        })
                                        .text(data.Code || data.Description)
                                        .appendTo($content);
                                }

                                $content.appendTo($item);

                                if (data.Status) {
                                    const badgeClass = data.Status === "Active" ? "bg-success" : "bg-secondary";
                                    $("<span>")
                                        .addClass("badge " + badgeClass)
                                        .css({
                                            fontSize: "9px",
                                            padding: "3px 6px",
                                            borderRadius: "4px",
                                            opacity: "0.8"
                                        })
                                        .text(data.Status)
                                        .appendTo($item);
                                }

                                return $item;
                            },
                            onOpened: function (e) {
                                const $popupContent = $(e.component._popup.content());
                                $popupContent.parent()
                                    .addClass("shadow-lg border rounded")
                                    .css({
                                        borderRadius: "8px",
                                        padding: "4px 0",
                                        borderColor: "#dee2e6"

                                    });

                                renderLastSearchHintcompanySizeP7347CD0B4C364443AD716ADC3225C05C($popupContent);
                            },
                            onFocusIn: function (e) {
                                InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("showClearButton", true);
                            },
                            onFocusOut: function (e) {
                                InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("showClearButton", false);
                            },
                            onKeyDown: function (e) {
                                if (e.key === "Enter" || e.key === "Tab") {
                                    InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("showClearButton", false);
                                }
                            },
                            onValueChanged: async function (e) {
                                if (!e.event) return;

                                if (_autoSavecompanySizeP7347CD0B4C364443AD716ADC3225C05C) {
                                    if (e.value === "" || e.value == null || e.value === 0 || e.value === "0") {
                                        InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("value", _initialcompanySizeP7347CD0B4C364443AD716ADC3225C05C);
                                        return;
                                    }

                                    $(cellElement).find(".dx-texteditor-input").blur();
                                    if (InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C && InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.blur) InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.blur();

                                    if (typeof window["onSelectBoxChanged_companySize"] === "function") {
                                        window["onSelectBoxChanged_companySize"](e.value, InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C, e);
                                    }

                                    const val = e.value;
                                    const dataJSON = JSON.stringify(["-1617191338", ["companySize"], [val || ""]]);

                                    let id1 = currentRecordID_ID;
                                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                                        id1 = cellInfo.data["ID"] || id1;
                                    }
                                    let currentRecordIDValue = [id1];
                                    let currentRecordID = ["ID"];

                                    if ("" && "".trim() !== "") {
                                        let id2 = currentRecordID_;
                                        if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                                            id2 = cellInfo.data[""] || id2;
                                        }
                                        currentRecordIDValue.push(id2);
                                        currentRecordID.push("");
                                    }
                                    const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);

                                    try {
                                        const json = await saveFunction(dataJSON, idValsJSON);
                      const dtError = json.data[json.data.length - 1] || [];
                                        if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                                            uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
    InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("value", _initialcompanySizeP7347CD0B4C364443AD716ADC3225C05C);
                                        } else {
                                            if (0 != 0 && 0 != null && 0 != "" && window.hpaSharedGridDataSources["0"]) {
                                                try {

                                                    let KeyRowTable = window.currentClicked_0;
                                                    console.log("KeyRowTable:", KeyRowTable);
                                                    if (KeyRowTable != null && KeyRowTable != undefined) {
                                                        var updateData = {};
                                                        updateData["0"] = KeyRowTable;
                                                        updateData["companySize"] = InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("value");

                                                        // 2. Thực hiện update Shared Grid
                                                        // Vì dùng RowID, Grid sẽ tự tìm dòng cực nhanh
                                                        window.updateSharedGridRow("0", updateData);

                                                        // 3. Cập nhật biến DataSource cục bộ (Dùng RowID để tìm)
                                                        if (typeof DataSource !== "undefined" && Array.isArray(DataSource)) {
                                                            // Chỉ cần 1 dòng filter duy nhất, không cần check hasKey2 rườm rà nữa
                                                            var ds = DataSource.filter(item => item.RowID === KeyRowTable);

                                                            if (ds && ds.length > 0) {
                                                                ds[0]["companySize"] = updateData["companySize"];

                                                                // Nếu bạn đang sửa chính là 1 trong các ID cấu thành RowID
                                                                // Cần cập nhật lại RowID mới nếu cần thiết (tùy logic nghiệp vụ)
                                                            }
                                                        }
                                                    }

                                                    var updateData = {};
                                                    updateData["ID"] = currentRecordIDValue[0];
                                                    updateData["companySize"] = InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("value");

                                                    var id2FieldName = "";
                                                    var hasKey2 = id2FieldName && id2FieldName !== "" && id2FieldName.indexOf("%") === -1;

                                                    if (hasKey2) {
                                                        if (currentRecordIDValue.length > 1 && currentRecordIDValue[1] !== undefined) {
                                                            updateData[id2FieldName] = currentRecordIDValue[1];
                                                        }
                                                    }

                                                    window.updateSharedGridRow("0", updateData);

                                                    if (typeof DataSource !== "undefined" && Array.isArray(DataSource)) {
                             var ds;
                                                        if (!hasKey2) {
                                                            ds = DataSource.filter(item => item["ID"] === updateData["ID"]);
                                                        } else {
                                                            ds = DataSource.filter(item =>
                                                                item["ID"] === updateData["ID"] &&
           item[id2FieldName] === updateData[id2FieldName]
                                                            );
                                                        }

                                                        if (ds && ds.length > 0) {
                                                            ds[0]["companySize"] = updateData["companySize"];
                                                        }
    }
                                                } catch (dsErr) {
                                                    console.warn("[Grid Sync] SelectBox companySizeP7347CD0B4C364443AD716ADC3225C05C: Không thể sync shared grid data source:", dsErr);
                                                }
                                            }

                                            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                                try {
                                                    const grid = cellInfo.component;
                                                    grid.cellValue(cellInfo.rowIndex, "companySize", val);
                                                    grid.repaint();
                                                } catch (syncErr) {
                                                    console.warn("[Grid Sync] SelectBox companySizeP7347CD0B4C364443AD716ADC3225C05C: Không thể sync grid:", syncErr);
                                                }
                                            }
                                            _initialcompanySizeP7347CD0B4C364443AD716ADC3225C05C = val;
                                        }
                                    } catch (err) {
                                        uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                                        InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("value", _initialcompanySizeP7347CD0B4C364443AD716ADC3225C05C);
                                        console.error("SelectBox Save Error:", err);
                                    }
                                    return;
                                }

                                // Manual mode - no save, just callbacks and grid sync
                                if (typeof window["onSelectBoxChanged_companySize"] === "function") {
                                    window["onSelectBoxChanged_companySize"](e.value, InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C, e);
                                }

                                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                    try {
                                        const grid = cellInfo.component;
                                        grid.cellValue(cellInfo.rowIndex, "companySize", e.value);
                                        grid.repaint();
                                    } catch (syncErr) {
                                        console.warn("[Grid Sync] Không thể sync grid:", syncErr);
                                    }
                                }
                            }
                        }).dxSelectBox("instance");

                        let _initialcompanySizeP7347CD0B4C364443AD716ADC3225C05C = InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("value");

                        if (companySizeP7347CD0B4C364443AD716ADC3225C05CDataSourceSP && companySizeP7347CD0B4C364443AD716ADC3225C05CDataSourceSP !== "") {
                            loadDataSourceCommon("companySize", companySizeP7347CD0B4C364443AD716ADC3225C05CDataSourceSP, function (data) {
                              companySizeP7347CD0B4C364443AD716ADC3225C05CIsDataLoaded = true;

                                const idField = window["DataSourceIDField_companySize"] || "ID";
                                const nameField = window["DataSourceNameField_companySize"] || "Name";

                                InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("valueExpr", idField);
                                InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("displayExpr", nameField);

                                InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("dataSource", getDataSourceConfigcompanySizeP7347CD0B4C364443AD716ADC3225C05C(data));
                                InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.repaint();
                            });
                        }

                        // Set initial value
                        if (cellInfo.value !== undefined && cellInfo.value !== null && InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C) {
                           InstancecompanySizeP7347CD0B4C364443AD716ADC3225C05C.option("value", cellInfo.value);
                        }
                    },
                },

                {
                    dataField: "address",
                    caption: "%Address%",
                    width: 150,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function (cellElement, cellInfo) {
                        const val = cellInfo.value;

                        if (val === undefined || val === null || val === "") {
                            
                            return;
                        }

                        const ds = window["DataSource_address"];
                        if (ds && Array.isArray(ds)) {
                            const f = ds.find(x => x.id == val || x.ID == val);
                            if (f) {
                                $("<div>").text(f.Text || f.Name || "").appendTo(cellElement);
                                return;
                            }
                        }

                        $("<div>").text(cellInfo.displayValue ?? val).appendTo(cellElement);
                    },
                    allowEditing: true,
                    editCellTemplate: function (cellElement, cellInfo) {
                        // Cập nhật record context ID cho row hiện tại
                        let rowID = null;
                        if (cellInfo.key !== undefined && cellInfo.key !== null) {
                            rowID = cellInfo.key;
                        } else if (cellInfo.data && cellInfo.data["ID"] !== undefined) {
                            rowID = cellInfo.data["ID"];
                        }

                        if (rowID !== null) {
                            currentRecordID_ID = rowID;
                        }

                        if ("" && "".trim() !== "" && cellInfo.data && cellInfo.data[""] !== undefined) {
                            currentRecordID_ = cellInfo.data[""];
                        }


                        // Set initial value
                        if (cellInfo.value !== undefined && cellInfo.value !== null && InstanceaddressP7347CD0B4C364443AD716ADC3225C05C) {
                            InstanceaddressP7347CD0B4C364443AD716ADC3225C05C.option("value", cellInfo.value);
                        }
        },
                },

                {
                    dataField: "contactPerson",
                    caption: "%ContactPerson%",
                    width: 150,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function (cellElement, cellInfo) {
                        const val = cellInfo.value;


                        if (val === undefined || val === null || val === "") {
                            
                            return;
                        }

                        const ds = window["DataSource_contactPerson"];
                        if (ds && Array.isArray(ds)) {
                            const f = ds.find(x => x.id == val || x.ID == val);
                            if (f) {
                                $("<div>").text(f.Text || f.Name || "").appendTo(cellElement);
                                return;
     }
                        }

                        $("<div>").text(cellInfo.displayValue ?? val).appendTo(cellElement);
                    },
                    allowEditing: true,
                    editCellTemplate: function (cellElement, cellInfo) {
                        // Cập nhật record context ID cho row hiện tại
                        let rowID = null;
                        if (cellInfo.key !== undefined && cellInfo.key !== null) {
                            rowID = cellInfo.key;
                        } else if (cellInfo.data && cellInfo.data["ID"] !== undefined) {
                            rowID = cellInfo.data["ID"];
                        }

                        if (rowID !== null) {
                            currentRecordID_ID = rowID;
                        }

                        if ("" && "".trim() !== "" && cellInfo.data && cellInfo.data[""] !== undefined) {
                            currentRecordID_ = cellInfo.data[""];
                        }


                        // Set initial value
                        if (cellInfo.value !== undefined && cellInfo.value !== null && InstancecontactPersonP7347CD0B4C364443AD716ADC3225C05C) {
                            InstancecontactPersonP7347CD0B4C364443AD716ADC3225C05C.option("value", cellInfo.value);
                        }
                    },
                },

                {
                    dataField: "phone",
                    caption: "%phoneNumber%",
                    width: 150,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function (cellElement, cellInfo) {
                        const val = cellInfo.value;

                        if (val === undefined || val === null || val === "") {
                            
                            return;
                        }

                        const ds = window["DataSource_phone"];
                        if (ds && Array.isArray(ds)) {
                            const f = ds.find(x => x.id == val || x.ID == val);
                            if (f) {
                                $("<div>").text(f.Text || f.Name || "").appendTo(cellElement);
                                return;
                            }
                        }

                        $("<div>").text(cellInfo.displayValue ?? val).appendTo(cellElement);
                    },
                    allowEditing: true,
                    editCellTemplate: function (cellElement, cellInfo) {
                        // Cập nhật record context ID cho row hiện tại
                        let rowID = null;
                        if (cellInfo.key !== undefined && cellInfo.key !== null) {
                            rowID = cellInfo.key;
   } else if (cellInfo.data && cellInfo.data["ID"] !== undefined) {
                            rowID = cellInfo.data["ID"];
                        }

                        if (rowID !== null) {
                            currentRecordID_ID = rowID;
                        }

                        if ("" && "".trim() !== "" && cellInfo.data && cellInfo.data[""] !== undefined) {
             currentRecordID_ = cellInfo.data[""];
                        }


                        // Set initial value
                        if (cellInfo.value !== undefined && cellInfo.value !== null && InstancephoneP7347CD0B4C364443AD716ADC3225C05C) {
                            InstancephoneP7347CD0B4C364443AD716ADC3225C05C.option("value", cellInfo.value);
                        }
                    },
                },

                {
                    dataField: "email",
                    caption: "%Email%",
                    width: 150,
                    allowSorting: true,
                    allowFiltering: true,
               cellTemplate: function (cellElement, cellInfo) {
                        const val = cellInfo.value;

                        if (val === undefined || val === null || val === "") {
                            
                            return;
                        }

                        const ds = window["DataSource_email"];
                 if (ds && Array.isArray(ds)) {
                            const f = ds.find(x => x.id == val || x.ID == val);
                            if (f) {
                                $("<div>").text(f.Text || f.Name || "").appendTo(cellElement);
                                return;
                            }
                        }

                        $("<div>").text(cellInfo.displayValue ?? val).appendTo(cellElement);
                    },
                    allowEditing: true,
                    editCellTemplate: function (cellElement, cellInfo) {
                        // Cập nhật record context ID cho row hiện tại
                        let rowID = null;
                        if (cellInfo.key !== undefined && cellInfo.key !== null) {
                            rowID = cellInfo.key;
                        } else if (cellInfo.data && cellInfo.data["ID"] !== undefined) {
                            rowID = cellInfo.data["ID"];
                        }

                        if (rowID !== null) {
                            currentRecordID_ID = rowID;
                        }

                        if ("" && "".trim() !== "" && cellInfo.data && cellInfo.data[""] !== undefined) {
                            currentRecordID_ = cellInfo.data[""];
                        }


                        // Set initial value
                        if (cellInfo.value !== undefined && cellInfo.value !== null && InstanceemailP7347CD0B4C364443AD716ADC3225C05C) {
                            InstanceemailP7347CD0B4C364443AD716ADC3225C05C.option("value", cellInfo.value);
                        }
                    },
                },

                {
                    dataField: "source",
                    caption: "%SourceDetail%",
                    width: 150,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function (cellElement, cellInfo) {
                        const val = cellInfo.value;

                        if (val === undefined || val === null || val === "") {
                            
                            return;
                        }

                        const ds = window["DataSource_source"];
                        if (ds && Array.isArray(ds)) {
                            const f = ds.find(x => x.id == val || x.ID == val);
                            if (f) {
                                $("<div>").text(f.Text || f.Name || "").appendTo(cellElement);
                                return;
                            }
                        }

                        $("<div>").text(cellInfo.displayValue ?? val).appendTo(cellElement);
                    },
            allowEditing: true,
                    editCellTemplate: function (cellElement, cellInfo) {
                        // Cập nhật record context ID cho row hiện tại
          let rowID = null;
                        if (cellInfo.key !== undefined && cellInfo.key !== null) {
                            rowID = cellInfo.key;
                        } else if (cellInfo.data && cellInfo.data["ID"] !== undefined) {
                            rowID = cellInfo.data["ID"];
                        }

                        if (rowID !== null) {
                            currentRecordID_ID = rowID;
                        }

                        if ("" && "".trim() !== "" && cellInfo.data && cellInfo.data[""] !== undefined) {
                            currentRecordID_ = cellInfo.data[""];
                        }


                        // Set initial value
                        if (cellInfo.value !== undefined && cellInfo.value !== null && InstancesourceP7347CD0B4C364443AD716ADC3225C05C) {
                            InstancesourceP7347CD0B4C364443AD716ADC3225C05C.option("value", cellInfo.value);
                        }
                    },
                },

                {
                    dataField: "negotiation1",
                    caption: "%lblNote%",
                    width: 150,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function (cellElement, cellInfo) {
                        const val = cellInfo.value;

                        if (val === undefined || val === null || val === "") {
                            
                            return;
                        }

                        const ds = window["DataSource_negotiation1"];
                        if (ds && Array.isArray(ds)) {
                            const f = ds.find(x => x.id == val || x.ID == val);
                            if (f) {
                                $("<div>").text(f.Text || f.Name || "").appendTo(cellElement);
                                return;
                            }
                        }

                        $("<div>").text(cellInfo.displayValue ?? val).appendTo(cellElement);
                    },
                    allowEditing: true,
                    editCellTemplate: function (cellElement, cellInfo) {
                        // Cập nhật record context ID cho row hiện tại
                        let rowID = null;
                        if (cellInfo.key !== undefined && cellInfo.key !== null) {
                            rowID = cellInfo.key;
                        } else if (cellInfo.data && cellInfo.data["ID"] !== undefined) {
                            rowID = cellInfo.data["ID"];
                        }

                        if (rowID !== null) {
                            currentRecordID_ID = rowID;
                        }

                        if ("" && "".trim() !== "" && cellInfo.data && cellInfo.data[""] !== undefined) {
                            currentRecordID_ = cellInfo.data[""];
                        }


                        /* Thêm CSS cho textarea height 100% */
                        if (!$("head").find("#hpa-textarea-height-style").length) {
                            $("head").append("<style id=\"hpa-textarea-height-style\">textarea.dx-texteditor-input { height: 100% !important; }</style>");
                     }

                        let $containernegotiation1P7347CD0B4C364443AD716ADC3225C05C = $(cellElement);
                        let Instancenegotiation1P7347CD0B4C364443AD716ADC3225C05C = null;

                        let negotiation1P7347CD0B4C364443AD716ADC3225C05COriginalValue = "";
                        let _savingnegotiation1P7347CD0B4C364443AD716ADC3225C05C = false;

                   let _autoSavenegotiation1P7347CD0B4C364443AD716ADC3225C05C = false;
                        let _readOnlynegotiation1P7347CD0B4C364443AD716ADC3225C05C = false;

         async function saveValuenegotiation1P7347CD0B4C364443AD716ADC3225C05C() {
                            if (_savingnegotiation1P7347CD0B4C364443AD716ADC3225C05C) return;

                            const newVal = (Instancenegotiation1P7347CD0B4C364443AD716ADC3225C05C ? Instancenegotiation1P7347CD0B4C364443AD716ADC3225C05C.option("value") : "").trim();

                            if (newVal === negotiation1P7347CD0B4C364443AD716ADC3225C05COriginalValue) {
                                return;
                           }

                            try {
                                _savingnegotiation1P7347CD0B4C364443AD716ADC3225C05C = true;

                                const dataJSON = JSON.stringify(["-1617191338", ["negotiation1"], [newVal || ""]]);

                                let id1 = currentRecordID_ID;
                                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                                    id1 = cellInfo.data["ID"] || id1;
                                }
                                let currentRecordIDValue = [id1];
                                let currentRecordID = ["ID"];

                                if ("" && "".trim() !== "") {
                                    let id2 = currentRecordID_;
                                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                                        id2 = cellInfo.data[""] || id2;
                                    }
                                    currentRecordIDValue.push(id2);
                                    currentRecordID.push("");
                                }

                                const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);
                                const json = await saveFunction(dataJSON, idValsJSON);

                                const dtError = json.data[json.data.length - 1] ?? [];
                                if (dtError.length && dtError[0].Status === "ERROR") {
                                    uiManager.showAlert({ type: "error", message: dtError[0].Message || "%SaveErrorMessage%" });
                                    _savingnegotiation1P7347CD0B4C364443AD716ADC3225C05C = false;
                                    return;
                                }

                                if (0 != 0 && 0 != null && 0 != "" && window.hpaSharedGridDataSources["0"]) {
                                    try {
                                        var updateData = {};
                                        updateData["ID"] = currentRecordIDValue[0];
                                        updateData["negotiation1"] = Instancenegotiation1P7347CD0B4C364443AD716ADC3225C05C ? Instancenegotiation1P7347CD0B4C364443AD716ADC3225C05C.option("value") : "";

                                        var id2FieldName = "";
                                        var hasKey2 = id2FieldName && id2FieldName !== "" && id2FieldName.indexOf("%") === -1;

                                        if (hasKey2) {
                                            if (currentRecordIDValue.length > 1 && currentRecordIDValue[1] !== undefined) {
                                                updateData[id2FieldName] = currentRecordIDValue[1];
                                     }
                                        }

                                        window.updateSharedGridRow("0", updateData);

                                        if (typeof DataSource !== "undefined" && Array.isArray(DataSource)) {
                                            var ds;
                                            if (!hasKey2) {
                         ds = DataSource.filter(item => item["ID"] === updateData["ID"]);
                                            } else {
                                                ds = DataSource.filter(item =>
                                                    item["ID"] === updateData["ID"] &&
                                                    item[id2FieldName] === updateData[id2FieldName]
                                                );
                                            }

                                            if (ds && ds.length > 0) {
                                                ds[0]["negotiation1"] = updateData["negotiation1"];
                                            }
                                      }
                                    } catch (dsErr) {
                                        console.warn("[Grid Sync] TextArea negotiation1P7347CD0B4C364443AD716ADC3225C05C: ", dsErr);
                                    }
                                }

                                if (_autoSavenegotiation1P7347CD0B4C364443AD716ADC3225C05C) {
                                    (async () => {
                                        try {
                                            _savingnegotiation1P7347CD0B4C364443AD716ADC3225C05C = true;
                                            const dataJSON = JSON.stringify(["-1617191338", ["negotiation1"], [newVal || ""]]);

                                            let id1 = currentRecordID_ID;
                                            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                                                id1 = cellInfo.data["ID"] || id1;
                                            }

                                            let currentRecordIDValue = [id1];
                                            let currentRecordID = ["ID"];

                                            if ("" && "".trim() !== "") {
                                                let id2 = currentRecordID_;
                                                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                                                    id2 = cellInfo.data[""] || id2;
                                                }
                                                currentRecordIDValue.push(id2);
                                                currentRecordID.push("");
                                            }

                                            const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);
                                            const json = await saveFunction(dataJSON, idValsJSON);

                                            const dtError = json.data[json.data.length - 1] ?? [];
                                            if (dtError.length && dtError[0].Status === "ERROR") {
                                                uiManager.showAlert({ type: "error", message: dtError[0].Message || "Lưu thất bại" });
                                                _savingnegotiation1P7347CD0B4C364443AD716ADC3225C05C = false;
                                                _justSavednegotiation1P7347CD0B4C364443AD716ADC3225C05C = false;
                                                return;
                                            }

                                            if (0 != 0 && 0 != null && 0 != "" && window.hpaSharedGridDataSources["0"]) {
                                          try {
                                                    var updateData = {};
                                                    updateData["ID"] = currentRecordIDValue[0];
                                                    updateData["negotiation1"] = Instancenegotiation1P7347CD0B4C364443AD716ADC3225C05C.option("value");

var id2FieldName = "";
                                                    var hasKey2 = id2FieldName && id2FieldName !== "" && id2FieldName.indexOf("%") === -1;

                                                    if (hasKey2) {
                 if (currentRecordIDValue.length > 1 && currentRecordIDValue[1] !== undefined) {
                                                            updateData[id2FieldName] = currentRecordIDValue[1];
                                                        }
                                                    }

                                                    // Thực hiện update shared grid
                                                    window.updateSharedGridRow("0", updateData);

         // Kiểm tra và cập nhật biến DataSource cục bộ
                                                    if (typeof DataSource !== "undefined" && Array.isArray(DataSource)) {
                                                        var ds;
                                                        if (!hasKey2) {
                                                            // Trường hợp 1 khóa
                                                            ds = DataSource.filter(item => item["ID"] === updateData["ID"]);
                                                        } else {
                                                            // Trường hợp 2 khóa
                                                            ds = DataSource.filter(item =>
                                                                item["ID"] === updateData["ID"] &&
                                                                item[id2FieldName] === updateData[id2FieldName]
                                                            );
                                                        }

                                                        if (ds && ds.length > 0) {
                                                            ds[0]["negotiation1"] = updateData["negotiation1"];
                                                        }
                                                    } // <-- Bạn thiếu dấu này
                                                } catch (dsErr) {
                                                    console.warn("[Grid Sync] TextAreaBox negotiation1P7347CD0B4C364443AD716ADC3225C05C: Không thể sync shared grid data source:", dsErr);
                                                }
                                            }


                                            negotiation1P7347CD0B4C364443AD716ADC3225C05COriginalValue = newVal;
                                            exitEditnegotiation1P7347CD0B4C364443AD716ADC3225C05C(false);
                                            _savingnegotiation1P7347CD0B4C364443AD716ADC3225C05C = false;
                                            _justSavednegotiation1P7347CD0B4C364443AD716ADC3225C05C = false;

                                            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                                try {
                                                    const grid = cellInfo.component;
                                                    grid.cellValue(cellInfo.rowIndex, "negotiation1", newVal);
                                                    grid.repaint();
                                                } catch (syncErr) { console.warn(syncErr); }
                                            }

                                        } catch (e) {
                                            uiManager.showAlert({ type: "error", message: "Lỗi khi lưu" });
                                            _savingnegotiation1P7347CD0B4C364443AD716ADC3225C05C = false;
                                        }
                                    })();

                                    return;
                                }

                                negotiation1P7347CD0B4C364443AD716ADC3225C05COriginalValue = newVal;
                                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                    try {
                                        const grid = cellInfo.component;
                                        grid.cellValue(cellInfo.rowIndex, "negotiation1", newVal);
                                        grid.repaint();
                                    } catch (syncErr) { }
                                }

                            } catch (e) {
                                uiManager.showAlert({ type: "error", message: "%SaveErrorMessage%" });
              } finally {
                                setTimeout(function () {
                                    _savingnegotiation1P7347CD0B4C364443AD716ADC3225C05C = false;
                                }, 100);
                            }
                        }

                        /* ================= CREATE UI ================= */
                        Instancenegotiation1P7347CD0B4C364443AD716ADC3225C05C = $("<div>").appendTo($containernegotiation1P7347CD0B4C364443AD716ADC3225C05C).dxTextArea({
                            value: "",
                            width: "100%",
                            height: 80,
                            inputAttr: {
                                style: "padding-left: 0; padding-right: 0; font-size: 14px;"
                            }
                        }).dxTextArea("instance");

                        // Set initial value
                        if (cellInfo.value !== undefined && cellInfo.value !== null && Instancenegotiation1P7347CD0B4C364443AD716ADC3225C05C) {
                            Instancenegotiation1P7347CD0B4C364443AD716ADC3225C05C.option("value", cellInfo.value);
                        }
                    },
                },

                {
                    dataField: "PositionID",
                    caption: "%ReferrerTitle%",
                    width: 150,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function (cellElement, cellInfo) {
                        const val = cellInfo.value;

                        if (val === undefined || val === null || val === "") {
                            
                            return;
                        }

                        const ds = window["DataSource_PositionID"];
                        if (ds && Array.isArray(ds)) {
                            const f = ds.find(x => x.id == val || x.ID == val);
                            if (f) {
                                $("<div>").text(f.Text || f.Name || "").appendTo(cellElement);
                                return;
                            }
                        }

                        $("<div>").text(cellInfo.displayValue ?? val).appendTo(cellElement);
                    },
                    allowEditing: true,
                    editCellTemplate: function (cellElement, cellInfo) {
                        // Cập nhật record context ID cho row hiện tại
                        let rowID = null;
                        if (cellInfo.key !== undefined && cellInfo.key !== null) {
                   rowID = cellInfo.key;
                        } else if (cellInfo.data && cellInfo.data["ID"] !== undefined) {
                            rowID = cellInfo.data["ID"];
                        }

                        if (rowID !== null) {
                            currentRecordID_ID = rowID;
                        }

                        if ("" && "".trim() !== "" && cellInfo.data && cellInfo.data[""] !== undefined) {
                            currentRecordID_ = cellInfo.data[""];
                        }


                        window["DataSource_PositionID"] = window["DataSource_PositionID"] || [];

                        let PositionIDP7347CD0B4C364443AD716ADC3225C05CDataSourceSP = "";
                        let PositionIDP7347CD0B4C364443AD716ADC3225C05CIsLoading = false;
                        let PositionIDP7347CD0B4C364443AD716ADC3225C05CIsDataLoaded = false;
                        let _autoSavePositionIDP7347CD0B4C364443AD716ADC3225C05C = false;
                        let _readOnlyPositionIDP7347CD0B4C364443AD716ADC3225C05C = false;
                        let PositionIDP7347CD0B4C364443AD716ADC3225C05CTableAddNew = "";
                        let PositionIDP7347CD0B4C364443AD716ADC3225C05CColumnAddNew = "";
                        let PositionIDP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = "";
                        let PositionIDP7347CD0B4C364443AD716ADC3225C05CLastSearchValue = "";
                        let InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C = null;
                        const PositionIDP7347CD0B4C364443AD716ADC3225C05CLastSearchClass = "hpa-last-search-P7347CD0B4C364443AD716ADC3225C05C";

                        function getDataSourceConfigPositionIDP7347CD0B4C364443AD716ADC3225C05C(data) {
                            const idField = window["DataSourceIDField_PositionID"] || "ID";
                            return new DevExpress.data.DataSource({
                                paginate: false,
                                store: new DevExpress.data.CustomStore({
                                    key: idField,
                                    load: function (loadOptions) {
                                        let searchValue = PositionIDP7347CD0B4C364443AD716ADC3225C05CCurrentSearch || "";

                                        if (!searchValue && loadOptions && loadOptions.searchValue) {
                                            searchValue = loadOptions.searchValue;
                                        }

                                        if (!searchValue && InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C && InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option) {
                                            searchValue = InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("searchValue") || "";
                                        }

                                        let result = data || [];

                                        if (searchValue && searchValue.trim()) {
                                            result = result.filter(item => customSearchPositionID(item, searchValue));

                                            if (PositionIDP7347CD0B4C364443AD716ADC3225C05CTableAddNew && PositionIDP7347CD0B4C364443AD716ADC3225C05CTableAddNew.trim() !== "") {
                                                const nameField = window["DataSourceNameField_PositionID"] || "Name";
                                                const addNewItem = { IsAddNew: true };
                                                addNewItem[nameField] = searchValue.trim();
                                                result.push(addNewItem);
                                            }
                                        }

                                        return Promise.resolve(result);
                                    },
              byKey: function (key) {
                                        const idField = window["DataSourceIDField_PositionID"] || "ID";
                                        return Promise.resolve((data || []).find(i => i[idField] === key));
                                    }
                                })
                            });
                        }

                        async function processAddNewPositionID(newValue) {
                            if (!newValue || !newValue.trim()) return;

                            InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("disabled", true);

                            const dataJSON = JSON.stringify([PositionIDP7347CD0B4C364443AD716ADC3225C05CTableAddNew, [PositionIDP7347CD0B4C364443AD716ADC3225C05CColumnAddNew], [newValue.trim()]]);

                            try {
                                console.log("dataJSON", dataJSON);
                                const json = await saveFunction(dataJSON);
                                const dtError = json.data[json.data.length - 1] || [];

                                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                                    uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lỗi thêm mới" });
                                } else {
                                    const newItemID = dtError[0]?.IDValue || null;

                                    if (newItemID) {
                                        const idField = window["DataSourceIDField_PositionID"] || "ID";
                                        const nameField = window["DataSourceNameField_PositionID"] || "Name";

                                        const newItem = {};
                                        newItem[idField] = newItemID;
                                        newItem[nameField] = newValue.trim();

                                        if (!window["DataSource_PositionID"]) {
                                            window["DataSource_PositionID"] = [];
                                        }
                                        window["DataSource_PositionID"].push(newItem);

                                        InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("dataSource", getDataSourceConfigPositionIDP7347CD0B4C364443AD716ADC3225C05C(window["DataSource_PositionID"]));

                                        InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("value", newItemID);
                                        InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("searchValue", "");
                                        PositionIDP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = "";
                                    }
                                }
                            } catch (e) {
                                console.error(e);
                                uiManager.showAlert({ type: "error", message: "Có lỗi khi thêm mới" });
                            } finally {
                                InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("disabled", false);
                                InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.close();
                            }
                        }

                        function customSearchPositionID(item, searchValue) {
                            if (!searchValue) return true;
                            const searchNormalized = hpaUtils.removeToneMarks(searchValue).toLowerCase();
                            const idField = window["DataSourceIDField_PositionID"] || "ID";
                            const nameField = window["DataSourceNameField_PositionID"] || "Name";
                            const fields = [idField, nameField, "Code", "Description"];

                            for (let i = 0; i < fields.length; i++) {
               const fieldValue = item[fields[i]];
                                if (fieldValue) {
                                    const fieldNormalized = hpaUtils.removeToneMarks(String(fieldValue)).toLowerCase();
                                    if (fieldNormalized.indexOf(searchNormalized) !== -1) return true;
                                }
                            }
                            return false;
                        }

               function renderLastSearchHintPositionIDP7347CD0B4C364443AD716ADC3225C05C($popupContent) {
                            if (!$popupContent || !$popupContent.length) return;

                            const lastSearch = (PositionIDP7347CD0B4C364443AD716ADC3225C05CLastSearchValue || "").trim();
                            let $hint = $popupContent.find("." + PositionIDP7347CD0B4C364443AD716ADC3225C05CLastSearchClass);

                            if (!lastSearch) {
                                if ($hint.length) {
                                    $hint.remove();
                                }
                                return;
                            }

                            if (!$hint.length) {
                                $hint = $("<div>")
      .addClass(PositionIDP7347CD0B4C364443AD716ADC3225C05CLastSearchClass + " d-flex align-items-center justify-content-between gap-2 px-3 py-2 border-bottom")
                                    .css({
                                        fontSize: "12px",
                                        background: "#f8f9fa"
                                    })
                                    .prependTo($popupContent);

                                $("<span>")
                                    .addClass("flex-fill text-muted text-truncate")
                                    .appendTo($hint);

                                $("<button>")
                                    .attr("type", "button")
                                    .addClass("btn btn-link p-0 text-decoration-none fw-semibold")
                                    .text("Áp dụng lại")
                                    .on("dxclick", function (ev) {
                                        ev.preventDefault();
                                        ev.stopPropagation();
                                        if (!PositionIDP7347CD0B4C364443AD716ADC3225C05CLastSearchValue) return;
                                        PositionIDP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = PositionIDP7347CD0B4C364443AD716ADC3225C05CLastSearchValue;
                                        InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("searchValue", PositionIDP7347CD0B4C364443AD716ADC3225C05CLastSearchValue);
                                        const $input = $(cellElement).find(".dx-texteditor-input");
                                        if ($input && $input.length) {
                                            setTimeout(function () { $input.focus(); }, 0);
                                        }
                                    })
                                    .appendTo($hint);
                            }

                            $hint.find("span").text("Lần tìm trước: \"" + lastSearch + "\"");
                        }

                        InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C = $(cellElement).dxSelectBox({
                            readOnly: _readOnlyPositionIDP7347CD0B4C364443AD716ADC3225C05C,
                            dataSource: getDataSourceConfigPositionIDP7347CD0B4C364443AD716ADC3225C05C(window["DataSource_PositionID"]),
                            valueExpr: window["DataSourceIDField_PositionID"] || "ID",
                            displayExpr: window["DataSourceNameField_PositionID"] || "Name",
                            onOptionChanged: function (e) {
                 if (!e || !e.component) return;
                                if (e.name === "searchValue") {
                                    const newVal = (e.value || "").toString();
                                    PositionIDP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = newVal;
                                    if (newVal && newVal.trim()) {
                                        PositionIDP7347CD0B4C364443AD716ADC3225C05CLastSearchValue = newVal;
                       }

                                    if (e.component.option("opened") && e.component._popup) {
                                        renderLastSearchHintPositionIDP7347CD0B4C364443AD716ADC3225C05C($(e.component._popup.content()));
   }
                                }
                            },
                            onContentReady: function (e) { },
                            placeholder: "Tìm kiếm hoặc chọn...",
                            searchEnabled: true,
                            searchTimeout: 300,
                            minSearchLength: 0,
                            showDataBeforeSearch: true,
                            showClearButton: false,
                            stylingMode: "outlined",
                            dropDownOptions: {
       showTitle: false,
                                closeOnOutsideClick: true,
                                height: "auto",
                                maxHeight: 400,
                                minWidth: 320,
                                onShowing: function (e) {
                                    if (InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C && InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option) {
                                        const pendingSearch = InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("searchValue") || "";
                                        if (pendingSearch && pendingSearch.trim()) {
                                            PositionIDP7347CD0B4C364443AD716ADC3225C05CLastSearchValue = pendingSearch;
                                        }
                                        PositionIDP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = "";
                                        InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("searchValue", "");
                                    }
                                },
                                onHidden: function () {
                                    PositionIDP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = "";
                                    if (InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C && InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option) {
                                        InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("searchValue", "");
                                    }
                                }
                            },
                            itemTemplate: function (data, index) {
                                if (data.IsAddNew) {
                                    const nameField = window["DataSourceNameField_PositionID"] || "Name";
                                    const $item = $("<div>")
                                        .addClass("d-flex align-items-center gap-2 px-3 py-2 text-primary")
                                        .css({ cursor: "pointer", borderTop: "1px dashed #dee2e6", fontWeight: "600" });

                                    $("<i>").addClass("bi bi-plus-circle fs-6").appendTo($item);
                                    $("<span>").text("Thêm mới: \"" + data[nameField] + "\"").appendTo($item);

                                    $item.on("dxclick", async function (e) {
                                        e.stopPropagation();
                                        if (InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C && InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.blur) InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.blur();
                                        await processAddNewPositionID(data[nameField]);
                                    });

                                    return $item;
                                }

                                const idField = window["DataSourceIDField_PositionID"] || "ID";
         const nameField = window["DataSourceNameField_PositionID"] || "Name";
                                const searchValue = InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("searchValue") || "";

                                const $item = $("<div>")
                                    .addClass("d-flex align-items-center gap-2 px-3 py-2 border-bottom border-light")
                                    .css({ cursor: "pointer" });

                                const $content = $("<div>").addClass("flex-fill").css("minWidth", "0");

                                const displayName = (data[idField] !== undefined ? data[idField] + " - " : "") + (data[nameField] || "");
                                $("<div>")
                                    .addClass("fw-normal ")
                                    .css({
                                        fontSize: "13px",
                                        overflow: "hidden",
                                        textOverflow: "ellipsis",
                                        whiteSpace: "nowrap"
                                    })
                                    .html(hpaUtils.highlightText(displayName, searchValue))
                                    .appendTo($content);

                                if (data.Description || data.Code) {
                                    $("<div>")
                                        .addClass("text-muted")
                                        .css({
                                            fontSize: "11px",
                                            overflow: "hidden",
                                            textOverflow: "ellipsis",
                                            whiteSpace: "nowrap"
                                        })
                                        .text(data.Code || data.Description)
                                        .appendTo($content);
                                }

                                $content.appendTo($item);

                                if (data.Status) {
                                    const badgeClass = data.Status === "Active" ? "bg-success" : "bg-secondary";
                                    $("<span>")
                                        .addClass("badge " + badgeClass)
                                        .css({
                                            fontSize: "9px",
                                            padding: "3px 6px",
                                            borderRadius: "4px",
                                            opacity: "0.8"
                                        })
                                        .text(data.Status)
                                        .appendTo($item);
                                }

                                return $item;
                            },
                            onOpened: function (e) {
                                const $popupContent = $(e.component._popup.content());
                                $popupContent.parent()
                                    .addClass("shadow-lg border rounded")
                                    .css({
                                        borderRadius: "8px",
                                        padding: "4px 0",
                                        borderColor: "#dee2e6"
                                    });

            renderLastSearchHintPositionIDP7347CD0B4C364443AD716ADC3225C05C($popupContent);
                            },
                            onFocusIn: function (e) {
                                InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("showClearButton", true);
                            },
                            onFocusOut: function (e) {
                                InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("showClearButton", false);
                       },
                            onKeyDown: function (e) {
                                if (e.key === "Enter" || e.key === "Tab") {
                                    InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("showClearButton", false);
                                }
                      },
                            onValueChanged: async function (e) {
                                if (!e.event) return;

                                if (_autoSavePositionIDP7347CD0B4C364443AD716ADC3225C05C) {
                                    if (e.value === "" || e.value == null || e.value === 0 || e.value === "0") {
                                        InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("value", _initialPositionIDP7347CD0B4C364443AD716ADC3225C05C);
                                        return;
          }

                                    $(cellElement).find(".dx-texteditor-input").blur();
                                    if (InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C && InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.blur) InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.blur();

                                    if (typeof window["onSelectBoxChanged_PositionID"] === "function") {
                                        window["onSelectBoxChanged_PositionID"](e.value, InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C, e);
                              }

                                    const val = e.value;
                                    const dataJSON = JSON.stringify(["-1617191338", ["PositionID"], [val || ""]]);

                                    let id1 = currentRecordID_ID;
                                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                                        id1 = cellInfo.data["ID"] || id1;
                                    }
                                    let currentRecordIDValue = [id1];
                                    let currentRecordID = ["ID"];

                                    if ("" && "".trim() !== "") {
                                        let id2 = currentRecordID_;
                                        if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                                            id2 = cellInfo.data[""] || id2;
                                        }
                                        currentRecordIDValue.push(id2);
                                        currentRecordID.push("");
                                    }
                                    const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);

                                    try {
                                        const json = await saveFunction(dataJSON, idValsJSON);
                                        const dtError = json.data[json.data.length - 1] || [];
                                        if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                                            uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                                            InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("value", _initialPositionIDP7347CD0B4C364443AD716ADC3225C05C);
                                        } else {
                               if (0 != 0 && 0 != null && 0 != "" && window.hpaSharedGridDataSources["0"]) {
                                                try {

                                                    let KeyRowTable = window.currentClicked_0;
                                                    console.log("KeyRowTable:", KeyRowTable);
                                                    if (KeyRowTable != null && KeyRowTable != undefined) {
                                                        var updateData = {};
                                                        updateData["0"] = KeyRowTable;
                                                        updateData["PositionID"] = InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("value");

                                                        // 2. Thực hiện update Shared Grid
                                                        // Vì dùng RowID, Grid sẽ tự tìm dòng cực nhanh
                                                        window.updateSharedGridRow("0", updateData);

                                                        // 3. Cập nhật biến DataSource cục bộ (Dùng RowID để tìm)
                                                        if (typeof DataSource !== "undefined" && Array.isArray(DataSource)) {
                                                            // Chỉ cần 1 dòng filter duy nhất, không cần check hasKey2 rườm rà nữa
                                                            var ds = DataSource.filter(item => item.RowID === KeyRowTable);

                                                            if (ds && ds.length > 0) {
                                                                ds[0]["PositionID"] = updateData["PositionID"];

                                                                // Nếu bạn đang sửa chính là 1 trong các ID cấu thành RowID
                                                                // Cần cập nhật lại RowID mới nếu cần thiết (tùy logic nghiệp vụ)
                                                            }
                                                        }
                                                    }

                                                    var updateData = {};
                                                    updateData["ID"] = currentRecordIDValue[0];
                                                    updateData["PositionID"] = InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("value");

                                                    var id2FieldName = "";
                                                    var hasKey2 = id2FieldName && id2FieldName !== "" && id2FieldName.indexOf("%") === -1;

                                                    if (hasKey2) {
                                                        if (currentRecordIDValue.length > 1 && currentRecordIDValue[1] !== undefined) {
                                                            updateData[id2FieldName] = currentRecordIDValue[1];
                                                        }
                                                    }

                                                    window.updateSharedGridRow("0", updateData);

                                                    if (typeof DataSource !== "undefined" && Array.isArray(DataSource)) {
                                                        var ds;
                                                        if (!hasKey2) {
                                                            ds = DataSource.filter(item => item["ID"] === updateData["ID"]);
                                                        } else {
                                                            ds = DataSource.filter(item =>
                                                                item["ID"] === updateData["ID"] &&
          item[id2FieldName] === updateData[id2FieldName]
                                                            );
                                                        }

                                                        if (ds && ds.length > 0) {
                                                            ds[0]["PositionID"] = updateData["PositionID"];
                                                        }
                                                    }
                                                } catch (dsErr) {
                                 console.warn("[Grid Sync] SelectBox PositionIDP7347CD0B4C364443AD716ADC3225C05C: Không thể sync shared grid data source:", dsErr);
                                                }
                                            }

                                            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                                try {
                                                    const grid = cellInfo.component;
                                                    grid.cellValue(cellInfo.rowIndex, "PositionID", val);
                                                    grid.repaint();
                                                } catch (syncErr) {
                                                    console.warn("[Grid Sync] SelectBox PositionIDP7347CD0B4C364443AD716ADC3225C05C: Không thể sync grid:", syncErr);
                                                }
                                            }
                                            _initialPositionIDP7347CD0B4C364443AD716ADC3225C05C = val;
                                        }
                                    } catch (err) {
                                        uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                                        InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("value", _initialPositionIDP7347CD0B4C364443AD716ADC3225C05C);
                                     console.error("SelectBox Save Error:", err);
                                    }
                                    return;
                                }

                                // Manual mode - no save, just callbacks and grid sync
                                if (typeof window["onSelectBoxChanged_PositionID"] === "function") {
                                    window["onSelectBoxChanged_PositionID"](e.value, InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C, e);
                                }

                                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                    try {
                                        const grid = cellInfo.component;
                                        grid.cellValue(cellInfo.rowIndex, "PositionID", e.value);
                                        grid.repaint();
                                    } catch (syncErr) {
                                        console.warn("[Grid Sync] Không thể sync grid:", syncErr);
                                    }
                                }
                            }
                        }).dxSelectBox("instance");

                        let _initialPositionIDP7347CD0B4C364443AD716ADC3225C05C = InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("value");

                        if (PositionIDP7347CD0B4C364443AD716ADC3225C05CDataSourceSP && PositionIDP7347CD0B4C364443AD716ADC3225C05CDataSourceSP !== "") {
                            loadDataSourceCommon("PositionID", PositionIDP7347CD0B4C364443AD716ADC3225C05CDataSourceSP, function (data) {
                                PositionIDP7347CD0B4C364443AD716ADC3225C05CIsDataLoaded = true;

                                const idField = window["DataSourceIDField_PositionID"] || "ID";
                                const nameField = window["DataSourceNameField_PositionID"] || "Name";

                                InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("valueExpr", idField);
                                InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("displayExpr", nameField);

                                InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("dataSource", getDataSourceConfigPositionIDP7347CD0B4C364443AD716ADC3225C05C(data));
                                InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.repaint();
                            });
                        }

                        // Set initial value
                        if (cellInfo.value !== undefined && cellInfo.value !== null && InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C) {
                            InstancePositionIDP7347CD0B4C364443AD716ADC3225C05C.option("value", cellInfo.value);
                        }
                    },
                },

                {
                    dataField: "Status",
                    caption: "%Approve_Status%",
                    width: 150,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function (cellElement, cellInfo) {
                        const statusID = cellInfo.value;

                        if (statusID === undefined || statusID === null || statusID === "") {
                         $("<div>").addClass("dx-placeholder text-center py-2").text("--").appendTo(cellElement);
                            return;
                        }

                        // Lấy text display từ DataSource
                        let statusText = cellInfo.displayValue || statusID;
                        const ds = window["DataSource_Status"];
                        if (ds && Array.isArray(ds)) {
                            const f = ds.find(x => x.id == statusID || x.ID == statusID);
                            if (f) {
                 statusText = f.Text || f.Name || statusText;
                            }
                        }

                        let bootstrapClass = "";
                        let icon = "";

                        // chờ duyệt = Vàng (warning)
                        if (statusID == 1) {
                            bootstrapClass = "bg-warning";
                            icon = "bi-clock-history";
                        }
                        // Hoàn thành = Xanh lá (success)
                        else if (statusID == 2) {
                            bootstrapClass = "bg-success";
                            icon = "bi-check-circle-fill";
                        }
                        // Hủy = Đỏ (danger)
                        else if (statusID == 3) {
                            bootstrapClass = "bg-danger";
                            icon = "bi-x-circle-fill";
                        }
                        else {
                            bootstrapClass = "bg-secondary";
                            icon = "bi-circle";
                        }

                        $("<div>")
                            .addClass("badge-view " + bootstrapClass)
                            .html(`<i class="bi ${icon} me-1"></i>${statusText}`)
                            .appendTo(cellElement);
                    },
                    allowEditing: true,
                    editCellTemplate: function (cellElement, cellInfo) {
                        // Cập nhật record context ID cho row hiện tại
                        let rowID = null;
                        if (cellInfo.key !== undefined && cellInfo.key !== null) {
                            rowID = cellInfo.key;
                        } else if (cellInfo.data && cellInfo.data["ID"] !== undefined) {
                            rowID = cellInfo.data["ID"];
                        }

                        if (rowID !== null) {
                            currentRecordID_ID = rowID;
                        }

                        if ("" && "".trim() !== "" && cellInfo.data && cellInfo.data[""] !== undefined) {
                            currentRecordID_ = cellInfo.data[""];
                        }


                        window["DataSource_Status"] = window["DataSource_Status"] || [];

                        let StatusP7347CD0B4C364443AD716ADC3225C05CDataSourceSP = "";
                        let StatusP7347CD0B4C364443AD716ADC3225C05CIsLoading = false;
                        let StatusP7347CD0B4C364443AD716ADC3225C05CIsDataLoaded = false;
                        let _autoSaveStatusP7347CD0B4C364443AD716ADC3225C05C = false;
                        let _readOnlyStatusP7347CD0B4C364443AD716ADC3225C05C = false;
    let StatusP7347CD0B4C364443AD716ADC3225C05CTableAddNew = "";
                        let StatusP7347CD0B4C364443AD716ADC3225C05CColumnAddNew = "";
                        let StatusP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = "";
                        let StatusP7347CD0B4C364443AD716ADC3225C05CLastSearchValue = "";
                        let InstanceStatusP7347CD0B4C364443AD716ADC3225C05C = null;
                        const StatusP7347CD0B4C364443AD716ADC3225C05CLastSearchClass = "hpa-last-search-P7347CD0B4C364443AD716ADC3225C05C";

                        function getDataSourceConfigStatusP7347CD0B4C364443AD716ADC3225C05C(data) {
                            const idField = window["DataSourceIDField_Status"] || "ID";
                            return new DevExpress.data.DataSource({
                                paginate: false,
                                store: new DevExpress.data.CustomStore({
                                    key: idField,
                                    load: function (loadOptions) {
                                        let searchValue = StatusP7347CD0B4C364443AD716ADC3225C05CCurrentSearch || "";

                          if (!searchValue && loadOptions && loadOptions.searchValue) {
                                            searchValue = loadOptions.searchValue;
                                        }

                                        if (!searchValue && InstanceStatusP7347CD0B4C364443AD716ADC3225C05C && InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option) {
                                            searchValue = InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("searchValue") || "";
                                        }

                                        let result = data || [];

                                        if (searchValue && searchValue.trim()) {
                                            result = result.filter(item => customSearchStatus(item, searchValue));

                                            if (StatusP7347CD0B4C364443AD716ADC3225C05CTableAddNew && StatusP7347CD0B4C364443AD716ADC3225C05CTableAddNew.trim() !== "") {
                                                const nameField = window["DataSourceNameField_Status"] || "Name";
                                                const addNewItem = { IsAddNew: true };
                                                addNewItem[nameField] = searchValue.trim();
                                                result.push(addNewItem);
                                            }
                                        }

                                        return Promise.resolve(result);
                                    },
                                    byKey: function (key) {
                                        const idField = window["DataSourceIDField_Status"] || "ID";
                                        return Promise.resolve((data || []).find(i => i[idField] === key));
     }
                                })
                            });
                        }

                        async function processAddNewStatus(newValue) {
                            if (!newValue || !newValue.trim()) return;

                            InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("disabled", true);

                            const dataJSON = JSON.stringify([StatusP7347CD0B4C364443AD716ADC3225C05CTableAddNew, [StatusP7347CD0B4C364443AD716ADC3225C05CColumnAddNew], [newValue.trim()]]);

                            try {
        console.log("dataJSON", dataJSON);
                                const json = await saveFunction(dataJSON);
                                const dtError = json.data[json.data.length - 1] || [];

                                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                                    uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lỗi thêm mới" });
                                } else {
                                    const newItemID = dtError[0]?.IDValue || null;

                                    if (newItemID) {
                                        const idField = window["DataSourceIDField_Status"] || "ID";
                                        const nameField = window["DataSourceNameField_Status"] || "Name";

                                        const newItem = {};
                                        newItem[idField] = newItemID;
           newItem[nameField] = newValue.trim();

                                        if (!window["DataSource_Status"]) {
                                            window["DataSource_Status"] = [];
                                        }
                                        window["DataSource_Status"].push(newItem);

                                        InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("dataSource", getDataSourceConfigStatusP7347CD0B4C364443AD716ADC3225C05C(window["DataSource_Status"]));

                                        InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("value", newItemID);
                                        InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("searchValue", "");
                                        StatusP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = "";
                                    }
                                }
                            } catch (e) {
                                console.error(e);
                                uiManager.showAlert({ type: "error", message: "Có lỗi khi thêm mới" });
                            } finally {
                                InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("disabled", false);
                                InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.close();
                            }
                        }

                        function customSearchStatus(item, searchValue) {
                            if (!searchValue) return true;
                            const searchNormalized = hpaUtils.removeToneMarks(searchValue).toLowerCase();
                            const idField = window["DataSourceIDField_Status"] || "ID";
                            const nameField = window["DataSourceNameField_Status"] || "Name";
                            const fields = [idField, nameField, "Code", "Description"];

                            for (let i = 0; i < fields.length; i++) {
                                const fieldValue = item[fields[i]];
                                if (fieldValue) {
                                    const fieldNormalized = hpaUtils.removeToneMarks(String(fieldValue)).toLowerCase();
                                    if (fieldNormalized.indexOf(searchNormalized) !== -1) return true;
                                }
                           }
                            return false;
                        }

                        function renderLastSearchHintStatusP7347CD0B4C364443AD716ADC3225C05C($popupContent) {
                            if (!$popupContent || !$popupContent.length) return;

                            const lastSearch = (StatusP7347CD0B4C364443AD716ADC3225C05CLastSearchValue || "").trim();
                            let $hint = $popupContent.find("." + StatusP7347CD0B4C364443AD716ADC3225C05CLastSearchClass);

                            if (!lastSearch) {
            if ($hint.length) {
                                    $hint.remove();
                                }
                                return;
                            }

                            if (!$hint.length) {
                                $hint = $("<div>")
                                    .addClass(StatusP7347CD0B4C364443AD716ADC3225C05CLastSearchClass + " d-flex align-items-center justify-content-between gap-2 px-3 py-2 border-bottom")
                                    .css({
                                        fontSize: "12px",
                                        background: "#f8f9fa"
                                    })
                                    .prependTo($popupContent);

                                $("<span>")
                                    .addClass("flex-fill text-muted text-truncate")
                                    .appendTo($hint);

                                $("<button>")
                           .attr("type", "button")
                                    .addClass("btn btn-link p-0 text-decoration-none fw-semibold")
                                    .text("Áp dụng lại")
                                    .on("dxclick", function (ev) {
                                        ev.preventDefault();
                                        ev.stopPropagation();
                                        if (!StatusP7347CD0B4C364443AD716ADC3225C05CLastSearchValue) return;
                                        StatusP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = StatusP7347CD0B4C364443AD716ADC3225C05CLastSearchValue;
                                        InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("searchValue", StatusP7347CD0B4C364443AD716ADC3225C05CLastSearchValue);
                                        const $input = $(cellElement).find(".dx-texteditor-input");
                                        if ($input && $input.length) {
                                            setTimeout(function () { $input.focus(); }, 0);
                                        }
                                    })
                                    .appendTo($hint);
                            }

                            $hint.find("span").text("Lần tìm trước: \"" + lastSearch + "\"");
                        }

                        InstanceStatusP7347CD0B4C364443AD716ADC3225C05C = $(cellElement).dxSelectBox({
                            readOnly: _readOnlyStatusP7347CD0B4C364443AD716ADC3225C05C,
                            dataSource: getDataSourceConfigStatusP7347CD0B4C364443AD716ADC3225C05C(window["DataSource_Status"]),
                            valueExpr: window["DataSourceIDField_Status"] || "ID",
                            displayExpr: window["DataSourceNameField_Status"] || "Name",
                            onOptionChanged: function (e) {
                                if (!e || !e.component) return;
                                if (e.name === "searchValue") {
                                    const newVal = (e.value || "").toString();
                                    StatusP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = newVal;
                                    if (newVal && newVal.trim()) {
                                        StatusP7347CD0B4C364443AD716ADC3225C05CLastSearchValue = newVal;
                                    }

                                    if (e.component.option("opened") && e.component._popup) {
                                        renderLastSearchHintStatusP7347CD0B4C364443AD716ADC3225C05C($(e.component._popup.content()));
                                    }
                                }
                            },
                            onContentReady: function (e) { },
                            placeholder: "Tìm kiếm hoặc chọn...",
                            searchEnabled: true,
                     searchTimeout: 300,
                            minSearchLength: 0,
                            showDataBeforeSearch: true,
                            showClearButton: false,
                            stylingMode: "outlined",
                            dropDownOptions: {
                                showTitle: false,
                                closeOnOutsideClick: true,
                                height: "auto",
                                maxHeight: 400,
                                minWidth: 320,
                                onShowing: function (e) {
                                    if (InstanceStatusP7347CD0B4C364443AD716ADC3225C05C && InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option) {
                                        const pendingSearch = InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("searchValue") || "";
                                        if (pendingSearch && pendingSearch.trim()) {
                                StatusP7347CD0B4C364443AD716ADC3225C05CLastSearchValue = pendingSearch;
                                        }
                                        StatusP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = "";
                                        InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("searchValue", "");
                                    }
                                },
                                onHidden: function () {
                                    StatusP7347CD0B4C364443AD716ADC3225C05CCurrentSearch = "";
                                    if (InstanceStatusP7347CD0B4C364443AD716ADC3225C05C && InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option) {
                                        InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("searchValue", "");
                                    }
                                }
                            },
                            itemTemplate: function (data, index) {
                                if (data.IsAddNew) {
                                    const nameField = window["DataSourceNameField_Status"] || "Name";
                                    const $item = $("<div>")
                                        .addClass("d-flex align-items-center gap-2 px-3 py-2 text-primary")
                                        .css({ cursor: "pointer", borderTop: "1px dashed #dee2e6", fontWeight: "600" });

                                    $("<i>").addClass("bi bi-plus-circle fs-6").appendTo($item);
                                    $("<span>").text("Thêm mới: \"" + data[nameField] + "\"").appendTo($item);

                                    $item.on("dxclick", async function (e) {
                                        e.stopPropagation();
                                        if (InstanceStatusP7347CD0B4C364443AD716ADC3225C05C && InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.blur) InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.blur();
                                        await processAddNewStatus(data[nameField]);
                                    });

                                    return $item;
                                }

                                const idField = window["DataSourceIDField_Status"] || "ID";
                                const nameField = window["DataSourceNameField_Status"] || "Name";
                                const searchValue = InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("searchValue") || "";

                                const $item = $("<div>")
                                    .addClass("d-flex align-items-center gap-2 px-3 py-2 border-bottom border-light")
                                    .css({ cursor: "pointer" });

                                const $content = $("<div>").addClass("flex-fill").css("minWidth", "0");

                                const displayName = (data[idField] !== undefined ? data[idField] + " - " : "") + (data[nameField] || "");
                                $("<div>")
                                    .addClass("fw-normal ")
                                    .css({
                                        fontSize: "13px",
                                        overflow: "hidden",
                                        textOverflow: "ellipsis",
                                        whiteSpace: "nowrap"
                                    })
                                    .html(hpaUtils.highlightText(displayName, searchValue))
                                    .appendTo($content);

                                if (data.Description || data.Code) {
                                    $("<div>")
                                        .addClass("text-muted")
                                        .css({
                                            fontSize: "11px",
  overflow: "hidden",
                                            textOverflow: "ellipsis",
                                            whiteSpace: "nowrap"
                                        })
                                        .text(data.Code || data.Description)
                                        .appendTo($content);
                                }

                                $content.appendTo($item);

                                if (data.Status) {
                                    const badgeClass = data.Status === "Active" ? "bg-success" : "bg-secondary";
                                    $("<span>")
                       .addClass("badge " + badgeClass)
                                        .css({
                                            fontSize: "9px",
                                            padding: "3px 6px",
                                            borderRadius: "4px",
                                            opacity: "0.8"
                                        })
                                        .text(data.Status)
                                        .appendTo($item);
                                }

                                return $item;
                            },
                            onOpened: function (e) {
                                const $popupContent = $(e.component._popup.content());
                                $popupContent.parent()
                                    .addClass("shadow-lg border rounded")
                                    .css({
                                        borderRadius: "8px",
                                        padding: "4px 0",
                                        borderColor: "#dee2e6"
                                    });

                                renderLastSearchHintStatusP7347CD0B4C364443AD716ADC3225C05C($popupContent);
                            },
                            onFocusIn: function (e) {
                                InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("showClearButton", true);
                            },
                            onFocusOut: function (e) {
                                InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("showClearButton", false);
             },
                            onKeyDown: function (e) {
                                if (e.key === "Enter" || e.key === "Tab") {
                                    InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("showClearButton", false);
                                }
                            },
                            onValueChanged: async function (e) {
                                if (!e.event) return;

                                if (_autoSaveStatusP7347CD0B4C364443AD716ADC3225C05C) {
                                    if (e.value === "" || e.value == null || e.value === 0 || e.value === "0") {
                                        InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("value", _initialStatusP7347CD0B4C364443AD716ADC3225C05C);
                                        return;
                                    }

                                    $(cellElement).find(".dx-texteditor-input").blur();
              if (InstanceStatusP7347CD0B4C364443AD716ADC3225C05C && InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.blur) InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.blur();

                                    if (typeof window["onSelectBoxChanged_Status"] === "function") {
                                        window["onSelectBoxChanged_Status"](e.value, InstanceStatusP7347CD0B4C364443AD716ADC3225C05C, e);
                                    }

                                    const val = e.value;
                                    const dataJSON = JSON.stringify(["-1617191338", ["Status"], [val || ""]]);

                                    let id1 = currentRecordID_ID;
                                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                                        id1 = cellInfo.data["ID"] || id1;
                                    }
                                    let currentRecordIDValue = [id1];
                                    let currentRecordID = ["ID"];

                                    if ("" && "".trim() !== "") {
                                        let id2 = currentRecordID_;
                                        if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                                         id2 = cellInfo.data[""] || id2;
                                        }
                                        currentRecordIDValue.push(id2);
                                        currentRecordID.push("");
                                    }
                                    const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);

                                    try {
                                        const json = await saveFunction(dataJSON, idValsJSON);
                                        const dtError = json.data[json.data.length - 1] || [];
                                        if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                                            uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                                            InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("value", _initialStatusP7347CD0B4C364443AD716ADC3225C05C);
                                        } else {
                                            if (0 != 0 && 0 != null && 0 != "" && window.hpaSharedGridDataSources["0"]) {
                                                try {

                                                    let KeyRowTable = window.currentClicked_0;
                                                    console.log("KeyRowTable:", KeyRowTable);
                                                    if (KeyRowTable != null && KeyRowTable != undefined) {
                                                        var updateData = {};
                            updateData["0"] = KeyRowTable;
                                                        updateData["Status"] = InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("value");

                                                        // 2. Thực hiện update Shared Grid
                                                        // Vì dùng RowID, Grid sẽ tự tìm dòng cực nhanh
                                                        window.updateSharedGridRow("0", updateData);

                                                        // 3. Cập nhật biến DataSource cục bộ (Dùng RowID để tìm)
                           if (typeof DataSource !== "undefined" && Array.isArray(DataSource)) {
                                                            // Chỉ cần 1 dòng filter duy nhất, không cần check hasKey2 rườm rà nữa
                                                            var ds = DataSource.filter(item => item.RowID === KeyRowTable);

                                                            if (ds && ds.length > 0) {
                                                                ds[0]["Status"] = updateData["Status"];

                                                                // Nếu bạn đang sửa chính là 1 trong các ID cấu thành RowID
                                                                // Cần cập nhật lại RowID mới nếu cần thiết (tùy logic nghiệp vụ)
                                                            }
                                                        }
                                                    }

                                                    var updateData = {};
                                                    updateData["ID"] = currentRecordIDValue[0];
                                                    updateData["Status"] = InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("value");

                                                    var id2FieldName = "";
                                                    var hasKey2 = id2FieldName && id2FieldName !== "" && id2FieldName.indexOf("%") === -1;

                                                    if (hasKey2) {
                                                        if (currentRecordIDValue.length > 1 && currentRecordIDValue[1] !== undefined) {
                                                    updateData[id2FieldName] = currentRecordIDValue[1];
                                                        }
                                                    }

                                                    window.updateSharedGridRow("0", updateData);

                                                    if (typeof DataSource !== "undefined" && Array.isArray(DataSource)) {
                                                        var ds;
                                                        if (!hasKey2) {
                                                            ds = DataSource.filter(item => item["ID"] === updateData["ID"]);
                                                        } else {
                                                            ds = DataSource.filter(item =>
                                                                item["ID"] === updateData["ID"] &&
                                                                item[id2FieldName] === updateData[id2FieldName]
                                                            );
                                                        }

                                                        if (ds && ds.length > 0) {
                                                            ds[0]["Status"] = updateData["Status"];
                                                        }
                                                    }
                                                } catch (dsErr) {
      console.warn("[Grid Sync] SelectBox StatusP7347CD0B4C364443AD716ADC3225C05C: Không thể sync shared grid data source:", dsErr);
                                                }
                                            }

                                            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                                try {
                                                    const grid = cellInfo.component;
                                                    grid.cellValue(cellInfo.rowIndex, "Status", val);
                                                    grid.repaint();
               } catch (syncErr) {
                                                    console.warn("[Grid Sync] SelectBox StatusP7347CD0B4C364443AD716ADC3225C05C: Không thể sync grid:", syncErr);
                                                }
                                            }
                                            _initialStatusP7347CD0B4C364443AD716ADC3225C05C = val;
                                        }
                     } catch (err) {
                                        uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                                        InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("value", _initialStatusP7347CD0B4C364443AD716ADC3225C05C);
                                        console.error("SelectBox Save Error:", err);
                                    }
                                    return;
                                }

                                // Manual mode - no save, just callbacks and grid sync
                                if (typeof window["onSelectBoxChanged_Status"] === "function") {
                                    window["onSelectBoxChanged_Status"](e.value, InstanceStatusP7347CD0B4C364443AD716ADC3225C05C, e);
                                }

                                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                    try {
                                        const grid = cellInfo.component;
                                        grid.cellValue(cellInfo.rowIndex, "Status", e.value);
                                        grid.repaint();
                                    } catch (syncErr) {
                    console.warn("[Grid Sync] Không thể sync grid:", syncErr);
                                    }
                                }
                            }
                        }).dxSelectBox("instance");

                        let _initialStatusP7347CD0B4C364443AD716ADC3225C05C = InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("value");

                        if (StatusP7347CD0B4C364443AD716ADC3225C05CDataSourceSP && StatusP7347CD0B4C364443AD716ADC3225C05CDataSourceSP !== "") {
                            loadDataSourceCommon("Status", StatusP7347CD0B4C364443AD716ADC3225C05CDataSourceSP, function (data) {
                                StatusP7347CD0B4C364443AD716ADC3225C05CIsDataLoaded = true;

                                const idField = window["DataSourceIDField_Status"] || "ID";
                                const nameField = window["DataSourceNameField_Status"] || "Name";

                                InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("valueExpr", idField);
                                InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("displayExpr", nameField);

                                InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("dataSource", getDataSourceConfigStatusP7347CD0B4C364443AD716ADC3225C05C(data));
                                InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.repaint();
                            });
                        }

     // Set initial value
                        if (cellInfo.value !== undefined && cellInfo.value !== null && InstanceStatusP7347CD0B4C364443AD716ADC3225C05C) {
                            InstanceStatusP7347CD0B4C364443AD716ADC3225C05C.option("value", cellInfo.value);
                        }
                    },
                },

            ],
            onCellClick(e) {
                if (1 !== 1) return;

                // Nếu có multi select:
                // - Click vào detail column (_detailAction) thì mở detail
                // - Click vào checkbox column thì chỉ select
                // - Click vào columns khác thì không làm gì
                if (1 === 1) {
            if (e.column.dataField === "_detailAction") {
                        // Click vào detail button - mở detail
                        const rowDataObject = e.data;
                        const recordID = e.key ?? e.data?.["ID"];
                        if (!recordID) return;
                        window.currentClicked_GridPedingKC = recordID;
                        window.currentRecordID_ID = recordID;
                        openDetailID?.(rowDataObject);
                    }
                    return; // Không xử lý các column khác khi có multi select
                }

                const rowDataObject = e.data;

                const recordID = e.key ?? e.data?.["ID"];
                if (!recordID) return;
                window.currentClicked_GridPedingKC = recordID;
                window.currentRecordID_ID = recordID;
                openDetailID?.(rowDataObject);
            },
            onRowPrepared(e) {
                // Disable checkbox for rows where Status != 1
                if (e.rowType === "data" && isManager) {
                    const status = e.data.Status;
                    if (status != 1) {
                        // Disable checkbox for this row
                        const $checkbox = $(e.rowElement).find(".dx-select-checkbox");
                        $checkbox.dxCheckBox("instance")?.option("disabled", true);
                        $(e.rowElement).css("opacity", "0.6");
                    }
                }
            },
            onSelectionChanged(e) {
                // Show/hide bulk action buttons based on selection
                if (isManager) {
					 // Skip filtering if this is triggered by select all or deselect all
                    if (e.component._selectAllInProgress) {
                        return;
                    }

                    const selectedRows = e.selectedRowsData || [];

                    // Filter out rows where Status != 1
                    const validSelectedRows = selectedRows.filter(row => row.Status == 1);

                    // If user selected invalid rows, deselect them (avoid recursion)
                    if (validSelectedRows.length !== selectedRows.length && !e.component._isDeselecting) {
                        e.component._isDeselecting = true;
                        const validKeys = validSelectedRows.map(row => row.ID);
                        e.component.selectRows(validKeys, false);
                        setTimeout(() => {
                            e.component._isDeselecting = false;
                        }, 100);
                        return;
                    }

                    // Update header buttons instead of toolbar buttons
                    const bulkActionContainer = document.getElementById("bulkActionButtons");
                    const btnReject = document.getElementById("btnBulkRejectHeader");
                    const btnApprove = document.getElementById("btnBulkApproveHeader");

                    if (validSelectedRows.length > 0) {
                        if (bulkActionContainer) bulkActionContainer.style.display = "flex";
                        if (btnReject) btnReject.style.display = "inline-block";
                  if (btnApprove) btnApprove.style.display = "inline-block";
                    } else {
                        if (bulkActionContainer) bulkActionContainer.style.display = "none";
                        if (btnReject) btnReject.style.display = "none";
                        if (btnApprove) btnApprove.style.display = "none";
                    }
                }
            },
             onSelectAllValueChanged(e) {
                // Handle select all checkbox behavior
                if (isManager) {
                    e.component._selectAllInProgress = true;

                    if (e.value === true) {
                        // When select all is checked, only select rows with Status = 1
                        const dataSource = e.component.getDataSource();
                        const allData = dataSource.items();
                        const validKeys = allData.filter(row => row.Status == 1).map(row => row.ID);

                        setTimeout(() => {
                            e.component.selectRows(validKeys, false);
                            setTimeout(() => {
                                e.component._selectAllInProgress = false;
                            }, 50);
                        }, 0);
                    } else {
                        // When deselect all, clear all selections
                        setTimeout(() => {
                            e.component.deselectAll();
                            setTimeout(() => {
                                e.component._selectAllInProgress = false;
                            }, 50);
                        }, 0);
                    }
                }
            }
            ,
            onOptionChanged(e) {
                // Persist column chooser changes (visibility/order/width)
                if (e.fullName && e.fullName.startsWith("columns[")) {
                    const timers = chooser.saveTimers;
                    if (timers[gridName]) {
                        clearTimeout(timers[gridName]);
                    }
                    timers[gridName] = setTimeout(function () {
                        chooser.save(InstanceGridPedingKCP7347CD0B4C364443AD716ADC3225C05C, gridName);
                    }, 400);
                }
            }

        }).dxDataGrid("instance");

        // Load saved column chooser settings after grid init
        chooser.load(InstanceGridPedingKCP7347CD0B4C364443AD716ADC3225C05C, gridName);

        // Shared grid data source registry so detail forms can trigger refreshes
        window.hpaSharedGridDataSources = window.hpaSharedGridDataSources || {};

        if (!window.reloadSharedGridDataSource) {
            window.reloadSharedGridDataSource = function (name, params) {
                const registry = window.hpaSharedGridDataSources || {};
                const entry = registry[name];
                if (!entry || typeof entry.reload !== "function") {
                    console.warn("[SharedGrid] Grid", name, "is not registered");
                    return Promise.resolve([]);
                }
                return entry.reload(params);
            };
        }

        if (!window.getSharedGridDataSource) {
            window.getSharedGridDataSource = function (name) {
                const registry = window.hpaSharedGridDataSources || {};
                return registry[name];
            };
        }

        if (!window.updateSharedGridRow) {
            window.updateSharedGridRow = function (name, rowData, options) {
                const registry = window.hpaSharedGridDataSources || {};
                const entry = registry[name];
                if (!entry || typeof entry.applyRowChanges !== "function") {
                    console.warn("[SharedGrid] Grid", name, "cannot accept row updates");
                    return Promise.resolve(false);
                }
                return entry.applyRowChanges(rowData, options);
            };
        }

        if (!window.removeSharedGridRow) {
            window.removeSharedGridRow = function (name, options) {
                const registry = window.hpaSharedGridDataSources || {};
                const entry = registry[name];
                if (!entry || typeof entry.removeRow !== "function") {
                    console.warn("[SharedGrid] Grid", name, "cannot remove rows");
                    return Promise.resolve(false);
                }
                return entry.removeRow(options);
            };
        }

        (function setupSharedGridSource() {
            const sharedKey = gridName;
            const primaryKeyField = "ID";

            const loginValue = typeof window.UserID !== "undefined"
                ? window.UserID
                : (typeof LoginID !== "undefined" ? LoginID : null);
            const languageValue = typeof window.LanguageID !== "undefined"
                ? window.LanguageID
                : (typeof LanguageID !== "undefined" ? LanguageID : null);

            const snapshotGridData = function (instance) {
                if (!instance) return [];
                try {
                    if (typeof instance.getDataSource === "function") {
                        const ds = instance.getDataSource();
                        if (ds && typeof ds.items === "function") {
                            const dsItems = ds.items();
                            if (Array.isArray(dsItems)) {
                                return dsItems.map(function (item) {
                                    return item && typeof item === "object" ? Object.assign({}, item) : item;
                                });
                            }
                        }
             }

                    if (typeof instance.option === "function") {
                        const rawData = instance.option("dataSource");
                        if (Array.isArray(rawData)) {
                            return rawData.map(function (item) {
                                return item && typeof item === "object" ? Object.assign({}, item) : item;
                            });
                        }
                    }
                } catch (snapshotErr) {
                    console.warn("[SharedGrid] Unable to snapshot grid data", snapshotErr);
                }
                return [];
            };

            let sharedEntry = window.hpaSharedGridDataSources[sharedKey];
            if (!sharedEntry) {
                sharedEntry = {
                    data: [],
                    subscribers: [],
                    loading: false
                };
            }

            sharedEntry.primaryKey = sharedEntry.primaryKey || primaryKeyField;
            sharedEntry.data = Array.isArray(sharedEntry.data) ? sharedEntry.data : [];
            sharedEntry.subscribers = Array.isArray(sharedEntry.subscribers) ? sharedEntry.subscribers : [];

            sharedEntry.loading = !!sharedEntry.loading;

            if (typeof sharedEntry.normalizeParams !== "function") {
                sharedEntry.normalizeParams = function (customParams) {
                    const base = [];
                    if (loginValue !== null && loginValue !== undefined) {
                        base.push("LoginID", loginValue);
                    }
                    if (languageValue !== null && languageValue !== undefined) {
                        base.push("LanguageID", languageValue);
                    }

                    if (Array.isArray(customParams) && customParams.length > 0) {
                        return base.concat(customParams);
                    }

                    if (customParams && typeof customParams === "object") {
                        const extras = [];
                        Object.keys(customParams).forEach(function (key) {
                            extras.push(key, customParams[key]);
                        });
                        return base.concat(extras);
                    }

                    return base;
                };
            }

            if (typeof sharedEntry.notify !== "function") {
                sharedEntry.notify = function () {
                    this.subscribers.forEach(function (callback) {
                        try {
                            callback(this.data);
                        } catch (err) {
                            console.error("[SharedGrid] subscriber error", err);
                        }
                    }, this);
                };
            }

            if (typeof sharedEntry.subscribe !== "function") {
                sharedEntry.subscribe = function (callback) {
                    if (typeof callback === "function") {
                        this.subscribers.push(callback);
                    }
                    return () => {
                        this.subscribers = this.subscribers.filter(function (fn) {
                            return fn !== callback;
     });
                    };
                };
            }

            if (typeof sharedEntry.applyRowChanges !== "function") {
                sharedEntry.applyRowChanges = function (rowData, options) {
                    const opts = options || {};
                    const keyField = this.primaryKey;
                    let keyValue = opts.key;
                    if ((keyValue === undefined || keyValue === null) && rowData && rowData[keyField] !== undefined) {
                        keyValue = rowData[keyField];
                    }

                    if (keyValue === undefined || keyValue === null) {
                        console.warn("[SharedGrid] Missing key when applying row changes for", sharedKey);
                        return Promise.resolve(false);
                    }

                    if (typeof this.ensureLocalData === "function") {
                        this.ensureLocalData();
                    }

                    const compare = opts.strict === true
                        ? function (candidate) { return candidate === keyValue; }
                        : function (candidate) {
                            if (candidate === undefined || candidate === null) return candidate === keyValue;
                            if (keyValue === undefined || keyValue === null) return false;
                            return String(candidate) === String(keyValue);
                        };

                    const nextData = Array.isArray(this.data) ? this.data.slice() : [];
                    let targetIndex = nextData.findIndex(function (item) {
                        return item ? compare(item[keyField]) : false;
                    });

                    const normalizedRow = Object.assign({}, targetIndex > -1 ? nextData[targetIndex] : {}, rowData);

                    if (targetIndex === -1) {
                        if (opts.ignoreMissing === true) {
                            return Promise.resolve(false);
                        }
                        if (opts.append === true) {
                            nextData.push(normalizedRow);
                            targetIndex = nextData.length - 1;
                        } else {
                            nextData.unshift(normalizedRow);
                            targetIndex = 0;
                        }
                    } else {
                        nextData[targetIndex] = normalizedRow;
                    }

                    this.data = nextData;
                    try {
                        if (this.instance && typeof this.instance.option === "function") {
                            this.instance.option("dataSource", nextData);
           this.instance.refresh();
                        }
                    } catch (applyErr) {
                        console.warn("[SharedGrid] Unable to push row update", applyErr);
                    }
                    this.notify();
                    return Promise.resolve({ index: targetIndex, data: normalizedRow });
                };
            }

            if (typeof sharedEntry.removeRow !== "function") {
                sharedEntry.removeRow = function (options) {
                    const opts = options || {};
                    const keyField = this.primaryKey;
                    const keyValue = opts.key;

                    if (keyValue === undefined || keyValue === null) {
                        console.warn("[SharedGrid] Missing key when removing row for", sharedKey);
                        return Promise.resolve(false);
                    }

                    if (typeof this.ensureLocalData === "function") {
                        this.ensureLocalData();
                    }

                    const filtered = (Array.isArray(this.data) ? this.data : []).filter(function (item) {
                        if (!item) return true;
                        const candidate = item[keyField];
                        if (opts.strict === true) {
                            return candidate !== keyValue;
                        }
                        if (candidate === undefined || candidate === null) {
                            return keyValue !== candidate;
                        }
                        return String(candidate) !== String(keyValue);
                    });

                    if (filtered.length === (Array.isArray(this.data) ? this.data.length : 0)) {
                        return Promise.resolve(false);
                    }

                    this.data = filtered;
     try {
                        if (this.instance && typeof this.instance.option === "function") {
                            this.instance.option("dataSource", filtered);
                            this.instance.refresh();
                        }
                    } catch (removeErr) {
                        console.warn("[SharedGrid] Unable to remove row", removeErr);
                    }
                    this.notify();
                    return Promise.resolve(true);
                };
            }

            sharedEntry.instance = InstanceGridPedingKCP7347CD0B4C364443AD716ADC3225C05C;

            if (typeof sharedEntry.ensureLocalData !== "function") {
                sharedEntry.ensureLocalData = function () {
                    if (Array.isArray(this.data) && this.data.length > 0) {
                        return;
                    }
                    const snapshot = snapshotGridData(this.instance);
                    if (snapshot.length > 0) {
                        this.data = snapshot;
                    }
                };
            }

            const currentSnapshot = snapshotGridData(sharedEntry.instance);
            if (currentSnapshot.length > 0) {
                sharedEntry.data = currentSnapshot;
            }

            sharedEntry.getData = function () {
                return this.data;
            };

            window.hpaSharedGridDataSources[sharedKey] = sharedEntry;
        })();

        //========================= end Grid Pending KCP7347CD0B4C364443AD716ADC3225C05C =========================

        '
            + (select loadUI from tblCommonControlType_Signed where UID = 'P7235EDC20B924BC6AEEA0606CA3905B0')
        +(select loadUI from tblCommonControlType_Signed where UID = 'P2CA05CCD700E4FB8A62C1D1108A6C237')
        +(select loadUI from tblCommonControlType_Signed where UID = 'PD6C7ED44D4104996A84FD935D2111307')
        +(select loadUI from tblCommonControlType_Signed where UID = 'P1F778863ED7C41D08712A761CE9D64E3')
+(select loadUI from tblCommonControlType_Signed where UID = 'PC0A728C3C79D4DB2B7004946CF08BF43')
        +(select loadUI from tblCommonControlType_Signed where UID = 'P62444692C8CA4B92BF2D21E81DDB743C')
        +(select loadUI from tblCommonControlType_Signed where UID = 'PC3B74A7F9CB54913BBF84EA8D1BB8ECF')
        +(select loadUI from tblCommonControlType_Signed where UID = 'PFD5D2756B322419EB79C8869BC0727C0')
        +(select loadUI from tblCommonControlType_Signed where UID = 'P545B25A8C4F048D39964AA798B0CE115')
        +(select loadUI from tblCommonControlType_Signed where UID = 'PEEF7B29B28754A088C4DB26DB2C70411')
        +(select loadUI from tblCommonControlType_Signed where UID = 'P88755B14CC254990A88CFB4F671A691E')
        +(select loadUI from tblCommonControlType_Signed where UID = 'P4EC2172540704139A0E5FA01A7142944')
        +(select loadUI from tblCommonControlType_Signed where UID = 'PC7C2C11BA1DD4EC3AFF6D836B67994A0')
        +(select loadUI from tblCommonControlType_Signed where UID = 'P951B39C3CDA443E8B6757A85F3310863')
        +N'

        // Configure grid toolbar with filter and action buttons
        function configurePendingGridToolbar() {
            // Nếu toolbar đã được tạo rồi thì không tạo lại
            if (isToolbarConfigured) return;

            const gridInstance = InstanceGridPedingKCP7347CD0B4C364443AD716ADC3225C05C;
            if (!gridInstance) return;

            gridInstance.option("toolbar", {
                items: [
                    {
                        location: "before",
                        template: function (data, index, element) {
                            const $container = $(''<div class="pending-toolbar-container" style="display: contents;">'' );

                            let $employeeDiv;
                            // Employee filter - only if isManager
                            if (isManager) {
                                $employeeDiv = $(''<div class="pending-toolbar-item" style="display: inline-flex; align-items: center; gap: 5px; flex-shrink: 0;">'' );
                                $employeeDiv.append(''<label style="font-size: 11px; color: #64748b; white-space: nowrap; flex-shrink: 0;">Nhân viên:</label>'');
                                $employeeDiv.append($(''<div id="pendingFilterEmployeeToolbar" style="width: 160px; min-width: 140px; flex-shrink: 0;"></div>''));
                            }

                            // From Date
                            const $fromDiv = $(''<div class="pending-toolbar-item" style="display: inline-flex; align-items: center; gap: 5px; flex-shrink: 0;">'' );
                            $fromDiv.append(''<label style="font-size: 11px; color: #64748b; white-space: nowrap; flex-shrink: 0;">Từ:</label>'');
                            $fromDiv.append(''<input type="date" id="pendingFilterFromDateToolbar" style="padding: 4px 6px; border: 1px solid #ccc; border-radius: 4px; font-size: 12px; width: 125px; flex-shrink: 0;">'');

                            // To Date
                            const $toDiv = $(''<div class="pending-toolbar-item" style="display: inline-flex; align-items: center; gap: 5px; flex-shrink: 0;">'' );
                            $toDiv.append(''<label style="font-size: 11px; color: #64748b; white-space: nowrap; flex-shrink: 0;">Đến:</label>'');
                            $toDiv.append(''<input type="date" id="pendingFilterToDateToolbar" style="padding: 4px 6px; border: 1px solid #ccc; border-radius: 4px; font-size: 12px; width: 125px; flex-shrink: 0;">'');

                            // Status filter
                            const $statusDiv = $(''<div class="pending-toolbar-item" style="display: inline-flex; align-items: center; gap: 5px; flex-shrink: 0;">'' );
                            $statusDiv.append(''<label style="font-size: 11px; color: #64748b; white-space: nowrap; flex-shrink: 0;">Trạng thái:</label>'');
                            $statusDiv.append($(''<select id="pendingFilterStatusToolbar" style="padding: 4px 6px; border: 1px solid #ccc; border-radius: 4px; font-size: 12px; height: 28px; flex-shrink: 0;">'' +
                                ''<option value="0">Tất cả</option>'' +
                                ''<option value="1">Đang chờ</option>'' +
                                ''<option value="2">Duyệt</option>'' +
                                ''<option value="3">Từ chối</option>'' +
                                ''<option value="6">Bị trùng data</option>'' + 
                            ''</select>''));                      
                            const $filterBtn = $(''<button class="pending-toolbar-btn" style="padding: 6px 12px; background: #198754; color: white; border: none; border-radius: 4px; font-size: 12px; cursor: pointer; flex-shrink: 0; white-space: nowrap;"><i class="bi bi-filter"></i> Tìm kiếm</button>'');
                            $filterBtn.on(''click'', function () { ReloadData(); });

                            // Reset button
                            const $resetBtn = $(''<button class="pending-toolbar-btn" style="padding: 6px 12px; background: transparent; color: #198754; border: 1px solid #198754; border-radius: 4px; font-size: 12px; cursor: pointer; margin-left: 5px; flex-shrink: 0; white-space: nowrap;"><i class="bi bi-arrow-clockwise"></i> Làm mới</button>'');
                            $resetBtn.on(''click'', function () { setDefaultDates(); ReloadData(); });

                            $container.append($employeeDiv, $fromDiv, $toDiv, $statusDiv, $filterBtn, $resetBtn);
                            $(element).append($container);

                            setTimeout(() => {
                                $("#pendingFilterStatusToolbar").val("1");
                                const origFromDate = document.getElementById("pendingFilterFromDate")?.value;
                                const origToDate = document.getElementById("pendingFilterToDate")?.value;
                                if (origFromDate) document.getElementById("pendingFilterFromDateToolbar").value = origFromDate;
                                if (origToDate) document.getElementById("pendingFilterToDateToolbar").value = origToDate;
                                attachEmployeeFilterToToolbar();
                            }, 50);
                            setTimeout(attachEmployeeFilterToToolbar, 200);
                            setTimeout(attachEmployeeFilterToToolbar, 600);
                        }
                    },
                    {
                        name: "columnChooserButton",
                        locateInMenu: "auto"
                    },
                    {
                        name: "searchPanel",
                        locateInMenu: "never"
                    }
                ]
            });

            // Configure selection mode based on manager status
            if (isManager) {
                gridInstance.option("selection.mode", "multiple");
                gridInstance.option("selection.showCheckBoxesMode", "always");
                gridInstance.option("selection.selectAllMode", "page");
                gridInstance.option("selection.allowSelectAll", true);
            } else {
                gridInstance.option("selection.mode", "single");
                gridInstance.option("selection.showCheckBoxesMode", "none");
            }

            // Đánh dấu toolbar đã được tạo
            isToolbarConfigured = true;
        }

        // Set chiều dài cố định theo Pixel
        // InstanceFullNameP951B39C3CDA443E8B6757A85F3310863.element().css("width", "100px");
        // InstanceFullNameP951B39C3CDA443E8B6757A85F3310863.element().css("height", "28px");
        // InstanceFullNameP951B39C3CDA443E8B6757A85F3310863.element().find(".dx-texteditor-input").css("height", "20px");
        // InstanceFullNameP951B39C3CDA443E8B6757A85F3310863.element().find(".dx-texteditor-container").css("height", "28px");

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

        // Load DataSource: sp_CRM_getCompanySize
        if ("sp_CRM_getCompanySize" && "sp_CRM_getCompanySize".trim() !== "") {
            loadDataSourceCommon("companySize", "sp_CRM_getCompanySize", function (data) {
                // Data được shared qua callback
            });
        }

        // Load DataSource: sp_CRM_getIndustry
        if ("sp_CRM_getIndustry" && "sp_CRM_getIndustry".trim() !== "") {
            loadDataSourceCommon("industry", "sp_CRM_getIndustry", function (data) {
                // Data được shared qua callback
            });
        }

        // Load DataSource: sp_CRM_getPositionCus
        if ("sp_CRM_getPositionCus" && "sp_CRM_getPositionCus".trim() !== "") {
            loadDataSourceCommon("PositionID", "sp_CRM_getPositionCus", function (data) {
                // Data được shared qua callback
            });
        }

        // Load DataSource: sp_CRM_ImportPendingApprove
        if ("sp_CRM_ImportPendingApprove" && "sp_CRM_ImportPendingApprove".trim() !== "") {
            loadDataSourceCommon("Status", "sp_CRM_ImportPendingApprove", function (data) {
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

                        if(dataSourceKey == ''DataSource_Status''){
                            // chưa có id 6 thêm vào
                            if(!window[dataSourceKey].some(item => item.ID === 6)){
                                window[dataSourceKey].push({ ID: 6, Name: window.LanguageID == "VN" ? "Bị trùng data" : "Duplicate data" });
                            }
                        }

                        if (InstancecompanySizePD6C7ED44D4104996A84FD935D2111307.getDataSource().items().length == 0 && window["DataSource_companySize"].length > 0) { InstancecompanySizePD6C7ED44D4104996A84FD935D2111307.option("dataSource", window["DataSource_companySize"]); }
                        if (InstanceindustryP1F778863ED7C41D08712A761CE9D64E3.getDataSource().items().length == 0 && window["DataSource_industry"].length > 0) { InstanceindustryP1F778863ED7C41D08712A761CE9D64E3.option("dataSource", window["DataSource_industry"]); }
                        if (InstancePositionIDP88755B14CC254990A88CFB4F671A691E.getDataSource().items().length == 0 && window["DataSource_PositionID"].length > 0) { InstancePositionIDP88755B14CC254990A88CFB4F671A691E.option("dataSource", window["DataSource_PositionID"]); }

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

        window.currentRecordID_taxCode = null;

        function ReloadData(fromDate = null, toDate = null, status = null) {
            // Nếu không truyền tham số, lấy từ input filter (ưu tiên toolbar)
            if (!fromDate) {
                fromDate = document.getElementById("pendingFilterFromDateToolbar")?.value || document.getElementById("pendingFilterFromDate")?.value || "";
            }
            if (!toDate) {
                toDate = document.getElementById("pendingFilterToDateToolbar")?.value || document.getElementById("pendingFilterToDate")?.value || "";
            }
            if (status === null) {
                status = document.getElementById("pendingFilterStatusToolbar")?.value || document.getElementById("pendingFilterStatus")?.value || "0";
            }

            AjaxHPAParadise({
                data: {
                    name: "sp_CRM_KpiPedingLoadData",
                    param: ["LoginID", window.UserID, "EmployeeIDs", InstanceFullNameP951B39C3CDA443E8B6757A85F3310863.getValueAsString(), "FromDate", fromDate, "ToDate", toDate, "Status", status]
                },
                success: function (res) {
                    const json = typeof res === "string" ? JSON.parse(res) : res;
                    const results = Array.isArray(json?.data?.[0])
    ? json.data[0]
                        : (json?.data?.[0] ? [json.data[0]] : []);

                    const obj = results.length === 1 ? results[0] : (results[0] || null);


                    // X? lý cho grid layout
                    const gridInstance = InstanceGridPedingKCP7347CD0B4C364443AD716ADC3225C05C;
                    const gridConfig = window.getGridConfig_GridPedingKC(results);

                    gridInstance.beginUpdate();

                    gridInstance.option("scrolling", {
                        mode: "standard",
                        showScrollbar: "onHover"
                    });

                    gridInstance.option("remoteOperations", false);  // Client-side cho <= 1000

                    // Set paging config
                    gridInstance.option("paging.enabled", true);
                    gridInstance.option("paging.pageSize", gridConfig.pageSize);
                    gridInstance.option("pager.allowedPageSizes", gridConfig.allowedPageSizes);
                    gridInstance.pageIndex(0);

                    gridInstance.option("dataSource", results);

                    gridInstance.endUpdate();

                    if (obj) { window.currentRecordID_taxCode = (obj.taxCode !== undefined && obj.taxCode !== null) ? obj.taxCode : window.currentRecordID_taxCode; }
                    DataSource = results;
                    '
                        + (select loadData from tblCommonControlType_Signed where UID = 'P7347CD0B4C364443AD716ADC3225C05C')
                + (select loadData from tblCommonControlType_Signed where UID = 'P7235EDC20B924BC6AEEA0606CA3905B0')
            +(select loadData from tblCommonControlType_Signed where UID = 'P2CA05CCD700E4FB8A62C1D1108A6C237')
            +(select loadData from tblCommonControlType_Signed where UID = 'PD6C7ED44D4104996A84FD935D2111307')
            +(select loadData from tblCommonControlType_Signed where UID = 'P1F778863ED7C41D08712A761CE9D64E3')
            +(select loadData from tblCommonControlType_Signed where UID = 'PC0A728C3C79D4DB2B7004946CF08BF43')
            +(select loadData from tblCommonControlType_Signed where UID = 'P62444692C8CA4B92BF2D21E81DDB743C')
            +(select loadData from tblCommonControlType_Signed where UID = 'PC3B74A7F9CB54913BBF84EA8D1BB8ECF')
            +(select loadData from tblCommonControlType_Signed where UID = 'PFD5D2756B322419EB79C8869BC0727C0')
            +(select loadData from tblCommonControlType_Signed where UID = 'P545B25A8C4F048D39964AA798B0CE115')
            +(select loadData from tblCommonControlType_Signed where UID = 'PEEF7B29B28754A088C4DB26DB2C70411')
            +(select loadData from tblCommonControlType_Signed where UID = 'P88755B14CC254990A88CFB4F671A691E')
            +(select loadData from tblCommonControlType_Signed where UID = 'P4EC2172540704139A0E5FA01A7142944')
   +(select loadData from tblCommonControlType_Signed where UID = 'PC7C2C11BA1DD4EC3AFF6D836B67994A0')
            +N'
        }
    })
            }

    // Load permission first, then initialize
    (async function init() {
        await loadPermission();
        ReloadData(null,null,"1"); // Mặc định load trạng thái đang chờ

        // Bind event handlers to header buttons
        if (isManager) {
            const btnRejectHeader = document.getElementById("btnBulkRejectHeader");
            const btnApproveHeader = document.getElementById("btnBulkApproveHeader");

            if (btnRejectHeader) {
                btnRejectHeader.addEventListener(''click'', handleBulkReject);
            }
            if (btnApproveHeader) {
                btnApproveHeader.addEventListener(''click'', handleBulkApprove);
            }
        }
    })();

    // Set default dates (today and 30 days ago)
    function setDefaultDates() {
        const today = new Date();
        const thirtyDaysAgo = new Date(today.getTime() - (30 * 24 * 60 * 60 * 1000));

        const formatDate = (date) => {
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, ''0'');
            const day = String(date.getDate()).padStart(2, ''0'');
            return `${year}-${month}-${day}`;
        };

        document.getElementById("pendingFilterFromDate").value = formatDate(thirtyDaysAgo);
        document.getElementById("pendingFilterToDate").value = formatDate(today);
    }
    setDefaultDates();

    // Configure toolbar ngay sau khi ReloadData gọi xong
    setTimeout(() => {
        configurePendingGridToolbar();
        attachEmployeeFilterToToolbar();
    }, 500);

    // Event listeners for filter buttons
    document.getElementById("btnPendingFilter")?.addEventListener("click", function () {
        ReloadData();
    });

    document.getElementById("btnPendingReset")?.addEventListener("click", function () {
        setDefaultDates();
        ReloadData();
    });

    // Global function to open detail popup
    function openDetailID(obj) {
        if (!obj) {
            console.warn("No data provided to openDetailID");
            return;
        }

        // Update modal title
        const modalTitle = document.getElementById("pendingModalTitle");
        if (modalTitle) {
            modalTitle.textContent = "Chi tiết dữ liệu";
        }

        loadStatus(obj.Status);

        // Load data into form controls
        '
            + (select loadData from tblCommonControlType_Signed where UID = 'P7235EDC20B924BC6AEEA0606CA3905B0')
        +(select loadData from tblCommonControlType_Signed where UID = 'P2CA05CCD700E4FB8A62C1D1108A6C237')
        +(select loadData from tblCommonControlType_Signed where UID = 'PD6C7ED44D4104996A84FD935D2111307')
        +(select loadData from tblCommonControlType_Signed where UID = 'P1F778863ED7C41D08712A761CE9D64E3')
        +(select loadData from tblCommonControlType_Signed where UID = 'PC0A728C3C79D4DB2B7004946CF08BF43')
        +(select loadData from tblCommonControlType_Signed where UID = 'P62444692C8CA4B92BF2D21E81DDB743C')
        +(select loadData from tblCommonControlType_Signed where UID = 'PC3B74A7F9CB54913BBF84EA8D1BB8ECF')
        +(select loadData from tblCommonControlType_Signed where UID = 'PFD5D2756B322419EB79C8869BC0727C0')
        +(select loadData from tblCommonControlType_Signed where UID = 'P545B25A8C4F048D39964AA798B0CE115')
        +(select loadData from tblCommonControlType_Signed where UID = 'PEEF7B29B28754A088C4DB26DB2C70411')
        +(select loadData from tblCommonControlType_Signed where UID = 'P4EC2172540704139A0E5FA01A7142944')
        +(select loadData from tblCommonControlType_Signed where UID = 'PC7C2C11BA1DD4EC3AFF6D836B67994A0')
        +N'

        window.currentID = obj.ID;

        // Show/hide reject and approve buttons based on isManager
        const btnReject = document.getElementById("btnRejectPending");
        const btnApprove = document.getElementById("btnSavePending");

        if (isManager && obj.Status && obj.Status == 1) {
            if (btnReject) btnReject.style.display = "block";
            if (btnApprove) btnApprove.style.display = "block";
        } else {
            if (btnReject) btnReject.style.display = "none";
            if (btnApprove) btnApprove.style.display = "none";
        }

        // Open modal
        const pendingModal = document.getElementById("pendingModal");
        if (pendingModal) {
            if (typeof bootstrap !== ''undefined'' && bootstrap.Modal) {
                const modal = new bootstrap.Modal(pendingModal);
                modal.show();
            } else {
                pendingModal.classList.add(''show'');
                pendingModal.style.display = ''block'';
                document.body.classList.add(''modal-open'');
            }
        }
    };

    function loadStatus(StatusID) {
        const statusText = window.DataSource_Status[StatusID].Name || "Không xác định";

        let bootstrapClass = "";
        let icon = "";
        let statusID = StatusID || 0;
        // chờ duyệt = Vàng
        if (statusID == 1) {
            bootstrapClass = "bg-warning";
            icon = "bi-clock-history";
        }
        // Hoàn thành = Xanh lá
        else if (statusID == 2) {
            bootstrapClass = "bg-success";
            icon = "bi-check-circle-fill";
        }
        // Hủy = Đỏ
        else if (statusID == 3) {
            bootstrapClass = "bg-danger";
            icon = "bi-x-circle-fill";
        }
        else {
            bootstrapClass = "bg-secondary";
            icon = "bi-circle";
        }

        const $badge = $("<div>")
            .addClass("badge-view " + bootstrapClass)
            .html(`<i class="bi ${icon} me-1"></i>${statusText}`);

        $(".statusForm").html("");
        $(".statusForm").append($badge);
    }


    // Event listener for Reject button
    document.getElementById("btnRejectPending")?.addEventListener("click", function () {
        // Mở modal nhập lý do từ chối
        showConfirmPopup({
            title: "Xác nhận từ chối?",
            message: "Bạn có chắc chắn muốn từ chối dữ liệu này?",
            YesText: "Từ chối",
            NoText: "Hủy",

            onYes: () => {
                const rejectModal = new bootstrap.Modal(document.getElementById("rejectReasonModal"));
                rejectModal.show();
            },
            onCancel: () => {

            }
        });
    });

    // Event listener for Confirm Reject button
    document.getElementById("btnConfirmReject")?.addEventListener("click", function () {
        const currentRecord = window.currentID;
        const rejectReason = document.getElementById("rejectReason").value;

        // Gọi API để từ chối
        if (currentRecord) {
            AjaxHPAParadise({
                data: {
                    name: "sp_CRM_KpiPedingReject",
                    param: ["ID", currentRecord, "Notes", rejectReason]
                },
                success: function (data) {
                    try {
                        if (typeof data == "string" && !IsNullOrEmpty(data)) {
                            data = data.includes("{") ? data : EncryptionStringDecryption(data);
                        }
                        loadStatus(3);
                        // Đóng modal nhập lý do
                        const rejectModal = bootstrap.Modal.getInstance(document.getElementById("rejectReasonModal"));
                        if (rejectModal) rejectModal.hide();
                        // Đóng modal chi tiết
                        //const modal = bootstrap.Modal.getInstance(document.getElementById("pendingModal"));
                        //if (modal) modal.hide();
                        // Xóa nội dung input
                        document.getElementById("rejectReason").value = "";
                        // Reload dữ liệu
                        uiManager.showAlert({ type: "success", message: "%RejectSuccessful%" });
                        ReloadData();
                    } catch (error) {
                        uiManager.showAlert({ type: "error", message: "Từ chối thất bại!" });
                    }
                },
                error: function (err) {
                    console.error("Lỗi khi từ chối:", err);
                    alert("Có lỗi khi từ chối bản ghi");
                }
            });
        }
    });

    // Event listener for Accept (Đồng ý) button
    document.getElementById("btnSavePending")?.addEventListener("click", function () {
        const currentRecord = window.currentID;
        showConfirmPopup({
            title: "Xác nhận duyệt?",
            message: "Bạn có chắc chắn duyệt dữ liệu này?",
            YesText: "Duyệt",
            NoText: "Hủy",

            onYes: () => {
                // Gọi API để đồng ý
                if (currentRecord) {
                    AjaxHPAParadise({
                        data: {
                            name: "sp_CRM_KpiPedingApprove",
                            param: ["IDs", currentRecord]
                        },
                        success: function (data) {
                            if (typeof data == "string" && !IsNullOrEmpty(data)) {
                                data = data.includes("{") ? data : EncryptionStringDecryption(data);
                            }
                            let dataObject = JSON.parse(data);
                            let newData = dataObject.data[0];
                            let ErrorData = dataObject.data[1];
                            if (newData.length > 0) {
                                let newRecord = newData[0].NewCompanyID;
                                if (newRecord) {
                                    loadStatus(2);
                                    uiManager.showAlert({ type: "success", message: "%sp_resignationletter_register_approvesuccessful%" });
                                    ReloadData();

                                } else if(ErrorData && ErrorData.length > 0){                                    
                                    let content = ''<div style="max-height: 400px; overflow-y: auto;"><table class="table table-bordered"><thead><tr><th>Mã số thuế</th><th>Số điện thoại</th><th>Lỗi</th></tr></thead><tbody>'';
                                    ErrorData.forEach(errItem => {
                                        content += `<tr><td>${errItem.TaxCode || ''''}</td><td style="word-break: break-word;">${errItem.NumberPhone || ''''}</td><td>bị trùng với người khác</td></tr>`;
                                    });
                                    content += ''</tbody></table></div>'';
                                    showPopupNotify("Thông báo", content, "OK", "50vw");
                                    ReloadData();
                                } else {
                                    uiManager.showAlert({ type: "error", message: "%MSG_FAIL_VN%" });
                                }
                            }

                        },
                        error: function (err) {
              console.error("Lỗi khi đồng ý:", err);
                            alert("Có lỗi khi đồng ý bản ghi");
                        }
                    });
                }
            },
            onCancel: () => {

            }
        });
    });

    // Bulk Reject handler
    function handleBulkReject() {
        if (!isManager) {
            uiManager.showAlert({ type: "warning", message: "%NoPermission%" });
            return;
        }

        const gridInstance = InstanceGridPedingKCP7347CD0B4C364443AD716ADC3225C05C;
        const selectedRows = gridInstance.getSelectedRowsData();

        if (selectedRows.length === 0) {
            uiManager.showAlert({ type: "warning", message: "%SelectAtLeastOneRecord%" });
            return;
        }

        showConfirmPopup({
            title: "Xác nhận từ chối?",
            message: `Bạn có chắc chắn muốn từ chối ${selectedRows.length} bản ghi được chọn?`,
            YesText: "Từ chối",
            NoText: "Hủy",
            onYes: () => {
                const rejectModal = new bootstrap.Modal(document.getElementById("rejectReasonModal"));
                window.bulkRejectData = selectedRows;
                rejectModal.show();
            }
        });
    }

    // Bulk Approve handler
 function handleBulkApprove() {
        if (!isManager) {
            uiManager.showAlert({ type: "warning", message: "%NoPermission%" });
            return;
        }

        const gridInstance = InstanceGridPedingKCP7347CD0B4C364443AD716ADC3225C05C;
        const selectedRows = gridInstance.getSelectedRowsData();

        if (selectedRows.length === 0) {
            uiManager.showAlert({ type: "warning", message: "%SelectAtLeastOneRecord%" });
            return;
        }

        showConfirmPopup({
            title: "Xác nhận duyệt?",
       message: `Bạn có chắc chắn duyệt ${selectedRows.length} bản ghi được chọn?`,
            YesText: "Duyệt",
            NoText: "Hủy",
            onYes: () => {
                // Collect all IDs as comma-separated string
                const ids = selectedRows.map(row => row.ID).join(",");
                console.log(ids)
                AjaxHPAParadise({
                    data: {
                        name: "sp_CRM_KpiPedingApprove",
                        param: ["IDs", ids]
                    },
                    success: function (data) {
                        if (typeof data == "string" && !IsNullOrEmpty(data)) {
                            data = data.includes("{") ? data : EncryptionStringDecryption(data);
                        }
                        let dataObject = JSON.parse(data);
                        let newData = dataObject.data[0];
                        let ErrorData = dataObject.data[1];
                        if (newData && newData.length > 0) {
                            let successCount = newData[0].ProcessedCount || 0;
                            uiManager.showAlert({ type: "success", message: `Duyệt thành công ${successCount} bản ghi!` });
                            if (successCount > 0 || ErrorData.length > 0) {
                                ReloadData();
                            }
                            const gridInstance = InstanceGridPedingKCP7347CD0B4C364443AD716ADC3225C05C;
                            gridInstance.clearSelection();
                            if (ErrorData && ErrorData.length > 0) {
                                let content = ''<div style="max-height: 400px; overflow-y: auto;"><table class="table table-bordered"><thead><tr><th>Mã số thuế</th><th>Số điện thoại</th><th>Lỗi</th></tr></thead><tbody>'';
                                ErrorData.forEach(errItem => {
                                    content += `<tr><td>${errItem.TaxCode || ''''}</td><td style="word-break: break-word;">${errItem.NumberPhone || ''''}</td><td>bị trùng với người khác</td></tr>`;
                                });
                                content += ''</tbody></table></div>'';
                                showPopupNotify("Thông báo", content, "OK", "50vw");
                            }

                        }
                    },
                    error: function (err) {
                        console.error("Lỗi khi duyệt:", err);
                        uiManager.showAlert({ type: "error", message: "Duyệt thất bại!" });
                    }
                });
            }
        });
    }

    // Override btnConfirmReject to handle bulk reject
    const originalConfirmRejectListener = document.getElementById("btnConfirmReject")?.onclick;
    document.getElementById("btnConfirmReject")?.removeEventListener(''click'', originalConfirmRejectListener);
    document.getElementById("btnConfirmReject")?.addEventListener("click", function () {
        const rejectReason = document.getElementById("rejectReason").value;

        // Check if this is bulk reject or single reject
        if (window.bulkRejectData && window.bulkRejectData.length > 0) {
            const selectedRows = window.bulkRejectData;
            const ids = selectedRows.map(row => row.ID).join(",");

            AjaxHPAParadise({
                data: {
                    name: "sp_CRM_KpiPedingReject",
                    param: ["IDs", ids, "Notes", rejectReason]
                },
                success: function (data) {
                    if (typeof data == "string" && !IsNullOrEmpty(data)) {
                        data = data.includes("{") ? data : EncryptionStringDecryption(data);
                    }
                    const rejectModal = bootstrap.Modal.getInstance(document.getElementById("rejectReasonModal"));
                    if (rejectModal) rejectModal.hide();
                    // clear check grid selection
             const gridInstance = InstanceGridPedingKCP7347CD0B4C364443AD716ADC3225C05C;
                    gridInstance.clearSelection();
                    document.getElementById("rejectReason").value = "";
                    window.bulkRejectData = null;
                    uiManager.showAlert({ type: "success", message: "Từ chối thành công!" });
                    ReloadData();
                },
                error: function (err) {
                    console.error("Lỗi khi từ chối:", err);
                    uiManager.showAlert({ type: "error", message: "Từ chối thất bại!" });
                }
            });
        } else {
            // Single reject from modal
            const currentRecord = window.currentID;
            if (currentRecord) {
                AjaxHPAParadise({
                    data: {
                        name: "sp_CRM_KpiPedingReject",
                        param: ["ID", currentRecord, "Notes", rejectReason]
                    },
                    success: function (data) {
                        try {
                            if (typeof data == "string" && !IsNullOrEmpty(data)) {
                                data = data.includes("{") ? data : EncryptionStringDecryption(data);
                            }
                            let dataObject = JSON.parse(data);
                            let newData = dataObject.data[0];
                            if (newData && newData.length > 0) {
                                loadStatus(3);
                                let result = newData[0].ProcessedCount || 0;
                                uiManager.showAlert({ type: "success", message: `Từ chối ${result} yêu cầu thành công!` });
                                if (result > 0) {
                                    ReloadData();
                                }
                            }
                            const rejectModal = bootstrap.Modal.getInstance(document.getElementById("rejectReasonModal"));
           if (rejectModal) rejectModal.hide();
                            //const modal = bootstrap.Modal.getInstance(document.getElementById("pendingModal"));
                            //if (modal) modal.hide();
                            document.getElementById("rejectReason").value = "";
                        } catch (error) {
                            uiManager.showAlert({ type: "error", message: "Từ chối thất bại!" });
                        }
                    }
                });
            }
        }
    });

        }) ();
</script>
	
	'

    SELECT @html AS html;
	-- exec sptblCommonControlType_Signed_DUC 'sp_CRM_KpiPending_html'
    -- EXEC sp_GenerateHTMLScript_new 'sp_CRM_KpiPending_html'
    -- EXEC sp_GenerateHTMLScript 'sp_Dashboard_Mobile_beta'
END

GO

-- ============================================================================
-- BƯỚC 2: CHUẨN HÓA STORED PROCEDURE ĐIỀU PHỐI [dbo].[sp_CRM_KpiPending]
-- ============================================================================
ALTER PROCEDURE [dbo].[sp_CRM_KpiPending](
    @LoginID INT = NULL,
    @LanguageID VARCHAR(5) = 'VN'
)
AS
BEGIN
    SET NOCOUNT ON;
    IF @LanguageID IS NULL OR LTRIM(RTRIM(@LanguageID)) = ''
        SET @LanguageID = 'VN';
    SELECT TOP 1 html
    FROM tblHtmlScriptCache
    WHERE (TableName = 'sp_CRM_KpiPending' OR TableName = 'sp_CRM_KpiPending_html')
      AND ScreenType = -1
      AND LanguageID = @LanguageID;
END
GO

-- ============================================================================
-- BƯỚC 3: BIÊN DỊCH MÃ NGUỒN GIAO DIỆN VÀO BẢNG CACHE
-- ============================================================================
IF OBJECT_ID('dbo.sp_GenerateHTMLScript_new', 'P') IS NOT NULL
BEGIN
    EXEC sp_GenerateHTMLScript_new 'sp_CRM_KpiPending_html', 'VN', 'sp_CRM_KpiPending';
    EXEC sp_GenerateHTMLScript_new 'sp_CRM_KpiPending_html', 'EN', 'sp_CRM_KpiPending';
END
ELSE
BEGIN
    EXEC sp_GenerateHTMLScript 'sp_CRM_KpiPending_html';
END
GO