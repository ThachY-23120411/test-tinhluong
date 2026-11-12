CREATE PROCEDURE [dbo].[spDailyAttendanceData_html]
(
    @LoginID INT = 3,
    @LanguageID VARCHAR(2) = 'VN',
    @isWeb INT = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @InitMonth INT, @InitYear INT;
    DECLARE @InitFromDate DATE, @InitToDate DATE;

    SELECT TOP 1 @InitMonth = [Month], @InitYear = [Year] FROM tblCurrentWorkingMonth;
    IF @InitMonth IS NULL
        SELECT @InitMonth = [Month], @InitYear = [Year] FROM dbo.fn_Get_Sal_Month_Year(GETDATE());
    SET @InitMonth = ISNULL(@InitMonth, MONTH(GETDATE()));
    SET @InitYear = ISNULL(@InitYear, YEAR(GETDATE()));

    SELECT @InitFromDate = FromDate, @InitToDate = ToDate
    FROM dbo.fn_Get_SalaryPeriod(@InitMonth, @InitYear);

    DECLARE @InitFromDateStr NVARCHAR(10) = CONVERT(NVARCHAR(10), @InitFromDate, 120);
    DECLARE @InitToDateStr NVARCHAR(10) = CONVERT(NVARCHAR(10), @InitToDate, 120);

    DECLARE @loadUI_Grid NVARCHAR(MAX);

    -- Chỉ select duy nhất loadUI của GridDailyAttendanceData (chứa cấu hình 14 cột của grid)
    SELECT @loadUI_Grid = CAST(loadUI AS NVARCHAR(MAX))
    FROM tblCommonControlType_Signed
    WHERE TableName = 'spDailyAttendanceData_html' AND ColumnName = 'GridDailyAttendanceData';
    SET @loadUI_Grid = REPLACE(@loadUI_Grid, N'api = true;', N'')



    DECLARE @html NVARCHAR(MAX) = N'';
    SET @html = N'
    <div id="spDailyAttendanceData_html" class="attendance-container">
        <style>
            .attendance-container {
                display: flex;
                flex-direction: column;
                height: calc(100vh - 7.75rem) !important;
                height: calc(100dvh - 7.75rem) !important;
                min-height: 32rem;
                box-sizing: border-box;
                background-color: var(--background-color);
                color: var(--text-color);
                gap: 12px;
                overflow: hidden; /* Prevent container from scrolling, force scroll on grid instead */

                /* Exact colors from the OLD form (extracted via getComputedStyle) */
                --att-card-bg-noin: #ffff80; /* rgb(255,255,128) - Yellow */
                --att-card-color-noin: #000000;
                --att-card-bg-holiday: #c0ffc0; /* rgb(192,255,192) - Light green */
                --att-card-color-holiday: #000000;
                --att-card-bg-noinnoout: #c0c000; /* rgb(192,192,0) - Dark olive */
                --att-card-color-noinnoout: #000000;
                --att-card-bg-normal: transparent;
                --att-card-color-normal: var(--text-color);
                --att-card-bg-noout: #ffc0ff; /* rgb(255,192,255) - Pink/magenta */
                --att-card-color-noout: #000000;
                --att-card-bg-workholiday: #c0c0ff; /* rgb(192,192,255) - Lavender/blue */
                --att-card-color-workholiday: #000000;
                --att-card-bg-leave: #ffe0c0; /* rgb(255,224,192) - Peach/orange */
                --att-card-color-leave: #000000;
                --att-card-bg-abnormal: #ffe0c0;
                --att-card-color-abnormal: #000000;
            }
            .attendance-toolbar {
                display: flex;
                flex-wrap: wrap;
                align-items: center;
                gap: 12px;
                padding: 12px 16px;
                background-color: var(--background-color, #ffffff);
                border-radius: 8px;
                box-shadow: 0 4px 6px -1px rgba(33, 37, 41, 0.05), 0 2px 4px -1px rgba(33, 37, 41, 0.03);
            }
            .attendance-btn {
                padding: 10px 20px;
                border-radius: 6px;
                font-weight: 600;
                font-size: 13px;
                cursor: pointer;
                transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
                border: none;
                display: inline-flex;
                align-items: center;
                gap: 6px;
                box-shadow: 0 1px 3px rgba(33, 37, 41, 0.1);
            }
            .attendance-btn:hover {
                transform: translateY(-1px);
                box-shadow: 0 4px 6px rgba(33, 37, 41, 0.1);
            }
            .attendance-btn:active {
                transform: translateY(0);
            }
            .btn-green {
                background-color: #2e7d32;
                color: #ffffff;
            }
            .btn-green:hover {
                background-color: #1b5e20;
            }

            .btn-light {
                background-color: #f8f9fa;
                color: #212529;
                border: 1px solid #ced4da;
            }
            .btn-light:hover {
                background-color: #e2e6ea;
                border-color: #dae0e5;
            }
            .filter-panel {
                display: flex;
                flex-direction: column;
                gap: 8px;
                padding: 8px 12px;
                background-color: var(--background-color, #ffffff);
                border-radius: 8px;
                box-shadow: 0 4px 6px -1px rgba(33, 37, 41, 0.05), 0 2px 4px -1px rgba(33, 37, 41, 0.03);
            }
            @media (max-width: 1200px) {
                .filter-panel {
                    grid-template-columns: 1fr;
                }
            }
            .checkbox-grid {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 5px;
            }
            @media (max-width: 768px) {
                .checkbox-grid {
                    grid-template-columns: repeat(2, 1fr);
                }
            }
            .checkbox-color-wrapper {
                display: flex;
                align-items: center;
                border-radius: 6px;
                padding: 4px 8px;
                border: 1px solid transparent;
                box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
                min-height: 34px;
                box-sizing: border-box;
                transition: all 0.2s ease;
            }
            .checkbox-color-wrapper:hover {
                filter: brightness(0.96);
                box-shadow: 0 2px 4px rgba(33, 37, 41, 0.08);
            }
            .checkbox-color-wrapper .dx-checkbox {
                width: 100%;
            }
            .checkbox-color-wrapper .dx-checkbox-text {
                font-weight: 600 !important;
                font-size: 13px !important;
            }
            .card-noin { background-color: var(--att-card-bg-noin); color: var(--att-card-color-noin); }
            .card-noin .dx-checkbox-text { color: var(--att-card-color-noin) !important; }

            .card-holiday { background-color: var(--att-card-bg-holiday); color: var(--att-card-color-holiday); }
            .card-holiday .dx-checkbox-text { color: var(--att-card-color-holiday) !important; }

            .card-noinnoout { background-color: var(--att-card-bg-noinnoout); color: var(--att-card-color-noinnoout); }
            .card-noinnoout .dx-checkbox-text { color: var(--att-card-color-noinnoout) !important; }

            .card-normal { background-color: var(--att-card-bg-normal); color: var(--att-card-color-normal); border: 1px solid #ced4da !important; }
            .card-normal .dx-checkbox-text { color: var(--att-card-color-normal) !important; }

            .card-noout { background-color: var(--att-card-bg-noout); color: var(--att-card-color-noout); }
            .card-noout .dx-checkbox-text { color: var(--att-card-color-noout) !important; }

            .card-workholiday { background-color: var(--att-card-bg-workholiday); color: var(--att-card-color-workholiday); }
            .card-workholiday .dx-checkbox-text { color: var(--att-card-color-workholiday) !important; }

            .card-leave { background-color: var(--att-card-bg-leave); color: var(--att-card-color-leave); }
            .card-leave .dx-checkbox-text { color: var(--att-card-color-leave) !important; }

            .card-abnormal { background-color: var(--att-card-bg-abnormal); color: var(--att-card-color-abnormal); }
            .card-abnormal .dx-checkbox-text { color: var(--att-card-color-abnormal) !important; }

            /* Grid Colors & Hover States */
            .dx-data-row.grid-row-workholiday > td { background-color: var(--att-card-bg-workholiday) !important; color: var(--att-card-color-workholiday) !important; }
            .dx-data-row.grid-row-holiday > td { background-color: var(--att-card-bg-holiday) !important; color: var(--att-card-color-holiday) !important; }

            /* Weekend Highlights (Overrides normal holiday/workholiday to specify Sat/Sun in green) */
            .dx-data-row.grid-row-saturday > td { background-color: var(--att-card-bg-holiday) !important; color: var(--att-card-color-holiday) !important; }
            .dx-data-row.grid-row-sunday > td { background-color: var(--att-card-bg-holiday) !important; color: var(--att-card-color-holiday) !important; }

            /* Leave has highest priority */
            .dx-data-row.grid-row-leave > td { background-color: var(--att-card-bg-leave) !important; color: var(--att-card-color-leave) !important; }

            .dx-data-row > td.grid-cell-noinnoout { background-color: var(--att-card-bg-noinnoout) !important; color: var(--att-card-color-noinnoout) !important; }
            .dx-data-row > td.grid-cell-noout { background-color: var(--att-card-bg-noout) !important; color: var(--att-card-color-noout) !important; }
            .dx-data-row > td.grid-cell-noin { background-color: var(--att-card-bg-noin) !important; color: var(--att-card-color-noin) !important; }

            /* Hover Overrides (Maintain colors and apply darkening overlay) */
            .dx-data-row.dx-state-hover.grid-row-workholiday > td { background-color: var(--att-card-bg-workholiday) !important; background-image: linear-gradient(rgba(33, 37, 41, 0.05), rgba(33, 37, 41, 0.05)) !important; color: var(--att-card-color-workholiday) !important; }
            .dx-data-row.dx-state-hover.grid-row-holiday > td { background-color: var(--att-card-bg-holiday) !important; background-image: linear-gradient(rgba(33, 37, 41, 0.05), rgba(33, 37, 41, 0.05)) !important; color: var(--att-card-color-holiday) !important; }
            .dx-data-row.dx-state-hover.grid-row-saturday > td { background-color: var(--att-card-bg-holiday) !important; background-image: linear-gradient(rgba(33, 37, 41, 0.05), rgba(33, 37, 41, 0.05)) !important; color: var(--att-card-color-holiday) !important; }
            .dx-data-row.dx-state-hover.grid-row-sunday > td { background-color: var(--att-card-bg-holiday) !important; background-image: linear-gradient(rgba(33, 37, 41, 0.05), rgba(33, 37, 41, 0.05)) !important; color: var(--att-card-color-holiday) !important; }
            .dx-data-row.dx-state-hover.grid-row-leave > td { background-color: var(--att-card-bg-leave) !important; background-image: linear-gradient(rgba(33, 37, 41, 0.05), rgba(33, 37, 41, 0.05)) !important; color: var(--att-card-color-leave) !important; }

            .dx-data-row.dx-state-hover > td.grid-cell-noinnoout { background-color: var(--att-card-bg-noinnoout) !important; background-image: linear-gradient(rgba(33, 37, 41, 0.05), rgba(33, 37, 41, 0.05)) !important; color: var(--att-card-color-noinnoout) !important; }
            .dx-data-row.dx-state-hover > td.grid-cell-noout { background-color: var(--att-card-bg-noout) !important; background-image: linear-gradient(rgba(33, 37, 41, 0.05), rgba(33, 37, 41, 0.05)) !important; color: var(--att-card-color-noout) !important; }
            .dx-data-row.dx-state-hover > td.grid-cell-noin { background-color: var(--att-card-bg-noin) !important; background-image: linear-gradient(rgba(33, 37, 41, 0.05), rgba(33, 37, 41, 0.05)) !important; color: var(--att-card-color-noin) !important; }

            .inputs-group {
                display: flex;
                flex-direction: row;
                flex-wrap: wrap;
                gap: 16px;
                align-items: center;
            }
            .input-row {
                display: flex;
                align-items: center;
                gap: 8px;
            }
            .input-label {
                font-weight: 600;
                font-size: 13px;
                color: var(--text-color);
            }
            .input-control {
                width: 140px;
            }
            .grid-container {
                flex: 1;
                min-height: 0;
                display: flex;
                flex-direction: column;
                background-color: var(--background-color, #ffffff);
                border-radius: 8px;
                overflow: hidden;
                min-width: 0;
                box-shadow: 0 4px 6px -1px rgba(33, 37, 41, 0.05), 0 2px 4px -1px rgba(33, 37, 41, 0.03);
            }

            #GridDailyAttendanceData .dx-datagrid-header-panel {
                padding: 8px 10px;
            }
            #GridDailyAttendanceData .dx-toolbar {
                height: auto;
            }
            #GridDailyAttendanceData .dx-toolbar .dx-toolbar-items-container {
                display: flex;
                flex-wrap: wrap;
                align-items: center;
                gap: 8px;
                height: auto;
                min-height: 40px;
            }
            #GridDailyAttendanceData .dx-toolbar .dx-toolbar-before,
            #GridDailyAttendanceData .dx-toolbar .dx-toolbar-after {
                position: static;
                display: flex;
                flex-wrap: wrap;
                align-items: center;
                gap: 8px;
                min-width: 0;
            }
            #GridDailyAttendanceData .dx-toolbar .dx-toolbar-before {
                flex: 1 1 500px;
            }
            #GridDailyAttendanceData .dx-toolbar .dx-toolbar-after {
                flex: 0 1 auto;
                margin-left: auto;
                right: auto;
            }
            #GridDailyAttendanceData .dx-toolbar .dx-toolbar-item {
                padding: 0;
            }
            #GridDailyAttendanceData .attendance-date-actions-item,
            #GridDailyAttendanceData .attendance-date-actions-item .dx-toolbar-item-content {
                display: flex;
                flex: 0 1 auto;
                min-width: 0;
            }
            #GridDailyAttendanceData .attendance-date-actions {
                display: flex;
                flex: 0 1 auto;
                flex-wrap: wrap;
                align-items: center;
                gap: 8px 10px;
                min-width: 0;
            }
            #GridDailyAttendanceData .attendance-date-field {
                display: flex;
                align-items: center;
                gap: 6px;
                flex: 0 0 auto;
                min-width: 0;
            }
            #GridDailyAttendanceData .attendance-toolbar-label {
                font-size: 12px;
                font-weight: 600;
                color: var(--text-color, var(--bs-body-color));
                white-space: nowrap;
            }
            #GridDailyAttendanceData .attendance-date-box {
                flex: 0 0 120px;
                width: 120px !important;
                min-width: 120px !important;
                max-width: 120px;
            }
            #GridDailyAttendanceData .attendance-recalculate {
                flex: 0 0 auto;
                border-radius: var(--paradise-border-radius-md);
                overflow: visible !important;
            }
            #GridDailyAttendanceData .attendance-recalculate .dx-button-content {
                line-height: normal !important;
                overflow: visible !important;
            }
            #GridDailyAttendanceData .attendance-recalculate .dx-button-text {
                line-height: 1.35 !important;
                overflow: visible !important;
            }
            #GridDailyAttendanceData .dx-datagrid-search-panel {
                min-width: 180px;
                max-width: 260px;
            }
            @media (max-width: 1280px) {
                #GridDailyAttendanceData .dx-toolbar .dx-toolbar-before,
                #GridDailyAttendanceData .dx-toolbar .dx-toolbar-after {
                    flex: 1 1 100%;
                    width: 100%;
                    margin-left: 0;
                }
                #GridDailyAttendanceData .dx-toolbar .dx-toolbar-after {
                    justify-content: flex-end;
                }
            }
            @media (max-width: 768px) {
                .attendance-container {
                    height: calc(100vh - 6.75rem) !important;
                    height: calc(100dvh - 6.75rem) !important;
                    min-height: 28rem !important;
                    padding: 8px;
                    gap: 8px;
                }
                .checkbox-grid {
                    grid-template-columns: repeat(2, minmax(0, 1fr));
                }
                #GridDailyAttendanceData .attendance-date-actions {
                    width: 100%;
                }
                #GridDailyAttendanceData .attendance-date-field {
                    flex: 1 1 calc(50% - 8px);
                }
                #GridDailyAttendanceData .attendance-date-box {
                    flex: 1 1 auto;
                    width: 100% !important;
                    min-width: 0 !important;
                    max-width: none;
                }
            }
            @media (max-width: 520px) {
                #GridDailyAttendanceData .attendance-date-field,
                #GridDailyAttendanceData .attendance-recalculate {
                    flex: 1 1 100%;
                    width: 100%;
                }
                #GridDailyAttendanceData .attendance-recalculate.dx-button {
                    width: 100%;
                }
                #GridDailyAttendanceData .dx-datagrid-search-panel {
                    flex: 1 1 100%;
                    width: 100% !important;
                    max-width: none;
                }
            }

            /* Skeleton / Shimmer */
            .skeleton-overlay-container {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                z-index: 1050;
                background-color: var(--background-color, #ffffff);
                padding: 15px;
                box-sizing: border-box;
                display: flex;
                flex-direction: column;
                gap: 15px;
            }
            .skeleton-row {
                display: flex;
                gap: 15px;
                width: 100%;
                align-items: center;
            }
            .skeleton-cell {
                height: 20px;
                background: linear-gradient(90deg, #f8f9fa 25%, #e9ecef 50%, #f8f9fa 75%);
                background-size: 200% 100%;
                animation: shimmer-effect 1.5s infinite linear;
                border-radius: 4px;
            }
            @keyframes shimmer-effect {
                0% { background-position: 200% 0; }
                100% { background-position: -200% 0; }
            }
        </style>

        <div class="filter-panel">
            <div class="checkbox-grid">
                <div class="checkbox-color-wrapper card-noout" title="%daily_attendance_no_out%">
                    <div id="NoOut_Checkbox"></div>
                </div>
                <div class="checkbox-color-wrapper card-noin" title="%daily_attendance_no_in%">
                    <div id="NoIn_Checkbox"></div>
                </div>
                <div class="checkbox-color-wrapper card-noinnoout" title="%daily_attendance_no_in_out%">
                    <div id="NoInNoOut_Checkbox"></div>
                </div>
                <div class="checkbox-color-wrapper card-normal" title="%daily_attendance_normal%">
                    <div id="Normal_Checkbox"></div>
                </div>
                <div class="checkbox-color-wrapper card-workholiday" title="%daily_attendance_work_on_holiday%">
                    <div id="WorkOnHoliday_Checkbox"></div>
                </div>
                <div class="checkbox-color-wrapper card-leave" title="%daily_attendance_leave%">
                    <div id="Leave_Checkbox"></div>
                </div>
                <div class="checkbox-color-wrapper card-holiday" title="%daily_attendance_holiday%">
                    <div id="Holiday_Checkbox"></div>
                </div>
                <div class="checkbox-color-wrapper card-abnormal" title="%daily_attendance_abnormal%" style="display: none;">
                    <div id="Abnormal_Checkbox"></div>
                </div>
            </div>
            <div id="EmployeeID_Box" style="display: none;"></div>
        </div>


        <div class="grid-container">
            <div id="GridDailyAttendanceData" style="height: 100%;"></div>
        </div>
    </div>

    <script>
        (() => {
            let api = true;
            let DataSource = [];
            let _currentKeyword = "";
             let dataStore_GridDailyAttendanceData = null;
              window._salaryPeriodFromDate = (typeof window.SalaryPeriodFromDateStr !== "undefined" && window.SalaryPeriodFromDateStr) 
                  ? window.SalaryPeriodFromDateStr 
                  : (window.SalaryPeriodFromDate || ' + ISNULL('''' + @InitFromDateStr + '''', 'null') + ');
              window._salaryPeriodToDate = (typeof window.SalaryPeriodToDateStr !== "undefined" && window.SalaryPeriodToDateStr) 
                  ? window.SalaryPeriodToDateStr 
                  : (window.SalaryPeriodToDate || ' + ISNULL('''' + @InitToDateStr + '''', 'null') + ');
              if (!window._salaryPeriodFromDate || !window._salaryPeriodToDate) {
                  window._salaryPeriodFromDate = ' + ISNULL('''' + @InitFromDateStr + '''', 'null') + ';
                  window._salaryPeriodToDate   = ' + ISNULL('''' + @InitToDateStr + '''', 'null') + ';
              }
              window._salaryPeriodLoaded = true;
              window._dailyAlertFilterValue = null;
              window._dailyAlertFilterSql = null;
              (function() {
                  try {
                      var pStr = sessionStorage.getItem("__pendingAlertFilter");
                      if (!pStr) return;
                      var p = JSON.parse(pStr);
                      if (!p || p.formName !== "spDailyAttendanceData") return;
                      var filterMap = {
                          missing_out: [[ ["In_0", "!=", null], "and", ["In_0", "!=", ""] ], "and", [ ["Out_0", "=", null], "or", ["Out_0", "=", ""] ]],
                          missing_in: [[ ["Out_0", "!=", null], "and", ["Out_0", "!=", ""] ], "and", [ ["In_0", "=", null], "or", ["In_0", "=", ""] ]],
                          unexcused_absents: [[ ["In_0", "=", null], "or", ["In_0", "=", ""] ], "and", [ ["LeaveCode", "=", null], "or", ["LeaveCode", "=", ""] ]],
                          on_leave: [["LeaveCode", "=", "Ph\u00e9p n\u0103m"], "or", ["LeaveCode", "=", "C\u00f4ng t\u00e1c"], "or", ["LeaveCode", "=", "\u0110\u00e1m tang, c\u01b0\u1edbi h\u1ecfi"], "or", ["LeaveCode", "=", "Ngh\u1ec9 l\u1ec5,T\u1ebft"], "or", ["LeaveCode", "=", "L\u00e0m online"], "or", ["LeaveCode", "=", "Annual Leave"], "or", ["LeaveCode", "=", "Bussiness trip"], "or", ["LeaveCode", "=", "Funeral / Wedding Leave"], "or", ["LeaveCode", "=", "Paid leave (holidays)"], "or", ["LeaveCode", "=", "Work from home"]],
                          unpaid_leaves: [["LeaveCode", "=", "Ngh\u1ec9 kh\u00f4ng l\u01b0\u01a1ng"], "or", ["LeaveCode", "=", "Unpaid Leave"]]
                      };
                      var rawFilterMap = {
                          missing_out: "In_0 IS NOT NULL AND LEN(In_0) > 0 AND (Out_0 IS NULL OR LEN(Out_0) = 0)",
                          missing_in: "Out_0 IS NOT NULL AND LEN(Out_0) > 0 AND (In_0 IS NULL OR LEN(In_0) = 0)"
                      };
                      window._dailyAlertFilterSql = rawFilterMap[p.alertId] || null;
                      var f = filterMap[p.alertId];
                      if (!f && !window._dailyAlertFilterSql) return;
                      window._dailyAlertFilterValue = f;
                      if (p.fromDate) window._salaryPeriodFromDate = p.fromDate;
                      if (p.toDate || p.fromDate) window._salaryPeriodToDate = p.toDate || p.fromDate;
                  } catch(e) {}
              })();

            function openDetailEmployeeID(rowData) {
                window.currentEditRowData = rowData;
                if (typeof openFormParam === "function") {
                    openFormParam(''spEmployeeDailyAttendanceData'');
                } else {
                    console.error("Hàm openFormParam chưa được định nghĩa trên window.");
                }
            };



            // Define parseDateSafe and formatDateSafe at a higher scope
            let parseDateSafe = function(val) {
                if (!val) return new Date();
                if (val instanceof Date) return val;
                let str = String(val).replace("SA", "AM").replace("CH", "PM");
                let d = new Date(str);
                if (!isNaN(d.getTime())) return d;

                // Try parse dd/MM/yyyy or dd-MM-yyyy
                let parts = str.split(/[\/\- ]/);
                if (parts.length >= 3) {
                    let day = parseInt(parts[0], 10);
                    let month = parseInt(parts[1], 10) - 1;
                    let year = parseInt(parts[2], 10);
                    let date = new Date(year, month, day);
                    if (!isNaN(date.getTime())) return date;
                }
                return new Date();
            };

            let formatDateSafe = function(val, timeSuffix) {
                if (!val) return null;
                let d = parseDateSafe(val);
                if (d && !isNaN(d.getTime())) {
                    let year = d.getFullYear();
                    let month = d.getMonth() + 1;
                    if (month < 10) month = "0" + month;
                    let day = d.getDate();
                    if (day < 10) day = "0" + day;
                    return `${year}-${month}-${day}` + (timeSuffix ? " " + timeSuffix : "");
                }
                return String(val);
            };



            function showSkeleton(containerSelector, type = "table") {
                let $container = $(containerSelector);
                if ($container.length === 0) return;

                let $loadPanel = $container.children(".dx-loadpanel-custom");
                if ($loadPanel.length === 0) {
                    $loadPanel = $("<div class=\"dx-loadpanel-custom\"></div>").appendTo($container);
                    $loadPanel.dxLoadPanel({
                        shadingColor: "rgba(0,0,0,0.4)",
                        position: { of: containerSelector },
                        visible: true,
                        showIndicator: true,
                        showPane: true,
                        shading: true,
                        closeOnOutsideClick: false
                    });
                } else {
                    $loadPanel.dxLoadPanel("instance").show();
                }
            }

            function hideSkeleton(containerSelector) {
                let $container = $(containerSelector);
                let $loadPanel = $container.children(".dx-loadpanel-custom");
                if ($loadPanel.length > 0) {
                    $loadPanel.dxLoadPanel("instance").hide();
                }
            }

            // AJAX sp_Get_SalaryPeriod call is removed since initial dates are pre-filled directly from SQL Server using fn_Get_Sal_Month_Year

            // Khởi tạo các filter controls tĩnh bằng DevExpress
            $("#Normal_Checkbox").dxCheckBox({
                value: true,
                text: "%daily_attendance_normal%",
                onValueChanged: function(e) { window.ReloadData(); }
            });
            $("#NoIn_Checkbox").dxCheckBox({
                value: true,
                text: "%daily_attendance_no_in%",
                onValueChanged: function(e) { window.ReloadData(); }
            });
            $("#NoOut_Checkbox").dxCheckBox({
                value: true,
                text: "%daily_attendance_no_out%",
                onValueChanged: function(e) { window.ReloadData(); }
            });
            $("#NoInNoOut_Checkbox").dxCheckBox({
                value: true,
                text: "%daily_attendance_no_in_out%",
                onValueChanged: function(e) { window.ReloadData(); }
            });
            $("#WorkOnHoliday_Checkbox").dxCheckBox({
                value: true,
                text: "%daily_attendance_work_on_holiday%",
                onValueChanged: function(e) { window.ReloadData(); }
            });
            $("#Leave_Checkbox").dxCheckBox({
                value: true,
                text: "%daily_attendance_leave%",
                onValueChanged: function(e) { window.ReloadData(); }
            });
            $("#Holiday_Checkbox").dxCheckBox({
  value: true,
                text: "%daily_attendance_holiday%",
                onValueChanged: function(e) { window.ReloadData(); }
            });
            $("#Abnormal_Checkbox").dxCheckBox({
                value: false,
                text: "%daily_attendance_abnormal%",
                onValueChanged: function(e) { window.ReloadData(); }
            });


            $("#EmployeeID_Box").dxTextBox({
                value: "",
                placeholder: "%daily_attendance_employee_id%",
                onEnterKey: function(e) { window.ReloadData(); }
            });

            // Tự động gắn quyền sửa cột cho Grid khi load xong
            setTimeout(() => {
                let gridInstance = $("#GridDailyAttendanceData").dxDataGrid("instance");
                if (gridInstance) {
                    gridInstance.beginUpdate();
                    gridInstance.option("onCellClick", function(e) {
                        if (e.column && (e.column.dataField === "Approved" || e.column.dataField === "Reason")) {
                            return;
                        }
                        let rowData = e.data;
                        if (rowData) {
                            openDetailEmployeeID(rowData);
                        }
                    });
                    gridInstance.option("editing", {
                        mode: "cell",
                        allowUpdating: true
                    });
                    gridInstance.columnOption("Approved", "dataType", "boolean");
                    gridInstance.columnOption("Approved", "allowEditing", false);
                    gridInstance.columnOption("Reason", "allowEditing", true);

                    // Format columns for times using cellTemplate to override the database-level template
                    let formatTimeCellTemplate = function(cellElement, cellInfo) {
                        const val = cellInfo.value;
                        if (!val || val === "") {
                            $("<div>").addClass("dx-placeholder").text("").appendTo(cellElement);
                            return;
                        }
                        const d = new Date(val);
                        if (!isNaN(d.getTime())) {
                            let hh = String(d.getHours()).padStart(2, ''0'');
                            let mm = String(d.getMinutes()).padStart(2, ''0'');
                            let ss = String(d.getSeconds()).padStart(2, ''0'');
                            $("<div>").text(hh + ":" + mm + ":" + ss).appendTo(cellElement);
                        } else {
                            $("<div>").text(cellInfo.text || val).appendTo(cellElement);
                        }
                    };
                    gridInstance.columnOption("In_0", "cellTemplate", formatTimeCellTemplate);
                    gridInstance.columnOption("Out_0", "cellTemplate", formatTimeCellTemplate);
                    gridInstance.columnOption("In_1", "cellTemplate", formatTimeCellTemplate);
                    gridInstance.columnOption("Out_1", "cellTemplate", formatTimeCellTemplate);

                    let approvedCellTemplate = function(cellElement, cellInfo) {
                        $("<div>").dxCheckBox({
                            value: cellInfo.value,
                            onValueChanged: function(e) {
                                let rowData = cellInfo.data;
                                if (rowData) {
                                    rowData.Approved = e.value;
                                    AjaxHPAParadise({
                                        data: {
                                            name: ''spDailyAttendanceData_SetApproved'',
                                            param: [
                                                ''@EmployeeID'', rowData.EmployeeID,
                                                ''@AttDate'', rowData.AttDate,
                                                ''@Approved'', rowData.Approved ? 1 : 0,
                                                ''@LoginID'', window.UserID || window.LoginID || 3
                                            ]
                                        },
                                        success: function(res) {
                                            uiManager.showAlert({ type: ''success'', message: ''%daily_attendance_approve_success%'' });
                                        },
                                        error: function(err) {
                                            uiManager.showAlert({ type: ''danger'', message: ''%daily_attendance_approve_error%'' + err });
                                        }
                                    });
                                }
                            }
                        }).appendTo(cellElement);
                    };
                    gridInstance.columnOption("Approved", "cellTemplate", approvedCellTemplate);

                    gridInstance.endUpdate();
                }
            }, 1000);

            dataStore_GridDailyAttendanceData = new DevExpress.data.CustomStore({
                key: "STT",
                cacheEnabled: true,
                load: function(loadOptions) {
                    let deferred = $.Deferred();
                    if (window._dailyAlertFilterValue && !loadOptions.filter) {
                        loadOptions.filter = window._dailyAlertFilterValue;
                    }

                    if (!window._salaryPeriodLoaded) {
                        deferred.resolve({ data: [], totalCount: 0 });
                        return deferred.promise();
                    }

                    showSkeleton("#GridDailyAttendanceData", "table");

                    if (!api) {
                        let results = DataSource || [];
                        let skip = loadOptions.skip || 0;
                        let take = loadOptions.take || 50;
                        let pageData = results.slice(skip, skip + take);
                        hideSkeleton("#GridDailyAttendanceData");
                        deferred.resolve({
                            data: pageData,
                            totalCount: results.length
                        });
                        return deferred.promise();
                    }

                    let fromDateBox = $("#FromDate_Box").dxDateBox("instance");
                    let fromDateVal = fromDateBox ? fromDateBox.option("value") : parseDateSafe(window._salaryPeriodFromDate);
                    let fromDate = formatDateSafe(fromDateVal);

                    let toDateBox = $("#ToDate_Box").dxDateBox("instance");
                    let toDateVal = toDateBox ? toDateBox.option("value") : parseDateSafe(window._salaryPeriodToDate);
                    let toDate = formatDateSafe(toDateVal);

                    let employeeIDBox = $("#EmployeeID_Box").dxTextBox("instance");
                    let employeeID = employeeIDBox ? (employeeIDBox.option("value") || "-1") : "-1";

                    let normalBox = $("#Normal_Checkbox").dxCheckBox("instance");
                    let normal = normalBox ? (normalBox.option("value") ? 1 : 0) : 1;
                    let noinBox = $("#NoIn_Checkbox").dxCheckBox("instance");
                    let noin = noinBox ? (noinBox.option("value") ? 1 : 0) : 1;
                    let nooutBox = $("#NoOut_Checkbox").dxCheckBox("instance");
                    let noout = nooutBox ? (nooutBox.option("value") ? 1 : 0) : 1;
                    let noinnooutBox = $("#NoInNoOut_Checkbox").dxCheckBox("instance");
                    let noinnoout = noinnooutBox ? (noinnooutBox.option("value") ? 1 : 0) : 1;
                    let workHolidayBox = $("#WorkOnHoliday_Checkbox").dxCheckBox("instance");
                    let workHoliday = workHolidayBox ? (workHolidayBox.option("value") ? 1 : 0) : 1;
                    let leaveBox = $("#Leave_Checkbox").dxCheckBox("instance");
                    let leave = leaveBox ? (leaveBox.option("value") ? 1 : 0) : 1;
                    let holidayBox = $("#Holiday_Checkbox").dxCheckBox("instance");
                    let holiday = holidayBox ? (holidayBox.option("value") ? 1 : 0) : 1;
                    let abnormalBox = $("#Abnormal_Checkbox").dxCheckBox("instance");
                    let abnormal = abnormalBox ? (abnormalBox.option("value") ? 1 : 0) : 0;

                    let procParam = "@LoginID = " + (window.UserID || window.LoginID || 3);
                    if (fromDate) procParam += ", @FromDate = ''" + fromDate + "''";
                    if (toDate) procParam += ", @ToDate = ''" + toDate + "''";
                    procParam += ", @EmployeeID_Pram = null";

                    procParam += ", @Normal = " + normal;
                    procParam += ", @NoIn = " + noin;
                    procParam += ", @NoOut = " + noout;
                    procParam += ", @NoInNoOut = " + noinnoout;
                    procParam += ", @WorkOnHoliday = " + workHoliday;
                    procParam += ", @Leave = " + leave;
                    procParam += ", @Holiday = " + holiday;
                    procParam += ", @LanguageID = ''" + (window.LanguageID || "VN") + "''";

                    let params = [];
                    params.push("@ProcName", "spDailyAttendanceData");
                    params.push("@ProcParam", procParam);
                    params.push("@Take", loadOptions.take || 50);
                    params.push("@Skip", loadOptions.skip || 0);

                    if (loadOptions.requireTotalCount) {
                        params.push("@RequireTotalCount", 1);
                    }

                    let sort = loadOptions.sort
                        ? loadOptions.sort.map(s => s.selector + (s.desc ? " DESC" : " ASC")).join(",")
                        : "EmployeeID ASC, AttDate ASC";

                    params.push("@Sort", sort != "" ? "ORDER BY " + sort : "");

                    if (_currentKeyword) {
                        params.push("@SearchValue", _currentKeyword);
                        params.push("@ColumnSearch", "EmployeeID,FullName");
                    }

                    if (window._dailyAlertFilterSql) {
                        params.push("@Filters", window._dailyAlertFilterSql);
                    } else if (loadOptions.filter) {
                        let hasFunction = JSON.stringify(loadOptions.filter, (key, val) => {
                            if (typeof val === "function") return "FUNCTION";
                            return val;
                        }).includes("FUNCTION");

                        if (!hasFunction) {
                            params.push("@Filters", createConditionQuery(loadOptions.filter));
                        }
                    }

                    AjaxHPAParadise({
                        data: {
                            name: "sp_LoadGridUsingAPI",
                            param: params
                        },
                        success: function (res) {
                            hideSkeleton("#GridDailyAttendanceData");
                            let json = typeof res === "string" ? JSON.parse(res) : res;
                            let results = Array.isArray(json?.data?.[0]) ? json.data[0] : [];
                            // Map STT key for each item
                            let mappedResults = results.map((item, index) => {
                                item.STT = index + 1;
                                return item;
                            });

                            let result = { data: mappedResults };

                            if (loadOptions.requireTotalCount) {
                                result.totalCount = json?.data?.[1]?.[0]?.TotalCount ?? 0;
                            }

                            DataSource = mappedResults;
                                      deferred.resolve(result);
                        },
                        error: function (err) {
                            console.error("CustomStore load error:", err);
                            hideSkeleton("#GridDailyAttendanceData");
                            deferred.reject("Data Loading Error");
                        }
                    });

                    return deferred.promise();
                },
                update: function(key, values) {
                    let deferred = $.Deferred();
                    let rowData = DataSource.find(item => item.STT === key);
                    if (rowData) {
                        Object.assign(rowData, values);
                        AjaxHPAParadise({
                            data: {
                                name: ''spDailyAttendanceData_SetApproved'',
                                param: [
                                    ''@EmployeeID'', rowData.EmployeeID,
                                    ''@AttDate'', rowData.AttDate,
                                    ''@Approved'', rowData.Approved ? 1 : 0,
                                    ''@LoginID'', window.UserID || window.LoginID || 3
                                ]
                            },
                            success: function(res) {
                                deferred.resolve();
                                uiManager.showAlert({ type: ''success'', message: ''%daily_attendance_approve_success%'' });
                            },
                            error: function(err) {
                                deferred.reject(err);
                                uiManager.showAlert({ type: ''danger'', message: ''%daily_attendance_approve_error%'' + err });
                            }
                        });
                    } else {
                        deferred.resolve();
                    }
                    return deferred.promise();
                }
            });

            window.ReloadData = function(keyword = null) {
                if (keyword !== null) _currentKeyword = keyword.trim();
                let gridInstance = typeof InstanceGridDailyAttendanceDataPCB0B9D9FCDCE482C9CBF11B3A389C278 !== "undefined"
                     ? InstanceGridDailyAttendanceDataPCB0B9D9FCDCE482C9CBF11B3A389C278
                     : $("#GridDailyAttendanceData").dxDataGrid("instance");
                if (gridInstance) {
                    api = true;
                    if (gridInstance.option("dataSource") !== dataStore_GridDailyAttendanceData) {
                        gridInstance.option("dataSource", dataStore_GridDailyAttendanceData);
                    } else {
                        gridInstance.refresh();
                    }
                }
            };

            setTimeout(() => {
                $(document).off("click", "#btnXemDuLieu").on("click", "#btnXemDuLieu", async function() {
                    showSkeleton("#GridDailyAttendanceData", "table");

                    let fromDateVal = $("#FromDate_Box").dxDateBox("instance").option("value");
                    let fromDate = formatDateSafe(fromDateVal);

                    let toDateVal = $("#ToDate_Box").dxDateBox("instance").option("value");
                    let toDate = formatDateSafe(toDateVal);

                    let employeeID = $("#EmployeeID_Box").dxTextBox("instance").option("value");
                    if (!employeeID || employeeID.trim() === "") {
                        employeeID = "-1";
                    } else {
                        employeeID = employeeID.trim();
                    }

                    let employeeID_Pram = (employeeID === "-1") ? null : employeeID;

                    let normal = $("#Normal_Checkbox").dxCheckBox("instance").option("value");
                    let noin = $("#NoIn_Checkbox").dxCheckBox("instance").option("value");
                    let noout = $("#NoOut_Checkbox").dxCheckBox("instance").option("value");
                    let noinnoout = $("#NoInNoOut_Checkbox").dxCheckBox("instance").option("value");
                    let workHoliday = $("#WorkOnHoliday_Checkbox").dxCheckBox("instance").option("value");
                    let leave = $("#Leave_Checkbox").dxCheckBox("instance").option("value");
                    let holiday = $("#Holiday_Checkbox").dxCheckBox("instance").option("value");
                    let abnormal = $("#Abnormal_Checkbox").dxCheckBox("instance").option("value");

                    try {
                        let shiftParams = [
                            "@LoginID", window.UserID || window.LoginID || 3,
                            "@FromDate", fromDate ? fromDate + " 00:00:00" : null,
                            "@ToDate", toDate ? toDate + " 23:59:59" : null,
                            "@EmployeeID", window.EmployeeID || window.employeeID
                        ];

                        await AjaxHPAParadiseAsync({
                            data: {
                                name: "sp_ShiftDetector",
                                param: shiftParams
                            },
                            success: async function (resultData) {
                                let jsonData = typeof resultData === "string" ? JSON.parse(resultData) : resultData;
                                if (jsonData.data) {
                                    jsonData.data.forEach(async (dataTable) => {
                                        if (dataTable && dataTable[0] && Object.keys(dataTable[0]).some(x => x.toLowerCase().replace("_", "") == "functionname")) {
                                        }
                                    });
                                }

                                let attendanceParams = [
                                    "@FromDate", fromDate ? fromDate + " 00:00:00" : null,
                                    "@ToDate", toDate ? toDate + " 23:59:59" : null,
                                    "@LoginID",  window.UserID || window.LoginID || 3,
                                    "@EmployeeID_Pram", null,
                                    "@Normal", normal,
                                    "@NoIn", noin,
                                    "@NoOut", noout,
                                    "@NoInNoOut", noinnoout,
                                    "@WorkOnHoliday", workHoliday,
                                    "@Leave", leave,
                                    "@Holiday", holiday
                                ];

                                await AjaxHPAParadiseAsync({
                                    data: {
                                        name: "spDailyAttendanceData",
                                        param: attendanceParams
                                    },
                                    success: async function (resData) {
                                        try {
                                            var jsonAtt = typeof resData === "string" ? JSON.parse(resData) : resData;
                                            if (jsonAtt.reason == "error") throw new Error(jsonAtt.reason ?? "%daily_attendance_unknown_error%");

                                            if (jsonAtt.data && jsonAtt.data[0]) {
                                                DataSource = jsonAtt.data[0].map((item, index) => {
                                                    item.STT = index + 1;
                                                    return item;
                                                });
                                                window.syncSharedGridData("GridDailyAttendanceData");

                                                let grid = typeof InstanceGridDailyAttendanceDataPCB0B9D9FCDCE482C9CBF11B3A389C278 !== "undefined"
                                                     ? InstanceGridDailyAttendanceDataPCB0B9D9FCDCE482C9CBF11B3A389C278
                                                     : $("#GridDailyAttendanceData").dxDataGrid("instance");
                                                 if (grid) {
                                                     api = false;
                                                     hideSkeleton(grid.element ? grid.element() : "#GridDailyAttendanceData");
                                                     if (grid.option("dataSource") !== dataStore_GridDailyAttendanceData) {
                                                         grid.option("dataSource", dataStore_GridDailyAttendanceData);
                                                     } else {
                                                         grid.refresh();
                                                     }
                                                 } else {
                                                     console.warn("grid NOT found");
                                                 }
                                            } else {
                                                hideSkeleton("#GridDailyAttendanceData");
                                            }
                                        } catch (err) {
                                            hideSkeleton("#GridDailyAttendanceData");
                                            uiManager.showAlert({ type: "danger", message: "%daily_attendance_error_prefix%" + (err.message || err) });
                                        }
                                    },
                                    error: function (err) {
                                        console.error("spDailyAttendanceData error callback:", err);
                                        hideSkeleton("#GridDailyAttendanceData");
                                        uiManager.showAlert({ type: "danger", message: "%daily_attendance_error_prefix%" + (err.statusText || err) });
                                    }
                                });
                            },
                            error: function (err) {
                                console.error("sp_ShiftDetector error callback:", err);
                                hideSkeleton("#GridDailyAttendanceData");
                                uiManager.showAlert({ type: "danger", message: "%daily_attendance_error_prefix%" + (err.statusText || err) });
                            }
                        });
                    } catch (e) {
                        console.error("try-catch block error:", e);
                        hideSkeleton("#GridDailyAttendanceData");
                        uiManager.showAlert({ type: "danger", message: "%daily_attendance_error_prefix%" + (e.message || e) });
                    }
                });

        async function hpaDailyAttendanceConfirm(message, title) {
            return await new Promise(function(resolve) {
                const onConfirm = function() { resolve(true); };
                const onCancel = function() { resolve(false); };
                if (typeof showConfirmPopup === "function") {
                    showConfirmPopup({
                        title: title || "%daily_attendance_confirm_title%",
                        message: message || "",
                        onYes: onConfirm,
                        onNo: onCancel
                    });
                    return;
                }
                if (typeof uiManager !== "undefined" && uiManager.showConfirmPopup) {
                    uiManager.showConfirmPopup({
                        title: title || "%daily_attendance_confirm_title%",
                        content: message || "",
                        onConfirm: onConfirm,
                        onCancel: onCancel
                    });
                    return;
                }
                console.error("showConfirmPopup/uiManager.showConfirmPopup is not available", { message, title });
                resolve(false);
            });
        }

                $(document).off("click", "#btnTinhLai").on("click", "#btnTinhLai", async function() {
                    let fromDateVal = parseDateSafe($("#FromDate_Box").dxDateBox("instance").option("value"));
                    let toDateVal = parseDateSafe($("#ToDate_Box").dxDateBox("instance").option("value"));

                    if (!fromDateVal || !toDateVal) {
                        uiManager.showAlert({ type: "warning", message: "%daily_attendance_select_date_range%" });
                        return;
                    }

                    showSkeleton("#spDailyAttendanceData_html", "form");

                    let dFrom = new Date(fromDateVal);
                    let dTo = new Date(toDateVal);
                    let monthsToCheck = [];
                    let curr = new Date(dFrom.getFullYear(), dFrom.getMonth(), 1);
                    while (curr <= dTo) {
                        monthsToCheck.push({ month: curr.getMonth() + 1, year: curr.getFullYear() });
                        curr.setMonth(curr.getMonth() + 1);
                    }

                    let isAnyLocked = false;
                    let lockedMonthsText = [];
                    try {
                        for (let item of monthsToCheck) {
                            let checkRes = await AjaxHPAParadiseAsync({
                                data: {
                                    name: "sp_LockAttendanceData_CheckStatus",
                                    param: [
                                        "@Month", item.month,
                                        "@Year", item.year,
                                        "@PeriodID", "0",
                                        "@LoginID", window.UserID || window.LoginID || 3,
                                        "@LanguageID", window.LanguageID || "VN"
                                    ]
                                }
                            });
                            let jsonCheck = typeof checkRes === "string" ? JSON.parse(checkRes) : checkRes;
                            let dataIndex = 0;
                            if (jsonCheck?.data?.[0]?.length > 0 && typeof jsonCheck.data[0][0].Column1 !== "undefined" && jsonCheck.data.length > 1) {
                                dataIndex = 1;
                            }
                            let checkList = Array.isArray(jsonCheck?.data?.[dataIndex]) ? jsonCheck.data[dataIndex] : [];
                            let isLocked = checkList.some(row => row.Remark && (row.Remark.includes("Đã khóa công") || row.Remark.includes("Attendance Locked")));
                            if (isLocked) {
                                isAnyLocked = true;
                                lockedMonthsText.push(item.month + "/" + item.year);
                            }
                        }
                    } catch (e) {
                        console.error("Lỗi kiểm tra khóa công:", e);
                    }

                    hideSkeleton("#spDailyAttendanceData_html");

                    if (isAnyLocked) {
                        let msg = "%daily_attendance_month_locked%".replace("{0}", lockedMonthsText.join(", "));
                        uiManager.showAlert({
                            type: "warning",
                            message: msg
                        });
                        return;
                    }

                    if (await hpaDailyAttendanceConfirm("%daily_attendance_recalculate_confirm%", "%daily_attendance_confirm_title%")) {
                            showSkeleton("#spDailyAttendanceData_html", "form");

                            let fromDate = dFrom.getFullYear() + "-" + String(dFrom.getMonth() + 1).padStart(2, "0") + "-" + String(dFrom.getDate()).padStart(2, "0");
                            let toDate = dTo.getFullYear() + "-" + String(dTo.getMonth() + 1).padStart(2, "0") + "-" + String(dTo.getDate()).padStart(2, "0");

                            let fromDateStr = fromDate + " 00:00:00";
                            let toDateStr = toDate + " 23:59:59";
                            let loginId = window.UserID || window.LoginID || 3;
                            let langId = window.LanguageID || "VN";

                            let employeeID = $("#EmployeeID_Box").dxTextBox("instance").option("value");
                            if (!employeeID || employeeID.trim() === "") {
                                employeeID = "-1";
                            } else {
                                employeeID = employeeID.trim();
                            }
                            let employeeID_Pram = (employeeID === "-1") ? null : employeeID;
                            let empIdDetector = employeeID_Pram || window.EmployeeID || window.employeeID || null;

                            let normal = $("#Normal_Checkbox").dxCheckBox("instance").option("value") ? true : false;
                            let noin = $("#NoIn_Checkbox").dxCheckBox("instance").option("value") ? true : false;
                            let noout = $("#NoOut_Checkbox").dxCheckBox("instance").option("value") ? true : false;
                            let noinnoout = $("#NoInNoOut_Checkbox").dxCheckBox("instance").option("value") ? true : false;
                            let workHoliday = $("#WorkOnHoliday_Checkbox").dxCheckBox("instance").option("value") ? true : false;
                            let leave = $("#Leave_Checkbox").dxCheckBox("instance").option("value") ? true : false;
                            let holiday = $("#Holiday_Checkbox").dxCheckBox("instance").option("value") ? true : false;

                            try {
                                await AjaxHPAParadiseAsync({
                                    data: {
                                        name: "spDailyAttendanceData_ReCalculate",
                                        param: [
                                            "@LoginID", loginId,
                                            "@Fromdate", fromDateStr,
                                            "@ToDate", toDateStr,
                                            "@EmployeeID_Pram", employeeID_Pram
                                        ]
                                    }
                                });

                                await AjaxHPAParadiseAsync({
                                    data: {
                                        name: "sp_ShiftDetector",
                                        param: [
                                            "@LoginID", loginId,
                                            "@FromDate", fromDateStr,
                                            "@ToDate", toDateStr,
                                            "@EmployeeID", empIdDetector
                                        ]
                                    }
                                });

                                let resData = await AjaxHPAParadiseAsync({
                                    data: {
                                        name: "spDailyAttendanceData",
                                        param: [
                                            "@FromDate", fromDateStr,
                                            "@ToDate", toDateStr,
                                            "@LoginID", loginId,
                                            "@EmployeeID_Pram", employeeID_Pram,
                                            "@Normal", normal,
                                            "@NoIn", noin,
                                            "@NoOut", noout,
                                            "@NoInNoOut", noinnoout,
                                            "@WorkOnHoliday", workHoliday,
                                            "@Leave", leave,
                                            "@Holiday", holiday,
                                            "@LanguageID", langId
                                        ]
                                    }
                                });

                                let jsonAtt = typeof resData === "string" ? JSON.parse(resData) : resData;
                                if (jsonAtt.reason == "error") throw new Error(jsonAtt.reason ?? "%daily_attendance_unknown_error%");

                                if (jsonAtt.data && jsonAtt.data[0]) {
                                    DataSource = jsonAtt.data[0].map((item, index) => {
                                        item.STT = index + 1;
                                        return item;
                                    });
                                    window.syncSharedGridData("GridDailyAttendanceData");

                                    let grid = typeof InstanceGridDailyAttendanceDataPCB0B9D9FCDCE482C9CBF11B3A389C278 !== "undefined"
                                         ? InstanceGridDailyAttendanceDataPCB0B9D9FCDCE482C9CBF11B3A389C278
                                         : $("#GridDailyAttendanceData").dxDataGrid("instance");
                                     if (grid) {
                                         api = false;
                                         hideSkeleton(grid.element ? grid.element() : "#GridDailyAttendanceData");
                                         if (grid.option("dataSource") !== dataStore_GridDailyAttendanceData) {
                                             grid.option("dataSource", dataStore_GridDailyAttendanceData);
                                         } else {
                                             grid.refresh();
                                         }
                                     }
                                }
                                hideSkeleton("#spDailyAttendanceData_html");
                                uiManager.showAlert({ type: "success", message: "%daily_attendance_recalculate_success%" });
                            } catch (err) {
                                hideSkeleton("#spDailyAttendanceData_html");
                                uiManager.showAlert({ type: "danger", message: "%daily_attendance_recalculate_error%" + (err.message || err.statusText || err) });
                            }
                        }
                });

                /*
                $(document).off("click", "#btnLuu").on("click", "#btnLuu", function() {
                    let grid = $("#GridDailyAttendanceData").dxDataGrid("instance");
                    if (!grid) return;

                    grid.saveEditData().done(function() {
                        let sharedKey = "GridDailyAttendanceData";
                        let entry = window.hpaSharedGridDataSources[sharedKey];
                        let data = entry ? entry.getData() : [];

                        if (data.length === 0) {
                            uiManager.showAlert({ type: "warning", message: "Không có dữ liệu thay đổi để lưu." });
                            return;
                        }

                        showSkeleton("#spDailyAttendanceData_html", "form");

                        AjaxHPAParadise({
           data: {
                                name: "spDailyAttendanceData_Update",
                                param: [
                                    "LoginID", window.UserID || window.LoginID || 3,
                                    "__TempTableData", JSON.stringify(data)
                                ]
                            },
                            success: function(res) {
                                hideSkeleton("#spDailyAttendanceData_html");
                                uiManager.showAlert({ type: "success", message: "Lưu dữ liệu thành công!" });
                                window.ReloadData();
                            },
                            error: function(err) {
                                hideSkeleton("#spDailyAttendanceData_html");
                                uiManager.showAlert({ type: "danger", message: "Lỗi khi lưu dữ liệu: " + err });
                            }
                        });
                    });
                });
                */

                // Custom DevExpress Toolbar Buttons
                let gridInstance = $("#GridDailyAttendanceData").dxDataGrid("instance");
                if (gridInstance) {
                    const attendanceRoot = document.getElementById("spDailyAttendanceData_html");
                    if (attendanceRoot) {
                        attendanceRoot.style.height = "calc(100vh - 7.75rem)";
                        attendanceRoot.style.minHeight = "32rem";
                        attendanceRoot.style.overflow = "hidden";
                    }
                    gridInstance.beginUpdate();
                    gridInstance.option({
                        "height": "100%",
                        "remoteOperations": { paging: true, filtering: true, sorting: true, searching: true },
                        "scrolling.mode": "infinite",
                        "scrolling.rowRenderingMode": "virtual",
                        "scrolling.preloadEnabled": false,
                        "paging.enabled": true,
                        "paging.pageSize": 50,
                        "pager.visible": false,
                        "pager.showPageSizeSelector": false,
                        "pager.showNavigationButtons": false,
                        "pager.showInfo": false
                    });
                    gridInstance.option("onRowPrepared", function(e) {
                        if (e.rowType === "data") {
                            let d = e.data;
                            let isWeekend = false;
                            let isSaturday = false;
                            let isSunday = false;
                            if (d.AttDate) {
                                  let dayOfWeek = new Date(d.AttDate).getDay();
                                  if (dayOfWeek === 6) { isWeekend = true; isSaturday = true; }
                                  else if (dayOfWeek === 0) { isWeekend = true; isSunday = true; }
                            }
                            let hasTime = (d.In_0 || d.Out_0 || d.In_1 || d.Out_1);
                            if (d.LeaveCode || d.LeaveStatus > 0 || d.LvAmount > 0) {
                                e.rowElement.addClass("grid-row-leave");
                            } else if (d.HolidayStatus === 1 || d.IsHoliday === 1 || d.DateStatus === 1 || isWeekend) {
                                if (hasTime) {
                                    e.rowElement.addClass("grid-row-workholiday");
                                } else {
                                    e.rowElement.addClass("grid-row-holiday");
                                }
                            }

                            if (!hasTime) {
                                if (isSaturday) {
                                    e.rowElement.addClass("grid-row-saturday");
                                } else if (isSunday) {
                                    e.rowElement.addClass("grid-row-sunday");
                                }
                            }
                        }
                    });
                    gridInstance.option("onCellPrepared", function(e) {
                        if (e.rowType === "data") {
                            let d = e.data;
                            let col = e.column.dataField;
                            if (col === "In_0" || col === "Out_0" || col === "In_1" || col === "Out_1") {
                                let inVal, outVal;
                                if (col === "In_0" || col === "Out_0") { inVal = d.In_0; outVal = d.Out_0; }
                                else { inVal = d.In_1; outVal = d.Out_1; }

                                let isWeekend = false;
                                if (d.AttDate) {
                                    let dayOfWeek = new Date(d.AttDate).getDay();
                                    if (dayOfWeek === 6 || dayOfWeek === 0) { isWeekend = true; }
                                }
                                let isHoliday = (d.HolidayStatus === 1 || d.IsHoliday === 1 || d.DateStatus === 1);

                                if (!inVal && !outVal) {
                                    if (!isWeekend && !isHoliday) {
                                        e.cellElement.addClass("grid-cell-noinnoout");
                                    }
                                } else if (inVal && !outVal) {
                                    e.cellElement.addClass("grid-cell-noout");
                                } else if (!inVal && outVal) {
                                    e.cellElement.addClass("grid-cell-noin");
                                }
                            }
                        }
                    });
                    gridInstance.option("onToolbarPreparing", function (e) {
                        var toolbarItems = e.toolbarOptions.items;



                        // Keep date filters and recalculate action as one responsive unit.
                        toolbarItems.unshift({
                            name: "attendanceDateActions",
                            location: "before",
                            locateInMenu: "never",
                            cssClass: "attendance-date-actions-item",
                            template: function() {
                                var createDateField = function(id, label, value) {
                                    var $field = $("<div class=\"attendance-date-field\"></div>");
                                    $("<span class=\"attendance-toolbar-label\"></span>").text(label).appendTo($field);
                                    var $dateBox = $("<div class=\"attendance-date-box\"></div>").attr("id", id).appendTo($field);
                                    $dateBox.dxDateBox({
                                        type: "date",
                                        displayFormat: "dd/MM/yyyy",
                                        dateSerializationFormat: "yyyy-MM-dd",
                                        value: value,
                                        height: 32,
                                        width: 120,
                                        elementAttr: { class: "attendance-date-box" },
                                        onValueChanged: function(ev) {
                                            if (ev.event) window.ReloadData();
                                        }
                                    });
                                    return $field;
                                };

                                var $group = $("<div class=\"attendance-date-actions\"></div>");
                                $group.append(createDateField(
                                    "FromDate_Box",
                                    "%daily_attendance_from_date%",
                                    window._salaryPeriodFromDate ? parseDateSafe(window._salaryPeriodFromDate) : parseDateSafe(' + ISNULL('''' + @InitFromDateStr + '''', 'new Date()') + ')
                                ));
                                $group.append(createDateField(
                                    "ToDate_Box",
                                    "%daily_attendance_to_date%",
                                    window._salaryPeriodToDate ? parseDateSafe(window._salaryPeriodToDate) : parseDateSafe(' + ISNULL('''' + @InitToDateStr + '''', 'new Date()') + ')
                                ));

                                var $recalculate = $("<div></div>")
                                    .attr("id", "btnTinhLai")
                                    .appendTo($group);
                                $recalculate.dxButton({
                                    text: "%daily_attendance_recalculate%",
                                    height: 32,
                                    stylingMode: "contained",
                                    elementAttr: { class: "attendance-recalculate paradise-btn paradise-btn--primary" }
                                });

                                return $group;
                            }
                        });

                        let formatDateSafe = function(val, timeSuffix) {
                            if (!val) return null;
                            let d = null;
                            if (val instanceof Date) {
                                d = val;
                            } else {
                                // Try parsing string
                                d = new Date(val);
                                if (isNaN(d.getTime())) {
                                    // Try parsing dd/MM/yyyy or dd-MM-yyyy
                                    let parts = String(val).split(/[\/\-]/);
                                    if (parts.length === 3) {
                                        if (parts[0].length === 4) {
                                            d = new Date(parts[0], parts[1] - 1, parts[2]);
                                        } else {
                                            d = new Date(parts[2], parts[1] - 1, parts[0]);
                                        }
                                    }
                                }
                            }
                            if (d && !isNaN(d.getTime())) {
                                let year = d.getFullYear();
                                let month = d.getMonth() + 1;
                                if (month < 10) month = "0" + month;
                                let day = d.getDate();
                                if (day < 10) day = "0" + day;
                                return `${year}-${month}-${day}` + (timeSuffix ? " " + timeSuffix : "");
                            }
                            return String(val);
                        };

                        let index = toolbarItems.findIndex(i => i.name === "columnChooserButton");
                        if (index === -1) index = toolbarItems.findIndex(i => i.name === "searchPanel");
                        if (index === -1) index = toolbarItems.length;

                        // Add reload button
                        if (!toolbarItems.some(i => i.options && i.options.hint === ''%daily_attendance_refresh%'')) {
                            toolbarItems.splice(index, 0, {
                                location: ''after'',
                                widget: ''dxButton'',
                                options: {
                                    icon: ''refresh'',
                                    hint: ''%daily_attendance_refresh%'',
                                    onClick: function() {
                                        window.ReloadData();
                                    }
                                }
                            });
                            index++;
                        }

                        // Only add if not already present
                        if (!toolbarItems.some(i => i.options && i.options.hint === "%daily_attendance_export_excel%")) {
                            toolbarItems.splice(index, 0, {
                                location: "after",
                                widget: "dxButton",
                                options: {
                                    icon: "xlsxfile",
                                    hint: "%daily_attendance_export_excel%",
                                    useSubmitBehavior: false,
                                    onClick: function(e) {
                                        if (e && e.event) { e.event.preventDefault(); e.event.stopPropagation(); }
                                        let grid = $("#GridDailyAttendanceData").dxDataGrid("instance");
                                        if (grid && typeof DevExpress.excelExporter !== "undefined") {
                                            let workbook = new ExcelJS.Workbook();
                                            let worksheet = workbook.addWorksheet("Sheet1");
                                            DevExpress.excelExporter.exportDataGrid({
                                                component: grid,
                                                worksheet: worksheet,
                                                autoFilterEnabled: true
                                            }).then(function() {
                                                workbook.xlsx.writeBuffer().then(function(buffer) {
                                                    saveAs(new Blob([buffer], { type: "application/octet-stream" }), "DuLieuChamCongHangNgay.xlsx");
                                                });
                                            });
                                        } else if (grid) {
                                            grid.exportToExcel(false);
                                        }
                                    }
                                }
                            });

                            toolbarItems.splice(index + 1, 0, {
                                location: "after",
                                widget: "dxButton",
                                options: {
                                    icon: "print",
                                    hint: "%daily_attendance_print_template_1%",
                                    useSubmitBehavior: false,
                                    onClick: async function(e) {
                                        if (e && e.event) { e.event.preventDefault(); e.event.stopPropagation(); }
                                        showSkeleton("#spDailyAttendanceData_html", "form");

                                        // Fallback params options helper
                                        let get_AttendanceDetail_Free_Param = function(extraOpts) {
                                            if (typeof paramsOptions !== "undefined" && typeof paramsOptions.get_AttendanceDetail_Free_Param === "function") {
                                                return paramsOptions.get_AttendanceDetail_Free_Param(extraOpts);
                                            }
                                            let fromDateVal = $("#FromDate_Box").dxDateBox("instance").option("value");
                                            let toDateVal = $("#ToDate_Box").dxDateBox("instance").option("value");
                                            let employeeID = $("#EmployeeID_Box").dxTextBox("instance").option("value") || "-1";
                                            let employeeID_Pram = (employeeID === "-1") ? null : employeeID;

                                            let base = [
                                                "@employeeid_pram", employeeID_Pram,
                                                "@FromDate", formatDateSafe(fromDateVal, "00:00:00"),
                                                "@ToDate", formatDateSafe(toDateVal, "23:59:59"),
                                                "@LoginID", window.UserID || window.LoginID || 3
                                            ];
                                            if (extraOpts) {
                                                Object.keys(extraOpts).forEach(k => {
                                                    base.push(k, extraOpts[k]);
                                                });
                                            }
                                            return base;
                                        };

                                        try {
                                            let ExportList;
                                            await AjaxHPAParadiseAsync({
                                                data: {
                                                    name: "AttendanceDetail_Free",
                                                    param: get_AttendanceDetail_Free_Param()
                                                },
                                                success: function (resultData) {
                                                    var jsonData = typeof resultData === "string" ? JSON.parse(resultData) : resultData;
                                                    if(jsonData.data && jsonData.data[0] && jsonData.data[0][0]) {
                                                        var keyExportVar = Object.keys(jsonData.data[0][0]).find(x => x.toLowerCase() == "exportname");
                                                        if(keyExportVar) {
                                                            ExportList = [...new Set(jsonData.data[0].map(item => item[keyExportVar]))];
                                                        }
                                                    }
                                                },
                                                error: function (xhr, status, error) {
                                                    hideSkeleton("#spDailyAttendanceData_html");
                                                }
                                            });

                                            await AjaxHPAParadiseParadiseAsync({
                                                data: {
                                                    name: "ExportLocationFolder",
                                                    param: ["", "AttendanceDetail_Free", "AttendanceDetail_Free.xlsx", ...get_AttendanceDetail_Free_Param({"@IsExport": true})]
                                                },
                                                success: function (resultData) {
                                                    var jsonData = typeof resultData === "string" ? JSON.parse(resultData) : resultData;
                                                    if(jsonData) {
                                                        try {
                                                            if(jsonData.result == "error") throw new Error(jsonData.reason ?? "%daily_attendance_unknown_error%");

                                                            if(window.ParadiseOption && window.ParadiseOption.AppInfoPackageName == "com.vietinsoft.onshiftparadisehr") {
                                                                hideSkeleton("#spDailyAttendanceData_html");

                                                                AjaxHPAParadiseParadise({
                                                                    data: {
                                                                        name: "MobileOpenFileAsync",
                                                                        param: [jsonData.FilePath, "AttendanceDetail_Free.xlsx"]
                                                                    },
                                                                    success: function (resultData) {},
                                                                    error: function (xhr, status, error) {}
                                                                });
                                                            } else {
                                                                jsonData = typeof jsonData.data === "string" ? JSON.parse(jsonData.data) : jsonData.data;
                                                                AjaxHPAParadiseParadise({
                                                                    data: {
                                                                        name: "ReadPathFileToByte",
                                                                        param: [jsonData.FilePath]
                                                                    },
                                                                    success: function (result) {
                                                                        var resultData = typeof result === "string" ? JSON.parse(result) : result;
                                                                        hideSkeleton("#spDailyAttendanceData_html");

                                                                        if (typeof saveAsFile === "function") {
                                                                            saveAsFile(jsonData.FileName, resultData.data);
                                                                        }
                                                                    },
                                                                    error: function (xhr, status, error) {
                                                                        hideSkeleton("#spDailyAttendanceData_html");
                                                                    }
                                                                });
                                                            }
                                                        } catch (error) {
                                                            hideSkeleton("#spDailyAttendanceData_html");

                                                            var direction = "up-push";
                                                            var position = "bottom right";
                                                            try {
                                                                var reason = JSON.parse(jsonData.reason);
                                                                reason = Array.isArray(reason) ? reason[0] : reason;
                                                                jsonData.reason = reason.ErrorDetail;
                                                            } catch(jsonError) {}
                                                            var message = jsonData.result == "error" && jsonData.reason ? jsonData.reason : error.message;
                                                            uiManager.showAlert({ type: "danger", message: message });
                                                        }
                                                    }
                                                },
                                                error: function (xhr, status, error) {
                                                    hideSkeleton("#spDailyAttendanceData_html");
                                                }
                                            });
                                        } catch (err) {
                                            hideSkeleton("#spDailyAttendanceData_html");
                                            uiManager.showAlert({ type: "danger", message: err.message || err });
                                        }
                                    }
                                }
                            });

                            toolbarItems.splice(index + 2, 0, {
                                location: "after",
                                widget: "dxButton",
                                options: {
                                    icon: "doc",
                                    hint: "%daily_attendance_print_template_2%",
                                    useSubmitBehavior: false,
                                    onClick: async function(e) {
                                        if (e && e.event) { e.event.preventDefault(); e.event.stopPropagation(); }
                                        showSkeleton("#spDailyAttendanceData_html", "form");

                                        // Fallback params options helper
                                        let get_sp_ExportSummary_Detail_Param = function(extraOpts) {
                                            if (typeof paramsOptions !== "undefined" && typeof paramsOptions.get_sp_ExportSummary_Detail_Param === "function") {
                                                return paramsOptions.get_sp_ExportSummary_Detail_Param(extraOpts);
                                            }
                                            let fromDateVal = $("#FromDate_Box").dxDateBox("instance").option("value");
                                            let toDateVal = $("#ToDate_Box").dxDateBox("instance").option("value");

                                            let base = [
                                                "@FromDate", formatDateSafe(fromDateVal, "00:00:00"),
                                                "@ToDate", formatDateSafe(toDateVal, "23:59:59"),
                                                "@LoginID", window.UserID || window.LoginID || 3,
                                                "@SalaryTermID", null,
                                                "@LanguageID", window.LanguageID || "VN"
                                            ];
                                            if (extraOpts) {
                                                Object.keys(extraOpts).forEach(k => {
                                                    base.push(k, extraOpts[k]);
                                                });
                                            }
                                            return base;
                                        };

                                        try {
                                            let ExportList;
                                            await AjaxHPAParadiseAsync({
                                                data: {
                                                    name: "sp_ExportSummary_Detail",
                                                    param: get_sp_ExportSummary_Detail_Param()
                                                },
                                                success: function (resultData) {
                                                    var jsonData = typeof resultData === "string" ? JSON.parse(resultData) : resultData;
                                                    if(jsonData.data && jsonData.data[0] && jsonData.data[0][0]) {
                                                        var keyExportVar = Object.keys(jsonData.data[0][0]).find(x => x.toLowerCase() == "exportname");
                                                        if(keyExportVar) {
                                                            ExportList = [...new Set(jsonData.data[0].map(item => item[keyExportVar]))];
                                                        }
                                                    }
                                                },
                                                error: function (xhr, status, error) {
                                                    hideSkeleton("#spDailyAttendanceData_html");
                                                }
                                            });

                                            if (ExportList) {
                                                for await (var exportItem of ExportList) {
                                                    var TemplateFileName;
                                                    await AjaxHPAParadiseAsync({
                                                        data: {
                                                            name: "sp_getExportListDetail",
                                                            param: ["@ExportName", exportItem]
                                                        },
                                                        success: function (resultData) {
                                                            var jsonData = typeof resultData === "string" ? JSON.parse(resultData) : resultData;
                                                            if(jsonData.data[0]) {
                                                                TemplateFileName = jsonData.data[0][0].TemplateFileName;
                                                            }
                                                        },
                                                        error: function (xhr, status, error) {}
                                                    });
                                                }
                                            }

                                            await AjaxHPAParadiseParadiseAsync({
                                                data: {
                                                    name: "ExportLocationFolder",
                                                    param: ["", "ExportSummary_Detail", "ExportSummaryDetail.xlsx", ...get_sp_ExportSummary_Detail_Param({"@IsExport": true})]
                                                },
                                                success: function (resultData) {
                                                    var jsonData = typeof resultData === "string" ? JSON.parse(resultData) : resultData;
                                                    if(jsonData) {
                                                        try {
                                                            if(jsonData.result == "error") throw new Error(jsonData.reason ?? "%daily_attendance_unknown_error%");

                                                            if(window.ParadiseOption && window.ParadiseOption.AppInfoPackageName == "com.vietinsoft.onshiftparadisehr") {
                                                                hideSkeleton("#spDailyAttendanceData_html");

                                                                AjaxHPAParadiseParadise({
                                                                    data: {
                                                                        name: "MobileOpenFileAsync",
                                                                        param: [jsonData.FilePath, "ExportSummaryDetail.xlsx"]
                                                                    },
                                                                    success: function (resultData) {},
                                                                    error: function (xhr, status, error) {}
                                                                });
                                                            } else {
                                                                jsonData = typeof jsonData.data === "string" ? JSON.parse(jsonData.data) : jsonData.data;
                                                                AjaxHPAParadiseParadise({
                                                                    data: {
                                                                        name: "ReadPathFileToByte",
                                                                        param: [jsonData.FilePath]
                                                                    },
                                                                    success: function (result) {
                                                                        var resultData = typeof result === "string" ? JSON.parse(result) : result;
                                                                        hideSkeleton("#spDailyAttendanceData_html");

                                                                        if (typeof saveAsFile === "function") {
                                                                            saveAsFile(jsonData.FileName, resultData.data);
                                                                        }
                                                                    },
                                                                    error: function (xhr, status, error) {
                                                                        hideSkeleton("#spDailyAttendanceData_html");
                                                                    }
                                                                });
                                                            }
                                                        } catch (error) {
                                                            hideSkeleton("#spDailyAttendanceData_html");

                                                            var direction = "up-push";
                                                            var position = "bottom right";
                                                            try {
                                                                var reason = JSON.parse(jsonData.reason);
                                                                reason = Array.isArray(reason) ? reason[0] : reason;
                                                                jsonData.reason = reason.ErrorDetail;
                                                            } catch(jsonError) {}
                                                            var message = jsonData.result == "error" && jsonData.reason ? jsonData.reason : error.message;
                                                            uiManager.showAlert({ type: "danger", message: message });
                                                        }
                                                    }
                                                },
                                                error: function (xhr, status, error) {
                                                    hideSkeleton("#spDailyAttendanceData_html");
                                                }
                                            });
                                        } catch (err) {
                                            hideSkeleton("#spDailyAttendanceData_html");
                                            uiManager.showAlert({ type: "danger", message: err.message || err });
                                        }
                                    }
                                }
                            });
                        }
                    });
                    gridInstance.endUpdate();
                    gridInstance.repaint();
                    requestAnimationFrame(function() {
                        gridInstance.updateDimensions();
                    });
                    $(window)
                        .off("resize.spDailyAttendanceResponsive")
                        .on("resize.spDailyAttendanceResponsive", function() {
                            clearTimeout(window._spDailyAttendanceResizeTimer);
                            window._spDailyAttendanceResizeTimer = setTimeout(function() {
                                if (gridInstance) gridInstance.updateDimensions();
                            }, 120);
                        });
                }

                // Define formatDateSafe has been moved to higher scope

                $(document).off("click", "#btnMau1").on("click", "#btnMau1", async function() {
                    showSkeleton("#spDailyAttendanceData_html", "form");
                    let fromDateVal = $("#FromDate_Box").dxDateBox("instance").option("value");
                    let toDateVal = $("#ToDate_Box").dxDateBox("instance").option("value");
                    let employeeID = $("#EmployeeID_Box").dxTextBox("instance").option("value") || "-1";
                    let employeeID_Pram = (employeeID === "-1") ? null : employeeID;

                    let get_AttendanceDetail_Free_Param = function(extraOpts) {
                        let base = [
                            "@employeeid_pram", employeeID_Pram || "-1",
                            "@FromDate", formatDateSafe(fromDateVal, "00:00:00"),
                            "@ToDate", formatDateSafe(toDateVal, "23:59:59"),
                            "@LoginID", window.UserID || window.LoginID || 21
                        ];
                        if (extraOpts) {
                            Object.keys(extraOpts).forEach(k => {
                                base.push(k, extraOpts[k]);
                            });
                        }
                        return base;
                    };

                    try {
                        let resultData = await AjaxHPAParadiseAsync({
                            data: {
                                name: "AttendanceDetail_Free",
                                param: get_AttendanceDetail_Free_Param()
                            }
                        });

                        var jsonData = typeof resultData === "string" ? JSON.parse(resultData) : resultData;
                        let ExportList;
                        if(jsonData.data && jsonData.data[0] && jsonData.data[0][0]) {
                            var keyExportVar = Object.keys(jsonData.data[0][0]).find(x => x.toLowerCase() == "exportname");
                            if(keyExportVar) {
                                ExportList = [...new Set(jsonData.data[0].map(item => item[keyExportVar]))];
                            }
                        }

                        let resultLocation = await AjaxHPAParadiseParadiseAsync({
                            data: {
                                name: "ExportLocationFolder",
                                param: ["", "AttendanceDetail_Free", "AttendanceDetail_Free.xlsx", ...get_AttendanceDetail_Free_Param({"@IsExport": true})]
                            }
                        });

                        var jsonLoc = typeof resultLocation === "string" ? JSON.parse(resultLocation) : resultLocation;
                        if (!jsonLoc) throw new Error("%daily_attendance_no_response_from_export%");
                        if(jsonLoc.result == "error") throw new Error(jsonLoc.reason ?? "%daily_attendance_unknown_error%");

                        if(window.ParadiseOption && window.ParadiseOption.AppInfoPackageName == "com.vietinsoft.onshiftparadisehr") {
                            hideSkeleton("#spDailyAttendanceData_html");
                            await AjaxHPAParadiseParadiseAsync({
                                data: {
                                    name: "MobileOpenFileAsync",
                                    param: [jsonLoc.FilePath, "AttendanceDetail_Free.xlsx"]
                                }
                            });
                        } else {
                            let localData = typeof jsonLoc.data === "string" ? JSON.parse(jsonLoc.data) : jsonLoc.data;
                            let fileResult = await AjaxHPAParadiseParadiseAsync({
                                data: {
                                    name: "ReadPathFileToByte",
                                    param: [localData.FilePath]
                                }
                            });

                            var fileData = typeof fileResult === "string" ? JSON.parse(fileResult) : fileResult;
                            hideSkeleton("#spDailyAttendanceData_html");
                            if (typeof saveAsFile === "function") {
                                saveAsFile(localData.FileName, fileData.data);
                            }
                        }
                    } catch (err) {
                        hideSkeleton("#spDailyAttendanceData_html");
                        var direction = "up-push";
                        var position = "bottom right";
                        let errMsg = err.message || err;
                        uiManager.showAlert({ type: "danger", message: errMsg });
                    }
                });

                $(document).off("click", "#btnMau2").on("click", "#btnMau2", async function() {
                    showSkeleton("#spDailyAttendanceData_html", "form");
                    let fromDateVal = $("#FromDate_Box").dxDateBox("instance").option("value");
                    let toDateVal = $("#ToDate_Box").dxDateBox("instance").option("value");

                    let get_sp_ExportSummary_Detail_Param = function(extraOpts) {
                        let base = [
                            "@FromDate", formatDateSafe(fromDateVal, "00:00:00"),
                            "@ToDate", formatDateSafe(toDateVal, "23:59:59"),
                            "@LoginID", window.UserID || window.LoginID || 21,
                            "@SalaryTermID", null,
                            "@LanguageID", window.LanguageID || "VN"
                        ];
                        if (extraOpts) {
                            Object.keys(extraOpts).forEach(k => {
                                base.push(k, extraOpts[k]);
                            });
                        }
                        return base;
                    };

                    try {
                        let resultData = await AjaxHPAParadiseAsync({
                            data: {
                                name: "sp_ExportSummary_Detail",
                                param: get_sp_ExportSummary_Detail_Param()
                            }
                        });

                        var jsonData = typeof resultData === "string" ? JSON.parse(resultData) : resultData;
                        let ExportList;
                        if(jsonData.data && jsonData.data[0] && jsonData.data[0][0]) {
                            var keyExportVar = Object.keys(jsonData.data[0][0]).find(x => x.toLowerCase() == "exportname");
                            if(keyExportVar) {
                                ExportList = [...new Set(jsonData.data[0].map(item => item[keyExportVar]))];
                            }
                        }

                        if (ExportList) {
                            for (var exportItem of ExportList) {
                                await AjaxHPAParadiseAsync({
                                    data: {
                                        name: "sp_getExportListDetail",
                                        param: ["@ExportName", exportItem]
                                    }
                                });
                            }
                        }

                        let resultLocation = await AjaxHPAParadiseParadiseAsync({
                            data: {
                                name: "ExportLocationFolder",
                                param: ["", "ExportSummary_Detail", "ExportSummaryDetail.xlsx", ...get_sp_ExportSummary_Detail_Param({"@IsExport": true})]
                            }
                        });

                        var jsonLoc = typeof resultLocation === "string" ? JSON.parse(resultLocation) : resultLocation;
                        if (!jsonLoc) throw new Error("%daily_attendance_no_response_from_export%");
                        if(jsonLoc.result == "error") throw new Error(jsonLoc.reason ?? "%daily_attendance_unknown_error%");

                        if(window.ParadiseOption && window.ParadiseOption.AppInfoPackageName == "com.vietinsoft.onshiftparadisehr") {
                            hideSkeleton("#spDailyAttendanceData_html");
                            await AjaxHPAParadiseParadiseAsync({
                                data: {
                                    name: "MobileOpenFileAsync",
                                    param: [jsonLoc.FilePath, "ExportSummaryDetail.xlsx"]
                                }
                            });
                        } else {
                            let localData = typeof jsonLoc.data === "string" ? JSON.parse(jsonLoc.data) : jsonLoc.data;
                            let fileResult = await AjaxHPAParadiseParadiseAsync({
                                data: {
                                    name: "ReadPathFileToByte",
                                    param: [localData.FilePath]
                                }
                            });

                            var fileData = typeof fileResult === "string" ? JSON.parse(fileResult) : fileResult;
                            hideSkeleton("#spDailyAttendanceData_html");
                            if (typeof saveAsFile === "function") {
                                saveAsFile(localData.FileName, fileData.data);
                            }
                        }
                    } catch (err) {
                        hideSkeleton("#spDailyAttendanceData_html");
                        var direction = "up-push";
                        var position = "bottom right";
                        let errMsg = err.message || err;
                        uiManager.showAlert({ type: "danger", message: errMsg });
                    }
                });
                if (typeof ReloadData === "function") ReloadData();
            }, 500);
        ';

        -- Nối phần loadUI của Grid (chứa cấu hình 14 cột động)
        SET @html = @html + N'
        ' + ISNULL(@loadUI_Grid, N'') + N'
        })();
        </script>';

        SELECT @html AS html;
/*=====
EXEC sptblCommonControlType_Signed_DUC  'spDailyAttendanceData_html'
EXEC sp_GenerateHTMLScript_new  'spDailyAttendanceData_html'
delete tblHtmlScriptCache where TableName = 'spDailyAttendanceData'
=====*/
END
