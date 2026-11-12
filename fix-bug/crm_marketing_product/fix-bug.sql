-- ===================================================================
-- BẢN VÁ TỔNG HỢP (PATCH SCRIPT) CHO MÀN HÌNH: SẢN PHẨM MARKETING
-- Phân hệ: Trang chủ CRM > Nhiệm vụ (MnuKPI048)
-- Stored Procedures: [dbo].[sp_CRM_marketing_product_html] & [dbo].[sp_CRM_marketing_product]
-- Database: Vietinsoft_ForTest_Tai2
-- Lỗi đã sửa:
--   1. TC-01: Fix màu chữ và độ tương phản Search Panel
--   2. Screenshot 24: Fix lỗi bộ lọc tìm kiếm (Search Filter) không hoạt động & tắt bôi đen
--   3. Nút Thêm: Đổi màu xanh rêu sang trọng #094c3a (chống chói) & mở rộng padding chống khuất chữ
--   4. Responsive UI: Chuẩn hóa Toolbar và DataGrid đa tỷ lệ màn hình theo /responsive-rules
-- Chuẩn hóa: 3 Bước Clean Code không dùng REPLACE theo quy chuẩn fix-rules
-- ===================================================================

USE [Vietinsoft_ForTest_Tai2];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*-------------------------------------------------------------------
 BƯỚC 1: CẬP NHẬT MÃ NGUỒN GIAO DIỆN SP_CRM_MARKETING_PRODUCT_HTML
 (Đã bổ sung CSS chuẩn hóa màu chữ trắng #ffffff và nền xám #212529 cho Search Panel)
--------------------------------------------------------------------*/
ALTER PROCEDURE [dbo].[sp_CRM_marketing_product_html]
    @LoginID INT = 3,
    @LanguageID VARCHAR(2) = 'VN',
    @isWeb int = 0
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @html nvarchar(max);
    SET @html = N'
    <style>
        #sp_CRM_marketing_product_html { padding: 15px; height: 100%; display: flex; flex-direction: column; gap: 15px; }
        .product-grid-container { flex: 1; min-height: 0; }
        .form-label { font-weight: bold; color: var(--paradise-color-header1); margin-bottom: 5px; display: block; }
        .btn-success, .btn-danger { border-radius: 6px !important; }
        .dx-button, .dx-button-content { overflow: visible !important; }

        /* ====== NÚT THÊM & CÁC NÚT SUCCESS: TÔNG MÀU XANH LÁ NON #258757 & NỚI RỘNG CHIỀU NGANG ====== */
        #sp_CRM_marketing_product_html .btn-success,
        #sp_CRM_marketing_product_html .dx-button-success,
        #GridProducts .dx-toolbar .btn-success,
        .dx-popup .btn-success,
        .dx-popup .dx-button-success {
            background-color: #258757 !important;
            border-color: #258757 !important;
            color: #ffffff !important;
            border-radius: 6px !important;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2) !important;
            transition: background-color 0.2s ease, border-color 0.2s ease !important;
        }

        #sp_CRM_marketing_product_html .btn-success:hover,
        #sp_CRM_marketing_product_html .dx-button-success:hover,
        #GridProducts .dx-toolbar .btn-success:hover,
        .dx-popup .btn-success:hover,
        .dx-popup .dx-button-success:hover {
            background-color: #2ca56b !important;
            border-color: #2ca56b !important;
            color: #ffffff !important;
        }

        #sp_CRM_marketing_product_html .btn-success:active,
        #sp_CRM_marketing_product_html .dx-button-success:active,
        #GridProducts .dx-toolbar .btn-success:active {
            background-color: #1e6b45 !important;
            border-color: #1e6b45 !important;
        }

        /* Khắc phục triệt để lỗi khuất chữ nút Thêm: mở rộng padding và đảm bảo text hiển thị trọn vẹn */
        #GridProducts .dx-toolbar .btn-success {
            min-width: 115px !important;
            width: auto !important;
            overflow: visible !important;
        }

        #GridProducts .dx-toolbar .btn-success .dx-button-content {
            padding: 6px 18px !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            gap: 6px !important;
            overflow: visible !important;
        }

        #GridProducts .dx-toolbar .btn-success .dx-button-text {
            overflow: visible !important;
            white-space: nowrap !important;
            text-overflow: clip !important;
            font-weight: 600 !important;
            font-size: 13.5px !important;
            color: #ffffff !important;
            letter-spacing: 0.3px !important;
        }

        #GridProducts .dx-toolbar .btn-success .dx-icon,
        #sp_CRM_marketing_product_html .btn-success .dx-icon,
        #sp_CRM_marketing_product_html .dx-button-success .dx-icon,
        .btn-success .dx-icon,
        .dx-button-success .dx-icon {
            color: #ffffff !important;
            fill: #ffffff !important;
            margin-right: 4px !important;
        }

        /* Nút Chọn cột hiển thị: Thu nhỏ width vừa vặn với icon để nằm sát gần nút Thêm */
        #GridProducts .dx-toolbar .dx-datagrid-column-chooser-button {
            min-width: 36px !important;
            max-width: 36px !important;
            width: 36px !important;
            padding: 0 !important;
            margin-right: 2px !important;
        }
        #GridProducts .dx-toolbar .dx-datagrid-column-chooser-button .dx-button-content {
            min-width: 36px !important;
            max-width: 36px !important;
            width: 36px !important;
            padding: 6px 0 !important;
            justify-content: center !important;
        }
        #GridProducts .dx-toolbar .dx-datagrid-column-chooser-button .dx-button-text {
            display: none !important;
        }
        #GridProducts .dx-toolbar .dx-item.dx-toolbar-item:has(.dx-datagrid-column-chooser-button) {
            min-width: 36px !important;
            max-width: 36px !important;
            width: 36px !important;
        }
        /* Fix hover shift bug on texteditor/textarea */
        .dx-texteditor.dx-state-hover, .dx-texteditor.dx-state-focused, .dx-texteditor:hover {
            margin-top: 0 !important;
            margin-bottom: 0 !important;
            transform: none !important;
        }
        /* Stretch dxTextArea within a 30vh container */
        .textarea-30vh .dx-texteditor-container,
        .textarea-30vh .dx-texteditor-input-container,
        .textarea-30vh textarea {
            height: auto !important;
            min-height: 30vh !important;
            flex: 1 !important;
        }
        .textarea-30vh .dx-texteditor-container {
            display: flex !important;
            flex-direction: column !important;
            width: 100% !important;
        }
    
        /* ====== FIX SEARCH FILTER CONTRAST (TC-01) & TẮT BÔI ĐEN ====== */
        .dx-datagrid-search-text {
            background-color: transparent !important;
            color: inherit !important;
        }
        #sp_CRM_marketing_product_html .dx-datagrid-search-panel,
        .dx-datagrid-search-panel {
            background-color: #212529 !important;
            border: 1px solid #3e444a !important;
            border-radius: 6px !important;
        }
        #sp_CRM_marketing_product_html .dx-datagrid-search-panel .dx-texteditor-input,
        .dx-datagrid-search-panel .dx-texteditor-input {
            color: #ffffff !important;
            background-color: transparent !important;
            font-size: 13px !important;
        }
        #sp_CRM_marketing_product_html .dx-datagrid-search-panel .dx-placeholder,
        #sp_CRM_marketing_product_html .dx-datagrid-search-panel .dx-placeholder::before,
        .dx-datagrid-search-panel .dx-placeholder,
        .dx-datagrid-search-panel .dx-placeholder::before {
            color: #adb5bd !important;
        }
        #sp_CRM_marketing_product_html .dx-datagrid-search-panel .dx-icon-search,
        #sp_CRM_marketing_product_html .dx-datagrid-search-panel .dx-icon-clear,
        .dx-datagrid-search-panel .dx-icon-search,
        .dx-datagrid-search-panel .dx-icon-clear {
            color: #adb5bd !important;
        }
        #sp_CRM_marketing_product_html .dx-datagrid-search-panel.dx-state-focused,
        #sp_CRM_marketing_product_html .dx-datagrid-search-panel:focus-within,
        .dx-datagrid-search-panel.dx-state-focused,
        .dx-datagrid-search-panel:focus-within {
            border-color: #0d6efd !important;
            box-shadow: 0 0 0 2px rgba(13, 110, 253, 0.25) !important;
        }

        /* ============================================================================
           BỘ QUY CHUẨN RESPONSIVE TOOLBAR & DATAGRID CHUẨN MỰC (/responsive-rules)
           Màn hình: Sản phẩm marketing (sp_CRM_marketing_product_html - GridProducts)
           BẢO TOÀN 100% STYLE GỐC CỦA CÁC COMPONENT (MÀU SẮC, NÚT THÊM, TÌM KIẾM NGUYÊN BẢN)
           ============================================================================ */

        /* 1. Master Layout Lock: Khóa tỷ lệ chuẩn 1440/1920, canh giữa trên 2K/4K */
        #sp_CRM_marketing_product_html {
            max-width: 1920px !important;
            margin: 0 auto !important;
            box-sizing: border-box !important;
            overflow-x: hidden !important;
        }

        /* 2. Header panel & Toolbar co giãn tự do, triệt tiêu 100% lỗi DataGrid che khuất Toolbar */
        #GridProducts .dx-datagrid-header-panel {
            height: auto !important;
            min-height: auto !important;
            overflow: visible !important;
            padding: 4px 0 8px 0 !important;
        }

        #GridProducts .dx-toolbar {
            height: auto !important;
            min-height: auto !important;
            overflow: visible !important;
            background: transparent !important;
            padding: 4px 0 !important;
            margin-bottom: 8px !important;
        }

        #GridProducts .dx-toolbar-items-container {
            height: auto !important;
            min-height: 44px !important;
            display: flex !important;
            flex-wrap: wrap !important;
            align-items: center !important;
            justify-content: flex-end !important;
            row-gap: 8px !important;
            column-gap: 8px !important;
            width: 100% !important;
            padding: 0 !important;
            overflow: visible !important;
        }

        /* Đưa dx-toolbar-before và dx-toolbar-after về Normal Document Flow */
        #GridProducts .dx-toolbar-before {
            position: static !important;
            display: flex !important;
            flex-wrap: wrap !important;
            align-items: center !important;
            min-width: 0 !important;
            height: auto !important;
            padding: 0 !important;
        }

        #GridProducts .dx-toolbar-after {
            position: static !important;
            display: flex !important;
            flex-wrap: wrap !important;
            align-items: center !important;
            justify-content: flex-end !important;
            margin-left: auto !important;
            gap: 8px !important;
            min-width: 0 !important;
            height: auto !important;
            overflow: visible !important;
            padding: 0 !important;
        }

        #GridProducts .dx-toolbar-item,
        #GridProducts .dx-toolbar-item-content {
            position: static !important;
            display: flex !important;
            align-items: center !important;
            height: auto !important;
            padding: 0 !important;
        }

        /* Khóa nguyên tử các widget chức năng: Chống co rút, chống vỡ chữ */
        #GridProducts .dx-toolbar .btn-success,
        #GridProducts .dx-toolbar .dx-button-success {
            flex-shrink: 0 !important;
            white-space: nowrap !important;
        }

        #GridProducts .dx-toolbar .dx-datagrid-column-chooser-button {
            flex-shrink: 0 !important;
        }

        /* Ô tìm kiếm Searchbox: Kích thước chuẩn 260px, co giãn linh hoạt */
        #GridProducts .dx-toolbar-item-search-panel,
        #GridProducts .dx-toolbar .dx-toolbar-after .dx-toolbar-item:has(.dx-searchbox),
        #GridProducts .dx-toolbar .dx-toolbar-after .dx-toolbar-item:has(.dx-datagrid-search-panel) {
            flex: 0 0 260px !important;
            width: 260px !important;
            min-width: 180px !important;
            max-width: 280px !important;
        }

        #GridProducts .dx-datagrid-search-panel,
        #GridProducts .dx-searchbox {
            width: 100% !important;
            min-width: 0 !important;
        }

        /* 3. Tự động dàn đều khi màn hình hẹp (Snap 1/2 <= 768px, Mobile) */
        @media (max-width: 768px) {
            #GridProducts .dx-toolbar-items-container {
                justify-content: flex-start !important;
            }

            #GridProducts .dx-toolbar-after {
                width: 100% !important;
                justify-content: space-between !important;
                margin-left: 0 !important;
                flex-wrap: wrap !important;
            }

            #GridProducts .dx-toolbar-item-search-panel,
            #GridProducts .dx-toolbar .dx-toolbar-after .dx-toolbar-item:has(.dx-searchbox),
            #GridProducts .dx-toolbar .dx-toolbar-after .dx-toolbar-item:has(.dx-datagrid-search-panel) {
                flex: 1 1 100% !important;
                width: 100% !important;
                max-width: 100% !important;
                margin-top: 4px !important;
            }

            /* Responsive cho Popup Modal Thêm/Sửa sản phẩm */
            .popup-textarea-row {
                flex-direction: column !important;
            }
        }
    </style>
    
    <div id="sp_CRM_marketing_product_html">
        <div class="product-grid-container">
            <div id="GridProducts"></div>
        </div>
    </div>
    ';
    
    SET @html = @html + N'
    <script>
      (async () => {
        let obj = {};
        let gridInstance = null;

        // 1. Khởi tạo Giao diện (loadUI)
        ' + ISNULL((SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'PD619B09BF980459DBBCA59A07FF09530'), '') + N'
        ' + ISNULL((SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'P6ED47CD861734F2C82DCD1BA7A142BBE'), '') + N'
        ' + ISNULL((SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'PDCEE8A3A1AB04B4E964DA0E886DFE66C'), '') + N'
        ' + ISNULL((SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'P0DFC1D93C3374C50BAE27EE3FAFAC6EE'), '') + N'
        ' + ISNULL((SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'PC2863E5A4EDE40B4BC6D86FE854CEC5A'), '') + N'

        // 2. Khởi tạo Dữ liệu (loadData)
        ' + ISNULL((SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'PD619B09BF980459DBBCA59A07FF09530'), '') + N'
        ' + ISNULL((SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'P6ED47CD861734F2C82DCD1BA7A142BBE'), '') + N'
        ' + ISNULL((SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'PDCEE8A3A1AB04B4E964DA0E886DFE66C'), '') + N'
        ' + ISNULL((SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'P0DFC1D93C3374C50BAE27EE3FAFAC6EE'), '') + N'
        ' + ISNULL((SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'PC2863E5A4EDE40B4BC6D86FE854CEC5A'), '') + N'
        
        try {
            gridInstance = $("#GridProducts").dxDataGrid("instance");
        } catch(ex) {}
        if (!gridInstance) {
            gridInstance = window.InstanceGridProductsPC2863E5A4EDE40B4BC6D86FE854CEC5A;
        }

        window.openDetailproductID = function(data) { showProductPopup(data); };

        if (gridInstance && typeof gridInstance.columnOption === "function") {
            // FIX SCREENSHOT 24: Xóa bỏ dummy lookup rỗng và cấu hình tìm kiếm chuẩn theo Tên sản phẩm
            // Tắt highlightSearchText (bôi đen) và tập trung lọc chính xác theo productName
            ["productID", "productName", "Description", "SampleRule"].forEach(function(col) {
                gridInstance.columnOption(col, "lookup", null);
                gridInstance.columnOption(col, "allowSearch", col === "productName");
            });
            gridInstance.option({
                searchPanel: {
                    visible: true,
                    width: 260,
                    placeholder: "%search_content%",
                    highlightSearchText: false,
                    searchVisibleColumnsOnly: false,
                    searchExpr: ["productName"]
                }
            });

            // Cấu hình Responsive cho GridProducts theo chuẩn /responsive-rules
            gridInstance.option({
                columnAutoWidth: false,
                allowColumnResizing: true,
                columnResizingMode: "widget",
                columnHidingEnabled: true,
                wordWrapEnabled: false
            });

            // Phân bổ tỷ lệ % chuẩn và hidingPriority cho 4 cột (Tổng = 100%)
            gridInstance.columnOption("productID", "visibleIndex", 0);
            gridInstance.columnOption("productID", "width", "8%");
            gridInstance.columnOption("productID", "minWidth", 50);
            gridInstance.columnOption("productID", "hidingPriority", 4);

            gridInstance.columnOption("productName", "visibleIndex", 1);
            gridInstance.columnOption("productName", "width", "24%");
            gridInstance.columnOption("productName", "minWidth", 150);
            gridInstance.columnOption("productName", "hidingPriority", 3);

            gridInstance.columnOption("Description", "visibleIndex", 2);
            gridInstance.columnOption("Description", "width", "38%");
            gridInstance.columnOption("Description", "minWidth", 200);
            gridInstance.columnOption("Description", "hidingPriority", 2);

            gridInstance.columnOption("SampleRule", "visibleIndex", 3);
            gridInstance.columnOption("SampleRule", "width", "30%");
            gridInstance.columnOption("SampleRule", "minWidth", 180);
            gridInstance.columnOption("SampleRule", "hidingPriority", 1);

            const originalToolbarHandler = gridInstance.option("onToolbarPreparing");
            gridInstance.option("onToolbarPreparing", function(e) {
                if (typeof originalToolbarHandler === "function") {
                    originalToolbarHandler(e);
                }
                
                e.toolbarOptions.items = e.toolbarOptions.items.filter(item => {
                    return !(item.widget === "dxButton" && item.options && (item.options.icon === "add" || item.options.icon === "refresh"));
                });

                let searchIndex = e.toolbarOptions.items.findIndex(item => item.name === "searchPanel");
                if (searchIndex === -1) searchIndex = e.toolbarOptions.items.length;

                e.toolbarOptions.items.splice(searchIndex, 0, {
                    location: "after",
                    widget: "dxButton",
                    options: {
                        text: "%add%",
                        icon: "add",
                        type: "success",
                        stylingMode: "contained",
                        elementAttr: { class: "btn btn-success d-flex justify-content-center align-items-center" },
                        onClick: function() {
                            showProductPopup();
                        }
                    }
                });
            });
            gridInstance.repaint();
        }

        function ReloadData() {
            let skel = null;
            if (window.uiManager && uiManager.showSkeleton) {
                skel = uiManager.showSkeleton({ target: "#GridProducts", type: "table" });
            }
            AjaxHPAParadise({
                data: {
                    name: "sp_CRM_marketing_product_CRUD",
                    param: ["ActionType", "SELECT", "LoginID", UserID, "productID", null]
                },
                success: function(res) {
                    const json = typeof res === "string" ? JSON.parse(res) : res;
                    const results = Array.isArray(json?.data?.[0]) ? json.data[0] : (json?.data?.[0] ? [json.data[0]] : []);
                    if (gridInstance) {
                        gridInstance.beginUpdate();
                        gridInstance.option("dataSource", results);
                        gridInstance.endUpdate();
                    }
                    if (skel) skel.remove();
                },
                error: function(err) {
                    console.error("Lỗi tải dữ liệu GridProducts:", err);
                    if (skel) skel.remove();
                }
            });
        }
        ReloadData();

        function showProductPopup(data = null) {
            const isEdit = !!data;
            const $popupContainer = $("<div />").appendTo("body");
            
            const popup = $popupContainer.dxPopup({
                title: isEdit ? "%UpdateProduct%" : "%AddNewProduct%",
                width: function() { return Math.min(900, $(window).width() * 0.95); },
                maxWidth: "95vw",
                maxHeight: "95vh",
                height: "auto",
                visible: true,
                closeOnOutsideClick: false,
                contentTemplate: function(contentElement) {
                    const $form = $("<div class=''p-3'' />").appendTo(contentElement);
                    
                    $("<label class=''form-label''>%productName% <span class=''text-danger''>*</span></label>").appendTo($form);
                    const txtName = $("<div class=''mb-3'' />").dxTextBox({
                        value: isEdit ? data.productName : "",
                        placeholder: "%PleaseEnterProductName%",
                        stylingMode: "outlined",
                        valueChangeEvent: "keyup",
                        onValueChanged: function(e) {
                            if (e.value && e.value.trim() !== "") {
                                e.component.option({ isValid: true });
                            }
                        }
                    }).appendTo($form).dxTextBox("instance");
                    
                    // Create horizontal layout for the two TextAreas
                    const $row = $("<div class=''d-flex gap-3 popup-textarea-row'' style=''flex-direction: row; align-items: stretch; flex-wrap: wrap;'' />").appendTo($form);
                    
                    const $colLeft = $("<div style=''flex: 1; min-width: 0; display: flex; flex-direction: column;'' />").appendTo($row);
                    $("<label class=''form-label''>%Description%</label>").appendTo($colLeft);
                    const txtDesc = $("<div class=''textarea-30vh'' style=''flex: 1; min-height: 30vh; display: flex;'' />").dxTextArea({
                        value: isEdit ? data.Description : "",
                        placeholder: "%Description%",
                        stylingMode: "outlined",
                        autoResizeEnabled: false,
                        valueChangeEvent: "keyup"
                    }).appendTo($colLeft).dxTextArea("instance");
                    
                    const $colRight = $("<div style=''flex: 1; min-width: 0; display: flex; flex-direction: column;'' />").appendTo($row);
                    $("<label class=''form-label''>%SampleRule%</label>").appendTo($colRight);
                    const txtRule = $("<div class=''textarea-30vh'' style=''flex: 1; min-height: 30vh; display: flex;'' />").dxTextArea({
                        value: isEdit ? data.SampleRule : "",
                        placeholder: "%SampleRule%",
                        stylingMode: "outlined",
                        autoResizeEnabled: false,
                        valueChangeEvent: "keyup",
                        inputAttr: { style: "font-family: monospace; line-height: 1.5;" }
                    }).appendTo($colRight).dxTextArea("instance");
                    
                    const $btnGroup = $("<div class=''d-flex justify-content-between align-items-center mt-4'' />").appendTo($form);
                    const $leftGroup = $("<div class=''d-flex gap-2'' />").appendTo($btnGroup);
                    const $rightGroup = $("<div class=''d-flex gap-2'' />").appendTo($btnGroup);
                    
                    if (isEdit) {
                        $("<div />").dxButton({
                            text: "%Delete%",
                            icon: "trash",
                            type: "danger",
                            stylingMode: "contained",
                            elementAttr: { class: "btn btn-danger d-flex justify-content-center align-items-center" },
                            onClick: function() {
                                deleteProduct(data.productID);
                                popup.hide();
                            }
                        }).appendTo($leftGroup);
                    }

                    $("<div />").dxButton({
                        text: "%Cancel%",
                        type: "normal",
                        onClick: () => popup.hide()
                    }).appendTo($rightGroup);

                    $("<div />").dxButton({
                        text: isEdit ? "%Update%" : "%Save%",
                        type: "success",
                        stylingMode: "contained",
                        elementAttr: { class: "btn btn-success d-flex justify-content-center align-items-center" },
                        onClick: async function() {
                            const payload = {
                                ActionType: isEdit ? "UPDATE" : "INSERT",
                                productID: isEdit ? data.productID : null,
                                productName: txtName.option("value"),
                                Description: txtDesc.option("value"),
                                SampleRule: txtRule.option("value"),
                                LoginID: UserID
                            };
                            
                            if (!payload.productName || payload.productName.trim() === "") {
                                txtName.option({
                                    isValid: false,
                                    validationError: { message: "%PleaseEnterProductName%" }
                                });
                                uiManager.showAlert({ type: "warning", message: "%PleaseEnterProductName%" });
                                return;
                            }

                            let skel = null;
                            if (window.uiManager && uiManager.showSkeleton) {
                                skel = uiManager.showSkeleton({ target: contentElement, type: "form" });
                            }
                            try {
                                let res = await AjaxHPAParadiseAsync({
                                    data: {
                                        name: "sp_CRM_marketing_product_CRUD",
                                        param: Object.keys(payload).flatMap(k => [k, payload[k]])
                                    }
                                });
                                let json = typeof res === "string" ? JSON.parse(res) : res;
                                if (json.data[0][0].result === "success") {
                                    uiManager.showAlert({ type: "success", message: json.data[0][0].message });
                                    popup.hide();
                                    
                                    const newID = isEdit ? data.productID : json.data[0][0].productID;
                                    const updatedRow = {
                                        productID: newID,
                                        productName: txtName.option("value"),
                                        Description: txtDesc.option("value"),
                                        SampleRule: txtRule.option("value")
                                    };
                                    if (window.updateSharedGridRow) {
                                        window.updateSharedGridRow("GridProducts", updatedRow);
                                    } else {
                                        ReloadData();
                                    }
                                }
                            } catch(ex) {
                                uiManager.showAlert({ type: "error", message: "Lỗi lưu dữ liệu" });
                            } finally {
                                if (skel) skel.remove();
                            }
                        }
                    }).appendTo($rightGroup);
                },
                onHidden: function() { $popupContainer.remove(); }
            }).dxPopup("instance");
        }

        function deleteProduct(id) {
            DevExpress.ui.dialog.confirm("%ConfirmDelete%", "%ConfirmDelete%").done(async function(result) {
                if (result) {
                    try {
                        let res = await AjaxHPAParadiseAsync({
                            data: {
                                name: "sp_CRM_marketing_product_CRUD",
                                param: ["ActionType", "DELETE", "productID", id, "LoginID", UserID]
                            }
                        });
                        let json = typeof res === "string" ? JSON.parse(res) : res;
                        if (json.data[0][0].result === "success") {
                            uiManager.showAlert({ type: "success", message: json.data[0][0].message });
                            if (window.removeSharedGridRow) {
                                window.removeSharedGridRow("GridProducts", { key: id });
                            } else {
                                ReloadData();
                            }
                        }
                    } catch(ex) {
                        uiManager.showAlert({ type: "error", message: "Lỗi khi xóa" });
                    }
                }
            });
        }
      })();
    </script>
    ';

    SELECT @html as html;
END;
GO

/*-------------------------------------------------------------------
 BƯỚC 2: CHUẨN HÓA STORED PROCEDURE ĐIỀU PHỐI SP_CRM_MARKETING_PRODUCT
 (Trỏ về đúng key quy ước hệ thống 'sp_CRM_marketing_product' & ScreenType = -1)
--------------------------------------------------------------------*/
ALTER PROCEDURE [dbo].[sp_CRM_marketing_product](
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
    WHERE TableName = 'sp_CRM_marketing_product'
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
    EXEC sp_GenerateHTMLScript_new 'sp_CRM_marketing_product_html', 'VN', 'sp_CRM_marketing_product';
    EXEC sp_GenerateHTMLScript_new 'sp_CRM_marketing_product_html', 'EN', 'sp_CRM_marketing_product';
END
ELSE
BEGIN
    EXEC sp_GenerateHTMLScript 'sp_CRM_marketing_product_html';
END
GO

PRINT N'===================================================================';
PRINT N'===> HOÀN TẤT CẬP NHẬT BẢN VÁ! MỞ TAB VÀ BẤM CTRL + F5 ĐỂ KIỂM TRA.';
PRINT N'===================================================================';
GO
