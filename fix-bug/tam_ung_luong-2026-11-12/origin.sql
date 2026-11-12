CREATE PROCEDURE [dbo].[SAL_Advance_Process_html]	
    @LoginID    INT = 3,	
    @LanguageID VARCHAR(2) = 'VN'	
AS	
BEGIN	
        DECLARE @CurrentMonth INT, @CurrentYear INT;
    SELECT TOP 1 @CurrentMonth = [Month], @CurrentYear = [Year] FROM tblCurrentWorkingMonth;
    IF @CurrentMonth IS NULL OR @CurrentMonth < 1 OR @CurrentMonth > 12
        SET @CurrentMonth = MONTH(GETDATE());
    IF @CurrentYear IS NULL OR @CurrentYear < 1900
        SET @CurrentYear = YEAR(GETDATE());
    SET NOCOUNT ON;	
    DECLARE @html NVARCHAR(MAX);	

    -- Lấy danh sách cột tiền tệ của Grid để build Summary động (tương thích SQL Server 2008 - 2022)
    DECLARE @summaryItems NVARCHAR(MAX);
    SELECT @summaryItems = STUFF((
        SELECT ',' + '{column:"' + ColumnName + '",' +
               'summaryType:"sum",' +
               'displayFormat:(window.LanguageID === "VN" ? "\u0054\u1ED5\u006E\u0067" : "Sum") + ": {0}",' +
               'valueFormat:"#,##0"}'
        FROM tblCommonControlType_Signed
        WHERE TableName      = 'SAL_Advance_Process_html'
          AND GridColumnName = 'GridSAL_Advance_Process'
          AND [Type]         = 'hpaControlMoney'
          AND Layout         = 'Grid_View'
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

    -- Dự phòng (Fallback) trong trường hợp database chưa cấu hình các cột tiền tệ cho Grid này
    IF ISNULL(@summaryItems, '') = ''
    BEGIN
        SET @summaryItems =
            '{column:"BasicSalary", summaryType:"sum", displayFormat:(window.LanguageID === "VN" ? "\u0054\u1ED5\u006E\u0067" : "Sum") + ": {0}", valueFormat:"#,##0"},' +
            '{column:"AdvanceAmount", summaryType:"sum", displayFormat:(window.LanguageID === "VN" ? "\u0054\u1ED5\u006E\u0067" : "Sum") + ": {0}", valueFormat:"#,##0"},' +
            '{column:"ActualSalary", summaryType:"sum", displayFormat:(window.LanguageID === "VN" ? "\u0054\u1ED5\u006E\u0067" : "Sum") + ": {0}", valueFormat:"#,##0"}';
    END

    SET @html = N'	
<style>	
    /* ===== TOOLBAR CUSTOM STYLES ===== */
    /* Ẩn tạm các filter controls trước khi đưa lên toolbar */
    #hidden-toolbar-items-advance {
        position: absolute;
        left: -9999px;
    }

    /* Filter items nằm trong toolbar */
    .sal-advance-toolbar-filter-item {
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .sal-advance-toolbar-filter-item span {
        font-weight: 600;
        white-space: nowrap;
        font-size: 13px;
        transition: color 0.3s ease;
    }

    .sal-advance-toolbar-filter-item .dx-texteditor-input,
    .sal-advance-toolbar-filter-item .dx-dropdowneditor-icon {
        transition: color 0.3s ease;
    }

    .toolbar-filters-wrap {
        display: flex;
        align-items: center;
        gap: 15px;
    }

    #SAL_Advance_Process .sal-advance-toolbar-filter-item {
        gap: 6px;
    }

    #SAL_Advance_Process #P13431133E9D6489CA60B01DD1C17F1F2 {
        flex: 0 0 76px !important;
        width: 76px !important;
        min-width: 76px !important;
        max-width: 76px !important;
    }

    #SAL_Advance_Process #P9F624C1BFF0846AA98AB688E66478E84 {
        flex: 0 0 88px !important;
        width: 88px !important;
        min-width: 88px !important;
        max-width: 88px !important;
    }

    #SAL_Advance_Process.sal-advance-toolbar-two-rows .dx-datagrid-header-panel .dx-toolbar,
    #SAL_Advance_Process.sal-advance-toolbar-two-rows .dx-datagrid-header-panel .dx-toolbar-items-container {
        height: 104px !important;
    }

    #SAL_Advance_Process.sal-advance-toolbar-two-rows .dx-datagrid-header-panel .dx-toolbar-items-container {
        display: grid !important;
        grid-template-columns: 1fr !important;
        grid-template-rows: 48px 48px !important;
    }

    #SAL_Advance_Process.sal-advance-toolbar-two-rows .dx-datagrid-header-panel .dx-toolbar-before,
    #SAL_Advance_Process.sal-advance-toolbar-two-rows .dx-datagrid-header-panel .dx-toolbar-after {
        position: static !important;
        width: 100% !important;
        height: 48px !important;
        display: flex !important;
        align-items: center !important;
    }

    #SAL_Advance_Process.sal-advance-toolbar-two-rows .dx-datagrid-header-panel .dx-toolbar-before {
        grid-row: 1;
        justify-content: flex-start !important;
    }

    #SAL_Advance_Process.sal-advance-toolbar-two-rows .dx-datagrid-header-panel .dx-toolbar-after {
        grid-row: 2;
        justify-content: flex-end !important;
    }

    #SAL_Advance_Process.sal-advance-toolbar-two-rows .dx-datagrid-header-panel .dx-toolbar-center {
        display: none !important;
    }

    .grid-wrapper {
        transition: background-color 0.3s ease;
    }

    #GridSAL_Advance_Process .dx-datagrid-header-panel
        .dx-button .dx-icon-add {
        display: none !important;
    }
    #GridSAL_Advance_Process .dx-datagrid-header-panel
        .dx-button:has(.dx-icon-add) {
        display: none !important;
    }

    /* Dark Mode support */
    .dark-mode .sal-advance-toolbar-filter-item span {
        color: #e4e6ef;
    }
    .dark-mode .sal-advance-toolbar-filter-item .dx-texteditor-input,
    .dark-mode .sal-advance-toolbar-filter-item .dx-dropdowneditor-icon {
        color: #e4e6ef !important;
    }
    .dark-mode .grid-wrapper {
        background: #2b2b40 !important;
    }
    #SAL_Advance_Process {
        height: calc(100vh - 110px) !important;
        max-height: calc(100vh - 110px) !important;
        width: 100% !important;
        display: flex;
        flex-direction: column;
        border-top: 1px solid var(--bs-border-color);
        overflow: hidden;
    }
</style>

<!-- ===== HIDDEN CONTAINER: Chứa filter DOM thật (ẩn bằng position:absolute, KHÔNG dùng display:none) ===== -->
<div id="hidden-toolbar-items-advance">
    <div class="toolbar-filters-wrap" id="advance-toolbar-filters">
        <div class="sal-advance-toolbar-filter-item">
            <span>%Month%</span>
            <div id="P13431133E9D6489CA60B01DD1C17F1F2"></div>
        </div>
        <div class="sal-advance-toolbar-filter-item">
            <span>%Year%</span>
            <div id="P9F624C1BFF0846AA98AB688E66478E84"></div>
        </div>
    </div>
</div>

<div id="SAL_Advance_Process">
    <!-- Khung chứa Lưới - toolbar nằm trong grid -->
    <div style="flex:1; overflow: hidden;" class="grid-wrapper">
        <div id="GridSAL_Advance_Process" style="height: 100%;"></div>
    </div>
</div>

    <script>
        (async () => {
  window["_hideID_P13431133E9D6489CA60B01DD1C17F1F2"] = true;
            window["_hideID_P9F624C1BFF0846AA98AB688E66478E84"] = true;
            _showtoolbarGrid_PC71DDD11A62E4B528C0CC0E3D1AB5929 = true

'	
    + (SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'P13431133E9D6489CA60B01DD1C17F1F2')	
    + (SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'P9F624C1BFF0846AA98AB688E66478E84')	
    + (SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'PC71DDD11A62E4B528C0CC0E3D1AB5929')	
    + N'	
        window.currentRecordID_MonthID = null;	
        window.currentRecordID_YearID = null;

        // GẮN CỨNG CŨ (ĐÃ COMMENT LẠI THEO YÊU CẦU TAIDANG):
                                
        // MỚI: Tự động dùng window.CurrentWorkingMonth / window.CurrentWorkingYear
        let initMonth = (typeof window.CurrentWorkingMonth !== "undefined" && window.CurrentWorkingMonth) ? Number(window.CurrentWorkingMonth) : ' + CAST(@CurrentMonth AS NVARCHAR(10)) + N';
        let initYear  = (typeof window.CurrentWorkingYear !== "undefined" && window.CurrentWorkingYear) ? Number(window.CurrentWorkingYear) : ' + CAST(@CurrentYear AS NVARCHAR(10)) + N';	
	
        let dataParams = {	
            get month() {	
                let inst = $("#P13431133E9D6489CA60B01DD1C17F1F2").dxSelectBox("instance");	
                return inst ? inst.option("value") : initMonth;	
            },	
            get year() {	
                let inst = $("#P9F624C1BFF0846AA98AB688E66478E84").dxSelectBox("instance");	
                return inst ? inst.option("value") : initYear;	
            },	
            isExport: false	
        };	
	
        // Tạo danh sách tháng	
        let monthList = [];	
        for (let i = 1; i <= 12; i++) {	
            monthList.push({	
                ID: i,	
  Name: i	
            });	
        }	
	
        // Tạo danh sách năm	
        let currentYearObj = initYear;	
        let yearList = [];	
        for (let i = currentYearObj - 5; i <= currentYearObj + 10; i++) {	
            yearList.push({	
                ID: i,	
                Name: i	
            });	
        }	
	
        // Khởi tạo Month SelectBox	
        let mInst = $("#P13431133E9D6489CA60B01DD1C17F1F2").dxSelectBox("instance");	
        if (mInst) {	
            mInst.option({	
                dataSource: monthList,
                valueExpr: "ID",
                displayExpr: "Name",
                width: 76,
                showClearButton: false,
                dropDownOptions: { width: 76, minWidth: 76, maxWidth: 76 },
                value: initMonth,
                onValueChanged: function(e) {
                    if (e.value) { ReloadData(); }
                }
            });	
        }	
	
        // Khởi tạo Year SelectBox	
        let yInst = $("#P9F624C1BFF0846AA98AB688E66478E84").dxSelectBox("instance");	
        if (yInst) {	
            yInst.option({	
                dataSource: yearList,
                valueExpr: "ID",
                displayExpr: "Name",
                width: 88,
                showClearButton: false,
                dropDownOptions: { width: 88, minWidth: 88, maxWidth: 88 },
                value: currentYearObj,
                onValueChanged: function(e) {
                    if (e.value) { ReloadData(); }
                }
            });	
        }	
	
            // --- HÀM XỬ LÝ NÚT IN BẢN KÝ NHẬN ---
            async function btnPrintClick() {
                DevExpress.ui.notify("%CreatingReceipt%", "info", 1500);
                try {
                    const ajaxFn = window.AjaxHPAParadiseParadiseAsync || window.AjaxHPAParadiseAsync;
                    const resExport = await ajaxFn({
                        data: {
                            name: "ExportLocationFolder",
                            param: [
                                "",
                                "EmployeeAdvance",
                                "",
                                "@Month", dataParams.month,
                                "@Year", dataParams.year,
                                "@LoginID", window.UserID || window.LoginID,
                                "@LanguageID", window.LanguageID || "VN"
                            ]
                        }
                    });

                    const resObj = typeof resExport === "string" ? JSON.parse(resExport) : resExport;
                    let filePath = "";
if (resObj.data) {
                        if (typeof resObj.data === "string") {
                            if (resObj.data.trim().startsWith("{")) {
                                try { filePath = JSON.parse(resObj.data).FilePath || resObj.data; } catch(e) { filePath = resObj.data; }
                            } else {
                                filePath = resObj.data;
                            }
                        } else {
                            filePath = resObj.data.FilePath || resObj.data;
                        }
                    } else {
                        filePath = resObj.FilePath || "";
                    }

                    if (!filePath) throw new Error("%ErrorReportFilePath%");

                    const fileDataRes = await ajaxFn({ data: { name: "ReadPathFileToByte", param: [filePath] } });
                    const fileDataObj = typeof fileDataRes === "string" ? JSON.parse(fileDataRes) : fileDataRes;
                    const fileData = fileDataObj.data;
                    if (!fileData) throw new Error("%ErrorReadFileData%");

                    let fileName = filePath.split("\\").pop();
                    if (typeof saveAsFile === "function") {
                        saveAsFile(fileName, fileData);
                    } else {
                        const byteCharacters = atob(fileData);
                        const byteNumbers = new Array(byteCharacters.length);
                        for (let i = 0; i < byteCharacters.length; i++) {
                            byteNumbers[i] = byteCharacters.charCodeAt(i);
                        }
                        const byteArray = new Uint8Array(byteNumbers);
                        const blob = new Blob([byteArray], { type: "application/octet-stream" });
                        const link = document.createElement("a");
                        link.href = window.URL.createObjectURL(blob);
                        link.download = fileName;
                        link.click();
                    }
                    DevExpress.ui.notify("%ReceiptCreatedSuccess%", "success", 2000);
                } catch (err) {
                    DevExpress.ui.notify("%ErrorPrintingReceipt%: " + err.message, "error", 3000);
                }
            }

            // --- HÀM XỬ LÝ NÚT XUẤT EXCEL ---
            async function btnExportClick() {
                let gridInstance = InstanceGridSAL_Advance_ProcessPC71DDD11A62E4B528C0CC0E3D1AB5929;
                if (!gridInstance) { DevExpress.ui.notify("%DataGridNotFound%", "error", 2000); return; }
                if (typeof ExcelJS === "undefined") { DevExpress.ui.notify("%ExcelJSLibraryNotFound%", "error", 3000); return; }

                DevExpress.ui.notify("%ExportingExcelData%", "info", 1500);

                try {
                    var workbook = new ExcelJS.Workbook();
                    var worksheet = workbook.addWorksheet(''%AdvanceSalaryTable%'');
                    await DevExpress.excelExporter.exportDataGrid({
                        component: gridInstance,
                        worksheet: worksheet,
                        autoGenerateFilter: false,
                        customizeCell: function(options) {
                            var gridCell = options.gridCell;
                            var excelCell = options.excelCell;
                            if (!gridCell || gridCell.rowType !== ''data'') return;
                            var field = gridCell.column && gridCell.column.dataField;
                            var row = gridCell.data;
                            if (!field || !row) return;
                            var raw = row[field];
                            if (field === ''HireDate'') {
                                if (raw) { var d = new Date(raw); excelCell.value = String(d.getDate()).padStart(2,''0'') + ''/'' + String(d.getMonth()+1).padStart(2,''0'') + ''/'' + d.getFullYear(); }
                                else { excelCell.value = ''''; }
                                return;
                            }
                            if (field === ''Cash'' || field === ''LockData'') { excelCell.value = raw ? ''%Yes%'' : ''%No%''; return; }
                         if ([''BasicSalary'',''AdvanceAmount'',''ActualSalary''].indexOf(field) !== -1) {
                                excelCell.value = (raw !== null && raw !== undefined) ? Number(raw) : 0;
                                excelCell.numFmt = ''#,##0''; return;
                            }
                            if ([''AttDays'',''OT150H'',''OT195H''].indexOf(field) !== -1) {
                                var num = (raw !== null && raw !== undefined) ? Number(raw) : 0;
                                excelCell.value = num;
                                excelCell.numFmt = (num % 1 !== 0) ? ''#,##0.######'' : ''#,##0''; return;
                            }
                            excelCell.value = (raw !== null && raw !== undefined) ? raw : '''';
                        }
                    });
                    var buffer = await workbook.xlsx.writeBuffer();
                    saveAs(new Blob([buffer], { type: ''application/octet-stream'' }), ''AdvanceSalaryTable_'' + dataParams.month + ''_'' + dataParams.year + ''.xlsx'');
                    DevExpress.ui.notify("%ExportExcelSuccess%", "success", 2000);
                } catch (err) {
                    DevExpress.ui.notify("%ErrorExportExcel%: " + err.message, "error", 3000);
                    console.error(err);
                }
            }


            // --- HÀM TÍNH TỔNG ĐỘNG ĐÈ LÊN SUMMARY CỦA GRID ---
            let _summaryCache = {};
            let _currentKeyword = "";

            async function fn_thanh_sumFull_SAL_Advance_Process(columnName) {
                let filterStr = "";
                let grid = $("#GridSAL_Advance_Process").dxDataGrid("instance") || (typeof InstanceGridSAL_Advance_ProcessPC71DDD11A62E4B528C0CC0E3D1AB5929 !== "undefined" ? InstanceGridSAL_Advance_ProcessPC71DDD11A62E4B528C0CC0E3D1AB5929 : null);
                if (grid) {
                    try {
                        let filterExpr = grid.getCombinedFilter();
                        if (filterExpr) {
                            filterStr = createConditionQuery(filterExpr);
                        }
                    } catch(e) {
                        console.warn("getCombinedFilter error:", e);
                    }
                }

                return new Promise((resolve) => {
                    AjaxHPAParadise({
                        data: {
                            name: "sp_thanh_sumFull_SAL_Advance_Process",
                            param: [
                                "LoginID", window.LoginID || window.UserID,
                                "Month", dataParams.month,
                                "Year", dataParams.year,
                                "LanguageID", window.LanguageID,
                                "Filters", filterStr,
                                "SearchValue", _currentKeyword || "",
                                "ColumnSearch", "DepartmentID,FullName,EmployeeID,HireDate,BasicSalary,SectionName",
                                "ColumnName", (columnName || "").trim()
                            ]
                        },
                        success: function (res) {
                            const json = typeof res === "string" ? JSON.parse(res) : res;
                            const sumVal = json?.data?.[0]?.[0]?.SumValue ?? 0;
                            resolve(sumVal);
                        },
                        error: function () {
                            resolve(0);
                        }
                    });
                });
            }

            // --- KHỞI TẠO CUSTOMSTORE ĐỂ BIND DỮ LIỆU ĐỘNG ---	
            let api = true;
            let DataSource = [];
            let dataStore_ = new DevExpress.data.CustomStore({	
    key: "EmployeeID",	
                load: function(loadOptions) {	
                    const deferred = $.Deferred();	

                    if (!api) {
                        const results = DataSource || [];
        const skip = loadOptions.skip || 0;
                        const take = loadOptions.take || 50;
                        const pageData = results.slice(skip, skip + take);
                        deferred.resolve({ data: pageData, totalCount: results.length });
                        api = true;
                        return deferred.promise();
                    }
	
                    let params = [];	
                    params.push("@ProcName", "SAL_Advance_Process");	
	
                    let procParam = "@Month=" + dataParams.month + ",@Year=" + dataParams.year + ",@LoginID=" + (window.UserID || window.LoginID) + ",@LanguageID=''" + (window.LanguageID || ''VN'') + "''";	
                    params.push("@ProcParam", procParam);	
	
                    params.push("@Take", loadOptions.take || 50);	
                    params.push("@Skip", loadOptions.skip || 0);	
	
                    if (loadOptions.requireTotalCount) {	
                        params.push("@RequireTotalCount", 1);	
                    }	
	
	
                    const sort = loadOptions.sort	
                        ? loadOptions.sort.map(s => s.selector + (s.desc ? " DESC" : " ASC")).join(",")	
                        : "EmployeeID ASC";	
                    params.push("@Sort", "ORDER BY " + sort);	
	
                    if (_currentKeyword) {
                        params.push("@SearchValue", _currentKeyword);
                        params.push("@ColumnSearch", "DepartmentID,FullName,EmployeeID,HireDate,BasicSalary,SectionName,Cash,LockData");
                    } else if (loadOptions.searchValue) {	
                        params.push("@SearchValue", loadOptions.searchValue);	
                        params.push("@ColumnSearch", "DepartmentID,FullName,EmployeeID,HireDate,BasicSalary,SectionName,Cash,LockData");	
                    }	
                    let activeFilter = loadOptions.filter;

                    if (activeFilter) {	
                        const hasFunction = JSON.stringify(activeFilter, (key, val) => {	
                            if (typeof val === "function") return "FUNCTION";	
                            return val;	
                        }).includes("FUNCTION");	
	
                        if (!hasFunction) {	
                            params.push("@Filters", createConditionQuery(activeFilter));	
                        }	
                    }	
                    let summaryKey = "";
                    let hasSummaryCache = false;

                    if (loadOptions.totalSummary) {
                        summaryKey = JSON.stringify({
                            procParam: procParam,
                            search: _currentKeyword || "",
                            filter: loadOptions.filter || null,
                            totalSummary: loadOptions.totalSummary || null
                        });
                        hasSummaryCache = !!_summaryCache[summaryKey];
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
                            }	

	
                            if (loadOptions.totalSummary) {
                                if (hasSummaryCache) {
                      result.summary = _summaryCache[summaryKey];
                                     DataSource = results;
                                     deferred.resolve(result);
                                 } else {
                             async function executeSequentialSum() {
                                         let sumVals = [];
                                         for (let i = 0; i < loadOptions.totalSummary.length; i++) {
                                             let item = loadOptions.totalSummary[i];
                                             let colName = item.selector || item.column;
                                             try {
                                                 let val = await fn_thanh_sumFull_SAL_Advance_Process(colName);
                                                 sumVals.push(val);
                                             } catch(e) {
                                                 sumVals.push(0);
                                             }
                                         }
                                         return sumVals;
                                     }

                                     executeSequentialSum().then(function(sumVals) {
                                         result.summary = sumVals;
                                         _summaryCache[summaryKey] = result.summary;
                                         DataSource = results;
                                         deferred.resolve(result);
                                     }).catch(function() {
                                         result.summary = loadOptions.totalSummary.map(() => 0);
                                         DataSource = results;
                                         deferred.resolve(result);
                                     });
                                 }
                             } else {
                                 DataSource = results;
                                 deferred.resolve(result);
                             }
                         },	
                         error: function (err) {	
                             deferred.reject("%ErrorLoadAdvanceData%");	
                         }	
                     });	
	
                     return deferred.promise();	
                 }	
             });	
	
              // --- HAM CAU HINH GRID DUY NHAT MOT LAN ---
              function ConfigureGrid() {
                  const gridInstance = InstanceGridSAL_Advance_ProcessPC71DDD11A62E4B528C0CC0E3D1AB5929;
                  if (gridInstance) {
                      gridInstance.beginUpdate();
                       let cols = gridInstance.option("columns");
                       if (cols) {
                           cols.forEach(function (col) {
                               if (col.dataField === "Cash" || col.dataField === "LockData") {
                                   col.dataType = "boolean";
                                   col.cellTemplate = function(cellElement, cellInfo) {
                                       const checked = cellInfo.value == 1 || cellInfo.value === true;
                                       const color = getComputedStyle(document.documentElement).getPropertyValue("--paradise-color-checkbox").trim() || "#198754";
                                       const $icon = $("<div>").css({
                                           display: "flex",
                                           alignItems: "center",
                                           justifyContent: "left",
                                           height: "100%"
                                       });
                                       if (checked) {
                                           $icon.html(
                                               "<svg width=''18'' height=''18'' viewBox=''0 0 18 18'' fill=''none'' xmlns=''http://www.w3.org/2000/svg''>" +
                                               "<rect width=''18'' height=''18'' rx=''4'' fill=''" + color + "''/>" +
                                               "<polyline points=''4,9 7.5,13 14,5'' stroke=''#fff'' stroke-width=''2.2'' stroke-linecap=''round'' stroke-linejoin=''round'' fill=''none''/>" +
                                               "</svg>"
                                           );
                                       } else {
                                           $icon.html(
                                               "<svg width=''18'' height=''18'' viewBox=''0 0 18 18'' fill=''none'' xmlns=''http://www.w3.org/2000/svg''>" +
                                               "<rect width=''17'' height=''17'' x=''0.5'' y=''0.5'' rx=''3.5'' stroke=''" + color + "'' stroke-opacity=''0.45'' fill=''none''/>" +
                                               "</svg>"
                                           );
                                       }
                                       $icon.appendTo(cellElement);
                                   };
                               }
                           });
                       }

                      // ============================================================
                      // BƯỚC 2: Wrap onToolbarPreparing theo chuẩn Mẫu-html.sql
                      // ============================================================
                      let oldOnToolbarPreparing = gridInstance.option("onToolbarPreparing");
                      gridInstance.option("onToolbarPreparing", function(e) {
                          if (typeof oldOnToolbarPreparing === "function") {
                              oldOnToolbarPreparing(e);
                          }

                          // 0. Lưu tạm bộ lọc để không bị hủy khi Grid vẽ lại Toolbar
                          const advanceFilters = document.querySelectorAll(".sal-advance-toolbar-filter-item");
                          const hiddenContainer = document.getElementById("hidden-toolbar-items-advance");
                          if (hiddenContainer && advanceFilters.length > 0) {
                              advanceFilters.forEach(f => hiddenContainer.appendChild(f));
                          }

                          // Xóa các nút custom cũ và filter cũ (nếu có) bằng splice để không làm hỏng reference của DevExtreme
                          const toolbarItems = e.toolbarOptions.items;
                          for (let i = toolbarItems.length - 1; i >= 0; i--) {
                              let item = toolbarItems[i];
                              if ((item.options && (item.options.icon === "print" || item.options.icon === "exportxlsx")) || item.isCustomAdvanceFilter) {
                                  toolbarItems.splice(i, 1);
                              }
                          }

                          // Ensure Reload button is present
                          const hasReload = toolbarItems.some(i => i.options && i.options.icon === "refresh");
                          if (!hasReload) {
                              let idx = toolbarItems.findIndex(i => i.name === "columnChooserButton");
                              if (idx === -1) idx = toolbarItems.length;
                              toolbarItems.splice(idx, 0, {
                                  location: "after",
                                  widget: "dxButton",
                                  options: {
                                      icon: "refresh",
                                      stylingMode: "text",
                                      elementAttr: { style: "color: var(--bs-body-color, #000);" },
                                      onClick: function() {
                              ReloadData();
                                      }
                                  }
                              });
                          }

                          // 1. Chèn filters Tháng + Năm vào bên trái (trước ô Search)
                          let searchPanelIndex = toolbarItems.findIndex(i => i.name === "searchPanel" || i.location === "after" || i.icon === "refresh");
                          let insertIndex = searchPanelIndex >= 0 ? searchPanelIndex : 0;

                          if (hiddenContainer) {
                              const filters = hiddenContainer.querySelectorAll(".sal-advance-toolbar-filter-item");
                              filters.forEach(filterHtml => {
                                  toolbarItems.splice(insertIndex, 0, {
                                      location: "before",
                                      isCustomAdvanceFilter: true, // Đánh dấu để xóa đi khi Reload
                                      template: function() {
                                          return $(filterHtml).show();
                                      }
                                  });
                                  insertIndex++; // Tăng index để giữ đúng thứ tự Month -> Year
                              });
                          }

                          // 2. Chèn nút Print và Export
                          let btnPrint = {
                              location: "after",
                              locateInMenu: "never",
                              widget: "dxButton",
                              options: {
                                  icon: "print",
                                  hint: "%Export.EmployeeAdvance%",
                                  type: "success",
                                  onClick: function() { btnPrintClick(); }
                              }
                          };

                          let btnExport = {
                              location: "after",
                              locateInMenu: "never",
                              widget: "dxButton",
                              options: {
                                  icon: "exportxlsx",
                                  hint: "%btnExport%",
                                  type: "default",
                                  onClick: function() { btnExportClick(); }
                              }
                          };

                          // Dùng splice để chèn vào vị trí insertIndex thay vì push
                          toolbarItems.splice(insertIndex, 0, btnPrint, btnExport);
                      });

                      gridInstance.option({
                          "allowColumnResizing": true,
                          "columnResizingMode": "widget",
                          "remoteOperations": {
                              paging: true, filtering: true, sorting: true, searching: true, summary: true
                          },
                          "searchPanel": {
                              visible: true,
                              width: 240,
                              placeholder: "%Search%..."
                          },
                          "onOptionChanged": function (e) {
                              if (e.name === "searchPanel" && e.fullName === "searchPanel.text") {
                                  _currentKeyword = (e.value || "").trim();
                                  _pageCache = {};
                                  _summaryCache = {};
                              }
                              if (e.fullName && (e.fullName.indexOf("filterValue") >= 0 || e.fullName.indexOf("filterValues") >= 0 || e.fullName.indexOf("selectedFilterOperation") >= 0)) {
                                  _pageCache = {};
                                  _summaryCache = {};
                              }
                          },
                          "headerFilter": {
                              "visible": true
   },
                          "filterRow": {
                              "visible": false
                          },
                          "onRowDblClick": function(e) {
                              if (e.data) {
                                  window.currentAdvanceSelected = e.data;
                                  if (typeof openFormParam === "function") {
                                      openFormParam("sp_SAL_Advance_Process_Edit", e.data);
                                  } else if (typeof window.openFormParam === "function") {
                                      window.openFormParam("sp_SAL_Advance_Process_Edit", e.data);
                                  }
                              }
                          },
                          "summary": {
                              totalItems: [' + ISNULL(@summaryItems, '') + N']
                          },
                          "columns": cols,
                           "customizeColumns": function (columns) {
                                columns.forEach(function (col) {
                                    let colName = col.dataField || col.name;
                                    if (colName) {
                                        col.width = undefined;
                                        let captionText = col.caption || colName;
                                        let calculatedMinWidth = Math.max(100, captionText.length * 9.5);
                                        col.minWidth = calculatedMinWidth;
                                    }
                                    if (col.dataField === "Cash" || col.dataField === "LockData") {
                                        col.dataType = "boolean";
                                        col.cellTemplate = function(cellElement, cellInfo) {
                                            const checked = cellInfo.value == 1 || cellInfo.value === true;
                                            const color = getComputedStyle(document.documentElement).getPropertyValue("--paradise-color-checkbox").trim() || "#198754";
                                            const $icon = $("<div>").css({
                                                display: "flex",
                                                alignItems: "center",
                                                justifyContent: "left",
                                                height: "100%"
                                            });
                                            if (checked) {
                                                $icon.html(
                                                    "<svg width=''18'' height=''18'' viewBox=''0 0 18 18'' fill=''none'' xmlns=''http://www.w3.org/2000/svg''>" +
                                                    "<rect width=''18'' height=''18'' rx=''4'' fill=''" + color + "''/>" +
                                                    "<polyline points=''4,9 7.5,13 14,5'' stroke=''#fff'' stroke-width=''2.2'' stroke-linecap=''round'' stroke-linejoin=''round'' fill=''none''/>" +
                                                    "</svg>"
                                                );
                                            } else {
                                                $icon.html(
                                                    "<svg width=''18'' height=''18'' viewBox=''0 0 18 18'' fill=''none'' xmlns=''http://www.w3.org/2000/svg''>" +
                                                    "<rect width=''17'' height=''17'' x=''0.5'' y=''0.5'' rx=''3.5'' stroke=''" + color + "'' stroke-opacity=''0.45'' fill=''none''/>" +
                                                    "</svg>"
                                                );
                                            }
                                            $icon.appendTo(cellElement);
                                        };
                                    }
                                   if (col.dataType === "number" || (col.format && col.format.indexOf("#,##0") >= 0)) {
                                       let oldCustomizeText = col.customizeText;
                                       col.customizeText = function(cellInfo) {
                                           if (cellInfo.value === null || cellInfo.value === undefined || cellInfo.value === "") {
                                               return "0";
                                           }
                                           if (typeof oldCustomizeText === "function") { let txt = oldCustomizeText(cellInfo); if (txt) return txt; } if (cellInfo.valueText) return cellInfo.valueText; return new Intl.NumberFormat("en-US").format(cellInfo.value);
                                       };
                                   }
                               });
                               let fullNameCol = columns.find(c => c.dataField === "FullName");
                               if (fullNameCol) fullNameCol.minWidth = 230;
                               let deptCol = columns.find(c => c.dataField === "DepartmentID");
                               if (deptCol) deptCol.minWidth = 200;
                               let secCol = columns.find(c => c.dataField === "SectionName");
                               if (secCol) secCol.minWidth = 200;
                           },
                          "scrolling.mode": "infinite",
                          "scrolling.rowRenderingMode": "virtual",
                          "scrolling.preloadEnabled": false,
                          "paging.enabled": true,
                          "paging.pageSize": 50,
                          "pager.visible": false,
                          "dataSource": dataStore_
                      });

                      gridInstance.endUpdate();
                      gridInstance.repaint();

                      const root = document.getElementById("SAL_Advance_Process");
                      const toolbarPanel = root ? root.querySelector(".dx-datagrid-header-panel") : null;
                      if (root && toolbarPanel && typeof ResizeObserver !== "undefined") {
                          const updateToolbarLayout = function() {
                              const before = toolbarPanel.querySelector(".dx-toolbar-before");
                              const after = toolbarPanel.querySelector(".dx-toolbar-after");
                              if (!before || !after) return;

                              const itemWidth = function(container) {
                                  return Array.from(container.children).reduce(function(total, item) {
                                      return total + item.getBoundingClientRect().width;
                                  }, 0);
                              };
                              const requiredWidth = itemWidth(before) + itemWidth(after) + 24;
                              root.classList.toggle("sal-advance-toolbar-two-rows", toolbarPanel.clientWidth < requiredWidth);
                              gridInstance.updateDimensions();
                          };

                          const toolbarResizeObserver = new ResizeObserver(updateToolbarLayout);
                          toolbarResizeObserver.observe(toolbarPanel);
                          updateToolbarLayout();
                      }
                  }
              }

              // --- HÀM REFRESH LƯỚI ---
              function ReloadData() {
                  _summaryCache = {};
                  api = true;
                  const gridInstance = InstanceGridSAL_Advance_ProcessPC71DDD11A62E4B528C0CC0E3D1AB5929;
                  if (gridInstance) {
                      gridInstance.refresh();
                  }
              }

              // --- CẤU HÌNH LƯỚI SAU KHI GRID ĐÃ ĐƯỢC LOAD ---
              let checkExist = setInterval(function() {
                  let gridInstance = InstanceGridSAL_Advance_ProcessPC71DDD11A62E4B528C0CC0E3D1AB5929;

                  if (typeof gridInstance !== "undefined" && gridInstance) {
                      clearInterval(checkExist);
                      ConfigureGrid();
                      ReloadData();
                  }
              }, 100);

              // Đăng ký tự động reload lưới khi bộ lọc Tháng/Năm thay đổi	
              window["onSelectBoxChanged_Month"] = function() { ReloadData(); };	
              window["onSelectBoxChanged_Year"] = function() { ReloadData(); };	

              function updateGridHeight() {
                  try {
                      const gridInstance = InstanceGridSAL_Advance_ProcessPC71DDD11A62E4B528C0CC0E3D1AB5929;
                      if (gridInstance) {
                          gridInstance.updateDimensions();
                      }
                  } catch (e) {
                      console.warn("[SAL_Advance_Process] updateGridHeight lỗi:", e);
                  }
              }

             setTimeout(updateGridHeight, 100);
             setTimeout(updateGridHeight, 500);

             const _resizeHandler = function() { updateGridHeight(); };
             $(window).on("resize.gridSAL_Advance", _resizeHandler);

             const _gridWrap = document.getElementById("SAL_Advance_Process");
             if (_gridWrap && typeof ResizeObserver !== "undefined") {
                 const _ro = new ResizeObserver(function() {
                     updateGridHeight();
                 });
                 _ro.observe(_gridWrap);
             }
         })();	
     </script>	
';	
    SELECT @html AS html;	
END
GO

CREATE PROCEDURE [dbo].[sp_LoadGridUsingAPI]--
    @LoginID           int           =3, --
    @LanguageID        varchar(5)    ='VN', --
    @UseTempDB         bit           =1, --
    @TableDataName     nVarchar(200) ='', --
    @ProcName          nVarchar(200) ='', --
    @ProcParam         nVarchar(max) ='', --
    @Take              int           =0, --
    @Skip              int           =0, --
    @RequireTotalCount bit           =0, --
    @TotalSummary      nVarchar(max) ='', --
    @Sort              nVarchar(500) ='', --
    @SearchValue       nVarchar(150) ='', --
    @ColumnSearch      nVarchar(max) ='', --
    @Filters           nVarchar(max) ='', --
    @SelectGroup       nVarchar(max) ='', --
    @GroupBy           nVarchar(max) ='', --
    @value             sql_Variant   =null
as begin
    set noCount on
	
    if not exists (select * from dbo.tblLanguage where LanguageID=@LanguageID)
        set @LanguageID='VN'
    if not(len(@TableDataName)>1)
        set @TableDataName=@ProcName+cast(@LoginID as nVarchar)+@LanguageID
    if @UseTempDB=1
          and @TableDataName not like '##%'
        set @TableDataName='##'+@TableDataName
    declare @ProcQuery nVarchar(max), @sql nVarchar(max), @Condition nVarchar(max) =N' WHERE ', @object_id int=object_Id(@TableDataName), @int int=0
    if @value is not null
       and @object_id is null begin
        set @int=1
        goto getData
    end
    if object_Id('tempdb..#temptable') is not null
        drop table #temptable
    select [name]
      into #temptable
      from sys.columns c
     where c.object_id=@object_id
    union
    select [name]
      from tempdb.sys.columns c
     where c.object_id=@object_id
    paradise:
    if @value is not null begin
        if(isNull(@ColumnSearch, '')='')begin
            select top 1 @ColumnSearch +=(','+[name])
              from #temptable
            if len(@ColumnSearch)>1
                set @ColumnSearch=right(@ColumnSearch, len(@ColumnSearch)-1)
        end
        set @sql=N'select * from '+@TableDataName+N' where '+@ColumnSearch+N' = @value '
        exec sp_executesql @sql, N'@value sql_Variant', @value=@value;
        return
    end
    getData:
    if object_Id(@TableDataName) is null
       or(@RequireTotalCount=1 and @Filters='')begin
        set @ProcQuery=N'
		if object_id('''+@TableDataName+N''') is not null Drop Table '+@TableDataName+N'
		if object_id(''tempdb..'+@TableDataName+N''') is not null Drop Table '+@TableDataName+N'
		EXEC '+@ProcName
        if len(@ProcParam)>0
            set @ProcQuery += N' '+@ProcParam+N','

        set @ProcQuery += N' @TempTableAPIName = '''+@TableDataName+N''';'

        exec(@ProcQuery)

        if @int=1 begin
            set @int=2
            set @object_id=object_Id(@TableDataName)
            goto paradise
        end
    end
    if(isNull(@ColumnSearch, '')='')begin
        select @ColumnSearch +=(','+[name])
          from #temptable
        if len(@ColumnSearch)>1
            set @ColumnSearch=right(@ColumnSearch, len(@ColumnSearch)-1)
    end
	
    if(@SearchValue<>'' and @ColumnSearch<>'')
        goto ConditionSearch
    if(@Filters<>'')
        goto ConditionFilters
    goto ConditionEnd
    ConditionSearch:
    if object_Id('tempdb..#temptable2') is not null
        drop table #temptable2
    select *
      into #temptable2
      from dbo.fn_SplitString(@ColumnSearch, ',')
    declare @StuffCondition nVarchar(max) =N'';
    if(@SearchValue like '%;%')begin
        if object_Id('tempdb..#temp') is not null
            drop table #temp
        select *
          into #temp
          from dbo.fn_SplitString(@SearchValue, ';')
        select @StuffCondition +=(select stuff((select ' or '+t2.Items+' like N''%'+t.Items+'%'''
                                                  from #temptable2 t2
                                                 where isNull(t.Items, '')<>''
                                                for xml path('')), 1, 4, ' and (')
                                        +')'
                                    from #temp t)
        if len(@StuffCondition)>1
            set @Condition += right(@StuffCondition, len(@StuffCondition)-5)
    end
    else begin
        select @StuffCondition +=(' or '+Items+' like N''%'+@SearchValue+'%''')
          from #temptable2
        if len(@StuffCondition)>1
            set @Condition += right(@StuffCondition, len(@StuffCondition)-4)
    end
    if(@Filters<>'')
        set @Condition += N' and '
    else
        goto ConditionEnd

    goto ConditionEnd
    ConditionFilters:
    set @Condition += @Filters
    ConditionEnd:
    if(@TotalSummary<>'')begin
        if object_Id('tempdb..#_temptable') is not null
            drop table #_temptable;
        with CTE as (select Items as value, charIndex('(', Items) as open_bracket, charIndex(')', Items) as close_bracket from dbo.fn_SplitString(@TotalSummary, ','))
        select lTrim(rTrim(substring(value, open_bracket+1, close_bracket-open_bracket-1))) as ColumnName, value
          into #_temptable
          from CTE
         where open_bracket>0
               and close_bracket>0
        set @TotalSummary=(select stuff((select ','+value from #_temptable where ColumnName in(select [name] from #temptable)for xml path('')), 1, 1, ''))
    end
    select @Condition=N''
     where @Condition like ' WHERE '
    if(@GroupBy<>'')begin
        if @Take > 0
            set @sql = N';WITH GroupCTE AS (SELECT '+@SelectGroup+N', ROW_NUMBER() OVER (ORDER BY '+replace(@GroupBy, 'GROUP BY ', '')+N') AS RowNum FROM '+@TableDataName+N' '+@Condition+N' '+@GroupBy+N') SELECT * FROM GroupCTE WHERE RowNum > '+cast(@Skip as nVarchar)+N' AND RowNum <= '+cast(@Skip + @Take as nVarchar)+N';'
        else
            set @sql = N'SELECT '+@SelectGroup+N' FROM '+@TableDataName+N' '+@Condition+N' '+@GroupBy+N' ORDER BY '+replace(@GroupBy, 'GROUP BY ', '')+N';'
        goto runSQL
    end
    else if isNull(@Sort, '')='' or @Sort = 'ORDER BY 1'
        set @Sort='ORDER BY (SELECT 1)'
    
    if @Take > 0
        set @sql = N';WITH NumberedCTE AS (SELECT *, ROW_NUMBER() OVER ('+@Sort+N') AS RowNum FROM '+@TableDataName+N' '+@Condition+N') SELECT * FROM NumberedCTE WHERE RowNum > '+cast(@Skip as nVarchar)+N' AND RowNum <= '+cast(@Skip + @Take as nVarchar)+N';'
    else
        set @sql = N'SELECT * FROM '+@TableDataName+N' '+@Condition+N' '+@Sort+N';'

    set @sql += N'
    '+case
      when @RequireTotalCount=1
      then 'SELECT COUNT(1) as TotalCount FROM '+@TableDataName+N' '+@Condition+' '
      else ''
      end+N';

    '+case
      when @TotalSummary<>''
      then 'SELECT '+@TotalSummary+N' FROM '+@TableDataName+N''
      else ''
      end+N'
    '
    runSQL:
		IF OBJECT_ID('tempdb..#temptable') IS NOT NULL  DROP TABLE #temptable
		IF OBJECT_ID('tempdb..#temptable2') IS NOT NULL  DROP TABLE #temptable2
		IF OBJECT_ID('tempdb..#_temptable') IS NOT NULL  DROP TABLE #_temptable
		IF OBJECT_ID('tempdb..#temp') IS NOT NULL  DROP TABLE #temp
        exec(@sql)
end
GO

CREATE PROCEDURE [dbo].[sp_SAL_Advance_Process_Edit_html]
(
    @LoginID INT = 3,
    @LanguageID VARCHAR(2) = 'VN',
    @isWeb INT = 1
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @html NVARCHAR(MAX);
    SET @html = N'

    <style>
        .dx-popup-content:has(#sp_SAL_Advance_Process_Edit_html) {
            padding: 0px !important;
        }
    </style>
    <div id="sp_SAL_Advance_Process_Edit_html" style="padding: 12px;">
        <div class="row align-items-center mb-2">
            <div class="col-md-2"><label class="font-weight-bold">' + ISNULL((SELECT TOP 1 DisplayName FROM tblCommonControlType_Signed WHERE UID = 'P2C632067A29F4E25812C0144D5019625'), '') + N':</label></div>
            <div class="col-md-4"><div id="P2C632067A29F4E25812C0144D5019625"></div></div>
            <div class="col-md-2"><label class="font-weight-bold">%Lock%:</label></div>
            <div class="col-md-4"><div id="P03965EDAFBF54FA0B84BED320C664F4A"></div></div>
        </div>
        <div class="row align-items-center mb-2">
            <div class="col-md-2"><label class="font-weight-bold">' + ISNULL((SELECT TOP 1 DisplayName FROM tblCommonControlType_Signed WHERE UID = 'PC11CD073FA774AC8BCBF9E7EFDE5E981'), '') + N':</label></div>
            <div class="col-md-4"><div id="PC11CD073FA774AC8BCBF9E7EFDE5E981"></div></div>
            <div class="col-md-2"><label class="font-weight-bold">' + ISNULL((SELECT TOP 1 DisplayName FROM tblCommonControlType_Signed WHERE UID = 'P0B1DB0A879264428A64EA2F4CB385E8A'), '') + N':</label></div>
            <div class="col-md-4"><div id="P0B1DB0A879264428A64EA2F4CB385E8A"></div></div>
        </div>
        <div class="row mt-3">
            <div class="col-md-12 d-flex justify-content-end">
                <div id="btnSaveAdvance"></div>
            </div>
        </div>
    </div>
    <script>
        (() => {
            let obj = window.currentAdvanceSelected;
            if (!obj) {
                try {
                    let localData = localStorage.getItem("SuaTamUngluong_Data");
                    if (localData) obj = JSON.parse(localData);
                } catch(e) {}
            }
            if (!obj) {
                obj = typeof window.param !== "undefined" ? window.param : (window.frmParam || {});
            }

             // Kiểm tra khóa: nếu IsLock = 1 thì hiện thông báo và đóng popup
             let isLocked = (obj && (obj.IsLock == 1 || obj.IsLock === true || obj.IsLock === "true" || obj.LockData == 1 || obj.LockData === true));
             if (isLocked) {
                 uiManager.showAlert({
                     type: "warning",
                     message: window.LanguageID === "VN"
                         ? "Dữ liệu tạm ứng của nhân viên này đã bị khóa, không thể chỉnh sửa!"
                         : "This employee advance data is locked and cannot be edited!"
                 });
                 setTimeout(function() {
                     try {
                         let popup = $(".dx-popup").map(function() {
                             return $(this).dxPopup("instance");
                         }).get().find(function(instance) {
                             return instance && $(instance.content()).find("#sp_SAL_Advance_Process_Edit_html").length;
                         });
                         if (popup) popup.hide();
                     } catch(e) {}
                 }, 300);
                 return;
             }

          //  console.log("🤷‍♂️ hoangthanh~ SuaTamUngluong opened with obj:", obj);'
    +(select loadUI from tblCommonControlType_Signed where UID = 'P2C632067A29F4E25812C0144D5019625')
    +(select loadUI from tblCommonControlType_Signed where UID = 'P03965EDAFBF54FA0B84BED320C664F4A')
    +(select loadUI from tblCommonControlType_Signed where UID = 'PC11CD073FA774AC8BCBF9E7EFDE5E981')
    +(select loadUI from tblCommonControlType_Signed where UID = 'P0B1DB0A879264428A64EA2F4CB385E8A') +N'

             // Khởi tạo checkbox Khóa (LockData) - inline vì DUC chưa dispatch hpaControlCheckBox
             window["InstanceLockDataP03965EDAFBF54FA0B84BED320C664F4A"] = $("#P03965EDAFBF54FA0B84BED320C664F4A").dxCheckBox({
                 value: false,
                 dataField: "LockData",
                 onValueChanged: function(e) {
     // Nếu tick vào Duyệt/Khóa thì tự động tick Tiền mặt
                     if (e.value === true) {
                         let instCash = window["InstanceCashPC11CD073FA774AC8BCBF9E7EFDE5E981"] || $("#PC11CD073FA774AC8BCBF9E7EFDE5E981").dxCheckBox("instance");
                         if (instCash) instCash.option("value", true);
                     }
                 }
             }).dxCheckBox("instance");

             // Khởi tạo checkbox Tiền mặt (Cash) - inline vì DUC chưa dispatch hpaControlCheckBox
             window["InstanceCashPC11CD073FA774AC8BCBF9E7EFDE5E981"] = $("#PC11CD073FA774AC8BCBF9E7EFDE5E981").dxCheckBox({
                 value: false,
                 dataField: "Cash"
             }).dxCheckBox("instance");

             window.currentRecordID_EmployeeID = null;

             // Hàm làm sạch dữ liệu số từ ô nhập tiền tệ
             let cleanNumber = (val) => {
                 if (typeof val === "number") return val;
                 if (typeof val === "string") {
                     let clean = val.replace(/[^0-9]/g, "");
                     let num = parseFloat(clean);
                     return isNaN(num) ? 0 : num;
                 }
                 return Number(val) || 0;
             };

             let getInst = (col, uid) => {
                  if (typeof window["Instance" + col + uid] !== "undefined" && window["Instance" + col + uid]) {
                      return window["Instance" + col + uid];
                  }
                  if (typeof window["Instance" + uid] !== "undefined" && window["Instance" + uid]) {
                      return window["Instance" + uid];
                  }
                  let $el = $("#" + uid);
                  if ($el.length) {
                      try {
                          let inst = null;
                          if (typeof DevExpress !== "undefined" && DevExpress.ui && DevExpress.ui.dxWidget) {
                              inst = DevExpress.ui.dxWidget.getInstance($el[0]);
                          }
                          return inst
                              || $el.dxTextBox("instance")
                              || $el.dxCheckBox("instance")
                              || $el.dxNumberBox("instance")
                              || $el.dxSelectBox("instance")
                              || $el.dxTextArea("instance");
                      } catch(e) {}
                  }
                  return null;
              };

            let checkFormInterval = setInterval(function() {
                try {
                    let uids = ["P2C632067A29F4E25812C0144D5019625", "P03965EDAFBF54FA0B84BED320C664F4A", "PC11CD073FA774AC8BCBF9E7EFDE5E981", "P0B1DB0A879264428A64EA2F4CB385E8A"];

                    uids.forEach(uid => {
                        let $el = $("#" + uid);
                        if ($el.length) {
                            try {
                                if (typeof DevExpress !== "undefined" && DevExpress.ui && DevExpress.ui.dxWidget) {
                                    let w = DevExpress.ui.dxWidget.getInstance($el[0]);
                                }
                            } catch(e) {}
                        }
                    });

                    let instNotes = getInst("Notes", "P0B1DB0A879264428A64EA2F4CB385E8A");
                    if (!instNotes) return;
                    clearInterval(checkFormInterval);

                    let instances = [
                        getInst("AdvanceAmount", "P2C632067A29F4E25812C0144D5019625"),
                        getInst("LockData", "P03965EDAFBF54FA0B84BED320C664F4A"),
                        getInst("Cash", "PC11CD073FA774AC8BCBF9E7EFDE5E981"),
                        instNotes
                    ];
                    let fields = ["AdvanceAmount", "LockData", "Cash", "Notes"];
                    for(let i = 0; i < instances.length; i++) {
                   if (instances[i]) {
                            let fieldName = instances[i].option("dataField") || fields[i];
                            let val = obj[fieldName] !== undefined ? obj[fieldName] : obj[fields[i]];
                            if (val !== undefined && val !== null) {
                                if (fields[i] === "LockData" || fields[i] === "Cash") {
                                    instances[i].option("value", val == 1 || val === true || val === "true");
                                } else {
                                    instances[i].option("value", val);
                                }
                            }
                        }
                    }
                } catch(e) { console.error("Lỗi khi fill data:", e); }
            }, 100);

            $("#btnSaveAdvance").dxButton({
                text: window.LanguageID === "VN" ? "Lưu" : "Save",
                icon: "save",
                type: "success",
                onClick: async function() {
                    let advanceAmount = obj.AdvanceAmount || 0;
                    let lockData = obj.LockData ? 1 : 0;
                    let cash = obj.Cash ? 1 : 0;
                    let notes = obj.Notes || "";

                    let instances = [
                        getInst("AdvanceAmount", "P2C632067A29F4E25812C0144D5019625"),
                        getInst("LockData", "P03965EDAFBF54FA0B84BED320C664F4A"),
                        getInst("Cash", "PC11CD073FA774AC8BCBF9E7EFDE5E981"),
                        getInst("Notes", "P0B1DB0A879264428A64EA2F4CB385E8A")
                    ];

                    for (let i = 0; i < instances.length; i++) {
                        let inst = instances[i];
                        if (inst) {
                            let df = inst.option("dataField");
                            let val = inst.option("value");
                            if (df === "AdvanceAmount" || (!df && i === 0)) advanceAmount = cleanNumber(val);
                            if (df === "LockData" || (!df && i === 1)) lockData = (val === true || val == 1 || val === "true") ? 1 : 0;
                            if (df === "Cash" || (!df && i === 2)) cash = (val === true || val == 1 || val === "true") ? 1 : 0;
                            if (df === "Notes" || (!df && i === 3)) notes = val || "";
                        }
                    }

                    // Lấy giá trị Tháng, Năm (nếu obj không có thì lấy từ global scope hoặc parent)
                    let currentMonth = obj.Month || window.Month || (window.parent && window.parent.Month) || 0;
                    let currentYear = obj.Year || window.Year || (window.parent && window.parent.Year) || 0;

                    // Fallback thử lấy từ control trên giao diện nếu vẫn bằng 0
                    if (!currentMonth || !currentYear) {
                        try {
                            if (!currentMonth && $("#Month").length) currentMonth = $("#Month").dxSelectBox("instance").option("value");
                            if (!currentYear && $("#Year").length) currentYear = $("#Year").dxSelectBox("instance").option("value");
                        } catch(e) {}
                    }

                    console.log("🤷‍♂️ hoangthanh~ btnSave onClick params:", JSON.stringify({
                        EmployeeID: obj.EmployeeID,
                        Month: currentMonth,
                        Year: currentYear,
                        AdvanceAmount: advanceAmount,
                        LockData: lockData,
                        Cash: cash,
                        Notes: notes
                    }));

                    if (!currentMonth || !currentYear) {
                        uiManager.showAlert({
                            type: "error",
                            message: window.LanguageID === "VN" ? "Không xác định được Tháng/Năm để lưu!" : "Cannot determine Month/Year to save!"
                        });
                        return;
 }

                    uiManager.showAlert({
                        type: "warning",
                        message: window.LanguageID === "VN" ? "Đang lưu dữ liệu..." : "Saving..."
                    });

                    try {
                        let res = await AjaxHPAParadiseAsync({ data: {
                            name: "sp_SAL_Advance_Update_API",
                            param: [
                                "EmployeeID", obj.EmployeeID,
                                "Month", currentMonth,
                                "Year", currentYear,
                                "AdvanceAmount", advanceAmount,
                                "LockData", lockData,
                                "Cash", cash,
                                "Notes", notes,
                                "LoginID", window.UserID || window.LoginID
                            ]
                        }});
                        let response = typeof res === "string" ? JSON.parse(res) : res;
                        if (response && (response.success === false || response.Success === false || response.error || response.Error)) {
                            throw new Error(response.message || response.Message || response.error || response.Error);
                        }

                        let popup = $(".dx-popup").map(function() {
                            return $(this).dxPopup("instance");
                        }).get().find(function(instance) {
                            return instance && $(instance.content()).find("#sp_SAL_Advance_Process_Edit_html").length;
                        });
                        if (popup) popup.hide();

                        let grid = $("#GridSAL_Advance_Process").dxDataGrid("instance");
                        if (grid) {
                            await grid.getDataSource().reload();
                        }

                        uiManager.showAlert({
                            type: "success",
                            message: window.LanguageID === "VN" ? "Lưu thành công!" : "Saved successfully!"
                        });
                    } catch (err) {
                        uiManager.showAlert({
                            type: "error",
                            message: err && err.message ? err.message : (window.LanguageID === "VN" ? "Lỗi lưu dữ liệu." : "Failed to save data.")
                        });
                    }
                }
            });

            '
        +N'})();
</script>
    ';
    SELECT @html AS html;
END
/*
EXEC sptblCommonControlType_Signed_DUC 'sp_SAL_Advance_Process_Edit_html'
exec sp_GenerateHTMLScript_new 'sp_SAL_Advance_Process_Edit_html'
*/
GO

CREATE PROCEDURE [dbo].[sp_SAL_Advance_Process_Edit]
	@LoginID int = null,
	@LanguageID varchar(2) = 'VN'
AS
	select html from tblHtmlScriptCache where TableName = 'sp_SAL_Advance_Process_Edit_html' and ScreenType = -1 and LanguageID = @LanguageID
GO

CREATE PROCEDURE [dbo].[sp_SAL_Advance_Update]
    @EmployeeID VARCHAR(20),
    @Month INT,
    @Year INT,
    @AdvanceAmount MONEY,
    @LockData BIT,
    @Cash BIT,
    @Notes NVARCHAR(MAX) = '',
    @LoginID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM dbo.tblSal_Advance
        WHERE EmployeeID = @EmployeeID
          AND [Month] = @Month
          AND [Year] = @Year
          AND IsLock = 1
    ) AND @LockData = 1
    BEGIN
        RAISERROR(N'Dữ liệu tạm ứng của nhân viên này đã bị khóa, không thể chỉnh sửa!', 16, 1);
        RETURN;
    END;

    DECLARE @OldData NVARCHAR(MAX);
    SELECT @OldData = CONCAT(N'Tạm ứng: ', AdvanceAmount, N', Khóa: ', IsLock, N', Tiền mặt: ', Cash, N', Ghi chú: ', Notes)
    FROM dbo.tblSal_Advance
    WHERE EmployeeID = @EmployeeID AND [Month] = @Month AND [Year] = @Year;

    UPDATE dbo.tblSal_Advance
    SET AdvanceAmount = @AdvanceAmount,
        IsLock = 1,
        Cash = @Cash,
        BankAmt = CASE WHEN @Cash = 1 THEN 0 ELSE @AdvanceAmount END,
        Notes = CASE WHEN ISNULL(@Notes, '') <> '' THEN @Notes ELSE Notes END
    WHERE EmployeeID = @EmployeeID AND [Month] = @Month AND [Year] = @Year;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR(N'Không tìm thấy dữ liệu tạm ứng cần cập nhật.', 16, 1);
        RETURN;
    END;

    DECLARE @NewData NVARCHAR(MAX) = CONCAT(N'Tạm ứng: ', @AdvanceAmount, N', Khóa: ', @LockData, N', Tiền mặt: ', @Cash, N', Ghi chú: ', @Notes);

    INSERT INTO dbo.tblSC_EZLog(LoginID, LogTime, EmployeeID, FunctionClassName, FunctionName, KindOfData, DateOfData, OldData, NewData)
    VALUES (@LoginID, GETDATE(), @EmployeeID, 'HPA.HumanResource.SalaryInformation', 'UpdateAdvance', 'Update advance salary', GETDATE(), @OldData, @NewData);

    SELECT CAST(1 AS bit) AS Success,
           N'Cập nhật tạm ứng thành công.' AS [Message];
END;
GO
