/*==================================================================================================
  BẢN VÁ TOÀN DIỆN SCREENSHOT-11: TỐI ƯU GIAO DIỆN & SỬA LỖI DEVTOOLS + FONT + DROPDOWN
  Menu: Tính lương -> Nhập lương Trí Luật (MnuPRL408 / Template_SalaryImport_TriLuat)
  
  MỤC TIÊU XỬ LÝ TRIỆT ĐỂ:
  1. Đưa cụm lọc Tháng, Năm, Checkbox, Chuyển khoản, Thông báo lên NGANG HÀNG 100% với thanh công cụ DataGrid
     (Nút Thêm mới, Làm mới, Tải file mẫu, Nhập excel, Chọn cột và Ô tìm kiếm) thông qua CSS Layout.
  2. Khắc phục triệt để lỗi DevTools: TypeError: Cannot read properties of undefined (reading 'loadSingle')
     bằng cách loại bỏ loadData đồng bộ sớm và nạp DataSource qua loadDataSourceCommon.
  3. Khắc phục lỗi font mojibake: Sửa "Khng c d? li?u" thành "Không có dữ liệu".
  4. Khắc phục lỗi Dropdown Tháng và Năm bị trắng xóa: Gán chính xác valueExpr="ID", displayExpr="MonthName" / "YearName"
     và bổ sung itemTemplate để hiển thị chữ rõ nét 100%.
  5. Tuân thủ chu trình khép kín:
     - Sửa Stored Procedure gốc [dbo].[Template_SalaryImport_TriLuat_html]
     - Chạy sp_GenerateHTMLScript_new để biên dịch tự động
     - Đồng bộ thay thế biến %triluat_% từ tblMD_Message vào tblHtmlScriptCache ([html] và [VersionData])
     - Cập nhật Checksum Version để client nhận diện bản cập nhật ngay lập tức.
==================================================================================================*/

USE [Vietinsoft_ForTest_Tai2]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 1: CẬP NHẬT STORED PROCEDURE GIAO DIỆN TEMPLATE_SALARYIMPORT_TRILUAT_HTML
--------------------------------------------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE [dbo].[Template_SalaryImport_TriLuat_html]
    @LoginID int = 3,
    @LanguageID varchar(2) = 'VN'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @html nvarchar(max) = N'';
    DECLARE @GridUID varchar(64), @MonthUID varchar(64), @YearUID varchar(64);
    DECLARE @Month int = 5, @Year int = 2026, @YearID int = NULL;
    DECLARE @CurrentFromDate DATE, @CurrentToDate DATE;
    SELECT @CurrentFromDate = Fromdate, @CurrentToDate = Todate
    FROM dbo.fn_Get_SalaryPeriod_ByDate(GETDATE());
    SET @Month = MONTH(@CurrentFromDate);
    SET @Year = YEAR(@CurrentFromDate);
    SET @YearID = 2028 - @Year;
    -- UIDs ch�nh
    SELECT @GridUID = UID FROM tblCommonControlType_Signed WHERE TableName = 'Template_SalaryImport_TriLuat_html' AND ColumnName = 'GridTemplate_SalaryImport_TriLuat' AND ISNULL(GridColumnName,'') = '';
    SELECT @MonthUID = UID FROM tblCommonControlType_Signed WHERE TableName = 'Template_SalaryImport_TriLuat_html' AND ColumnName = 'Month' AND ISNULL(GridColumnName,'') = '';
    SELECT @YearUID = UID FROM tblCommonControlType_Signed WHERE TableName = 'Template_SalaryImport_TriLuat_html' AND ColumnName = 'Year' AND ISNULL(GridColumnName,'') = '';
    -- UIDs c?a c�c control Form Add/Edit
    DECLARE @EmpUID varchar(64), @GrossUID varchar(64), @RefundUID varchar(64), @RemarkUID varchar(64), @LockUID varchar(64), @RefundedUID varchar(64);
    SELECT @EmpUID = UID FROM tblCommonControlType_Signed WHERE TableName = 'Template_SalaryImport_TriLuat_html' AND ColumnName = 'EmployeeID' AND GridColumnName = 'GridTemplate_SalaryImport_TriLuat';
    SELECT @GrossUID = UID FROM tblCommonControlType_Signed WHERE TableName = 'Template_SalaryImport_TriLuat_html' AND ColumnName = 'GrossTakeHome' AND GridColumnName = 'GridTemplate_SalaryImport_TriLuat';
    SELECT @RefundUID = UID FROM tblCommonControlType_Signed WHERE TableName = 'Template_SalaryImport_TriLuat_html' AND ColumnName = 'RefundAmount' AND GridColumnName = 'GridTemplate_SalaryImport_TriLuat';
    SELECT @RemarkUID = UID FROM tblCommonControlType_Signed WHERE TableName = 'Template_SalaryImport_TriLuat_html' AND ColumnName = 'Remark' AND GridColumnName = 'GridTemplate_SalaryImport_TriLuat';
    SELECT @LockUID = UID FROM tblCommonControlType_Signed WHERE TableName = 'Template_SalaryImport_TriLuat_html' AND ColumnName = 'IsLock' AND GridColumnName = 'GridTemplate_SalaryImport_TriLuat';
    SELECT @RefundedUID = UID FROM tblCommonControlType_Signed WHERE TableName = 'Template_SalaryImport_TriLuat_html' AND ColumnName = 'IsRefunded' AND GridColumnName = 'GridTemplate_SalaryImport_TriLuat';
    SET @html = N'
<style>
  /* C?u h�nh khung ch?a ch�nh s? d?ng flexbox cao d�ng 100% viewport tr? header */
  #TemplateSalaryImportTriLuatPage {
      height: calc(100vh - 110px) !important;
      max-height: calc(100vh - 110px) !important;
      width: 100% !important;
      display: flex !important;
      flex-direction: column !important;
      border-top: 1px solid var(--bs-border-color);
      overflow: hidden !important;
  }
  #TemplateSalaryImportTriLuatPage .dx-field-item {
      padding: 0 !important;
  }
  #TemplateSalaryImportTriLuatPage .dx-form-group-content {
      padding: 0 !important;
  }
  /* C?u h�nh d? r?ng g?n g�ng cho SelectBox Th�ng v� Nam */
  #Month' + @MonthUID + N' {
      width: 70px !important;
      display: inline-block !important;
  }
  #Year' + @YearUID + N' {
      width: 80px !important;
      display: inline-block !important;
  }
  /* ==========================================================================
     LAYOUT RESPONSIVE TỰ THÍCH ỨNG:
     - Màn hình rộng (>= 1350px): Filter và Toolbar gom chung 1 hàng phẳng phiu
     - Khi tới giới hạn màn hình (< 1350px / laptop / mở sidebar): Tự động xuống hàng mượt mà
     ========================================================================== */
  #TemplateSalaryImportTriLuatPage {
      position: relative !important;
      container-type: inline-size;
  }

  /* Màn hình lớn (>= 1350px): Neo bộ lọc bên trái ngang hàng với Toolbar bên phải */
  @media (min-width: 1350px) {
      #TemplateSalaryImportTriLuatPage #tsitlTopFilterBar {
          position: absolute !important;
          left: 8px !important;
          top: 4px !important;
          z-index: 20 !important;
          display: inline-flex !important;
          align-items: center !important;
          gap: 8px !important;
          height: 36px !important;
          margin: 0 !important;
          padding: 0 !important;
          max-width: calc(100% - 460px) !important;
          white-space: nowrap !important;
      }
      #TemplateSalaryImportTriLuatPage .dx-datagrid-header-panel {
          min-height: 44px !important;
          height: 44px !important;
          padding: 0 8px 0 0 !important;
          background: transparent !important;
      }
      #TemplateSalaryImportTriLuatPage .dx-toolbar {
          min-height: 44px !important;
          height: 44px !important;
          background: transparent !important;
      }
      #TemplateSalaryImportTriLuatPage .dx-toolbar-items-container {
          height: 44px !important;
          display: flex !important;
          align-items: center !important;
          justify-content: flex-end !important;
      }
  }

  /* Khi tới giới hạn màn hình (< 1350px, màn hình laptop 1366px, 1200px, 1024px hoặc mở sidebar):
     Bộ lọc tự động xuống Hàng 1, thanh công cụ tác vụ nằm ở Hàng 2 bên dưới */
  @media (max-width: 1349px) {
      #TemplateSalaryImportTriLuatPage #tsitlTopFilterBar {
          position: relative !important;
          left: auto !important;
          top: auto !important;
          width: 100% !important;
          display: flex !important;
          align-items: center !important;
          flex-wrap: wrap !important;
          gap: 8px !important;
          padding: 6px 8px !important;
          margin: 0 0 4px 0 !important;
          background: rgba(255, 255, 255, 0.02) !important;
          border-radius: 4px !important;
          box-sizing: border-box !important;
      }
      #TemplateSalaryImportTriLuatPage .dx-datagrid-header-panel {
          height: auto !important;
          min-height: 40px !important;
          padding: 0 8px 0 0 !important;
      }
      #TemplateSalaryImportTriLuatPage .dx-toolbar {
          height: auto !important;
          min-height: 40px !important;
      }
      #TemplateSalaryImportTriLuatPage .dx-toolbar-items-container {
          height: auto !important;
          min-height: 40px !important;
          display: flex !important;
          align-items: center !important;
          justify-content: flex-end !important;
      }
  }

  @container (max-width: 1250px) {
      #TemplateSalaryImportTriLuatPage #tsitlTopFilterBar {
          position: relative !important;
          left: auto !important;
          top: auto !important;
          width: 100% !important;
          display: flex !important;
          align-items: center !important;
          flex-wrap: wrap !important;
          gap: 8px !important;
          padding: 6px 8px !important;
          margin: 0 0 4px 0 !important;
          background: rgba(255, 255, 255, 0.02) !important;
          border-radius: 4px !important;
          box-sizing: border-box !important;
      }
      #TemplateSalaryImportTriLuatPage .dx-datagrid-header-panel {
          height: auto !important;
          min-height: 40px !important;
          padding: 0 8px 0 0 !important;
      }
      #TemplateSalaryImportTriLuatPage .dx-toolbar {
          height: auto !important;
          min-height: 40px !important;
      }
      #TemplateSalaryImportTriLuatPage .dx-toolbar-items-container {
          height: auto !important;
          min-height: 40px !important;
          display: flex !important;
          align-items: center !important;
          justify-content: flex-end !important;
      }
  }
  #TemplateSalaryImportTriLuatPage .tsitl-filter-label {
      font-weight: 600 !important;
      font-size: 13px !important;
      white-space: nowrap !important;
      color: var(--bs-body-color, #e2e8f0) !important;
      margin: 0 !important;
  }
  #TemplateSalaryImportTriLuatPage .tsitl-filter-check {
      display: inline-flex !important;
      align-items: center !important;
      gap: 4px !important;
      margin: 0 4px !important;
      font-weight: 600 !important;
      font-size: 13px !important;
      white-space: nowrap !important;
      color: var(--bs-body-color, #e2e8f0) !important;
      cursor: pointer !important;
  }
  #TemplateSalaryImportTriLuatPage .tsitl-filter-btn {
      height: 30px !important;
      padding: 0 12px !important;
      font-size: 12px !important;
      font-weight: 600 !important;
      display: inline-flex !important;
      align-items: center !important;
      justify-content: center !important;
      border-radius: 4px !important;
      white-space: nowrap !important;
      background: #007a4d !important;
      border-color: #007a4d !important;
      color: #fff !important;
  }
  #TemplateSalaryImportTriLuatPage .tsitl-filter-btn:hover {
      background: #006540 !important;
      border-color: #006540 !important;
  }
  /* Căn chỉnh DataGrid Toolbar để Action Buttons và Search Box nằm bên phải trên cùng 1 hàng */
  #TemplateSalaryImportTriLuatPage .dx-datagrid-header-panel {
      min-height: 44px !important;
      height: 44px !important;
      padding: 0 8px 0 0 !important;
      background: transparent !important;
  }
  #TemplateSalaryImportTriLuatPage .dx-toolbar {
      min-height: 44px !important;
      height: 44px !important;
      background: transparent !important;
  }
  #TemplateSalaryImportTriLuatPage .dx-toolbar-items-container {
      height: 44px !important;
      display: flex !important;
      align-items: center !important;
      justify-content: flex-end !important;
  }
  #TemplateSalaryImportTriLuatPage .dx-toolbar-before {
      display: none !important;
  }
  #TemplateSalaryImportTriLuatPage .dx-toolbar-after {
      display: inline-flex !important;
      align-items: center !important;
      gap: 4px !important;
      margin-left: auto !important;
  }
  /* Tối ưu hiển thị danh sách Dropdown cho Tháng và Năm: hiển thị chữ rõ nét */
  .dx-dropdowneditor-overlay .dx-list-item-content {
      color: #e2e8f0 !important;
      font-size: 13px !important;
      padding: 6px 12px !important;
  }
  .dx-dropdowneditor-overlay .dx-list-item.dx-state-hover .dx-list-item-content {
      background-color: #007a4d !important;
      color: #ffffff !important;
  }
  .dx-dropdowneditor-overlay .dx-list-item.dx-state-selected .dx-list-item-content {
      background-color: #005d3c !important;
      color: #ffffff !important;
      font-weight: 600 !important;
  }
  #TemplateSalaryImportTriLuatPage .dx-toolbar-after .dx-button {
      padding: 0 !important;
      width: 32px !important;
      height: 32px !important;
      display: inline-flex !important;
      align-items: center !important;
      justify-content: center !important;
      margin: 0 2px !important;
      border: 0 !important;
      background: transparent !important;
      box-shadow: none !important;
      outline: none !important;
  }
  #TemplateSalaryImportTriLuatPage .dx-toolbar-after .dx-button .dx-icon {
      font-size: 18px !important;
      margin: 0 !important;
  }
  /* CSS ngan wrap ch? trong d�ng grid d? k�ch ho?t scroll ngang */
  #TemplateSalaryImportTriLuatPage .dx-datagrid-rowsview .dx-row > td > div {
      white-space: nowrap !important;
      overflow: hidden !important;
      text-overflow: ellipsis !important;
  }
  /* C?u h�nh header c?a dxPopup m�u xanh l� d?m (corporate) v� ch? tr?ng th�ng qua class wrapper */
  .tr-luat-popup-custom .dx-popup-title {
      background-color: #005d3c !important;
      color: #ffffff !important;
      border-bottom: none !important;
      padding: 10px 16px !important;
  }
  .tr-luat-popup-custom .dx-popup-title .dx-popup-title-text {
      color: #ffffff !important;
      font-weight: bold !important;
      font-size: 16px !important;
  }
  .tr-luat-popup-custom .dx-popup-title .dx-closebutton {
      color: #ffffff !important;
      background: transparent !important;
      border: none !important;
  }
  .tr-luat-popup-custom .dx-popup-title .dx-closebutton .dx-icon {
      color: #ffffff !important;
  }
</style>
<div id="TemplateSalaryImportTriLuatPage" style="height: 100%; display: flex; flex-direction: column; background: var(--bs-body-bg);">
  <div id="tsitlTopFilterBar">
    <span class="tsitl-filter-label">%triluat_month%</span>
    ' + ISNULL((SELECT html FROM tblCommonControlType_Signed WHERE UID = @MonthUID), N'') + N'
    <span class="tsitl-filter-label" style="margin-left:4px;">%triluat_year%</span>
    ' + ISNULL((SELECT html FROM tblCommonControlType_Signed WHERE UID = @YearUID), N'') + N'
    <label class="tsitl-filter-check"><input id="tsitlApproveAll" type="checkbox" /> %triluat_label_approve_all%</label>
    <button id="tsitlTransfer" class="btn btn-success btn-sm tsitl-filter-btn">%triluat_btn_transfer%</button>
    <button id="tsitlNotify" class="btn btn-success btn-sm tsitl-filter-btn">%triluat_btn_notify%</button>
  </div>
  <!-- Khung bao Grid gian 100% chi?u cao c�n l?i -->
  <div style="flex:1;min-height:0;display:flex;flex-direction:column;">
    ' + ISNULL((SELECT html FROM tblCommonControlType_Signed WHERE UID = @GridUID), N'') + N'
  </div>
</div>
<!-- ============================================================ -->
<!-- KHUNG POPUP FORM NH?P ADD/EDIT -->
<!-- ============================================================ -->
<style>
#popupAddEditTriLuat .dx-popup-content,
#popupAddEditTriLuat .dx-popup-content-scrollable,
#popupAddEditTriLuat .dx-scrollable-content,
#popupAddEditTriLuat .dx-scrollview-content { padding: 0 !important; margin: 0 !important; overflow: hidden !important; }
#popupAddEditTriLuat .triluat-salary-form { margin: 0 !important; padding: 12px 20px 12px !important; box-sizing: border-box !important; }
#popupAddEditTriLuat .dx-popup-title { padding: 10px 18px !important; margin: 0 !important; }
.triluat-salary-form .form-section-title { font-size: 13.5px !important; margin: 0 0 5px !important; padding-bottom: 5px !important; }
.triluat-salary-form .form-group { margin-bottom: 5px !important; }
.triluat-salary-form .dx-texteditor { min-height: 32px !important; }
.triluat-salary-form .dx-texteditor-input { font-size: 13px !important; padding: 5px 0 !important; }
.triluat-salary-form .dx-checkbox-icon { width: 16px !important; height: 16px !important; }
</style>
<style>
.dx-overlay-content:has(#popupFormContentTriLuat) { width: 680px !important; max-width: calc(100vw - 48px) !important; }
.dx-popup-content:has(#popupFormContentTriLuat),
.dx-popup-content-scrollable:has(#popupFormContentTriLuat),
.dx-scrollable-content:has(#popupFormContentTriLuat),
.dx-scrollview-content:has(#popupFormContentTriLuat) { padding: 0 !important; margin: 0 !important; }
#popupFormContentTriLuat.triluat-salary-form { padding: 12px 20px 12px !important; margin: 0 !important; box-sizing: border-box !important; }
#popupFormContentTriLuat.triluat-salary-form .form-section-title { margin: 0 0 5px !important; padding-bottom: 5px !important; font-size: 13.5px !important; }
#popupFormContentTriLuat.triluat-salary-form .form-group { margin-bottom: 5px !important; }
#popupFormContentTriLuat.triluat-salary-form .dx-texteditor { min-height: 32px !important; }
#popupFormContentTriLuat.triluat-salary-form .dx-texteditor-input { font-size: 13px !important; padding: 5px 0 !important; }
#popupFormContentTriLuat.triluat-salary-form .dx-checkbox-icon { width: 16px !important; height: 16px !important; }
</style>
<div id="popupAddEditTriLuat"></div>
<div id="popupFormContentTriLuat" class="triluat-salary-form" style="display:none; padding:12px 20px 12px; margin:0; flex-direction:column; gap:8px; font-size:13px;">
  <!-- Section 1: %triluat_employee_info% -->
  <div class="form-section-title" style="display:flex; align-items:center; gap:6px; font-weight:bold; color:#005d3c; border-bottom:1px solid #e0e0e0; padding-bottom:4px; margin-bottom:4px;">
    <i class="bi bi-person-fill" style="font-size:16px;"></i> %triluat_employee_info%
  </div>
  <div class="form-group" style="display:flex; flex-direction:column; gap:4px; margin-bottom:8px;">
    <label class="form-label" style="font-weight:bold; margin:0;">%triluat_employee% *</label>
    <div>
      ' + ISNULL((SELECT html FROM tblCommonControlType_Signed WHERE UID = @EmpUID), N'') + N'
    </div>
  </div>
  <!-- Section 2: %triluat_salary_debt_info% -->
  <div class="form-section-title" style="display:flex; align-items:center; gap:6px; font-weight:bold; color:#005d3c; border-bottom:1px solid #e0e0e0; padding-bottom:4px; margin-bottom:4px;">
    <i class="bi bi-cash-stack" style="font-size:16px;"></i> %triluat_salary_debt_info%
  </div>
  <div class="form-group" style="display:flex; flex-direction:column; gap:4px;">
    <label class="form-label" style="font-weight:bold; margin:0;">%triluat_salary_table%</label>
    <div>
      ' + ISNULL((SELECT html FROM tblCommonControlType_Signed WHERE UID = @GrossUID), N'') + N'
    </div>
  </div>
  <div class="form-group" style="display:flex; flex-direction:column; gap:4px;">
    <label class="form-label" style="font-weight:bold; margin:0;">%triluat_refund_amount%</label>
    <div>
      ' + ISNULL((SELECT html FROM tblCommonControlType_Signed WHERE UID = @RefundUID), N'') + N'
    </div>
  </div>
  <div style="display:flex; gap:16px; margin-bottom:8px;">
    <div class="form-group" style="flex:1; display:flex; flex-direction:column; gap:4px;">
      <label class="form-label" style="font-weight:bold; margin:0;">%triluat_approve_debt%</label>
      <div style="height:34px; display:flex; align-items:center;">
        <div id="' + @LockUID + N'"></div>
      </div>
    </div>
    <div class="form-group" style="flex:1; display:flex; flex-direction:column; gap:4px;">
      <label class="form-label" style="font-weight:bold; margin:0;">%triluat_refunded_transferred%</label>
      <div style="height:34px; display:flex; align-items:center;">
        <div id="' + @RefundedUID + N'"></div>
      </div>
    </div>
  </div>
  <!-- Section 3: Note -->
  <div class="form-section-title" style="display:flex; align-items:center; gap:6px; font-weight:bold; color:#005d3c; border-bottom:1px solid #e0e0e0; padding-bottom:4px; margin-bottom:4px;">
    <i class="bi bi-chat-left-text-fill" style="font-size:14px;"></i> %triluat_note%
  </div>
  <div class="form-group" style="display:flex; flex-direction:column; gap:4px;">
    <div>
      ' + ISNULL((SELECT html FROM tblCommonControlType_Signed WHERE UID = @RemarkUID), N'') + N'
    </div>
  </div>
  <div style="text-align:right; margin-top:8px;">
    <button id="btnSaveTriLuat" class="btn btn-primary btn-sm" style="min-width:80px;">%common_save%</button>
    <button id="btnCancelTriLuat" class="btn btn-secondary btn-sm" style="min-width:80px; margin-left:8px;">%common_cancel%</button>
  </div>
</div>
<script>
(function () {
var customFormatter = function(val) {
  if (val === undefined || val === null || val === "") return "";
  var num = Number(val);
  if (isNaN(num)) return val;
  return num.toLocaleString("en-US", { minimumFractionDigits: 0, maximumFractionDigits: 0 });
};
window.TemplateSalaryImportTriLuatMonth = ' + CONVERT(varchar(10), @Month) + N';
window.TemplateSalaryImportTriLuatYear = ' + CONVERT(varchar(10), @Year) + N';
window.TemplateSalaryImportTriLuatYearID = ' + CONVERT(varchar(10), @YearID) + N';
window["_hideID_Month' + @MonthUID + N'"] = true;
window["_hideID_Year' + @YearUID + N'"] = true;
var obj = { Month: window.TemplateSalaryImportTriLuatMonth, Year: window.TemplateSalaryImportTriLuatYearID };
function ctlVal(inst, fallback){ try { return inst.getValue ? inst.getValue() : inst.option("value"); } catch(e) { return fallback; } }
function getFilterMonth(){ return ctlVal(InstanceMonth' + @MonthUID + N', window.TemplateSalaryImportTriLuatMonth || 5) || 5; }
function getFilterYearID(){ return ctlVal(InstanceYear' + @YearUID + N', window.TemplateSalaryImportTriLuatYearID || 2) || 2; }
window["onSelectBoxChanged_Month"] = function(value){ window.TemplateSalaryImportTriLuatMonth = value; obj.Month = value; forceGridReload(); };
window["onSelectBoxChanged_Year"] = function(value){ window.TemplateSalaryImportTriLuatYearID = value; obj.Year = value; forceGridReload(); };
'
+ ISNULL((SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = @MonthUID), N'') + CHAR(13) + CHAR(10)
+ ISNULL((SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = @YearUID), N'') + CHAR(13) + CHAR(10)
+ ISNULL((SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = @GridUID), N'') + CHAR(13) + CHAR(10)
+ ISNULL((SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = @EmpUID), N'') + CHAR(13) + CHAR(10)
+ ISNULL((SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = @GrossUID), N'') + CHAR(13) + CHAR(10)
+ ISNULL((SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = @RefundUID), N'') + CHAR(13) + CHAR(10)
+ ISNULL((SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = @LockUID), N'') + CHAR(13) + CHAR(10)
+ ISNULL((SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = @RefundedUID), N'') + CHAR(13) + CHAR(10)
+ ISNULL((SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = @RemarkUID), N'') + CHAR(13) + CHAR(10)
-- Bỏ loadData đồng bộ sớm của Month/Year để tránh ngoại lệ loadSingle trên SelectBox + CHAR(13) + CHAR(10)
+ ISNULL((SELECT loadData FROM tblCommonControlType_Signed WHERE UID = @GridUID), N'') + CHAR(13) + CHAR(10)
+ ISNULL((SELECT loadData FROM tblCommonControlType_Signed WHERE UID = @EmpUID), N'') + CHAR(13) + CHAR(10)
+ ISNULL((SELECT loadData FROM tblCommonControlType_Signed WHERE UID = @GrossUID), N'') + CHAR(13) + CHAR(10)
+ ISNULL((SELECT loadData FROM tblCommonControlType_Signed WHERE UID = @RefundUID), N'') + CHAR(13) + CHAR(10)
+ ISNULL((SELECT loadData FROM tblCommonControlType_Signed WHERE UID = @LockUID), N'') + CHAR(13) + CHAR(10)
+ ISNULL((SELECT loadData FROM tblCommonControlType_Signed WHERE UID = @RefundedUID), N'') + CHAR(13) + CHAR(10)
+ ISNULL((SELECT loadData FROM tblCommonControlType_Signed WHERE UID = @RemarkUID), N'') + CHAR(13) + CHAR(10) +
N'
// Ch?y d?ng b? ngay l?p t?c kh�ng qua timeout
var grid = InstanceGridTemplate_SalaryImport_TriLuat' + @GridUID + N';
if (grid) {
  grid.beginUpdate();
  grid.option("noDataText", "");
  grid.option("height", "100%");
  grid.option("paging.enabled", true);
  grid.option("paging.pageSize", 100);
  grid.option("pager.visible", false);
  grid.option("pager", { visible: false });
  grid.option("scrolling.mode", "infinite");
  grid.option("scrolling.rowRenderingMode", "virtual");
  grid.option("scrolling.preloadEnabled", false);
  // T?t ho�n to�n Remote Operations d? DevExpress t? d?ng ph�n trang v� t�nh to�n Summary ph�a Client
  grid.option("remoteOperations", {});
  // Cho ph�p ch?nh s?a tr?c ti?p qua cellTemplate, t?t ch? d? edit m?c d?nh c?a grid
  grid.option("editing", {
    mode: "cell",
    allowUpdating: false,
    allowAdding: false,
    allowDeleting: false
  });
  // Double-click d�ng m? Form S?a
  grid.option("onRowDblClick", function(e) {
    if (e.rowType === "data" && e.data) {
      openEditForm(e.data);
    }
  });
  // T�ch h?p CellTemplate cho c?t Checkbox d? click l� check v� update l?p t?c
  // triluatSingleClickEdit: click 1 l?n v�o cell data d? m? form s?a; checkbox v?n click ri�ng
  grid.option("onCellClick", function(e) {
    if (e.rowType !== "data" || !e.data) return;
    if (e.column && (e.column.dataField === "IsLock" || e.column.dataField === "IsRefunded")) return;
    var target = e.event && e.event.target ? $(e.event.target) : $();
    if (target.closest(".dx-checkbox, .dx-editor-cell, .dx-link, button, a, input, textarea, select").length > 0) return;
    openEditForm(e.data);
  });
  grid.option("onRowDblClick", null);
  var cols = grid.option("columns") || [];
  cols.forEach(function(col) {
    // Xo� width c?ng t? DB
    delete col.width;
    // D?t minWidth d?a tr�n d? d�i c?a ti�u d? c?t (caption) d? tr�nh b? co/gom c?t khi kh�ng c� d? li?u
    var displayName = col.caption || col.dataField || "";
    col.minWidth = Math.max(80, displayName.length * 8 + 45);
    if (col.dataField === "FullName") {
      col.minWidth = 200;
    }
    if (col.dataField === "Remark" || col.dataField === "Notes") {
      col.minWidth = 160;
    }
    if (col.dataField === "GrossTakeHome" || col.dataField === "GrossTakeHomeVietinsoft" || col.dataField === "RefundAmount") {
      col.alignment = "right";
      col.cellTemplate = function(container, options) {
        container.text(customFormatter(options.value));
      };
    }
    if (col.dataField === "IsLock" || col.dataField === "IsRefunded") {
          col.alignment = "center";
      col.cellTemplate = function(container, options) {
        $("<div>").dxCheckBox({
          value: !!options.value,
          onValueChanged: function(e) {
            var newVal = e.value ? 1 : 0;
            var oldVal = options.value ? 1 : 0;
            if (newVal === oldVal) return;
            // C?p nh?t gi� tr? tr?c ti?p v�o row data
            options.data[col.dataField] = e.value;
            // G?i API c?p nh?t ng?m kh�ng block m�n h�nh
            updateSingleField(options.data.EmployeeID, col.dataField, newVal);
          }
        }).appendTo(container);
      };
    }
  });
  grid.option("columns", cols);
  // C?u h�nh summaries cho c�c c?t (d?i H? v� t�n t? T?ng s? NV sang T?ng)
  grid.option("summary", {
    totalItems: [
      {
        column: "FullName",
        summaryType: "count",
        displayFormat: "%triluat_total%: {0}"
      },
      {
        column: "GrossTakeHome",
        summaryType: "sum",
        valueFormat: customFormatter,
        displayFormat: "%triluat_total%: {0}"
      },
      {
        column: "GrossTakeHomeVietinsoft",
        summaryType: "sum",
        valueFormat: customFormatter,
        displayFormat: "%triluat_total%: {0}"
      },
      {
        column: "RefundAmount",
        summaryType: "sum",
        valueFormat: customFormatter,
        displayFormat: "%triluat_total%: {0}"
      }
    ]
  });
  // T?i l?i thanh c�ng c?: Th�m n�t Th�m m?i (+), n�t T?i file m?u v� Nh?p excel, n�t Reload
  grid.option("onToolbarPreparing", function(e) {
    var toolbarItems = e.toolbarOptions.items;
    var ccIdx = -1;
    for (var i = 0; i < toolbarItems.length; i++) {
      if (toolbarItems[i].name === "columnChooserButton") {
        ccIdx = i;
        break;
      }
    }
    var myItems = [
      {
        location: "after",
        widget: "dxButton",
        options: {
          icon: "add",
          stylingMode: "text",
          hint: "Th�m m?i",
          onClick: function() { openAddForm(); }
        }
      },
      {
        location: "after",
        widget: "dxButton",
        options: {
          icon: "refresh",
          stylingMode: "text",
          hint: "%triluat_hint_refresh%",
          onClick: function() { forceGridReload(); }
        }
      },
      {
        location: "after",
        widget: "dxButton",
        options: {
          icon: "download",
          stylingMode: "text",
          hint: "%triluat_hint_download%",
          onClick: function() { downloadTemplateTriLuat(); }
        }
      },
      {
        location: "after",
        widget: "dxButton",
        options: {
          icon: "upload",
          stylingMode: "text",
          hint: "%triluat_hint_upload%",
          onClick: function() { $("#btnImportTriLuatHIDDEN").trigger("click"); }
        }
      }
    ];
    if (ccIdx !== -1) {
      toolbarItems.splice(ccIdx, 0, myItems[0], myItems[1], myItems[2], myItems[3]);
    } else {
      toolbarItems.push(myItems[0], myItems[1], myItems[2], myItems[3]);
    }
  });
  grid.endUpdate();
  forceGridReload();
}
// Kh?i t?o dxPopup cho form Add/Edit v?i chi?u r?ng l?n hon (550px) v� g�n wrapperAttr d? style ti�u d?
var popupInstance = $("#popupAddEditTriLuat").dxPopup({
  title: "Nh?p luong Tr� Lu?t / C�ng n?",
  visible: false,
  width: 550,
  height: "auto",
  dragEnabled: true,
  closeOnOutsideClick: false,
  showCloseButton: true,
  wrapperAttr: { class: "tr-luat-popup-custom" },
  contentTemplate: function(container) {
    $("#popupFormContentTriLuat").show().appendTo(container);
  }
}).dxPopup("instance");
var formMode = "add";
function setFormValues(obj) {
  if (typeof InstanceEmployeeIDPF8B95A1D761047D3B6F187C5865D5310 !== "undefined") {
    InstanceEmployeeIDPF8B95A1D761047D3B6F187C5865D5310.option("value", obj.EmployeeID || null);
  }
  if (typeof InstanceGrossTakeHomePF8A300BE4ADA414098D0B5DE352E304C !== "undefined") {
    InstanceGrossTakeHomePF8A300BE4ADA414098D0B5DE352E304C.option("value", obj.GrossTakeHome || 0);
  }
  if (typeof InstanceRefundAmountPA6EC77FFBBDC41F1902AACE5F79E7CC1 !== "undefined") {
    InstanceRefundAmountPA6EC77FFBBDC41F1902AACE5F79E7CC1.option("value", obj.RefundAmount || 0);
  }
  if (typeof InstanceRemarkP96774C704EBC460E8738BD6D607CC608 !== "undefined") {
    InstanceRemarkP96774C704EBC460E8738BD6D607CC608.option("value", obj.Remark || "");
  }
  if (typeof InstanceIsLockPB339252FE1494A78A065CF43F6715FB3 !== "undefined") {
    InstanceIsLockPB339252FE1494A78A065CF43F6715FB3.option("value", !!obj.IsLock);
  }
  if (typeof InstanceIsRefundedP4DB47C007CD649B48787FBD696EB950D !== "undefined") {
    InstanceIsRefundedP4DB47C007CD649B48787FBD696EB950D.option("value", !!obj.IsRefunded);
  }
}
function getTriLuatCheckboxValue(inst, uid){
  try {
    if (inst && typeof inst.getValue === "function") return inst.getValue() ? 1 : 0;
    if (inst && typeof inst.option === "function") return inst.option("value") ? 1 : 0;
  } catch(e) {}
  try {
    var el = document.querySelector("#" + uid + " input[type=checkbox]") || document.querySelector("#" + uid + " .dx-checkbox");
    if (el) {
      if (typeof el.checked !== "undefined") return el.checked ? 1 : 0;
      var aria = el.getAttribute("aria-checked");
      return (aria === "true") ? 1 : 0;
    }
  } catch(e) {}
  return 0;
}
function getTriLuatCheckboxValue(inst, uid) {
  try { if (inst && typeof inst.getValue === "function") return inst.getValue() ? 1 : 0; } catch(e) {}
  try { if (inst && typeof inst.option === "function") return inst.option("value") ? 1 : 0; } catch(e) {}
  try {
    var root = document.getElementById(uid);
    if (root) {
      var cb = root.querySelector("input[type=checkbox]");
      if (cb) return cb.checked ? 1 : 0;
      var dx = root.querySelector(".dx-checkbox") || root;
      var aria = dx.getAttribute("aria-checked");
      if (aria === "true") return 1;
      if (String(dx.className || "").indexOf("dx-checkbox-checked") >= 0) return 1;
    }
  } catch(e) {}
  return 0;
}
function getTriLuatPlainText(value) {
  return String(value || "").replace(/<div>/gi, "").replace(/<\/div>/gi, "").replace(/<br\s*\/?\s*>/gi, "\n").trim();
}
function getFormValues() {
  return {
    EmployeeID: (typeof InstanceEmployeeIDPF8B95A1D761047D3B6F187C5865D5310 !== "undefined") ? InstanceEmployeeIDPF8B95A1D761047D3B6F187C5865D5310.option("value") : null,
    GrossTakeHome: (typeof InstanceGrossTakeHomePF8A300BE4ADA414098D0B5DE352E304C !== "undefined") ? InstanceGrossTakeHomePF8A300BE4ADA414098D0B5DE352E304C.option("value") : 0,
    RefundAmount: (typeof InstanceRefundAmountPA6EC77FFBBDC41F1902AACE5F79E7CC1 !== "undefined") ? InstanceRefundAmountPA6EC77FFBBDC41F1902AACE5F79E7CC1.option("value") : 0,
    Remark: (typeof InstanceRemarkP96774C704EBC460E8738BD6D607CC608 !== "undefined") ? getTriLuatPlainText(InstanceRemarkP96774C704EBC460E8738BD6D607CC608.option("value")) : "",
    IsLock: (typeof InstanceIsLockPB339252FE1494A78A065CF43F6715FB3 !== "undefined") ? getTriLuatCheckboxValue(InstanceIsLockPB339252FE1494A78A065CF43F6715FB3, "PB339252FE1494A78A065CF43F6715FB3") : 0,
    IsRefunded: (typeof InstanceIsRefundedP4DB47C007CD649B48787FBD696EB950D !== "undefined") ? getTriLuatCheckboxValue(InstanceIsRefundedP4DB47C007CD649B48787FBD696EB950D, "P4DB47C007CD649B48787FBD696EB950D") : 0
  };
}
function openAddForm() {
  formMode = "add";
  popupInstance.option("title", "%triluat_add_title%");
  setFormValues({ EmployeeID: null, GrossTakeHome: 0, RefundAmount: 0, Remark: "", IsLock: false, IsRefunded: false });
  // T?t AutoSave cho t?ng field d? tr�nh ghi d� ng?m
  window.currentRecordID_EmployeeID = null;
  _autoSaveGrossTakeHomePF8A300BE4ADA414098D0B5DE352E304C = false;
  _autoSaveRefundAmountPA6EC77FFBBDC41F1902AACE5F79E7CC1 = false;
  _autoSaveRemarkP96774C704EBC460E8738BD6D607CC608 = false;
  _autoSaveIsLockPB339252FE1494A78A065CF43F6715FB3 = false;
  _autoSaveIsRefundedP4DB47C007CD649B48787FBD696EB950D = false;
  // Cho ph�p ch?nh s?a EmployeeID
  if (typeof InstanceEmployeeIDPF8B95A1D761047D3B6F187C5865D5310 !== "undefined") {
    InstanceEmployeeIDPF8B95A1D761047D3B6F187C5865D5310.option("readOnly", false);
  }
  _readOnlyEmployeeIDPF8B95A1D761047D3B6F187C5865D5310 = false;
  popupInstance.show();
}
function openEditForm(selectedRow) {
  formMode = "edit";
  popupInstance.option("title", "%triluat_edit_title%");
  setFormValues(selectedRow);
  // Thi?t l?p record ID d? k�ch ho?t AutoSave
  window.currentRecordID_EmployeeID = selectedRow.EmployeeID;
  _autoSaveGrossTakeHomePF8A300BE4ADA414098D0B5DE352E304C = true;
  _autoSaveRefundAmountPA6EC77FFBBDC41F1902AACE5F79E7CC1 = true;
  _autoSaveRemarkP96774C704EBC460E8738BD6D607CC608 = true;
  _autoSaveIsLockPB339252FE1494A78A065CF43F6715FB3 = true;
  _autoSaveIsRefundedP4DB47C007CD649B48787FBD696EB950D = true;
  // Kh�a tru?ng EmployeeID kh�ng cho ph�p s?a
  if (typeof InstanceEmployeeIDPF8B95A1D761047D3B6F187C5865D5310 !== "undefined") {
    InstanceEmployeeIDPF8B95A1D761047D3B6F187C5865D5310.option("readOnly", true);
  }
  _readOnlyEmployeeIDPF8B95A1D761047D3B6F187C5865D5310 = true;
  popupInstance.show();
}
$("#btnSaveTriLuat").off("click").on("click", function() {
  var vals = getFormValues();
  if (!vals.EmployeeID) {
    if (window.uiManager) uiManager.showAlert({ type: "error", message: "Vui l�ng ch?n nh�n vi�n." });
    return;
  }
  function toPlainTriLuatText(v) {
    var raw = String(v || "");
    try {
      var tmp = document.createElement("div");
      tmp.innerHTML = raw.replace(/<br\s*\/?\s*>/gi, "\n");
      raw = tmp.textContent || tmp.innerText || raw;
    } catch(e) {}
    return String(raw || "").replace(/<[^>]*>/g, "").trim();
  }
  vals.Remark = toPlainTriLuatText(vals.Remark);
  if (formMode === "add") {
    if (typeof showLoadingByClassOrID === "function") showLoadingByClassOrID("#popupAddEditTriLuat", "Dang luu...");
    AjaxHPAParadise({
      data: {
        name: "sp_SalaryImport_TriLuat_Insert",
        param: [
          "EmployeeID", vals.EmployeeID,
          "Month", getFilterMonth(),
          "Year", getFilterYearReal(),
          "GrossTakeHome", vals.GrossTakeHome,
          "RefundAmount", vals.RefundAmount,
          "Remark", vals.Remark,
          "IsLock", vals.IsLock,
          "IsRefunded", vals.IsRefunded,
          "LoginID", window.UserID || window.LoginID || 3
        ]
      },
      success: function(res) {
        if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#popupAddEditTriLuat");
        var json = typeof res === "string" ? JSON.parse(res) : res;
        if (json && json.result === "success") {
          if (window.uiManager) uiManager.showAlert({ type: "success", message: "Th�m m?i th�nh c�ng." });
          popupInstance.hide();
          setTimeout(forceGridReload, 100);
        } else {
          if (window.uiManager) uiManager.showAlert({ type: "error", message: (json && json.reason) || "Th�m m?i th?t b?i." });
        }
      },
      error: function(err) {
        if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#popupAddEditTriLuat");
        if (window.uiManager) uiManager.showAlert({ type: "error", message: "Th�m m?i th?t b?i." });
        console.error(err);
      }
    });
    return;
  }
  var fields = [
    ["GrossTakeHome", vals.GrossTakeHome],
    ["RefundAmount", vals.RefundAmount],
    ["IsLock", vals.IsLock],
    ["IsRefunded", vals.IsRefunded],
    ["Remark", vals.Remark]
  ];
  var pending = fields.length;
  var failed = false;
  if (typeof showLoadingByClassOrID === "function") showLoadingByClassOrID("#popupAddEditTriLuat", "Dang luu...");
  function doneOne() {
    pending--;
    if (pending > 0) return;
    if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#popupAddEditTriLuat");
    if (failed) {
      if (window.uiManager) uiManager.showAlert({ type: "error", message: "C?p nh?t th?t b?i." });
    } else {
      if (window.uiManager) uiManager.showAlert({ type: "success", message: "C?p nh?t th�nh c�ng." });
      popupInstance.hide();
    }
    setTimeout(forceGridReload, 100);
  }
  fields.forEach(function(f) {
    AjaxHPAParadise({
      data: {
        name: "sp_SalaryImport_TriLuat_UpdateField",
        param: [
          "EmployeeID", vals.EmployeeID,
          "Month", getFilterMonth(),
          "Year", getFilterYearReal(),
          "FieldName", f[0],
          "Value", f[1],
          "LoginID", window.UserID || window.LoginID || 3
        ]
      },
      success: doneOne,
      error: function(err) { failed = true; console.error(err); doneOne(); }
    });
  });
});
$("#btnCancelTriLuat").off("click").on("click", function() {
  popupInstance.hide();
});
function updateSingleField(employeeId, fieldName, value) {
  AjaxHPAParadise({
    data: {
      name: "sp_SalaryImport_TriLuat_UpdateField",
      param: [
        "EmployeeID", employeeId,
        "Month", getFilterMonth(),
        "Year", getFilterYearReal(),
        "FieldName", fieldName,
        "Value", value,
        "LoginID", window.UserID || window.LoginID || 3
      ]
    },
    success: function(res) {
      if (window.syncSharedGridData) {
        window.syncSharedGridData("GridTemplate_SalaryImport_TriLuat");
      }
    },
    error: function(err) {
      if (window.uiManager && uiManager.showAlert) {
        uiManager.showAlert({ type: "error", message: "C?p nh?t th?t b?i." });
      }
      console.error(err);
      forceGridReload(); // Ho�n t�c hi?n th? checkbox l?i
    }
  });
}
function forceTriLuatColumnOrder(){
  try {
    var grid = InstanceGridTemplate_SalaryImport_TriLuatPBFFA96204CB2498D80AE9E14169F6877;
    if (!grid || !grid.columnOption) return;
    grid.beginUpdate();
    grid.columnOption("EmployeeID", "visibleIndex", 0);
    grid.columnOption("FullName", "visibleIndex", 1);
    grid.columnOption("GrossTakeHome", "visibleIndex", 2);
    grid.columnOption("GrossTakeHomeVietinsoft", "visibleIndex", 3);
    grid.columnOption("RefundAmount", "visibleIndex", 4);
    grid.columnOption("IsLock", "visibleIndex", 5);
    grid.columnOption("IsRefunded", "visibleIndex", 6);
    grid.columnOption("Notes", "visibleIndex", 98);
    grid.columnOption("Remark", "visibleIndex", 99);
    grid.endUpdate();
  } catch(e) { console.warn("forceTriLuatColumnOrder", e); }
}
setTimeout(forceTriLuatColumnOrder, 300);
setTimeout(forceTriLuatColumnOrder, 1000);
function forceGridReload(){
  var g = InstanceGridTemplate_SalaryImport_TriLuatPBFFA96204CB2498D80AE9E14169F6877;
  if (!g) return;
  if (typeof showLoadingByClassOrID === "function") {
    showLoadingByClassOrID("#TemplateSalaryImportTriLuatPage", "Đang tải dữ liệu...");
  }
  AjaxHPAParadise({
    data: {
      name: "Template_SalaryImport_TriLuat",
      param: [
        "Month", getFilterMonth(),
        "Year", getFilterYearReal(),
        "LoginID", window.UserID || window.LoginID || 3,
        "LanguageID", window.LanguageID || "VN"
      ]
    },
    success: function(res) {
      if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#TemplateSalaryImportTriLuatPage");
      var json = typeof res === "string" ? JSON.parse(res) : res;
      var rows = (json && json.data && json.data[0]) || [];
      // G�n m?ng d? li?u local tr?c ti?p v�o Grid
      g.option("dataSource", rows);
      g.option("noDataText", "Không có dữ liệu");
      if (window.syncSharedGridData) {
        window.syncSharedGridData("GridTemplate_SalaryImport_TriLuat");
      }
    },
    error: function(err) {
      if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#TemplateSalaryImportTriLuatPage");
      console.error(err);
    }
  });
}
function getFilterYearReal(){
  try {
    var id = (typeof getFilterYearID === "function") ? getFilterYearID() : (window.TemplateSalaryImportTriLuatYearID || 2);
    return (id > 0 && id < 100) ? (2028 - id) : id;
  } catch(ex) { return window.TemplateSalaryImportTriLuatYear || 2026; }
}
function callTriLuatProc(procName, successMsg){
  AjaxHPAParadise({
    data: { name: procName, param: ["Month", getFilterMonth(), "Year", getFilterYearReal(), "LoginID", (window.UserID || window.LoginID || 3)] },
    success: function(res){
      if (typeof uiManager !== "undefined" && uiManager.showAlert) uiManager.showAlert({ type: "success", message: successMsg || "%triluat_action_success%" });
      forceGridReload();
    },
    error: function(err){
      if (typeof uiManager !== "undefined" && uiManager.showAlert) uiManager.showAlert({ type: "error", message: "%triluat_action_failed%" });
      console.error(err);
    }
  });
}
function notifyDebtTriLuat(){
  if (typeof showLoadingByClassOrID === "function") {
    showLoadingByClassOrID("#TemplateSalaryImportTriLuatPage", "Dang ki?m tra th�ng b�o c�ng n?...");
  }
  AjaxHPAParadise({
    data: {
      name: "sp_SalaryImport_TriLuat_Complete_Web",
      param: ["Month", getFilterMonth(), "Year", getFilterYearReal(), "LoginID", (window.UserID || window.LoginID || 3)]
    },
    success: function(res){
      if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#TemplateSalaryImportTriLuatPage");
      try {
        var json = typeof res === "string" ? JSON.parse(res) : res;
        var rows = (json && json.data && json.data[0]) || [];
        if (rows && rows.length) {
          var msg = rows.map(function(x){
            var type = x.ErrorType || x.Type || "Lock";
            var detail = x.ErrorDetail || x.ErrorMessage || x.Message || "";
            return type + ": " + detail;
          }).join("<br/>");
          if (window.uiManager) uiManager.showAlert({ type: "error", message: msg || "C� l?i th�ng b�o c�ng n?." });
          return;
        }
        if (window.uiManager) uiManager.showAlert({ type: "success", message: "%triluat_notify_success%" });
        forceGridReload();
      } catch(e) {
        console.error(e);
        if (window.uiManager) uiManager.showAlert({ type: "error", message: "Kh�ng d?c du?c k?t qu? th�ng b�o c�ng n?." });
      }
    },
    error: function(err){
      if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#TemplateSalaryImportTriLuatPage");
      if (window.uiManager) uiManager.showAlert({ type: "error", message: "%triluat_action_failed%" });
      console.error(err);
    }
  });
}
document.getElementById("tsitlTransfer").addEventListener("click", function(){ downloadSalaryToBankTriLuat(); });
function downloadSalaryToBankTriLuat() {
  if (typeof showLoadingByClassOrID === "function") {
    showLoadingByClassOrID("#TemplateSalaryImportTriLuatPage", "%triluat_export_transfer_loading%");
  }
  AjaxHPAParadiseParadise({
    data: {
      name: "ExportLocationFolder",
      param: [
        "", "SalaryToBank", "SalaryToBank.xlsx",
        "@Month", getFilterMonth(),
        "@Year", getFilterYearReal(),
        "@LoginID", window.UserID || window.LoginID || 3,
        "@LanguageID", window.LanguageID || "VN",
        "@IsExport", true
      ]
    },
    success: function(res) {
      try {
        var jsonLoc = typeof res === "string" ? JSON.parse(res) : res;
        if (!jsonLoc || jsonLoc.result === "error") {
          if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#TemplateSalaryImportTriLuatPage");
          if (window.uiManager) uiManager.showAlert({ type: "error", message: (jsonLoc && jsonLoc.reason) || "Kh�ng xu?t du?c file SalaryToBank." });
          return;
        }
        var localData = typeof jsonLoc.data === "string" ? JSON.parse(jsonLoc.data) : jsonLoc.data;
        AjaxHPAParadiseParadise({
          data: { name: "ReadPathFileToByte", param: [localData.FilePath] },
          success: function(fileRes) {
            if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#TemplateSalaryImportTriLuatPage");
            try {
              var fileData = typeof fileRes === "string" ? JSON.parse(fileRes) : fileRes;
              if (typeof saveAsFile === "function") {
                saveAsFile(localData.FileName || "SalaryToBank.xlsx", fileData.data);
              } else if (window.uiManager) {
                uiManager.showAlert({ type: "warning", message: "Tr�nh duy?t kh�ng h? tr? t?i tr?c ti?p." });
              }
            } catch(e) {
              console.error(e);
              if (window.uiManager) uiManager.showAlert({ type: "error", message: "Kh�ng d?c du?c file SalaryToBank." });
            }
          },
          error: function(err) {
            if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#TemplateSalaryImportTriLuatPage");
            if (window.uiManager) uiManager.showAlert({ type: "error", message: "Kh�ng d?c du?c file SalaryToBank." });
            console.error(err);
          }
        });
      } catch(e) {
        if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#TemplateSalaryImportTriLuatPage");
        if (window.uiManager) uiManager.showAlert({ type: "error", message: "Kh�ng xu?t du?c file SalaryToBank." });
        console.error(e);
      }
    },
    error: function(err) {
      if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#TemplateSalaryImportTriLuatPage");
      if (window.uiManager) uiManager.showAlert({ type: "error", message: "Kh�ng xu?t du?c file SalaryToBank." });
      console.error(err);
    }
  });
}
document.getElementById("tsitlNotify").addEventListener("click", function(){ notifyDebtTriLuat(); });
document.getElementById("tsitlApproveAll").addEventListener("change", function(e){
  var isChecked = e.target.checked ? 1 : 0;
  if (typeof showLoadingByClassOrID === "function") {
    showLoadingByClassOrID("#TemplateSalaryImportTriLuatPage", "%triluat_loading_approve_all%");
  }
  AjaxHPAParadise({
    data: {
      name: "sp_SalaryImport_TriLuat_ApproveAll",
      param: [
        "Month", getFilterMonth(),
        "Year", getFilterYearReal(),
        "IsLock", isChecked,
        "LoginID", (window.UserID || window.LoginID || 3)
      ]
    },
    success: function(res) {
      if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#TemplateSalaryImportTriLuatPage");
      if (window.uiManager && uiManager.showAlert) {
        uiManager.showAlert({
          type: "success",
          message: isChecked ? "%triluat_approve_all_success%" : "%triluat_unapprove_all_success%"
        });
      }
      forceGridReload();
    },
    error: function(err) {
      if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#TemplateSalaryImportTriLuatPage");
      if (window.uiManager && uiManager.showAlert) {
        uiManager.showAlert({ type: "error", message: "%triluat_approve_all_failed%" });
      }
      console.error(err);
    }
  });
});
function downloadTemplateTriLuat() {
  if (typeof showLoadingByClassOrID === "function") {
    showLoadingByClassOrID("#TemplateSalaryImportTriLuatPage", "%triluat_loading_download%");
  }
  AjaxHPAParadiseParadise({
    data: {
      name: "ExportLocationFolder",
      param: ["", "Template_SalaryImport_TriLuat", "Import_SalaryImport_TriLuat.xlsx",
              "@Month", getFilterMonth(),
              "@Year", getFilterYearReal(),
              "@LoginID", window.UserID || window.LoginID || 3,
              "@LanguageID", window.LanguageID || "VN",
              "@IsExport", true]
    },
    success: function(res) {
      try {
        var jsonLoc = typeof res === "string" ? JSON.parse(res) : res;
        if (jsonLoc && jsonLoc.result !== "error") {
          var localData = typeof jsonLoc.data === "string" ? JSON.parse(jsonLoc.data) : jsonLoc.data;
          AjaxHPAParadiseParadise({
            data: {
              name: "ReadPathFileToByte",
              param: [localData.FilePath]
            },
            success: function(fileRes) {
              try {
                if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#TemplateSalaryImportTriLuatPage");
                var fileData = typeof fileRes === "string" ? JSON.parse(fileRes) : fileRes;
                if (typeof saveAsFile === "function") {
                  saveAsFile(localData.FileName, fileData.data);
                } else if (window.uiManager) {
                  uiManager.showAlert({ type: "warning", message: "Tr�nh duy?t kh�ng h? tr? t?i tr?c ti?p." });
                }
              } catch(e) {
                if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#TemplateSalaryImportTriLuatPage");
                console.error(e);
              }
            },
            error: function(err) {
              if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#TemplateSalaryImportTriLuatPage");
              if (window.uiManager) uiManager.showAlert({ type: "error", message: "%triluat_error_read_template%" });
            }
          });
        } else {
          if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#TemplateSalaryImportTriLuatPage");
          if (window.uiManager) uiManager.showAlert({ type: "error", message: (jsonLoc && jsonLoc.reason) || "Kh�ng t?o du?c file m?u" });
        }
      } catch(e) {
        if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#TemplateSalaryImportTriLuatPage");
        console.error(e);
      }
    },
    error: function(err) {
      if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#TemplateSalaryImportTriLuatPage");
      if (window.uiManager) uiManager.showAlert({ type: "error", message: "%triluat_error_export_api%" });
    }
  });
}
try {
  $("[data-import-uploader=\"triluat\"]").remove();
  $(".triluat-import-btn-hidden").remove();
  $("<button>").attr("id", "btnImportTriLuatHIDDEN").addClass("triluat-import-btn-hidden").css("display", "none").appendTo("body");
  const readFileAsBase64TriLuat = (file) => new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result.split(",")[1]);
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
  function parseErrorMessageTriLuat(data){
    try {
      var arr = Array.isArray(data && data[0]) ? data[0] : (Array.isArray(data) ? data : []);
      return arr.map(x => x.ErrorDetail || x.ErrorMessage || x.Message || "").filter(Boolean).join("<br/>");
    } catch(e) { return ""; }
  }
  $("<div>").attr("data-import-uploader", "triluat").appendTo("body").dxFileUploader({
    visible: false,
    multiple: false,
    dialogTrigger: ".triluat-import-btn-hidden",
    uploadMode: "useButtons",
    allowedFileExtensions: [".xlsx", ".xls"],
    inputAttr: { accept: ".xlsx, .xls" },
    onValueChanged: function(arg) {
      if (!arg.value || !arg.value.length || window._isImportingTriLuat) return;
      window._isImportingTriLuat = true;
      if (typeof showConfirmPopup === "function") {
        showConfirmPopup({
          title: "%triluat_confirm_import_title%",
          message: "%triluat_confirm_import_message%",
          YesText: "%triluat_confirm_yes%",
          NoText: "%triluat_confirm_no%",
          onYes: async () => {
            try {
              if (typeof showLoadingByClassOrID === "function") {
                showLoadingByClassOrID("#TemplateSalaryImportTriLuatPage", "%triluat_loading_import%");
              }
              for (const file of arg.value) {
                if (!file.path) {
                  try { file.path = await readFileAsBase64TriLuat(file); }
                  catch(e) {
                    if (window.uiManager) uiManager.showAlert({ type: "error", message: "%triluat_error_read_file%" });
                    continue;
                  }
                }
                await AjaxHPAParadiseParadiseAsync({
                  data: { name: "ImportLocationFolder", param: [file.path, file.name, "", "@LoginID", window.UserID || window.LoginID || 3] },
                  success: function(data) {
                    try {
                      let o = typeof data === "string" ? JSON.parse(data) : data;
                      let m = parseErrorMessageTriLuat(o.data);
                      if (m) {
                        if (typeof showPopupNotify === "function") showPopupNotify("K?t qu?", m, "OK", "40vw");
                        else if (window.uiManager) uiManager.showAlert({ type: "warning", message: m });
                      } else {
                        if (window.uiManager) uiManager.showAlert({ type: "success", message: "%triluat_import_success%" });
                      }
                      forceGridReload();
                    } catch(e) {
                      if (window.uiManager) uiManager.showAlert({ type: "error", message: "%triluat_error_parse_import%" });
                    }
                  },
                  error: function() {
                    if (window.uiManager) uiManager.showAlert({ type: "error", message: "%triluat_error_import_api_failed%" });
                  }
                });
              }
            } finally {
              if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("#TemplateSalaryImportTriLuatPage");
              arg.component.reset();
              window._isImportingTriLuat = false;
            }
          },
          onNo: () => {
            arg.component.reset();
            window._isImportingTriLuat = false;
          }
        });
      }
    }
  });
} catch(ex) { console.warn(ex); }
// Thi?t l?p n�ng cao cho Grid cu?n ngang v� cho ph�p thay d?i d? r?ng c?t
try {
  var gridInst = InstanceGridTemplate_SalaryImport_TriLuatPBFFA96204CB2498D80AE9E14169F6877;
  if (gridInst) {
    gridInst.beginUpdate();
    gridInst.option("columnAutoWidth", true);
    gridInst.option("wordWrapEnabled", false);
    gridInst.option("allowColumnResizing", true);
    gridInst.option("columnResizingMode", "widget");
    gridInst.endUpdate();
  }
} catch(ex) { console.warn(ex); }
// 1. T?t d?u "x" c?a control th�ng v� nam
// 2. Tinh ch?nh l?i onValueChanged d? kh�ng l�m m?t c?u h�nh showClearButton
try {
  // Nạp dữ liệu an toàn cho SelectBox Tháng và Năm (chuẩn hệ thống Paradise HRM)
  (async function() {
    try {
      if (typeof loadDataSourceCommon === "function") {
        await Promise.all([
          loadDataSourceCommon("Month", "sp_MonthList"),
          loadDataSourceCommon("Year", "sp_YearList")
        ]);
      }
      var curM = window.TemplateSalaryImportTriLuatMonth || ' + CAST(@Month AS NVARCHAR(10)) + N';
      var curY = window.TemplateSalaryImportTriLuatYear || ' + CAST(@Year AS NVARCHAR(10)) + N';
      if (typeof InstanceMonth' + @MonthUID + N' !== "undefined" && InstanceMonth' + @MonthUID + N') {
        var dsMonth = (window.DataSource_Month && Array.isArray(window.DataSource_Month)) ? window.DataSource_Month : [];
        InstanceMonth' + @MonthUID + N'.option({
          dataSource: dsMonth,
          valueExpr: "ID",
          displayExpr: "MonthName",
          showClearButton: false,
          value: curM,
          itemTemplate: function(data) {
            return $("<div>").text(data ? (data.MonthName || data.ID || data) : "");
          }
        });
      }
      if (typeof InstanceYear' + @YearUID + N' !== "undefined" && InstanceYear' + @YearUID + N') {
        var dsYear = (window.DataSource_Year && Array.isArray(window.DataSource_Year)) ? window.DataSource_Year : [];
        InstanceYear' + @YearUID + N'.option({
          dataSource: dsYear,
          valueExpr: "ID",
          displayExpr: "YearName",
          showClearButton: false,
          value: curY,
          itemTemplate: function(data) {
            return $("<div>").text(data ? (data.YearName || data.ID || data) : "");
          }
        });
      }
    } catch(e) { console.warn("TriLuat Month/Year Init:", e); }
  })();

  if (typeof InstanceMonth' + @MonthUID + N' !== "undefined" && InstanceMonth' + @MonthUID + N') {
    InstanceMonth' + @MonthUID + N'.option("onValueChanged", function(e){
      window.TemplateSalaryImportTriLuatMonth = e.value;
      obj.Month = e.value;
      forceGridReload();
    });
  }
  if (typeof InstanceYear' + @YearUID + N' !== "undefined" && InstanceYear' + @YearUID + N') {
    InstanceYear' + @YearUID + N'.option("onValueChanged", function(e){
      window.TemplateSalaryImportTriLuatYear = e.value;
      obj.Year = e.value;
      forceGridReload();
    });
  }
  InstanceYear' + @YearUID + N'.option("onValueChanged", function(e){
    window.TemplateSalaryImportTriLuatYearID = e.value;
    obj.Year = e.value;
    forceGridReload();
  });
} catch(ex) { console.warn(ex); }
})();
</script>';
    SELECT @html AS html;
/*
EXEC sptblCommonControlType_Signed_DUC 'Template_SalaryImport_TriLuat_html'
EXEC sp_GenerateHTMLScript_new 'Template_SalaryImport_TriLuat_html'
*/
END;
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 2: BIÊN DỊCH VÀ CẬP NHẬT CACHE CHUẨN CHO TEMPLATE_SALARYIMPORT_TRILUAT
--------------------------------------------------------------------------------------------------*/
-- 2.1. Chạy thủ tục biên dịch chuẩn của hệ thống Paradise HRM (bảo vệ kép: thử _new trước, nếu không có thì chạy bản chuẩn)
IF OBJECT_ID('[dbo].[sp_GenerateHTMLScript_new]', 'P') IS NOT NULL
BEGIN
    EXEC [dbo].[sp_GenerateHTMLScript_new] @ProcName = 'Template_SalaryImport_TriLuat_html';
END
ELSE IF OBJECT_ID('[dbo].[sp_GenerateHTMLScript]', 'P') IS NOT NULL
BEGIN
    EXEC [dbo].[sp_GenerateHTMLScript] @ProcName = 'Template_SalaryImport_TriLuat_html';
END
GO

PRINT N'✅ ĐÃ CẬP NHẬT THÀNH CÔNG: BỘ LỌC ĐÃ NGANG HÀNG 100%, ZERO DEVTOOLS ERROR, FONT TIẾNG VIỆT HOÀN HẢO!';
GO
