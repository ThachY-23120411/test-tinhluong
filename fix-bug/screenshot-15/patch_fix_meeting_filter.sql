-- =========================================================================================
-- BẢN VÁ SỬA LỖI GIAO DIỆN: SCREENSHOT 15 - CÁC CUỘC HỌP (sp_KPIMeetingDemo)
-- Vấn đề:
--   1. Thanh lọc dữ liệu (Filter toolbar) bị render 2 lần lặp lại nằm cạnh nhau trên cùng một hàng.
--   2. Ô SearchPanel (kính lúp) bị đè chồng lấn lên cụm filter thứ hai ở góc phải.
--   3. Các ô chọn ngày và ô tìm kiếm bị lệch màu nền trắng / đen thui chưa đồng bộ Dark Theme.
-- Nguyên nhân gốc rễ (RCA):
--   1. Trong template của DevExtreme toolbar item, code sử dụng lệnh:
--      $(element).parent().prepend($container);
--      -> Lệnh này đẩy $container ra ngoài thẻ element được DevExtreme quản lý để nhét vào parent.
--      Khi DevExtreme tính lại layout hoặc render lại toolbar, nó lại gọi hàm template một lần nữa,
--      dẫn đến 2 khối $container cùng tồn tại song song trên thanh công cụ!
--   2. Mảng toolbar newItems lại spread "...existingItems" bừa bãi, khiến searchPanel và buttons
--      bị chèn lặp lại và đè lên cụm filter thứ hai.
-- Giải pháp:
--   - Chuyển sang gắn trực tiếp vào container chuẩn của DevExtreme: $(element).empty().append($container).
--   - Dọn sạch mọi instance thừa trên DOM: $("#Grid_MeetingCRM .ms-filter-toolbar").not(element).remove().
--   - Chuẩn hóa mảng newItems gọn gàng gồm: [Filter (before), SearchPanel (after), ColumnChooser (after)].
--   - Đồng bộ màu xám ghi (#2b3035) cho ô chọn ngày và ô tìm kiếm ăn khớp 100% với Dark Theme.
-- =========================================================================================

USE [Vietinsoft_ForTest_Tai2]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_KPIMeetingDemo_html]
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
<div id="meetingScheduleComponent" class="ms-container">
    <style>
        /* [SCREENSHOT 15 FIX]: Tối ưu Toolbar Responsive Flex Wrap - Chống đè lấn các phần tử */
        #Grid_MeetingCRM .dx-toolbar {
            height: auto !important;
            overflow: visible !important;
            margin-bottom: 8px !important;
        }

        #Grid_MeetingCRM .dx-toolbar .dx-toolbar-items-container {
            height: auto !important;
            min-height: 44px !important;
            display: flex !important;
            flex-wrap: wrap !important;
            align-items: center !important;
            justify-content: space-between !important;
            row-gap: 8px !important;
            column-gap: 12px !important;
            padding: 4px 0 !important;
            width: 100% !important;
        }

        /* Triệt tiêu thuộc tính position: absolute ngầm của DevExtreme gây đè chồng các cụm nút */
        #Grid_MeetingCRM .dx-toolbar .dx-toolbar-before,
        #Grid_MeetingCRM .dx-toolbar .dx-toolbar-center,
        #Grid_MeetingCRM .dx-toolbar .dx-toolbar-after {
            position: relative !important;
            left: auto !important;
            right: auto !important;
            top: auto !important;
            transform: none !important;
            height: auto !important;
        }

        #Grid_MeetingCRM .dx-toolbar .dx-toolbar-before {
            flex: 1 1 auto !important;
            display: flex !important;
            align-items: center !important;
            max-width: 100% !important;
        }

        #Grid_MeetingCRM .dx-toolbar .dx-toolbar-after {
            flex: 0 0 auto !important;
            margin-left: auto !important;
            display: flex !important;
            align-items: center !important;
        }

        #Grid_MeetingCRM .ms-filter-toolbar {
            display: flex !important;
            align-items: center !important;
            flex-wrap: wrap !important;
            gap: 8px !important;
            width: 100% !important;
        }

        #Grid_MeetingCRM .ms-toolbar-right-group {
            display: flex !important;
            align-items: center !important;
            flex-wrap: nowrap !important;
            white-space: nowrap !important;
            gap: 8px !important;
        }

        #Grid_MeetingCRM .ms-toolbar-right-group .dx-textbox {
            width: 220px !important;
            max-width: 220px !important;
        }

        #Grid_MeetingCRM .ms-toolbar-right-group .dx-textbox,
        #Grid_MeetingCRM .ms-toolbar-right-group .dx-texteditor {
            background-color: #2b3035 !important;
            border: 1px solid #495057 !important;
            color: #e9ecef !important;
            border-radius: 4px !important;
        }

        #Grid_MeetingCRM .ms-toolbar-right-group .dx-texteditor-input {
            background-color: transparent !important;
            color: #e9ecef !important;
            padding-right: 24px !important;
        }

        #Grid_MeetingCRM .ms-toolbar-right-group .dx-icon-search {
            color: #adb5bd !important;
        }

        #Grid_MeetingCRM .ms-toolbar-right-group .btn-columnchooser-toolbar .dx-button-content {
            padding: 7px 10px !important;
            background-color: #2b3035 !important;
            border: 1px solid #495057 !important;
            border-radius: 4px !important;
            color: #adb5bd !important;
        }

        #Grid_MeetingCRM .ms-toolbar-right-group .btn-columnchooser-toolbar .dx-icon {
            color: #adb5bd !important;
        }

        #Grid_MeetingCRM .ms-toolbar-right-group .btn-create-meeting-toolbar:hover {
            background-color: #157347 !important;
            color: #ffffff !important;
        }
.ms-container {
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.07);
            padding: 24px;
            margin-bottom: 20px;
        }

        .ms-header-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
            padding-bottom: 16px;
            border-bottom: 2px solid #e3e8ef;
        }

        .ms-header-section h2 {
            margin: 0;
            color: #2c3e50;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .ms-header-section h2 i {
            color: #3498db;
        }

        .modal-content {
            border: none !important;
            box-shadow: none !important;
        }

        .modal-footer {
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }

        .ms-table tbody tr {
            cursor: pointer;
        }

        .ms-table tbody tr:hover {
            background-color: rgba(255, 255, 255, 0.05) !important;
        }

        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .status-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .status-pending {
            background-color: #fff3cd;
            color: #856404;
            border: 1px solid #ffeaa7;
        }

        .status-failed {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .teams-badge {
            background: linear-gradient(135deg, #6264a7 0%, #8b5cf6 100%);
            color: white;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .attendee-list {
            max-width: 300px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .ms-table thead {
            color: white;
        }

        .ms-table thead th {
            border: none;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 0.5px;
        }


        .ms-filter {
            display: none;
            /* Hidden - now using toolbar */
            gap: 12px;
            align-items: flex-end;
            margin-bottom: 20px;
            padding: 16px;
            border-radius: 8px;
            flex-wrap: wrap;
        }

        .ms-filter label {
            margin: 0;
            font-weight: 500;
            font-size: 13px;
        }

        .ms-filter input[type="date"] {
            padding: 8px 0;
            border: none;
            border-bottom: 2px solid #ddd;
            border-radius: 0;
            font-size: 13px;
            cursor: pointer;
            background: transparent;
        }

        .ms-filter input[type="date"]:focus {
            outline: none;
            border-bottom-color: #198754;
            box-shadow: none;
        }

        .ms-filter .btn {
            padding: 8px 20px;
 font-size: 13px;
            font-weight: 500;
            border-radius: 6px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s ease;
        }

        .ms-filter .btn-success {
            background-color: #198754;
            border-color: #198754;
            color: white;
        }

        .ms-filter .btn-success:hover {
            background-color: #157347;
            border-color: #157347;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(25, 135, 84, 0.2);
        }

        .ms-filter .btn-outline-secondary {
            border: 2px solid #198754;
            color: #198754;
        }

        .ms-filter .btn-outline-secondary:hover {
            color: #157347;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(100, 116, 139, 0.15);
        }

        .ms-filter .form-group {
            margin: 0;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        /* Form Control Styles - Bottom Border Only (Modal Only) */
        .modal .form-control,
        .modal input[type="text"],
        .modal input[type="email"],
        .modal input[type="number"],
        .modal textarea {
            border: none !important;
            border-radius: 0 !important;
            background: transparent !important;
            padding: 8px 0 !important;
            font-size: 14px !important;
            transition: all 0.2s ease !important;
            border-bottom: 1px solid #ccc !important;
        }

        .modal .form-control:focus,
        .modal input[type="text"]:focus,
        .modal input[type="email"]:focus,
        .modal input[type="number"]:focus,
        .modal textarea:focus {
            outline: none !important;
            box-shadow: none !important;
            background: transparent !important;
        }
    </style>

    <!-- [REMOVED]: Create Meeting Button đã chuyển vào Toolbar DataGrid ngang hàng với Search -->

    <div class="table-responsive">
        <!-- <table class="table table-hover ms-table">
            <thead>
                <tr>
                    <th>STT</th>
                    <th>Tiêu đề</th>
                    <th>Thời gian bắt đầu</th>
                    <th>Thời gian kết thúc</th>
                    <th>Người tham dự</th>
                    <th>Địa điểm</th>
                    <th>Trạng thái</th>
                    <th>Hành động</th>
                </tr>
            </thead>
            <tbody id="meetingScheduleTableBody">
            </tbody>
        </table> -->
        <div id="Grid_MeetingCRM" style="height: 100%;"></div>
    </div>
</div>

<!-- Meeting Schedule Modal -->
<div class="modal fade" id="meetingScheduleModal" tabindex="-1" data-bs-backdrop="static" data-bs-keyboard="false">
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="meetingScheduleModalTitle">Tạo cuộc họp mới</h5>
                <button type="button" class="btn-close"></button>
            </div>
            <style>
                .required-field::after {
                    content: '' *'';
                    color: #dc3545;
                    font-weight: bold;
                }
            </style>
            <div class="modal-body">
                <form id="meetingScheduleForm">
                    <!-- Tiêu đề cuộc họp -->
                  <div class="form-group mb-3" style="display: flex; align-items: center; gap: 10px;">
                        <label for="ms_title" class="form-label required-field"
                            style="min-width: 140px; margin: 0;">Tiêu đề:</label>
                        <input type="text" class="form-control" id="ms_title" name="Title"
                            placeholder="Nhập tiêu đề cuộc họp" required style="flex: 1;">
                    </div>

                    <!-- Địa điểm -->
                    <div class="form-group mb-3" style="display: flex; align-items: center; gap: 10px;">
                        <label for="ms_location" class="form-label" style="min-width: 140px; margin: 0;">Địa
                            điểm:</label>
                        <input type="text" class="form-control" id="ms_location" name="Location"
                            placeholder="Phòng họp / Địa chỉ" style="flex: 1;">
                    </div>

                    <!-- Thời gian bắt đầu -->
                    <div class="form-group mb-3" style="display: flex; align-items: center; gap: 10px;">
                        <label for="ms_start" class="form-label required-field" style="min-width: 140px; margin: 0;">Bắt
                            đầu:</label>
                        <div id="PBF27C4AAE68A411FBC22A5ABD308D044" style="flex: 1;"></div>
                    </div>

                    <!-- Thời gian kết thúc -->
                    <div class="form-group mb-3" style="display: flex; align-items: center; gap: 10px;">
                        <label for="ms_end" class="form-label required-field" style="min-width: 140px; margin: 0;">Kết
                            thúc:</label>
                        <div id="P823B2119D2694A6C8BC61E67B1D13FAE" style="flex: 1;"></div>
                    </div>

                    <!-- Người tham dự -->
                    <div class="form-group mb-3" style="display: flex; align-items: flex-start; gap: 10px;">
                        <label for="ms_attendees" class="form-label"
                            style="min-width: 140px; margin: 0; padding-top: 5px;">Người tham dự:</label>
                        <div style="flex: 1;">
                            <input type="text" class="form-control" id="ms_attendees"
                                placeholder="Nhập email và nhấn Enter để thêm" list="msEmployeeList">
                            <datalist id="msEmployeeList"></datalist>
                            <div id="ms_attendees_tags" class="mt-2" style="display: flex; flex-wrap: wrap; gap: 8px;">
                            </div>
                            <input type="hidden" id="ms_attendees_hidden">
                        </div>
                    </div>

                    <!-- Nội dung cuộc họp -->
                    <div class="form-group mb-3" style="display: flex; align-items: flex-start; gap: 10px;">
                        <label for="ms_description" class="form-label"
                            style="min-width: 140px; margin: 0; padding-top: 5px;">Nội dung:</label>
                        <!-- <textarea class="form-control" id="ms_description" name="Description" rows="4"
                            placeholder="Mô tả chi tiết nội dung cuộc họp" style="flex: 1;"></textarea> -->
                        <div class="w-100" id="P2ABD553B3460416D8CA937F74E864933"></div>
                    </div>

                    <!-- Teams checkbox + Remind checkbox -->
                    <div style="display: flex; gap: 30px; margin-bottom: 15px; justify-content: end;">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="ms_is_teams" name="IsMeetingTeams">
                            <label class="form-check-label" for="ms_is_teams">
                                Cuộc họp Teams Online
                            </label>
       </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="ms_is_remind" name="IsRemind">
                            <label class="form-check-label" for="ms_is_remind">
                                Bật nhắc nhở
                            </label>
                        </div>
                    </div>

                    <!-- Nhắc nhở -->
                    <div class="form-group mb-3" style="display: flex; align-items: center; gap: 10px;">
                        <label for="ms_remind_minutes" class="form-label" style="min-width: 140px; margin: 0;">Nhắc
                            trước:</label>
                        <div style="display: flex; align-items: center; gap: 5px; flex: 1;">
                            <input type="number" class="form-control" id="ms_remind_minutes"
                                name="ReminderMinutesBeforeStart" value="15" min="0" style="max-width: 100px;">
                            <span style="color: #666; font-size: 13px;">phút</span>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" id="cancelMeetingBtn">Hủy</button>
                <button type="button" class="btn btn-success" onclick="saveMeetingSchedule()"><i
                        class="fas fa-save me-2"></i>Lưu cuộc họp</button>
            </div>
        </div>
    </div>
</div>

<!-- Meeting Detail Modal -->
<div class="modal fade" id="meetingDetailModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Chi tiết cuộc họp</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="meetingDetailBody">
                <!-- Detail will be rendered here -->
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<div class="d-none">
    <div id="PE4B749C9E22149ED91266A5C6444354E"></div>
</div>

<script>
    (async () => {
        let _pageCache = {};
        let dataStore_Grid_MeetingCRM = null;
        var mailEmployeeList = [];
        async function loadMailEmployee() {
            AjaxHPAParadise({
                data: {
                    name: "sp_KPIgetEmailListCompany",
                    param: [''LoginID'', window.UserID]
                },
                success: function (data) {
                    if (typeof data == "string" && !IsNullOrEmpty(data)) {
                        data = data.includes("{") ? data : EncryptionStringDecryption(data);
                    }
                    let dataObject = JSON.parse(data);
                    let mailEmployeeData = dataObject.data?.[0];
                    if (mailEmployeeData) {
                        mailEmployeeList = mailEmployeeData;
                    }
                }
            })
        }

        if (typeof mailEmployeeList === ''undefined'' || mailEmployeeList.length === 0) {
            await loadMailEmployee();
        }

        let DataSource = []

        '
            + (select LoadUI from tblCommonControlType_Signed where UID = 'PE4B749C9E22149ED91266A5C6444354E')
        + (select loadUI from tblCommonControlType_Signed where UID = 'PBF27C4AAE68A411FBC22A5ABD308D044')
        +(select loadUI from tblCommonControlType_Signed where UID = 'P823B2119D2694A6C8BC61E67B1D13FAE')
        +(select loadUI from tblCommonControlType_Signed where UID = 'P2ABD553B3460416D8CA937F74E864933') +N'

        // if ("sp_EmployeeListDataMultiSelectSelectBox" && "sp_EmployeeListDataMultiSelectSelectBox".trim() !== "") {
        //     loadDataSourceCommon("EmployeeID", "sp_EmployeeListDataMultiSelectSelectBox", function (data) {
        // // Data được shared qua callback
        //     });
        //}

        function loadDataSourceCommon(columnName, dataSourceSP, onSuccessCallback) {
            if (!columnName || !dataSourceSP || dataSourceSP.trim() === "") {
                console.warn("[loadDataSourceCommon] Missing columnName or dataSourceSP");
                return;
            }

            const dataSourceKey = "DataSource_" + columnName;
            const loadedKey = columnName + "DataSourceLoaded";

            if (window[loadedKey] === true) {
                if (typeof onSuccessCallback === "function") {
                    onSuccessCallback(window[dataSourceKey] || []);
                }
                return;
            }

            if (window[loadedKey] === "loading") {
                setTimeout(function () {
                    loadDataSourceCommon(columnName, dataSourceSP, onSuccessCallback);
                }, 100);
                return;
            }

            window[loadedKey] = "loading";

            AjaxHPAParadise({
                data: {
                    name: dataSourceSP,
                    param: ["LoginID", LoginID, "LanguageID", LanguageID]
                },
                success: function (res) {
                    const json = typeof res === "string" ? JSON.parse(res) : res;
                    window[dataSourceKey] = (json.data && json.data[0]) || [];

                    window[loadedKey] = true;

                    if (typeof onSuccessCallback === "function") {
                        onSuccessCallback(window[dataSourceKey]);
                    }

                    const instanceVariants = [
                        "Instance" + columnName.charAt(0).toUpperCase() + columnName.slice(1) + "P89D4A2BDA88F4F8A81EC9926B84F0D11",
                        "Instance" + columnName + "P89D4A2BDA88F4F8A81EC9926B84F0D11",
                        "instance" + columnName.charAt(0).toUpperCase() + columnName.slice(1) + "P89D4A2BDA88F4F8A81EC9926B84F0D11"
                    ];

                    for (let i = 0; i < instanceVariants.length; i++) {
                        const instanceKey = instanceVariants[i];

                        if (window[instanceKey] || instanceKey) {
                            const instanceObj = window[instanceKey] || instanceKey;


                            // Ki?m tra n?u dây là dxDataGrid
                            if (typeof instanceObj.dxDataGrid === "function" || instanceObj.option && instanceObj.option("dataSource") !== undefined) {
                                try {
                                    // N?u là Grid, apply dynamic config
                                    const gridConfigFn = window["getGridConfig_" + columnName.charAt(0).toUpperCase() + columnName.slice(1)];
                                    if (typeof gridConfigFn === "function") {
                                        const gridConfig = gridConfigFn(window[dataSourceKey]);
                                        instanceObj.option("remoteOperations", gridConfig.remoteOperations);
                                        instanceObj.option("paging.pageSize", gridConfig.pageSize);
                                        instanceObj.option("pager.allowedPageSizes", gridConfig.allowedPageSizes);
                                    }

                                    instanceObj.option("dataSource", window[dataSourceKey]);
                                    break;
                                } catch (e) {
                                    console.warn("[LoadDataSourceCommon] Grid config error:", e);
                                    // Fallback: just set data source
                                    instanceObj.option("dataSource", window[dataSourceKey]);
                                    break;
                                }
                            } else if (typeof instanceObj.setDataSource === "function") {
                                instanceObj.setDataSource(window[dataSourceKey]);
                                break;
                            } else if (typeof instanceObj.option === "function") {
                                try {
                                    instanceObj.option("dataSource", window[dataSourceKey]);
                                    break;
                                } catch (e) {
                                    // Continue to next variant
                                }
                            }
                        }
                    }
                },
                error: function (err) {
                    console.error("[loadDataSourceCommon] Failed to load datasource for", columnName, ":", err);
                    window[loadedKey] = false;
                    if (typeof onSuccessCallback === "function") {
                        onSuccessCallback([]);
                    }
                }
            });
        }

        window.InstanceGrid_MeetingCRMP05D3499250FE4F37B3E7BC0C1605115F = null;
        // Thêm responsive styles cho grid header
        const styleGrid_MeetingCRM = document.createElement("style");
        styleGrid_MeetingCRM.textContent = `
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

                                /* Ensure Action column is always visible */
                                .dx-datagrid .dx-col-fixed {
                                    z-index: 999 !important;
                                }

                                .dx-datagrid .dx-fixed-col[aria-describedby*="Action"] {
                                    display: table-cell !important;
                                    visibility: visible !important;
                           min-width: 120px !important;
 }

                                /* Mobile Action buttons - show icons only */
                    .dx-datagrid .dx-data-row .button-container button {
                                    padding: 3px 6px !important;
                                    min-width: 30px !important;
                                    font-size: 10px !important;
                                }

                                .dx-datagrid .dx-data-row .button-container button span {
                                    display: none !important;
                                }

                                .dx-datagrid .dx-data-row .button-container button i {
                                    font-size: 12px !important;
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
        document.head.appendChild(styleGrid_MeetingCRM);

        // Helper normalize function: bỏ dấu - dùng chung cho search/grid
        window.normalizeVietnameseText = window.normalizeVietnameseText || function (value) {
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
        const gridName = "Grid_MeetingCRM";
        window.hpaColumnChooser = window.hpaColumnChooser || { saveTimers: {} };
        const chooser = window.hpaColumnChooser;


        if (!chooser.normalize) {
            chooser.normalize = function (res) {
                if (typeof res === "string" && res.trim() !== "") {
                    return res.includes("{") ? JSON.parse(res) : JSON.parse(EncryptionStringDecryption(res));
                }
                return res;
            };
        }

        if (!chooser.load) {
            chooser.load = function (gridInstance, gridNameParam) {
                AjaxHPAParadise({
                    data: {
                        name: "sp_GridColumnChooser_Load",
                        param: [
                            "LoginID", window.UserID,
                            "GridName", gridNameParam
                        ]
                    },
                    success: function (res) {
                        const json = chooser.normalize(res);
                        const rows = (json?.data && json.data[0]) || [];
                        const settingsJson = rows[0]?.SettingsJson;
                        if (!settingsJson) return;
                        let arr = [];
                        try { arr = JSON.parse(settingsJson) || []; } catch (e) { arr = []; }
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
            chooser.save = function (gridInstance, gridNameParam) {
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
                    success: function (res) {
                        if (typeof res === "string" && res.trim() !== "") {
                            res = res.includes("{") ? res : EncryptionStringDecryption(res);
                        }
                    }
                });
            };
        }

        // =============== GRID CONFIG DYNAMIC BASED ON DATA SIZE ===============
        // Hàm tính remoteOperations dựa trên số lượng dòng
        window.getGridConfig_Grid_MeetingCRM = function (dataArray) {
            const dataSize = Array.isArray(dataArray) ? dataArray.length : 0;
            const isLargeDataset = dataSize > 1000;

            return {
                remoteOperations: isLargeDataset,
                pageSize: 50,
                allowedPageSizes: isLargeDataset ? [10, 25, 50] : [5, 10, 50, 100]
            };
        };

        InstanceGrid_MeetingCRMP05D3499250FE4F37B3E7BC0C1605115F = $("#Grid_MeetingCRM").dxDataGrid({
            dataSource: [],
            keyExpr: "MeetID",
  height: "100%",
            width: "100%",
            showBorders: true,
            showRowLines: true,
            rowAlternationEnabled: false,
            hoverStateEnabled: false,
            columnAutoWidth: true,
            allowColumnReordering: true,
            allowColumnResizing: true,
            columnResizingMode: "widget",
            columnMinWidth: 80,
            wordWrapEnabled: true,

            scrolling: {
                mode: "standard",
                showScrollbar: "onHover",
                useNative: false,
                preloadEnabled: false
            },

            paging: {
                enabled: true,
                pageSize: 50
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
                allowSearch: true,
                position: {
                    my: "right top",
                    at: "right bottom",
                    of: "#Grid_MeetingCRM .btn-columnchooser-toolbar",
                    collision: "fit flip"
                }
            },

            stateStoring: {
                enabled: false,
                type: "localStorage",
                storageKey: "gridState_Grid_MeetingCRM"
            },

            grouping: {
                autoExpandAll: false,
                contextMenuEnabled: false,
                allowCollapsing: false
            },

            groupPanel: { visible: false },
            columnFixing: { enabled: true },

            customizeColumns: function (columns) {
                const normalizeText = window.normalizeVietnameseText || function (val) {
                    if (val === undefined || val === null) return "";
                    return String(val).toLowerCase();
                };

                columns.forEach(function (column) {
                    if (column._hpaSearchNormalized) return;
                    column._hpaSearchNormalized = true;

                    const originalCalculate = column.calculateFilterExpression;
                    const dataFieldPath = column.dataField || column.name || "";
                    const getValue = column.calculateCellValue
                        ? column.calculateCellValue.bind(column)
                        : function (dataObj) {
                            if (!dataObj || !dataFieldPath) return null;
                            if (dataFieldPath.indexOf(".") === -1) {
                                return dataObj[dataFieldPath];
                            }
                            return dataFieldPath.split(".").reduce(function (acc, key) {
                                return acc && acc[key] !== undefined ? acc[key] : null;
                            }, dataObj);
                        };

                    column.calculateFilterExpression = function (filterValue, selectedFilterOperation, target) {
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

                            return function (dataItem) {
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
            rowDragging: {
                allowReordering: false,
                showDragIcons: false
            }
            ,
            noDataText: "Không có dữ liệu",
            columns: [

                {
                    dataField: "Title",
                    caption: "%TKTitle%",
                    minWidth: 260,
                    alignment: "left",
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function (cellElement, cellInfo) {
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
                    dataField: "MeetStart",
                    caption: "%lblStartTime%",
                    width: 145,
                    alignment: "center",
                    minWidth: 130,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function (cellElement, cellInfo) {
                        const val = cellInfo.value;
                        if (!val || val === "") {
                            $("<div>").addClass("dx-placeholder").text("").appendTo(cellElement);
                            return;
                        }
                        const d = new Date(val);
                        let text = ""; text = DevExpress.localization.formatDate(d, "dd/MM/yyyy HH:mm");
                        $("<div>").text(text).appendTo(cellElement);
                    },
                    allowEditing: false,
                },

                {
                    dataField: "MeetEnd",
                    caption: "%lblEndTime%",
                    width: 145,
                    alignment: "center",
                    minWidth: 130,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function (cellElement, cellInfo) {
                        const val = cellInfo.value;
                        if (!val || val === "") {
                            $("<div>").addClass("dx-placeholder").text("").appendTo(cellElement);
                            return;
                        }
                        const d = new Date(val);
let text = ""; text = DevExpress.localization.formatDate(d, "dd/MM/yyyy HH:mm");
                        $("<div>").text(text).appendTo(cellElement);
                    },
                    allowEditing: false,
                },

                {
                    dataField: "Attendees",
                    caption: "%MSG_PARTICIPANT%",
                    minWidth: 260,
                    alignment: "left",
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function (cellElement, cellInfo) {
                        const val = cellInfo.value;
                        if (val === undefined || val === null || val === "") {
                            $("<div>").addClass("dx-placeholder").text("Chưa có").appendTo(cellElement);
                            return;
                        }

                        const emails = val.split('','').map(email => email.trim()).filter(email => email !== '''');

                        if (emails.length === 0) {
                            $("<div>").addClass("dx-placeholder").text("Chưa có").appendTo(cellElement);
                            return;
                        }

                        const container = $("<div>").css({
                            ''display'': ''flex'',
                            ''flex-wrap'': ''wrap'',
                            ''gap'': ''4px'',
                            ''align-items'': ''center'',
                            ''line-height'': ''1.2''
                        }).appendTo(cellElement);

                        const maxVisible = 2; // Hiển thị tối đa 2 email ban đầu

                        // Hiển thị các email đầu tiên
                        emails.slice(0, maxVisible).forEach(email => {
                            $("<span>").css({
                                ''color'': ''#198754'',
                                ''padding'': ''2px 8px'',
                                ''border-radius'': ''12px'',
                                ''font-size'': ''11px'',
                                ''font-weight'': ''500'',
                                ''border'': ''1px solid #bbdefb'',
                                ''white-space'': ''nowrap'',
                                ''max-width'': ''none'',
                                ''overflow'': ''hidden'',
                                ''text-overflow'': ''ellipsis'',
                                ''display'': ''inline-block''
                            }).text(email).appendTo(container);
                        });

                        // Nếu có nhiều email hơn maxVisible
                        if (emails.length > maxVisible) {
                            const remainingCount = emails.length - maxVisible;
                            const expandBtn = $("<span>").css({
                                ''color'': ''#198754'',
                                ''padding'': ''2px 6px'',
                                ''border-radius'': ''12px'',
                                ''font-size'': ''11px'',
                                ''font-weight'': ''bold'',
                                ''border'': ''1px solid #ddd'',
                                ''cursor'': ''pointer'',
                                ''user-select'': ''none'',
                                ''transition'': ''all 0.2s ease''
                            }).text(`+${remainingCount}`).appendTo(container);

                            // Container cho các email ẩn
                            const hiddenContainer = $("<div>").css({
                                ''display'': ''none'',
                                ''flex-wrap'': ''wrap'',
                                ''gap'': ''4px'',
                                ''margin-top'': ''4px'',
                                ''width'': ''100%''
                            }).appendTo(cellElement);

                            // Thêm các email còn lại vào container ẩn
                            emails.slice(maxVisible).forEach(email => {
                                $("<span>").css({
                                    ''color'': ''#198754'',
                                    ''padding'': ''2px 8px'',
                                    ''border-radius'': ''12px'',
                                    ''font-size'': ''11px'',
                                    ''font-weight'': ''500'',
                                    ''border'': ''1px solid #c8e6c9'',
                                    ''white-space'': ''nowrap'',
                                    ''max-width'': ''none'',
                                    ''overflow'': ''hidden'',
                                    ''text-overflow'': ''ellipsis'',
                                    ''display'': ''inline-block''
                                }).text(email).appendTo(hiddenContainer);
                            });

                            let isExpanded = false;

                            // Click handler cho expand/collapse
                            expandBtn.on(''click'', function (e) {
                                e.stopPropagation();
                                isExpanded = !isExpanded;

                                if (isExpanded) {
                                    hiddenContainer.css(''display'', ''flex'');
                                    expandBtn.text(''−'').css({
                                        ''border-color'': ''#ffb74d'',
                                        ''color'': ''#198754''
                                    });
                                } else {
                                    hiddenContainer.css(''display'', ''none'');
                                    expandBtn.text(`+${remainingCount}`).css({
                                        ''border-color'': ''#c8e6c9'',
                                        ''color'': ''#198754''
                                    });
                                }
                            });

                            // Hover effects
                            expandBtn.hover(
                                function () {
                                    $(this).css({
                                        ''transform'': ''scale(1.05)''
                                    });
                                },
                                function () {
                                    $(this).css({
                                        ''transform'': ''scale(1)''
                                    });
                                }
                            );
                        }
                    },
                    allowEditing: false,
                },

                {
                    dataField: "Location",
                    caption: "%Location%",
                    width: 130,
                    alignment: "left",
                    minWidth: 100,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function (cellElement, cellInfo) {
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
                    dataField: "TeamsMeetingUrl",
                    caption: "%UrlMeeting%",
                    minWidth: 180,
                    alignment: "left",
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function (cellElement, cellInfo) {
                        const val = cellInfo.value;
                        if (!val || val === "") {
                            $("<div>").addClass("dx-placeholder").text("").appendTo(cellElement);
                            return;
                        }
                        const href = (val.indexOf("http") === 0) ? val : "https://" + val;

                        $("<a>")
                            .attr("href", href)
                            .attr("target", "_blank")
                            .attr("rel", "noopener noreferrer")
                            .attr("title", val) // Thêm dòng này: Hiển thị tooltip toàn bộ URL khi hover
                            .text(val)
                            .css({
                                "color": "#0d6efd",
                                "text-decoration": "underline",
                                "cursor": "pointer",
                                "display": "block",
                                "white-space": "nowrap",
                                "overflow": "hidden",
                                "text-overflow": "ellipsis",
                                "width": "100%"
                            })
                            .on("click", function (e) { e.stopPropagation(); })
                            .appendTo(cellElement);
                    },
                    allowEditing: false,
                },
                {
                    dataField: "Status",
                    caption: "%Status%",
                    width: 110,
                    alignment: "center",
                    minWidth: 100,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function (cellElement, cellInfo) {
                        const val = cellInfo.value;

                        // Parse status value - handle different data types
                        let isCreated = false;
                        if (val === true || val === 1 || val === "1" || val === "true") {
                            isCreated = true;
                        } else if (val === false || val === 0 || val === "0" || val === "false") {
                            isCreated = false;
                        } else if (val === undefined || val === null || val === "") {
                            // Default to false for empty values
                            isCreated = false;
                        } else {
                            // For other values, try to determine based on content
                            const valStr = String(val).toLowerCase();
                            isCreated = valStr.includes(''đã tạo'') || valStr.includes(''success'') || valStr.includes(''complete'');
                        }

                        const statusBadge = $("<div>").css({
                            ''display'': ''inline-flex'',
                            ''align-items'': ''center'',
                            ''gap'': ''6px'',
                            ''padding'': ''4px 12px'',
                            ''border-radius'': ''16px'',
                            ''font-size'': ''12px'',
                            ''font-weight'': ''600'',
                            ''border'': ''1px solid'',
                            ''white-space'': ''nowrap'',
                            ''justify-content'': ''center''
                        });

                        if (isCreated) {
                            // Success status - green with check icon
                            const icon = $("<i>").addClass("bi bi-check-circle-fill").css({
                 ''font-size'': ''14px'',
                                ''color'': ''#28a745''
                            });
                            statusBadge.css({
                                ''background-color'': ''#d4edda'',
                                ''color'': ''#155724'',
                                ''border-color'': ''#c3e6cb''
                            }).append(icon).append($("<span>").text("Đã tạo"));
                        } else {
                            // Failed/Pending status - red with X icon
                            const icon = $("<i>").addClass("bi bi-x-circle-fill").css({
                                ''font-size'': ''14px'',
                                ''color'': ''#dc3545''
                            });
                            statusBadge.css({
                                ''background-color'': ''#f8d7da'',
                                ''color'': ''#721c24'',
                                ''border-color'': ''#f1b0b7''
                            }).append(icon).append($("<span>").text("Chưa tạo"));
                        }

                        statusBadge.appendTo(cellElement);
                    },
                    allowEditing: false,
                },

                {
                    dataField: "Action",
                    caption: "",
                    width: 85,
                    alignment: "center",
                    minWidth: 80,
                    allowSorting: false,
                    allowFiltering: false,
                    fixed: true,
                    fixedPosition: "right",
                    cellTemplate: function (cellElement, cellInfo) {
                        const meetID = cellInfo.data.MeetID;
                        if (!meetID) return;

                        const buttonContainer = $("<div>").css({
                            ''display'': ''flex'',
                            ''gap'': ''8px'',
                            ''justify-content'': ''center'',
                            ''align-items'': ''center''
                        }).appendTo(cellElement);

                        // Delete Button
                        const deleteBtn = $("<button>").css({
                            ''background-color'': ''#dc3545'',
                            ''color'': ''white'',
                            ''border'': ''1px solid #dc3545'',
                            ''border-radius'': ''6px'',
                            ''padding'': ''4px 8px'',
                            ''font-size'': ''12px'',
                            ''font-weight'': ''500'',
                            ''cursor'': ''pointer'',
                            ''display'': ''flex'',
                            ''align-items'': ''center'',
                            ''gap'': ''4px'',
                            ''transition'': ''all 0.2s ease'',
                            ''white-space'': ''nowrap''
                        }).on(''click'', function (e) {
                            e.stopPropagation();
                            deleteMeetingSchedule(meetID);
                        }).hover(
                            function () {
                                $(this).css({
                                    ''background-color'': ''#c82333'',
                                    ''border-color'': ''#c82333'',
                                    ''transform'': ''scale(1.05)''
                                });
                            },
                            function () {
                                $(this).css({
                                    ''background-color'': ''#dc3545'',
                                    ''border-color'': ''#dc3545'',
                                    ''transform'': ''scale(1)''
                                });
                            }
  );

                        const deleteIcon = $("<i>").addClass("bi bi-trash").css({
                            ''font-size'': ''13px''
                        });
                        deleteBtn.append(deleteIcon).append($("<span>").text("Xóa"));

                        buttonContainer.append(deleteBtn);
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
                        const recordID = e.key ?? e.data?.["MeetID"];
                        if (!recordID) return;
                        window.currentClicked_Grid_MeetingCRM = recordID;
                        window.currentRecordID_MeetID = recordID;
                        openDetailMeetID?.(rowDataObject);
                    }
                    return; // Không xử lý các column khác khi có multi select
                }

                const rowDataObject = e.data;

                const recordID = e.key ?? e.data?.["MeetID"];
                if (!recordID) return;
                window.currentClicked_Grid_MeetingCRM = recordID;
                window.currentRecordID_MeetID = recordID;
                openDetailMeetID?.(rowDataObject);
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
                    timers[gridName] = setTimeout(function () {
                        chooser.save(InstanceGrid_MeetingCRMP05D3499250FE4F37B3E7BC0C1605115F, gridName);
                    }, 400);
                }
            }

        }).dxDataGrid("instance");

        // Load saved column chooser settings after grid init
        chooser.load(InstanceGrid_MeetingCRMP05D3499250FE4F37B3E7BC0C1605115F, gridName);

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
            const primaryKeyField = "MeetID";

            const loginValue = typeof window.UserID !== "undefined"
                ? window.UserID
                : (typeof LoginID !== "undefined" ? LoginID : null);
            const languageValue = typeof window.LanguageID !== "undefined"
                ? window.LanguageID
                : (typeof LanguageID !== "undefined" ? LanguageID : null);

            const snapshotGridData = function (instance) {
                if (!instance) return [];
                try {
                    if (typeof instance.getDataSource === "function") {
                        const ds = instance.getDataSource();
                        if (ds && typeof ds.items === "function") {
                            const dsItems = ds.items();
                            if (Array.isArray(dsItems)) {
                                return dsItems.map(function (item) {
                                    return item && typeof item === "object" ? Object.assign({}, item) : item;
                                });
                            }
                        }
                    }

                    if (typeof instance.option === "function") {
                        const rawData = instance.option("dataSource");
                        if (Array.isArray(rawData)) {
                            return rawData.map(function (item) {
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
                        ? function (candidate) { return candidate === keyValue; }
                        : function (candidate) {
                            if (candidate === undefined || candidate === null) return candidate === keyValue;
                            if (keyValue === undefined || keyValue === null) return false;
                            return String(candidate) === String(keyValue);
                        };

                    const nextData = Array.isArray(this.data) ? this.data.slice() : [];
                    let targetIndex = nextData.findIndex(function (item) {
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
                sharedEntry.removeRow = function (options) {
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

                    const filtered = (Array.isArray(this.data) ? this.data : []).filter(function (item) {
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

            sharedEntry.instance = InstanceGrid_MeetingCRMP05D3499250FE4F37B3E7BC0C1605115F;

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

            window.hpaSharedGridDataSources[sharedKey] = sharedEntry;
        })();

        function configureMeetingGridToolbar() {
            if (IsloadFilter) return; // Already configured, skip
            const gridInstance = InstanceGrid_MeetingCRMP05D3499250FE4F37B3E7BC0C1605115F;
            if (gridInstance) {
                IsloadFilter = true; // Mark as configured

                // Create clean items array without duplicating existingItems
                const newItems = [
                    {
                        location: "before",
                        template: function (data, index, element) {
                            $("#Grid_MeetingCRM .ms-filter-toolbar").not(element).remove();
                            $(element).empty();

                            // 1 HÀNG DUY NHẤT: Bố trí ngang hàng toàn bộ bộ lọc
                            const $container = $(''<div class="ms-filter-toolbar" style="display: flex; align-items: center; width: 100%; box-sizing: border-box;">'');

                            const $filterRow = $(''<div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap; width: 100%;">'');

                            // 1. Bộ lọc Nhân viên
                            let $employeeDiv;
                            if (window.EmployeeID_Login) {
                                $employeeDiv = $(''<div style="display: flex; align-items: center; gap: 5px; min-width: 160px;">'');
                                $employeeDiv.append(''<label style="font-size: 11px; color: #adb5bd; white-space: nowrap;">Nhân viên:</label>'');
                                $employeeDiv.append($(''<div id="meetingFilterEmployeeToolbar" style="width: 160px;"></div>''));
                                $filterRow.append($employeeDiv);
                            }

                            // 2. Bộ lọc Ngày: Từ ngày - Đến ngày
                            const $dateContainer = $(''<div style="display: flex; gap: 8px; align-items: center;">'');

                            const $fromDiv = $(''<div style="display: flex; align-items: center; gap: 5px; min-width: 120px;">'');
                            $fromDiv.append(''<label style="font-size: 11px; color: #adb5bd; white-space: nowrap;">Từ :</label>'');
                            $fromDiv.append(''<input type="date" id="toolbarMsFilterFromDate" style="padding: 5px 8px; border: 1px solid #495057; border-radius: 4px; font-size: 12px; width: 130px; background-color: #2b3035; color: #e9ecef;">'');

                            const $toDiv = $(''<div style="display: flex; align-items: center; gap: 5px; min-width: 120px;">'');
                            $toDiv.append(''<label style="font-size: 11px; color: #adb5bd; white-space: nowrap;">Đến :</label>'');
                            $toDiv.append(''<input type="date" id="toolbarMsFilterToDate" style="padding: 5px 8px; border: 1px solid #495057; border-radius: 4px; font-size: 12px; width: 130px; background-color: #2b3035; color: #e9ecef;">'');

                            $dateContainer.append($fromDiv, $toDiv);
                            $filterRow.append($dateContainer);

                            // 3. Nút Làm mới
                            const $actionButtonContainer = $(''<div style="display: flex; gap: 5px; align-items: center;">'');
                            const $filterBtn = $(''<button class="btn btn-success" style="padding: 5px 12px; color: white; border: none; border-radius: 4px; font-size: 12px; cursor: pointer; white-space: nowrap;"><i class="bi bi-funnel"></i> Làm mới</button>'');
                            $filterBtn.on(''click'', toolbarFilterMS);

                            const $resetBtn = $(''<button class="d-none btn btn-outline-success" style="border: 1px solid #198754; color: #198754; padding: 5px 12px; font-size: 12px; cursor: pointer; white-space: nowrap;"><i class="bi bi-arrow-clockwise"></i> Làm mới</button>'');
                            $resetBtn.on(''click'', toolbarResetFilterMS);

                            $actionButtonContainer.append($filterBtn, $resetBtn);
                            $filterRow.append($actionButtonContainer);

                            // 4. Checkbox "Xem tất cả ngày" và "Chỉ xem của tôi" - Ngang hàng trực tiếp
                            const $checkboxRow = $(''<div style="display: flex; align-items: center; gap: 12px; margin-left: 4px;">'');

                            const $viewAllWrapper = $(''<div style="display: flex; align-items: center; gap: 5px;">'');
                            $viewAllWrapper.append(''<input type="checkbox" id="toolbarMsFilterViewAll" style="width: 15px; height: 15px; cursor: pointer; accent-color: #198754;">'');
                            $viewAllWrapper.append(''<label for="toolbarMsFilterViewAll" style="font-size: 11px; color: #adb5bd; white-space: nowrap; cursor: pointer; margin: 0;">%ViewAllDays%</label>'');
                            $checkboxRow.append($viewAllWrapper);

                            if (window.EmployeeID_Login) {
                                const $myDataWrapper = $(''<div style="display: flex; align-items: center; gap: 5px;">'');
                                $myDataWrapper.append(''<input type="checkbox" id="toolbarMsFilterMyData" style="width: 15px; height: 15px; cursor: pointer; accent-color: #198754;">'');
                                $myDataWrapper.append(''<label for="toolbarMsFilterMyData" style="font-size: 11px; color: #adb5bd; white-space: nowrap; cursor: pointer; margin: 0;">Chỉ xem của tôi</label>'');
                                $checkboxRow.append($myDataWrapper);
                            }

                            // Toggle when "View All" changes
                            $checkboxRow.find(''#toolbarMsFilterViewAll'').on(''change'', function () {
                                const checked = $(this).is('':checked'');
                                $fromDiv.find(''input'').prop(''disabled'', checked);
                                $toDiv.find(''input'').prop(''disabled'', checked);
                                $fromDiv.css(''opacity'', checked ? ''0.4'' : ''1'');
                                $toDiv.css(''opacity'', checked ? ''0.4'' : ''1'');
                                toolbarFilterMS();
                            });

                            // Toggle when "My Data" changes
                            $checkboxRow.find(''#toolbarMsFilterMyData'').on(''change'', function () {
                                const checked = $(this).is('':checked'');
                                if (checked) {
                                    if (typeof InstanceEmployeeIDPE4B749C9E22149ED91266A5C6444354E !== ''undefined'') {
                                        InstanceEmployeeIDPE4B749C9E22149ED91266A5C6444354E.option(''value'', window.EmployeeID_Login);
                                    }
                                } else {
                                    if (typeof InstanceEmployeeIDPE4B749C9E22149ED91266A5C6444354E !== ''undefined'') {
                                        InstanceEmployeeIDPE4B749C9E22149ED91266A5C6444354E.option(''value'', null);
                                    }
                                }
                                toolbarFilterMS();
                            });

                            $filterRow.append($checkboxRow);
                            $container.append($filterRow);
                            $(element).empty().append($container);

                            // Initialize default dates
                            setTimeout(() => {
                                let fromDate, toDate;

                                if (window.FromDateKPI && window.ToDateKPI) {
                                    fromDate = window.FromDateKPI;
                                    toDate = window.ToDateKPI;
                                    if (typeof InstanceEmployeeIDPE4B749C9E22149ED91266A5C6444354E !== ''undefined'') {
                                        InstanceEmployeeIDPE4B749C9E22149ED91266A5C6444354E.option(''value'', window.EmployeeIDsKPI);
                                    }
                                    $(''#toolbarMsFilterViewAll'').prop(''checked'', false);
                                } else {
                                    const today = new Date();
                                    $(''#toolbarMsFilterViewAll'').prop(''checked'', true);
                                    let checked = $(''#toolbarMsFilterViewAll'').is('':checked'');
                                    $fromDiv.find(''input'').prop(''disabled'', checked);
                                    $toDiv.find(''input'').prop(''disabled'', checked);
                                    $fromDiv.css(''opacity'', checked ? ''0.4'' : ''1'');
                                    $toDiv.css(''opacity'', checked ? ''0.4'' : ''1'');

                                    const startOfWeek = new Date(today);
                                    const dayOfWeek = today.getDay();
                                    const daysFromMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1;
                                    startOfWeek.setDate(today.getDate() - daysFromMonday);

                                    const formatLocalDate = (date) => {
                                        const year = date.getFullYear();
                                        const month = String(date.getMonth() + 1).padStart(2, ''0'');
                                        const day = String(date.getDate()).padStart(2, ''0'');
                                        return `${year}-${month}-${day}`;
                                    };

                                    fromDate = formatLocalDate(startOfWeek);
                                    toDate = formatLocalDate(today);
                                }

                                $(''#toolbarMsFilterFromDate'').val(fromDate);
                                $(''#toolbarMsFilterToDate'').val(toDate);

                                // Move employee filter to toolbar
                                if (window.EmployeeID_Login) {
                                    setTimeout(() => {
                                        const employeeFilterWrapper = document.getElementById("meetingFilterEmployeeToolbar");
                                        if (employeeFilterWrapper && employeeFilterWrapper.children.length === 0) {
                                            const originalEmployee = document.getElementById("PE4B749C9E22149ED91266A5C6444354E");
                                            if (originalEmployee && originalEmployee.parentElement) {
                                                const employeeDiv = originalEmployee.parentElement.querySelector(''div'');
                                                if (employeeDiv) {
                                                    employeeFilterWrapper.appendChild(employeeDiv);
                                                }
                                            }
                                        }
                                    }, 300);
                                }
                            }, 100);

                            return $container;
                        }
                    },
                    {
                        location: "after",
                        template: function (data, index, element) {
                            $("#Grid_MeetingCRM .ms-toolbar-right-group").not(element).remove();
                            $(element).empty();

                            const $rightGroup = $(''<div class="ms-toolbar-right-group" style="display: flex; align-items: center; gap: 8px; height: 100%;">'');

                            // 1. Ô Tìm kiếm nội dung
                            const $searchContainer = $(''<div style="width: 200px;"></div>'');
                            $searchContainer.dxTextBox({
                                placeholder: "Tìm kiếm theo nội dung...",
                                mode: "search",
                                width: 200,
                                value: gridInstance.option("searchPanel.text") || "",
                                onValueChanged: function (e) {
                                    gridInstance.option("searchPanel.text", e.value || "");
                                }
                            });

                            // 2. Nút Chọn cột hiển thị (Neo popup ngay bên dưới nút)
                            const $colBtn = $(''<div class="btn-columnchooser-toolbar"></div>'').dxButton({
                                icon: "columnchooser",
                                hint: "Chọn cột hiển thị",
                                onClick: function (e) {
                                    gridInstance.option("columnChooser.position", {
                                        my: "right top",
                                        at: "right bottom",
                                        of: e.element,
                                        collision: "fit flip"
                                    });
                                    gridInstance.showColumnChooser();
                                }
                            });

                            // 3. Nút Tạo cuộc họp mới
                            const $createBtn = $(''<button type="button" class="btn btn-success btn-create-meeting-toolbar" style="display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px; font-size: 13px; font-weight: 500; border-radius: 4px; white-space: nowrap; height: 34px; cursor: pointer; border: none; background-color: #198754; color: #fff;"><i class="bi bi-plus-circle"></i> Tạo cuộc họp mới</button>'');
                            $createBtn.on(''click'', function () {
                                openMeetingModal();
                            });

                            $rightGroup.append($searchContainer, $colBtn, $createBtn);
                            $(element).append($rightGroup);
                            return $rightGroup;
                        }
                    }
                ];

                gridInstance.option("toolbar", {
                    items: newItems
                });
            }
        }

        // Toolbar-specific filter functions
        function toolbarFilterMS() {
            const fromDate = $(''#toolbarMsFilterFromDate'').val();
            const toDate = $(''#toolbarMsFilterToDate'').val();

            // Get employee filter value from toolbar
            let employeeSelect = '''';
            try {
                const toolbarEmployeeFilter = $(''#toolbarEmployeeFilter'');
                if (toolbarEmployeeFilter.length > 0) {
                    employeeSelect = toolbarEmployeeFilter.val() || '''';
                } else if (typeof InstanceEmployeeIDPE4B749C9E22149ED91266A5C6444354E !== ''undefined'') {
                    employeeSelect = InstanceEmployeeIDPE4B749C9E22149ED91266A5C6444354E.getValueAsString();
                }
            } catch (e) {

            }

            if (!fromDate || !toDate) {
                uiManager.showAlert({ type: "warning", message: "Vui lòng chọn cả hai ngày!" });
                return;
            }

            if (fromDate > toDate) {
                uiManager.showAlert({ type: "warning", message: "Ngày bắt đầu phải nhỏ hơn ngày kết thúc!" });
                return;
            }

            ReloadData(fromDate, toDate, employeeSelect);
        }

        function toolbarResetFilterMS() {
            let fromDateStr, toDateStr;

            // Check if FromDateKPI and ToDateKPI exist
            if (window.FromDateKPI && window.ToDateKPI) {
                fromDateStr = window.FromDateKPI;
                toDateStr = window.ToDateKPI;
            } else {
                // Default: current week (Monday to today)
                const today = new Date();

                // Get start of current week (Monday)
                const startOfWeek = new Date(today);
                const dayOfWeek = today.getDay(); // 0 = Sunday, 1 = Monday, ...
                const daysFromMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1; // Convert Sunday to 6, others to dayOfWeek - 1
                startOfWeek.setDate(today.getDate() - daysFromMonday);

                const formatLocalDate = (date) => {
                    const year = date.getFullYear();
                    const month = String(date.getMonth() + 1).padStart(2, ''0'');
                    const day = String(date.getDate()).padStart(2, ''0'');
                    return `${year}-${month}-${day}`;
                };

                fromDateStr = formatLocalDate(startOfWeek);
                toDateStr = formatLocalDate(today);
            }

            $(''#toolbarMsFilterFromDate'').val(fromDateStr).prop(''disabled'', false).css(''opacity'', ''1'');
            $(''#toolbarMsFilterToDate'').val(toDateStr).prop(''disabled'', false).css(''opacity'', ''1'');

            // Reset checkboxes
            $(''#toolbarMsFilterViewAll'').prop(''checked'', false);
            $(''#toolbarMsFilterMyData'').prop(''checked'', false);

            // Reset date input containers opacity
            $(''#toolbarMsFilterFromDate'').parent().css(''opacity'', ''1'');
            $(''#toolbarMsFilterToDate'').parent().css(''opacity'', ''1'');

            // Reset employee filter
            try {
                const toolbarEmployeeFilter = $(''#toolbarEmployeeFilter'');
                if (toolbarEmployeeFilter.length > 0) {
                    toolbarEmployeeFilter.val('''').trigger(''change'');
                } else if (typeof InstanceEmployeeIDPE4B749C9E22149ED91266A5C6444354E !== ''undefined'') {
                    InstanceEmployeeIDPE4B749C9E22149ED91266A5C6444354E.option(''value'', null);
                }
            } catch (e) {

            }

            // Clear global filter variables
            window.FromDateKPI = '''';
            window.ToDateKPI = '''';

            ReloadData(fromDateStr, toDateStr, '''');
        }

        function initMSToolbarFilter() {
            let fromDateStr, toDateStr;

            // Check if FromDateKPI and ToDateKPI are already defined
            if (window.FromDateKPI && window.ToDateKPI) {
                fromDateStr = window.FromDateKPI;
                toDateStr = window.ToDateKPI;
            } else {
                // Default: current week (Monday to today)
                const today = new Date();

                // Get start of current week (Monday)
                const startOfWeek = new Date(today);
                const dayOfWeek = today.getDay(); // 0 = Sunday, 1 = Monday, ...
                const daysFromMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1; // Convert Sunday to 6, others to dayOfWeek - 1
                startOfWeek.setDate(today.getDate() - daysFromMonday);

                const formatLocalDate = (date) => {
                    const year = date.getFullYear();
                    const month = String(date.getMonth() + 1).padStart(2, ''0'');
                    const day = String(date.getDate()).padStart(2, ''0'');
                    return `${year}-${month}-${day}`;
                };

                fromDateStr = formatLocalDate(startOfWeek);
                toDateStr = formatLocalDate(today);
            }

            $(''#toolbarMsFilterFromDate'').val(fromDateStr);
            $(''#toolbarMsFilterToDate'').val(toDateStr);
        }

        window.currentRecordID_MeetID = null;

        var IsloadFilter = false; // Flag to check if toolbar filter is already configured
        var meetingScheduleList = [];
        var meetingAttendeesList = [];
        var currentEditMeetID = null;
        var msAttendeesList = []; // [{email: string, empId: string}]
        var originalFormData = null; // Lưu trạng thái ban đầu của form khi edit
        var lastRemovedAttendees = []; // Track successfully removed attendees from latest edit operation
        var isSaveSuccessful = false; // Flag to skip confirmation popup when modal closes after successful save
        var isMeetingTimeAutoSyncing = false;

        function normalizeDateTimeValue(value) {
            if (!value) return null;
            const dateValue = value instanceof Date ? new Date(value.getTime()) : new Date(value);
            return Number.isNaN(dateValue.getTime()) ? null : dateValue;
        }

        function handleMeetStartValueChanged(e) {
            updateReminderDisabledState();

            if (isMeetingTimeAutoSyncing) return;

            const fromDate = normalizeDateTimeValue(e && e.value);
            if (!fromDate) return;

            const toInstance = InstanceMeetEndP823B2119D2694A6C8BC61E67B1D13FAE;
            if (!toInstance) return;

            const currentToDate = normalizeDateTimeValue(toInstance.option(''value''));
            if (currentToDate) return;

            isMeetingTimeAutoSyncing = true;
            try {
                const nextToDate = new Date(fromDate.getTime() + (60 * 60 * 1000));
                toInstance.option(''value'', nextToDate);
            } finally {
                isMeetingTimeAutoSyncing = false;
            }
        }

        function handleMeetEndValueChanged(e) {
            if (isMeetingTimeAutoSyncing) return;

            const toDate = normalizeDateTimeValue(e && e.value);
            if (!toDate) return;

            const fromInstance = InstanceMeetStartPBF27C4AAE68A411FBC22A5ABD308D044;
            if (!fromInstance) return;

            const currentFromDate = normalizeDateTimeValue(fromInstance.option(''value''));
            if (currentFromDate) return;

            isMeetingTimeAutoSyncing = true;
            try {
                const prevFromDate = new Date(toDate.getTime() - (30 * 60 * 1000));
                fromInstance.option(''value'', prevFromDate);
                updateReminderDisabledState();
            } finally {
                isMeetingTimeAutoSyncing = false;
            }
        }

        function bindMeetingTimeAutoSyncHandlers() {
            const fromInstance = InstanceMeetStartPBF27C4AAE68A411FBC22A5ABD308D044;
            const toInstance = InstanceMeetEndP823B2119D2694A6C8BC61E67B1D13FAE;

            if (!fromInstance || !toInstance || typeof fromInstance.on !== ''function'' || typeof toInstance.on !== ''function'') {
                return;
            }

            if (typeof fromInstance.off === ''function'') {
                fromInstance.off(''valueChanged'', handleMeetStartValueChanged);
            }
            if (typeof toInstance.off === ''function'') {
                toInstance.off(''valueChanged'', handleMeetEndValueChanged);
            }

            fromInstance.on(''valueChanged'', handleMeetStartValueChanged);
            toInstance.on(''valueChanged'', handleMeetEndValueChanged);
        }

        function getCurrentUserEmailForMeeting() {
            const myEmpId = window.EmployeeID_Login || '''';
            const myInfo = typeof mailEmployeeList !== ''undefined''
                ? mailEmployeeList.find(e => e.EmployeeID === myEmpId)
                : null;
            return myInfo ? myInfo.Email : (window.UserID || '''');
        }

        const decodeBase64HTML = (base64String) => {
        try {
        if (!base64String) return "";
        const binaryStr = window.atob(base64String.trim());
        const bytes = new Uint8Array(binaryStr.length);
        for (let i = 0; i < binaryStr.length; i++) {
            bytes[i] = binaryStr.charCodeAt(i);
         }
        const decoder = new TextDecoder(''utf-16le'');
        return decoder.decode(bytes);
         } catch (error) {
        console.error("Lỗi giải mã:", error);
        return base64String;
         }
        };

        async function createMeetingWithTaskID(employeeEmail, meetingData, meetID) {
            return new Promise(resolve => {
                const organizerEmployeeID = window.EmployeeID_Login || '''';
                AjaxHPAParadise({
                    data: {
                        name: ''sp_CRMCreateOutlookEvent'',
                        param: [
                            ''MeetingData'', JSON.stringify(meetingData),
                            ''OrganizerEmployeeID'', organizerEmployeeID
                        ]
                    },
                    success: function (data) {
                        try {
                            if (typeof data === ''string'' && data) {
                                const result = JSON.parse(data);

                                if (result.data && result.data[0] && result.data[0].length > 0) {
                                    const row = result.data[0][0];

                                    if (row.Result === ''SUCCESS'') {
                                        console.log(`✅ Event tạo thành công cho MeetID=${meetID}`);
                                        resolve({
                                            id: meetID,
                                            onlineMeeting: row.TeamsUrl ? { joinUrl: row.TeamsUrl } : null
                                        });
                                    } else {
                                        console.error(`❌ Lỗi tạo event cho MeetID=${meetID}:`, row.ErrorMessage || ''Unknown error'');
                                        resolve(null);
                                    }
                                } else {
                                    console.error(`❌ Invalid response format for MeetID=${meetID}`);
                                    resolve(null);
                                }
                            } else {
                                console.error(`❌ Empty response for MeetID=${meetID}`);
                                resolve(null);
                            }
                        } catch (err) {
                            console.error(`❌ Error parsing response for MeetID=${meetID}:`, err);
                            resolve(null);
                        }
                    },
                    error: function (err) {
                        console.error(`❌ Server call failed for MeetID=${meetID}:`, err);
                        resolve(null);
                    }
                });
            });
        }

        async function deleteOutlookEvent(meetID, status) {
            return new Promise(resolve => {
                AjaxHPAParadise({
                    data: {
                        name: ''sp_CRMDeleteOutlookEventByMeetID'',
                        param: [
                            "MeetID", meetID || 0,
                            "Status", status || 0
                        ]
                    },
                    success: function (data) {
                        try {
                            if (typeof data === ''string'' && data) {
                                const result = JSON.parse(data);

                                if (result.data && result.data[0] && result.data[0].length > 0) {
                                    const row = result.data[0][0];

                                    if (row.Result === ''SUCCESS'') {
                                        console.log(`✅ Event xóa thành công cho MeetID=${meetID}`);
                                        resolve(true);
                                    } else {
                                        console.error(`❌ Lỗi xóa event cho MeetID=${meetID}`);
                                        resolve(false);
                                    }
                                } else {
                                    resolve(false);
                                }
                            } else {
                                resolve(false);
                            }
                        } catch (err) {
                            console.error(`❌ Error parsing response for delete:`, err);
                            resolve(false);
                        }
                    },
                    error: function (err) {
                        console.error(`❌ Server call failed for delete:`, err);
                        resolve(false);
                    }
                });
            });
        }

        async function updateOutlookEvent(meetID, meetingData) {
            return new Promise(resolve => {
                AjaxHPAParadise({
                    data: {
                        name: ''sp_CRMUpdateOutlookEventByMeetID'',
                        param: [
                            ''MeetingData'', JSON.stringify(meetingData),
                            ''CalendarID'', 1
                        ]
                    },
                    success: function (data) {
                        try {
                            if (typeof data === ''string'' && data) {
                                const result = JSON.parse(data);

                                if (result.data && result.data[0] && result.data[0].length > 0) {
                                    const row = result.data[0][0];

                                    if (row.Result === ''SUCCESS'') {
                                        console.log(`✅ Event cập nhật thành công cho MeetID=${meetID}`);
                                        resolve(true);
                                    } else {
                                        console.error(`❌ Lỗi cập nhật event cho MeetID=${meetID}`);
                                        resolve(null);
                                    }
                                } else {
                                    resolve(null);
                                }
                            } else {
                                resolve(null);
                            }
                        } catch (err) {
                            console.error(`❌ Error parsing response for update:`, err);
                            resolve(null);
                        }
   },
                    error: function (err) {
                        console.error(`❌ Server call failed for update:`, err);
                        resolve(null);
                    }
                });
            });
        }

        function clearPageCache() {
            _pageCache = {};
        }

        function getGridHeight() {
            const gridEl = InstanceGrid_MeetingCRMP05D3499250FE4F37B3E7BC0C1605115F.element();
            const domElement = gridEl.jquery ? gridEl[0] : gridEl;
            const top = domElement.getBoundingClientRect().top;
            return window.innerHeight - top - 20;
        }

        function ReloadData(fromDate, toDate, employeeSelect = '''', isViewAll = null, keyword = null) {

            _pageCache = {};

            let _currentKeyword = String(
                keyword != null
                    ? keyword
                    : (InstanceGrid_MeetingCRMP05D3499250FE4F37B3E7BC0C1605115F.option("searchPanel.text") || "")
            ).trim();


            dataStore_Grid_MeetingCRM = new DevExpress.data.CustomStore({
                key: "MeetID",
                load: function (loadOptions) {
                    const deferred = $.Deferred();

                    let params = [];

                    // SP nghiệp vụ
                    params.push("@ProcName", "sp_KPIgetScheduleMeeting");

                    // Tham số riêng của sp_KPIgetScheduleMeeting
                    let procParam = "";
                    isViewAll = isViewAll == null ? ($(''#toolbarMsFilterViewAll'').is('':checked'') ? 1 : 0) : isViewAll;
                    const fallbackFrom = $(''#toolbarMsFilterFromDate'').val();
                    const fallbackTo = $(''#toolbarMsFilterToDate'').val();

                    procParam += `@LoginID=${window.UserID}`;
                    procParam += `,@isViewAll=${isViewAll}`;

                    if (!isViewAll) {
                        const effectiveFrom = fromDate || fallbackFrom;
                        const effectiveTo = toDate || fallbackTo;
                        if (effectiveFrom && effectiveTo) {
                            procParam += `,@FromDate=''${effectiveFrom}''`;
                            procParam += `,@ToDate=''${effectiveTo}''`;
                        }
                    }

                    procParam += `,@EmployeeIDs=''${employeeSelect ? employeeSelect : (InstanceEmployeeIDPE4B749C9E22149ED91266A5C6444354E.option(''value'') || '''')}''`;

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
                        : "MeetStart DESC"; // này cho mặc định. tự chỉnh theo menu mỗi người

                    params.push("@Sort", "ORDER BY " + sort);

                    // Search
                    if (_currentKeyword) {
                        params.push("@SearchValue", _currentKeyword);
                        params.push("@ColumnSearch", "Title,MeetStart,MeetEnd,Attendees,Location");
                    }

                    // Filter
                    if (loadOptions.filter) {
                        // Kiểm tra filter item có phải function không
                        const isJSFunction = (item) => typeof item === ''function'';

                        const hasFunction = JSON.stringify(loadOptions.filter, (key, val) => {
                            if (typeof val === ''function'') return ''FUNCTION'';
                   return val;
                        }).includes(''FUNCTION'');

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
                        let selectGroup = "", groupBy = "GROUP BY ";
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
                            const results = Array.isArray(json?.data?.[0]) ? json.data[0] : [];

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
                            meetingScheduleList = results;
                            deferred.resolve(result);
                        },
                        error: function (err) {
                            deferred.reject("Data Loading Error");
                        }
                    });

                    return deferred.promise();
                }
            });

            // Gán store vào grid để kích hoạt load
            const gridInstance = InstanceGrid_MeetingCRMP05D3499250FE4F37B3E7BC0C1605115F;
            if (!IsloadFilter) {
       setTimeout(() => {
                    configureMeetingGridToolbar();
                }, 50);
            }
            gridInstance.beginUpdate();
            gridInstance.option("remoteOperations", {
                paging: true,
                filtering: true,
                sorting: true,
                searching: true
            });

            // scroll
            gridInstance.option("scrolling.mode", "infinite");
            gridInstance.option("scrolling.rowRenderingMode", "virtual");
            gridInstance.option("scrolling.preloadEnabled", false);

            gridInstance.option("paging.enabled", true);
            gridInstance.option("paging.pageSize", 50);
            gridInstance.option("pager.visible", false);
            gridInstance.option("pager.allowedPageSizes", [50]);
            gridInstance.option("searchPanel.highlightSearchText", false);
            gridInstance.option("dataSource", dataStore_Grid_MeetingCRM);
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



        // function renderMeetingScheduleTable(data) {
        //     const $tbody = $(''#meetingScheduleTableBody'');
        //     $tbody.empty();

        //     const displayList = data || meetingScheduleList;
        //     displayList.forEach((item, index) => {
        //         const startDate = item.MeetStart ? new Date(item.MeetStart).toLocaleString(''vi-VN'') : ''N/A'';
        //         const endDate = item.MeetEnd ? new Date(item.MeetEnd).toLocaleString(''vi-VN'') : ''N/A'';

        //         let statusBadge = '''';
        //         if (item.Status == 1) {
        //             statusBadge = ''<span class="status-badge status-success"><i class="bi bi-check-circle-fill"></i> Đã tạo</span>'';
        //         } else if (item.Status == 0) {
        //             statusBadge = ''<span class="status-badge status-pending"><i class="bi bi-hourglass-split"></i> Chờ tạo</span>'';
        //         } else {
        //             statusBadge = ''<span class="status-badge status-failed"><i class="bi bi-x-circle-fill"></i> Thất bại</span>'';
        //         }

        //         const teamsBadge = item.IsMeetingTeams ? ''<span class="teams-badge"><i class="bi bi-microsoft-teams"></i> Teams</span>'' : '''';
        //         const location = item.Location || ''Chưa xác định'';

        //         // Format attendees as badges
        //         const attendeesStr = item.Attendees || '''';
        //         const attendeesList = attendeesStr.split('','').filter(e => e.trim()).map(e => e.trim());

        //         let attendeesHtml = '''';
        //         if (attendeesList.length === 0) {
        //             attendeesHtml = ''<span class="text-muted">Chưa có</span>'';
        //         } else if (attendeesList.length <= 2) {
        //             // Show all badges if 2 or fewer
        //             attendeesHtml = attendeesList.map(email =>
        //                 `<span class="badge bg-light text-dark" style="font-size: 11px; margin-right: 4px; margin-bottom: 4px;">${email}</span>`
        //             ).join('''');
        //         } else {
        //             // Show first 2 + count of remaining

        //             const first2 = attendeesList.slice(0, 2).map(email =>
        // `<span class="badge bg-light text-dark" style="font-size: 11px; margin-right: 4px; margin-bottom: 4px;">${email}</span>`
        //             ).join('''');
        //             const remaining = attendeesList.length - 2;
     //             attendeesHtml = first2 + `<span class="badge bg-secondary" style="font-size: 11px; margin-right: 4px; margin-bottom: 4px;" title="${attendeesList.slice(2).join('', '')}">+${remaining}</span>`;
        //         }

        //         const $row = $(`
        //     <tr onclick="viewMeetingDetail(${item.MeetID})">
        //         <td>${index + 1}</td>
        //         <td>
        //             ${item.Title || ''N/A''} ${teamsBadge}
        //         </td>
        //         <td>${startDate}</td>
        //         <td>${endDate}</td>
        //         <td>
        //             <div style="display: flex; flex-wrap: wrap; gap: 4px; max-width: 300px;">
        //   ${attendeesHtml}
        //             </div>
        //         </td>
        //         <td>${location}</td>
        //         <td>${statusBadge}</td>
        //         <td onclick="event.stopPropagation()">
        //             <button class="btn btn-sm btn-outline-primary" onclick="editMeetingSchedule(${item.MeetID})">
        //                 <i class="bi bi-pencil-square"></i> Sửa
        //             </button>
        //             <button class="btn btn-sm btn-outline-danger" onclick="deleteMeetingSchedule(${item.MeetID})">
        //                 <i class="bi bi-trash"></i> Xóa
        //             </button>
        //      </td>
        //     </tr>
        // `);
        //         $tbody.append($row);
        //     });
        // }

        // Helper function to check if date is in the past
        function isDateInPast(dateTimeString) {
            if (!dateTimeString) return false;
            const selectedDate = new Date(dateTimeString.replace('' '', ''T''));
            const now = new Date();
            return selectedDate < now;
        }

        // Helper function to disable/enable reminder based on date
        function updateReminderDisabledState() {
            const startDateTime = InstanceMeetStartPBF27C4AAE68A411FBC22A5ABD308D044 ? InstanceMeetStartPBF27C4AAE68A411FBC22A5ABD308D044.option(''value'') : null;
            const normalizedStartDate = normalizeDateTimeValue(startDateTime);
            const isInPast = normalizedStartDate ? normalizedStartDate < new Date() : false;

            if (isInPast) {
                $(''#ms_is_remind'').prop(''checked'', false).prop(''disabled'', true);
                $(''#ms_remind_minutes'').prop(''disabled'', true);
            } else {
                $(''#ms_is_remind'').prop(''disabled'', false);
                $(''#ms_remind_minutes'').prop(''disabled'', false);
            }
        }

        function getHTMLinDesciption() {
            let currentHtml = InstanceDescriptionP2ABD553B3460416D8CA937F74E864933?.value;
            let standardHtml = getStandardHtml_DescriptionP2ABD553B3460416D8CA937F74E864933(currentHtml);

            let base64Html = utf16_le_to_b64_DescriptionP2ABD553B3460416D8CA937F74E864933(standardHtml);
            return base64Html;
        }

        function resetMeetingSaveButton() {
            const $saveBtn = $(''#meetingScheduleModal'').find(''button[onclick="saveMeetingSchedule()"]'');
            $saveBtn.prop(''disabled'', false).css(''opacity'', ''1'').css(''cursor'', ''pointer'');
        }

        async function openDetailMeetID(obj) {

            originalFormData = {
                title: $(''#ms_title'').val(),
                location: $(''#ms_location'').val(),
                start: InstanceMeetStartPBF27C4AAE68A411FBC22A5ABD308D044 ? InstanceMeetStartPBF27C4AAE68A411FBC22A5ABD308D044.option(''value'') : null,
                end: InstanceMeetEndP823B2119D2694A6C8BC61E67B1D13FAE ? InstanceMeetEndP823B2119D2694A6C8BC61E67B1D13FAE.option(''value'') : null,
                description: getHTMLinDesciption(),
                isTeams: $(''#ms_is_teams'').is('':checked''),
                isRemind: $(''#ms_is_remind'').is('':checked''),
                remindMinutes: $(''#ms_remind_minutes'').val(),
                attendees: msAttendeesList.map(a => a.email).sort().join('','')
            };

            currentEditMeetID = obj.MeetID;

            // Clear flags and tracking
            lastRemovedAttendees = [];
            isSaveSuccessful = false;

            // const item = meetingScheduleList.find(x => x.MeetID == meetID);
            if (!obj) return;

            $(''#meetingScheduleModalTitle'').text(''Chỉnh sửa cuộc họp'');
            $(''#ms_title'').val(obj.Title || '''');
            $(''#ms_location'').val(obj.Location || '''');
            const decodedDescription = decodeBase64HTML(obj.Description);
            obj.Description = decodedDescription; // ghi đè lại để đoạn loadData bên dưới dùng giá trị đã decode
            '+ (select loadData from tblCommonControlType_Signed where UID = 'PBF27C4AAE68A411FBC22A5ABD308D044')
                + (select loadData from tblCommonControlType_Signed where UID = 'P823B2119D2694A6C8BC61E67B1D13FAE')
            +(select loadData from tblCommonControlType_Signed where UID = 'P2ABD553B3460416D8CA937F74E864933') +N'

            //$(''#ms_description'').val(obj.Description || '''');

            // Set checkbox values and disable if already checked
            const isTeamsChecked = obj.IsMeetingTeams == 1;
            const isRemindChecked = obj.IsRemind == 1;

            $(''#ms_is_teams'').prop(''checked'', isTeamsChecked).prop(''disabled'', isTeamsChecked);
            $(''#ms_is_remind'').prop(''checked'', isRemindChecked).prop(''disabled'', isRemindChecked);
            $(''#ms_remind_minutes'').val(obj.ReminderMinutesBeforeStart || 15);

            // Load attendees for this meeting
            loadMeetingAttendees(currentEditMeetID);

            bindMeetingTimeAutoSyncHandlers();

            // Check if start date is in the past and disable reminder if so
            updateReminderDisabledState();

            // Make sure save button is enabled when opening the edit popup
            resetMeetingSaveButton();

            // Save original form state for change detection
            saveOriginalFormData();

            const myModal = new bootstrap.Modal(document.getElementById(''meetingScheduleModal''));

            // Ensure handlers are bound for edit modal
            setTimeout(() => {
                bindModalCloseHandlers();
            }, 50);

            myModal.show();
        }

        async function openMeetingModal() {
            currentEditMeetID = null;
            msAttendeesList = [];
            originalFormData = null; // Reset for new meeting

            // Clear flags and tracking
            lastRemovedAttendees = [];
            isSaveSuccessful = false;

            // Add current user to attendees by default (as organizer, cannot be removed)
            const myEmpId = window.EmployeeID_Login || '''';
            const myInfo = typeof mailEmployeeList !== ''undefined''
                ? mailEmployeeList.find(e => e.EmployeeID === myEmpId)
                : null;
            const myEmail = myInfo ? myInfo.Email : null;
            if (myEmail) {
                msAttendeesList.push({ email: myEmail, empId: myEmpId, isOrganizer: true });
            } else {
                uiManager.showAlert({ type: "warning", message: "Bạn chưa có Email. Vui lòng thêm mail ở phần thông tin tài khoản!" });
                return
            }

            let obj = {
                title: null,
                location: null,
                start: null,
                end: null,
                description: null,
            };

            $(''#ms_title'').val('''');
            $(''#ms_location'').val('''');
            $(''#ms_is_teams'').prop(''checked'', false).prop(''disabled'', false);
            $(''#ms_is_remind'').prop(''checked'', true).prop(''disabled'', false);

            '+ (select loadData from tblCommonControlType_Signed where UID = 'PBF27C4AAE68A411FBC22A5ABD308D044')
                + (select loadData from tblCommonControlType_Signed where UID = 'P823B2119D2694A6C8BC61E67B1D13FAE')
            +(select loadData from tblCommonControlType_Signed where UID = 'P2ABD553B3460416D8CA937F74E864933') +N'

            $(''#meetingScheduleModalTitle'').text(''Tạo cuộc họp mới'');
            $(''#meetingScheduleForm'')[0].reset();

            renderMSAttendeeTags();

            // Set default values
            const now = new Date();
            const tomorrow = new Date(now);
            tomorrow.setDate(now.getDate() + 1);
            tomorrow.setHours(9, 0, 0, 0);

            const endTime = new Date(tomorrow);
            endTime.setHours(10, 0, 0, 0);

            $(''#ms_remind_minutes'').val(15);

            // Make sure save button is enabled when opening the create popup
            resetMeetingSaveButton();

            bindMeetingTimeAutoSyncHandlers();
            updateReminderDisabledState();

            const myModal = new bootstrap.Modal(document.getElementById(''meetingScheduleModal''));

            // Ensure handlers are bound for new meeting modal
            setTimeout(() => {
                bindModalCloseHandlers();
            }, 50);

            myModal.show();
        }

        // Unified modal close handler with showConfirmPopup
        function handleModalClose(e) {
            e.preventDefault();
            e.stopPropagation();

            // Skip confirmation popup if modal is closing after successful save
            if (isSaveSuccessful) {
                isSaveSuccessful = false; // Reset flag
                originalFormData = null;
                closeModal();
                return;
            }

            if (currentEditMeetID && hasFormChanged()) {
                showConfirmPopup({
                    title: "Hủy bỏ thay đổi",
                    message: "Bạn có chắc chắn muốn hủy bỏ các thay đổi này?",
                    YesText: "Có",
                    NoText: "Không",
                    onYes: () => {
                        originalFormData = null;
                        closeModal();
                    },
                    onNo: () => {
                        // User chose to stay, do nothing
                    }
                });
            } else {
                // No changes or new meeting, close immediately
                originalFormData = null;
                closeModal();
            }
        }

        // Close modal utility function
        function closeModal() {
            const modalEl = document.getElementById(''meetingScheduleModal'');
            const modalInstance = bootstrap.Modal.getInstance(modalEl);
            if (modalInstance) {
                // Remove handlers before closing to prevent event loops
                unbindModalCloseHandlers();
                modalInstance.hide();
                // Re-bind handlers after a short delay for next use
                setTimeout(() => {
                    bindModalCloseHandlers();
                }, 300);
            }
        }

        // Bind modal close event handlers
        function bindModalCloseHandlers() {
            // Handle X button click
            $(''#meetingScheduleModal .btn-close'').off(''click.modalClose'').on(''click.modalClose'', function (e) {
                $(this).data(''handled'', true);
                handleModalClose(e);
            });

            // Handle Cancel button click
            $(''#cancelMeetingBtn'').off(''click.modalClose'').on(''click.modalClose'', function (e) {
                $(this).data(''handled'', true);
                handleModalClose(e);
            });

            // Handle backdrop click and ESC key
            $(''#meetingScheduleModal'').off(''hide.bs.modal.modalClose'').on(''hide.bs.modal.modalClose'', handleModalClose);
        }

        // Remove modal close event handlers
        function unbindModalCloseHandlers() {
            $(''#meetingScheduleModal .btn-close'').off(''click.modalClose'').removeData(''handled'');
            $(''#cancelMeetingBtn'').off(''click.modalClose'').removeData(''handled'');
            $(''#meetingScheduleModal'').off(''hide.bs.modal.modalClose'');
        }

        function loadMeetingAttendees(meetID) {
            const item = meetingScheduleList.find(x => x.MeetID == meetID);
            if (!item) return;

            // Attendees already loaded in Attendees field from sp_KPIgetScheduleMeeting
            const attendeesStr = item.Attendees || '''';
            msAttendeesList = attendeesStr.split('','').filter(e => e.trim()).map(email => {
                const trimmedEmail = email.trim();
                return {
                    email: trimmedEmail,
                    empId: '''',
                    isOrganizer: trimmedEmail === item.OrganizerEmail // Mark organizer based on OrganizerEmail field
                };
            });
            renderMSAttendeeTags();
        }

        // Save original form data for change detection
        function saveOriginalFormData() {
            originalFormData = {
                title: $(''#ms_title'').val(),
                location: $(''#ms_location'').val(),
                start: InstanceMeetStartPBF27C4AAE68A411FBC22A5ABD308D044 ? InstanceMeetStartPBF27C4AAE68A411FBC22A5ABD308D044.option(''value'') : null,
                end: InstanceMeetEndP823B2119D2694A6C8BC61E67B1D13FAE ? InstanceMeetEndP823B2119D2694A6C8BC61E67B1D13FAE.option(''value'') : null,
                description: getHTMLinDesciption(),
                isTeams: $(''#ms_is_teams'').is('':checked''),
                isRemind: $(''#ms_is_remind'').is('':checked''),
                remindMinutes: $(''#ms_remind_minutes'').val(),
                attendees: msAttendeesList.map(a => a.email).sort().join('','')
            };
        }

        // Check if form has changes
        function hasFormChanged() {
            if (!originalFormData || !currentEditMeetID) return false;

            const currentData = {
                title: $(''#ms_title'').val(),
                description: getHTMLinDesciption(),
                isTeams: $(''#ms_is_teams'').is('':checked''),
                isRemind: $(''#ms_is_remind'').is('':checked''),
                location: $(''#ms_location'').val(),
                start: InstanceMeetStartPBF27C4AAE68A411FBC22A5ABD308D044 ? InstanceMeetStartPBF27C4AAE68A411FBC22A5ABD308D044.option(''value'') : null,
                end: InstanceMeetEndP823B2119D2694A6C8BC61E67B1D13FAE ? InstanceMeetEndP823B2119D2694A6C8BC61E67B1D13FAE.option(''value'') : null,
                remindMinutes: $(''#ms_remind_minutes'').val(),
                attendees: msAttendeesList.map(a => a.email).sort().join('','')
            };

            // So sánh từng field một cách chính xác
            const fieldsToCompare = [''title'', ''description'', ''isTeams'', ''isRemind'', ''location'', ''remindMinutes'', ''attendees''];

            // So sánh các field cơ bản
            for (const field of fieldsToCompare) {
                if (currentData[field] !== originalFormData[field]) {
                    return true;
                }
            }

            // So sánh Date objects đặc biệt
            const normalizeDate = (date) => {
                if (!date) return null;
                return new Date(date).getTime(); // Convert to timestamp
            };

            if (normalizeDate(currentData.start) !== normalizeDate(originalFormData.start)) {
                return true;
            }

            if (normalizeDate(currentData.end) !== normalizeDate(originalFormData.end)) {
                return true;
            }

            return false;
        }

        function viewMeetingDetail(item) {
            //const item = meetingScheduleList.find(x => x.MeetID == meetID);
            if (!item) return;

            const startDate = item.MeetStart ? new Date(item.MeetStart).toLocaleString(''vi-VN'') : ''N/A'';
            const endDate = item.MeetEnd ? new Date(item.MeetEnd).toLocaleString(''vi-VN'') : ''N/A'';

            let statusText = '''';
            if (item.Status == 1) statusText = ''✓ Đã tạo'';
            else if (item.Status == 0) statusText = ''⏳ Đang tạo'';
            else statusText = ''✗ Tạo thất bại'';

            const teamsInfo = item.IsMeetingTeams
                ? `<p><strong><i class="bi bi-microsoft-teams"></i> Teams Meeting:</strong> <a href="${item.TeamsMeetingUrl || ''#''}" target="_blank" class="btn btn-sm btn-primary"><i class="bi bi-box-arrow-up-right"></i> Join Meeting</a></p>`
                : '''';

            // Format attendees as badges
            const attendeesStr = item.Attendees || '''';
            const attendeesList = attendeesStr.split('','').filter(e => e.trim()).map(e => e.trim());

            let attendeesHtml = '''';
            if (attendeesList.length === 0) {
                attendeesHtml = ''<span class="text-muted">Chưa có</span>'';
            } else {
                attendeesHtml = attendeesList.map(email =>
                    `<span class="badge bg-light text-dark" style="font-size: 12px; margin-right: 6px; margin-bottom: 6px; padding: 6px 12px;">${email}</span>`
                ).join('''');
            }
            const decodedDesc = decodeBase64HTML(item.Description) || ''Không có mô tả'';
         
            const html = `
            <p><strong><i class="bi bi-card-heading"></i> Tiêu đề:</strong> ${item.Title || ''N/A''}</p>
            <p><strong><i class="bi bi-geo-alt"></i> Địa điểm:</strong> ${item.Location || ''Chưa xác định''}</p>
            <p><strong><i class="bi bi-calendar-check"></i> Bắt đầu:</strong> ${startDate}</p>
            <p><strong><i class="bi bi-calendar-x"></i> Kết thúc:</strong> ${endDate}</p>
            <p><strong><i class="bi bi-person-circle"></i> Người tổ chức:</strong> ${item.OrganizerEmail || ''N/A''}</p>
            <p><strong><i class="bi bi-people"></i> Người tham dự:</strong></p>
            <div style="display: flex; flex-wrap: wrap; gap: 6px; margin-left: 20px; margin-bottom: 12px;">
                ${attendeesHtml}
            </div>
            ${teamsInfo}
            <p><strong><i class="bi bi-file-text"></i> Nội dung:</strong></p>
            
            <p style="white-space: pre-wrap; padding: 10px; background: #f8f9fa; border-radius: 8px;">${decodedDesc}</p>
            <p><strong><i class="bi bi-bell"></i> Nhắc nhở:</strong> ${item.IsRemind ? `Có (Trước ${item.ReminderMinutesBeforeStart} phút )` : ''Không''}</p>
            <p><strong><i class="bi bi-info-circle"></i> Trạng thái:</strong> ${statusText}</p>
            <p><strong><i class="bi bi-hash"></i> MeetID:</strong> ${item.MeetID}</p>
            `;

            $(''#meetingDetailBody'').html(html);
            const myModal = new bootstrap.Modal(document.getElementById(''meetingDetailModal''));
            myModal.show();
        }

        // New wrapper function to check changes before saving

        async function handleSaveMeetingSchedule() {
            // For new meetings, always save
            if (!currentEditMeetID) {
                await saveMeetingSchedule();
                return;
            }

            // For edit meetings, check if there are changes
            if (hasFormChanged()) {
                await saveMeetingSchedule();
            } else {

                // Mark as save successful to skip confirmation popup (even though no save needed)
                isSaveSuccessful = true;

                const modalEl = document.getElementById(''meetingScheduleModal'');
                let instance = bootstrap.Modal.getInstance(modalEl);
                if (!instance) instance = new bootstrap.Modal(modalEl);
                instance.hide();
            }
        }

        async function saveMeetingSchedule() {
            // Disable save button to prevent multiple submissions
            const $saveBtn = $(''#meetingScheduleModal'').find(''button[onclick="saveMeetingSchedule()"]'');
            $saveBtn.prop(''disabled'', true).css(''opacity'', ''0.6'').css(''cursor'', ''not-allowed'');

            let Title = $(''#ms_title'').val().trim();
            if (!Title) {
                uiManager.showAlert({ type: "warning", message: "Vui lòng nhập tiêu đề cuộc họp!" });
                $saveBtn.prop(''disabled'', false).css(''opacity'', ''1'').css(''cursor'', ''pointer'');
                return;
            }
            let MeetStart = InstanceMeetStartPBF27C4AAE68A411FBC22A5ABD308D044 ? InstanceMeetStartPBF27C4AAE68A411FBC22A5ABD308D044.option(''value'') : null;
            let MeetEnd = InstanceMeetEndP823B2119D2694A6C8BC61E67B1D13FAE ? InstanceMeetEndP823B2119D2694A6C8BC61E67B1D13FAE.option(''value'') : null;
            if (!MeetStart || !MeetEnd) {
                uiManager.showAlert({ type: "warning", message: "Vui lòng chọn thời gian bắt đầu và kết thúc!" });
                $saveBtn.prop(''disabled'', false).css(''opacity'', ''1'').css(''cursor'', ''pointer'');
                return;
            }

            // 1. Collect form data
            const formData = {
                Title: $(''#ms_title'').val(),
                Description: getHTMLinDesciption(),
                Location: $(''#ms_location'').val(),
                MeetStart: InstanceMeetStartPBF27C4AAE68A411FBC22A5ABD308D044 ? InstanceMeetStartPBF27C4AAE68A411FBC22A5ABD308D044.option(''value'') : null,
                MeetEnd: InstanceMeetEndP823B2119D2694A6C8BC61E67B1D13FAE ? InstanceMeetEndP823B2119D2694A6C8BC61E67B1D13FAE.option(''value'') : null,
                IsMeetingTeams: $(''#ms_is_teams'').is('':checked'') ? 1 : 0,
                IsRemind: $(''#ms_is_remind'').is('':checked'') ? 1 : 0,
                ReminderMinutesBeforeStart: parseInt($(''#ms_remind_minutes'').val()) || 0
            };

            // 2. Separate internal vs external attendees
            const allAttendees = msAttendeesList; // [{email, empId}]
            const internalAttendees = allAttendees.filter(a => a.empId && a.empId.trim() !== '''');

            // 3. Generate MeetID
            const employeeID = parseInt(window.EmployeeID_Login || window.UserID) || 0;
            const meetID = currentEditMeetID || ((Date.now() * 1000) + employeeID);

            // 4. Determine current organizer email
            let organizerEmail = '''';
            let createSuccess = false;

            if (!currentEditMeetID) {
                // 5. Save to Database first with Status = 0 (pending)
                const dbData = {
                    MeetID: meetID,
                    Title: formData.Title,
                    Description: formData.Description,
                    MeetStart: formData.MeetStart,
                    MeetEnd: formData.MeetEnd,
                    Location: formData.Location,
                    IsMeetingTeams: formData.IsMeetingTeams,
                    IsRemind: formData.IsRemind,
                    ReminderMinutesBeforeStart: parseInt(formData.ReminderMinutesBeforeStart) || 0,
                    TeamsMeetingUrl: '''',
                    OrganizerEmail: '''',
                    Status: 0,
                    EmployeeID: window.EmployeeID_Login,
                };

                // 5.1. Save attendees
                // if (allAttendees.length > 0) {
                //     const attendeesData = allAttendees.map(att => ({
                //         MeetID: meetID,
                //         AttendeeEmail: att.email
                //     }));
                // }

                organizerEmail = getCurrentUserEmailForMeeting();
                if (!organizerEmail) {
                    uiManager.showAlert({ type: "warning", message: "Không tìm thấy email người tạo cuộc họp!" });
                    $saveBtn.prop(''disabled'', false).css(''opacity'', ''1'').css(''cursor'', ''pointer'');
                    return;
                }

                dbData.OrganizerEmail = organizerEmail;

                const organizerMeetingData = {
                    ...dbData,
                    attendees: allAttendees.filter(a => a.email !== organizerEmail).map(a => a.email).join('','')
                };
                const organizerEvent = await createMeetingWithTaskID(organizerEmail, organizerMeetingData, meetID);

                if (organizerEvent) {
                    createSuccess = true;
                }

                if (createSuccess) {
                    uiManager.showAlert({ type: "success", message: "Cuộc họp đã được tạo thành công trên Outlook!" });
                } else {
                    uiManager.showAlert({ type: "error", message: "Tạo cuộc họp trên Outlook thất bại!" });
                }

            } else {
                const item = meetingScheduleList.find(x => x.MeetID == meetID);

                if (!item) {
                    uiManager.showAlert({ type: "error", message: "Không tìm thấy cuộc họp!" });
                    $saveBtn.prop(''disabled'', false).css(''opacity'', ''1'').css(''cursor'', ''pointer'');
                    return;
                }

                // Get original attendees list for comparison
                let originalAttendees = [];
                if (originalFormData && originalFormData.attendees) {
                    originalAttendees = originalFormData.attendees.split('','').map(email => email.trim()).filter(email => email !== '''');
                }

                // Get current attendees list
                const currentAttendees = msAttendeesList.map(a => a.email.trim());

                // Find removed attendees (those who were in original but not in current)
                const removedAttendees = originalAttendees.filter(email => !currentAttendees.includes(email));

                if (item.Status == 1 && item.OrganizerEmail) {
                    const updateMeetingData = {
                        ...formData,
                        attendees: removedAttendees.length > 0
                            ? currentAttendees.filter(email => email !== item.OrganizerEmail).join('','')
                            : msAttendeesList.filter(a => a.email !== item.OrganizerEmail).map(a => a.email).join('',''),
                        MeetID: meetID
                    };

                    try {
                        const updateResult = await updateOutlookEvent(meetID, updateMeetingData);

                        if (updateResult) {
                            if (removedAttendees.length > 0) {
                                uiManager.showAlert({ type: "success", message: `Cuộc họp đã được cập nhật thành công! Đã hủy lịch cho ${removedAttendees.length} người tham dự bị remove.` });
                            } else {
                                uiManager.showAlert({ type: "success", message: "Cuộc họp đã được cập nhật thành công trên cả hệ thống và Outlook!" });
                            }
                        } else {
                            uiManager.showAlert({
                                type: "error", message: removedAttendees.length > 0
                                    ? "Xóa thất bại!"
                                    : "Cuộc họp đã được cập nhật trong hệ thống nhưng không thể cập nhật trên Outlook."
                            });
                        }
                    } catch (error) {

                    }
                } else {
                    uiManager.showAlert({ type: "success", message: "Cuộc họp đã được cập nhật thành công!" });
                }
            }

            // Mark as save successful to skip confirmation popup
            isSaveSuccessful = true;

            const modalEl = document.getElementById(''meetingScheduleModal'');
            let instance = bootstrap.Modal.getInstance(modalEl);
            if (!instance) instance = new bootstrap.Modal(modalEl);
            instance.hide();

            reloadMeetingScheduleWithCurrentRange();
        }

        async function deleteMeetingSchedule(meetID) {
            showConfirmPopup({
                title: "Xóa cuộc họp?",
                message: "Bạn có chắc chắn muốn xóa cuộc họp này?",
                YesText: "Xóa",
                NoText: "Hủy",
                onYes: async () => {

                    const item = meetingScheduleList.find(x => x.MeetID == meetID);
                    if (!item) {
                        uiManager.showAlert({ type: "error", message: "Không tìm thấy cuộc họp!" });
                        return;
                    }

                    let deleteResult = await deleteOutlookEvent(meetID);

                    if (deleteResult) {
                        reloadMeetingScheduleWithCurrentRange();
                        uiManager.showAlert({ type: "success", message: "Đã xóa cuộc họp thành công!" });
                    } else {
                        uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi xóa cuộc họp!" });
                    }


                },
                onNo: () => {
                }
            });
        }

        // Meeting Schedule Filter Functions
        function getMSFilterRange() {
            // Check both original and toolbar filters
            const toolbarFrom = $(''#toolbarMsFilterFromDate'').val();
            const toolbarTo = $(''#toolbarMsFilterToDate'').val();
            const originalFrom = $(''#msFilterFromDate'').val();
            const originalTo = $(''#msFilterToDate'').val();

            return {
                fromDate: toolbarFrom || originalFrom || '''',
                toDate: toolbarTo || originalTo || ''''
            };
        }

        function reloadMeetingScheduleWithCurrentRange() {
            const { fromDate, toDate } = getMSFilterRange();

            // Get current employee filter value
            let employeeSelect = '''';
            try {
                const toolbarEmployeeFilter = $(''#toolbarEmployeeFilter'');
                if (toolbarEmployeeFilter.length > 0) {
                    employeeSelect = toolbarEmployeeFilter.val() || '''';
                } else if (typeof InstanceEmployeeIDPE4B749C9E22149ED91266A5C6444354E !== ''undefined'') {
                    employeeSelect = InstanceEmployeeIDPE4B749C9E22149ED91266A5C6444354E.getValueAsString();
                }
            } catch (e) {

            }

            ReloadData(fromDate, toDate, employeeSelect);
        }

        function filterMS() {
            // Use toolbar function if available and configured
            if (IsloadFilter && $(''#toolbarMsFilterFromDate'').length > 0) {
                toolbarFilterMS();
                return;
            }


            const { fromDate, toDate } = getMSFilterRange();


            // Get employee filter value from toolbar
            let employeeSelect = '''';
            try {
                const toolbarEmployeeFilter = $(''#toolbarEmployeeFilter'');
                if (toolbarEmployeeFilter.length > 0) {
                    employeeSelect = toolbarEmployeeFilter.val() || '''';
                } else if (typeof InstanceEmployeeIDPE4B749C9E22149ED91266A5C6444354E !== ''undefined'') {
                    employeeSelect = InstanceEmployeeIDPE4B749C9E22149ED91266A5C6444354E.getValueAsString();
                }
            } catch (e) {


            }

            if (!fromDate || !toDate) {
                console.warn(''⚠️ Validation failed: Missing dates'');
                uiManager.showAlert({ type: "error", message: "Vui lòng chọn cả hai ngày!" });
                return;
            }

            if (fromDate > toDate) {
                console.warn(''⚠️ Validation failed: fromDate > toDate'');
                uiManager.showAlert({ type: "error", message: "Ngày bắt đầu phải <= ngày kết thúc!" });
                return;
            }

            ReloadData(fromDate, toDate, employeeSelect);
        }

        function resetFilterMS() {
            // Use toolbar function if available and configured
            if (IsloadFilter && $(''#toolbarMsFilterFromDate'').length > 0) {
                toolbarResetFilterMS();
                return;
            }

            const today = new Date();

            // Get start of current week (Monday)
            const startOfWeek = new Date(today);
            const dayOfWeek = today.getDay(); // 0 = Sunday, 1 = Monday, ...
            const daysFromMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1; // Convert Sunday to 6, others to dayOfWeek - 1
            startOfWeek.setDate(today.getDate() - daysFromMonday);

            // Format dates using local time instead of ISO
            const formatLocalDate = (date) => {
                return String(date.getFullYear()).padStart(4, ''0'') + ''-'' +
                    String(date.getMonth() + 1).padStart(2, ''0'') + ''-'' +
                    String(date.getDate()).padStart(2, ''0'');
            };

            const fromDateStr = formatLocalDate(startOfWeek);
            const toDateStr = formatLocalDate(today);

            $(''#msFilterFromDate'').val(fromDateStr);
            $(''#msFilterToDate'').val(toDateStr);

            // Clear global filter variables
            window.FromDateKPI = '''';
            window.ToDateKPI = '''';

            // Get employee filter value
            let employeeSelect = '''';
            try {
                const toolbarEmployeeFilter = $(''#toolbarEmployeeFilter'');
                if (toolbarEmployeeFilter.length > 0) {
                    employeeSelect = toolbarEmployeeFilter.val() || '''';
                } else if (typeof InstanceEmployeeIDPE4B749C9E22149ED91266A5C6444354E !== ''undefined'') {
                    employeeSelect = InstanceEmployeeIDPE4B749C9E22149ED91266A5C6444354E.getValueAsString();
                }
            } catch (e) {

            }

            ReloadData(fromDateStr, toDateStr, employeeSelect);
        }

        function initMSFilter() {
            // Use toolbar function if available and configured
            if (IsloadFilter && $(''#toolbarMsFilterFromDate'').length > 0) {
                initMSToolbarFilter();
                return;
            }

            let fromDateStr, toDateStr;

            // Check if FromDateKPI and ToDateKPI are already defined
            if (window.FromDateKPI && window.ToDateKPI) {
                fromDateStr = window.FromDateKPI;
                toDateStr = window.ToDateKPI;
            } else {
                // Set default dates (current week - Monday to today)
                const today = new Date();

                // Get start of current week (Monday)
                const startOfWeek = new Date(today);
                const dayOfWeek = today.getDay(); // 0 = Sunday, 1 = Monday, ...
                const daysFromMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1; // Convert Sunday to 6, others to dayOfWeek - 1
                startOfWeek.setDate(today.getDate() - daysFromMonday);

                // Format dates using local time instead of ISO
                const formatLocalDate = (date) => {
                    return String(date.getFullYear()).padStart(4, ''0'') + ''-'' +
                        String(date.getMonth() + 1).padStart(2, ''0'') + ''-'' +
                        String(date.getDate()).padStart(2, ''0'');
                };

                fromDateStr = formatLocalDate(startOfWeek);
                toDateStr = formatLocalDate(today);
            }

            $(''#msFilterFromDate'').val(fromDateStr);
            $(''#msFilterToDate'').val(toDateStr);
        }

        // Email tag management
        function addMSAttendeeTag(email, empId = '''') {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                uiManager.showAlert({ type: "error", message: "Email không hợp lệ!" });
                return false;
            }

            if (msAttendeesList.find(a => a.email == email)) {
                uiManager.showAlert({ type: "error", message: "Email này đã được thêm!" });
                return false;
            }

            msAttendeesList.push({ email: email, empId: empId });
            renderMSAttendeeTags();
            $(''#ms_attendees'').val('''');
            return true;
        }

        function removeMSAttendeeTag(email) {
            // Prevent removing organizer
            const attendee = msAttendeesList.find(a => a.email === email);
            if (attendee && attendee.isOrganizer) {
                uiManager.showAlert({ type: "error", message: "Không thể xóa người tổ chức cuộc họp!" });
                return false;
            }
            msAttendeesList = msAttendeesList.filter(a => a.email !== email);
            renderMSAttendeeTags();
            return true;
        }

        function renderMSAttendeeTags() {
            const $container = $(''#ms_attendees_tags'');
            $container.empty();

            msAttendeesList.forEach(attendee => {
                const isOrganizer = attendee.isOrganizer;
                const removeBtn = isOrganizer
                    ? `<span style="cursor: not-allowed;" title="Không thể xóa người tổ chức">🔒</span>`
                    : `<span style="cursor: pointer; font-weight: bold;" onclick="removeMSAttendeeTag(''${attendee.email}'')">&times;</span>`;

                const $tag = $(`
                <div style="padding: 6px 12px; border-radius: 16px; display: inline-flex; align-items: center; gap: 8px; border: 1px solid #ddd;">
                    <span>${attendee.email}${isOrganizer ? '' <i class="bi bi-star-fill" style="font-size: 10px;"></i>'' : ''''}</span>
                    ${removeBtn}
                </div>
            `);
                $container.append($tag);
            });

            const emails = msAttendeesList.map(a => a.email).join('','');
            $(''#ms_attendees_hidden'').val(emails);
        }

        if (window.FromDateKPI && window.ToDateKPI) {
            ReloadData(window.FromDateKPI, window.ToDateKPI, window.EmployeeIDsKPI ? window.EmployeeIDsKPI : '''', 0);
        } else {
            initMSFilter();
            const initialRange = getMSFilterRange();
            ReloadData(null, null, '''', 1);
        }

        // Bind filter button click event via jQuery
        $(document).ready(function () {
            $(''#filterMSBtn'').on(''click'', function (e) {
                filterMS();
            });

            // Ensure modal buttons always have handlers
            bindModalCloseHandlers();

            // Rebind handlers whenever modal is shown
            $(''#meetingScheduleModal'').on(''shown.bs.modal'', () => {
                bindModalCloseHandlers();
            });

            // Global backup handler for close button (in case specific handlers fail)
            $(document).on(''click'', ''#meetingScheduleModal .btn-close, #cancelMeetingBtn'', function (e) {
                if (!$(this).data(''handled'')) {
                    handleModalClose(e);
                }
            });
        });

        // Load employee list for datalist
        if (typeof mailEmployeeList !== ''undefined'' && mailEmployeeList.length > 0) {
            const $datalist = $(''#msEmployeeList'');
            mailEmployeeList.forEach(emp => {
                if (emp.Email) {
                    const label = emp.FullName || emp.EmployeeName || emp.Email;
                    $datalist.append(`<option value="${emp.Email}">${label}</option>`);
             }
            });
        }

        // Handle email input
        $(document).on(''keydown'', ''#ms_attendees'', function (e) {
            const email = $(this).val().trim();
            if (e.key === ''Enter'' || e.key === '','') {
                e.preventDefault();
                const cleanEmail = email.replace(/,\s*$/, '''').trim();
                if (cleanEmail) {
                    const emp = typeof mailEmployeeList !== ''undefined''
                        ? mailEmployeeList.find(e => e.Email == cleanEmail)
                        : null;
                    const empId = emp ? emp.EmployeeID : '''';
                    addMSAttendeeTag(cleanEmail, empId);
                }
            }
        });

        $(document).on(''change'', ''#ms_attendees'', function () {
            const email = $(this).val().trim();
            if (email) {
                const emp = typeof mailEmployeeList !== ''undefined''
                    ? mailEmployeeList.find(e => e.Email == email)
                    : null;
                const empId = emp ? emp.EmployeeID : '''';
                addMSAttendeeTag(email, empId);
            }
        });

        // Expose necessary functions to global scope for HTML onclick handlers
        window.filterMS = filterMS;
        window.resetFilterMS = resetFilterMS;
        window.openMeetingModal = openMeetingModal;
        window.saveMeetingSchedule = handleSaveMeetingSchedule; // Use wrapper function
        window.viewMeetingDetail = viewMeetingDetail;
        window.openDetailMeetID = openDetailMeetID;
        window.deleteMeetingSchedule = deleteMeetingSchedule;
        window.removeMSAttendeeTag = removeMSAttendeeTag;
        window.getLastRemovedAttendees = () => lastRemovedAttendees; // Get last removed attendees array

    })();

</script>
 '

    SELECT @html AS html;
 -- exec sptblCommonControlType_Signed_Duc 'sp_KPIMeetingDemo_html'
    -- EXEC sp_GenerateHTMLScript_new 'sp_KPIMeetingDemo_html'
    -- EXEC sp_GenerateHTMLScript 'sp_Dashboard_Mobile_beta'
END
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 2: CHUẨN HÓA STORED PROCEDURE ĐIỀU PHỐI (TRỎ VỀ ĐÚNG KEY CHUẨN 'sp_KPIMeetingDemo')
--------------------------------------------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE [dbo].[sp_KPIMeetingDemo]
(
    @LoginID INT = 3,
    @LanguageID VARCHAR(5) = 'VN'
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @LanguageID IS NULL OR LTRIM(RTRIM(@LanguageID)) = ''
        SET @LanguageID = 'VN';

    -- Đọc duy nhất 1 Key chuẩn quy ước của hệ thống Paradise HRM (Khắc phục lỗi trỏ nhầm _html)
    SELECT TOP 1 html AS Col1 
    FROM tblHtmlScriptCache 
    WHERE TableName = 'sp_KPIMeetingDemo' 
      AND ScreenType = -1 
      AND LanguageID = @LanguageID;
END
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 3: TÁI TẠO BỘ NHỚ ĐỆM GIAO DIỆN QUA SP_GENERATEHTMLSCRIPT_NEW
  Biên dịch tự động vào tblHtmlScriptCache cho cả 2 khóa để đảm bảo tương thích 100%
--------------------------------------------------------------------------------------------------*/
PRINT N'==> Đang biên dịch cache giao diện Các cuộc họp qua sp_GenerateHTMLScript_new...';
EXEC [dbo].[sp_GenerateHTMLScript_new] 'sp_KPIMeetingDemo_html', '-1', 'sp_KPIMeetingDemo';
EXEC [dbo].[sp_GenerateHTMLScript_new] 'sp_KPIMeetingDemo_html', '-1', 'sp_KPIMeetingDemo_html';
GO

PRINT N'=========================================================================================';
PRINT N'==> HOÀN TẤT CẬP NHẬT SCREENSHOT 15! HÃY VÀO TRÌNH DUYỆT BẤM CTRL + F5 ĐỂ KIỂM TRA NGHIỆM THU.';
PRINT N'=========================================================================================';
GO
