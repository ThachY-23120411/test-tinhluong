const fs = require('fs');
const path = require('path');

const originPath = path.resolve('fix-bug/zalo_ai_generated_history/origin.sql');
const outDir = path.resolve('fix-bug/zalo_ai_generated_history');
const fixPath = path.join(outDir, 'fix-bug.sql');

const origin = fs.readFileSync(originPath, 'utf8');

// The upgraded responsive CSS block
const responsiveCss = `
        /* ============================================================================
           BỘ QUY CHUẨN RESPONSIVE TOOLBAR, WIDGET & DATAGRID (/responsive-rules)
           ============================================================================ */

        /* 1. Nhóm 1: Master Layout Lock & Max-Width Pinning trên 2K/4K */
        #sp_zalo_AIgenerated_history_html {
            height: 100%;
            display: flex;
            flex-direction: column;
            gap: 12px;
            overflow-x: hidden;
            overflow-y: auto;
            max-width: 1920px;
            margin: 0 auto;
            box-sizing: border-box;
        }

        .grid-section {
            border-radius: 8px;
            padding: 12px 15px;
            flex: 1;
            display: flex;
            flex-direction: column;
            min-height: 380px;
            box-sizing: border-box;
            width: 100%;
            max-width: 100%;
        }

        .history-grid-container {
            flex: 1;
            min-height: 0;
            width: 100%;
            max-width: 100%;
        }

        /* 2. Nhóm 4 & Golden CSS Fix: Đưa Header Panel & Toolbar về Normal Document Flow */
        #GridZaloHistory .dx-datagrid-header-panel {
            height: auto !important;
            min-height: auto !important;
            overflow: visible !important;
            padding: 4px 0 8px 0 !important;
        }

        #GridZaloHistory .dx-toolbar {
            height: auto !important;
            min-height: auto !important;
            position: static !important;
            overflow: visible !important;
            background: transparent !important;
            padding: 4px 0 !important;
            margin-bottom: 8px !important;
            width: 100% !important;
            max-width: 100% !important;
            min-width: 0 !important;
            box-sizing: border-box !important;
        }

        /* 3. Nhóm 6.5: Container Toolbar - STRICT flex-start chống dạt phải */
        #GridZaloHistory .dx-toolbar-items-container {
            height: auto !important;
            min-height: 44px !important;
            display: flex !important;
            flex-direction: row !important;
            flex-wrap: wrap !important;
            align-items: center !important;
            justify-content: flex-start !important; /* QUY TẮC 6.5: CẤM space-between */
            row-gap: 8px !important;
            column-gap: 12px !important;
            width: 100% !important;
            max-width: 100% !important;
            min-width: 0 !important;
            padding: 0 !important;
            margin: 0 !important;
            position: relative !important;
            overflow: visible !important;
            box-sizing: border-box !important;
        }

        /* 4. Nhóm 3: Khối Bộ Lọc Bên Trái (Thanh Capsule Pills) */
        #GridZaloHistory .dx-toolbar .dx-toolbar-before {
            position: static !important;
            display: flex !important;
            flex-direction: row !important;
            align-items: center !important;
            gap: 8px !important;
            flex: 0 1 auto !important;
            max-width: 100% !important;
            min-width: 0 !important;
            height: auto !important;
            overflow: visible !important;
            padding: 0 !important;
        }

        /* 5. Nhóm 2 & 4: Thanh Capsule cuộn ngang cục bộ êm ái khi màn hình co hẹp */
        .zalo-pill-group {
            display: inline-flex !important;
            align-items: center !important;
            background: var(--bs-tertiary-bg, rgba(128, 128, 128, 0.08)) !important;
            border: 1px solid var(--bs-border-color, rgba(128, 128, 128, 0.2)) !important;
            border-radius: 20px !important;
            padding: 2px 4px !important;
            gap: 4px !important;
            max-width: 100% !important;
            overflow-x: auto !important;
            -webkit-overflow-scrolling: touch !important;
            scrollbar-width: none !important;
            -ms-overflow-style: none !important;
            flex: 0 1 auto !important;
        }

        .zalo-pill-group::-webkit-scrollbar {
            display: none !important;
            width: 0 !important;
            height: 0 !important;
        }

        /* 6. Nhóm 7: Khóa nguyên tử Widget chữ (Atomic Text & Non-Shrink Lock) */
        .zalo-pill-btn {
            background: transparent !important;
            border: none !important;
            outline: none !important;
            color: var(--bs-secondary-color, var(--bs-body-color, #6c757d)) !important;
            border-radius: 16px !important;
            padding: 5px 14px !important;
            font-size: 12px !important;
            font-weight: 500 !important;
            cursor: pointer !important;
            transition: all 0.2s ease !important;
            line-height: 1.4 !important;
            flex: 0 0 auto !important;
            flex-shrink: 0 !important;
            white-space: nowrap !important;
        }

        .zalo-pill-btn.active {
            background: #00b074 !important;
            color: #ffffff !important;
            font-weight: 600 !important;
            box-shadow: 0 2px 6px rgba(0, 176, 116, 0.35) !important;
        }

        /* 7. Nhóm 3 & 6.3: Khối Hành Động Bên Phải (Ưu tiên rớt dòng từ phải sang trái, bám lề phải) */
        #GridZaloHistory .dx-toolbar .dx-toolbar-after {
            position: static !important;
            margin-left: auto !important;
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

        #GridZaloHistory .dx-toolbar .dx-toolbar-center {
            display: none !important;
        }

        /* Nhóm 2: Bất biến Style gốc của Icon Buttons (Refresh, Column Chooser) */
        #GridZaloHistory .dx-toolbar .dx-toolbar-after .dx-button {
            border: none !important;
            background: transparent !important;
            box-shadow: none !important;
            flex-shrink: 0 !important;
        }

        /* Nhóm 2 & 7: Searchbox kích thước chuẩn, không đè chữ */
        #GridZaloHistory .dx-toolbar-item-search-panel,
        #GridZaloHistory .dx-toolbar .dx-toolbar-after .dx-toolbar-item:has(.dx-searchbox),
        #GridZaloHistory .dx-toolbar .dx-toolbar-after .dx-toolbar-item:has(.dx-datagrid-search-panel) {
            flex: 0 0 240px !important;
            flex-shrink: 0 !important;
            width: 240px !important;
            min-width: 200px !important;
            max-width: 260px !important;
        }

        #GridZaloHistory .dx-datagrid-search-panel,
        #GridZaloHistory .dx-searchbox {
            width: 100% !important;
        }

        /* 8. Nhóm 9: Cô lập cuộn Bảng dữ liệu lớn (Wide-Component Scroll Isolation) */
        #GridZaloHistory .dx-datagrid {
            font-size: 14px !important;
            height: calc(100vh - 160px) !important;
            min-height: 400px !important;
            width: 100% !important;
            max-width: 100% !important;
            table-layout: fixed !important;
        }

        #GridZaloHistory .dx-datagrid-rowsview {
            overflow-x: auto !important;
            -webkit-overflow-scrolling: touch !important;
        }
`;

// Extract procedure 1 definition
const proc1Start = origin.indexOf('CREATE PROCEDURE [dbo].[sp_zalo_AIgenerated_history_html]');
const proc1End = origin.indexOf('-- ===================================================================\n-- STORED PROCEDURE 2');
let proc1Content = origin.substring(proc1Start, proc1End !== -1 ? proc1End : origin.indexOf('-- STORED PROCEDURE 2'));

// Replace CREATE with ALTER
proc1Content = proc1Content.replace('CREATE PROCEDURE [dbo].[sp_zalo_AIgenerated_history_html]', 'ALTER PROCEDURE [dbo].[sp_zalo_AIgenerated_history_html]');

// Replace the old <style> block inside proc1Content
const styleStart = proc1Content.indexOf('<style>');
const styleEnd = proc1Content.indexOf('</style>');
if (styleStart === -1 || styleEnd === -1) {
    console.error('Style block not found in proc1Content');
    process.exit(1);
}

proc1Content = proc1Content.substring(0, styleStart) + '<style>' + responsiveCss + proc1Content.substring(styleEnd);

// Add grid responsive options in JS
const gridInstanceMarker = 'if (gridInstance) {\n            gridInstance.option("dataSource", ds_GridZaloHistory);';
const gridInstanceMarkerCrLf = 'if (gridInstance) {\r\n            gridInstance.option("dataSource", ds_GridZaloHistory);';

const targetMarker = proc1Content.indexOf(gridInstanceMarker) !== -1 ? gridInstanceMarker : gridInstanceMarkerCrLf;
const replacementWithConfig = `if (gridInstance) {
            gridInstance.option({
                columnAutoWidth: false,
                allowColumnResizing: true,
                columnResizingMode: "widget",
                columnMinWidth: 80,
                wordWrapEnabled: false
            });
            gridInstance.option("dataSource", ds_GridZaloHistory);`;

if (proc1Content.indexOf(targetMarker) !== -1) {
    proc1Content = proc1Content.replace(targetMarker, replacementWithConfig);
}

// Clean up trailing comments or go
const goIdx = proc1Content.lastIndexOf('GO');
if (goIdx !== -1) {
    proc1Content = proc1Content.substring(0, goIdx).trim();
}

// Build Step 2: sp_zalo_AIgenerated_history
const step2 = `ALTER PROCEDURE [dbo].[sp_zalo_AIgenerated_history](
    @LoginID INT = NULL,
    @LanguageID VARCHAR(5) = 'VN',
    @isWeb INT = 0
)
AS
BEGIN
    SET NOCOUNT ON;
    IF @LanguageID IS NULL OR LTRIM(RTRIM(@LanguageID)) = ''
        SET @LanguageID = 'VN';
    
    DECLARE @html NVARCHAR(MAX);
    SELECT TOP 1 @html = html
    FROM tblHtmlScriptCache
    WHERE TableName = 'sp_zalo_AIgenerated_history'
      AND ScreenType = -1
      AND LanguageID = @LanguageID;

    IF @html IS NULL OR LEN(@html) = 0
    BEGIN
        SELECT TOP 1 @html = html
        FROM tblHtmlScriptCache
        WHERE TableName = 'sp_zalo_AIgenerated_history_html'
          AND ScreenType = -1
          AND LanguageID = @LanguageID;
    END

    IF @html IS NULL OR LEN(@html) = 0
    BEGIN
        EXEC sp_zalo_AIgenerated_history_html @LoginID = @LoginID, @LanguageID = @LanguageID, @isWeb = @isWeb;
        RETURN;
    END

    SELECT @html AS html;
END
GO`;

// Build Step 3: Compile cache
const step3 = `IF OBJECT_ID('dbo.sp_GenerateHTMLScript_new', 'P') IS NOT NULL
BEGIN
    EXEC sp_GenerateHTMLScript_new 'sp_zalo_AIgenerated_history_html', 'VN', 'sp_zalo_AIgenerated_history';
    EXEC sp_GenerateHTMLScript_new 'sp_zalo_AIgenerated_history_html', 'EN', 'sp_zalo_AIgenerated_history';
END
ELSE
BEGIN
    EXEC sp_GenerateHTMLScript 'sp_zalo_AIgenerated_history_html';
END
GO`;

const fullFixSql = `USE [Vietinsoft_ForTest_Tai2]
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
-- 7. Quy tắc 9: Cô lập cuộn Bảng dữ liệu lớn (overflow-x: auto trên DataGrid)
-- ===================================================================

${proc1Content}
GO

-- ===================================================================
-- BƯỚC 2: CHUẨN HÓA STORED PROCEDURE ĐIỀU PHỐI [sp_zalo_AIgenerated_history]
-- ===================================================================
${step2}

-- ===================================================================
-- BƯỚC 3: BIÊN DỊCH MÃ NGUỒN GIAO DIỆN VÀO BẢNG CACHE VÀ CẬP NHẬT VERSION
-- ===================================================================
${step3}
`;

fs.writeFileSync(fixPath, fullFixSql, 'utf8');
console.log('Successfully generated fix-bug.sql:', fs.statSync(fixPath).size, 'bytes');

if (fs.existsSync('scripts/generate_build_script.js')) {
    fs.unlinkSync('scripts/generate_build_script.js');
}
