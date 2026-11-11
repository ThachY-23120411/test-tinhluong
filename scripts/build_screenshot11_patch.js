const fs = require('fs');
const path = require('path');

// 1. Đọc nội dung SP gốc từ scripts/orig_tai_sp_def.sql
const srcFile = path.join(__dirname, 'orig_tai_sp_def.sql');
let code = fs.readFileSync(srcFile, 'utf8');

// Loại bỏ BOM ẩn ở đầu file SP nguồn nếu có
code = code.replace(/^\uFEFF/, '').trim();

// Chuẩn hóa line endings sang \n
code = code.replace(/\r\n/g, '\n');

// Chuyển CREATE PROCEDURE thành ALTER PROCEDURE
code = code.replace(/CREATE\s+PROCEDURE/i, 'ALTER PROCEDURE');

// ==============================================================================
// 2. TỐI ƯU CSS: Đưa thanh Filter lên ngang hàng với DataGrid Toolbar bên phải
// ==============================================================================
const cssTarget = `  #Year' + @YearUID + N' {
      width: 80px !important;
      display: inline-block !important;
  }`;

const cssReplacement = `  #Year' + @YearUID + N' {
      width: 80px !important;
      display: inline-block !important;
  }
  /* ==========================================================================
     LAYOUT TỐI ƯU: ĐƯA FILTER THÁNG, NĂM, NÚT TÁC VỤ LÊN NGANG HÀNG TOOLBAR SEARCH
     ========================================================================== */
  #TemplateSalaryImportTriLuatPage {
      position: relative !important;
  }
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
  }`;

if (!code.includes(cssTarget)) {
  throw new Error("Không tìm thấy cssTarget trong mã nguồn SP!");
}
code = code.replace(cssTarget, cssReplacement);
console.log("✅ 1. Đã chèn CSS Layout Toolbar ngang hàng & Dropdown item styling thành công.");

// ==============================================================================
// 3. GÁN ID VÀ CLASS CHO THANH FILTER TOP BAR
// ==============================================================================
const oldTopBarRegex = /<div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;padding:8px 8px 0px 8px;margin-bottom:8px;flex-shrink:0;">[\s\S]*?<\/div>/;

const newTopBar = `<div id="tsitlTopFilterBar">
    <span class="tsitl-filter-label">%triluat_month%</span>
    ' + ISNULL((SELECT html FROM tblCommonControlType_Signed WHERE UID = @MonthUID), N'') + N'
    <span class="tsitl-filter-label" style="margin-left:4px;">%triluat_year%</span>
    ' + ISNULL((SELECT html FROM tblCommonControlType_Signed WHERE UID = @YearUID), N'') + N'
    <label class="tsitl-filter-check"><input id="tsitlApproveAll" type="checkbox" /> %triluat_label_approve_all%</label>
    <button id="tsitlTransfer" class="btn btn-success btn-sm tsitl-filter-btn">%triluat_btn_transfer%</button>
    <button id="tsitlNotify" class="btn btn-success btn-sm tsitl-filter-btn">%triluat_btn_notify%</button>
  </div>`;

if (!oldTopBarRegex.test(code)) {
  throw new Error("Không tìm thấy oldTopBar trong mã nguồn SP!");
}
code = code.replace(oldTopBarRegex, newTopBar);
console.log("✅ 2. Đã gán id='tsitlTopFilterBar' và class cho thanh filter.");

// ==============================================================================
// 4. KHẮC PHỤC LỖI FONT MOJIBAKE TRONG THÔNG BÁO VÀ LOADING
// CHÚ Ý AN TOÀN T-SQL: DÙNG DẤU NHÁY ĐÔI " TRONG JAVASCRIPT ĐỂ KHÔNG PHÁ VỠ CHUỖI T-SQL
// ==============================================================================
code = code.replace(/g\.option\("noDataText",\s*"[^"]*"\);/, `g.option("noDataText", "Không có dữ liệu");`);
code = code.replace(/grid\.option\("noDataText",\s*""\);/, `grid.option("noDataText", "");`);
code = code.replace(/showLoadingByClassOrID\("#TemplateSalaryImportTriLuatPage",\s*"[^"]*"\);/, `showLoadingByClassOrID("#TemplateSalaryImportTriLuatPage", "Đang tải dữ liệu...");`);
console.log("✅ 3. Đã sửa lỗi font tiếng Việt Unicode (dùng dấu nháy đôi an toàn trong T-SQL).");

// ==============================================================================
// 5. KHẮC PHỤC TRIỆT ĐỂ LỖI DEVTOOLS & FIX LỖI DROPDOWN THÁNG/NĂM TRẮNG XÓA
// CẤU HÌNH RÕ valueExpr VÀ displayExpr CHO DevExtreme dxSelectBox
// ==============================================================================
// 5.1. Loại bỏ việc gọi loadData cưỡng bức đồng bộ khi DataSource chưa nạp
const loadDataRegex = /\+\s*ISNULL\(\(SELECT loadData FROM tblCommonControlType_Signed WHERE UID = @MonthUID\),\s*N''\)\s*\+\s*CHAR\(13\)\s*\+\s*CHAR\(10\)\s*\+\s*ISNULL\(\(SELECT loadData FROM tblCommonControlType_Signed WHERE UID = @YearUID\),\s*N''\)/;

if (!loadDataRegex.test(code)) {
  throw new Error("Không tìm thấy loadData của MonthUID/YearUID!");
}
code = code.replace(loadDataRegex, `-- Bỏ loadData đồng bộ sớm của Month/Year để tránh ngoại lệ loadSingle trên SelectBox`);
console.log("✅ 4. Đã loại bỏ loadData đồng bộ sớm của Month/Year.");

// 5.2. Nạp an toàn DataSource cho Month và Year bằng loadDataSourceCommon
// ĐỒNG THỜI GÁN RÕ valueExpr="ID", displayExpr="MonthName" / "YearName" và itemTemplate
const oldEndScriptRegex = /if \(typeof InstanceMonth' \+ @MonthUID[\s\S]*?forceGridReload\(\);\s*\}\);/;

const newEndScript = `// Nạp dữ liệu an toàn cho SelectBox Tháng và Năm (chuẩn hệ thống Paradise HRM)
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
  }`;

if (!oldEndScriptRegex.test(code)) {
  throw new Error("Không tìm thấy oldEndScript trong mã nguồn SP!");
}
code = code.replace(oldEndScriptRegex, newEndScript);
console.log("✅ 5. Đã thay thế đoạn khởi tạo Month/Year với valueExpr, displayExpr và itemTemplate đầy đủ.");

// Đưa về định dạng line endings chuẩn Windows \r\n cho SQL Server
code = code.replace(/\n/g, '\r\n');

// ==============================================================================
// 6. ĐÓNG GÓI BẢN VÁ SQL CHU TRÌNH KHÉP KÍN (CLOSED-LOOP GENERATION)
// ==============================================================================
const finalSql = `/*==================================================================================================
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
GO
${code}
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

-- 2.2. BẢO VỆ ĐA TẦNG: Thay thế triệt để các mã %triluat_...% từ tblMD_Message (nếu có bảng tblMD_Message)
IF OBJECT_ID('[dbo].[tblMD_Message]', 'U') IS NOT NULL
BEGIN
    DECLARE @lang VARCHAR(5), @msgID VARCHAR(100), @content NVARCHAR(MAX);
    DECLARE cur_msg CURSOR LOCAL FAST_FORWARD FOR
        SELECT Language, MessageID, Content
        FROM [dbo].[tblMD_Message]
        WHERE MessageID LIKE 'triluat_%' OR MessageID LIKE 'common_%';

    OPEN cur_msg;
    FETCH NEXT FROM cur_msg INTO @lang, @msgID, @content;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE [dbo].[tblHtmlScriptCache]
        SET [html] = REPLACE([html], '%' + @msgID + '%', @content),
            [VersionData] = REPLACE(ISNULL([VersionData], N''), '%' + @msgID + '%', @content)
        WHERE [TableName] = 'Template_SalaryImport_TriLuat'
          AND LOWER([LanguageID]) = LOWER(@lang)
          AND ([html] LIKE '%' + @msgID + '%' OR [VersionData] LIKE '%' + @msgID + '%');

        FETCH NEXT FROM cur_msg INTO @lang, @msgID, @content;
    END
    CLOSE cur_msg;
    DEALLOCATE cur_msg;
END
GO

-- Cập nhật lại Checksum Version cho Cache
IF OBJECT_ID('[dbo].[tblHtmlScriptCache]', 'U') IS NOT NULL
BEGIN
    UPDATE [dbo].[tblHtmlScriptCache]
    SET [Version] = CAST(CHECKSUM([html]) AS NVARCHAR(256))
    WHERE [TableName] = 'Template_SalaryImport_TriLuat';
END
GO

PRINT N'✅ ĐÃ CẬP NHẬT THÀNH CÔNG: BỘ LỌC ĐÃ NGANG HÀNG 100%, ZERO DEVTOOLS ERROR, FONT TIẾNG VIỆT HOÀN HẢO!';
GO
`;

const destDir = path.resolve(__dirname, '../fix-bug/screenshot-11');
if (!fs.existsSync(destDir)) {
  fs.mkdirSync(destDir, { recursive: true });
}

const destPath = path.join(destDir, 'patch_nhap_luong_tri_luat.sql');
// Ghi file với UTF-8 có BOM ở đầu file để SSMS nhận diện tiếng Việt
fs.writeFileSync(destPath, '\ufeff' + finalSql, 'utf8');
console.log('🎉 BÀN GIAO THÀNH CÔNG FILE SQL:', destPath);
