# Create fix-bug.sql from origin.sql
$originPath = "fix-bug/crm_quan_ly_phan_he/origin.sql"
$originContent = [System.IO.File]::ReadAllText($originPath, [System.Text.Encoding]::UTF8)

# Replacement CSS
$newCss = @"
        /* ============================================================================
           BỘ QUY CHUẨN RESPONSIVE TOOLBAR, WIDGET & DATAGRID (/responsive-rules)
           PHÂN HỆ: Trang Chủ CRM > Báo giá > Quản lý phân hệ (sp_Sub_SubProduct)
           ============================================================================ */

        /* 1. Nhóm 1: Master Layout Lock & Max-Width Pinning */
        #sp_Sub_SubProduct_html,
        #gridSubProductList {
            width: 100% !important;
            max-width: 1920px !important;
            min-width: 0 !important;
            margin: 0 auto !important;
            box-sizing: border-box !important;
        }

        /* Ẩn header section gốc */
        #sp_Sub_SubProduct_html .header-section {
            display: none !important;
        }

        /* 2. Nhóm 4 & Golden CSS Fix: Đưa Header Panel & Toolbar về Normal Document Flow */
        #gridSubProductList .dx-datagrid-header-panel {
            height: auto !important;
            min-height: auto !important;
            overflow: visible !important;
            padding: 4px 0 8px 0 !important;
        }

        #sp_Sub_SubProduct_html .dx-toolbar,
        #gridSubProductList .dx-toolbar {
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
        #sp_Sub_SubProduct_html .dx-toolbar-items-container,
        #gridSubProductList .dx-toolbar-items-container {
            height: auto !important;
            min-height: 40px !important;
            display: flex !important;
            flex-direction: row !important;
            flex-wrap: wrap !important;
            align-items: center !important;
            justify-content: flex-start !important;
            gap: 8px !important;
            width: 100% !important;
            max-width: 100% !important;
            min-width: 0 !important;
            padding: 0 !important;
            margin: 0 !important;
            position: relative !important;
            overflow: visible !important;
            box-sizing: border-box !important;
        }

        /* 4. Nhóm 6.4: Triệt tiêu thứ bậc trung gian (Flat Sibling) */
        #sp_Sub_SubProduct_html .dx-toolbar-before,
        #gridSubProductList .dx-toolbar-before {
            display: contents !important;
        }

        /* 5. Nhóm 3 & 6.3: Khối Hành Động Bên Phải (Tự động neo sát lề phải & Wrap mượt mà) */
        #sp_Sub_SubProduct_html .dx-toolbar-after,
        #gridSubProductList .dx-toolbar-after {
            position: static !important;
            margin-left: auto !important;
            display: flex !important;
            flex-direction: row !important;
            align-items: center !important;
            flex-wrap: wrap !important;
            gap: 8px !important;
            flex: 0 0 auto !important;
            width: auto !important;
            max-width: 100% !important;
            height: auto !important;
            padding: 0 8px 0 0 !important;
            box-sizing: border-box !important;
            overflow: visible !important;
        }

        #sp_Sub_SubProduct_html .dx-toolbar-center,
        #gridSubProductList .dx-toolbar-center {
            display: none !important;
        }

        #sp_Sub_SubProduct_html .dx-toolbar-item,
        #gridSubProductList .dx-toolbar-item {
            flex: 0 0 auto !important;
            padding: 0 !important;
            min-width: 0 !important;
            height: auto !important;
        }

        /* 6. Nhóm 7: Atomic Text Lock cho Nút + Thêm phân hệ */
        #sp_Sub_SubProduct_html .btn-add-SubProduct {
            height: 32px !important;
            padding: 0 16px !important;
            font-size: 13px !important;
            font-weight: 500 !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            gap: 6px !important;
            white-space: nowrap !important;
            flex-shrink: 0 !important;
            border-radius: 4px !important;
        }

        /* 7. SỬA LỖI SEARCHBOX: Chống icon kính lúp đè lên chữ text & placeholder */
        #gridSubProductList .dx-datagrid-search-panel,
        #gridSubProductList .dx-searchbox {
            height: 32px !important;
            min-height: 32px !important;
            max-height: 32px !important;
            width: 250px !important;
            max-width: 100% !important;
            padding-top: 0 !important;
            padding-bottom: 0 !important;
            box-sizing: border-box !important;
            background-color: #2b3035 !important;
            border: 1px solid #495057 !important;
            border-radius: 4px !important;
            color: #e9ecef !important;
            position: relative !important;
        }

        #gridSubProductList .dx-datagrid-search-panel .dx-texteditor-container,
        #gridSubProductList .dx-datagrid-search-panel .dx-texteditor-input-container {
            height: 100% !important;
            min-height: 0 !important;
            max-height: 100% !important;
            box-sizing: border-box !important;
        }

        /* FIX SEARCHBOX ICON OVERLAPPING TEXT: Lùi lề trái 34px chống đè kính lúp */
        #gridSubProductList .dx-datagrid-search-panel .dx-texteditor-input,
        #gridSubProductList .dx-searchbox .dx-texteditor-input {
            height: 100% !important;
            min-height: 0 !important;
            box-sizing: border-box !important;
            padding-top: 0 !important;
            padding-bottom: 0 !important;
            padding-left: 34px !important; /* LÙI LỀ TRÁI 34PX CHỐNG ĐÈ KÍNH LÚP */
            background-color: transparent !important;
            color: #e9ecef !important;
            font-size: 13px !important;
        }

        #gridSubProductList .dx-datagrid-search-panel .dx-placeholder,
        #gridSubProductList .dx-datagrid-search-panel .dx-placeholder::before,
        #gridSubProductList .dx-searchbox .dx-placeholder,
        #gridSubProductList .dx-searchbox .dx-placeholder::before {
            padding-left: 34px !important; /* LÙI LỀ TRÁI 34PX CHO PLACEHOLDER */
            color: #adb5bd !important;
            -webkit-text-fill-color: #adb5bd !important;
            opacity: 1 !important;
            font-size: 13px !important;
        }

        #gridSubProductList .dx-datagrid-search-panel .dx-icon-search,
        #gridSubProductList .dx-searchbox .dx-icon-search {
            color: #adb5bd !important;
        }

        /* Hỗ trợ Light theme */
        [data-bs-theme="light"] #gridSubProductList .dx-datagrid-search-panel,
        [data-bs-theme="light"] #gridSubProductList .dx-datagrid-search-panel:is(:hover, .dx-state-hover, .dx-state-focused, :focus-within) {
            background: #fff !important;
            color: #000 !important;
            border-color: #ced4da !important;
        }
        [data-bs-theme="light"] #gridSubProductList .dx-datagrid-search-panel .dx-texteditor-input,
        [data-bs-theme="light"] #gridSubProductList .dx-datagrid-search-panel:is(:hover, .dx-state-hover, .dx-state-focused, :focus-within) .dx-texteditor-input {
            background: #fff !important;
            color: #000 !important;
        }
        [data-bs-theme="light"] #gridSubProductList .dx-datagrid-search-panel .dx-icon,
        [data-bs-theme="light"] #gridSubProductList .dx-datagrid-search-panel .dx-placeholder,
        [data-bs-theme="light"] #gridSubProductList .dx-datagrid-search-panel .dx-placeholder::before,
        [data-bs-theme="light"] #gridSubProductList .dx-datagrid-search-panel input::placeholder {
            color: #6c757d !important;
            -webkit-text-fill-color: #6c757d !important;
        }

        #gridSubProductList .dx-toolbar .dx-button {
            padding: 0 !important;
            border-radius: 4px !important;
            font-size: 12px !important;
        }
        #gridSubProductList .dx-toolbar .dx-button .dx-button-content {
            padding: 6px 12px !important;
        }

        /* 8. Nhóm 9: Cô lập cuộn Bảng dữ liệu lớn */
        #gridSubProductList .dx-datagrid-headers,
        #gridSubProductList .dx-datagrid-rowsview {
            overflow-x: auto !important;
        }

        /* 9. Windows Snap & Mobile Layout: Tự co giãn toàn chiều rộng khi màn hình hẹp */
        @media (max-width: 576px) {
            #gridSubProductList .dx-datagrid-search-panel,
            #gridSubProductList .dx-searchbox {
                width: 100% !important;
            }
            #sp_Sub_SubProduct_html .dx-toolbar-after,
            #gridSubProductList .dx-toolbar-after {
                width: 100% !important;
                justify-content: flex-start !important;
            }
        }
"@

# Extract start of proc
$step1Header = @"
-- ===================================================================
-- PATCH: [sp_Sub_SubProduct_html] & [sp_Sub_SubProduct]
-- PHÂN HỆ: Trang Chủ CRM > Báo giá > Quản lý phân hệ (MnuCSM003)
-- DATABASE: Vietinsoft_ForTest_Tai2
-- ÁP DỤNG BỘ 9 NHÓM QUY TẮC BẤT BIẾN /responsive-rules & CLEAN CODE 3 BƯỚC:
--   1. Master Layout Lock: Khóa max-width 1920px, canh giữa margin: 0 auto.
--   2. Normal Document Flow: Triệt tiêu 100% lỗi DataGrid che khuất Toolbar (height: auto, position: static).
--   3. Sibling Flattening: display: contents trên .dx-toolbar-before.
--   4. Right-to-Left Wrapping: margin-left: auto trên .dx-toolbar-after đẩy sát lề phải & bọc dòng mượt mà.
--   5. Atomic Text Lock: Khóa nguyên tử flex-shrink: 0 & white-space: nowrap cho nút '+ Thêm phân hệ'.
--   6. SỬA LỖI SEARCHBOX: Lùi lề trái 34px chống icon kính lúp đè lên chữ text & placeholder 'Tìm kiếm theo nội dung'.
--   7. Cô lập cuộn Bảng dữ liệu lớn: overflow-x: auto trên DataGrid headers & rowsview.
-- ===================================================================

USE [Vietinsoft_ForTest_Tai2]
GO

/*-------------------------------------------------------------------
 BƯỚC 1: CẬP NHẬT MÃ NGUỒN GIAO DIỆN [dbo].[sp_Sub_SubProduct_html]
 (Chứa toàn bộ mã nguồn HTML/CSS/JS đã sửa lỗi responsive & searchbox)
--------------------------------------------------------------------*/
"@

# Replace CREATE PROCEDURE with ALTER PROCEDURE
$modifiedProc = $originContent -replace 'CREATE PROCEDURE \[dbo\]\.\[sp_Sub_SubProduct_html\]', 'ALTER PROCEDURE [dbo].[sp_Sub_SubProduct_html]'

# Replace old CSS block
$patternOldCss = '(?s)/\* ================= RESPONSIVE TOOLBAR & SEARCH UX \(COMPACT & ADAPTIVE\) ================= \*/.*?#gridSubProductList \.dx-toolbar \.dx-button \.dx-button-content \{ padding: 6px 12px !important; \}'
if ($modifiedProc -match $patternOldCss) {
    Write-Host "Matched old CSS block successfully."
    $modifiedProc = [System.Text.RegularExpressions.Regex]::Replace($modifiedProc, $patternOldCss, $newCss)
} else {
    Write-Host "Warning: Could not regex match old CSS block!"
}

# Replace the dirty hack in stylegridSubProductList
$oldPlaceholderHack = '\.dx-datagrid-search-panel \.dx-placeholder \{\s*display: none !important;\s*\}'
$newPlaceholderFix = ".dx-datagrid-search-panel .dx-placeholder {`n                                padding-left: 34px !important;`n                            }"
if ($modifiedProc -match $oldPlaceholderHack) {
    Write-Host "Matched old placeholder hack in JS successfully."
    $modifiedProc = [System.Text.RegularExpressions.Regex]::Replace($modifiedProc, $oldPlaceholderHack, $newPlaceholderFix)
} else {
    Write-Host "Notice: Old placeholder hack not found or already clean."
}

# Step 2 and Step 3
$step2And3 = @"

GO

/*-------------------------------------------------------------------
 BƯỚC 2: CHUẨN HÓA STORED PROCEDURE ĐIỀU PHỐI [dbo].[sp_Sub_SubProduct]
--------------------------------------------------------------------*/
ALTER PROCEDURE [dbo].[sp_Sub_SubProduct](
    @LoginID INT = NULL,
    @LanguageID VARCHAR(5) = 'VN',
    @EmployeeID VARCHAR(20) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    IF @LanguageID IS NULL OR LTRIM(RTRIM(@LanguageID)) = ''
        SET @LanguageID = 'VN';

    DECLARE @html NVARCHAR(MAX);
    SELECT TOP 1 @html = html
    FROM tblHtmlScriptCache
    WHERE (TableName = 'sp_Sub_SubProduct_html' OR TableName = 'sp_Sub_SubProduct')
      AND ScreenType = -1
      AND LanguageID = @LanguageID;

    IF @html IS NOT NULL
        SELECT @html AS html;
    ELSE
        SELECT TOP 1 html
        FROM tblHtmlScriptCache
        WHERE (TableName = 'sp_Sub_SubProduct_html' OR TableName = 'sp_Sub_SubProduct')
          AND ScreenType = -1;
END
GO

/*-------------------------------------------------------------------
 BƯỚC 3: BIÊN DỊCH MÃ NGUỒN GIAO DIỆN VÀO BẢNG CACHE VÀ CẬP NHẬT VERSION
--------------------------------------------------------------------*/
IF OBJECT_ID('dbo.sp_GenerateHTMLScript_new', 'P') IS NOT NULL
BEGIN
    EXEC sp_GenerateHTMLScript_new 'sp_Sub_SubProduct_html', 'VN', 'sp_Sub_SubProduct';
    EXEC sp_GenerateHTMLScript_new 'sp_Sub_SubProduct_html', 'EN', 'sp_Sub_SubProduct';
    EXEC sp_GenerateHTMLScript_new 'sp_Sub_SubProduct_html', 'VN', 'sp_Sub_SubProduct_html';
    EXEC sp_GenerateHTMLScript_new 'sp_Sub_SubProduct_html', 'EN', 'sp_Sub_SubProduct_html';
END
ELSE
BEGIN
    EXEC sp_GenerateHTMLScript 'sp_Sub_SubProduct_html';
END
GO
"@

$finalContent = $step1Header + "`r`n" + $modifiedProc.Trim() + "`r`n" + $step2And3

$outPath = "fix-bug/crm_quan_ly_phan_he/fix-bug.sql"
[System.IO.File]::WriteAllText($outPath, $finalContent, [System.Text.Encoding]::UTF8)
Write-Host "Generated $outPath successfully. Length: $($finalContent.Length) chars."
