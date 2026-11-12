/*==================================================================================================
  PARADISE HRM - BẢN VÁ SỬA LỖI GIAO DIỆN: SCREENSHOT 6 (MenuID: MnuKPI449 / MnuCRM001)
  MÀN HÌNH: DANH SÁCH CÔNG TY CRM (Trang chủ CRM -> Thiết lập -> Danh sách công ty CRM)
  
  HIỆN TRẠNG LỖI TRÊN SCREENSHOT 6:
    1. Các cột "TÊN CÔNG TY" và "ĐỊA CHỈ" bị co ngắn cụt ngủn (~150px), chữ bị cắt dấu ba chấm (...).
    2. Khoảng trống đen khổng lồ thừa thãi xuất hiện giữa cột "MÃ SỐ THUẾ" và cột "KÍCH HOẠT".
    3. Cột "KÍCH HOẠT" bị dạt sang tận mép phải xa xôi của màn hình, thiếu căn giữa cân đối.
    4. Ký tự typo thừa chữ "s" tại dòng kết thúc script (})();s) tiềm ẩn nguy cơ lỗi runtime JS.

  GIẢI PHÁP KIẾN TRÚC HOÀN THIỆN:
    1. Tự động dãn linh hoạt (Flex Auto-fill) tràn viền 100% cho 2 cột văn bản dài:
       - Cột "Company": Xóa bỏ width & maxWidth, gán minWidth = 280px để chiếm trọn không gian trống.
       - Cột "Address": Xóa bỏ width & maxWidth, gán minWidth = 320px để chiếm trọn không gian trống.
    2. Định kích thước cố định vừa vặn, chuẩn thẩm mỹ cho 2 cột ngắn:
       - Cột "TaxCode": width = 160px, minWidth = 130px, căn trái.
       - Cột "IsActive": width = 110px, minWidth = 90px, header căn trái, checkbox căn giữa.
    3. Bổ sung thuộc tính title tooltip trên từng ô: Người dùng rê chuột vào là đọc được toàn bộ Tên công ty / Địa chỉ.
    4. Bật chế độ cho phép người dùng tự kéo dãn cột (allowColumnResizing: true, columnResizingMode: "widget").
    5. Dọn sạch ký tự typo thừa "s" ở cuối script (đóng })(); chuẩn xác).
    6. Chuẩn hóa Stored Procedure điều phối sp_CRM_CompanyList và quy trình biên dịch tự động qua sp_GenerateHTMLScript_new.
==================================================================================================*/

USE [Vietinsoft_ForTest_Tai2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 1: CẬP NHẬT GIAO DIỆN SP_CRM_COMPANYLIST_HTML (HTML / CSS RESPONSIVE / JS DEVIEXTREME)
--------------------------------------------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE [dbo].[sp_CRM_CompanyList_html]
    @LoginID INT = 3,
    @LanguageID NVARCHAR(10) = N'VN',
    @isWeb INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @html NVARCHAR(MAX) = N'';

    SET @html = N'
    <div id="sp_CRM_CompanyList_html">
        <div id="GridCompanyList" style="height: 100%;"></div>
    </div>
    <script>
        (() => {
            let api = true;
            let DataSource = [];
            let _pageCache = {};
            let _currentKeyword = "";
            let _searchTimer = null;
            let dataStore_GridCompanyList = null;
            let _showtoolbarGrid_P3A154CE250774CED990853E06804BF8B = true;
            let _showtoolbarAdd_P3A154CE250774CED990853E06804BF8B = true;

            // ============================================================
            // 0. KHAI BÁO CÁC HÀM SỰ KIỆN MẶC ĐỊNH CHO GRID
            // ============================================================
            function addCompany_ID() {
                console.log("Ham addCompany_ID chua duoc dinh nghia.");
            };
            function openDetailCompany_ID(rowData) {
                console.log("Ham openDetailCompany_ID chua duoc dinh nghia. Data:", rowData);
            };

            // ============================================================
            // 1. KHỞI TẠO DATASTORE DUY NHẤT MỘT LẦN
            // ============================================================
            dataStore_GridCompanyList = new DevExpress.data.CustomStore({
                key: "Company_ID",
                load: function(loadOptions) {
                    const deferred = $.Deferred();

                    if (!api) {
                        const results = DataSource || [];
                        const skip = loadOptions.skip || 0;
                        const take = loadOptions.take || 50;
                        const pageData = results.slice(skip, skip + take);
                        deferred.resolve({
                            data: pageData,
                            totalCount: results.length
                        });
                        api = true;
                        return deferred.promise();
                    }

                    let params = [];
                    // SP nghiệp vụ
                    params.push("@ProcName", "sp_CRM_LoadCompanyList");

                    // Tham số của tên thủ tục load Data
                    let procParam = "@LoginID = " + (window.UserID || window.LoginID) + ", @LanguageID = " + window.LanguageID;

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
                        ? loadOptions.sort.map(s => s.selector + (s.desc ? " DESC" : " ASC")).join(",")
                        : "";

                    params.push("@Sort", sort != "" ? "ORDER BY " + sort : "");

                    // Search
                    if (_currentKeyword) {
                        params.push("@SearchValue", _currentKeyword);
                        params.push(
                            "@ColumnSearch",
                            "Company,TaxCode,Address,Source"
                        );
                    }

                    // Filter
                    if (loadOptions.filter) {
                        const hasFunction = JSON.stringify(loadOptions.filter, (key, val) => {
                            if (typeof val === "function") return "FUNCTION";
                            return val;
                        }).includes("FUNCTION");

                        if (!hasFunction) {
                            params.push("@Filters", createConditionQuery(loadOptions.filter));
                        }
                    }

                    // Summary
                    if (loadOptions.totalSummary) {
                        const summary = loadOptions.totalSummary.map(item => {
                            const type = item.summaryType === "custom"
                                ? `count(CASE WHEN [${item.selector}] = 1 THEN 1 END) as ${item.selector}_COUNT`
                                : `${item.summaryType}([${item.selector}]) as ${item.selector}_${item.summaryType.toUpperCase()}`;
                            return type;
                        });
                        params.push("@TotalSummary", summary.join(", "));
                    }

                    AjaxHPAParadise({
                        data: {
                            name: "sp_LoadGridUsingAPI",
                            param: params
                        },
                        success: function (res) {
                            const json = typeof res === "string" ? JSON.parse(res) : res;
                            let dataIndex = 0;
                            if (json?.data?.[0]?.length > 0 && typeof json.data[0][0].Column1 !== "undefined" && json.data.length > 1) {
                                dataIndex = 1;
                            }
                            const results = Array.isArray(json?.data?.[dataIndex]) ? json.data[dataIndex] : [];
                            let result = { data: results };

                            if (loadOptions.requireTotalCount) {
                                result.totalCount = json?.data?.[dataIndex + 1]?.[0]?.TotalCount ?? 0;
                                if (loadOptions.totalSummary) {
                                    result.summary = Object.values(json?.data?.[dataIndex + 2]?.[0] ?? {});
                                }
                            } else {
                                if (loadOptions.totalSummary) {
                                    result.summary = Object.values(json?.data?.[dataIndex + 1]?.[0] ?? {});
                                }
                            }

                            DataSource = results;
                            window.syncSharedGridData("GridCompanyList");
                            deferred.resolve(result);
                        },
                        error: function (err) {
                            deferred.reject("Data Loading Error");
                        }
                    });

                    return deferred.promise();
                }
            });

            '
    +(select loadUI from tblCommonControlType_Signed where UID = 'P3A154CE250774CED990853E06804BF8B') +N'
            
            window.currentRecordID_Company_ID = null;

            function clearPageCache() {
                _pageCache = {};
            }

            function getGridHeight() {
                const gridEl = InstanceGridCompanyListP3A154CE250774CED990853E06804BF8B.element();
                const domElement = gridEl.jquery ? gridEl[0] : gridEl;
                const top = domElement.getBoundingClientRect().top;
                return window.innerHeight - top - 20;
            }

            // ============================================================
            // 2. KHỞI TẠO GRID LAYOUT & TỐI ƯU HÓA RESPONSIVE CHO CÁC CỘT
            // ============================================================
            const gridInstance = InstanceGridCompanyListP3A154CE250774CED990853E06804BF8B;

            // Thứ tự hiển thị cột chuẩn nghiệp vụ:
            // Tên công ty -> Địa chỉ -> Mã số thuế -> Kích hoạt.
            // ============================================================
            // [BẢN VÁ SCREENSHOT 6]: Cấu hình Responsive thông minh cho các cột
            // - Bỏ gán cứng width: 150 & maxWidth: 400 gây cắt cụt văn bản và hở khoảng trống lớn
            // - Cột Tên công ty & Địa chỉ tự động dãn linh hoạt (Flex Auto-fill) chiếm trọn màn hình
            // - Cột Mã số thuế (160px) và Kích hoạt (110px) cố định gọn gàng
            // - Thêm tooltip title cho Tên công ty & Địa chỉ khi hover chuột
            // - Kích hoạt allowColumnResizing & columnResizingMode: "widget"
            // ============================================================
            function applyCompanyColumnOrder() {
                const desiredOrder = [
                    "Company",
                    "Address",
                    "TaxCode",
                    "IsActive"
                ];
                const currentColumns = gridInstance.option("columns") || [];
                const orderedColumns = [];

                desiredOrder.forEach(function (dataField) {
                    const column = currentColumns.find(function (item) {
                        return item && item.dataField === dataField;
                    });
                    if (column) {
                        // Tối ưu hóa cấu hình responsive cho từng cột
                        if (dataField === "Company") {
                            delete column.width;
                            delete column.maxWidth;
                            column.minWidth = 280;
                            const origCell = column.cellTemplate;
                            column.cellTemplate = function(cellElement, cellInfo) {
                                if (origCell) origCell(cellElement, cellInfo);
                                if (cellInfo.value) cellElement.attr("title", cellInfo.value);
                            };
                        } else if (dataField === "Address") {
                            delete column.width;
                            delete column.maxWidth;
                            column.minWidth = 320;
                            const origCell = column.cellTemplate;
                            column.cellTemplate = function(cellElement, cellInfo) {
                                if (origCell) origCell(cellElement, cellInfo);
                                if (cellInfo.value) cellElement.attr("title", cellInfo.value);
                            };
                        } else if (dataField === "TaxCode") {
                            column.width = 160;
                            column.minWidth = 130;
                            delete column.maxWidth;
                            column.alignment = "left";
                        } else if (dataField === "IsActive") {
                            column.width = 110;
                            column.minWidth = 90;
                            delete column.maxWidth;
                            column.alignment = "left";
                        }
                        orderedColumns.push(column);
                    }
                });

                currentColumns.forEach(function (column) {
                    if (!column || desiredOrder.indexOf(column.dataField) === -1) {
                        orderedColumns.push(column);
                    }
                });

                gridInstance.option({
                    "columnAutoWidth": false,
                    "allowColumnResizing": true,
                    "columnResizingMode": "widget"
                });

                gridInstance.option("columns", orderedColumns);
            }

            // Cột Kích hoạt: header căn trái theo yêu cầu, checkbox trong cell căn giữa
            // Không bật editing cho toàn grid để tránh sửa nhầm các cột còn lại.
            gridInstance.columnOption("IsActive", {
                alignment: "left",
                allowEditing: false,
                cellTemplate: function (container, options) {
                    container.css("text-align", "center");
                    const rowData = options.data;
                    let savedValue =
                        rowData.IsActive === true ||
                        rowData.IsActive === 1 ||
                        rowData.IsActive === "1";
                    let isRollingBack = false;

                    const $wrapper = $("<div>").css({
                        display: "flex",
                        justifyContent: "center",
                        alignItems: "center",
                        width: "100%"
                    }).appendTo(container);

                    $("<div>").dxCheckBox({
                        value: savedValue,
                        onValueChanged: function (e) {
                            if (isRollingBack || !e.event) return;

                            const checkBox = e.component;
                            const newValue = e.value === true;
                            if (newValue === savedValue) return;

                            checkBox.option("disabled", true);

                            AjaxHPAParadise({
                                data: {
                                    name: "sp_CRM_CompanyInfo_UpdateBit",
                                    param: [
                                        "Company_ID", rowData.Company_ID,
                                        "IsActive", newValue ? 1 : 0
                                    ]
                                },
                                success: function () {
                                    savedValue = newValue;
                                    rowData.IsActive = newValue;
                                    checkBox.option("disabled", false);

                                    if (
                                        typeof uiManager !== "undefined" &&
                                        uiManager &&
                                        typeof uiManager.showAlert === "function"
                                    ) {
                                        uiManager.showAlert({
                                            type: "success",
                                            message: "Đã cập nhật trạng thái kích hoạt"
                                        });
                                    }
                                },
                                error: function (error) {
                                    console.error(
                                        "[GridCompanyList] Update IsActive failed",
                                        error
                                    );

                                    isRollingBack = true;
                                    checkBox.option("value", savedValue);
                                    isRollingBack = false;
                                    checkBox.option("disabled", false);

                                    if (
                                        typeof uiManager !== "undefined" &&
                                        uiManager &&
                                        typeof uiManager.showAlert === "function"
                                    ) {
                                        uiManager.showAlert({
                                            type: "error",
                                            message: "Không cập nhật được trạng thái kích hoạt"
                                        });
                                    }
                                }
                            });
                        }
                    }).appendTo($wrapper);
                }
            });

            gridInstance.beginUpdate();
            gridInstance.option("remoteOperations", {
                paging: true, filtering: true, sorting: true, searching: true
            });

            gridInstance.option({
                "scrolling.mode": "infinite",
                "scrolling.rowRenderingMode": "virtual",
                "scrolling.preloadEnabled": false,
                "paging.enabled": true,
                "paging.pageSize": 50,
                "pager.visible": false,
                "searchPanel.highlightSearchText": false,
                "dataSource": dataStore_GridCompanyList,
                "height": getGridHeight()
            });

            gridInstance.option("onOptionChanged", function (e) {
                if (e.name === "searchPanel" && e.fullName === "searchPanel.text") {
                    _currentKeyword = (e.value || "").trim();
                    _pageCache = {};

                    clearTimeout(_searchTimer);
                    _searchTimer = setTimeout(function () {
                        gridInstance.pageIndex(0);
                        gridInstance.refresh();
                    }, 350);
                }
            });
            gridInstance.endUpdate();

            // Áp ngay và áp lại sau khi cấu hình column chooser trả về.
            applyCompanyColumnOrder();
            setTimeout(applyCompanyColumnOrder, 500);
            setTimeout(applyCompanyColumnOrder, 1500);

            // ============================================================
            // 3. HÀM RELOAD DATA TỐI GIẢN
            // ============================================================
            function ReloadData(pageNumber, pageSize, keyword = null) {
                if (keyword !== null) _currentKeyword = keyword.trim();
                _pageCache = {};
                gridInstance.refresh();
            }

            '
        +(select loadData from tblCommonControlType_Signed where UID = 'P3A154CE250774CED990853E06804BF8B') +N'

            ReloadData()
        })();
</script>
    ';
    SELECT @html AS html;
END;
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 2: CHUẨN HÓA STORED PROCEDURE ĐIỀU PHỐI (TRỎ VỀ ĐÚNG 1 KEY CHUẨN HỆ THỐNG)
--------------------------------------------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE [dbo].[sp_CRM_CompanyList]
    @LoginID INT = NULL,
    @LanguageID VARCHAR(5) = 'VN',
    @EmployeeID VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @LanguageID IS NULL OR LTRIM(RTRIM(@LanguageID)) = ''
        SET @LanguageID = 'VN';

    -- Đọc duy nhất 1 Key chuẩn quy ước của hệ thống (Không dùng IN, không fallback chắp vá)
    SELECT TOP 1 html AS Col1 
    FROM tblHtmlScriptCache 
    WHERE TableName = 'sp_CRM_CompanyList' 
      AND ScreenType = -1 
      AND LanguageID = @LanguageID;
END
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 3: BIÊN DỊCH MÃ NGUỒN GIAO DIỆN VÀO BẢNG CACHE QUA SP_GENERATEHTMLSCRIPT_NEW
  Tự động biên dịch mã nguồn và cập nhật vào tblHtmlScriptCache WHERE TableName = 'sp_CRM_CompanyList'
--------------------------------------------------------------------------------------------------*/
PRINT N'==> Đang biên dịch cache giao diện Danh sách công ty CRM qua sp_GenerateHTMLScript_new...';
IF OBJECT_ID('dbo.sp_GenerateHTMLScript_new', 'P') IS NOT NULL
    EXEC [dbo].[sp_GenerateHTMLScript_new] 'sp_CRM_CompanyList_html', '-1', 'sp_CRM_CompanyList';
ELSE
    EXEC [dbo].[sp_GenerateHTMLScript] 'sp_CRM_CompanyList_html';
GO

PRINT N'==================================================================================================';
PRINT N'==> HOÀN TẤT CẬP NHẬT SCREENSHOT 6! HÃY VÀO TRÌNH DUYỆT BẤM CTRL + F5 ĐỂ KIỂM TRA NGHIỆM THU.';
PRINT N'==================================================================================================';
GO
