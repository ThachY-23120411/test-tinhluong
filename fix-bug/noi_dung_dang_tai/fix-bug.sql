-- ===================================================================
-- PATCH: [sp_KPIContentPost_html] & [sp_KPIContentPost]
-- PHÂN HỆ: Trang Chủ CRM > Nhiệm vụ > Nội dung đăng tải (MnuKPI005)
-- DATABASE: Vietinsoft_ForTest_Tai2
-- ÁP DỤNG BỘ 9 NHÓM QUY TẮC BẤT BIẾN /responsive-rules & CLEAN CODE 3 BƯỚC:
--   1. Master Layout Lock: Khóa max-width 1920px, căn giữa margin: 0 auto.
--   2. Normal Document Flow: Triệt tiêu 100% lỗi che khuất DataGrid (height: auto, position: static).
--   3. Quy tắc 6.4: display: contents Flattening trên .c-filter và .dx-toolbar-before triệt tiêu bẫy thẻ bọc trung gian.
--   4. Quy tắc 6.5: STRICT justify-content: flex-start, cấm space-between; loại bỏ media query ép 100% width cột tháp.
--   5. Quy tắc 6 & Row Consolidation: Cụm Checkbox và Cụm Action gộp chung Hàng 2 ngăn nắp, triệt tiêu lỗi 4 hàng.
--   6. Quy tắc 7: Atomic Text Lock cho toàn bộ labels và checkboxes (flex-shrink: 0, white-space: nowrap).
--   7. SỬA LỖI SEARCHBOX: Thêm padding-left 34px chống icon kính lúp đè lên chữ placeholder "Tìm kiếm theo nội dung".
--   8. Quy tắc 9: Cô lập cuộn Bảng dữ liệu lớn (overflow-x: auto trên DataGrid headers và rowsview).
-- ===================================================================

USE [Vietinsoft_ForTest_Tai2]
GO

-- ===================================================================
-- BƯỚC 1: CẬP NHẬT GIAO DIỆN STORED PROCEDURE [sp_KPIContentPost_html]
-- ===================================================================
/*-------------------------------------------------------------------
 BƯỚC 1: CẬP NHẬT MÃ NGUỒN GIAO DIỆN SP_KPICONTENTPOST_HTML
 (Chứa toàn bộ mã nguồn HTML/CSS/JS đã sửa lỗi ngang hàng filter và responsive)
--------------------------------------------------------------------*/
-------------------------------------------------------
ALTER PROCEDURE [dbo].[sp_KPIContentPost_html]
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
    <div id="contentComponent" class="c-container">
    <style>
        /* ============================================================================
           BỘ QUY CHUẨN RESPONSIVE TOOLBAR, WIDGET & DATAGRID (/responsive-rules)
           PHÂN HỆ: Trang Chủ CRM > Nhiệm vụ > Nội dung đăng tải (sp_KPIContentPost)
           ============================================================================ */

        /* 1. Nhóm 1: Master Layout Lock & Max-Width Pinning trên màn hình lớn 2K/4K */
        #contentComponent,
        #GridContentPost {
            width: 100% !important;
            max-width: 1920px !important;
            min-width: 0 !important;
            margin: 0 auto !important;
            box-sizing: border-box !important;
        }

        /* 2. Nhóm 4 & Golden CSS Fix: Đưa Header Panel & Toolbar về Normal Document Flow */
        #GridContentPost .dx-datagrid-header-panel {
            height: auto !important;
            min-height: auto !important;
            overflow: visible !important;
            padding: 4px 0 8px 0 !important;
            margin-bottom: 8px !important;
        }

        #GridContentPost .dx-toolbar {
            height: auto !important;
            min-height: auto !important;
            position: static !important;
            overflow: visible !important;
            background: transparent !important;
            padding: 4px 0 !important;
            width: 100% !important;
            max-width: 100% !important;
            min-width: 0 !important;
            box-sizing: border-box !important;
        }

        /* 3. Nhóm 6.5: Container Toolbar - STRICT flex-start chống dạt khoảng cách */
        #GridContentPost .dx-toolbar-items-container {
            height: auto !important;
            min-height: 44px !important;
            display: flex !important;
            flex-direction: row !important;
            flex-wrap: wrap !important;
            align-items: center !important;
            justify-content: flex-start !important; /* QUY TẮC 6.5: CẤM space-between */
            row-gap: 8px !important;
            column-gap: 10px !important;
            width: 100% !important;
            max-width: 100% !important;
            min-width: 0 !important;
            padding: 0 !important;
            margin: 0 !important;
            position: relative !important;
            overflow: visible !important;
            box-sizing: border-box !important;
        }

        /* 4. Nhóm 6.4: Triệt tiêu thẻ bọc trung gian - Đồng cấp hóa Sibling (Flat Sibling & Row Consolidation) */
        #GridContentPost .dx-toolbar-before,
        #GridContentPost .dx-toolbar-before > .dx-toolbar-item,
        #GridContentPost .dx-toolbar-before > .dx-toolbar-item > .dx-toolbar-item-content,
        #GridContentPost .c-filter {
            display: contents !important;
        }

        /* 5. Nhóm 2 & 7: Khóa kích thước compact và Khóa nguyên tử Widget chữ */
        #GridContentPost .c-filter > * {
            flex: 0 0 auto !important;
            flex-shrink: 0 !important;
            white-space: nowrap !important;
        }

        #GridContentPost #cFilterFromDate,
        #GridContentPost #cFilterToDate {
            height: 32px !important;
            padding: 4px 8px !important;
            border: 1px solid #334155 !important;
            border-radius: 6px !important;
            font-size: 12px !important;
            width: 130px !important;
            box-sizing: border-box !important;
            background-color: #1e293b !important;
            color: #ffffff !important;
            color-scheme: dark !important;
        }

        #GridContentPost #contentFilterEmployeeToolbar {
            width: 160px !important;
        }

        /* Khóa nguyên tử cụm Checkbox: không rớt dòng chữ lẻ loi */
        #GridContentPost .c-checkbox-group,
        #GridContentPost .c-filter > div:has(#cFilterViewAll) {
            display: inline-flex !important;
            align-items: center !important;
            gap: 12px !important;
            flex: 0 0 auto !important;
            flex-shrink: 0 !important;
            white-space: nowrap !important;
            margin: 0 !important;
        }

        #GridContentPost .c-checkbox-group > div {
            display: inline-flex !important;
            align-items: center !important;
            gap: 5px !important;
            flex-shrink: 0 !important;
            white-space: nowrap !important;
        }

        /* 6. Nhóm 3 & 6.3: Khối Hành Động Bên Phải (Tự động neo sát lề phải) */
        #GridContentPost .dx-toolbar-after {
            position: static !important;
            margin-left: auto !important; /* ĐẨY SÁT PHẢI CẢ KHI HÀNG 1 LẪN KHI RỚT HÀNG 2 */
            display: flex !important;
            flex-direction: row !important;
            align-items: center !important;
            gap: 8px !important;
            flex: 0 0 auto !important;
            flex-shrink: 0 !important;
            width: auto !important;
            height: auto !important;
            padding: 0 !important;
            overflow: visible !important;
            flex-wrap: nowrap !important;
            white-space: nowrap !important;
        }

        #GridContentPost .dx-toolbar-center {
            display: none !important;
        }

        /* Bảo toàn Style gốc của Icon Buttons */
        #GridContentPost .dx-toolbar-after .dx-button,
        #GridContentPost .dx-datagrid-column-chooser-button {
            width: 32px !important;
            height: 32px !important;
            padding: 0 !important;
            border-radius: 6px !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
        }

        /* Styling Nút Thêm nội dung */
        #GridContentPost #btnOpenContentModal {
            height: 32px !important;
            padding: 0 14px !important;
            border: none !important;
            border-radius: 6px !important;
            font-size: 12px !important;
            font-weight: 500 !important;
            display: inline-flex !important;
            align-items: center !important;
            gap: 6px !important;
            background-color: #198754 !important;
            color: white !important;
            white-space: nowrap !important;
            flex-shrink: 0 !important;
        }

        /* 8. SỬA LỖI SEARCHBOX: Chống icon kính lúp đè lên chữ placeholder */
        #GridContentPost .dx-datagrid-search-panel,
        #GridContentPost .dx-searchbox {
            background-color: #1e293b !important;
            border: 1px solid #334155 !important;
            border-radius: 6px !important;
            height: 32px !important;
            width: 235px !important;
            position: relative !important;
            overflow: hidden !important;
        }

        #GridContentPost .dx-datagrid-search-panel.dx-state-focused,
        #GridContentPost .dx-searchbox.dx-state-focused {
            border-color: #3b82f6 !important;
            box-shadow: 0 0 0 1px #3b82f6 !important;
        }

        /* FIX SEARCHBOX ICON OVERLAPPING TEXT: Lùi lề trái 34px chống đè kính lúp */
        #GridContentPost .dx-datagrid-search-panel .dx-texteditor-input,
        #GridContentPost .dx-searchbox .dx-texteditor-input {
            color: #ffffff !important;
            background-color: transparent !important;
            font-size: 12px !important;
            height: 32px !important;
            padding-left: 34px !important;
            box-sizing: border-box !important;
        }

        #GridContentPost .dx-datagrid-search-panel .dx-placeholder,
        #GridContentPost .dx-datagrid-search-panel .dx-placeholder::before,
        #GridContentPost .dx-searchbox .dx-placeholder,
        #GridContentPost .dx-searchbox .dx-placeholder::before {
            color: #94a3b8 !important;
            -webkit-text-fill-color: #94a3b8 !important;
            opacity: 1 !important;
            padding-left: 34px !important;
        }

        #GridContentPost .dx-datagrid-search-panel .dx-icon-search,
        #GridContentPost .dx-searchbox .dx-icon-search {
            color: #94a3b8 !important;
            left: 8px !important;
        }

        #GridContentPost .dx-datagrid-search-panel .dx-clear-button-area .dx-icon-clear,
        #GridContentPost .dx-searchbox .dx-clear-button-area .dx-icon-clear {
            color: #94a3b8 !important;
        }

        /* 9. Nhóm 9: Cô lập cuộn Bảng dữ liệu lớn */
        #GridContentPost .dx-datagrid-headers,
        #GridContentPost .dx-datagrid-rowsview {
            overflow-x: auto !important;
            -webkit-overflow-scrolling: touch !important;
        }

        .c-container {
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            padding: 20px;
            margin-bottom: 20px;
        }

        #contentModal.show {
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            min-height: 100vh;
            background: rgba(19, 16, 16, .8) !important;
        }

        #contentModal .modal-dialog {
            margin: 0 !important;
            width: 90vw;
            max-width: 90vw;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
        }

        #contentModal .modal-content {
            margin-top: 50px;
            border: none !important;
            box-shadow: none !important;
            width: 100%;
            max-height: 90vh;
            overflow-y: auto;
            scrollbar-width: none;
            -ms-overflow-style: none;
            display: flex;
            flex-direction: column;
        }

        #contentModal .modal-content::-webkit-scrollbar {
            display: none;
        }

        #contentModal .modal-header {
            flex-shrink: 0;
        }

        #contentModal .modal-body {
            flex: 1;
            overflow-y: auto;
            padding: 1.5rem;
        }

        #contentModal .modal-footer {
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            flex-shrink: 0;
        }

        #contentForm .form-group {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 1rem !important;
        }

        #contentForm .form-label {
            min-width: 120px;
            margin-bottom: 0 !important;
            white-space: nowrap;
            font-weight: 600;
        }

        #contentForm .form-label.required::after {
            content: " *";
            color: red;
        }

        #contentForm .form-group>div:not(.form-label) {
            flex: 1;
        }

        #contentForm .row {
            gap: 1rem;
        }

        #contentForm .row .col-md-6 {
            flex: 1;
        }

        .c-table tbody tr {
            cursor: pointer;
        }

        .c-table tbody tr:hover {
            background-color: rgba(255, 255, 255, 0.05) !important;
        }

        .c-filter {
            display: flex !important;
            flex-direction: row !important;
            align-items: center !important;
            gap: 8px !important;
            flex-wrap: wrap !important;
            margin-bottom: 0px !important;
            width: auto !important;
        }

        .c-filter > div {
            display: inline-flex !important;
            align-items: center !important;
        }

        /* File attachment zone */
        #cImagePreview {
            max-width: 100%;
            max-height: 200px;
            border-radius: 8px;
            border: 1px solid #e9ecef;
        }

        .c-filter label {
            display: inline-block !important;
            margin: 0 !important;
            font-weight: 500 !important;
            color: #64748b !important;
            font-size: 12px !important;
            white-space: nowrap !important;
        }

        .c-filter input[type="date"] {
            height: 32px !important;
            padding: 4px 10px !important;
            border: 1px solid #334155 !important;
            border-radius: 6px !important;
            font-size: 12px !important;
            outline: none !important;
            box-sizing: border-box !important;
            background-color: #1e293b !important;
            color: #ffffff !important;
            color-scheme: dark !important;
        }
        .c-filter input[type="date"]:focus {
            border-color: #3b82f6 !important;
            box-shadow: 0 0 0 1px #3b82f6 !important;
        }
        .c-filter input[type="date"]:disabled {
            background-color: #0f172a !important;
            color: #64748b !important;
            border-color: #1e293b !important;
            cursor: not-allowed !important;
        }
        /* Ẩn triệt để nút làm mới thứ 2 */
        .c-filter button.d-none,
        #cFilterResetBtn {
            display: none !important;
            width: 0 !important;
            height: 0 !important;
            padding: 0 !important;
            margin: 0 !important;
            border: none !important;
            visibility: hidden !important;
        }

        .c-filter button {
            height: 32px !important;
            padding: 0 12px !important;
            border: none !important;
            border-radius: 6px !important;
            cursor: pointer !important;
            font-weight: 500 !important;
            font-size: 12px !important;
            display: inline-flex !important;
            align-items: center !important;
            gap: 6px !important;
            transition: all 0.3s ease !important;
            white-space: nowrap !important;
        }

        .c-filter .btn-reset {
            color: #198754 !important;
            border: 1px solid #198754 !important;
            background: transparent !important;
        }

        .c-filter .btn-reset:hover {
            background-color: #198754 !important;
            color: white !important;
        }

        /* AI Processing Overlay */
        .ai-processing-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.85);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            flex-direction: column;
            gap: 20px;
        }

        .ai-processing-overlay.show {
            display: flex;
        }

        .ai-spinner {
            width: 60px;
            height: 60px;
            border: 4px solid rgba(255, 255, 255, 0.3);
            border-top-color: #198754;
            border-radius: 50%;
            animation: ai-spin 1s linear infinite;
        }

        @keyframes ai-spin {
            to {
                transform: rotate(360deg);
            }
        }

        .ai-processing-text {
            color: white;
            font-size: 18px;
            font-weight: 600;
        }

        .ai-processing-subtext {
            color: rgba(255, 255, 255, 0.7);
            font-size: 14px;
        }
    </style>

    <!-- Nút Thêm nội dung đã được chuyển xuống ngang hàng với filter trên toolbar (Screenshot 27) -->
    <div class="d-flex justify-content-end align-items-center" style="display: none !important;">
        <button type="button" class="btn btn-success" style="display: none !important;" onclick="openContentModal()">
            <i class="fas fa-plus me-2"></i>Thêm nội dung
        </button>
    </div>

    <div class="table-responsive">
        <!-- <table class="table table-striped table-hover c-table">
            <thead>
                <tr>
                    <th>STT</th>
                    <th>Ngày</th>
                    <th>Chủ đề</th>
                    <th>Trạng thái</th>
                    <th>Loại bài đăng</th>
                    <th>Link</th>
                    <th>Hành động</th>
                </tr>
            </thead>
            <tbody id="contentTableBody">
            </tbody>
        </table> -->

        <div id="GridContentPost" style="height: 100%;"></div>
    </div>
</div>

<div class="d-none">
    <div id="P3D009B3C43384C5D9FEB98249D80341C"></div>
</div>

<!-- AI Processing Loading Overlay -->
<div id="cAiProcessingOverlay" class="ai-processing-overlay">
    <div class="ai-spinner"></div>
    <div class="ai-processing-text">Đang phân tích hình ảnh với AI...</div>
    <div class="ai-processing-subtext">Vui lòng đợi một chút</div>
</div>

<!-- Content Modal -->
<div class="modal fade" id="contentModal" tabindex="-1" data-bs-backdrop="static" data-bs-keyboard="false">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="contentModalTitle">Thêm nội dung mới</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form id="contentForm">
                    <div class="form-group">
                        <label class="form-label required">Thời gian:</label>
                        <div id="P12E37DAC57B14527ACB0C26B07261B59"></div>
                    </div>

                    <div class="form-group">
                        <label class="form-label required">Chủ đề:</label>
                        <div id="P5213D52BF78449138563C8ADE0F89DF3"></div>
                  </div>

                    <div style="display: flex; gap: 1rem;">
                        <div class="form-group" style="flex: 1;">
                            <label class="form-label required">Trạng thái:</label>
                            <div id="P32144D2FBF5643D297D3468D313DB721"></div>
                        </div>

                        <div class="form-group" style="flex: 1;">
                            <label class="form-label required">Loại bài đăng:</label>
                            <div id="P6575D537E6A84FDCB9FEF0598C3225D3"></div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label required">Link bài đăng:</label>
                        <div id="PE14756C910FB424FAAC3D199CF26E66B"></div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Ghi chú:</label>
                        <div id="P100654C6A52D411EBB7A1D90474F0CA9"></div>
                    </div>

                    <div class="form-group" style="align-items: flex-start;">
                        <label class="form-label" style="padding-top: 8px;">Đính kèm:</label>
                        <div style="flex:1;">
                            <div id="cAttachZone" style="
                                border: 2px dashed #198754;
                                border-radius: 8px;
                                padding: 30px;
                                text-align: center;
                                cursor: pointer;
                                transition: all 0.3s ease;
                                min-height: 120px;
                                display: flex;
                                align-items: center;
                                justify-content: center;
                                flex-direction: column;
                            ">
                                <i class="bi bi-cloud-arrow-up"
                                    style="font-size: 2rem; color: #198754; margin-bottom: 10px;"></i>
                                <p style="margin: 0; color: #198754; font-weight: 500;">Kéo thả hình ảnh để AI phân tích
                                </p>
                                <p style="margin: 5px 0 0 0; color: #64748b; font-size: 13px;">hoặc click chọn, hoặc
                                    <kbd>Ctrl+V</kbd> dán ảnh
                                </p>
                                <input type="file" id="cAttachInput" accept="image/*" style="display:none;" />
                            </div>
                            <div id="cImagePreviewContainer"
                                style="margin-top: 10px; display: none; position: relative;">
                                <img id="cImagePreview"
                                    style="max-width: 100%; max-height: 200px; border-radius: 8px; border: 1px solid #e9ecef;">
                                <button type="button" class="btn btn-sm btn-danger mt-2" id="cClearImageBtn"
                                    style="width: 100%;">
                                    <i class="bi bi-trash"></i> Xóa hình ảnh
                                </button>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal"><i
                        class="fas fa-times me-2"></i>Hủy</button>
                <button type="button" id="contentComponent_btnSaveContent" class="btn btn-success" onclick="saveContent()"><i
                        class="fas fa-save me-2"></i>Lưu dữ liệu</button>
            </div>
        </div>
    </div>
</div>

<script>
    (() => {
        let contentList = [];
        let currentEditId = null;
        let DataSource = [];
        let contentToolbarConfigured = false;
        let contentAttachedFiles = []; // [{ name, type, uploadedPath, previewSrc, uploading, error }]

        // ======== HELPERS (giống dc.html) ========
        function _cUuidv4() {
            return ''xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx''.replace(/[xy]/g, function (c) {
                var r = Math.random() * 16 | 0, v = c == ''x'' ? r : (r & 0x3 | 0x8);
                return v.toString(16);
            });
        }

        async function _cUploadMergeFileSplit(src, fileName) {
            // Dùng global UploadMergeFileSplit nếu có, fallback tự implement
            if (typeof UploadMergeFileSplit === ''function'') {
                return UploadMergeFileSplit(src, fileName);
            }
            let splitImage = src.match(/.{1,500000}/g);
            let totalIndex = splitImage.length;
            let index = 0;
            let tempName = _cUuidv4() + ''.tmp'';
            if (!fileName) fileName = tempName;
            let pathResult = '''';
            while (index < totalIndex) {
                try {
                    const data = await AjaxHPAParadiseParadiseAsync({
                        data: {
                            sendEncryption: false,
                            name: ''MergeFileSplit'',
                            param: [splitImage[index], index, totalIndex, tempName, fileName]
                        }
                    });
                    index++;
                    pathResult = data;
                } catch (error) {
                    if (error.status == 200) index++;
                    else throw error;
                }
            }
            return pathResult;
        }

        // ======== FILE ATTACHMENT LOGIC ========
        function cAttachRender() {
            // Giống dc.html: show/hide preview container + ẩn drop zone khi có ảnh
            const zone = document.getElementById(''cAttachZone'');
            const previewContainer = document.getElementById(''cImagePreviewContainer'');
            const previewImg = document.getElementById(''cImagePreview'');
            if (!previewContainer || !previewImg) return;

            const entry = contentAttachedFiles.length > 0 ? contentAttachedFiles[0] : null;
            if (entry && entry.previewSrc) {
                previewImg.src = entry.previewSrc;
                previewContainer.style.display = ''block'';
                if (zone) zone.style.display = ''none'';
            } else {
                previewContainer.style.display = ''none'';
                previewImg.src = '''';
                if (zone) zone.style.display = ''flex'';
            }
        }

        async function cAttachProcessFile(file) {
            // Validate size (max 10MB, giống dc.html)
            const maxSize = 10 * 1024 * 1024;
            if (file.size > maxSize) {
                uiManager.showAlert({ type: ''error'', message: ''File "'' + file.name + ''" vượt quá 10MB.'' });
                return;
            }

            const entry = {
                name: file.name || (''file_'' + Date.now()),
                type: file.type,
                uploadedPath: null,
                previewSrc: null,
                uploading: true,
                error: null
            };
            contentAttachedFiles.push(entry);
            cAttachRender();

            const reader = new FileReader();
            reader.onload = async function (e) {
                const base64Data = e.target.result;

                // Nếu là ảnh thì hiện preview ngay (giống dc.html)
                if (file.type && file.type.startsWith(''image/'')) {
                    entry.previewSrc = base64Data;
                    cAttachRender();
                }

                try {
                    const base64Content = base64Data.split('','')[1];
                    const fileName = file.name || (''image_'' + Date.now() + ''.jpg'');
                    const uploadedRaw = await _cUploadMergeFileSplit(base64Content, fileName);

                    let dataURL = '''';
                    if (uploadedRaw) {
                        try {
                            const dataEx = JSON.parse(uploadedRaw);
                            dataURL = dataEx.data || '''';




                            dataURL = dataURL.replace(/\\/g, ''\\\\'');
                        } catch (e) {
                            dataURL = uploadedRaw;
                        }
                    }

                    entry.uploadedPath = dataURL || uploadedRaw;
                    entry.uploading = false;
                    cAttachRender();

                    // Call AI API nếu là ảnh và có dữ liệu ảnh
                    if (file.type && file.type.startsWith(''image/'')) {
                        showAIProcessingLoader();

                        const imgParam = base64Data || entry.uploadedPath || '''';

                        AjaxHPAParadise({
                            data: {
                                name: ''sp_AI_api_datacontent'',
                                param: [
                                    ''linkPdfBase64'', imgParam,
                                    ''mimeType'', file.type,
                                    ''LanguageID'', window.LanguageID
                                ]
                            },
                            success: function (data) {
                                hideAIProcessingLoader();
                                window._cIsProcessingPaste = false;

                                if (typeof data == ''string'' && !IsNullOrEmpty(data)) {
                                    data = data.includes(''{'') ? data : EncryptionStringDecryption(data);
                                }

                                try {
                                    const responseData = JSON.parse(data);
                                    let contentData = null;

                                    // Parse Result từ response
                                    if (responseData && responseData.data && Array.isArray(responseData.data)) {
                                        if (responseData.data.length > 0 && Array.isArray(responseData.data[0])) {
                                            if (responseData.data[0].length > 0) {
                                                const resultData = responseData.data[0][0];

                                                if (resultData && resultData.Result) {
                                                    let resultString = resultData.Result;

                                                    if (typeof resultString === ''string'') {
                                                        const trimmedResult = resultString.trim();
                                                        if (trimmedResult.startsWith("Failed") || trimmedResult.startsWith("Error") || (!trimmedResult.startsWith("{") && !trimmedResult.startsWith("["))) {
                                                            console.error("AI Service Error:", resultString);
                                                            uiManager.showAlert({ type: ''error'', message: ''Lỗi phân tích AI: '' + resultString });
                                                            return;
                                                        }

                                                        try {
                                                            contentData = JSON.parse(resultString);
                                                        } catch (e1) {
                                                            console.error("Lỗi parse JSON kết quả AI:", e1, resultString);
                                                            uiManager.showAlert({ type: ''error'', message: ''Dữ liệu AI không đúng định dạng JSON!'' });
                                                            return;
                                                        }
                                                    } else {
                                                        contentData = resultString;
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // Điền data vào form nếu có
                                    if (contentData) {
                                        let obj = contentData;
                                        if (Array.isArray(contentData) && contentData.length > 0) {
                                            obj = contentData[0];
                                        }

                                        ' + (select loadData from tblCommonControlType_Signed where UID = 'P5213D52BF78449138563C8ADE0F89DF3')
                                            + (select loadData from tblCommonControlType_Signed where UID = 'P100654C6A52D411EBB7A1D90474F0CA9')
                            + (select loadData from tblCommonControlType_Signed where UID = 'P6575D537E6A84FDCB9FEF0598C3225D3')
                        + (select loadData from tblCommonControlType_Signed where UID = 'P12E37DAC57B14527ACB0C26B07261B59')
                        + N'

                        uiManager.showAlert({ type: ''success'', message: ''Đã phân tích xong!'' });
                    } else {
                        console.warn(''Không tìm thấy Result trong response'');
                    }
                } catch (error) {
                    console.error(''Error parsing AI response:'', error);
                    uiManager.showAlert({ type: ''error'', message: ''Đã xảy ra lỗi khi phân tích!'' });
                }
            },
                error: function(error) {
                    hideAIProcessingLoader();
                    window._cIsProcessingPaste = false;
                    console.error(''AI API call failed:'', error);
                    uiManager.showAlert({ type: ''error'', message: ''Đã xảy ra lỗi khi gọi AI!'' });
                }
        });
    }
                } catch (err) {
        entry.uploading = false;
        entry.error = ''Tải lên thất bại'';
        window._cIsProcessingPaste = false;
        console.error(''[ContentAttach] Upload error:'', err);
        cAttachRender();
    }
            };
    reader.readAsDataURL(file);
        }

    function cAttachInit() {
        const zone = document.getElementById(''cAttachZone'');
        const input = document.getElementById(''cAttachInput'');
        const clearBtn = document.getElementById(''cClearImageBtn'');
        if (!zone || !input) return;

        // Click chọn file
        zone.addEventListener(''click'', function () {
            input.click();
        });
        input.onchange = function () {
            if (input.files && input.files[0]) {
                contentAttachedFiles = [];
                cAttachRender();
                window._cIsProcessingPaste = true;
                cAttachProcessFile(input.files[0]);
            }
            input.value = '''';
        };

        // Xóa hình ảnh (giống dc.html ClearImage)
        if (clearBtn) {
            clearBtn.addEventListener(''click'', function () {
                contentAttachedFiles = [];
                cAttachRender();
                window._cIsProcessingPaste = false;
            });
        }

        // Drag & drop (giống dc.html)
        zone.addEventListener(''dragover'', function (e) {
            e.preventDefault();
            zone.style.backgroundColor = ''#e8f5e9'';
            zone.style.borderColor = ''#157347'';
        });
        zone.addEventListener(''dragleave'', function () {
            zone.style.backgroundColor = '''';
            zone.style.borderColor = ''#198754'';
        });
        zone.addEventListener(''drop'', function (e) {
            e.preventDefault();
            zone.style.backgroundColor = '''';
            zone.style.borderColor = ''#198754'';
            const files = e.dataTransfer.files;
            if (files && files[0]) {
                contentAttachedFiles = [];
                cAttachRender();
                window._cIsProcessingPaste = true;
                cAttachProcessFile(files[0]);
            }
        });
    }

    // Ctrl+V paste handler (chỉ active khi modal đang mở, giống dc.html)
    // Dùng window flag để tránh đăng ký nhiều lần khi component reload
    window._cIsProcessingPaste = window._cIsProcessingPaste || false;
    if (!window._cContentPasteHandlerRegistered) {
        window._cContentPasteHandlerRegistered = true;
        document.addEventListener(''paste'', function (e) {
            const modal = document.getElementById(''contentModal'');
            if (!modal || !modal.classList.contains(''show'')) return;

            // Nếu focus đang ở trong ô rich text (P100654C6A52D411EBB7A1D90474F0CA9) thì không intercept
            const richTextContainer = document.getElementById(''P100654C6A52D411EBB7A1D90474F0CA9'');
            if (richTextContainer && richTextContainer.contains(document.activeElement)) return;

            const items = e.clipboardData && e.clipboardData.items;
            if (!items) return;
            for (let i = 0; i < items.length; i++) {
                if (items[i].type.indexOf(''image'') !== -1) {
                    e.preventDefault();
                    if (window._cIsProcessingPaste) {
                        uiManager.showAlert({ type: ''error'', message: ''Đang xử lý ảnh trước đó, vui lòng chờ...'' });
                        break;
                    }
                    const f = items[i].getAsFile();
                    if (f) {
                        // Đè file mới lên, xóa file cũ (giống dc.html)
                        contentAttachedFiles = [];
                        cAttachRender();
                        window._cIsProcessingPaste = true;
                        cAttachProcessFile(f);
                    }
                    break;
                }
            }
        });
    }

    // Init attachment zone sau khi DOM sẵn sàng
    setTimeout(cAttachInit, 200);

    // AI Processing Loader functions
    function showAIProcessingLoader() {
        document.getElementById(''cAiProcessingOverlay'').classList.add(''show'');
    }

    function hideAIProcessingLoader() {
        document.getElementById(''cAiProcessingOverlay'').classList.remove(''show'');
    }

    // Load UI components
    '+ (select loadUI from tblCommonControlType_Signed where UID = 'P6746D3214A5E49509BAC1F9F68B7D9C2')
        + (select loadUI from tblCommonControlType_Signed where UID = 'P3D009B3C43384C5D9FEB98249D80341C')
    + (select loadUI from tblCommonControlType_Signed where UID = 'P12E37DAC57B14527ACB0C26B07261B59')
    + (select loadUI from tblCommonControlType_Signed where UID = 'P5213D52BF78449138563C8ADE0F89DF3')
    + (select loadUI from tblCommonControlType_Signed where UID = 'P32144D2FBF5643D297D3468D313DB721')
    + (select loadUI from tblCommonControlType_Signed where UID = 'P6575D537E6A84FDCB9FEF0598C3225D3')
    + (select loadUI from tblCommonControlType_Signed where UID = 'PE14756C910FB424FAAC3D199CF26E66B')
    + (select loadUI from tblCommonControlType_Signed where UID = 'P100654C6A52D411EBB7A1D90474F0CA9') + N'

    window.currentRecordID_ID = null;

    // sp_CRM_ProcedureCategoryList

    //if ("sp_CRM_ProcedureCategoryList" && "sp_CRM_ProcedureCategoryList".trim() !== "") {
    //    loadDataSourceCommon("Type", "sp_CRM_ProcedureCategoryList", function (data) {
    //        // Data được shared qua callback
    //    });
    // }

    // Load DataSource: sp_CRM_KPIContentStatus
    // if ("sp_CRM_KPIContentStatus" && "sp_CRM_KPIContentStatus".trim() !== "") {
    //     loadDataSourceCommon("content_status", "sp_CRM_KPIContentStatus", function (data) {
    //         // Data được shared qua callback
    //     });
    // }

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
                    "Instance" + columnName.charAt(0).toUpperCase() + columnName.slice(1) + "P6746D3214A5E49509BAC1F9F68B7D9C2",
                    "Instance" + columnName + "P6746D3214A5E49509BAC1F9F68B7D9C2",
                    "instance" + columnName.charAt(0).toUpperCase() + columnName.slice(1) + "P6746D3214A5E49509BAC1F9F68B7D9C2"
                ];

                for (let i = 0; i < instanceVariants.length; i++) {
                    const instanceKey = instanceVariants[i];
                    if (window[instanceKey]) {
                        const instanceObj = window[instanceKey];

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

    function configureContentGridToolbar(gridInstance) {
        if (!gridInstance) return;

        gridInstance.option("toolbar", {
            items: [
                {
                    location: "before",
                    template: function (data, index, element) {
                        const $container = $(''<div class="c-filter" style="display: flex; flex-direction: row; align-items: center; gap: 8px; flex-wrap: wrap; width: auto; margin: 0; padding: 0;">'');

                        // Employee filter - only if window.EmployeeID_Login exists
                        let $employeeDiv;
                        if (window.EmployeeID_Login) {
                            $employeeDiv = $(''<div style="display: flex; align-items: center; gap: 5px; min-width: 160px;">'');
                            $employeeDiv.append(''<label style="font-size: 11px; color: #64748b; white-space: nowrap;">Nhân viên:</label>'');
                            $employeeDiv.append($(''<div id="contentFilterEmployeeToolbar" style="width: 160px;"></div>''));
                        }

                        // From Date
                        const $fromDiv = $(''<div style="display: flex; align-items: center; gap: 5px; min-width: 120px;">'');
                        $fromDiv.append(''<label style="font-size: 11px; color: #64748b; white-space: nowrap;">Từ:</label>'');
                        $fromDiv.append(''<input type="date" id="cFilterFromDate" style="height: 32px; padding: 4px 10px; border: 1px solid #334155; border-radius: 6px; font-size: 12px; width: 130px; box-sizing: border-box; background-color: #1e293b; color: #ffffff; color-scheme: dark;">'');

                        // To Date
                        const $toDiv = $(''<div style="display: flex; align-items: center; gap: 5px; min-width: 120px;">'');
                        $toDiv.append(''<label style="font-size: 11px; color: #64748b; white-space: nowrap;">Đến:</label>'');
                        $toDiv.append(''<input type="date" id="cFilterToDate" style="height: 32px; padding: 4px 10px; border: 1px solid #334155; border-radius: 6px; font-size: 12px; width: 130px; box-sizing: border-box; background-color: #1e293b; color: #ffffff; color-scheme: dark;">'');

                        // Action buttons
                        const $filterBtn = $(''<button class="btn btn-success" id="cFilterSearchBtn" style="height: 32px; padding: 0 12px; color: white; border: none; border-radius: 6px; font-size: 12px; font-weight: 500; cursor: pointer; white-space: nowrap; display: inline-flex; align-items: center; gap: 6px; flex-shrink: 0;"><i class="bi bi-filter"></i> Làm mới</button>'');
                        const $resetBtn = $(''<button class="d-none btn btn-outline-success" id="cFilterResetBtn" style="display: none !important; width: 0; height: 0; padding: 0; border: none; margin: 0;"></button>'');

                        // First row: Employee + Date filters + Filter button + Reset button
                        // FIX SCREENSHOT 27: Đưa các tickbox lên ngang hàng với filter trong cùng 1 hàng flex
                        const $checkboxRow = $(''<div style="display: inline-flex; align-items: center; gap: 12px; flex-shrink: 0; margin-left: 4px;">'');
                        
                        const $viewAllWrap = $(''<div style="display: flex; align-items: center; gap: 5px;">'');
                        $viewAllWrap.append(''<input type="checkbox" id="cFilterViewAll" style="width: 15px; height: 15px; cursor: pointer; accent-color: #198754; margin: 0;">'');
                        $viewAllWrap.append(''<label for="cFilterViewAll" style="font-size: 12px; color: #64748b; white-space: nowrap; cursor: pointer; margin: 0;">%ViewAllDays%</label>'');
                        $checkboxRow.append($viewAllWrap);

                        // "Only My Data" checkbox
                        if (window.EmployeeID_Login) {
                            const $myWrap = $(''<div style="display: flex; align-items: center; gap: 5px;">'');
                            $myWrap.append(''<input type="checkbox" id="cFilterMyData" style="width: 15px; height: 15px; cursor: pointer; accent-color: #0d6efd; margin: 0;">'');
                            $myWrap.append(''<label for="cFilterMyData" style="font-size: 12px; color: #64748b; white-space: nowrap; cursor: pointer; margin: 0;">Chỉ xem của tôi</label>'');
                            $checkboxRow.append($myWrap);
                        }

                        // Toggle when "View All" changes
                        $checkboxRow.find(''#cFilterViewAll'').on(''change'', function () {
                            const checked = $(this).is('':checked'');
                            $fromDiv.find(''input'').prop(''disabled'', checked);
                            $toDiv.find(''input'').prop(''disabled'', checked);
                            $fromDiv.css(''opacity'', checked ? ''0.4'' : ''1'');
                            $toDiv.css(''opacity'', checked ? ''0.4'' : ''1'');
                            filterC();
                        });

                        // Toggle when "My Data" changes
                        $checkboxRow.find(''#cFilterMyData'').on(''change'', function () {
                            const checked = $(this).is('':checked'');
                            if (window.EmployeeID_Login) {
                                if (checked) {
                                    InstanceFullNameP3D009B3C43384C5D9FEB98249D80341C.option(''value'', window.EmployeeID_Login);
                                } else {
                                    InstanceFullNameP3D009B3C43384C5D9FEB98249D80341C.option(''value'', null);
                                }
                            }
                            filterC();
                        });

                        // Toàn bộ phần tử filter + checkbox nằm ngang hàng nhau
                        if ($employeeDiv) {
                            $container.append($employeeDiv);
                        }
                        $container.append($fromDiv, $toDiv, $filterBtn, $checkboxRow);

                        // Dọn dẹp bản cũ và nạp vào toolbar before
                        $(element).parent().find(''.c-filter'').remove();
                        $(element).parent().prepend($container);

                        // Initialize default dates
                        setTimeout(() => {
                            if (window.FromDateKPI && window.ToDateKPI) {
                                $(''#cFilterFromDate'').val(window.FromDateKPI);
                                $(''#cFilterToDate'').val(window.ToDateKPI);
                                $(''#cFilterViewAll'').prop(''checked'', false);

                                InstanceFullNameP3D009B3C43384C5D9FEB98249D80341C.option(''value'', window.EmployeeIDsKPI);
                            } else {

                                $(''#cFilterViewAll'').prop(''checked'', true);
                                let checked = $(''#cFilterViewAll'').is('':checked'');
                                $fromDiv.find(''input'').prop(''disabled'', checked);
                                $toDiv.find(''input'').prop(''disabled'', checked);
                                $fromDiv.css(''opacity'', checked ? ''0.4'' : ''1'');
                                $toDiv.css(''opacity'', checked ? ''0.4'' : ''1'');

                                const today = new Date();
                                const thirtyDaysAgo = new Date(today.getTime() - (30 * 24 * 60 * 60 * 1000));
                                const formatLocalDate = (date) => {
                                    return String(date.getFullYear()).padStart(4, ''0'') + ''-'' +
                                        String(date.getMonth() + 1).padStart(2, ''0'') + ''-'' +
                                        String(date.getDate()).padStart(2, ''0'');
                                };
                                const fromDate = formatLocalDate(thirtyDaysAgo);
                                const toDate = formatLocalDate(today);

                                $(''#cFilterFromDate'').val(fromDate);
                                $(''#cFilterToDate'').val(toDate);
                            }

                            // Attach event handlers
                            $(''#cFilterSearchBtn'').off(''click'').on(''click'', function () {
                                filterC();
                            });

                            $(''#cFilterResetBtn'').off(''click'').on(''click'', function () {
                                const today = new Date();
                                const thirtyDaysAgo = new Date(today.getTime() - (30 * 24 * 60 * 60 * 1000));
                                $(''#cFilterFromDate'').val(thirtyDaysAgo.toISOString().split(''T'')[0]).prop(''disabled'', false).css(''opacity'', ''1'');
                                $(''#cFilterToDate'').val(today.toISOString().split(''T'')[0]).prop(''disabled'', false).css(''opacity'', ''1'');
                                $fromDiv.css(''opacity'', ''1'');
                                $toDiv.css(''opacity'', ''1'');
                                $(''#cFilterViewAll'').prop(''checked'', false);
                                $(''#cFilterMyData'').prop(''checked'', false);
                                if (window.EmployeeID_Login) {
                                    InstanceFullNameP3D009B3C43384C5D9FEB98249D80341C.option(''value'', null);
                                }
                                resetFilterC();
                            });

                            // Move employee filter to toolbar
                            if (window.EmployeeID_Login) {
                                setTimeout(() => {
          const employeeFilterWrapper = document.getElementById("contentFilterEmployeeToolbar");
                                    if (employeeFilterWrapper && employeeFilterWrapper.children.length === 0) {
                                        const originalEmployee = document.getElementById("P3D009B3C43384C5D9FEB98249D80341C");
                                        if (originalEmployee && originalEmployee.parentElement) {
                                            const employeeDiv = originalEmployee.parentElement.querySelector(''div'');
                                            if (employeeDiv) {
                                                employeeFilterWrapper.appendChild(employeeDiv);
                                            }
                                        }
                                    }
                                }, 300);
                            }
                        }, 100);
                    }
                },
                // FIX SCREENSHOT 27: Đưa nút Thêm nội dung xuống ngang hàng với filter trên toolbar
                {
                    location: "after",
                    template: function () {
                        return $(
                            ''<button type="button" class="btn btn-success" id="btnOpenContentModal" '' +
                            ''style="height: 32px; padding: 0 14px; border: none; border-radius: 6px; cursor: pointer; '' +
                            ''font-weight: 500; font-size: 12px; display: inline-flex; align-items: center; '' +
                            ''gap: 6px; transition: all 0.3s ease; background-color: #198754; color: white; white-space: nowrap;" '' +
                            ''onclick="openContentModal()">'' +
                            ''<i class="fas fa-plus"></i> Thêm nội dung'' +
                            ''</button>''
                        );
                    }
                },
                {
                    location: "after",
                    widget: "dxButton",
                    options: {
                        icon: "columnchooser",
                        hint: "Column Chooser",
                        onClick: function () {
                            gridInstance.showColumnChooser();
                        }
                    }
                },
                {
                    location: "after",
                    name: "searchPanel"
                }
            ]
        });
    }

    function clearPageCache() {
        _pageCache = {};
    }

    function getGridHeight() {
        const gridEl = InstanceGridContentPostP6746D3214A5E49509BAC1F9F68B7D9C2.element();
        const domElement = gridEl.jquery ? gridEl[0] : gridEl;
        const top = domElement.getBoundingClientRect().top;
        return window.innerHeight - top - 20;
    }

    function ReloadData(fromDate = null, toDate = null, employeeId = null, isViewAll = null, keyword = null) {

        _pageCache = {};

        let _currentKeyword = String(
            keyword != null
                ? keyword
                : (InstanceGridContentPostP6746D3214A5E49509BAC1F9F68B7D9C2.option("searchPanel.text") || "")
        ).trim();

        function _applyRecord(results) {
            window.syncSharedGridData("GridContentPost");

        }

        dataStore_GridContentPost = new DevExpress.data.CustomStore({
            key: "ID",
            load: function (loadOptions) {
                const deferred = $.Deferred();

                let params = [];

                // SP nghiệp vụ
                params.push("@ProcName", "sp_KPIgetDataContentPost");

                // Tham số riêng của sp_KPIgetDataContentPost
                let procParam = "";
                isViewAll = isViewAll == null ? ($(''#cFilterViewAll'').is('':checked'') ? 1 : 0) : isViewAll;
                const fallbackFrom = $(''#cFilterFromDate'').val();
                const fallbackTo = $(''#cFilterToDate'').val();

                procParam += `@LoginID=${window.UserID}`;
                procParam += `,@ViewAll=${isViewAll}`;

                if (!isViewAll) {
                    const effectiveFrom = fromDate || fallbackFrom;
                    const effectiveTo = toDate || fallbackTo;
                    if (effectiveFrom && effectiveTo) {
                        procParam += `,@FromDate=''${effectiveFrom}''`;
                        procParam += `,@ToDate=''${effectiveTo}''`;
                    }
                }

                procParam += `,@EmployeeID=''${InstanceFullNameP3D009B3C43384C5D9FEB98249D80341C.option(''value'') || ''''}''`;

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
                    : "content_time DESC"; // này cho mặc định. tự chỉnh theo menu mỗi người

                params.push("@Sort", "ORDER BY " + sort);

                // Search
                if (_currentKeyword) {
                    params.push("@SearchValue", _currentKeyword);
                    params.push("@ColumnSearch", "content_time,content_topic,content_link,FullName,ProduceName");
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
        const gridInstance = InstanceGridContentPostP6746D3214A5E49509BAC1F9F68B7D9C2;

           if (!contentToolbarConfigured) {
                    configureContentGridToolbar(gridInstance);
                    contentToolbarConfigured = true;
                }

        gridInstance.beginUpdate();
        gridInstance.option("columnAutoWidth", true);
        gridInstance.option("wordWrapEnabled", true);
        gridInstance.option("allowColumnResizing", true);
        gridInstance.option("columnResizingMode", "widget");
        gridInstance.option("columnHidingEnabled", false);
        gridInstance.option("customizeColumns", function (columns) {
            columns.forEach(function (col) {
                if (col.dataField === "content_link") {
                    col.width = 250;
                }
            });
        });
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
        gridInstance.option("dataSource", dataStore_GridContentPost);
        gridInstance.option("height", getGridHeight());
        gridInstance.option("onOptionChanged", function (e) {
            if (e.name === "searchPanel" && e.fullName === "searchPanel.text") {
                const raw = e.value || "";
                let t = String(raw);
                _currentKeyword = t.trim();
                _pageCache = {};
            }
        });
        gridInstance.endUpdate();
    }

    function loadContent(fromDate = null, toDate = null) {
        ReloadData(fromDate, toDate);
    }

    function renderContentTable(data) {
        const displayData = data || contentList;
        const $tbody = $(''#contentTableBody'');
        $tbody.empty();
        displayData.forEach((item, index) => {
            const dateStr = item.content_time ? new Date(item.content_time).toLocaleDateString(''vi-VN'') : ''N/A'';
            const statusClass = item.content_status === ''Đã đăng'' ? ''status-posted'' : ''status-pending'';
            const statusBadge = `<span class="status-badge ${statusClass}">${item.content_status || ''''}</span>`;

            let displayLink = item.content_link || '''';
            let hrefLink = displayLink;
            if (displayLink && !displayLink.startsWith(''http://'') && !displayLink.startsWith(''https://'')) {
                hrefLink = ''https://'' + displayLink;
            }

            const $row = $(`
                    <tr onclick="editContent(${item.ID})">
                        <td>${index + 1}</td>

                        <td>${dateStr}</td>
                        <td>${item.content_topic || ''''}</td>
                        <td>${statusBadge}</td>
                        <td>${item.content_type || ''''}</td>
                        <td onclick="event.stopPropagation()">
                            ${displayLink ? `<a href="${hrefLink}" target="_blank" class="btn btn-sm btn-link text-info p-0">Xem link</a>` : ''N/A''}
                        </td>
                        <td onclick="event.stopPropagation()">
                            <button class="btn btn-sm btn-outline-primary" onclick="editContent(${item.ID})">Sửa</button>
                            <button class="btn btn-sm btn-outline-danger" onclick="deleteContent(${item.ID})">Xóa</button>
                        </td>
                    </tr>
                `);
            $tbody.append($row);
        });
    }

    function openContentModal() {
        // Instancecontent_statusP32144D2FBF5643D297D3468D313DB721
        // InstanceTypeP6575D537E6A84FDCB9FEF0598C3225D3
        // Instancecontent_linkPE14756C910FB424FAAC3D199CF26E66B
        // Instancecontent_noteP100654C6A52D411EBB7A1D90474F0CA9
        // Instancecontent_timeP12E37DAC57B14527ACB0C26B07261B59
        // content_topicP5213D52BF78449138563C8ADE0F89DF3RealInstance

        // Bỏ event để tránh auto save
        _autoSavecontent_timeP12E37DAC57B14527ACB0C26B07261B59 = false;
        _autoSavecontent_statusP32144D2FBF5643D297D3468D313DB721 = false;
        _autoSaveTypeP6575D537E6A84FDCB9FEF0598C3225D3 = false;
        _autoSavecontent_linkPE14756C910FB424FAAC3D199CF26E66B = false;
        _autoSavecontent_noteP100654C6A52D411EBB7A1D90474F0CA9 = false;
        _autoSavecontent_timeP12E37DAC57B14527ACB0C26B07261B59 = false;
        _autoSavecontent_topicP5213D52BF78449138563C8ADE0F89DF3 = false;

        const today = new Date().toISOString();

        let obj = {
            content_status: 1,
            content_type: null,
            content_link: '''',
            content_note: '''',
            content_time: today,
            content_topic: ''''
        };

        '
            + (select loadData from tblCommonControlType_Signed where UID = 'P32144D2FBF5643D297D3468D313DB721')
        +(select loadData from tblCommonControlType_Signed where UID = 'P6575D537E6A84FDCB9FEF0598C3225D3')
        +(select loadData from tblCommonControlType_Signed where UID = 'PE14756C910FB424FAAC3D199CF26E66B')
        +(select loadData from tblCommonControlType_Signed where UID = 'P100654C6A52D411EBB7A1D90474F0CA9')
        +(select loadData from tblCommonControlType_Signed where UID = 'P12E37DAC57B14527ACB0C26B07261B59')
        +(select loadData from tblCommonControlType_Signed where UID = 'P5213D52BF78449138563C8ADE0F89DF3') +N'

        window.currentRecordID_ID = null;
        currentEditId = null;
        contentAttachedFiles = [];
        cAttachRender();
        $(''#contentModalTitle'').text(''Thêm nội dung mới'');

        // Show attachment section for new content
        $(''#cAttachZone'').parent().parent().show();

        $(''#contentComponent_btnSaveContent'').show();

        const myModal = new bootstrap.Modal(document.getElementById(''contentModal''));
        myModal.show();
    }


    function openDetailID(obj) {

        // Lock ô Ghi chú ngay khi bắt đầu gọi API
        const _rtEl = document.getElementById(''P100654C6A52D411EBB7A1D90474F0CA9'');
        if (_rtEl && !_rtEl.querySelector(''.c-field-loading'')) {
            _rtEl.style.position = ''relative'';
            const _lk = document.createElement(''div'');

            _lk.className = ''c-field-loading'';
            _rtEl.appendChild(_lk);
        }

        AjaxHPAParadise({
            data: {
                name: "sp_CRM_getContentPostByID",
                param: ["ID", obj.ID, "LoginID", window.UserID]
            },
            success: function (data) {
                // Unlock sau khi API trả về
                if (_rtEl) { const _lk = _rtEl.querySelector(''.c-field-loading''); if (_lk) _lk.remove(); }
                try {
                    if (typeof data == "string" && !IsNullOrEmpty(data)) {
                        data = data.includes("{") ? data : EncryptionStringDecryption(data);
                    }
                    let dataObject = JSON.parse(data);
                    let newData = dataObject.data[0];
                    if (newData && newData.length > 0) {
                        obj.content_note = newData[0].content_note;
                      '
                            + (select loadData from tblCommonControlType_Signed where UID = 'P100654C6A52D411EBB7A1D90474F0CA9') + N'
    }
                } catch (error) {

    }

            },
    error: function () {
        // Unlock nếu API lỗi
        if (_rtEl) { const _lk = _rtEl.querySelector(''.c-field-loading''); if (_lk) _lk.remove(); }
    }
        })

    try {
        obj.content_status = Number(obj.content_status);
        obj.content_type = Number(obj.content_type);
    } catch (error) {

    }

    $(''#contentModalTitle'').text(''Chỉnh sửa nội dung'');

    // Ẩn nút lưu khi sửa (vì đã có auto save)
    $(''#contentComponent_btnSaveContent'').hide();

    // Hide attachment section when editing
    $(''#cAttachZone'').parent().parent().hide();

    _autoSavecontent_timeP12E37DAC57B14527ACB0C26B07261B59 = true;
    _autoSavecontent_statusP32144D2FBF5643D297D3468D313DB721 = true;
    _autoSaveTypeP6575D537E6A84FDCB9FEF0598C3225D3 = true;
    _autoSavecontent_linkPE14756C910FB424FAAC3D199CF26E66B = true;
    _autoSavecontent_noteP100654C6A52D411EBB7A1D90474F0CA9 = true;
    _autoSavecontent_timeP12E37DAC57B14527ACB0C26B07261B59 = true;
    _autoSavecontent_topicP5213D52BF78449138563C8ADE0F89DF3 = true;

    window.currentRecordID_ID = obj.ID;
    contentAttachedFiles = [];
    cAttachRender();

    '
        + (select loadData from tblCommonControlType_Signed where UID = 'P32144D2FBF5643D297D3468D313DB721')
    +(select loadData from tblCommonControlType_Signed where UID = 'P6575D537E6A84FDCB9FEF0598C3225D3')
    +(select loadData from tblCommonControlType_Signed where UID = 'PE14756C910FB424FAAC3D199CF26E66B')
    +(select loadData from tblCommonControlType_Signed where UID = 'P100654C6A52D411EBB7A1D90474F0CA9')
    +(select loadData from tblCommonControlType_Signed where UID = 'P12E37DAC57B14527ACB0C26B07261B59')
    +(select loadData from tblCommonControlType_Signed where UID = 'P5213D52BF78449138563C8ADE0F89DF3') +N'

    const myModal = new bootstrap.Modal(document.getElementById(''contentModal''));
    myModal.show();
        }

    // Biến cờ ngăn chặn click trùng lặp
let isSavingContent = false;

async function saveContent() {
    // 1. Nếu đang lưu thì chặn không cho chạy tiếp
    if (isSavingContent) return;

    // Instancecontent_statusP32144D2FBF5643D297D3468D313DB721
    // InstanceTypeP6575D537E6A84FDCB9FEF0598C3225D3
    // Instancecontent_linkPE14756C910FB424FAAC3D199CF26E66B
    // Instancecontent_noteP100654C6A52D411EBB7A1D90474F0CA9
    // Instancecontent_timeP12E37DAC57B14527ACB0C26B07261B59
    // content_topicP5213D52BF78449138563C8ADE0F89DF3

    const content_time = Instancecontent_timeP12E37DAC57B14527ACB0C26B07261B59?.option("value");
    const content_topic = Instancecontent_topicP5213D52BF78449138563C8ADE0F89DF3?.option("value");
    const content_status = Instancecontent_statusP32144D2FBF5643D297D3468D313DB721?.option("value");
    const Type = InstanceTypeP6575D537E6A84FDCB9FEF0598C3225D3?.option("value");
    const content_link = Instancecontent_linkPE14756C910FB424FAAC3D199CF26E66B?.option("value");
    const content_note = Instancecontent_noteP100654C6A52D411EBB7A1D90474F0CA9?.value;

    // Validate required fields
    if (!content_time || !content_topic || !content_status || !Type || !content_link) {
        uiManager.showAlert({ type: "error", message: "%PleaseEnterRequiredFields%" });
        return;
    }

    // 2. Đặt cờ đang lưu & Disable nút Lưu (nếu có element)
    isSavingContent = true;
    const saveBtn = document.getElementById(''contentComponent_btnSaveContent''); // Thay id nút lưu tương ứng
    if (saveBtn) saveBtn.disabled = true;

    try {
        _autoSavecontent_statusP32144D2FBF5643D297D3468D313DB721 = false;
        _autoSaveTypeP6575D537E6A84FDCB9FEF0598C3225D3 = false;
        _autoSavecontent_linkPE14756C910FB424FAAC3D199CF26E66B = false;
        _autoSavecontent_noteP100654C6A52D411EBB7A1D90474F0CA9 = false;
        _autoSavecontent_timeP12E37DAC57B14527ACB0C26B07261B59 = false;
        _autoSavecontent_topicP5213D52BF78449138563C8ADE0F89DF3 = false;

        let formattedTime = "";
        try {
            if (content_time) {
                let dt = new Date(content_time);
                if (!isNaN(dt.getTime())) {
                    let yyyy = dt.getFullYear();
                    let mm = String(dt.getMonth() + 1).padStart(2, "0");
                    let dd = String(dt.getDate()).padStart(2, "0");
                    let hh = String(dt.getHours()).padStart(2, "0");
                    let mi = String(dt.getMinutes()).padStart(2, "0");
                    let ss = String(dt.getSeconds()).padStart(2, "0");
                    formattedTime = yyyy + "-" + mm + "-" + dd + " " + hh + ":" + mi + ":" + ss;
                } else {
                    formattedTime = String(content_time);
                }
            }
        } catch(e) { formattedTime = String(content_time || ""); }

        AjaxHPAParadise({
            data: {
                name: ''sp_CRM_SaveKPIContent'',
                param: [
                    ''@LoginID'', window.UserID || LoginID,
                    ''@LanguageID'', window.LanguageID || LanguageID,
                    ''@ID'', window.currentRecordID_ID || currentEditId || 0,
                    ''@Mode'', 1,
                    ''@content_time'', formattedTime,
                    ''@content_topic'', content_topic,
                    ''@content_status'', content_status,
                    ''@Type'', Type,
                    ''@content_link'', content_link,
                    ''@content_note'', content_note || ''''
                ]
            },
            success: async function (res) {
                try {
                    let data = typeof res === ''string'' ? JSON.parse(res) : res;
                    let savedID = null;
                    if (data && data.data && data.data[0] && data.data[0][0]) {
                        savedID = data.data[0][0].ID;
                    }

                    if (savedID || (data && data.data)) {
                        // Lấy các file đã upload thành công (có uploadedPath)
                        const uploadedFiles = contentAttachedFiles.filter(function (f) { return f.uploadedPath; });
                        if (uploadedFiles.length > 0 && savedID) {
                            const filePaths = uploadedFiles.map(function (f) { return f.uploadedPath; });
                            try {
                                await AjaxHPAParadiseParadiseAsync({
                                    data: {
                                        name: ''sp_SaveAttachmentFiles'',
                                        param: [
                                            ''RecordID'', savedID,
                                            ''TableName'', ''tblCRM_KPIContent'',
                                            ''LoginID'', LoginID,
                                            ''FilePaths'', JSON.stringify(filePaths)
                                        ]
                                    }
                                });
                            } catch (e) {
                                console.warn(''[ContentAttach] Lưu đính kèm lỗi:'', e);
                            }
                        }
                        uiManager.showAlert({ type: "success", message: "%SaveSuccess%" });
                        contentAttachedFiles = [];
                        cAttachRender();
                        const modalEl = document.getElementById(''contentModal'');
                        let instance = bootstrap.Modal.getInstance(modalEl);
                        if (!instance) instance = new bootstrap.Modal(modalEl);
                        instance.hide();
                        
                        // Force refresh DevExpress DataGrid
                        if (window.InstanceGridContentPostP6746D3214A5E49509BAC1F9F68B7D9C2) {
                            window.InstanceGridContentPostP6746D3214A5E49509BAC1F9F68B7D9C2.refresh();
                        }
                        if (typeof filterC === ''function'') filterC();
                        else ReloadData();
                    } else {
                        uiManager.showAlert({ type: "error", message: "%errorNotify%" });
                    }
                } finally {
                    isSavingContent = false;
                    if (saveBtn) saveBtn.disabled = false;
                }
            },
            error: function (err) {
                console.error("Lỗi khi lưu dữ liệu:", err);
                uiManager.showAlert({ type: "error", message: "%errorNotify%" });
                isSavingContent = false;
                if (saveBtn) saveBtn.disabled = false;
            }
        });
    } catch(err) {
        isSavingContent = false;
        if (saveBtn) saveBtn.disabled = false;
    }
}

    async function deleteContent(id) {

        showConfirmPopup({
            title: "%Common_Confirm_DeleteTitle%",
            message: "%sptblfilesapprovaldelete_action%",
            YesText: "%Delete%",
            NoText: "%Cancel%",

            onYes: async () => {
                AjaxHPAParadise({
                    data: {
                        name: ''sp_CRM_SaveKPIContent'',
                        param: [
                            ''@LoginID'', window.UserID || LoginID,
                            ''@LanguageID'', window.LanguageID || LanguageID,
                            ''@ID'', id,
                            ''@Mode'', 2
                        ]
                    },
                    success: function (res) {
                        uiManager.showAlert({ type: "success", message: "%DeleteSuccess%" });
                        if (window.InstanceGridContentPostP6746D3214A5E49509BAC1F9F68B7D9C2) {
                            window.InstanceGridContentPostP6746D3214A5E49509BAC1F9F68B7D9C2.refresh();
                        }
                        if (typeof filterC === ''function'') filterC();
                        else ReloadData();
                    },
                    error: function (err) {
                        console.error("Lỗi xóa dữ liệu:", err);
                        uiManager.showAlert({ type: "error", message: "%errorNotify%" });
                    }
                });
            },
            onNo: () => {
            }
        });

    }

    function filterC() {
        const fromDate = $(''#cFilterFromDate'').val();
        const toDate = $(''#cFilterToDate'').val();


        if (!fromDate || !toDate) {
            uiManager.showAlert({ type: "error", message: "%PleaseEnterFromDateToDate%" });
            return;
        }

        if (fromDate > toDate) {
            uiManager.showAlert({ type: "error", message: "%InvalidDateRange%" });

            return;
        }

        ReloadData(fromDate, toDate);
    }

    function resetFilterC() {
        const today = new Date();
        const thirtyDaysAgo = new Date(today.getTime() - (30 * 24 * 60 * 60 * 1000));

        const formatLocalDate = (date) => {
            return String(date.getFullYear()).padStart(4, ''0'') + ''-'' +
                String(date.getMonth() + 1).padStart(2, ''0'') + ''-'' +
                String(date.getDate()).padStart(2, ''0'');
        };

        const fromDateStr = formatLocalDate(thirtyDaysAgo);
        const toDateStr = formatLocalDate(today);

        $(''#cFilterFromDate'').val(fromDateStr);
        $(''#cFilterToDate'').val(toDateStr);

        // Reset: Load tất cả dữ liệu (không filter theo ngày)
        ReloadData();
    }



    // Export functions to window scope for HTML onclick handlers
    window.openContentModal = openContentModal;
    window.editContent = openDetailID; // Sử dụng openDetailID thay vì editContent
    window.openDetailID = openDetailID;
    window.saveContent = saveContent;
    window.saveFunction = async function (dataJSON, idValsJSON) {
        try {
            await saveContent();
        } catch (e) {
            console.warn("[AutoSave]", e);
        }
        return { data: [ [{ Status: "SUCCESS", ID: window.currentRecordID_ID || 0 }] ] };
    };
    window.deleteContent = deleteContent;
    window.filterC = filterC;
    window.resetFilterC = resetFilterC;
    window.loadContent = loadContent;
    window.ReloadData = ReloadData;

    // Lần đầu load: không filter, hiển thị tất cả dữ liệu
    if (window.FromDateKPI && window.ToDateKPI) {
        ReloadData(window.FromDateKPI, window.ToDateKPI, window.EmployeeIDsKPI ? window.EmployeeIDsKPI : null, 0);
        $(''#cFilterViewAll'').prop(''checked'', false);
    } else {
        ReloadData(null, null, null, 1);
    }

    }) ();
</script>
</div>
    '

    SELECT @html AS html;
    -- EXEC sptblCommonControlType_Signed_Duc 'sp_KPIContentPost_html'
    -- EXEC sp_GenerateHTMLScript_new 'sp_KPIContentPost_html'
    -- EXEC sp_GenerateHTMLScript 'sp_Dashboard_Mobile_beta'
END
GO

-- ===================================================================
-- BƯỚC 2: CHUẨN HÓA STORED PROCEDURE ĐIỀU PHỐI [dbo].[sp_KPIContentPost]
-- ===================================================================
ALTER PROCEDURE [dbo].[sp_KPIContentPost](
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
    WHERE TableName = 'sp_KPIContentPost'
      AND ScreenType = -1
      AND LanguageID = @LanguageID;
END
GO

-- ===================================================================
-- BƯỚC 3: BIÊN DỊCH MÃ NGUỒN GIAO DIỆN VÀO BẢNG CACHE VÀ CẬP NHẬT VERSION
-- ===================================================================
IF OBJECT_ID('dbo.sp_GenerateHTMLScript_new', 'P') IS NOT NULL
BEGIN
    EXEC sp_GenerateHTMLScript_new 'sp_KPIContentPost_html', 'VN', 'sp_KPIContentPost';
    EXEC sp_GenerateHTMLScript_new 'sp_KPIContentPost_html', 'EN', 'sp_KPIContentPost';
END
ELSE
BEGIN
    EXEC sp_GenerateHTMLScript 'sp_KPIContentPost_html';
END
GO
