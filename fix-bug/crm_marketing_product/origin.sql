-- ===================================================================
-- ORIGIN SOURCE CODE: TRÍCH XUẤT TỪ DATABASE (READ-ONLY)
-- Stored Procedures: [dbo].[sp_CRM_marketing_product_html] & [dbo].[sp_CRM_marketing_product]
-- Database: Vietinsoft_ForTest_Tai2
-- ===================================================================

USE [Vietinsoft_ForTest_Tai2];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_CRM_marketing_product_html]
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
        .btn-success, .btn-danger { border-radius: 4px !important; }
        .dx-button, .dx-button-content { overflow: visible !important; }
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
            gridInstance.columnOption("productID", "visibleIndex", 0);
            gridInstance.columnOption("productName", "visibleIndex", 1);
            gridInstance.columnOption("Description", "visibleIndex", 2);
            gridInstance.columnOption("SampleRule", "visibleIndex", 3);

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
                width: 900,
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
                    const $row = $("<div class=''d-flex gap-3'' style=''flex-direction: row; align-items: stretch;'' />").appendTo($form);
                    
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


CREATE PROCEDURE [dbo].sp_CRM_marketing_product
 @LoginID int = 3,
 @LanguageID varchar(2) ='VN'
as
begin
	SET NOCOUNT ON;
	select html as Col1 from tblHtmlScriptCache where TableName = 'sp_CRM_marketing_product_html' and LanguageID = @LanguageID;
end;

GO

