USE [Vietinsoft_ForTest_Tai2]
GO

-- ===================================================================
-- BƯỚC 1: CẬP NHẬT GIAO DIỆN STORED PROCEDURE [sp_zalo_AIgenerated_history_html]
-- ÁP DỤNG BỘ 9 NHÓM QUY TẮC BẤT BIẾN /responsive-rules:
-- 1. Master Layout Lock: Khóa max-width 1920px & Căn giữa màn hình lớn
-- 2. Bảo toàn 100% Style gốc của Component (Zalo Pill Group #00b074, Icon Buttons)
-- 3. Right-to-Left Wrapping: Cụm công cụ bên phải rớt Hàng 2 tự động bám lề phải (margin-left: auto)
-- 4. Normal Document Flow: Triệt tiêu 100% lỗi che khuất DataGrid (height: auto, position: static)
-- 5. Quy tắc 6.5: justify-content: flex-start chống dạt phải cho Capsule Tabs
-- 6. Quy tắc 7: Atomic Text Lock (flex-shrink: 0, white-space: nowrap cho Pills)
-- 7. Quy tắc 8 & 9: Viewport Boundary Lock & Cô lập cuộn Bảng dữ liệu lớn
-- 8. Chống đè icon kính lúp lên placeholder & Khóa nút Chọn cột hiển thị trực tiếp
-- ===================================================================

ALTER PROCEDURE [dbo].[sp_zalo_AIgenerated_history_html]
    @LoginID INT = 3,
    @LanguageID VARCHAR(2) = 'VN',
    @isWeb int = 0
AS
-- taidang
BEGIN
    SET NOCOUNT ON;
    DECLARE @html nvarchar(max);

    SET @html = N'
    <style>
        /* ============================================================================
           BỘ QUY CHUẨN THIẾT KẾ RESPONSIVE TOOLBAR, WIDGET & DATAGRID (/responsive-rules)
           Áp dụng cho Menu: Lịch sử tin AI tạo tin nhắn (sp_zalo_AIgenerated_history)
           ============================================================================ */

        /* 1. Nhóm 1: Master Layout Lock & Max-Width Pinning trên 2K/4K */
        #sp_zalo_AIgenerated_history_html {
            height: 100%;
            display: flex;
            flex-direction: column;
            gap: 15px;
            overflow-y: auto;
            max-width: 1920px;
            margin: 0 auto;
            min-width: 0 !important;
            box-sizing: border-box;
            overflow-x: hidden !important;
        }

        .dashboard-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 5px;
            flex-wrap: wrap;
            gap: 10px;
        }
        .dashboard-title {
            font-size: 18px;
            font-weight: bold;
            color: #00b074;
            white-space: nowrap;
        }
        
        /* 2. Bảo toàn 100% Style gốc của Pill Filter Tabs + Khóa nguyên tử (Quy tắc 7) */
        .zalo-pill-group {
            display: inline-flex !important;
            align-items: center !important;
            background: var(--bs-tertiary-bg, rgba(128, 128, 128, 0.08));
            border: 1px solid var(--bs-border-color, rgba(128, 128, 128, 0.2));
            border-radius: 20px;
            padding: 2px 3px;
            gap: 3px;
            flex-shrink: 0 !important;
            max-width: 100% !important;
            overflow-x: auto !important;
            -webkit-overflow-scrolling: touch !important;
            scrollbar-width: none !important;
        }
        .zalo-pill-group::-webkit-scrollbar {
            display: none !important;
        }
        .zalo-pill-btn {
            background: transparent;
            border: none;
            outline: none;
            color: var(--bs-secondary-color, var(--bs-body-color, #6c757d));
            border-radius: 16px;
            padding: 4px 14px;
            font-size: 12px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
            line-height: 1.4;
            flex-shrink: 0 !important;
            white-space: nowrap !important;
        }
        .zalo-pill-btn:hover {
            color: var(--bs-body-color, #212529);
            background: rgba(128, 128, 128, 0.15);
        }
        .zalo-pill-btn.active {
            background: #00b074 !important;
            color: #ffffff !important;
            font-weight: 600;
            box-shadow: 0 2px 6px rgba(0, 176, 116, 0.35);
        }

        .grid-section {
            border-radius: 8px;
            padding: 15px;
            flex: 1;
            display: flex;
            flex-direction: column;
            min-height: 380px;
            box-sizing: border-box;
            max-width: 100%;
            overflow: hidden;
        }
        .history-grid-container {
            flex: 1;
            min-height: 0;
            width: 100%;
            max-width: 100%;
        }
        
        #GridZaloHistory .dx-datagrid {
            font-size: 14px;
            height: calc(100vh - 160px);
            max-height: 85.5vh;
            table-layout: fixed !important;
        }

        /* 3. Đưa DevExtreme Toolbar về Normal Document Flow (Golden CSS Fix) */
        #GridZaloHistory .dx-datagrid-header-panel {
            height: auto !important;
            min-height: auto !important;
            overflow: visible !important;
            padding: 4px 0 8px 0 !important;
        }
        #GridZaloHistory .dx-toolbar {
            height: auto !important;
            min-height: auto !important;
            overflow: visible !important;
            background: transparent !important;
        }
        #GridZaloHistory .dx-toolbar-items-container {
            height: auto !important;
            min-height: auto !important;
            display: flex !important;
            flex-wrap: wrap !important;
            align-items: center !important;
            justify-content: flex-start !important; /* Cấm space-between theo Quy tắc 6.5 */
            row-gap: 8px !important;
            column-gap: 12px !important;
            width: 100% !important;
            padding: 0 !important;
        }

        /* 4. Đánh sập cơ chế absolute của dx-toolbar-before & after */
        #GridZaloHistory .dx-toolbar-before {
            position: static !important;
            display: flex !important;
            flex-wrap: wrap !important;
            align-items: center !important;
            max-width: 100% !important;
            min-width: 0 !important;
            height: auto !important;
            padding: 0 !important;
        }
        #GridZaloHistory .dx-toolbar-after {
            position: static !important;
            display: flex !important;
            align-items: center !important;
            flex-wrap: wrap !important;
            gap: 8px !important;
            margin-left: auto !important; /* Đẩy sát lề phải tự động */
            height: auto !important;
            padding: 0 !important;
        }
        #GridZaloHistory .dx-toolbar-center {
            display: none !important;
        }

        /* 5. Khóa hiển thị nút Chọn cột hiển thị & Ẩn menu 3 chấm thừa */
        #GridZaloHistory .dx-toolbar .dx-toolbar-item.dx-toolbar-item-auto-hide,
        #GridZaloHistory .dx-toolbar .dx-toolbar-item.dx-toolbar-item-invisible,
        #GridZaloHistory .dx-toolbar .dx-datagrid-column-chooser-button {
            display: inline-flex !important;
            visibility: visible !important;
        }
        #GridZaloHistory .dx-toolbar-menu-container {
            display: none !important;
        }

        /* 6. Chuẩn hóa ô Tìm kiếm Search Panel & Thụt lề 34px chống đè icon kính lúp */
        #GridZaloHistory .dx-datagrid-search-panel {
            margin-right: 0px !important;
            background-color: #1e293b !important;
            border: 1px solid #334155 !important;
            border-radius: 6px !important;
            width: 220px !important;
            min-width: 180px !important;
        }
        #GridZaloHistory .dx-datagrid-search-panel .dx-texteditor-input {
            color: #ffffff !important;
            -webkit-text-fill-color: #ffffff !important;
            background-color: transparent !important;
            font-size: 13px !important;
            padding-left: 34px !important;
            padding-inline-start: 34px !important;
            padding-right: 30px !important;
        }
        #GridZaloHistory .dx-datagrid-search-panel .dx-placeholder,
        #GridZaloHistory .dx-datagrid-search-panel .dx-placeholder::before {
            color: #94a3b8 !important;
            padding-left: 34px !important;
            padding-inline-start: 34px !important;
        }

        /* 7. Nhóm 9: Cô lập cuộn Bảng dữ liệu lớn */
        #GridZaloHistory .dx-datagrid-rowsview {
            width: 100% !important;
            max-width: 100% !important;
            overflow-x: auto !important;
            -webkit-overflow-scrolling: touch !important;
        }
</style>

    <div id="sp_zalo_AIgenerated_history_html">
        <!-- Grid Section -->
        <div class="grid-section border shadow-sm">
            <div class="history-grid-container">
                <div id="GridZaloHistory"></div>
            </div>
        </div>
    </div>
    ';

    SET @html = @html + N'
    <script>
      (async () => {
        let obj = {};
        let gridInstance = null;
        let currentFilterType = "ALL";

        // 1. (Đã gỡ Menu trạng thái bên ngoài, dùng filter trên lưới)

        // 3. Khởi tạo Giao diện Grid (loadUI)
        ' + ISNULL((SELECT loadUI FROM tblCommonControlType_Signed WHERE TableName = 'sp_zalo_AIgenerated_history_html' AND Type = 'hpaControlGrid_Duc'), '') + N'

        // Hàm chuyển đổi filter của DevExtreme sang SQL WHERE
        function convertFilterToSql(filter) {
            if (!filter) return "";
            if (typeof filter === "string") return filter;
            if (Array.isArray(filter)) {
                if (filter.length === 0) return "";
                if (typeof filter[0] === "string" && (filter.length === 3 || filter.length === 2)) {
                    var field = filter[0];
                    var op = filter[1];
                    var val = filter[2];
                    if (val instanceof Date) {
                        var pad = function(n) { return n < 10 ? "0" + n : n; };
                        val = val.getFullYear() + "-" + pad(val.getMonth() + 1) + "-" + pad(val.getDate()) + " " + pad(val.getHours()) + ":" + pad(val.getMinutes()) + ":" + pad(val.getSeconds());
                    }
                    if (op === "=") return field + " = ''" + val + "''";
                    if (op === "<>") return field + " <> ''" + val + "''";
                    if (op === ">") return field + " > ''" + val + "''";
                    if (op === ">=") return field + " >= ''" + val + "''";
                    if (op === "<") return field + " < ''" + val + "''";
                    if (op === "<=") return field + " <= ''" + val + "''";
                    if (op === "contains") return field + " LIKE ''%" + val + "%''";
                    if (op === "startswith") return field + " LIKE ''" + val + "%''";
                    if (op === "endswith") return field + " LIKE ''%" + val + "''";
                }
                var sqlParts = [];
                var logicalOp = " AND ";
                for (var i = 0; i < filter.length; i++) {
                    var item = filter[i];
                    if (typeof item === "string" && (item.toLowerCase() === "and" || item.toLowerCase() === "or")) {
                        logicalOp = " " + item.toUpperCase() + " ";
                    } else if (Array.isArray(item)) {
                        var subSql = convertFilterToSql(item);
                        if (subSql) sqlParts.push("(" + subSql + ")");
                    }
                }
                return sqlParts.join(logicalOp);
            }
            return "";
        }

        // 4. Khởi tạo Dữ liệu Grid (loadData) qua sp_LoadGridUsingAPI
        let ds_GridZaloHistory = new DevExpress.data.CustomStore({
            key: ["ZaloID", "SenderName", "CreateTime"],
            load: function(loadOptions) {
                const deferred = $.Deferred();
                let params = [];
                params.push("@ProcName", "sp_zalo_AIgenerated_history_Data");
                
                var loginId = window.UserID || window.LoginID || 0;
                var langId = window.LanguageID || "VN";
                
                params.push("@ProcParam", "@LoginID=" + loginId + ", @LanguageID=''" + langId + "'', @FilterStatus=''ALL'', @FilterType=''" + currentFilterType + "''");

                // Phân trang
                params.push("@Take", loadOptions.take || 50);
                params.push("@Skip", loadOptions.skip || 0);

                if (loadOptions.filter) {
                    var filterSql = convertFilterToSql(loadOptions.filter);
                    if (filterSql) {
                        params.push("@Filter", filterSql);
                    }
                }

                if (loadOptions.sort) {
                    const sortStr = loadOptions.sort.map(s => s.selector + (s.desc ? " DESC" : " ASC")).join(",");
                    params.push("@Sort", "ORDER BY " + sortStr);
                } else {
                    params.push("@Sort", "ORDER BY CreateTime DESC");
                }

                AjaxHPAParadise({
                    data: {
                        name: "sp_LoadGridUsingAPI",
                        param: params
                    },
                    success: function (res) {
                        try {
                            const json = typeof res === "string" ? JSON.parse(res) : res;
                            const results = Array.isArray(json?.data?.[0]) ? json.data[0] : [];
                            let tc = json?.data?.[1]?.[0]?.TotalCount;
                            if (tc === undefined) tc = results.length;
                            deferred.resolve({
                                data: results,
                                totalCount: tc
                            });
                        } catch(ex) {
                            deferred.reject("Parse Error");
                        }
                    },
                    error: function() {
                        deferred.reject("Network Error");
                    }
                });
                return deferred.promise();
            }
        });

        try {
            gridInstance = $("#GridZaloHistory").dxDataGrid("instance");
        } catch(ex) {}
        if (gridInstance) {
            gridInstance.option("dataSource", ds_GridZaloHistory);

            // Thêm Pill Tabs vào toolbar của Grid
            gridInstance.option("onToolbarPreparing", function(e) {
                var items = e.toolbarOptions.items;
                
                // 1. Thêm cụm Pill tabs bên trái
                items.unshift({
                    location: "before",
                    template: function() {
                        var $pillGroup = $(''<div class="zalo-pill-group"></div>'');
                        var tabs = [
                            { type: "ALL", text: "%zalo_tab_all%" },
                            { type: "FRIENDS", text: "%zalo_tab_friends%" },
                            { type: "GROUPS", text: "%zalo_tab_groups%" },
                            { type: "CUSTOMERS", text: "%zalo_tab_strangers%" }
                        ];
                        tabs.forEach(function(t) {
                            var $btn = $(''<button type="button" class="zalo-pill-btn" data-type="'' + t.type + ''">'' + t.text + ''</button>'');
                            if (t.type === currentFilterType) {
                                $btn.addClass("active");
                            }
                            $btn.on("click", function() {
                                $(".zalo-pill-btn").removeClass("active");
                                $(this).addClass("active");
                                currentFilterType = $(this).attr("data-type") || "ALL";
                                if (gridInstance) {
                                    gridInstance.refresh();
                                }
                            });
                            $pillGroup.append($btn);
                        });
                        return $pillGroup;
                    }
                });

                // 2. Thêm nút Refresh bên phải (trước Column Chooser)
                var refreshBtnItem = {
                    location: "after",
                    widget: "dxButton",
                    locateInMenu: "never",
                    options: {
                        icon: "refresh",
                        hint: "Refresh",
                        onClick: function() {
                            if (gridInstance) {
                                gridInstance.refresh();
                            }
                        }
                    }
                };
                
                // Khóa không cho DevExtreme tự động giấu nút Chọn cột và Search Panel vào menu 3 chấm
                var colChooser = items.find(function(i) { return i.name === "columnChooserButton"; });
                if (colChooser) {
                    colChooser.locateInMenu = "never";
                }
                var searchPanelItem = items.find(function(i) { return i.name === "searchPanel"; });
                if (searchPanelItem) {
                    searchPanelItem.locateInMenu = "never";
                }

                var colChooserIdx = items.findIndex(function(i) { return i.name === "columnChooserButton"; });
                if (colChooserIdx >= 0) {
                    items.splice(colChooserIdx, 0, refreshBtnItem);
                } else {
                    var searchIdx = items.findIndex(function(i) { return i.name === "searchPanel"; });
                    if (searchIdx >= 0) {
                        items.splice(searchIdx, 0, refreshBtnItem);
                    } else {
                        items.push(refreshBtnItem);
                    }
                }
            });
        }

        // Tùy chỉnh thêm các thuộc tính Grid
        if (gridInstance && typeof gridInstance.columnOption === "function") {
            gridInstance.columnOption("CreateTime", "sortOrder", "desc");
            gridInstance.columnOption("SenderName", "width", 250);
            
            // Cấu hình cột CreateTime với headerFilter nạp toàn bộ ngày từ Database
            gridInstance.columnOption("CreateTime", { 
                width: 170,
                dataType: "date",
                format: "HH:mm dd/MM/yyyy",
                calculateCellValue: function(data) {
                    if (!data.CreateTime) return null;
                    let d = new Date(data.CreateTime);
                    return isNaN(d.getTime()) ? data.CreateTime : d;
                },
                headerFilter: {
                    dataSource: function(options) {
                        var deferred = $.Deferred();
                        var loginId = window.UserID || window.LoginID || 0;
                        var langId = window.LanguageID || "VN";
                        
                        AjaxHPAParadise({
                            data: {
                                name: "sp_zalo_AIgenerated_history_Data",
                                param: [
                                    "@LoginID", loginId,
                                    "@LanguageID", langId,
                                    "@ActionType", "GET_DATE_LIST"
                                ]
                            },
                            success: function(res) {
                                try {
                                    var json = typeof res === "string" ? JSON.parse(res) : res;
                                    var rows = (json && json.data && json.data[0]) ? json.data[0] : [];
                                    var yearMap = {};
                                    
                                    rows.forEach(function(r) {
                                        var dStr = r.FullDate;
                                        if (!dStr) return;
                                        var parts = dStr.split("T")[0].split("-");
                                        var y = parseInt(parts[0], 10);
                                        var m = parseInt(parts[1], 10);
                                        var d = parseInt(parts[2], 10);
                                        
                                        if (!yearMap[y]) yearMap[y] = {};
                                        if (!yearMap[y][m]) yearMap[y][m] = [];
                                        if (yearMap[y][m].indexOf(d) === -1) yearMap[y][m].push(d);
                                    });
                                    
                                    var tree = [];
                                    Object.keys(yearMap).sort(function(a,b){ return b - a; }).forEach(function(y) {
                                        var yItem = { text: y, value: parseInt(y), items: [] };
                                        Object.keys(yearMap[y]).sort(function(a,b){ return b - a; }).forEach(function(m) {
                                            var mItem = { text: "%zalo_history_month% " + m, value: [parseInt(y), parseInt(m)], items: [] };
                                            yearMap[y][m].sort(function(a,b){ return b - a; }).forEach(function(d) {
                                                var dPadded = d < 10 ? "0" + d : d;
                                                var mPadded = m < 10 ? "0" + m : m;
                                                var dateVal = y + "-" + mPadded + "-" + dPadded;
                                                mItem.items.push({
                                                    text: d.toString(),
                                                    value: [
                                                        ["CreateTime", ">=", dateVal + " 00:00:00"],
                                                        "and",
                                                        ["CreateTime", "<=", dateVal + " 23:59:59"]
                                                    ]
                                                });
                                            });
                                            yItem.items.push(mItem);
                                        });
                                        tree.push(yItem);
                                    });
                                    deferred.resolve(tree);
                                } catch(e) {
                                    deferred.resolve([]);
                                }
                            },
                            error: function() {
                                deferred.resolve([]);
                            }
                        });
                        return deferred.promise();
                    }
                },
                cellTemplate: function(container, options) {
                    if (!options.value) return;
                    let d = new Date(options.value);
                    if (isNaN(d.getTime())) {
                        container.text(options.value);
                        return;
                    }
                    let pad = function(n) { return n < 10 ? "0" + n : n; };
                    container.text(pad(d.getHours()) + ":" + pad(d.getMinutes()) + " " + pad(d.getDate()) + "/" + pad(d.getMonth() + 1) + "/" + d.getFullYear());
                }
            });
            gridInstance.columnOption("AI_Message", {
                headerFilter: {
                    dataSource: [
                        { text: "%zalo_history_ai_generated_message%", value: [["AI_Message", "<>", "%zalo_history_spam_detected%"], "and", ["AI_Message", "<>", "%zalo_history_not_spam%"]] },
                        { text: "%zalo_history_not_spam%", value: ["AI_Message", "=", "%zalo_history_not_spam%"] },
                        { text: "%zalo_history_spam_detected%", value: ["AI_Message", "=", "%zalo_history_spam_detected%"] }
                    ]
                }
            });

            gridInstance.columnOption("Status", "width", 160);
            gridInstance.columnOption("ErrorMsg", "width", 150);
            
            gridInstance.option("onCellPrepared", function(e) {
                if (e.rowType === "data" && e.column.dataField === "AI_Message" && e.value) {
                    e.cellElement.attr("title", "%zalo_history_click_copy%");
                    e.cellElement.css("cursor", "pointer");
                    
                    let valStr = String(e.value).toLowerCase();
                    if (valStr.indexOf("không phải spam") >= 0 || valStr.indexOf("not spam") >= 0) {
                        e.cellElement.css("color", "var(--bs-warning)"); 
                        e.cellElement.css("font-weight", "500");
                    } else if (valStr.indexOf("phát hiện spam") >= 0 || valStr.indexOf("spam detected") >= 0) {
                        e.cellElement.css("color", "var(--bs-success)"); 
                        e.cellElement.css("font-weight", "500");
                    }
                }
            });

            gridInstance.option("onCellClick", function(e) {
                if(e.rowType === "data" && e.column.dataField === "AI_Message" && e.value) {
                    let text = e.value;
                    if (navigator.clipboard && window.isSecureContext) {
                        navigator.clipboard.writeText(text).then(function() {
                            DevExpress.ui.notify("%zalo_history_copied%", "success", 2000);
                        });
                    } else {
                        let textArea = document.createElement("textarea");
                        textArea.value = text;
                        textArea.style.position = "fixed";
                        textArea.style.left = "-999999px";
                        textArea.style.top = "-999999px";
                        document.body.appendChild(textArea);
                        textArea.focus();
                        textArea.select();
                        try { document.execCommand("copy"); } catch (err) {}
                        textArea.remove();
                        DevExpress.ui.notify("%zalo_history_copied%", "success", 2000);
                    }
                }
            });

            gridInstance.repaint();
        }

      })();
    </script>
    ';

    SELECT @html as html;
END
/*======
    -- Cache vào tblHtmlScriptCache
    EXEC sptblCommonControlType_Signed_DUC 'sp_zalo_AIgenerated_history_html'
    EXEC sp_GenerateHTMLScript_new 'sp_zalo_AIgenerated_history_html'

======*/
GO

-- ===================================================================
-- BƯỚC 2: CHUẨN HÓA STORED PROCEDURE ĐIỀU PHỐI [dbo].[sp_zalo_AIgenerated_history]
-- ===================================================================
ALTER PROCEDURE [dbo].[sp_zalo_AIgenerated_history](
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
    WHERE TableName = 'sp_zalo_AIgenerated_history'
      AND ScreenType = -1
      AND LanguageID = @LanguageID;
END
GO

-- ===================================================================
-- BƯỚC 3: BIÊN DỊCH MÃ NGUỒN GIAO DIỆN VÀO BẢNG CACHE VÀ CẬP NHẬT VERSION
-- ===================================================================
IF OBJECT_ID('dbo.sp_GenerateHTMLScript_new', 'P') IS NOT NULL
BEGIN
    EXEC sp_GenerateHTMLScript_new 'sp_zalo_AIgenerated_history_html', 'VN', 'sp_zalo_AIgenerated_history';
    EXEC sp_GenerateHTMLScript_new 'sp_zalo_AIgenerated_history_html', 'EN', 'sp_zalo_AIgenerated_history';
END
ELSE
BEGIN
    EXEC sp_GenerateHTMLScript 'sp_zalo_AIgenerated_history_html';
END
GO
