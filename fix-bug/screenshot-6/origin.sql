/***************************************************************************************************
  DATABASE NGUỒN GỐC : [Vietinsoft_ForTest_Tai] (Chưa qua chỉnh sửa)
  SCREENSHOT         : SCREENSHOT-6
  MÀN HÌNH / MENU    : CRM -> Danh sách công ty (MnuCRM001)
  MỤC ĐÍCH           : Lưu trữ nguyên trạng mã nguồn Stored Procedure gốc để Sếp đối chiếu (COMPARE)
                       trước và sau khi áp dụng bản vá trong file patch tương ứng.
***************************************************************************************************/

USE [Vietinsoft_ForTest_Tai];
GO

/*--------------------------------------------------------------------------------------------------
  THỦ TỤC GỐC [1/2]: [dbo].[sp_CRM_CompanyList_html]
--------------------------------------------------------------------------------------------------*/
-- =================================================================================
-- BƯỚC 5: TẠO CẶP STORED PROCEDURE GIAO DIỆN (CÓ GỌI ReloadData() ĐỂ NẠP DỮ LIỆU)
-- =================================================================================
CREATE PROCEDURE [dbo].[sp_CRM_CompanyList_html]
    @LoginID INT = 3,
    @LanguageID NVARCHAR(10) = N'VN'
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
            // 0. KHAI BAO CAC HAM SU KIEN MAC DINH CHO GRID
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
                          // Kiểm tra filter item có phải function không
                      const isJSFunction = (item) => typeof item === "function";

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
            // 2. KHỞI TẠO GRID LAYOUT MỘT LẦN DUY NHẤT
    // ============================================================
            const gridInstance = InstanceGridCompanyListP3A154CE250774CED990853E06804BF8B;

            // Đảo thứ tự hiển thị cột:
            // Tên công ty -> Địa chỉ -> Mã số thuế -> Kích hoạt.
            // Phải sắp lại mảng columns vì column chooser tải bất đồng bộ
            // có thể ghi đè visibleIndex.
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
                    if (column) orderedColumns.push(column);
                });

                currentColumns.forEach(function (column) {
                    if (!column || desiredOrder.indexOf(column.dataField) === -1) {
                        orderedColumns.push(column);
                    }
                });

                gridInstance.option("columns", orderedColumns);
            }

            // Cột Kích hoạt: dùng checkbox thật và lưu ngay khi người dùng thay đổi.
            // Không bật editing cho toàn grid để tránh sửa nhầm các cột còn lại.
            gridInstance.columnOption("IsActive", {
                alignment: "center",
                allowEditing: false,
                cellTemplate: function (container, options) {
                    const rowData = options.data;
                    let savedValue =
                        rowData.IsActive === true ||
                        rowData.IsActive === 1 ||
                        rowData.IsActive === "1";
                    let isRollingBack = false;

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
                    }).appendTo(container);
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
        })();s
</script>
        '
    SELECT @html AS html;
END;
GO

/*--------------------------------------------------------------------------------------------------
  [dbo].[sp_CRM_CompanyList]
  TRẠNG THÁI GỐC: Thủ tục này CHƯA TỒN TẠI trên CSDL gốc [Vietinsoft_ForTest_Tai].
  GHI CHÚ: Thủ tục này được tạo mới trong quá trình sửa lỗi để làm thủ tục điều phối nạp cache.
--------------------------------------------------------------------------------------------------*/

