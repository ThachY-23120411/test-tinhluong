CREATE PROCEDURE [dbo].[sp_Sub_SubProduct_html]
 @LoginID INT = 3,
 @LanguageID VARCHAR(2) = 'VN',
 @isWeb int = 1
AS
BEGIN
 SET NOCOUNT ON;

 DECLARE @html nvarchar(max);
 SET @html = N'<style>
  #sp_Sub_SubProduct_html .badge-status {
    padding: 0.25rem 0.75rem;
    border-radius: 999px;
    font-size: 0.75rem;
    font-weight: 700;
    display: inline-block;
    color: #fff;
  }
  #sp_Sub_SubProduct_html .btn-add-SubProduct {
    white-space: nowrap;
    padding: 6px 18px;
    font-weight: 500;
    font-size: 0.9rem;
    border: none;
    box-shadow: 0 2px 4px rgba(74, 158, 15, 0.2);
    transition: background-color 0.2s;
  }

        /* ================= RESPONSIVE TOOLBAR & SEARCH UX (COMPACT & ADAPTIVE) ================= */
        #sp_Sub_SubProduct_html {
            min-width: 0;
            max-width: 100%;
        }
        #sp_Sub_SubProduct_html .dx-toolbar,
        #sp_Sub_SubProduct_html .dx-toolbar .dx-toolbar-items-container {
            height: auto !important;
            min-width: 0;
            overflow: visible !important;
        }
        #sp_Sub_SubProduct_html .dx-toolbar .dx-toolbar-items-container {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 8px;
        }
        #sp_Sub_SubProduct_html .dx-toolbar .dx-toolbar-before,
        #sp_Sub_SubProduct_html .dx-toolbar .dx-toolbar-after {
            position: static;
            transform: none;
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 8px;
            min-width: 0;
            padding: 0;
        }
        #sp_Sub_SubProduct_html .dx-toolbar .dx-toolbar-after {
            margin-left: auto;
            padding-right: 8px !important;
            box-sizing: border-box;
        }
        #sp_Sub_SubProduct_html .dx-toolbar .dx-toolbar-item {
            flex: 0 0 auto;
            padding: 0;
            min-width: 0;
        }
        /* Ẩn tiêu đề và mô tả quản lý phân hệ (Subsystem) */
        #sp_Sub_SubProduct_html .header-section {
            display: none !important;
        }

        /* DevExtreme Search Box & Button UX (report_1B fix) */
        #gridSubProductList .dx-toolbar .dx-toolbar-after { padding-right: 8px !important; box-sizing: border-box; }
        #gridSubProductList .dx-datagrid-search-panel {
            height: 32px !important;
            min-height: 32px !important;
            max-height: 32px !important;
            padding-top: 0 !important;
            padding-bottom: 0 !important;
            box-sizing: border-box !important;
            background-color: #2b3035 !important;
            border: 1px solid #495057 !important;
            border-radius: 4px !important;
            color: #e9ecef !important;
        }
        #gridSubProductList .dx-datagrid-search-panel .dx-texteditor-container,
        #gridSubProductList .dx-datagrid-search-panel .dx-texteditor-input-container { height: 100% !important; min-height: 0 !important; max-height: 100% !important; box-sizing: border-box !important; }
        #gridSubProductList .dx-datagrid-search-panel .dx-texteditor-input { height: 100% !important; min-height: 0 !important; box-sizing: border-box !important; padding-top: 0 !important; padding-bottom: 0 !important; background-color: transparent !important; color: #e9ecef !important; }
        #gridSubProductList .dx-datagrid-search-panel .dx-icon-search { color: #adb5bd !important; }

        [data-bs-theme="light"] #gridSubProductList .dx-datagrid-search-panel,
        [data-bs-theme="light"] #gridSubProductList .dx-datagrid-search-panel:is(:hover, .dx-state-hover, .dx-state-focused, :focus-within) { background: #fff !important; color: #000 !important; border-color: #ced4da !important; }
        [data-bs-theme="light"] #gridSubProductList .dx-datagrid-search-panel .dx-texteditor-input,
        [data-bs-theme="light"] #gridSubProductList .dx-datagrid-search-panel:is(:hover, .dx-state-hover, .dx-state-focused, :focus-within) .dx-texteditor-input { background: #fff !important; color: #000 !important; }
        [data-bs-theme="light"] #gridSubProductList .dx-datagrid-search-panel .dx-icon,
        [data-bs-theme="light"] #gridSubProductList .dx-datagrid-search-panel .dx-placeholder,
        [data-bs-theme="light"] #gridSubProductList .dx-datagrid-search-panel .dx-placeholder::before,
        [data-bs-theme="light"] #gridSubProductList .dx-datagrid-search-panel input::placeholder { color: #6c757d !important; }
        #gridSubProductList .dx-toolbar .dx-button { padding: 0 !important; border-radius: 4px !important; font-size: 12px !important; }
        #gridSubProductList .dx-toolbar .dx-button .dx-button-content { padding: 6px 12px !important; }
    </style>

<div id="sp_Sub_SubProduct_html">
  <div class="header-section pb-3">
    <div
      class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-3"
    >
      <div>
        <h3 class="mb-1 fw-bold">
          <i class="bi bi-grid-fill me-2"></i>%SubsystemManagementTitle%
        </h3>
        <p class="mb-0 opacity-75">%SubsystemManagementSubtitle%</p>
      </div>
    </div>
  </div>
  <div id="gridSubProductList" style="height: 100%"></div>
</div>
<script>
  (() => {
    let api = true; // m?c d?nh load call API. n?u mu?n tìm ki?m ch? load l?i dataSource dã load thì set = false
    let DataSource = [];
    let _pageCache = {};
    let _currentKeyword = "";
    let dataStore_gridSubProductList = null;

    window.InstancegridSubProductListP8F9FB1B1CC3A4599BCFD3BE6C5D75A53 = null;
    // Thêm responsive styles cho grid header
    const stylegridSubProductList = document.createElement("style");
    stylegridSubProductList.textContent = `
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
    document.head.appendChild(stylegridSubProductList);

    // Helper normalize function: bỏ dấu - dùng chung cho search/grid
    window.normalizeVietnameseText =
      window.normalizeVietnameseText ||
      function (value) {
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
    let gridName = "gridSubProductList";
    //window.hpaColumnChooser = window.hpaColumnChooser || { saveTimers: {} };

    InstancegridSubProductListP8F9FB1B1CC3A4599BCFD3BE6C5D75A53 = $("#gridSubProductList")
      .dxDataGrid({
        dataSource: [],
        keyExpr: "SubID",
        height: "100%",
        width: "100%",
        showBorders: true,
        showRowLines: true,
        rowAlternationEnabled: false,
        hoverStateEnabled: false,
        //columnAutoWidth: false,
        allowColumnReordering: true,
        allowColumnResizing: true,
        //columnResizingMode: "widget",
        columnResizingMode: "nextColumn",
        columnMinWidth: 80,
        wordWrapEnabled: true,
        scrolling: {
          mode: "standard",
          showScrollbar: "onHover",
        },
        paging: {
          enabled: true,
          pageSize: 50,
        },

        selection: {
          mode: "single",
          showCheckBoxesMode: "none",
          allowSelectAll: false,
        },

        searchPanel: {
          visible: true,
          width: 400,
          highlightSearchResults: false,
          highlightCaseSensitive: false,
          placeholder: "Tìm kiếm theo nội dung",
        },

        stateStoring: {
          enabled: false,
          type: "localStorage",
          storageKey: "gridState_gridSubProductList",
        },
        groupPanel: { visible: false },
        editing: {
          mode: "cell",
          allowUpdating: false,
        },
        rowDragging: {
          allowReordering: false,
          showDragIcons: false,
        },
        noDataText: "Không có dữ liệu",
        columns: [
          {
            dataField: "SubName",
            caption: "%GridSubsystemName%",
            width: 400,
            alignment: "left",
          },

          {
            dataField: "SubLicensePrice",
            caption: "%GridLicensePrice%",
            width: 300,
            alignment: "left",
            format: "#,##0 đ",
          },

          {
            dataField: "SubCustomizePrice",
            caption: "%GridImplementationPrice%",
            width: 300,
            alignment: "left",
            allowSorting: true,
            format: "#,##0 đ",
          },

          {
            dataField: "Priority",
            caption: "%GridPriority%",
            width: 300,
            alignment: "left",
            allowSorting: true,        
          },
            {
              caption: "%Action%",
              type: "buttons",
              width: 200,
              name: "updateBtn",
              buttons: [
                {
                  hint: "Sửa",
                  icon: "edit",
                  onClick: function (e) {
                    let key = e.row.data.SubID
                    if (["Android", "iOS"].includes(getMobileOperatingSystem())) {
                          OpenFormParamMobile(`sp_Sub_CUSubProduct`,{SubID: key});
                      } else {
                        openFormParam(`sp_Sub_CUSubProduct`, {SubID: key});
                      }
                  },
                },
              ],
            },
        ],
          /*onRowDblClick: function(e) {
             if (["Android", "iOS"].includes(getMobileOperatingSystem())) {
                      OpenFormParamMobile(`sp_Sub_CUSubProduct`,{SubID: e.key});
                  } else {
                    openFormParam(`sp_Sub_CUSubProduct`, {SubID: e.key});
                  }
          },*/
          onToolbarPreparing: function (e) {
            e.toolbarOptions.items.unshift({
              location: "after",
              template: function () {
                const $wrap = $(
                  ''<div class="toolbar-right d-flex align-items-center gap-2"></div>'',
                );
                const $btnAdd =
                  $(`<button class="btn btn-add-SubProduct btn-success">
                                              <i class="bi bi-plus-lg"></i> Thêm phân hệ
                                                  </button>
                                                  `);
                $btnAdd.off("click").on("click", function () {
                       if (["Android", "iOS"].includes(getMobileOperatingSystem())) {
                        OpenFormParamMobile(`sp_Sub_CUSubProduct`);
                    } else {
                        openFormParam(`sp_Sub_CUSubProduct`);
                    }
                });
                const $btnGroup = $(
                  ''<div class="d-flex align-items-center gap-2"></div>'',
                );
                $btnGroup.append($btnAdd);
                $wrap.append($btnGroup);
                return $wrap;
              },
            },)
          }
      })
      .dxDataGrid("instance");

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

    if (!window.syncSharedGridData) {
      window.syncSharedGridData = function (name) {
        const registry = window.hpaSharedGridDataSources || {};
        const entry = registry[name];
        if (!entry || typeof entry.syncFromGrid !== "function") {
          console.warn("[SharedGrid] Grid", name, "cannot sync");
          return [];
        }
        return entry.syncFromGrid();
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
      const primaryKeyField = "SubID";

      const loginValue =
        typeof window.UserID !== "undefined"
          ? window.UserID
          : typeof LoginID !== "undefined"
            ? LoginID
            : null;
      const languageValue =
        typeof window.LanguageID !== "undefined"
          ? window.LanguageID
          : typeof LanguageID !== "undefined"
            ? LanguageID
            : null;

      const snapshotGridData = function (instance) {
        if (!instance) return [];
        try {
          // Ưu tiên đọc raw dataSource trước - luôn có FULL data
          // kể cả khi toolbar search/filter đang active
          if (typeof instance.option === "function") {
            const rawData = instance.option("dataSource");
            if (Array.isArray(rawData) && rawData.length > 0) {
              return rawData.map(function (item) {
                return item && typeof item === "object"
                  ? Object.assign({}, item)
                  : item;
              });
            }
          }

          // Fallback: ds.items() - CHÚ Ý: chỉ trả về filtered rows
          if (typeof instance.getDataSource === "function") {
            const ds = instance.getDataSource();
            if (ds && typeof ds.items === "function") {
              const dsItems = ds.items();
              if (Array.isArray(dsItems) && dsItems.length > 0) {
                return dsItems.map(function (item) {
                  return item && typeof item === "object"
                    ? Object.assign({}, item)
                    : item;
                });
              }
            }
          }
        } catch (snapshotErr) {
          console.warn(
            "[SharedGrid] Unable to snapshot grid data",
            snapshotErr,
          );
        }
        return [];
      };

      let sharedEntry = window.hpaSharedGridDataSources[sharedKey];
      if (!sharedEntry) {
        sharedEntry = {
          data: [],

          subscribers: [],
          loading: false,
        };
      }

      sharedEntry.primaryKey = sharedEntry.primaryKey || primaryKeyField;
      sharedEntry.data = Array.isArray(sharedEntry.data)
        ? sharedEntry.data
        : [];
      sharedEntry.subscribers = Array.isArray(sharedEntry.subscribers)
        ? sharedEntry.subscribers
        : [];

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
          if (
            (keyValue === undefined || keyValue === null) &&
            rowData &&
            rowData[keyField] !== undefined
          ) {
            keyValue = rowData[keyField];
          }

          if (keyValue === undefined || keyValue === null) {
            console.warn(
              "[SharedGrid] Missing key when applying row changes for",
              sharedKey,
            );
            return Promise.resolve(false);
          }

          if (typeof this.ensureLocalData === "function") {
            this.ensureLocalData();
          }

          const compare =
            opts.strict === true
              ? function (candidate) {
                  return candidate === keyValue;
                }
              : function (candidate) {
                  if (candidate === undefined || candidate === null)
                    return candidate === keyValue;
                  if (keyValue === undefined || keyValue === null) return false;
                  return String(candidate) === String(keyValue);
                };

          const nextData = Array.isArray(this.data) ? this.data.slice() : [];
          let targetIndex = nextData.findIndex(function (item) {
            return item ? compare(item[keyField]) : false;
          });

          const normalizedRow = Object.assign(
            {},
            targetIndex > -1 ? nextData[targetIndex] : {},
            rowData,
          );

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
            console.warn(
              "[SharedGrid] Missing key when removing row for",
              sharedKey,
            );
            return Promise.resolve(false);
          }

          if (typeof this.ensureLocalData === "function") {
            this.ensureLocalData();
          }

          const filtered = (Array.isArray(this.data) ? this.data : []).filter(
            function (item) {
              if (!item) return true;
              const candidate = item[keyField];
              if (opts.strict === true) {
                return candidate !== keyValue;
              }

              if (candidate === undefined || candidate === null) {
                return keyValue !== candidate;
              }
              return String(candidate) !== String(keyValue);
            },
          );

          if (
            filtered.length ===
            (Array.isArray(this.data) ? this.data.length : 0)
          ) {
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

      sharedEntry.instance =
        InstancegridSubProductListP8F9FB1B1CC3A4599BCFD3BE6C5D75A53;

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

      // Gọi sau khi API reload data mới để sync lại cache
      sharedEntry.syncFromGrid = function () {
        const fresh = snapshotGridData(this.instance);
        if (fresh.length > 0) {
          this.data = fresh;
        }
        return this.data;
      };

      window.hpaSharedGridDataSources[sharedKey] = sharedEntry;
    })();

    window.currentRecordID_SubID = null;

    function clearPageCache() {
      _pageCache = {};
    }

    function getGridHeight() {
      const gridEl =
        InstancegridSubProductListP8F9FB1B1CC3A4599BCFD3BE6C5D75A53.element();
      const domElement = gridEl.jquery ? gridEl[0] : gridEl;
      const top = domElement.getBoundingClientRect().top;
      return window.innerHeight - top - 20;
    }

    function ReloadData(pageNumber, pageSize, keyword = null) {
      _pageCache = {};

      let _currentKeyword = String(
        keyword != null
          ? keyword
          : InstancegridSubProductListP8F9FB1B1CC3A4599BCFD3BE6C5D75A53.option(
              "searchPanel.text",
            ) || "",
      ).trim();

      function _applyRecord(results) {
        window.syncSharedGridData("gridSubProductList");
      }

      dataStore_gridSubProductList = new DevExpress.data.CustomStore({
        key: "SubID",
        load: function (loadOptions) {
          const deferred = $.Deferred();

          if (!api) {
            const results = DataSource || [];
            const skip = loadOptions.skip || 0;
            const take = loadOptions.take || 50;
            const pageData = results.slice(skip, skip + take);
            deferred.resolve({
              data: pageData,
              totalCount: results.length,
            });
            api = true;
            return deferred.promise();
          }

          let params = [];

          // SP nghiệp vụ
          params.push("@ProcName", "sp_Sub_SubProduct_Get");

          // Tham số của tên thủ tục load Data
          let procParam = "";
          // @LoginID = window.UserID, @LanguageID = window.LanguageID,......

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
            ? loadOptions.sort
                .map((s) => s.selector + (s.desc ? " DESC" : " ASC"))
                .join(",")
            : "SubID ASC"; // này cho mặc định. tự chỉnh theo menu mỗi người

          params.push("@Sort", "ORDER BY " + sort);

          // Search
          if (_currentKeyword) {
            params.push("@SearchValue", _currentKeyword);
            params.push("@ColumnSearch", "");
            // tên cột muốn search, không dc để trống nếu có search
          }

          // Filter
          if (loadOptions.filter) {
            // Kiểm tra filter item có phải function không
            const isJSFunction = (item) => typeof item === "function";

            const hasFunction = JSON.stringify(
              loadOptions.filter,
              (key, val) => {
                if (typeof val === "function") return "FUNCTION";
                return val;
              },
            ).includes("FUNCTION");

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
            let selectGroup = "",
              groupBy = "GROUP BY ";
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
            const summary = loadOptions.totalSummary.map((item) => {
              const type =
                item.summaryType === "custom"
                  ? `count(CASE WHEN [${item.selector}] = 1 THEN 1 END) as ${item.selector}_COUNT`
                  : `${item.summaryType}([${item.selector}]) as ${item.selector}_${item.summaryType.toUpperCase()}`;
              return type;
            });
            params.push("@TotalSummary", summary.join(", "));
          }

          AjaxHPAParadise({
            data: {
              name: "sp_LoadGridUsingAPI",
              param: params,
            },
            success: function (res) {
              const json = typeof res === "string" ? JSON.parse(res) : res;
              const results = Array.isArray(json?.data?.[0])
                ? json.data[0]
                : [];

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
            },
          });

          return deferred.promise();
        },
      });

      const gridInstance =
        InstancegridSubProductListP8F9FB1B1CC3A4599BCFD3BE6C5D75A53;
      gridInstance.beginUpdate();
      gridInstance.option("remoteOperations", {
        paging: true,
        filtering: true,
        sorting: true,
        searching: true,
      });

      // scrolling mode, nếu phân trang bình thường thì bỏ scrolling
      gridInstance.option("scrolling.mode", "infinite");
      gridInstance.option("scrolling.rowRenderingMode", "virtual");
      gridInstance.option("scrolling.preloadEnabled", false);

      gridInstance.option("paging.enabled", true);
      gridInstance.option("paging.pageSize", 50);
      gridInstance.option("pager.visible", false); // bật cái này để hiện số trang, dùng cho list click vô số trang rồi mở trang đó.
      gridInstance.option("pager.allowedPageSizes", [50]);
      gridInstance.option("searchPanel.highlightSearchText", false);
      gridInstance.option("dataSource", dataStore_gridSubProductList);
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
  

    ReloadData();
  })();
</script>

 '
 SELECT @html as html
  -- exec sp_GenerateHTMLScript_new 'sp_Sub_SubProduct_html'

END
