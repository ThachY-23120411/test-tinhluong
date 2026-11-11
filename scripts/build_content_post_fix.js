const fs = require('fs');
const path = require('path');

const originPath = path.resolve(__dirname, '../fix-bug/noi_dung_dang_tai/origin.sql');
let code = fs.readFileSync(originPath, 'utf8');

// Ensure ALTER PROCEDURE
code = code.replace(/CREATE\s+PROCEDURE\s+\[dbo\]\.\[sp_KPIContentPost_html\]/i, 'ALTER PROCEDURE [dbo].[sp_KPIContentPost_html]');

// Replace CSS block
const cssStartMarker = '/* ====== FIX RESPONSIVE TOOLBAR CHO N';
const cssEndMarker = '.c-container {';

const startIndex = code.indexOf(cssStartMarker);
const endIndex = code.indexOf(cssEndMarker);

if (startIndex === -1 || endIndex === -1) {
  console.error('Cannot locate CSS block in origin.sql');
  process.exit(1);
}

const standardCss = `/* ============================================================================
           BỘ QUY CHUẨN RESPONSIVE TOOLBAR, WIDGET & DATAGRID (/responsive-rules)
           PHÂN HỆ: Trang Chủ CRM > Nhiệm vụ > Nội dung đăng tải (sp_KPIContentPost)
           ============================================================================ */

        /* 1. Nhóm 1: Master Layout Lock & Max-Width Pinning trên màn hình lớn 2K/4K */
        #contentComponent,
        #GridContentPost {
            width: 100% !important;
            max-width: 1920px !important;
            min-width: 0 !important;
            margin: 0 auto !important;
            box-sizing: border-box !important;
        }

        /* 2. Nhóm 4 & Golden CSS Fix: Đưa Header Panel & Toolbar về Normal Document Flow */
        #GridContentPost .dx-datagrid-header-panel {
            height: auto !important;
            min-height: auto !important;
            overflow: visible !important;
            padding: 4px 0 8px 0 !important;
            margin-bottom: 8px !important;
        }

        #GridContentPost .dx-toolbar {
            height: auto !important;
            min-height: auto !important;
            position: static !important;
            overflow: visible !important;
            background: transparent !important;
            padding: 4px 0 !important;
            width: 100% !important;
            max-width: 100% !important;
            min-width: 0 !important;
            box-sizing: border-box !important;
        }

        /* 3. Nhóm 6.5: Container Toolbar - STRICT flex-start chống dạt khoảng cách */
        #GridContentPost .dx-toolbar-items-container {
            height: auto !important;
            min-height: 44px !important;
            display: flex !important;
            flex-direction: row !important;
            flex-wrap: wrap !important;
            align-items: center !important;
            justify-content: flex-start !important; /* QUY TẮC 6.5: CẤM space-between */
            row-gap: 8px !important;
            column-gap: 10px !important;
            width: 100% !important;
            max-width: 100% !important;
            min-width: 0 !important;
            padding: 0 !important;
            margin: 0 !important;
            position: relative !important;
            overflow: visible !important;
            box-sizing: border-box !important;
        }

        /* 4. Nhóm 6.4: Triệt tiêu thẻ bọc trung gian - Đồng cấp hóa Sibling (Flat Sibling & Row Consolidation) */
        #GridContentPost .dx-toolbar-before,
        #GridContentPost .dx-toolbar-before > .dx-toolbar-item,
        #GridContentPost .dx-toolbar-before > .dx-toolbar-item > .dx-toolbar-item-content,
        #GridContentPost .c-filter {
            display: contents !important;
        }

        /* 5. Nhóm 2 & 7: Khóa kích thước compact và Khóa nguyên tử Widget chữ */
        #GridContentPost .c-filter > * {
            flex: 0 0 auto !important;
            flex-shrink: 0 !important;
            white-space: nowrap !important;
        }

        #GridContentPost #cFilterFromDate,
        #GridContentPost #cFilterToDate {
            height: 32px !important;
            padding: 4px 8px !important;
            border: 1px solid #334155 !important;
            border-radius: 6px !important;
            font-size: 12px !important;
            width: 130px !important;
            box-sizing: border-box !important;
            background-color: #1e293b !important;
            color: #ffffff !important;
            color-scheme: dark !important;
        }

        #GridContentPost #contentFilterEmployeeToolbar {
            width: 160px !important;
        }

        /* Khóa nguyên tử cụm Checkbox: không rớt dòng chữ lẻ loi */
        #GridContentPost .c-checkbox-group,
        #GridContentPost .c-filter > div:has(#cFilterViewAll) {
            display: inline-flex !important;
            align-items: center !important;
            gap: 12px !important;
            flex: 0 0 auto !important;
            flex-shrink: 0 !important;
            white-space: nowrap !important;
            margin: 0 !important;
        }

        #GridContentPost .c-checkbox-group > div {
            display: inline-flex !important;
            align-items: center !important;
            gap: 5px !important;
            flex-shrink: 0 !important;
            white-space: nowrap !important;
        }

        /* 6. Nhóm 3 & 6.3: Khối Hành Động Bên Phải (Tự động neo sát lề phải) */
        #GridContentPost .dx-toolbar-after {
            position: static !important;
            margin-left: auto !important; /* ĐẨY SÁT PHẢI CẢ KHI HÀNG 1 LẪN KHI RỚT HÀNG 2 */
            display: flex !important;
            flex-direction: row !important;
            align-items: center !important;
            gap: 8px !important;
            flex: 0 0 auto !important;
            flex-shrink: 0 !important;
            width: auto !important;
            height: auto !important;
            padding: 0 !important;
            overflow: visible !important;
            flex-wrap: nowrap !important;
            white-space: nowrap !important;
        }

        #GridContentPost .dx-toolbar-center {
            display: none !important;
        }

        /* Bảo toàn Style gốc của Icon Buttons */
        #GridContentPost .dx-toolbar-after .dx-button,
        #GridContentPost .dx-datagrid-column-chooser-button {
            width: 32px !important;
            height: 32px !important;
            padding: 0 !important;
            border-radius: 6px !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
        }

        /* Styling Nút Thêm nội dung */
        #GridContentPost #btnOpenContentModal {
            height: 32px !important;
            padding: 0 14px !important;
            border: none !important;
            border-radius: 6px !important;
            font-size: 12px !important;
            font-weight: 500 !important;
            display: inline-flex !important;
            align-items: center !important;
            gap: 6px !important;
            background-color: #198754 !important;
            color: white !important;
            white-space: nowrap !important;
            flex-shrink: 0 !important;
        }

        /* 8. SỬA LỖI SEARCHBOX: Chống icon kính lúp đè lên chữ placeholder */
        #GridContentPost .dx-datagrid-search-panel,
        #GridContentPost .dx-searchbox {
            background-color: #1e293b !important;
            border: 1px solid #334155 !important;
            border-radius: 6px !important;
            height: 32px !important;
            width: 235px !important;
            position: relative !important;
            overflow: hidden !important;
        }

        #GridContentPost .dx-datagrid-search-panel.dx-state-focused,
        #GridContentPost .dx-searchbox.dx-state-focused {
            border-color: #3b82f6 !important;
            box-shadow: 0 0 0 1px #3b82f6 !important;
        }

        /* FIX SEARCHBOX ICON OVERLAPPING TEXT: Lùi lề trái 34px chống đè kính lúp */
        #GridContentPost .dx-datagrid-search-panel .dx-texteditor-input,
        #GridContentPost .dx-searchbox .dx-texteditor-input {
            color: #ffffff !important;
            background-color: transparent !important;
            font-size: 12px !important;
            height: 32px !important;
            padding-left: 34px !important;
            box-sizing: border-box !important;
        }

        #GridContentPost .dx-datagrid-search-panel .dx-placeholder,
        #GridContentPost .dx-datagrid-search-panel .dx-placeholder::before,
        #GridContentPost .dx-searchbox .dx-placeholder,
        #GridContentPost .dx-searchbox .dx-placeholder::before {
            color: #94a3b8 !important;
            -webkit-text-fill-color: #94a3b8 !important;
            opacity: 1 !important;
            padding-left: 34px !important;
        }

        #GridContentPost .dx-datagrid-search-panel .dx-icon-search,
        #GridContentPost .dx-searchbox .dx-icon-search {
            color: #94a3b8 !important;
            left: 8px !important;
        }

        #GridContentPost .dx-datagrid-search-panel .dx-clear-button-area .dx-icon-clear,
        #GridContentPost .dx-searchbox .dx-clear-button-area .dx-icon-clear {
            color: #94a3b8 !important;
        }

        /* 9. Nhóm 9: Cô lập cuộn Bảng dữ liệu lớn */
        #GridContentPost .dx-datagrid-headers,
        #GridContentPost .dx-datagrid-rowsview {
            overflow-x: auto !important;
            -webkit-overflow-scrolling: touch !important;
        }

        `;

code = code.substring(0, startIndex) + standardCss + code.substring(endIndex);

// Update JS: Line 960 $container to display: contents
code = code.replace(
  /\$container\s*=\s*\$''<div class="c-filter"[^>]*>''\);/,
  `$container = $('<div class="c-filter" style="display: contents;">');`
);

// Update JS: Line 986 $checkboxRow to add class c-checkbox-group
code = code.replace(
  /\$checkboxRow\s*=\s*\$''<div style="display:\s*inline-flex;[^>]*>''\);/,
  `$checkboxRow = $('<div class="c-checkbox-group" style="display: inline-flex; align-items: center; gap: 12px; flex-shrink: 0; margin-left: 0; white-space: nowrap;">');`
);

// Assemble Clean Code 3 Steps
const patchSql = `-- ===================================================================
-- PATCH: [sp_KPIContentPost_html] & [sp_KPIContentPost]
-- PHÂN HỆ: Trang Chủ CRM > Nhiệm vụ > Nội dung đăng tải (MnuKPI005)
-- DATABASE: Vietinsoft_ForTest_Tai2
-- ÁP DỤNG BỘ 9 NHÓM QUY TẮC BẤT BIẾN /responsive-rules & CLEAN CODE 3 BƯỚC:
--   1. Master Layout Lock: Khóa max-width 1920px, căn giữa margin: 0 auto.
--   2. Normal Document Flow: Triệt tiêu 100% lỗi che khuất DataGrid (height: auto, position: static).
--   3. Quy tắc 6.4: display: contents Flattening trên .c-filter và .dx-toolbar-before triệt tiêu bẫy thẻ bọc trung gian.
--   4. Quy tắc 6.5: STRICT justify-content: flex-start, cấm space-between; loại bỏ media query ép 100% width cột tháp.
--   5. Quy tắc 6 & Row Consolidation: Cụm Checkbox và Cụm Action gộp chung Hàng 2 ngăn nắp, triệt tiêu lỗi 4 hàng.
--   6. Quy tắc 7: Atomic Text Lock cho toàn bộ labels và checkboxes (flex-shrink: 0, white-space: nowrap).
--   7. SỬA LỖI SEARCHBOX: Thêm padding-left 34px chống icon kính lúp đè lên chữ placeholder "Tìm kiếm theo nội dung".
--   8. Quy tắc 9: Cô lập cuộn Bảng dữ liệu lớn (overflow-x: auto trên DataGrid headers và rowsview).
-- ===================================================================

USE [Vietinsoft_ForTest_Tai2]
GO

-- ===================================================================
-- BƯỚC 1: CẬP NHẬT GIAO DIỆN STORED PROCEDURE [sp_KPIContentPost_html]
-- ===================================================================
` + code.trim() + `
GO

-- ===================================================================
-- BƯỚC 2: CHUẨN HÓA STORED PROCEDURE ĐIỀU PHỐI [dbo].[sp_KPIContentPost]
-- ===================================================================
ALTER PROCEDURE [dbo].[sp_KPIContentPost](
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
    WHERE TableName = 'sp_KPIContentPost'
      AND ScreenType = -1
      AND LanguageID = @LanguageID;
END
GO

-- ===================================================================
-- BƯỚC 3: BIÊN DỊCH MÃ NGUỒN GIAO DIỆN VÀO BẢNG CACHE VÀ CẬP NHẬT VERSION
-- ===================================================================
IF OBJECT_ID('dbo.sp_GenerateHTMLScript_new', 'P') IS NOT NULL
BEGIN
    EXEC sp_GenerateHTMLScript_new 'sp_KPIContentPost_html', 'VN', 'sp_KPIContentPost';
    EXEC sp_GenerateHTMLScript_new 'sp_KPIContentPost_html', 'EN', 'sp_KPIContentPost';
END
ELSE
BEGIN
    EXEC sp_GenerateHTMLScript 'sp_KPIContentPost_html';
END
GO
`;

const outputPath = path.resolve(__dirname, '../fix-bug/noi_dung_dang_tai/fix-bug.sql');
fs.writeFileSync(outputPath, patchSql, 'utf8');
console.log('Successfully generated fix-bug.sql for noi_dung_dang_tai!');
