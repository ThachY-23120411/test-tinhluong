
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
                    width: 150,
                    alignment: "left",
                    minWidth: 80,
                    maxWidth: 400,
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
                    width: 150,
                    alignment: "left",
                    minWidth: 80,
                    maxWidth: 400,
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
                    width: 150,
                    alignment: "left",
                    minWidth: 80,
                    maxWidth: 400,
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
                    