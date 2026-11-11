const fs = require('fs');
const path = require('path');

function buildFixBugSql() {
  const origin = fs.readFileSync('fix-bug/lich_su_nhap_kho/origin.sql', 'utf8');
  console.log('Origin length:', origin.length);

  // 1. Replace CREATE PROCEDURE [dbo].[sp_WH_InventoryImport_html] \n as
  let modified = origin.replace(
    /CREATE\s+PROCEDURE\s+\[dbo\]\.\[sp_WH_InventoryImport_html\]\s*[\r\n]+\s*as/i,
    `ALTER PROCEDURE [dbo].[sp_WH_InventoryImport_html]
AS
BEGIN
\tSET NOCOUNT ON;`
  );

  // 2. Replace the CSS block (lines 16 to 420 in origin)
  const cssTargetRegex = /<style>[\s\S]*?<\/style>/;
  const newCss = `<style>
/* ============================================================================
   LỊCH SỬ NHẬP KHO (sp_WH_InventoryImport_html) - UNIFIED DARK THEME & RESPONSIVE
   ============================================================================ */
#sp_WH_InventoryImport_html {
    width: 100% !important;
    max-width: 100% !important;
    min-width: 0 !important;
    box-sizing: border-box !important;
}

#sp_WH_InventoryImport_html .container-fluid {
    padding-left: 16px !important;
    padding-right: 16px !important;
    margin-top: 10px !important;
    max-width: 100% !important;
    min-width: 0 !important;
    box-sizing: border-box !important;
}

/* --- DATAGRID CONTAINER --- */
#gridInventoryImport {
    width: 100% !important;
    max-width: 100% !important;
    min-width: 0 !important;
    box-sizing: border-box !important;
}

#gridInventoryImport .dx-datagrid {
    max-width: 100% !important;
    font-size: 13px !important;
}

#gridInventoryImport .dx-datagrid-headers,
#gridInventoryImport .dx-datagrid-rowsview,
#gridInventoryImport .dx-datagrid-total-footer {
    overflow-x: auto !important;
}

#gridInventoryImport .dx-datagrid-headers .dx-header-row > td {
    font-weight: 600 !important;
    vertical-align: middle !important;
    white-space: nowrap !important;
}

#gridInventoryImport .dx-datagrid-rowsview .dx-row > td {
    vertical-align: middle !important;
}

/* FIX CHE KHUẤT DGV: Tự động co giãn theo chiều cao toolbar, không để headers đè lên toolbar */
#gridInventoryImport .dx-datagrid-header-panel {
    height: auto !important;
    overflow: visible !important;
    padding: 4px 0 8px 0 !important;
}

/* --- UNIFIED FLUID TOOLBAR (DÀN ĐỀU 1 HÀNG TRÊN MÀN HÌNH CHUẨN, WRAP TỰ NHIÊN KHI HẾT CHỖ) --- */
#gridInventoryImport .dx-toolbar {
    height: auto !important;
    min-height: auto !important;
    overflow: visible !important;
    background: transparent !important;
}

#gridInventoryImport .dx-toolbar-items-container {
    height: auto !important;
    min-height: auto !important;
    display: flex !important;
    flex-wrap: wrap !important;
    align-items: center !important;
    width: 100% !important;
    padding: 0 !important;
}

/* Đưa dx-toolbar-before về normal flow (position: static) để header-panel tự động đẩy dgv xuống */
#gridInventoryImport .dx-toolbar-before {
    position: static !important;
    display: flex !important;
    flex-wrap: wrap !important;
    align-items: center !important;
    width: 100% !important;
    max-width: 100% !important;
    min-width: 0 !important;
    height: auto !important;
    padding: 0 !important;
}

#gridInventoryImport .dx-toolbar-after,
#gridInventoryImport .dx-toolbar-center {
    display: none !important;
}

#gridInventoryImport .dx-toolbar-item,
#gridInventoryImport .dx-toolbar-item-content {
    position: static !important;
    flex: 1 1 100% !important;
    width: 100% !important;
    max-width: 100% !important;
    height: auto !important;
    padding: 0 !important;
}

/* --- FILTER TOOLBAR ITEMS (TẤT CẢ PHẦN TỬ CĂN TRÁI LIỀN MẠCH, THẲNG HÀNG) --- */
#gridInventoryImport .ms-filter-toolbar {
    display: flex !important;
    flex-wrap: wrap !important;
    align-items: center !important;
    justify-content: flex-start !important;
    gap: 6px !important;
    width: 100% !important;
    max-width: 100% !important;
    min-width: 0 !important;
    box-sizing: border-box !important;
}

/* --- EMPLOYEE FILTER DISPLAY BOX (GIỮ NGUYÊN BẢN GỐC, TĂNG CHIỀU NGANG ĐỂ KHÔNG BỊ XUỐNG DÒNG) --- */
#gridInventoryImport #multilselectedEmployeeInventoryImport {
    width: 170px !important;
    max-width: 100% !important;
    min-width: 0 !important;
    white-space: nowrap !important;
}

#gridInventoryImport #multilselectedEmployeeInventoryImport * {
    white-space: nowrap !important;
}

/* --- DATE PICKERS (CLEAN SINGLE-BORDER DESIGN, 105PX VỪA VẶN dd/MM/yyyy) --- */
#gridInventoryImport .filter-from-date,
#gridInventoryImport .filter-to-date {
    width: 105px !important;
    min-width: 105px !important;
    height: 32px !important;
    min-height: 32px !important;
    max-height: 32px !important;
    background-color: #212529 !important;
    border: 1px solid #3e444a !important;
    border-radius: 4px !important;
    box-sizing: border-box !important;
    transition: border-color 0.2s, box-shadow 0.2s !important;
}

#gridInventoryImport .filter-from-date.dx-editor-outlined,
#gridInventoryImport .filter-to-date.dx-editor-outlined {
    border: 1px solid #3e444a !important;
}

#gridInventoryImport .filter-from-date:hover,
#gridInventoryImport .filter-to-date:hover,
#gridInventoryImport .filter-from-date.dx-state-focused,
#gridInventoryImport .filter-to-date.dx-state-focused {
    border-color: #198754 !important;
}

#gridInventoryImport .filter-from-date .dx-dropdowneditor-input-wrapper,
#gridInventoryImport .filter-to-date .dx-dropdowneditor-input-wrapper,
#gridInventoryImport .filter-from-date .dx-texteditor-container,
#gridInventoryImport .filter-to-date .dx-texteditor-container {
    border: none !important;
    background: transparent !important;
    height: 30px !important;
}

#gridInventoryImport .filter-from-date .dx-texteditor-input,
#gridInventoryImport .filter-to-date .dx-texteditor-input {
    color: #ffffff !important;
    background-color: transparent !important;
    height: 30px !important;
    font-size: 12px !important;
    padding: 0 4px !important;
    border: none !important;
    box-sizing: border-box !important;
}

#gridInventoryImport .filter-from-date .dx-dropdowneditor-button,
#gridInventoryImport .filter-to-date .dx-dropdowneditor-button {
    width: 24px !important;
    min-width: 24px !important;
}

#gridInventoryImport .filter-from-date .dx-dropdowneditor-icon,
#gridInventoryImport .filter-to-date .dx-dropdowneditor-icon {
    color: #8b949e !important;
}

/* --- ACTION BUTTONS (GỌN GÀNG, ĐỒNG BỘ MÀU XANH PARADISE) --- */
#gridInventoryImport .btn-add-inventory {
    height: 32px !important;
    min-height: 32px !important;
    padding: 0 8px !important;
    font-size: 12px !important;
    font-weight: 500 !important;
    border-radius: 4px !important;
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    gap: 5px !important;
    white-space: nowrap !important;
    box-sizing: border-box !important;
    transition: all 0.2s !important;
    box-shadow: none !important;
}

#gridInventoryImport .btn-add-inventory.btn-success {
    background-color: #198754 !important;
    border: 1px solid #198754 !important;
    color: #ffffff !important;
}

#gridInventoryImport .btn-add-inventory.btn-success:hover {
    background-color: #157347 !important;
    border-color: #146c43 !important;
}

#gridInventoryImport .btn-add-inventory.btn-outline-success {
    background-color: transparent !important;
    border: 1px solid #198754 !important;
    color: #198754 !important;
}

#gridInventoryImport .btn-add-inventory.btn-outline-success:hover {
    background-color: #198754 !important;
    color: #ffffff !important;
}

/* --- CHECKBOXES IN TOOLBAR --- */
#gridInventoryImport .toolbar-checkbox-wrap {
    display: inline-flex !important;
    align-items: center !important;
    gap: 8px !important;
    padding: 0 2px !important;
    height: 32px !important;
}

#gridInventoryImport .toolbar-checkbox-item {
    display: inline-flex !important;
    align-items: center !important;
    gap: 5px !important;
    cursor: pointer !important;
    margin: 0 !important;
    user-select: none !important;
}

#gridInventoryImport .toolbar-checkbox-item input[type="checkbox"] {
    width: 15px !important;
    height: 15px !important;
    accent-color: #198754 !important;
    cursor: pointer !important;
    margin: 0 !important;
}

#gridInventoryImport .toolbar-checkbox-item label,
#gridInventoryImport .toolbar-checkbox-label {
    font-size: 12px !important;
    color: #adb5bd !important;
    cursor: pointer !important;
    margin: 0 !important;
    font-weight: 400 !important;
    white-space: nowrap !important;
}

/* --- COMPACT FLUID SEARCH BOX (KHÔNG BỊ BÓNG MA, CĂN PHẢI, HIỂN THỊ ĐẦY ĐỦ TEXT) --- */
#gridInventoryImport .filter-search-box {
    height: 32px !important;
    min-height: 32px !important;
    max-height: 32px !important;
    width: 185px !important;
    flex: 0 0 185px !important;
    min-width: 160px !important;
    max-width: 220px !important;
    background-color: #212529 !important;
    border: 1px solid #3e444a !important;
    border-radius: 4px !important;
    display: inline-flex !important;
    align-items: center !important;
    padding: 0 8px !important;
    box-sizing: border-box !important;
    transition: border-color 0.2s !important;
}

#gridInventoryImport .filter-search-box:hover,
#gridInventoryImport .filter-search-box:focus-within {
    border-color: #198754 !important;
}

#gridInventoryImport .filter-search-box i {
    color: #8b949e !important;
    font-size: 12px !important;
    margin-right: 6px !important;
}

#gridInventoryImport .filter-search-box input {
    border: none !important;
    background: transparent !important;
    color: #ffffff !important;
    font-size: 12px !important;
    width: 100% !important;
    outline: none !important;
    padding: 0 !important;
}

#gridInventoryImport .filter-search-box input::placeholder {
    color: #8b949e !important;
    font-size: 12px !important;
    opacity: 1 !important;
}

/* --- RIGHT-ALIGNED ACTIONS (+ THÊM MỚI & SEARCH BOX CĂN PHẢI) --- */
#gridInventoryImport .toolbar-right-actions {
    display: flex !important;
    align-items: center !important;
    gap: 6px !important;
    margin-left: auto !important;
    flex: 0 0 auto !important;
}

@media (max-width: 480px) {
    #gridInventoryImport .toolbar-right-actions {
        width: 100% !important;
        margin-left: 0 !important;
        justify-content: space-between !important;
    }
    #gridInventoryImport .filter-search-box {
        flex: 1 1 auto !important;
        max-width: 100% !important;
    }
}
</style>`;

  modified = modified.replace(cssTargetRegex, newCss);

  // 3. Set searchPanel: { visible: false } in grid options to eliminate redundant DevExtreme search box
  const oldSearchPanelRegex = /searchPanel:\s*\{[\s\S]*?placeholder:\s*"Tìm kiếm theo nội dung",\s*\},/;
  const newSearchPanel = `searchPanel: { visible: false },`;
  modified = modified.replace(oldSearchPanelRegex, newSearchPanel);

  // 4. Refactor onToolbarPreparing:
  // - Put ALL controls (Employee, From, To, Action buttons, Checkboxes, Add button, Search box) into ONE unified container
  // - Wrap naturally line-by-line across all window snap layouts / resolutions
  const oldToolbarRegex = /onToolbarPreparing:\s*function\s*\(e\)\s*\{[\s\S]*?onRowDblClick:\s*function\s*\(e\)/;
  const newToolbarCode = `onToolbarPreparing: function (e) {
            e.toolbarOptions.items.unshift({
              location: "before",
              template: function (data, index, element) {
                const $container = $(\`
                  <div class="ms-filter-toolbar"></div>
                \`);

                let $employeeDiv;
                if (window.EmployeeID_Login) {
                  $employeeDiv = $(\`
                    <div style="display:flex;align-items:center;gap:5px;flex:0 0 auto;">
                      <label style="font-size:11px;color:#64748b;white-space:nowrap;margin:0;">Nhân viên:</label>
                      <div id="multilselectedEmployeeInventoryImport" style="width:170px;white-space:nowrap;"></div>
                    </div>
                  \`);
                }

                const $fromDiv = $(\`
                  <div style="display:flex;align-items:center;gap:5px;flex:0 0 auto;">
                    <label style="font-size:12px;color:#adb5bd;white-space:nowrap;margin:0;">Từ:</label>
                    <div class="filter-from-date"></div>
                  </div>
                \`);

                let InstanceFromDate = $fromDiv
                  .find(".filter-from-date")
                  .dxDateBox({
                    width: 105,
                    type: "date",
                    disabled: true,
                    displayFormat: "dd/MM/yyyy",
                    value: new Date(new Date().getFullYear(), new Date().getMonth(), 1),
                    onValueChanged: function (e) {
                      fromDateValue = e.value;
                    }
                  })
                  .dxDateBox("instance");

                const $toDiv = $(\`
                  <div style="display:flex;align-items:center;gap:5px;flex:0 0 auto;">
                    <label style="font-size:12px;color:#adb5bd;white-space:nowrap;margin:0;">Đến:</label>
                    <div class="filter-to-date"></div>
                  </div>
                \`);

                let InstanceToDate = $toDiv
                  .find(".filter-to-date")
                  .dxDateBox({
                    width: 105,
                    type: "date",
                    displayFormat: "dd/MM/yyyy",
                    disabled: true,
                    value: new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0),
                    onValueChanged: function (e) {
                      toDateValue = e.value;
                    }
                  })
                  .dxDateBox("instance");

                const $actionButtonContainer = $(\`
                  <div style="display:inline-flex;gap:5px;align-items:center;flex:0 0 auto;"></div>
                \`);

                $filterBtn = $(\`<button class="btn btn-add-inventory btn-success" title="Tìm kiếm">
                    <i class="bi bi-funnel"></i> %search%
                </button>\`);

                $filterBtn.on("click", function () {
                  InstancegridInventoryImportPF1056C745EBA4177B902DDA26509CA4D.getDataSource().reload();
                });

                const $resetBtn = $(\`
                  <button class="btn btn-outline-success btn-add-inventory" title="Làm mới">
                    <i class="bi bi-arrow-clockwise"></i> Làm mới
                  </button>
                \`);

                $actionButtonContainer.append($filterBtn, $resetBtn);

                const $checkboxRow = $(\`
                  <div class="toolbar-checkbox-wrap" style="flex:0 0 auto;"></div>
                \`);

                $checkboxRow.append(\`
                  <label class="toolbar-checkbox-item">
                    <input type="checkbox" checked class="toolbar-view-all">
                    <span class="toolbar-checkbox-label">Xem tất cả</span>
                  </label>
                \`);

                if (window.EmployeeID_Login) {
                  $checkboxRow.append(\`
                    <label class="toolbar-checkbox-item">
                      <input type="checkbox" class="toolbar-only-user">
                      <span class="toolbar-checkbox-label">Chỉ xem của tôi</span>
                    </label>
                  \`);
                }

                $checkboxRow
                  .find(".toolbar-view-all")
                  .off("change")
                  .on("change", function () {
                    const checked = $(this).is(":checked");
                    isViewAll = checked;
                    InstanceToDate.option("disabled", checked);
                    InstanceFromDate.option("disabled", checked);
                    if (checked) {
                      fromDateValue = null;
                      toDateValue = null;
                    } else {
                      fromDateValue = InstanceFromDate.option("value");
                      toDateValue = InstanceToDate.option("value");
                    }
                    InstancegridInventoryImportPF1056C745EBA4177B902DDA26509CA4D.getDataSource().reload();
                    $fromDiv.css("opacity", checked ? "0.4" : "1");
                    $toDiv.css("opacity", checked ? "0.4" : "1");
                  });

                $checkboxRow
                  .find(".toolbar-only-user")
                  .off("change")
                  .on("change", function () {
                    const checked = $(this).is(":checked");
                    if (checked) {
                        InstanceEmployeeIDSelectedEmployeesp_CRM_CustomerList.option("value", EmployeeID_Login);
                    } else {
                        InstanceEmployeeIDSelectedEmployeesp_CRM_CustomerList.option("value", null);
                    }
                    InstancegridInventoryImportPF1056C745EBA4177B902DDA26509CA4D.getDataSource().reload();
                });

                const $btnAdd = $(\`<button class="btn btn-add-inventory btn-success" title="Thêm mới" style="flex:0 0 auto;">
                    <i class="bi bi-plus-lg"></i> %addnew%
                </button>\`);
                $btnAdd.off("click").on("click", function () {
                    addInventory();
                });

                const $searchDiv = $(\`
                  <div class="filter-search-box">
                    <i class="bi bi-search"></i>
                    <input type="text" placeholder="Tìm kiếm theo nội dung">
                  </div>
                \`);
                $searchDiv.find("input").on("input", function () {
                  InstancegridInventoryImportPF1056C745EBA4177B902DDA26509CA4D.searchByText($(this).val());
                });

                $resetBtn.off("click").on("click", function () {
                    isViewAll = true;
                    InstanceToDate.option("disabled", isViewAll);
                    InstanceFromDate.option("disabled", isViewAll);
                    $checkboxRow.find(".toolbar-view-all").prop("checked", true);
                    $checkboxRow.find(".toolbar-only-user").prop("checked", false);
                    fromDateValue = null;
                    toDateValue = null;
                    InstanceEmployeeIDSelectedEmployeesp_CRM_CustomerList.option("value", null);
                    $searchDiv.find("input").val("");
                    InstancegridInventoryImportPF1056C745EBA4177B902DDA26509CA4D.searchByText("");
                    InstancegridInventoryImportPF1056C745EBA4177B902DDA26509CA4D.getDataSource().reload();
                });

                const $rightActions = $(\`
                  <div class="toolbar-right-actions"></div>
                \`);
                $rightActions.append($btnAdd, $searchDiv);

                $container.append(
                  $employeeDiv || $("<div></div>"),
                  $fromDiv,
                  $toDiv,
                  $actionButtonContainer,
                  $checkboxRow,
                  $rightActions
                );

                $(element).parent().prepend($container);
              }
            });
        },

        onRowDblClick: function (e)`;

  modified = modified.replace(oldToolbarRegex, newToolbarCode);

  // 4b. Grid Options for Responsive
  const oldGridOptsRegex = /columnAutoWidth:\s*true,[\s\S]*?wordWrapEnabled:\s*true,/;
  const newGridOpts = `columnAutoWidth: false,
        allowColumnReordering: true,
        allowColumnResizing: true,
        columnResizingMode: "widget",
        columnHidingEnabled: true,
        columnMinWidth: 80,
        wordWrapEnabled: false,`;
  modified = modified.replace(oldGridOptsRegex, newGridOpts);

  // 5. Update columns to responsive proportions (Total = 100%: 18% + 14% + 24% + 22% + 16% + 6%)
  const oldColumnsRegex = /columns:\s*\[[\s\S]*?\],\s*onCellClick\(e\)/;
  const newColumnsCode = `columns: [
          {
            dataField: "InventoryCode",
            caption: "Lệnh nhập hàng",
            width: "18%",
            minWidth: 130,
            alignment: "left",
            hidingPriority: 6,
            allowSorting: true,
            allowFiltering: true,
            cellTemplate: function (cellElement, cellInfo) {
              const val = cellInfo.value;
              if (val === undefined || val === null || val === "") {
                $("<div>").addClass("dx-placeholder").text("--").appendTo(cellElement);
                return;
              }
              $("<div>").css({ fontWeight: "600", fontFamily: "monospace" }).text(val).appendTo(cellElement);
            },
            allowEditing: false,
          },
          {
            dataField: "Date",
            caption: "Ngày lập lệnh",
            width: "14%",
            minWidth: 110,
            alignment: "center",
            hidingPriority: 3,
            allowSorting: true,
            allowFiltering: true,
            cellTemplate: function (cellElement, cellInfo) {
              const val = cellInfo.value;
              if (!val || val === "") {
                $("<div>").addClass("dx-placeholder").text("--").appendTo(cellElement);
                return;
              }
              const d = new Date(val);
              const text = DevExpress.localization.formatDate(d, "dd/MM/yyyy");
              $("<div>").text(text).appendTo(cellElement);
            },
            allowEditing: false,
          },
          {
            dataField: "EmployeeID",
            caption: "Người thực hiện",
            width: "24%",
            minWidth: 160,
            alignment: "left",
            hidingPriority: 4,
            allowSorting: true,
            allowFiltering: true,
            cellTemplate: function (cellElement, cellInfo) {
              const val = cellInfo.value;
              if (!val || val === "") {
                $("<div>").addClass("dx-placeholder").text("--").appendTo(cellElement);
                return;
              }
              const ds = window["DataSource_EmployeeIDMultiselectedsp_WH_InventoryImport"];
              if (ds && Array.isArray(ds)) {
                const f = ds.find((x) => x.id == val || x.ID == val);
                if (f) {
                  $("<div>").text(f.Text || f.Name || "").appendTo(cellElement);
                  return;
                }
              }
              $("<div>").text(val).appendTo(cellElement);
            },
            allowEditing: false,
          },
          {
            dataField: "CommandTypeID",
            caption: "Loại lệnh",
            width: "22%",
            minWidth: 150,
            alignment: "left",
            hidingPriority: 2,
            allowSorting: true,
            allowFiltering: true,
            cellTemplate: function (cellElement, cellInfo) {
              const val = cellInfo.value;
              if (!val || val === "") {
                $("<div>").addClass("dx-placeholder").text("--").appendTo(cellElement);
                return;
              }
              const ds = window["DataSource_CommandTypeID"];
              if (ds && Array.isArray(ds)) {
                const f = ds.find((x) => x.id == val || x.ID == val);
                if (f) {
                  $("<div>").text(f.Text || f.Name || "").appendTo(cellElement);
                  return;
                }
              }
              $("<div>").text(val).appendTo(cellElement);
            },
            allowEditing: false,
          },
          {
            dataField: "StatusID",
            caption: "Tình trạng thực hiện",
            width: "16%",
            minWidth: 130,
            alignment: "center",
            hidingPriority: 5,
            allowSorting: true,
            allowFiltering: true,
            cellTemplate: function (cellElement, cellInfo) {
              const val = cellInfo.value;
              if (!val || val === "") {
                $("<div>").addClass("dx-placeholder").text("--").appendTo(cellElement);
                return;
              }
              $("<div>").text(val).addClass(\`text-\${cellInfo.data.Color}\`).appendTo(cellElement);
            },
            allowEditing: false,
          },
          {
            caption: "",
            width: "6%",
            minWidth: 50,
            alignment: "center",
            hidingPriority: 1,
            allowSorting: false,
            allowFiltering: false,
            cellTemplate: function (cellElement, cellInfo) {
              if (String(cellInfo.data.Status) === "2" || String(cellInfo.data.StatusID) === "2") {
                let $btn = $("<button>").addClass("btn btn-sm btn-outline-danger border-0").attr("title", "Xóa").html(''<i class="bi bi-trash"></i>'');
                $btn.on("click", async function (e) {
                  e.stopPropagation();
                  showConfirmPopup({
                    title: "%ACComfirm%",
                    message: "%Common_Confirm_DeleteTitle%",
                    YesText: "%ConfirmYes%",
                    NoText: "%cancelBtn%",
                    onYes: async () => {
                      const skeletonId = "skeleton-delete-" + Date.now();
                      const skeletonHTML = \`
                        <div id="\${skeletonId}" style="position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(var(--bs-body-bg-rgb), 0.8); z-index: 9999; display: flex; align-items: center; justify-content: center;">
                          <div style="color: var(--bs-primary); font-size: 24px; font-weight: bold; letter-spacing: 4px;">║  ║  ║</div>
                        </div>
                      \`;
                      $("body").append(skeletonHTML);
                      try {
                        let res = await AjaxHPAParadiseAsync({
                          data: { name: "spWH_DeleteInventoryImport", param: ["Action", "Delete", "InventoryCode", cellInfo.data.InventoryCode] }
                        });
                        if (res) {
                          uiManager.showAlert({ type: "success", message: "Xóa thành công!" });
                          if (typeof _pageCache !== "undefined") {
                            const deletedCode = cellInfo.data.InventoryCode;
                            Object.keys(_pageCache).forEach(key => {
                              if (_pageCache[key] && Array.isArray(_pageCache[key].data)) {
                                let originalLength = _pageCache[key].data.length;
                                _pageCache[key].data = _pageCache[key].data.filter(item => item.InventoryCode !== deletedCode);
                                let newLength = _pageCache[key].data.length;
                                if (originalLength > newLength) {
                                  _pageCache[key].totalCount = Math.max(0, _pageCache[key].totalCount - (originalLength - newLength));
                                }
                              }
                            });
                          }
                          InstancegridInventoryImportPF1056C745EBA4177B902DDA26509CA4D.getDataSource().reload();
                        } else {
                          uiManager.showAlert({ type: "warning", message: "Xóa thất bại!" });
                        }
                      } catch (err) {
                        uiManager.showAlert({ type: "danger", message: "Lỗi hệ thống!" });
                      } finally {
                        $("#" + skeletonId).remove();
                      }
                    }
                  });
                });
                cellElement.append($btn);
              }
            },
            allowEditing: false,
          },
        ],

        onCellClick(e)`;

  modified = modified.replace(oldColumnsRegex, newColumnsCode);

  // 6. Clean up procedure ending and append Step 2 & Step 3
  const lastSelectIdx = modified.lastIndexOf("select @Html");
  if (lastSelectIdx !== -1) {
    const beforeEnd = modified.substring(0, lastSelectIdx);
    const newEnding = `select @Html;
END
GO

-- ============================================================================
-- BƯỚC 2: CHUẨN HÓA STORED PROCEDURE ĐIỀU PHỐI [dbo].[sp_WH_InventoryImport]
-- ============================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_WH_InventoryImport](
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
    WHERE TableName = 'sp_WH_InventoryImport'
      AND ScreenType = -1
      AND LanguageID = @LanguageID;
END
GO

-- ============================================================================
-- BƯỚC 3: BIÊN DỊCH MÃ NGUỒN GIAO DIỆN VÀO BẢNG CACHE VÀ CẬP NHẬT VERSION
-- ============================================================================
IF OBJECT_ID('dbo.sp_GenerateHTMLScript_new', 'P') IS NOT NULL
BEGIN
    EXEC sp_GenerateHTMLScript_new 'sp_WH_InventoryImport_html', 'VN', 'sp_WH_InventoryImport';
    EXEC sp_GenerateHTMLScript_new 'sp_WH_InventoryImport_html', 'EN', 'sp_WH_InventoryImport';
END
ELSE
BEGIN
    EXEC sp_GenerateHTMLScript 'sp_WH_InventoryImport_html';
END
GO
`;
    modified = beforeEnd + newEnding;
  }

  const outPath = path.resolve('fix-bug/lich_su_nhap_kho/fix-bug.sql');
  fs.writeFileSync(outPath, modified, 'utf8');
  console.log('Saved fix-bug.sql successfully! Final Length:', modified.length);
}

buildFixBugSql();
