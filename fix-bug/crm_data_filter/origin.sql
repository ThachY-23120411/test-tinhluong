
CREATE PROCEDURE [dbo].[sp_DataFilter_html]
    @LoginID      INT           = 3,
    @LanguageID   VARCHAR(2)    = 'VN'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @html NVARCHAR(MAX) = N'';
    SET @html = @html + N'
<style>
    #dataFilterRoot .dx-selection.dx-row > td,
    #dataFilterRoot .dx-selection.dx-row > tr > td { background: rgba(0,0,0,.04) !important; }
    [data-bs-theme=dark] #dataFilterRoot .dx-selection.dx-row > td,
    [data-bs-theme=dark] #dataFilterRoot .dx-selection.dx-row > tr > td { background: rgba(255,255,255,.10) !important; }
    #dataFilterRoot .dx-datagrid-header-panel { display: none !important; }
    #filterGridContainer .dx-data-row td { user-select: text !important; -webkit-user-select: text !important; cursor: text !important; vertical-align: middle !important; padding-top: 4px !important; padding-bottom: 4px !important; }
    #filterGridContainer .dx-header-row td,
    #filterGridContainer .dx-header-row th { padding-top: 6px !important; padding-bottom: 6px !important; }
    #filterGridContainer .dx-command-select { padding-top: 4px !important; padding-bottom: 4px !important; }
    #filterGridContainer .dx-datagrid-rowsview .dx-row { height: auto !important; min-height: 0 !important; }
    .filter-item { flex: 0 1 200px; min-width: 140px; }
    .filter-item .dx-selectbox { width: 100% !important; }

    /* POPUP FORM: tối giản khoảng trống */
    #editPopupContainer .dx-popup-content { padding: 0 !important; }
    #editPopupContainer .dx-popup-body { padding: 0 !important; }
    #editPopupContainer .dx-popup-body-content,
    #editPopupContainer .dx-scrollview-content,
    #editPopupContainer .dx-scrollable-content { padding: 0 !important; }
    #editPopupContainer .dx-popup-title { padding: 6px 10px !important; min-height: auto !important; line-height: 1.2 !important; }
    #editPopupContainer .dx-toolbar-after { padding-right: 4px !important; }
    .edit-popup-wrapper { display: flex; flex-direction: column; width: 100%; padding: 4px 10px 6px; box-sizing: border-box; }
    .edit-popup-wrapper #P6B4B866340AB45CF93E7401EB5ED52F9 { margin-bottom: 2px !important; }
    .edit-popup-wrapper #P6B4B866340AB45CF93E7401EB5ED52F9 .dx-field-item { margin-bottom: 0 !important; padding-bottom: 0 !important; }
    .edit-popup-wrapper #P6B4B866340AB45CF93E7401EB5ED52F9 .dx-texteditor { margin-top: 0 !important; }
    .edit-popup-wrapper #PE9A4B07B784C4C3DBE659B6F5A63DE2C { margin-bottom: 2px !important; line-height: 1.35 !important; }
    .edit-popup-wrapper #potentialSlot { margin-bottom: 2px !important; }
    .edit-popup-wrapper #editForm { flex: 0 1 auto; margin-top: 0 !important; }
    .edit-popup-wrapper #editForm .dx-layout-manager { width: 100% !important; }
    .edit-popup-wrapper #editForm .dx-texteditor { width: 100% !important; }
    .edit-popup-wrapper #editForm .dx-field-item { padding: 0 !important; margin: 0 0 2px 0 !important; }
    .edit-popup-wrapper #editForm .dx-field-item-label { padding: 0 0 2px 0 !important; margin: 0 !important; }
    .edit-popup-wrapper #editForm .dx-field-item-label-text { font-weight: 600; }
    .edit-popup-buttons { flex: 0 0 auto; padding: 4px 0 0 !important; margin-top: 0 !important; }
    #potentialSlot #PA0BAB6BAB1BA4CAB8B0DD40E698A92CA { padding: 0 !important; margin: 0 !important; }
    #potentialSlot .dx-tagbox { width: 100% !important; min-height: 38px !important; }
    #potentialSlot .dx-tagbox .dx-texteditor-container { min-height: 0 !important; }
    #potentialSlot .dx-field-item { padding: 0 !important; margin: 0 !important; }

    /* Checkbox (Cột 1): cố định bên trái, thêm nền !important để che cột cuộn phía dưới */
    #filterGridContainer td.dx-command-select,
    #filterGridContainer th.dx-command-select {
        position: sticky !important;
        left: 0 !important;
        z-index: 800 !important;
        background-color: var(--bs-body-bg, #ffffff) !important;
    }

    /* Icon Mắt (Cột 2): cố định ngay sau Checkbox, giữ 40px là chuẩn nhất để không bị đè cột Mã */
    #filterGridContainer td.dx-datagrid-sticky-column-left.dx-datagrid-sticky-column-border-right,
    #filterGridContainer th.dx-datagrid-sticky-column-left.dx-datagrid-sticky-column-border-right,
    #filterGridContainer td[aria-colindex="2"], 
    #filterGridContainer th[aria-colindex="2"] {
        position: sticky !important;
        left: 40px !important; 
        z-index: 800 !important;
        background-color: var(--bs-body-bg, #ffffff) !important;
    }
    
    /* Chống đè màu trong suốt khi chọn dòng cho 2 cột đầu */
    #dataFilterRoot .dx-selection.dx-row > td.dx-command-select,
    #dataFilterRoot .dx-selection.dx-row > td.dx-datagrid-sticky-column-border-right,
    #dataFilterRoot .dx-selection.dx-row > td[aria-colindex="2"] { 
        background-color: var(--bs-secondary-bg, #f8f9fa) !important; 
    }
    [data-bs-theme=dark] #dataFilterRoot .dx-selection.dx-row > td.dx-command-select,
    [data-bs-theme=dark] #dataFilterRoot .dx-selection.dx-row > td.dx-datagrid-sticky-column-border-right,
    [data-bs-theme=dark] #dataFilterRoot .dx-selection.dx-row > td[aria-colindex="2"] { 
        background-color: rgba(255,255,255,.10) !important; 
    }

    /* === SKELETON SCREEN (dạng table ║──┬──║) ===
       Dùng opacity + pointer-events thay vì display:none
       để grid giữ nguyên kích thước — tránh virtual scroll tính sai chiều cao */
    #filterSkeletonOverlay {
        display: none;
        padding: 0;
        position: absolute;
        top: 42px; left: 0; right: 0; bottom: 0;
        z-index: 10;
        background: var(--bs-body-bg);
    }
    #filterGridWrapper { position: relative; }
    .skeleton-table-header {
        height: 42px; border-radius: 4px; margin-bottom: 6px;
        background: linear-gradient(90deg, var(--bs-secondary-bg) 25%, var(--bs-tertiary-bg) 50%, var(--bs-secondary-bg) 75%);
        background-size: 200% 100%;
        animation: skeletonShimmer 1.4s ease-in-out infinite;
    }
    .skeleton-table-row {
        height: 36px; border-radius: 4px; margin-bottom: 4px;
        background: linear-gradient(90deg, var(--bs-secondary-bg) 25%, var(--bs-tertiary-bg) 50%, var(--bs-secondary-bg) 75%);
        background-size: 200% 100%;
        animation: skeletonShimmer 1.4s ease-in-out infinite;
    }
    .skeleton-table-row:nth-child(odd) { opacity: 0.75; }
    @keyframes skeletonShimmer {
        0%   { background-position: 200% 0; }
        100% { background-position: -200% 0; }
    }

    /* Cho phép select & copy text trong popup import progress */
    #importProgressPopup,
    #importProgressPopup *,
    #importProgressPopup .dx-overlay-content,
    #importProgressPopup .dx-overlay-content *,
    #importProgressPopup .dx-popup-content,
    #importProgressPopup .dx-popup-content *,
    #importProgressPopup .dx-popup-wrapper,
    #importProgressPopup .dx-popup-wrapper *,
    #importProgressPopup .dx-scrollable-content,
    #importProgressPopup .dx-scrollable-content * {
        user-select: text !important;
        -webkit-user-select: text !important;
        -moz-user-select: text !important;
        -ms-user-select: text !important;
    }
    #importProgressPopup table td,
    #importProgressPopup table th {
        cursor: text !important;
    }
    /* Fix icon X (close button) không hiển thị — màu icon trùng background */
    #importProgressPopup .dx-closebutton .dx-icon {
        color: var(--bs-body-color, #333) !important;
        font-size: 18px !important;
    }
    #importProgressPopup .dx-closebutton {
        opacity: 1 !important;
        visibility: visible !important;
    }
</style>

<div class="p-3" id="dataFilterRoot" data-bs-theme="light">
    <div class="d-flex gap-2 align-items-center mb-3 w-100" style="flex-wrap: nowrap;">
        <div class="filter-item" id="PFD44AED7A8FE463BBF7B338FA58B198F" style="flex: 0 1 260px;"></div>
        <div class="filter-item" id="P051CC77BF33743BBB831F7E8FB3413F8"></div>
        <div class="filter-item" id="P25278BACA91B4C22A6809FAD6921714E"></div>

        <div class="ms-auto d-flex align-items-center gap-2" style="flex-shrink: 0;">
            <!-- Dùng class Bootstrap btn-danger/btn-success thay vì hardcode màu hex -->
            <button class="btn btn-sm btn-danger" style="border-radius: 20px; padding: 5px 15px; white-space: nowrap;" onclick="deleteSelectedData()">
                %datafilter.btnDelete%
            </button>
            <button class="btn btn-sm btn-success" style="border-radius: 20px; padding: 5px 15px; white-space: nowrap;" onclick="loadFilteredData()">
                %datafilter.btnFilterData%
            </button>
            <button class="btn btn-sm btn-success" style="border-radius: 20px; padding: 5px 15px; white-space: nowrap;" onclick="importSelectedToCRM()">
                %datafilter.btnExportData%
            </button>
            <div id="filterSearchBox" style="width: 280px;"></div>
            <button class="btn btn-outline-secondary btn-sm" style="border-radius: 50%; width: 34px; height: 34px; padding: 0; display: flex; align-items: center; justify-content: center;" onclick="try{ InstancefilterGridContainerPAD9FC60D93DA48DEBC7B0E6D0FF4C2F4.showColumnChooser(); }catch(e){ $(''#filterGridContainer'').dxDataGrid(''instance'').showColumnChooser(); }" title="%datafilter.BtnColumnChooser%">
                <i class="dx-icon dx-icon-column-chooser" style="font-size:16px;"></i>
            </button>
        </div>
    </div>
    <!-- Skeleton overlay đè lên grid, grid vẫn render bình thường phía sau -->
    <div id="filterGridWrapper">
        <div id="filterSkeletonOverlay">
            <div class="skeleton-table-header"></div>
            <div class="skeleton-table-row"></div>
            <div class="skeleton-table-row"></div>
            <div class="skeleton-table-row"></div>
            <div class="skeleton-table-row"></div>
            <div class="skeleton-table-row"></div>
            <div class="skeleton-table-row"></div>
            <div class="skeleton-table-row"></div>
            <div class="skeleton-table-row"></div>
            <div class="skeleton-table-row"></div>
            <div class="skeleton-table-row"></div>
        </div>
        <div id="filterGridContainer"></div>
    </div>
</div>

<div id="editPopupContainer"></div>
<div id="potentialBoxHolder" style="display:none;"><div id="PA0BAB6BAB1BA4CAB8B0DD40E698A92CA"></div></div>
<div id="pickerBoxHolder" style="display:none;"><div id="P6B4B866340AB45CF93E7401EB5ED52F9"></div></div>
<div id="infoBoxHolder" style="display:none;"><div id="PE9A4B07B784C4C3DBE659B6F5A63DE2C"></div></div>
';

    SET @html = @html + N'
<script>
(() => {
// Object.keys(window).forEach(function(k){ if(k.endsWith("DataSourceLoaded")) window[k] = false; });
window.currentRecordID_IDControl = 2
window["_isEdit_PotentialPA0BAB6BAB1BA4CAB8B0DD40E698A92CA"] = true;
window["_isDelete_PotentialPA0BAB6BAB1BA4CAB8B0DD40E698A92CA"] = true;
let api = true;
let DataSource = [];
let _pageCache = {};
let _currentKeyword = "";
let dataStore_filterGridContainer = null;
var obj = {};

'
+(SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'PAD9FC60D93DA48DEBC7B0E6D0FF4C2F4')
+(SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'PFD44AED7A8FE463BBF7B338FA58B198F')
+(SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'P051CC77BF33743BBB831F7E8FB3413F8')
+(SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'P25278BACA91B4C22A6809FAD6921714E')
+(SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'PA0BAB6BAB1BA4CAB8B0DD40E698A92CA')
+(SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'P6B4B866340AB45CF93E7401EB5ED52F9')
+(SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'PE9A4B07B784C4C3DBE659B6F5A63DE2C')
+(SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'PA1EE60BA94A54D0AA832172992702000')
+(SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'P24C13532C32A4CC38567F85B2E158858')
+(SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'PD0A9C34068F347948DAED96B0BE2907E')
+(SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'P15F2D12031DE49779B5A1A35EF9BC32F')
+(SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'P47CB40FDFB104FB5B7E311FE8DBFD664')
+(SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'PFD997832FB54422483A350D5A8CE2479')
+(SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'PC0F054E03857458598E20CF639F5BFEC')
+(SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'P29E8D8ADF2D2445A97B2F22A52790000')
+(SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'P4D64251B8BF04C42A70CD43133E4A44F')
+N'

// Hiện skeleton phủ lên grid (grid vẫn giữ kích thước — tránh virtual scroll loop)
function showGridSkeleton() {
    $("#filterSkeletonOverlay").show();
}

// Ẩn skeleton khi dữ liệu đã ready
function hideGridSkeleton() {
    $("#filterSkeletonOverlay").hide();
}

// Wrapper gọi SP qua AjaxHPAParadiseAsync — async/await, có kiểm tra !res khi API lỗi
async function callSP(spName, params, onSuccess, onError) {
    try {
        var res = await AjaxHPAParadiseAsync({ data: { name: spName, param: params } });
        if (!res) { if (typeof onError === "function") onError("No response"); return; }
        var json = typeof res === "string" ? JSON.parse(res) : res;
        if (typeof onSuccess === "function") onSuccess(json);
    } catch(err) {
        if (typeof onError === "function") onError(err);
    }
}

// Load data source có cache — tránh gọi API trùng lặp khi nhiều control cùng cần dữ liệu
function loadDataSourceCommon(columnName, dataSourceSP, onSuccessCallback) {
    if (!columnName || !dataSourceSP || dataSourceSP.trim() === "") return;
    var dataSourceKey = "DataSource_" + columnName;
    var loadedKey = columnName + "DataSourceLoaded";
    if (window[loadedKey] === true) { if (typeof onSuccessCallback === "function") onSuccessCallback(window[dataSourceKey] || []); return; }
    if (window[loadedKey] === "loading") { setTimeout(function() { loadDataSourceCommon(columnName, dataSourceSP, onSuccessCallback); }, 100); return; }
    window[loadedKey] = "loading";
    return new Promise(function(resolve, reject) {
        callSP(dataSourceSP, ["LoginID", LoginID, "LanguageID", LanguageID],
            function(json) {
                window[dataSourceKey] = (json.data && json.data[0]) || [];
                window[loadedKey] = true;
                if (typeof onSuccessCallback === "function") onSuccessCallback(window[dataSourceKey], json);
                resolve(window[dataSourceKey]);
            },
            function(err) { window[loadedKey] = false; reject(err); }
        );
    });
}

// Lấy instance DataGrid (ưu tiên biến global, fallback về jQuery)
function getGridInstance() {
    try { return InstancefilterGridContainerPAD9FC60D93DA48DEBC7B0E6D0FF4C2F4; } catch(e) {}
    try { return $("#filterGridContainer").dxDataGrid("instance"); } catch(e) {}
    return null;
}

// Khởi tạo CustomStore mới và bind vào grid để load dữ liệu từ server (hỗ trợ infinite scroll, filter, sort, search)
function ReloadData(pageNumber, pageSize, keyword) {

    var obj = {};
    _pageCache = {};

    var comboTagBox = null, provinceBox = null, districtBox = null;
    try { comboTagBox = $("#PFD44AED7A8FE463BBF7B338FA58B198F").dxSelectBox("instance"); } catch(e) {}
    try { provinceBox = $("#P051CC77BF33743BBB831F7E8FB3413F8").dxSelectBox("instance"); } catch(e) {}
    try { districtBox = $("#P25278BACA91B4C22A6809FAD6921714E").dxSelectBox("instance"); } catch(e) {}

    var cTag = comboTagBox ? (comboTagBox.option("value") || "") : "";
    var pCode = provinceBox ? (provinceBox.option("value") || "") : "";
    var dId = districtBox ? (districtBox.option("value") || "") : "";

    var gridForKeyword = getGridInstance();
    _currentKeyword = String(
        keyword != null
            ? keyword
            : (gridForKeyword ? gridForKeyword.option("searchPanel.text") || "" : "")
    ).trim();

    dataStore_filterGridContainer = new DevExpress.data.CustomStore({
        key: "ID",
        update: function(key, values) { return $.Deferred().resolve().promise(); },
        insert: function(values) { return $.Deferred().resolve().promise(); },
        remove: function(key) { return $.Deferred().resolve().promise(); },
        load: function(loadOptions) {
            var deferred = $.Deferred();

            if (!api) {
                var results = DataSource || [];
                var skip = loadOptions.skip || 0;
                var take = loadOptions.take || 50;
      var pageData = results.slice(skip, skip + take);
                deferred.resolve({
                    data: pageData,
                    totalCount: results.length
                });
                api = true;
                return deferred.promise();
            }

            var params = [];

            // SP nghiệp vụ
            params.push("@ProcName", "sp_DataFilter_Action");

            // Tham số của sp_DataFilter_Action
            var procParam = "@LoginID = " + (typeof UserID !== "undefined" ? UserID : 0)
                + ", @LanguageID = ''" + (typeof LanguageID !== "undefined" ? LanguageID : "VN") + "''"
                + ", @ComboTag = N''" + String(cTag).replace(/''/g, "''''") + "''"
                + ", @ProvinceCode = N''" + String(pCode).replace(/''/g, "''''") + "''"
                + ", @DistrictID = N''" + String(dId).replace(/''/g, "''''") + "''";

            params.push("@ProcParam", procParam);

            // Phân trang
            params.push("@Take", loadOptions.take || 50);
            params.push("@Skip", loadOptions.skip || 0);

            // TotalCount
            if (loadOptions.requireTotalCount) {
                params.push("@RequireTotalCount", 1);
            }

            // Sort
            var sort = loadOptions.sort
                ? loadOptions.sort.map(function(s) { return s.selector + (s.desc ? " DESC" : " ASC"); }).join(",")
                : "ID DESC";
            params.push("@Sort", "ORDER BY " + sort);

            // Search
            if (_currentKeyword) {
                params.push("@SearchValue", _currentKeyword);
                params.push("@ColumnSearch", "PlaceName,Address,PhoneNumber,Category,WebsiteName,DistrictName,ComboTag");
            }

            // Filter
            if (loadOptions.filter) {
                var hasFunction = JSON.stringify(loadOptions.filter, function(key, val) {
                    if (typeof val === "function") return "FUNCTION";
                    return val;
                }).includes("FUNCTION");

                if (!hasFunction) {
                    params.push("@Filters", createConditionQuery(loadOptions.filter));
                }
            }

            // Group
            if (loadOptions.group) {
                var selectGroup = "", groupBy = "GROUP BY ";
                loadOptions.group.forEach(function(item, index) {
                    if (selectGroup) selectGroup += ", ";
                    if (groupBy !== "GROUP BY ") groupBy += ", ";
                    if (item.groupInterval) {
                        selectGroup += item.groupInterval.toUpperCase() + "(" + item.selector + ") as col" + index;
                        groupBy += item.groupInterval.toUpperCase() + "(" + item.selector + ")";
                    } else {
                        selectGroup += item.selector + " as col" + index;
                        groupBy += item.selector;
                    }
                });
                selectGroup += ", Count(*) as totalCount";
                params.push("@SelectGroup", selectGroup);
                params.push("@GroupBy", groupBy);
            }

            // Summary
            if (loadOptions.totalSummary) {
                var summary = loadOptions.totalSummary.map(function(item) {
                    var type = item.summaryType === "custom"
                        ? "count(CASE WHEN [" + item.selector + "] = 1 THEN 1 END) as " + item.selector + "_COUNT"
                        : item.summaryType + "([" + item.selector + "]) as " + item.selector + "_" + item.summaryType.toUpperCase();
                    return type;
                });
                params.push("@TotalSummary", summary.join(", "));
            }

            callSP("sp_LoadGridUsingAPI", params,
                function(json) {
                    var results = (json && json.data && Array.isArray(json.data[0])) ? json.data[0] : [];

                    var result = { data: results };

                    if (loadOptions.requireTotalCount) {
                        result.totalCount = (json && json.data && json.data[1] && json.data[1][0]) ? json.data[1][0].TotalCount : 0;
                        if (loadOptions.totalSummary) {
                            result.summary = Object.values((json && json.data && json.data[2] && json.data[2][0]) ? json.data[2][0] : {});
                        }
                    } else {
                        if (loadOptions.totalSummary) {
                            result.summary = Object.values((json && json.data && json.data[1] && json.data[1][0]) ? json.data[1][0] : {});
                        }
                    }

                    DataSource = results;
                    deferred.resolve(result);
                },
                function(err) {
                    deferred.reject("Data Loading Error");
                }
            );

            return deferred.promise();
        }
    });

    var grid = getGridInstance();
    if (grid) {
        grid.beginUpdate();
        grid.option("remoteOperations", {
            paging: true,
            filtering: true,
            sorting: true,
            searching: true
        });
        grid.option("scrolling.mode", "infinite");
        grid.option("scrolling.rowRenderingMode", "virtual");
        grid.option("scrolling.preloadEnabled", false);
        grid.option("paging.enabled", true);
        grid.option("paging.pageSize", 50);
        grid.option("pager.visible", false);
        grid.option("pager.allowedPageSizes", [50]);
        grid.option("searchPanel.highlightSearchText", false);
        grid.option("dataSource", dataStore_filterGridContainer);
        grid.option("noDataText", "");
        grid.option("onContentReady", function() { hideGridSkeleton(); }); // Ẩn skeleton khi grid ready
        grid.option("onOptionChanged", function(e) {
            if (e.name === "searchPanel" && e.fullName === "searchPanel.text") {
                var raw = e.value || "";
                _currentKeyword = String(raw).trim();
                _pageCache = {};
            }
        });
        grid.endUpdate();
    }
}
'
+(SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'PAD9FC60D93DA48DEBC7B0E6D0FF4C2F4')
+(SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'PFD44AED7A8FE463BBF7B338FA58B198F')
+(SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'P051CC77BF33743BBB831F7E8FB3413F8')
+(SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'P25278BACA91B4C22A6809FAD6921714E')
+(SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'PA0BAB6BAB1BA4CAB8B0DD40E698A92CA')
+(SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'P6B4B866340AB45CF93E7401EB5ED52F9')
+(SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'PE9A4B07B784C4C3DBE659B6F5A63DE2C')
+(SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'PA1EE60BA94A54D0AA832172992702000')
+(SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'P24C13532C32A4CC38567F85B2E158858')
+(SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'PD0A9C34068F347948DAED96B0BE2907E')
+(SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'P15F2D12031DE49779B5A1A35EF9BC32F')
+(SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'P47CB40FDFB104FB5B7E311FE8DBFD664')
+(SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'PFD997832FB54422483A350D5A8CE2479')
+(SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'PC0F054E03857458598E20CF639F5BFEC')
+(SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'P29E8D8ADF2D2445A97B2F22A52790000')
+(SELECT loadData FROM tblCommonControlType_Signed WHERE UID = 'P4D64251B8BF04C42A70CD43133E4A44F')
+N'
// Áp dụng infinite scroll ngay khi grid init + tắt search/column chooser mặc định DevExpress
(function initGridScroll() {
    var grid = getGridInstance();
    if (!grid) return;
    grid.beginUpdate();
    grid.option("stateStoring", { enabled: false });
    grid.option("scrolling.mode", "infinite");
    grid.option("scrolling.rowRenderingMode", "virtual");
    grid.option("scrolling.preloadEnabled", true);
    grid.option("paging.enabled", true);
    grid.option("paging.pageSize", 50);
    grid.option("pager.visible", false);
    grid.option("pager.allowedPageSizes", [50]);
    // Tắt thanh search mặc định của DevExpress (dùng #filterSearchBox custom thay thế)
    grid.option("searchPanel.visible", false);
    // enabled nhưng ẩn nút mặc định, dùng nút custom thay thế
    grid.option("columnChooser", { enabled: true, mode: "select", title: "%datafilter.BtnColumnChooser%", height: 420, width: 300, search: { enabled: true }, selection: { recursive: true, selectByClick: true } });
    grid.option("toolbar", { items: [{ name: "columnChooserButton", location: "after" }] });
    grid.option("height", function() {
        var el = document.getElementById("filterGridContainer");
        if (!el) return "calc(100vh - 120px)";
        var top = el.getBoundingClientRect().top;
        return window.innerHeight - top - 20;
    });
    // Cột Potential: hiển thị badge Bootstrap (không hardcode màu)
    grid.columnOption("Potential", "cellTemplate", function(container, options) {
        var raw = options.value || "";
        if (!raw.trim()) return;
        var tags = raw.split(",").map(function(s) { return s.trim(); }).filter(Boolean);
        tags.forEach(function(tag) {
            $("<span>").text(tag)
                .addClass("badge bg-success")
                .css({ borderRadius: "12px", marginRight: "4px", marginBottom: "2px", fontSize: "12px", whiteSpace: "nowrap" })
                .appendTo(container);
        });
    });
    // Cột Website/Map: nút Bootstrap btn-success, không hardcode màu
    grid.columnOption("WebsiteName", "cellTemplate", function(container, options) {
        if (options.value && String(options.value).trim() !== "") {
            $("<a>").attr({ href: options.value, target: "_blank" })
                .addClass("btn btn-sm btn-success")
                .css({ borderRadius: "20px" })
                .text("Web")
                .appendTo(container);
        }
    });
    grid.columnOption("GoogleMapUrl", "cellTemplate", function(container, options) {
        if (options.value && String(options.value).trim() !== "") {
            $("<a>").attr({ href: options.value, target: "_blank" })
                .addClass("btn btn-sm btn-success")
                .css({ borderRadius: "20px" })
                .text("Map")
                .appendTo(container);
        }
    });
    grid.endUpdate();

    // Reset state cũ từ localStorage (stateStoring restore chạy async → cần setTimeout)
    setTimeout(function() {
        var g = getGridInstance();
        if (!g) return;
        g.state(null);
        try { var key = g.option("stateStoring.storageKey"); if (key) localStorage.removeItem(key); } catch(e) {}
    }, 100);
})();

// (Đã xoá _fixStickyBg vì dùng CSS .dx-col-fixed tĩnh ổn định hơn)

// Hook icon con mắt: khi currentRecordID_ID thay đổi → tìm rowData → mở popup sửa
(function hookEyeIcon() {
    var _recordID = null;
    Object.defineProperty(window, "currentRecordID_ID", {
        get: function() { return _recordID; },
        set: function(val) {
            _recordID = val;
            if (val == null) return;
            var grid = getGridInstance();
            if (!grid) return;
            var ds = grid.getDataSource();
            if (!ds) return;
            var items = ds.items() || [];
            var rowData = null;
            for (var i = 0; i < items.length; i++) {
                if (items[i].ID == val) { rowData = items[i]; break; }
            }
            if (rowData) {
                openEditPopup([rowData]);
            }
        },
        configurable: true
    });
})();

// Control grid gọi hàm này khi click icon con mắt (truyền toàn bộ rowData)
window.openDetailID = function(rowData) {
    if (rowData) {
        openEditPopup([rowData]);
    }
};

// Không tự động load data khi mở trang - chờ user chọn filter rồi bấm "Lọc dữ liệu"
// ReloadData();
setTimeout(applyDynamicProvinceDistrictDataSources, 450);
setTimeout(applyDynamicProvinceDistrictDataSources, 1600);

// Đồng bộ dark/light theme giữa hệ thống và DevExpress (theo class ''dark-mode'' trên body)
function applyTheme(){
    var dark = document.body.classList.contains(''dark-mode'');
    var root = document.getElementById(''dataFilterRoot'');
    if(!root) return;
    root.setAttribute(''data-bs-theme'', dark ? ''dark'' : ''light'');
    if(typeof DevExpress !== ''undefined'' && DevExpress.ui && DevExpress.ui.themes){
        try { DevExpress.ui.themes.current(dark ? ''generic.dark'' : ''generic.light''); } catch(e){}
    }
}
applyTheme();
var obs = new MutationObserver(function(m){ m.forEach(function(r){ if(r.attributeName===''class'') applyTheme(); }); });
obs.observe(document.body, { attributes: true });

var editPopupInstance;
window.currentEditingRows = [];
window._editDataMap = {};
window._editCurrentIdx = 0;

// Convert giá trị TagBox (mảng ID) → chuỗi tên để lưu lên server
function _getTagBoxNames(tagBox) {
    if (!tagBox) return "";
    var ids = tagBox.option("value") || [];
    var ds = window.DataSource_Potential || [];
    var nameField = window["DataSourceNameField_Potential"] || "Name";
    var idField = window["DataSourceIDField_Potential"] || "ID";
    return ids.map(function(id) {
        var item = ds.filter(function(d) { return d[idField] == id; })[0];
        return item ? item[nameField] : "";
    }).filter(Boolean).join(", ");
}

// Convert chuỗi tên "Tag1, Tag2" → mảng ID để bind vào TagBox
function _namesToIds(raw) {
    if (!raw) return [];
    var ds = window.DataSource_Potential || [];
    var nameField = window["DataSourceNameField_Potential"] || "Name";
    var idField = window["DataSourceIDField_Potential"] || "ID";
    var names = raw.split(",").map(function(s) { return s.trim(); }).filter(Boolean);
    return names.map(function(n) {
        var item = ds.filter(function(d) { return d[nameField] === n; })[0];
        return item ? item[idField] : null;
    }).filter(function(v) { return v !== null; });
}

// Snapshot dữ liệu form + TagBox hiện tại vào _editDataMap (giữ lại khi chuyển dòng trong popup)
function _saveCurrentToMap() {
    var form = $("#editForm").dxForm("instance");
    if (!form) return;
    var fd = form.option("formData");
    var tagBox = $("#PA0BAB6BAB1BA4CAB8B0DD40E698A92CA").dxTagBox("instance");
    var potentialVal = _getTagBoxNames(tagBox);
    window._editDataMap[window._editCurrentIdx] = { Potential: potentialVal, Note: fd.Note || "" };
}

// Load dòng thứ [idx] vào form/TagBox (ưu tiên dữ liệu đã sửa trong _editDataMap)
function _loadItemToForm(idx) {
    window._editCurrentIdx = idx;
    var row = window.currentEditingRows[idx];
    var saved = window._editDataMap[idx] || {};
    var form = $("#editForm").dxForm("instance");
    if (form) {
        form.option("formData", {
            Note: saved.Note !== undefined ? saved.Note : (row.Note || "")
        });
    }
    var tagBox = $("#PA0BAB6BAB1BA4CAB8B0DD40E698A92CA").dxTagBox("instance");
    if (tagBox) {
        var raw = saved.Potential !== undefined ? saved.Potential : (row.Potential || "");
        tagBox.option("value", _namesToIds(raw));
    }
    // Update PlaceName textbox
    var pickerInst = null;
    try { pickerInst = $("#P6B4B866340AB45CF93E7401EB5ED52F9").dxTextBox("instance"); } catch(e) {}
    if (pickerInst) { pickerInst.option("value", row.PlaceName || ""); }
    // Update Address textbox
    var infoInst = null;
    try { infoInst = $("#PE9A4B07B784C4C3DBE659B6F5A63DE2C").dxTextBox("instance"); } catch(e) {}
    if (infoInst) { infoInst.option("value", row.Address || ""); }
}

// Mở popup sửa cho các dòng đang chọn trong grid
function editSelectedRows() {
    var grid = getGridInstance();
    var selected = grid.getSelectedRowsData();
    if (!selected || selected.length === 0) {
        if(typeof uiManager !== "undefined") uiManager.showAlert({ type: "warning", message: "%datafilter.msgRequireSelectEdit%" });
        return;
    }
    openEditPopup(selected);
}

// Mở popup sửa dòng (tái dùng instance nếu đã tạo): PlaceName, Address (readonly), Tag, Note
function openEditPopup(rows) {
    window.currentEditingRows = rows;
    window._editDataMap = {};
    window._editCurrentIdx = 0;

    if (!editPopupInstance) {
        editPopupInstance = $("#editPopupContainer").dxPopup({
            title: "%datafilter.titleUpdateSelected%",
            width: 750,
            height: "auto",
            maxHeight: "95vh",
            showCloseButton: true,
            dragEnabled: true,
            contentTemplate: function(contentElement) {
                var $wrapper = $("<div>").addClass("edit-popup-wrapper");
                var lblStyle = { fontWeight: 600, marginBottom: "0", fontSize: "13px", lineHeight: "1.3" };
                var $pickerLabel = $("<div>").css(lblStyle).text("%datafilter.lblPlaceName%");
                var $pickerSlot = $("<div>").attr("id", "pickerSlot");
                var $infoLabel = $("<div>").css(lblStyle).text("%datafilter.lblAddress%");
                var $infoSlot = $("<div>").attr("id", "infoSlot");
                var $potentialLabel = $("<div>").css(lblStyle).text("%datafilter.lblTag%");
                var $potentialSlot = $("<div>").attr("id", "potentialSlot");
                var $formContainer = $("<div>").attr("id", "editForm");
                var $btnContainer = $("<div>").addClass("edit-popup-buttons d-flex justify-content-end gap-2");
                $btnContainer.append(
                    $("<button>").addClass("btn btn-secondary").css({ borderRadius: "20px", padding: "6px 20px" }).text("%datafilter.btnClose%").on("click", function(){ _saveCurrentToMap(); editPopupInstance.hide(); }),
                    $("<button>").attr("id","btnSaveEdit").addClass("btn btn-success").css({ borderRadius: "20px", padding: "6px 20px" }).text("%datafilter.btnSaveAll%").on("click", function(){ saveEditForm(); })
                );
                $wrapper.append($pickerLabel).append($pickerSlot).append($infoLabel).append($infoSlot).append($potentialLabel).append($potentialSlot).append($formContainer).append($btnContainer);
                contentElement.append($wrapper);
            }
        }).dxPopup("instance");
    }

    editPopupInstance.option("title", "%datafilter.titleUpdateSelected%");
    editPopupInstance.option("onHidden", function() {
        $("#PA0BAB6BAB1BA4CAB8B0DD40E698A92CA").appendTo("#potentialBoxHolder");
        $("#P6B4B866340AB45CF93E7401EB5ED52F9").appendTo("#pickerBoxHolder");
        $("#PE9A4B07B784C4C3DBE659B6F5A63DE2C").appendTo("#infoBoxHolder");
    });
    editPopupInstance.show().done(function() {
        $("#P6B4B866340AB45CF93E7401EB5ED52F9").appendTo("#pickerSlot").show();
        $("#PE9A4B07B784C4C3DBE659B6F5A63DE2C").appendTo("#infoSlot").show();
        $("#PA0BAB6BAB1BA4CAB8B0DD40E698A92CA").appendTo("#potentialSlot").show();

        // Set PlaceName textbox
        var pickerInst = null;
        try { pickerInst = $("#P6B4B866340AB45CF93E7401EB5ED52F9").dxTextBox("instance"); } catch(e) {}
        if (pickerInst) {
            pickerInst.option("value", rows[0].PlaceName || "");
            pickerInst.option("readOnly", true);
        }

        // Set Address textbox
        var infoInstance = null;
        try { infoInstance = $("#PE9A4B07B784C4C3DBE659B6F5A63DE2C").dxTextBox("instance"); } catch(e) {}
        if (infoInstance) {
            infoInstance.option("value", rows[0].Address || "");
            infoInstance.option("readOnly", true);
        }

        var tagBox = $("#PA0BAB6BAB1BA4CAB8B0DD40E698A92CA").dxTagBox("instance");
        if(tagBox) {
            tagBox.option({
                value: _namesToIds(rows[0].Potential || ""),
                multiline: true,
                maxDisplayedTags: 50,
                showMultiTagOnly: false,
                placeholder: "%datafilter.placeholderSearchOrSelectMulti%"
            });
        }

        $("#editForm").dxForm({
            formData: { Note: rows[0].Note || "" },
            labelLocation: "top",
            showColonAfterLabel: false,
            colCount: 1,
            items: [
                {
                    dataField: "Note",
                    label: { text: "%datafilter.lblNote%" },
                    editorType: "dxTextArea",
                    editorOptions: {
                        height: 90,
                        placeholder: "%datafilter.placeholderNote%"
                    }
                }
            ]
        });
    });
}

// Gửi dữ liệu tất cả dòng trong popup lên SP sp_DataFilter_Save, reload grid sau khi thành công
function saveEditForm() {
    _saveCurrentToMap();
    var rows = window.currentEditingRows;

    var listToSave = rows.map(function(r, i) {
        var edited = window._editDataMap[i] || {};
        return {
            ID: r.ID,
            Potential: edited.Potential !== undefined ? edited.Potential : (r.Potential || ""),
            Note: edited.Note !== undefined ? edited.Note : (r.Note || ""),
            PlaceName: r.PlaceName || "", Address: r.Address || "",
            PhoneNumber: r.PhoneNumber || "", Category: r.Category || "",
            Rating: r.Rating || "", Status: r.Status || "",
            WebsiteName: r.WebsiteName || "", GoogleMapUrl: r.GoogleMapUrl || "",
            ImageUrl: r.ImageUrl || "", ProvinceCode: r.ProvinceCode || "",
            DistrictName: r.DistrictName || "", ComboTag: r.ComboTag || ""
        };
    });

    var $btn = $("#btnSaveEdit");
    var oldText = $btn.text();
    $btn.html("<span class=''spinner-border spinner-border-sm me-1'' role=''status'' aria-hidden=''true''></span> Đang lưu...").prop("disabled", true);

    callSP("sp_DataFilter_Save",
        ["LoginID", LoginID, "Data", JSON.stringify(listToSave)],
        function() {
            $btn.text(oldText).prop("disabled", false);

            // Cập nhật local DataSource để grid hiện ngay không cần reload
            listToSave.forEach(function(item) {
                for (var j = 0; j < DataSource.length; j++) {
                    if (DataSource[j].ID == item.ID) {
                        DataSource[j].Potential = item.Potential;
                        DataSource[j].Note = item.Note;
                        break;
                    }
                }
            });

            api = false;
            var grid = getGridInstance();
            if (grid) {
                grid.endCustomLoading();
                grid.clearSelection();
                if(typeof uiManager !== "undefined") uiManager.showAlert({ type: "success", message: "%datafilter.msgUpdateSuccessPrefix%" + rows.length + "%datafilter.msgUpdateSuccessSuffix%" });
                editPopupInstance.hide();
                grid.getDataSource().reload();
            }
        },
        function() {
            $btn.text(oldText).prop("disabled", false);
            if(typeof uiManager !== "undefined") uiManager.showAlert({ type: "error", message: "%datafilter.msgUpdateError%" });
        }
    );
}

// Load danh sách Tỉnh theo ComboTag, tự reset Quận về trống
function loadFilterProvincesForDataFilter(cTag, provinceBox, districtBox) {
    if (!provinceBox) return;
    var uid = typeof UserID !== "undefined" ? UserID : 0;
    var lid = typeof LanguageID !== "undefined" ? LanguageID : "VN";
    callSP("sp_DataFilter_Action",
        ["Action", "GET_FILTER_PROVINCES", "LoginID", uid, "LanguageID", lid, "ComboTag", cTag || "", "ProvinceCode", "", "DistrictID", ""],
        function(json) {
            var data = (json.data && json.data[0]) ? json.data[0] : [];
            provinceBox.option({ dataSource: data, valueExpr: "ID", displayExpr: "Name", value: null });
            if (districtBox) districtBox.option({ dataSource: [], value: null });
        },
        function() {
            provinceBox.option({ dataSource: [], value: null });
            if (districtBox) districtBox.option({ dataSource: [], value: null });
        }
    );
}

// Load Quận/Huyện theo Tỉnh đã chọn (cascade); nếu chưa chọn tỉnh thì xóa trắng
function loadFilterDistrictsForDataFilter(cTag, provCode, districtBox) {
    if (!districtBox) return;
    if (!provCode) { districtBox.option({ dataSource: [], value: null }); return; }
    var uid = typeof UserID !== "undefined" ? UserID : 0;
    var lid = typeof LanguageID !== "undefined" ? LanguageID : "VN";
    callSP("sp_DataFilter_Action",
        ["Action", "GET_FILTER_DISTRICTS", "LoginID", uid, "LanguageID", lid, "ComboTag", cTag || "", "ProvinceCode", String(provCode), "DistrictID", ""],
        function(json) {
            var data = (json.data && json.data[0]) ? json.data[0] : [];
            districtBox.option({ dataSource: data, valueExpr: "ID", displayExpr: "Name", value: null });
        },
        function() { districtBox.option({ dataSource: [], value: null }); }
    );
}

// Khởi động cascade Tỉnh→Quận dựa trên ComboTag hiện tại (gọi nhiều lần để chắc control đã init)
function applyDynamicProvinceDistrictDataSources() {
    if (typeof loadFilterProvincesForDataFilter !== "function") return;
    var provinceBox = $("#P051CC77BF33743BBB831F7E8FB3413F8").dxSelectBox("instance");
    var districtBox = $("#P25278BACA91B4C22A6809FAD6921714E").dxSelectBox("instance");
    var comboTagBox = $("#PFD44AED7A8FE463BBF7B338FA58B198F").dxSelectBox("instance");
    if (!provinceBox || !districtBox || !comboTagBox) return;
    var cTag = comboTagBox.option("value");
    cTag = (cTag !== undefined && cTag !== null) ? String(cTag) : "";
    loadFilterProvincesForDataFilter(cTag, provinceBox, districtBox);
}

$(function(){
    loadDataSourceCommon("Potential", "sp_GoogleMap_LoadPotential", function(data) {
        window.DataSource_Potential = data;
        var tagBox = $("#PA0BAB6BAB1BA4CAB8B0DD40E698A92CA").dxTagBox("instance");
        if(tagBox) {
            tagBox.option({
                dataSource: data,
                multiline: true,
                maxDisplayedTags: 50,
                showMultiTagOnly: false
            });
        }
    });

    setTimeout(function(){
        var provinceBox = $("#P051CC77BF33743BBB831F7E8FB3413F8").dxSelectBox("instance");
        var districtBox = $("#P25278BACA91B4C22A6809FAD6921714E").dxSelectBox("instance");
        var comboTagBox = $("#PFD44AED7A8FE463BBF7B338FA58B198F").dxSelectBox("instance");

        if(comboTagBox) comboTagBox.option({
            displayExpr: "Name", itemTemplate: function(data) { return data.Name; }, searchExpr: "Name", placeholder: "%datafilter.placeholderSearchOrSelect%", showClearButton: true,
            onValueChanged: function(e) {
                var c = (e.value !== undefined && e.value !== null) ? String(e.value) : "";
                loadFilterProvincesForDataFilter(c, provinceBox, districtBox);
            }
        });
        if(provinceBox) provinceBox.option({ placeholder: "%datafilter.placeholderSelectProvince%", showClearButton: true, valueExpr: "ID", displayExpr: "Name", dataSource: [] });
        if(districtBox) districtBox.option({ placeholder: "%datafilter.placeholderSelectDistrict%", showClearButton: true, dataSource: [] });

        var potTag = $("#PA0BAB6BAB1BA4CAB8B0DD40E698A92CA").dxTagBox("instance");
        if(potTag) {
            potTag.option({ multiline: true, maxDisplayedTags: 50, showMultiTagOnly: false, placeholder: "%datafilter.placeholderSearchOrSelectMulti%" });
        }

        if(provinceBox && districtBox && comboTagBox) {
            provinceBox.on("valueChanged", function(e) {
                var provCode = e.value || "";
                var cTag = comboTagBox.option("value");
                cTag = (cTag !== undefined && cTag !== null) ? String(cTag) : "";
                if(provCode) loadFilterDistrictsForDataFilter(cTag, provCode, districtBox);
                else districtBox.option({ dataSource: [], value: null });
            });
            loadFilterProvincesForDataFilter("", provinceBox, districtBox);
            setTimeout(applyDynamicProvinceDistrictDataSources, 700);
            setTimeout(applyDynamicProvinceDistrictDataSources, 2000);
        }
    }, 500);

    $("#filterSearchBox").dxTextBox({
        placeholder: "%ApplicationOption.lblFind%", mode: "search", showClearButton: true, valueChangeEvent: "keyup",
        onValueChanged: function(e) {
            _currentKeyword = String(e.value || "").trim();
            _pageCache = {};
            var grid = getGridInstance();
            if (grid) { grid.getDataSource().reload(); }
        }
    });
});

// Nút Lọc: kiểm tra ít nhất 1 điều kiện, hiện skeleton rồi gọi ReloadData
function loadFilteredData() {
    var comboTagBox = $("#PFD44AED7A8FE463BBF7B338FA58B198F").dxSelectBox("instance");
    var provinceBox = $("#P051CC77BF33743BBB831F7E8FB3413F8").dxSelectBox("instance");
    var districtBox = $("#P25278BACA91B4C22A6809FAD6921714E").dxSelectBox("instance");

    if(!comboTagBox || !provinceBox || !districtBox) return;

    var cTag = comboTagBox.option("value") || ""; var pCode = provinceBox.option("value") || ""; var dId = districtBox.option("value") || "";

    if (!cTag && !pCode && !dId) {
        if(typeof uiManager !== "undefined") uiManager.showAlert({ type: "warning", message: "%datafilter.msgRequireFilterCondition%" }); return;
    }

    showGridSkeleton(); // Ẩn tự động trong onContentReady
    ReloadData();
}

// Xoá các dòng đã chọn (confirm trước) — gọi SP Action=''DELETE''
function deleteSelectedData() {
    var grid = getGridInstance();
    if (!grid) return;
    var selectedRows = grid.getSelectedRowsData();

    if (!selectedRows || selectedRows.length === 0) {
        if(typeof uiManager !== "undefined") uiManager.showAlert({ type: "warning", message: "%datafilter.msgRequireSelectDelete%" });
        return;
    }

    showConfirmPopup({
        title: "%datafilter.titleConfirmDelete%",
        message: "%datafilter.msgConfirmDeletePrefix%" + selectedRows.length + "%datafilter.msgConfirmDeleteSuffix%",
        onYes: function() {
            var ids = selectedRows.map(function(r) { return r.ID; }).filter(function(id) { return id != null; });
            if (ids.length === 0) return;

            grid.beginCustomLoading("%datafilter.msgDeletingData%");

            callSP("sp_DataFilter_Action",
                ["LoginID", LoginID, "Action", "DELETE", "IDs", ids.join(",")],
                function() {
                    grid.endCustomLoading();
                    grid.clearSelection();
                    grid.refresh();
                    if(typeof uiManager !== "undefined") uiManager.showAlert({ type: "success", message: "%datafilter.msgDeleteSuccessPrefix%" + ids.length + "%datafilter.msgDeleteSuccessSuffix%" });
                },
                function(err) {
                    grid.endCustomLoading();
                    if(typeof uiManager !== "undefined") uiManager.showAlert({ type: "error", message: "%datafilter.msgDeleteError%" });
                }
            );
        }
    });
}

// Xuất dòng đã chọn sang CRM (không tra MST — chuyển thẳng)
function importSelectedToCRM() {
    var grid = getGridInstance();
    if (!grid) return;
    var selectedRows = grid.getSelectedRowsData();

    if (!selectedRows || selectedRows.length === 0) {
        if(typeof uiManager !== "undefined") uiManager.showAlert({ type: "warning", message: "%datafilter.msgRequireSelectCRM%" });
        return;
    }

    showConfirmPopup({
        title: "%datafilter.titleConfirmExport%",
        message: "%datafilter.msgConfirmExportPrefix%" + selectedRows.length + "%datafilter.msgConfirmExportSuffix%",
        onYes: function() {
            var ids = selectedRows.map(function(r) { return r.ID; }).filter(function(id) { return id != null; });
            if (ids.length === 0) return;

            // Skeleton loading
            grid.beginCustomLoading("%datafilter.msgExporting%");

            callSP("sp_DataFilter_Action",
                ["LoginID", LoginID, "Action", "IMPORT_TO_CRM", "IDs", ids.join(",")],
                function(json) {
                    grid.endCustomLoading();
                    var logs = (json && json.data && Array.isArray(json.data[0])) ? json.data[0] : [];
                    var created = logs.filter(function(r){ return r.ResultStatus === "CREATED"; }).length;
                    var existed = logs.filter(function(r){ return r.ResultStatus === "EXISTED"; }).length;

                    grid.clearSelection();
                    grid.refresh();
                    if(typeof uiManager !== "undefined") uiManager.showAlert({
                        type: "success",
                        message: "%datafilter.msgImportDonePrefix%" + created + "%datafilter.msgImportDoneCreated%" + existed + "%datafilter.msgImportDoneExisted%"
                    });
                },
                function() {
                    grid.endCustomLoading();
                    if(typeof uiManager !== "undefined") uiManager.showAlert({ type: "error", message: "%datafilter.msgImportError%" });
                }
            );
        }
    });
}

window.editSelectedRows = editSelectedRows;
window.deleteSelectedData = deleteSelectedData;
window.loadFilteredData = loadFilteredData;
window.importSelectedToCRM = importSelectedToCRM;
})();
</script>';
--EXEC sptblCommonControlType_Signed_DUC 'sp_DataFilter_html'
--EXEC sp_GenerateHTMLScript_new 'sp_DataFilter_html'
    SELECT @html AS html;
END
