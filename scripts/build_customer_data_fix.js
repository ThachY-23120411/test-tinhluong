const fs = require('fs');
const path = require('path');

const originPath = path.resolve(__dirname, '../fix-bug/crm_customer_data/origin.sql');
let content = fs.readFileSync(originPath, 'utf8');

console.log('Original length:', content.length);

// 1. Identify CSS block to replace
// In origin.sql, remove any legacy conflicting block between #dataCollectionComponent .crm-status-row { display: none; and .dc-container {
const oldDisplayNoneBlock = `        #dataCollectionComponent .crm-status-row {
            display: none;
            flex-wrap: nowrap;
            align-items: center;
            padding: 6px;
            border: 1px solid #e0e0e0;
            border-radius: 999px;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
            scrollbar-width: thin;
            scrollbar-color: #c1c1c1 transparent;
        }
        #dataCollectionComponent .crm-status-row::-webkit-scrollbar {
            height: 6px;
            background: transparent;
        }
        #dataCollectionComponent .crm-status-row::-webkit-scrollbar-thumb {
            background: #c1c1c1;
            border-radius: 4px;
        }
        @media (max-width: 768px) {
            #dataCollectionComponent .dc-status-filter-row {
                flex-wrap: wrap !important;
            }
            #dataCollectionComponent .dc-status-filter-row > .crm-status-row,
            #dataCollectionComponent .dc-status-filter-row > .dc-filter {
                width: auto !important;
                flex: 0 1 auto !important;
                min-width: 0 !important;
            }
        }`;

if (content.includes(oldDisplayNoneBlock)) {
  content = content.replace(oldDisplayNoneBlock, '');
  console.log('✅ Removed old conflicting display:none block.');
}

const cssStartMarker = '        #GridKC .dx-toolbar .dx-toolbar-items-container {';
const cssEndMarker = '        .dc-container {';

const startIdx = content.indexOf(cssStartMarker);
const endIdx = content.indexOf(cssEndMarker);

if (startIdx === -1 || endIdx === -1) {
  console.error('Markers not found! startIdx:', startIdx, 'endIdx:', endIdx);
  process.exit(1);
}

console.log('Found CSS range from char', startIdx, 'to', endIdx);

const replacementCss = `        /* =========================================================================
           VTS_RESPONSIVE_RULES_PARADISE_HRM: MENU DỮ LIỆU KHÁCH HÀNG (MnuKPI003)
           Tuân thủ Bộ 9 Nhóm quy tắc Bất biến về Bố cục & Widget (/responsive-rules)
           ========================================================================= */

        /* 1. Nhóm 1: Baseline Resolution Rule (Master Layout Lock 1920px & Max-Width Pinning) */
        /*    Nhóm 8: Khóa biên Vùng chứa theo Khung nhìn thực tế (Viewport Boundary Lock) */
        #dataCollectionComponent {
            max-width: 1920px !important;
            margin: 0 auto !important;
            width: 100% !important;
            min-width: 0 !important;
            box-sizing: border-box !important;
            overflow-x: hidden !important;
        }

        /* 2. Nhóm 5: Đưa Header Panel & Toolbar về Normal Document Flow (Triệt tiêu 100% lỗi che khuất DataGrid) */
        #dataCollectionComponent #GridKC .dx-datagrid-header-panel,
        #GridKC .dx-datagrid-header-panel {
            height: auto !important;
            min-height: auto !important;
            overflow: visible !important;
            padding: 4px 0 8px 0 !important;
            width: 100% !important;
            max-width: 100% !important;
            min-width: 0 !important;
            box-sizing: border-box !important;
        }

        #dataCollectionComponent #GridKC .dx-toolbar,
        #GridKC .dx-toolbar {
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

        /* 3. Container chứa Toolbar: Dàn 1 hàng trên Desktop (1440/1920), Wrap tự nhiên từ phải sang trái khi thu hẹp */
        #dataCollectionComponent #GridKC .dx-toolbar .dx-toolbar-items-container,
        #dataCollectionComponent #GridKC .dx-toolbar-items-container,
        #GridKC .dx-toolbar .dx-toolbar-items-container,
        #GridKC .dx-toolbar-items-container {
            height: auto !important;
            min-height: 44px !important;
            display: flex !important;
            flex-direction: row !important;
            flex-wrap: wrap !important;
            align-items: center !important;
            justify-content: space-between !important;
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

        /* 4. Nhóm 3: Khối Bộ Lọc Bên Trái (Hàng 1 Bất biến: Capsule + Phễu + Checkbox "Xem của tôi") */
        #dataCollectionComponent #GridKC .dx-toolbar .dx-toolbar-before,
        #GridKC .dx-toolbar .dx-toolbar-before {
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

        #dataCollectionComponent .dc-status-wrapper {
            display: flex !important;
            flex-direction: row !important;
            align-items: center !important;
            gap: 8px !important;
            flex-wrap: nowrap !important;
            width: auto !important;
            max-width: 100% !important;
            min-width: 0 !important;
            flex: 0 1 auto !important;
            overflow: visible !important;
        }

        #dataCollectionComponent .dc-status-filter-row {
            display: flex !important;
            flex-direction: row !important;
            align-items: center !important;
            gap: 6px !important;
            flex-wrap: nowrap !important;
            width: auto !important;
            max-width: 100% !important;
            min-width: 0 !important;
            overflow: visible !important;
        }

        /* 5. Nhóm 2 & 4: Thanh Capsule cuộn ngang cục bộ êm ái khi màn hình co hẹp, nền trong suốt gốc */
        #dataCollectionComponent .crm-status-row {
            display: flex !important;
            flex: 0 1 auto !important;
            width: auto !important;
            max-width: 100% !important;
            min-width: 0 !important;
            flex-wrap: nowrap !important;
            overflow-x: auto !important;
            padding: 4px 6px !important;
            border: 1px solid #e0e0e0 !important;
            border-radius: 999px !important;
            align-items: center !important;
            scrollbar-width: none !important;
            -ms-overflow-style: none !important;
            -webkit-overflow-scrolling: touch !important;
            background: transparent !important;
        }

        #dataCollectionComponent .crm-status-row::-webkit-scrollbar {
            display: none !important;
            width: 0 !important;
            height: 0 !important;
        }

        /* 6. Nhóm 7: Khóa nguyên tử Chiều rộng của Widget chữ (Atomic Text & Non-Shrink Lock) */
        #dataCollectionComponent .crm-status-pill {
            flex: 0 0 auto !important;
            flex-shrink: 0 !important;
            white-space: nowrap !important;
            border: 1px solid transparent !important;
        }

        #dataCollectionComponent .dc-filter {
            flex: 0 0 auto !important;
            flex-shrink: 0 !important;
            display: flex !important;
            align-items: center !important;
            gap: 0 !important;
            width: auto !important;
            min-width: 0 !important;
            white-space: nowrap !important;
        }

        #dataCollectionComponent .filter-pill-btn,
        #dataCollectionComponent .filter-pill-btn-P1D1261311DFB4BDABD06DE5867CFF5B5 {
            flex-shrink: 0 !important;
            white-space: nowrap !important;
        }

        #dataCollectionComponent .dc-quick-mydata-row,
        #dataCollectionComponent .dc-quick-mydata-row * {
            flex: 0 0 auto !important;
            flex-shrink: 0 !important;
            white-space: nowrap !important;
        }

        #dataCollectionComponent .dc-quick-mydata-row {
            display: inline-flex !important;
            align-items: center !important;
            gap: 6px !important;
            width: auto !important;
            min-width: max-content !important;
        }

        /* 7. Nhóm 3 & 6: Khối Hành Động Bên Phải (Ưu tiên rớt dòng từ phải sang trái, bám lề phải) */
        #dataCollectionComponent #GridKC .dx-toolbar .dx-toolbar-after,
        #GridKC .dx-toolbar .dx-toolbar-after {
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

        #dataCollectionComponent #GridKC .dx-toolbar .dx-toolbar-center,
        #GridKC .dx-toolbar .dx-toolbar-center {
            display: none !important;
        }

        /* Nhóm 2: Bất biến Style gốc của Icon Buttons (+, ⋮, Column Chooser) */
        #GridKC .dx-toolbar .dx-toolbar-after .dx-button,
        #GridKC .dx-toolbar .dx-toolbar-after .dx-dropdownbutton {
            border: none !important;
            background: transparent !important;
            box-shadow: none !important;
            flex-shrink: 0 !important;
        }

        /* Nhóm 2 & 7: Searchbox kích thước chuẩn, không đè chữ */
        #GridKC .dx-toolbar-item-search-panel,
        #GridKC .dx-toolbar .dx-toolbar-after .dx-toolbar-item:has(.dx-searchbox),
        #GridKC .dx-toolbar .dx-toolbar-after .dx-toolbar-item:has(.dx-datagrid-search-panel) {
            flex: 0 0 240px !important;
            flex-shrink: 0 !important;
            width: 240px !important;
            min-width: 220px !important;
            max-width: 260px !important;
        }

        #GridKC .dx-datagrid-search-panel,
        #GridKC .dx-searchbox {
            width: 100% !important;
            min-width: 0 !important;
            max-width: 100% !important;
        }

        /* 8. Nhóm 9: Cô lập Chiều rộng của Bảng dữ liệu lớn (Wide-Component Scroll Isolation) */
        #dataCollectionComponent #GridKC,
        #GridKC {
            width: 100% !important;
            max-width: 100% !important;
            min-width: 0 !important;
            box-sizing: border-box !important;
            overflow: hidden !important;
        }

        #dataCollectionComponent #GridKC .dx-datagrid,
        #GridKC .dx-datagrid {
            width: 100% !important;
            max-width: 100% !important;
            min-width: 0 !important;
            box-sizing: border-box !important;
        }

        #dataCollectionComponent #GridKC .dx-datagrid-headers,
        #dataCollectionComponent #GridKC .dx-datagrid-rowsview,
        #GridKC .dx-datagrid-headers,
        #GridKC .dx-datagrid-rowsview {
            width: 100% !important;
            max-width: 100% !important;
            overflow-x: auto !important;
            -webkit-overflow-scrolling: touch !important;
        }

`;

content = content.substring(0, startIdx) + replacementCss + content.substring(endIdx);
console.log('CSS replaced. New length:', content.length);

// 2. Update statusWrapper class in script (has doubled single quotes in SQL string)
const oldWrapper = `const $statusWrapper = $(''<div style="display:flex;flex-direction:row;align-items:center;gap:12px;width:auto;flex-wrap:nowrap;">'');`;
const newWrapper = `const $statusWrapper = $(''<div class="dc-status-wrapper" style="display:flex;flex-direction:row;align-items:center;gap:8px;width:auto;max-width:100%;min-width:0;flex-wrap:nowrap;">'');`;

if (content.includes(oldWrapper)) {
  content = content.replace(oldWrapper, newWrapper);
  console.log('✅ Replaced oldWrapper with dc-status-wrapper.');
} else {
  console.log('⚠️ oldWrapper already updated or not found.');
}

// 3. Update applyFilter in script: ReloadData(null, null, null, 1)
if (content.includes('ReloadData();')) {
  content = content.replace('ReloadData();', 'ReloadData(null, null, null, 1);');
  console.log('✅ Updated ReloadData call to preserve isViewAll = 1.');
}

// 4. Add ensureFilterControlsMounted function before $pill.on(''click'' (with doubled quotes for SQL literal)
const mountFn = `
                                function ensureFilterControlsMounted() {
                                    try {
                                        const fromWrapper = document.getElementById(''pillFromDateContainerP4510BE8E25E842D286E3E8C0ACAE8E7E'');
                                        if (fromWrapper && fromWrapper.children.length === 0) {
                                            const originalFrom = document.getElementById(''P4510BE8E25E842D286E3E8C0ACAE8E7E'');
                                            if (originalFrom) fromWrapper.appendChild(originalFrom);
                                        }
                                        const toWrapper = document.getElementById(''pillToDateContainerPF18C5687EA514B69BFBA6BCA32E2D629'');
                                        if (toWrapper && toWrapper.children.length === 0) {
                                            const originalTo = document.getElementById(''PF18C5687EA514B69BFBA6BCA32E2D629'');
                                            if (originalTo) toWrapper.appendChild(originalTo);
                                        }
                                        const empWrapper = document.getElementById(''pillEmpContainerP1D1261311DFB4BDABD06DE5867CFF5B5'');
                                        if (empWrapper && empWrapper.children.length === 0) {
                                            const originalEmp = document.getElementById(''PDF424130C28F4C1298C81F737570F7A7'');
                                            if (originalEmp) {
                                                const elToMount = (originalEmp.parentElement && originalEmp.parentElement.querySelector(''div'')) || originalEmp;
                                                if (elToMount) empWrapper.appendChild(elToMount);
                                            }
                                        }
                                    } catch (err) { }
                                }
`;

const pillClickTarget = "$pill.on(''click'', function (e) {";
if (content.includes(pillClickTarget) && !content.includes('ensureFilterControlsMounted')) {
  content = content.replace(
    pillClickTarget,
    mountFn + "                                $pill.on(''click'', function (e) {\r\n                                    ensureFilterControlsMounted();"
  );
  console.log('✅ Added ensureFilterControlsMounted call to pill click.');
}

// 5. Ensure ALTER PROCEDURE and USE statement
content = content.replace(/CREATE\s+PROCEDURE\s+\[dbo\]\.\[sp_KPIListDataCollection_html\]/i, 'ALTER PROCEDURE [dbo].[sp_KPIListDataCollection_html]');
content = content.replace(/^CREATE\s+PROCEDURE/im, 'ALTER PROCEDURE');

const steps2And3 = `
GO

-- ===================================================================
-- BƯỚC 2: CHUẨN HÓA STORED PROCEDURE ĐIỀU PHỐI [dbo].[sp_KPIListDataCollection]
-- ===================================================================
ALTER PROCEDURE [dbo].[sp_KPIListDataCollection](
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
    WHERE TableName = 'sp_KPIListDataCollection'
      AND ScreenType = -1
      AND LanguageID = @LanguageID;
END
GO

-- ===================================================================
-- BƯỚC 3: BIÊN DỊCH MÃ NGUỒN GIAO DIỆN VÀO BẢNG CACHE VÀ CẬP NHẬT VERSION
-- ===================================================================
IF OBJECT_ID('dbo.sp_GenerateHTMLScript_new', 'P') IS NOT NULL
BEGIN
    EXEC sp_GenerateHTMLScript_new 'sp_KPIListDataCollection_html', 'VN', 'sp_KPIListDataCollection';
    EXEC sp_GenerateHTMLScript_new 'sp_KPIListDataCollection_html', 'EN', 'sp_KPIListDataCollection';
END
ELSE
BEGIN
    EXEC sp_GenerateHTMLScript 'sp_KPIListDataCollection_html';
END
GO
`;

const finalFixPath = path.resolve(__dirname, '../fix-bug/crm_customer_data/fix-bug.sql');
let fullSql = content.trim();
if (!fullSql.endsWith('GO')) fullSql += '\r\nGO';

// Check if steps 2 and 3 already exist in fullSql
if (!fullSql.includes('BƯỚC 2: CHUẨN HÓA STORED PROCEDURE ĐIỀU PHỐI')) {
  fullSql += '\r\n' + steps2And3;
}

// Prepend USE [Vietinsoft_ForTest_Tai2]
if (!fullSql.startsWith('USE [Vietinsoft_ForTest_Tai2]')) {
  fullSql = 'USE [Vietinsoft_ForTest_Tai2]\r\nGO\r\n\r\n' + fullSql;
}

fs.writeFileSync(finalFixPath, fullSql, 'utf8');
console.log('🎉 fix-bug.sql updated successfully with the 9 rules! Final length:', fullSql.length);
