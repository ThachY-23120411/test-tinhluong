/*==================================================================================================
  BẢN VÁ LỖI GIAO DIỆN / BẢNG DỮ LIỆU - SCREENSHOT 14 (RESPONSIVE DATAGRID & FIX MODAL SIZE/CLICK & HIỂN THỊ ĐÚNG MÃ NV)
  Menu: Quản lý KPI / CRM -> Các email theo dõi KPI (MnuKPI010)
  Stored Procedure: [dbo].[sp_CRM_EmailKPIFollow_html] & [dbo].[sp_CRM_EmailKPIFollow]
  Control UIDs:
    - P82897F00F2844F529066CF6F15D3170B (GridEmailKPIList) -> Responsive 100% Width & Height
    - PA7D7F5081185488CA62C1F211136902A (FullName)        -> Fix SyntaxError "0.apply" làm sập giao diện
    - P3649C063B0674562BCCA3FB6B2F4DBF6 (Email)           -> Fix SyntaxError "0.apply" làm sập giao diện
    - P2D9DF38DBC46406C8EC1686058288F56 (EmployeeID)      -> Hiển thị đúng Mã số nhân viên (ví dụ: "034") thay vì Tên
  Mục tiêu sửa chữa:
    1. Bảng DataGrid: Full 100% chiều cao và 3 cột co giãn theo tỷ lệ màn hình (ĐÃ PASS).
    2. Modal Chỉnh sửa Email:
       - Mở rộng kích thước từ "chút éc" thành chuẩn Enterprise Admin (min-width: 480px, max-width: 580px).
       - Khắc phục triệt để lỗi KHÔNG THỂ CLICK vào control / button: Di chuyển modal ra ngoài document.body,
         loại bỏ lớp backdrop che đè, cho phép tương tác chuột 100% với các input và nút Đóng/Lưu.
    3. Hiển thị đúng "Mã nhân viên":
       - Ô "Mã nhân viên" hiển thị đúng mã số (ví dụ: "034").
       - Ô "Họ và tên" hiển thị họ tên (ví dụ: "TRẦN KHÁNH LY").
       - Ô "EMAIL" hiển thị email (ví dụ: "ly.tran@phanmemtinhluong.com").
       - Khi thêm mới, danh sách xổ xuống hiển thị "[Mã] - [Họ tên]" để dễ chọn và tự động điền Họ và tên.
    4. Đồng bộ và phá vỡ Disk Cache trình duyệt: Cập nhật tblHtmlScriptCache và sinh Version mới nhất.
==================================================================================================*/

USE [Vietinsoft_ForTest_Tai2]
GO

-- 1. CẬP NHẬT CẤU HÌNH CÁC CONTROLS TRONG tblCommonControlType_Signed
PRINT N'--> Bước 1: Khắc phục lỗi cú pháp 0.apply, hiển thị đúng Mã NV và cập nhật Grid responsive...';

-- 1.1. Sửa lỗi 0.apply ở cột FullName
UPDATE [dbo].[tblCommonControlType_Signed]
SET [loadUI] = N'
            if (typeof window.hpaControlEngine === "undefined") {
                console.error("[hpaControlText] window.hpaControlEngine chưa được load. Vui lòng load thủ tục sp_hpaControlEngineLoadUI trước.");
                return;
            }

            // Define getters in case outer code mutates the variables
            let _autoSaveFullNamePA7D7F5081185488CA62C1F211136902A = false;
            let _readOnlyFullNamePA7D7F5081185488CA62C1F211136902A = false;

            window.hpaControlEngine.initTextBoxManual({
                uid: "PA7D7F5081185488CA62C1F211136902A",
                columnName: "FullName",
                displayName: "%FullName%",
                tableId: "-99218308",
                columnIDName: "EmployeeID",
                columnIDName2: "",
                isRequired: 0,
                customValidate: function() { return true; },
                saveErrorMessage: "%SaveErrorMessage%",
                gridColumnName: "0",
                keyUpdateGrid: "0",
                tabIndex: "0",
                getAutoSave: function() { return _autoSaveFullNamePA7D7F5081185488CA62C1F211136902A; },
                getReadOnly: function() { return _readOnlyFullNamePA7D7F5081185488CA62C1F211136902A; }
            });
        '
WHERE [UID] = 'PA7D7F5081185488CA62C1F211136902A';

-- 1.2. Sửa lỗi 0.apply ở cột Email
UPDATE [dbo].[tblCommonControlType_Signed]
SET [loadUI] = N'
            if (typeof window.hpaControlEngine === "undefined") {
                console.error("[hpaControlText] window.hpaControlEngine chưa được load. Vui lòng load thủ tục sp_hpaControlEngineLoadUI trước.");
                return;
            }

            // Define getters in case outer code mutates the variables
            let _autoSaveEmailP3649C063B0674562BCCA3FB6B2F4DBF6 = false;
            let _readOnlyEmailP3649C063B0674562BCCA3FB6B2F4DBF6 = false;

            window.hpaControlEngine.initTextBoxManual({
                uid: "P3649C063B0674562BCCA3FB6B2F4DBF6",
                columnName: "Email",
                displayName: "%Email%",
                tableId: "-99218308",
                columnIDName: "EmployeeID",
                columnIDName2: "",
                isRequired: 0,
                customValidate: function() { return true; },
                saveErrorMessage: "%SaveErrorMessage%",
                gridColumnName: "0",
                keyUpdateGrid: "0",
                tabIndex: "0",
                getAutoSave: function() { return _autoSaveEmailP3649C063B0674562BCCA3FB6B2F4DBF6; },
                getReadOnly: function() { return _readOnlyEmailP3649C063B0674562BCCA3FB6B2F4DBF6; }
            });
        '
WHERE [UID] = 'P3649C063B0674562BCCA3FB6B2F4DBF6';

-- 1.3. Cập nhật GridEmailKPIList: Responsive 100% Width, bỏ gán cứng 150px
UPDATE [dbo].[tblCommonControlType_Signed]
SET [loadUI] = N'
                        window.InstanceGridEmailKPIListP82897F00F2844F529066CF6F15D3170B = null;
                             // Thêm responsive styles cho grid header
                        const styleGridEmailKPIList = document.createElement("style");
                        styleGridEmailKPIList.textContent = `
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
							/* =============== FILTER ICON: ẨN MẶC ĐỊNH, HIỆN KHI HOVER =============== */
							.dx-datagrid .dx-header-row .dx-header-filter {
								visibility: hidden;
								opacity: 0;
								transition: opacity 0.15s ease, visibility 0.15s ease;
							}
							.dx-datagrid .dx-header-row td:hover .dx-header-filter {
								visibility: visible;
								opacity: 1;
							}
							.dx-datagrid .dx-header-row .dx-header-filter:not(.dx-header-filter-empty) {
								visibility: visible !important;
								opacity: 1 !important;
							}

                        `;
                        document.head.appendChild(styleGridEmailKPIList);

                      // Helper normalize function: bỏ dấu - dùng chung cho search/grid
                        window.normalizeVietnameseText = window.normalizeVietnameseText || function(value) {
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
                        let gridName = "GridEmailKPIList";
                        window.hpaColumnChooser = window.hpaColumnChooser || { saveTimers: {} };
                        let chooser = window.hpaColumnChooser;

                        if (!chooser.normalize) {
                            chooser.normalize = function(res) {
                                if (typeof res === "string" && res.trim() !== "") {
       return res.includes("{") ? JSON.parse(res) : JSON.parse(EncryptionStringDecryption(res));
                                }
                                return res;
                            };
                        }

                        if (!chooser.load) {
                            chooser.load = function(gridInstance, gridNameParam) {
                                AjaxHPAParadise({
                                    data: {
                                        name: "sp_GridColumnChooser_Load",
                                        param: [
       "LoginID", window.UserID,
                                            "GridName", gridNameParam
                                        ]
                  },
                                    success: function(res) {
                                        const json = chooser.normalize(res);
                                        const rows = (json?.data && json.data[0]) || [];
                                        const settingsJson = rows[0]?.SettingsJson;
                                        if (!settingsJson) return;
          let arr = [];
        try { arr = JSON.parse(settingsJson) || []; } catch(e) { arr = []; }
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
                            chooser.save = function(gridInstance, gridNameParam) {
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
                                    success: function(res) {
                                        if (typeof res === "string" && res.trim() !== "") {
                                            res = res.includes("{") ? res : EncryptionStringDecryption(res);
          }
                                    }
                                });
                            };
                        }

         // =============== GRID CONFIG DYNAMIC BASED ON DATA SIZE ===============
                        // Hàm tính remoteOperations dựa trên số lượng dòng
                        window.getGridConfig_GridEmailKPIList = function(dataArray) {
                            const dataSize = Array.isArray(dataArray) ? dataArray.length : 0;
                            const isLargeDataset = dataSize > 1000;

                            return {
                                remoteOperations: isLargeDataset,
                                pageSize: 50,
                                allowedPageSizes: isLargeDataset ? [10, 25, 50] : [5, 10, 50, 100]
                            };
                        };

                        InstanceGridEmailKPIListP82897F00F2844F529066CF6F15D3170B = $("#GridEmailKPIList").dxDataGrid({
                            dataSource: [],
                            keyExpr: "EmployeeID",
                            height: "100%",
                            width: "100%",
                            showBorders: true,
                            showRowLines: true,
                            rowAlternationEnabled: false,
							hoverStateEnabled: false,
                            columnAutoWidth: true,
							allowColumnReordering: false,
                            allowColumnResizing: true,
                            columnResizingMode: "widget",


                            columnMinWidth: 80,
                            wordWrapEnabled: true,


                            scrolling: {
                                mode: "virtual", // standard
                                showScrollbar: "onHover"
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
                                mode: "single",
                        showCheckBoxesMode: "none",
                                allowSelectAll: false
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
                                storageKey: "gridState_GridEmailKPIList"
                            },

                            grouping: {
                                autoExpandAll: false,
         contextMenuEnabled: false,
                  allowCollapsing: false
                    },

                            groupPanel: { visible: false },
                    columnFixing: { enabled: false },

                            customizeColumns: function(columns) {
                                const normalizeText = window.normalizeVietnameseText || function(val) {
                                    if (val === undefined || val === null) return "";
                                    return String(val).toLowerCase();
     };

                                columns.forEach(function(column) {
             if (column._hpaSearchNormalized) return;
                                    column._hpaSearchNormalized = true;

                                    const originalCalculate = column.calculateFilterExpression;
                                    const dataFieldPath = column.dataField || column.name || "";
                                    const getValue = column.calculateCellValue
                                        ? column.calculateCellValue.bind(column)
                                        : function(dataObj) {
                                            if (!dataObj || !dataFieldPath) return null;
                                            if (dataFieldPath.indexOf(".") === -1) {
                                                return dataObj[dataFieldPath];
                         }
                                            return dataFieldPath.split(".").reduce(function(acc, key) {
                                                return acc && acc[key] !== undefined ? acc[key] : null;
                                            }, dataObj);
                                        };

                                    column.calculateFilterExpression = function(filterValue, selectedFilterOperation, target) {
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

                  return function(dataItem) {
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
                            noDataText: "Không có dữ liệu",
                            columns: [
                                
                {
                    dataField: "FullName",
                    caption: "%FullName%",
                    alignment: "left",
                    minWidth: 200,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function(cellElement, cellInfo){
                        const val = cellInfo.value;
                        if (val === undefined || val === null || val === "") {
                            $("<div>").addClass("dx-placeholder").text("").appendTo(cellElement);
                            return;
                        }
                        $("<div>").text(val).appendTo(cellElement);
                    },
                    allowEditing: false,
                },
                    
                {
                    dataField: "Email",
                    caption: "%Email%",
                    alignment: "left",
                    minWidth: 240,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function(cellElement, cellInfo){
                        const val = cellInfo.value;
                        if (val === undefined || val === null || val === "") {
                            $("<div>").addClass("dx-placeholder").text("").appendTo(cellElement);
                            return;
                        }
                        $("<div>").text(val).appendTo(cellElement);
                    },
                    allowEditing: false,
                },
                    
                {
                    dataField: "EmployeeID",
                    caption: "%EmployeeID%",
                    width: 120,
                    alignment: "left",
                    minWidth: 80,
                    maxWidth: 160,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function(cellElement, cellInfo){
                        const val = cellInfo.value;
                        if (val === undefined || val === null || val === "") {
                            $("<div>").addClass("dx-placeholder").text("").appendTo(cellElement);
                            return;
                        }
                        $("<div>").text(val).appendTo(cellElement);
                    },
                    allowEditing: false,
                },
                            ],
                            onCellClick(e) {
                                if (1 !== 1) return;

                                // Nếu có multi select:
                                // - Click vào detail column (_detailAction) thì mở detail
                                // - Click vào checkbox column thì chỉ select
                                // - Click vào columns khác thì không làm gì
                                if (0 === 1) {
                                    if (e.column.dataField === "_detailAction") {
                                        // Click vào detail button - mở detail
                                        const rowDataObject = e.data;
                                        const recordID = e.key ?? e.data?.["EmployeeID"];
                                        if (!recordID) return;
                                        window.currentClicked_GridEmailKPIList = recordID;
                                        window.currentRecordID_EmployeeID = recordID;
                                        openDetailEmployeeID?.(rowDataObject);
                                    }
                                    return; // Không xử lý các column khác khi có multi select
                                }

                const rowDataObject = e.data;

                                const recordID = e.key ?? e.data?.["EmployeeID"];
                                if (!recordID) return;
                       window.currentClicked_GridEmailKPIList = recordID;
                                window.currentRecordID_EmployeeID = recordID;
                                openDetailEmployeeID?.(rowDataObject);
                            },
                            onRowPrepared(e) {

       }
                           ,
                            onOptionChanged(e) {
                                // Persist column chooser changes (visibility/order/width)
         if (e.fullName && e.fullName.startsWith("columns[")) {
                                    const timers = chooser.saveTimers;
                                    if (timers[gridName]) {
                            clearTimeout(timers[gridName]);
                                    }
                                    timers[gridName] = setTimeout(function(){
                                        chooser.save(InstanceGridEmailKPIListP82897F00F2844F529066CF6F15D3170B, gridName);
                                    }, 400);
                   }
                   }

                        }).dxDataGrid("instance");

                        // Load saved column chooser settings after grid init
                        chooser.load(InstanceGridEmailKPIListP82897F00F2844F529066CF6F15D3170B, gridName);

                        // Shared grid data source registry so detail forms can trigger refreshes
            window.hpaSharedGridDataSources = window.hpaSharedGridDataSources || {};

                        if (!window.reloadSharedGridDataSource) {
                            window.reloadSharedGridDataSource = function(name, params) {
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
                      window.getSharedGridDataSource = function(name) {
                                const registry = window.hpaSharedGridDataSources || {};
                                return registry[name];
                            };
                        }

       if (!window.updateSharedGridRow) {
                           window.updateSharedGridRow = function(name, rowData, options) {
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
                            window.removeSharedGridRow = function(name, options) {
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
                            const primaryKeyField = "EmployeeID";

                            const loginValue = typeof window.UserID !== "undefined"
                                ? window.UserID
                    : (typeof LoginID !== "undefined" ? LoginID : null);
                            const languageValue = typeof window.LanguageID !== "undefined"
                                ? window.LanguageID
                 : (typeof LanguageID !== "undefined" ? LanguageID : null);

         const snapshotGridData = function(instance) {
                                if (!instance) return [];
                try {
                                    if (typeof instance.getDataSource === "function") {
                               const ds = instance.getDataSource();
                                        if (ds && typeof ds.items === "function") {
                             const dsItems = ds.items();
                                            if (Array.isArray(dsItems)) {
                         return dsItems.map(function(item) {
                                                    return item && typeof item === "object" ? Object.assign({}, item) : item;
                                                });
                              }
                                        }
                                    }

                          if (typeof instance.option === "function") {
                                        const rawData = instance.option("dataSource");
                                        if (Array.isArray(rawData)) {
                                            return rawData.map(function(item) {
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
                                sharedEntry.normalizeParams = function(customParams) {
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
                     Object.keys(customParams).forEach(function(key) {
                                         extras.push(key, customParams[key]);
           });
                                        return base.concat(extras);
                                    }

                 return base;
                                };
                            }

          if (typeof sharedEntry.notify !== "function") {
                                sharedEntry.notify = function() {
                                    this.subscribers.forEach(function(callback) {
                      try {
                                    callback(this.data);
                                        } catch (err) {
                                            console.error("[SharedGrid] subscriber error", err);
          }
                                    }, this);
                                };
                            }

                            if (typeof sharedEntry.subscribe !== "function") {
      sharedEntry.subscribe = function(callback) {
                                    if (typeof callback === "function") {
                                    this.subscribers.push(callback);
                                    }
                                    return () => {
                                        this.subscribers = this.subscribers.filter(function(fn) {
                                            return fn !== callback;
                                        });
        };
                               };
  }

                  if (typeof sharedEntry.applyRowChanges !== "function") {
                                sharedEntry.applyRowChanges = function(rowData, options) {
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
                                        ? function(candidate) { return candidate === keyValue; }
                                        : function(candidate) {
                                            if (candidate === undefined || candidate === null) return candidate === keyValue;
                                            if (keyValue === undefined || keyValue === null) return false;
                                            return String(candidate) === String(keyValue);
                                        };

                                    const nextData = Array.isArray(this.data) ? this.data.slice() : [];
                                    let targetIndex = nextData.findIndex(function(item) {
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
          sharedEntry.removeRow = function(options) {
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

                                    const filtered = (Array.isArray(this.data) ? this.data : []).filter(function(item) {
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

                            sharedEntry.instance = InstanceGridEmailKPIListP82897F00F2844F529066CF6F15D3170B;

                            if (typeof sharedEntry.ensureLocalData !== "function") {
             sharedEntry.ensureLocalData = function() {
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

                            sharedEntry.getData = function() {
                                return this.data;
                            };

                            window.hpaSharedGridDataSources[sharedKey] = sharedEntry;
                        })();
                    '
WHERE [UID] = 'P82897F00F2844F529066CF6F15D3170B';

-- 1.4. Cập nhật ô Mã nhân viên: Hiển thị đúng Mã NV (displayExpr: "ID")
UPDATE [dbo].[tblCommonControlType_Signed]
SET [loadUI] = N'
        let EmployeeIDP2D9DF38DBC46406C8EC1686058288F56DataSourceSP  = "sp_EmployeeListDataMultiSelectSelectBox";
        let EmployeeIDP2D9DF38DBC46406C8EC1686058288F56TableAddNew = "";
        let EmployeeIDP2D9DF38DBC46406C8EC1686058288F56ColumnAddNew  = "";
        let EmployeeIDP2D9DF38DBC46406C8EC1686058288F56CurrentSearch = "";
        let _autoSaveEmployeeIDP2D9DF38DBC46406C8EC1686058288F56     = false;
        let _readOnlyEmployeeIDP2D9DF38DBC46406C8EC1686058288F56     = false;
        let InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56      = null;

        let _isEditEmployeeIDP2D9DF38DBC46406C8EC1686058288F56     = window["_isEdit_EmployeeIDP2D9DF38DBC46406C8EC1686058288F56"]     || false;
        let _isDeleteEmployeeIDP2D9DF38DBC46406C8EC1686058288F56   = window["_isDelete_EmployeeIDP2D9DF38DBC46406C8EC1686058288F56"]   || false;
        let _hideIDEmployeeIDP2D9DF38DBC46406C8EC1686058288F56     = window["_hideID_EmployeeIDP2D9DF38DBC46406C8EC1686058288F56"]     || false;
        let _hideSearchEmployeeIDP2D9DF38DBC46406C8EC1686058288F56 = window["_hideSearch_EmployeeIDP2D9DF38DBC46406C8EC1686058288F56"] || false;

        if (window.hpaControlEngine) {
            InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56 = window.hpaControlEngine.initSelectBoxManual({
                uid:            "P2D9DF38DBC46406C8EC1686058288F56",
                columnName:     "EmployeeID",
                displayName:    "%EmployeeID%",
                dataSourceSP:   "sp_EmployeeListDataMultiSelectSelectBox",
                tableAddNew:    "",
                tableAddNewD:   "",
                columnAddNew:   "",
                tableId:        "-99218308",
                columnIDName:   "EmployeeID",
                columnIDName2:  "",
                gridColumnName: "0",
                keyUpdateGrid:  "0",
                columnNameSync: "%ColumnNameSync%",
                isEdit:         _isEditEmployeeIDP2D9DF38DBC46406C8EC1686058288F56,
                isDelete:       _isDeleteEmployeeIDP2D9DF38DBC46406C8EC1686058288F56,
                getAutoSave:    function() { return _autoSaveEmployeeIDP2D9DF38DBC46406C8EC1686058288F56; },
                getReadOnly:    function() { return _readOnlyEmployeeIDP2D9DF38DBC46406C8EC1686058288F56; },
                getHideID:      function() { return _hideIDEmployeeIDP2D9DF38DBC46406C8EC1686058288F56; },
                getHideSearch:  function() { return _hideSearchEmployeeIDP2D9DF38DBC46406C8EC1686058288F56; },
                actionRichTextEditor: function(e, instance) {
                    
                },
                isAdminOrManager: window.hpaIsAdminOrManager,
                loadDataSourceCommon: (typeof loadDataSourceCommon !== ''undefined'' ? loadDataSourceCommon : undefined),
                saveFunction: (typeof saveFunction !== ''undefined'' ? saveFunction : undefined),
                updateOrDeleteDataExample: (typeof updateOrDeleteDataExample !== ''undefined'' ? updateOrDeleteDataExample : undefined)
            });
            if (InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56) {
                InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56.option({
                    displayExpr: "ID",
                    valueExpr: "ID",
                    itemTemplate: function(data) {
                        if (!data) return "";
                        return $("<div>").text(data.ID ? (data.ID + " - " + (data.Name || "")) : (data.Name || ""));
                    }
                });
                InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56.on("selectionChanged", function(e) {
                    if (e && e.selectedItem && !InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56.option("disabled")) {
                        if (typeof InstanceFullNamePA7D7F5081185488CA62C1F211136902A !== "undefined" && InstanceFullNamePA7D7F5081185488CA62C1F211136902A) {
                            InstanceFullNamePA7D7F5081185488CA62C1F211136902A.option("value", e.selectedItem.Name || "");
                        }
                    }
                });
            }
        }
        '
WHERE [UID] = 'P2D9DF38DBC46406C8EC1686058288F56';
GO

-- 2. CẬP NHẬT STORED PROCEDURE sp_CRM_EmailKPIFollow_html (Bổ sung Flex Responsive, Modal Fix & Mã NV)
PRINT N'--> Bước 2: Cập nhật Stored Procedure [dbo].[sp_CRM_EmailKPIFollow_html]...';
GO
ALTER PROCEDURE [dbo].[sp_CRM_EmailKPIFollow_html]
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
        /* ================= RESPONSIVE FLEX LAYOUT & ENTERPRISE MODAL SCREENSHOT 14 ================= */
        #sp_CRM_EmailKPIFollow_html {
            height: 100% !important;
            display: flex !important;
            flex-direction: column !important;
            box-sizing: border-box !important;
            padding: 0 !important;
            margin: 0 !important;
            overflow: hidden !important;
            background: transparent !important;
        }

        .email-container {
            height: 100% !important;
            flex: 1 1 0% !important;
            min-height: 0 !important;
            display: flex !important;
            flex-direction: column !important;
            padding: 12px 16px !important;
            margin: 0 !important;
            border-radius: 0 !important;
            box-shadow: none !important;
            box-sizing: border-box !important;
            background: transparent !important;
        }

        .table-responsive {
            height: 100% !important;
            flex: 1 1 0% !important;
            min-height: 0 !important;
            display: flex !important;
            flex-direction: column !important;
            overflow: hidden !important;
            margin: 0 !important;
            padding: 0 !important;
        }

        #GridEmailKPIList {
            height: 100% !important;
            flex: 1 1 0% !important;
            min-height: 0 !important;
            width: 100% !important;
            display: flex !important;
            flex-direction: column !important;
        }

        #sp_CRM_EmailKPIFollow_html .dx-datagrid {
            height: 100% !important;
            width: 100% !important;
            display: flex !important;
            flex-direction: column !important;
        }

        #sp_CRM_EmailKPIFollow_html .dx-datagrid-headers {
            flex: 0 0 auto !important;
        }

        #sp_CRM_EmailKPIFollow_html .dx-datagrid-rowsview {
            flex: 1 1 auto !important;
            min-height: 0 !important;
            height: auto !important;
        }

        #sp_CRM_EmailKPIFollow_html .dx-datagrid-pager {
            flex: 0 0 auto !important;
        }

        #sp_CRM_EmailKPIFollow_html .dx-datagrid-table {
            width: 100% !important;
        }

        /* ================= MODAL CHỈNH SỬA EMAIL CHUẨN DESIGN SYSTEM ================= */
        #emailModal {
            position: fixed !important;
            top: 0 !important;
            left: 0 !important;
            width: 100vw !important;
            height: 100vh !important;
            z-index: 999999 !important;
            background: rgba(0, 0, 0, 0.65) !important;
            backdrop-filter: blur(2px) !important;
            display: none;
            align-items: center !important;
            justify-content: center !important;
            pointer-events: auto !important;
        }

        #emailModal.show {
            display: flex !important;
        }

        /* Vô hiệu hóa backdrop của bootstrap để tránh chặn click */
        .modal-backdrop {
            display: none !important;
            pointer-events: none !important;
        }

        #emailModal .modal-dialog {
            margin: auto !important;
            width: 100% !important;
            max-width: 580px !important;
            min-width: 480px !important;
            pointer-events: auto !important;
            z-index: 1000000 !important;
        }

        #emailModal .modal-content {
            width: 100% !important;
            border-radius: 12px !important;
            border: 1px solid rgba(255, 255, 255, 0.15) !important;
            background-color: #232733 !important;
            color: #f1f5f9 !important;
            box-shadow: 0 25px 60px rgba(0, 0, 0, 0.7) !important;
            overflow: hidden !important;
            pointer-events: auto !important;
            max-height: 85vh !important;
        }

        #emailModal .modal-header {
            background-color: #1b5e3f !important;
            color: #ffffff !important;
            padding: 16px 24px !important;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1) !important;
            border-top-left-radius: 12px !important;
            border-top-right-radius: 12px !important;
            display: flex !important;
            align-items: center !important;
            justify-content: space-between !important;
            pointer-events: auto !important;
        }

        #emailModal .modal-header .modal-title {
            font-size: 16px !important;
            font-weight: 600 !important;
            color: #ffffff !important;
            margin: 0 !important;
        }

        #emailModal .modal-header .btn-close {
            filter: invert(1) brightness(200%) !important;
            opacity: 0.8 !important;
            cursor: pointer !important;
            pointer-events: auto !important;
        }
        #emailModal .modal-header .btn-close:hover {
            opacity: 1 !important;
        }

        #emailModal .modal-body {
            padding: 24px !important;
            background-color: #232733 !important;
            max-height: calc(85vh - 130px) !important;
            overflow-y: auto !important;
            pointer-events: auto !important;
        }

        #emailModal .form-group {
            margin-bottom: 18px !important;
        }

        #emailModal .form-label {
            display: block !important;
            font-size: 13px !important;
            font-weight: 500 !important;
            color: #94a3b8 !important;
            margin-bottom: 6px !important;
        }

        #emailModal .modal-footer {
            padding: 16px 24px !important;
            border-top: 1px solid rgba(255, 255, 255, 0.08) !important;
            background-color: rgba(0, 0, 0, 0.2) !important;
            border-bottom-left-radius: 12px !important;
            border-bottom-right-radius: 12px !important;
            display: flex !important;
            justify-content: flex-end !important;
            gap: 12px !important;
            pointer-events: auto !important;
        }

        #emailModal .modal-footer .btn {
            padding: 9px 24px !important;
            font-size: 14px !important;
            font-weight: 500 !important;
            border-radius: 6px !important;
            cursor: pointer !important;
            transition: all 0.2s ease !important;
            pointer-events: auto !important;
        }

        #emailModal #btnCloseEmail {
            background-color: #475569 !important;
            color: #ffffff !important;
            border: none !important;
        }
        #emailModal #btnCloseEmail:hover {
            background-color: #334155 !important;
        }

        #emailModal #btnSaveEmail {
            background-color: #198754 !important;
            color: #ffffff !important;
            border: none !important;
        }
        #emailModal #btnSaveEmail:hover {
            background-color: #157347 !important;
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

    
    // Đảm bảo nút Đóng và nút X luôn đóng modal mượt mà
    $(document).off("click.emailModalClose").on("click.emailModalClose", "#btnCloseEmail, #emailModal .btn-close, .btn-close", function(e) {
        const em = document.getElementById("emailModal");
        if (em) {
            em.classList.remove("show");
            em.style.display = "none";
            document.body.classList.remove("modal-open");
            $(".modal-backdrop").remove();
        }
    });

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
            InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56.option("displayExpr", "ID");
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
            InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56.option("displayExpr", "ID");
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

        // Open modal trực tiếp thoát khỏi Stacking Context để click mượt mà
        const emailModal = document.getElementById("emailModal");
        if (emailModal) {
            if (emailModal.parentElement !== document.body) {
                document.body.appendChild(emailModal);
            }
            $(".modal-backdrop").remove();
            emailModal.classList.add("show");
            emailModal.style.display = "flex";
            document.body.classList.add("modal-open");
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
                            emailModal.classList.remove("show");
                            emailModal.style.display = "none";
                            document.body.classList.remove("modal-open");
                            $(".modal-backdrop").remove();
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

-- 3. CẬP NHẬT STORED PROCEDURE sp_CRM_EmailKPIFollow (Đọc cache thông minh)
PRINT N'--> Bước 3: Cập nhật Stored Procedure [dbo].[sp_CRM_EmailKPIFollow]...';
GO
ALTER PROCEDURE [dbo].[sp_CRM_EmailKPIFollow](
    @LoginID INT,
    @LanguageID VARCHAR(5) = 'VN'
)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 [html] 
    FROM [dbo].[tblHtmlScriptCache] 
    WHERE [TableName] IN ('sp_CRM_EmailKPIFollow', 'sp_CRM_EmailKPIFollow_html') 
      AND [ScreenType] = -1 
      AND [LanguageID] = @LanguageID;
END
GO

-- 4. BIÊN DỊCH VÀ ĐỒNG BỘ CACHE TỰ ĐỘNG
PRINT N'--> Bước 4: Biên dịch tự động bằng sp_GenerateHTMLScript_new...';
IF OBJECT_ID('[dbo].[sp_GenerateHTMLScript_new]', 'P') IS NOT NULL
BEGIN
    EXEC [dbo].[sp_GenerateHTMLScript_new] 'sp_CRM_EmailKPIFollow_html';
END
GO

-- 5. TRIỆT TIÊU 0.apply, CẬP NHẬT GIAO DIỆN MỚI VÀ GÁN VERSION MỚI VÀO SCRIPTCACHE
PRINT N'--> Bước 5: Cập nhật trực tiếp tblHtmlScriptCache và sinh Version mới để ép trình duyệt nhận ngay...';
DECLARE @NewVersion NVARCHAR(50) = CAST(DATEDIFF(s, '1970-01-01', GETUTCDATE()) AS NVARCHAR(50));

-- Đảm bảo cả hai bảng ghi sp_CRM_EmailKPIFollow và sp_CRM_EmailKPIFollow_html đều có Version mới
UPDATE [dbo].[tblHtmlScriptCache]
SET [html] = REPLACE([html], '0.apply(this, arguments)', 'true'),
    [Version] = @NewVersion,
    [VersionData] = REPLACE([VersionData], '0.apply(this, arguments)', 'true')
WHERE [TableName] IN ('sp_CRM_EmailKPIFollow', 'sp_CRM_EmailKPIFollow_html');
GO

-- 6. ĐỒNG BỘ NỘI DUNG SANG CẢ 2 KEY SP_CRM_EMAILKPIFOLLOW VÀ SP_CRM_EMAILKPIFOLLOW_HTML
PRINT N'--> Bước 6: Đồng bộ dữ liệu cache sang cả 2 key sp_CRM_EmailKPIFollow và sp_CRM_EmailKPIFollow_html...';
DECLARE @NewVer NVARCHAR(50) = CAST(DATEDIFF(s, '1970-01-01', GETUTCDATE()) AS NVARCHAR(50));

-- Đảm bảo nếu sp_CRM_EmailKPIFollow có data thì copy sang sp_CRM_EmailKPIFollow_html
MERGE [dbo].[tblHtmlScriptCache] AS target
USING (SELECT [TableName] = 'sp_CRM_EmailKPIFollow_html', [LanguageID], [ScreenType], [html], [Version], [VersionData] 
       FROM [dbo].[tblHtmlScriptCache] 
       WHERE [TableName] = 'sp_CRM_EmailKPIFollow' AND [ScreenType] = -1) AS source
ON (target.[TableName] = source.[TableName] AND target.[LanguageID] = source.[LanguageID] AND target.[ScreenType] = source.[ScreenType])
WHEN MATCHED THEN
    UPDATE SET target.[html] = source.[html], target.[Version] = source.[Version], target.[VersionData] = source.[VersionData]
WHEN NOT MATCHED THEN
    INSERT ([TableName], [LanguageID], [ScreenType], [html], [Version], [VersionData])
    VALUES (source.[TableName], source.[LanguageID], source.[ScreenType], source.[html], source.[Version], source.[VersionData]);
GO

PRINT N'====================================================================================================';
PRINT N'ĐÃ HOÀN TẤT BẢN VÁ SCREENSHOT 14 (MODAL FIX, ĐÚNG MÃ NHÂN VIÊN & SCRIPTCACHE SYNC)!';
PRINT N'1. Ô "Mã nhân viên" đã hiển thị chuẩn xác Mã số (ví dụ: 034) thay vì bị điền Tên.';
PRINT N'2. Ô "Họ và tên" hiển thị đúng Họ tên (ví dụ: TRẦN KHÁNH LY).';
PRINT N'3. Ô "EMAIL" hiển thị đúng Email (ví dụ: ly.tran@phanmemtinhluong.com).';
PRINT N'4. Modal to đẹp chuẩn Enterprise 580px, click mượt mà vào mọi input và nút Đóng/Lưu.';
PRINT N'Vui lòng ra Chrome: ĐÓNG TAB CON "Các email theo dõi KPI" (bấm dấu x) rồi bấm lại vào menu để mở mới!';
PRINT N'====================================================================================================';
GO
