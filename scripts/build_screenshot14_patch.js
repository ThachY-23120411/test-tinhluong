const fs = require('fs');
const path = require('path');

const outDir = path.resolve(__dirname, '../fix-bug/screenshot-14');
if (!fs.existsSync(outDir)) {
  fs.mkdirSync(outDir, { recursive: true });
}

// 1. Đọc sp_CRM_EmailKPIFollow_html gốc
const spHtmlPath = path.resolve(__dirname, 'sp_CRM_EmailKPIFollow_html.sql');
let content = fs.readFileSync(spHtmlPath, 'utf8');

// Chuẩn hóa line endings thành \n để xử lý regex/replace hoàn toàn chính xác
const originalHasCrlf = content.includes('\r\n');
content = content.replace(/\r\n/g, '\n');

// 2. Thay thế toàn bộ CSS cũ của .email-container và modal bằng CSS Responsive + Chuẩn QTV UI Design System
const oldCssStart = '.email-container {';
const oldCssEnd = '.email-table tbody tr:hover {';

const newCssBlock = `/* ================= RESPONSIVE FLEX LAYOUT & ENTERPRISE MODAL SCREENSHOT 14 ================= */
        #sp_CRM_EmailKPIFollow_html {
            height: 100% !important;
            display: flex !important;
            flex-direction: column !important;
            box-sizing: border-box !important;
            padding: 0 !important;
            margin: 0 !important;
            overflow: hidden !important;
            background: transparent !important;
        }

        .email-container {
            height: 100% !important;
            flex: 1 1 0% !important;
            min-height: 0 !important;
            display: flex !important;
            flex-direction: column !important;
            padding: 12px 16px !important;
            margin: 0 !important;
            border-radius: 0 !important;
            box-shadow: none !important;
            box-sizing: border-box !important;
            background: transparent !important;
        }

        .table-responsive {
            height: 100% !important;
            flex: 1 1 0% !important;
            min-height: 0 !important;
            display: flex !important;
            flex-direction: column !important;
            overflow: hidden !important;
            margin: 0 !important;
            padding: 0 !important;
        }

        #GridEmailKPIList {
            height: 100% !important;
            flex: 1 1 0% !important;
            min-height: 0 !important;
            width: 100% !important;
            display: flex !important;
            flex-direction: column !important;
        }

        #sp_CRM_EmailKPIFollow_html .dx-datagrid {
            height: 100% !important;
            width: 100% !important;
            display: flex !important;
            flex-direction: column !important;
        }

        #sp_CRM_EmailKPIFollow_html .dx-datagrid-headers {
            flex: 0 0 auto !important;
        }

        #sp_CRM_EmailKPIFollow_html .dx-datagrid-rowsview {
            flex: 1 1 auto !important;
            min-height: 0 !important;
            height: auto !important;
        }

        #sp_CRM_EmailKPIFollow_html .dx-datagrid-pager {
            flex: 0 0 auto !important;
        }

        #sp_CRM_EmailKPIFollow_html .dx-datagrid-table {
            width: 100% !important;
        }

        /* ================= MODAL CHỈNH SỬA EMAIL CHUẨN DESIGN SYSTEM ================= */
        #emailModal {
            position: fixed !important;
            top: 0 !important;
            left: 0 !important;
            width: 100vw !important;
            height: 100vh !important;
            z-index: 999999 !important;
            background: rgba(0, 0, 0, 0.65) !important;
            backdrop-filter: blur(2px) !important;
            display: none;
            align-items: center !important;
            justify-content: center !important;
            pointer-events: auto !important;
        }

        #emailModal.show {
            display: flex !important;
        }

        /* Vô hiệu hóa backdrop của bootstrap để tránh chặn click */
        .modal-backdrop {
            display: none !important;
            pointer-events: none !important;
        }

        #emailModal .modal-dialog {
            margin: auto !important;
            width: 100% !important;
            max-width: 580px !important;
            min-width: 480px !important;
            pointer-events: auto !important;
            z-index: 1000000 !important;
        }

        #emailModal .modal-content {
            width: 100% !important;
            border-radius: 12px !important;
            border: 1px solid rgba(255, 255, 255, 0.15) !important;
            background-color: #232733 !important;
            color: #f1f5f9 !important;
            box-shadow: 0 25px 60px rgba(0, 0, 0, 0.7) !important;
            overflow: hidden !important;
            pointer-events: auto !important;
            max-height: 85vh !important;
        }

        #emailModal .modal-header {
            background-color: #1b5e3f !important;
            color: #ffffff !important;
            padding: 16px 24px !important;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1) !important;
            border-top-left-radius: 12px !important;
            border-top-right-radius: 12px !important;
            display: flex !important;
            align-items: center !important;
            justify-content: space-between !important;
            pointer-events: auto !important;
        }

        #emailModal .modal-header .modal-title {
            font-size: 16px !important;
            font-weight: 600 !important;
            color: #ffffff !important;
            margin: 0 !important;
        }

        #emailModal .modal-header .btn-close {
            filter: invert(1) brightness(200%) !important;
            opacity: 0.8 !important;
            cursor: pointer !important;
            pointer-events: auto !important;
        }
        #emailModal .modal-header .btn-close:hover {
            opacity: 1 !important;
        }

        #emailModal .modal-body {
            padding: 24px !important;
            background-color: #232733 !important;
            max-height: calc(85vh - 130px) !important;
            overflow-y: auto !important;
            pointer-events: auto !important;
        }

        #emailModal .form-group {
            margin-bottom: 18px !important;
        }

        #emailModal .form-label {
            display: block !important;
            font-size: 13px !important;
            font-weight: 500 !important;
            color: #94a3b8 !important;
            margin-bottom: 6px !important;
        }

        #emailModal .modal-footer {
            padding: 16px 24px !important;
            border-top: 1px solid rgba(255, 255, 255, 0.08) !important;
            background-color: rgba(0, 0, 0, 0.2) !important;
            border-bottom-left-radius: 12px !important;
            border-bottom-right-radius: 12px !important;
            display: flex !important;
            justify-content: flex-end !important;
            gap: 12px !important;
            pointer-events: auto !important;
        }

        #emailModal .modal-footer .btn {
            padding: 9px 24px !important;
            font-size: 14px !important;
            font-weight: 500 !important;
            border-radius: 6px !important;
            cursor: pointer !important;
            transition: all 0.2s ease !important;
            pointer-events: auto !important;
        }

        #emailModal #btnCloseEmail {
            background-color: #475569 !important;
            color: #ffffff !important;
            border: none !important;
        }
        #emailModal #btnCloseEmail:hover {
            background-color: #334155 !important;
        }

        #emailModal #btnSaveEmail {
            background-color: #198754 !important;
            color: #ffffff !important;
            border: none !important;
        }
        #emailModal #btnSaveEmail:hover {
            background-color: #157347 !important;
        }

        .email-table tbody tr:hover {`;

const sIdx = content.indexOf(oldCssStart);
const eIdx = content.indexOf(oldCssEnd);
if (sIdx !== -1 && eIdx !== -1) {
  content = content.slice(0, sIdx) + newCssBlock + content.slice(eIdx + oldCssEnd.length);
  console.log('CSS block replaced successfully!');
} else {
  console.error('FAILED to find CSS markers!');
}

// 3. Thay thế hàm mở modal trong JS (openDetailEmployeeID)
const oldModalOpenRegex = /\/\/\s*Open modal[\s\S]*?document\.body\.classList\.add\('{1,2}modal-open'{1,2}\);\s*\}\s*\}/;

const newModalOpenJS = `// Open modal trực tiếp thoát khỏi Stacking Context để click mượt mà
        const emailModal = document.getElementById("emailModal");
        if (emailModal) {
            if (emailModal.parentElement !== document.body) {
                document.body.appendChild(emailModal);
            }
            $(".modal-backdrop").remove();
            emailModal.classList.add("show");
            emailModal.style.display = "flex";
            document.body.classList.add("modal-open");
        }`;

if (oldModalOpenRegex.test(content)) {
  content = content.replace(oldModalOpenRegex, newModalOpenJS);
  console.log('Modal open JS replaced successfully!');
} else {
  console.error('FAILED to match oldModalOpenRegex!');
}

// 4. Thay thế hàm đóng modal trong JS khi Save xong
const oldModalCloseRegex = /\/\/\s*Close modal[\s\S]*?document\.body\.classList\.remove\('{1,2}modal-open'{1,2}\);\s*\}\s*\}/;

const newModalCloseJS = `// Close modal
                        const emailModal = document.getElementById("emailModal");
                        if (emailModal) {
                            emailModal.classList.remove("show");
                            emailModal.style.display = "none";
                            document.body.classList.remove("modal-open");
                            $(".modal-backdrop").remove();
                        }`;

if (oldModalCloseRegex.test(content)) {
  content = content.replace(oldModalCloseRegex, newModalCloseJS);
  console.log('Modal close JS replaced successfully!');
} else {
  console.error('FAILED to match oldModalCloseRegex!');
}

// 5. Cấu hình ô "Mã nhân viên" hiển thị đúng Mã nhân viên (displayExpr: "ID")
content = content.replace(
  'InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56.option("disabled", true);',
  'InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56.option("disabled", true);\n            InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56.option("displayExpr", "ID");'
);

content = content.replace(
  'InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56.option("disabled", false);',
  'InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56.option("disabled", false);\n            InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56.option("displayExpr", "ID");'
);

// 6. Bổ sung bộ lắng nghe sự kiện đóng modal cho nút Đóng và nút X
const hookCloseEvents = `
    // Đảm bảo nút Đóng và nút X luôn đóng modal mượt mà
    $(document).off("click.emailModalClose").on("click.emailModalClose", "#btnCloseEmail, #emailModal .btn-close, .btn-close", function(e) {
        const em = document.getElementById("emailModal");
        if (em) {
            em.classList.remove("show");
            em.style.display = "none";
            document.body.classList.remove("modal-open");
            $(".modal-backdrop").remove();
        }
    });
`;

content = content.replace('ReloadData();', hookCloseEvents + '\n    ReloadData();');

// Đổi lại \r\n
if (originalHasCrlf) {
  content = content.replace(/\n/g, '\r\n');
}

let alterProcHtml = content;
if (!alterProcHtml.includes('ALTER PROCEDURE') && alterProcHtml.includes('CREATE PROCEDURE')) {
  alterProcHtml = alterProcHtml.replace('CREATE PROCEDURE', 'ALTER PROCEDURE');
}

// 7. Đọc và tinh chỉnh loadUI của UID P82897F00F2844F529066CF6F15D3170B (GridEmailKPIList)
const loadUIPath = path.resolve(__dirname, 'original_loadUI.js');
let loadUIContent = fs.readFileSync(loadUIPath, 'utf8');

const oldColsPattern = /\{\s*dataField:\s*"FullName",\s*caption:\s*"%FullName%",\s*width:\s*150,\s*alignment:\s*"left",\s*minWidth:\s*80,\s*maxWidth:\s*400,[\s\S]*?\{\s*dataField:\s*"Email",\s*caption:\s*"%Email%",\s*width:\s*150,\s*alignment:\s*"left",\s*minWidth:\s*80,\s*maxWidth:\s*400,[\s\S]*?\{\s*dataField:\s*"EmployeeID",\s*caption:\s*"%EmployeeID%",\s*width:\s*150,\s*alignment:\s*"left",\s*minWidth:\s*80,\s*maxWidth:\s*400,[\s\S]*?allowEditing:\s*false,\s*\}/;

const newCols = `{
                    dataField: "FullName",
                    caption: "%FullName%",
                    alignment: "left",
                    minWidth: 200,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function(cellElement, cellInfo){
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
                    dataField: "Email",
                    caption: "%Email%",
                    alignment: "left",
                    minWidth: 240,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function(cellElement, cellInfo){
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
                    dataField: "EmployeeID",
                    caption: "%EmployeeID%",
                    width: 120,
                    alignment: "left",
                    minWidth: 80,
                    maxWidth: 160,
                    allowSorting: true,
                    allowFiltering: true,
                    cellTemplate: function(cellElement, cellInfo){
                        const val = cellInfo.value;
                        if (val === undefined || val === null || val === "") {
                            $("<div>").addClass("dx-placeholder").text("").appendTo(cellElement);
                            return;
                        }
                        $("<div>").text(val).appendTo(cellElement);
                    },
                    allowEditing: false,
                }`;

if (oldColsPattern.test(loadUIContent)) {
  loadUIContent = loadUIContent.replace(oldColsPattern, newCols);
}

loadUIContent = loadUIContent.replace(
  '.dx-datagrid-table {\r\n                 table-layout: fixed !important;\r\n                                width: 100% !important;\r\n                  }',
  '.dx-datagrid-table {\r\n                 width: 100% !important;\r\n                  }'
);

// 8. Sửa lỗi cú pháp 0.apply trong loadUI của PA7D7F5081185488CA62C1F211136902A và P3649C063B0674562BCCA3FB6B2F4DBF6
let loadUI_PA7D = fs.readFileSync(path.resolve(__dirname, 'loadUI_PA7D.js'), 'utf8');
loadUI_PA7D = loadUI_PA7D.replace(
  'customValidate: function() { return typeof 0 === "function" ? 0.apply(this, arguments) : true; },',
  'customValidate: function() { return true; },'
);

let loadUI_P364 = fs.readFileSync(path.resolve(__dirname, 'loadUI_P364.js'), 'utf8');
loadUI_P364 = loadUI_P364.replace(
  'customValidate: function() { return typeof 0 === "function" ? 0.apply(this, arguments) : true; },',
  'customValidate: function() { return true; },'
);

// 9. Cấu hình loadUI của UID P2D9DF38DBC46406C8EC1686058288F56 (Mã nhân viên)
let loadUI_P2D9 = fs.readFileSync(path.resolve(__dirname, 'loadUI_P2D9.js'), 'utf8');
const p2d9HasCrlf = loadUI_P2D9.includes('\r\n');
loadUI_P2D9 = loadUI_P2D9.replace(/\r\n/g, '\n');

const customP2D9Code = `
            if (InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56) {
                InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56.option({
                    displayExpr: "ID",
                    valueExpr: "ID",
                    itemTemplate: function(data) {
                        if (!data) return "";
                        return $("<div>").text(data.ID ? (data.ID + " - " + (data.Name || "")) : (data.Name || ""));
                    }
                });
                InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56.on("selectionChanged", function(e) {
                    if (e && e.selectedItem && !InstanceEmployeeIDP2D9DF38DBC46406C8EC1686058288F56.option("disabled")) {
                        if (typeof InstanceFullNamePA7D7F5081185488CA62C1F211136902A !== "undefined" && InstanceFullNamePA7D7F5081185488CA62C1F211136902A) {
                            InstanceFullNamePA7D7F5081185488CA62C1F211136902A.option("value", e.selectedItem.Name || "");
                        }
                    }
                });
            }`;

const p2d9Idx = loadUI_P2D9.lastIndexOf('});');
if (p2d9Idx !== -1) {
  loadUI_P2D9 = loadUI_P2D9.slice(0, p2d9Idx + 3) + customP2D9Code + loadUI_P2D9.slice(p2d9Idx + 3);
}
if (p2d9HasCrlf) {
  loadUI_P2D9 = loadUI_P2D9.replace(/\n/g, '\r\n');
}

// Escape dấu nháy đơn
const escapedLoadUI_Grid = loadUIContent.replace(/'/g, "''");
const escapedLoadUI_PA7D = loadUI_PA7D.replace(/'/g, "''");
const escapedLoadUI_P364 = loadUI_P364.replace(/'/g, "''");
const escapedLoadUI_P2D9 = loadUI_P2D9.replace(/'/g, "''");

// 10. Tạo mã SQL hoàn chỉnh cho patch_email_kpi_follow.sql
const patchSql = `/*==================================================================================================
  BẢN VÁ LỖI GIAO DIỆN / BẢNG DỮ LIỆU - SCREENSHOT 14 (RESPONSIVE DATAGRID & FIX MODAL SIZE/CLICK & HIỂN THỊ ĐÚNG MÃ NV)
  Menu: Quản lý KPI / CRM -> Các email theo dõi KPI (MnuKPI010)
  Stored Procedure: [dbo].[sp_CRM_EmailKPIFollow_html] & [dbo].[sp_CRM_EmailKPIFollow]
  Control UIDs:
    - P82897F00F2844F529066CF6F15D3170B (GridEmailKPIList) -> Responsive 100% Width & Height
    - PA7D7F5081185488CA62C1F211136902A (FullName)        -> Fix SyntaxError "0.apply" làm sập giao diện
    - P3649C063B0674562BCCA3FB6B2F4DBF6 (Email)           -> Fix SyntaxError "0.apply" làm sập giao diện
    - P2D9DF38DBC46406C8EC1686058288F56 (EmployeeID)      -> Hiển thị đúng Mã số nhân viên (ví dụ: "034") thay vì Tên
  Mục tiêu sửa chữa:
    1. Bảng DataGrid: Full 100% chiều cao và 3 cột co giãn theo tỷ lệ màn hình (ĐÃ PASS).
    2. Modal Chỉnh sửa Email:
       - Mở rộng kích thước từ "chút éc" thành chuẩn Enterprise Admin (min-width: 480px, max-width: 580px).
       - Khắc phục triệt để lỗi KHÔNG THỂ CLICK vào control / button: Di chuyển modal ra ngoài document.body,
         loại bỏ lớp backdrop che đè, cho phép tương tác chuột 100% với các input và nút Đóng/Lưu.
    3. Hiển thị đúng "Mã nhân viên":
       - Ô "Mã nhân viên" hiển thị đúng mã số (ví dụ: "034").
       - Ô "Họ và tên" hiển thị họ tên (ví dụ: "TRẦN KHÁNH LY").
       - Ô "EMAIL" hiển thị email (ví dụ: "ly.tran@phanmemtinhluong.com").
       - Khi thêm mới, danh sách xổ xuống hiển thị "[Mã] - [Họ tên]" để dễ chọn và tự động điền Họ và tên.
    4. Đồng bộ và phá vỡ Disk Cache trình duyệt: Cập nhật tblHtmlScriptCache và sinh Version mới nhất.
==================================================================================================*/

USE [Vietinsoft_ForTest_Tai2]
GO

-- 1. CẬP NHẬT CẤU HÌNH CÁC CONTROLS TRONG tblCommonControlType_Signed
PRINT N'--> Bước 1: Khắc phục lỗi cú pháp 0.apply, hiển thị đúng Mã NV và cập nhật Grid responsive...';

-- 1.1. Sửa lỗi 0.apply ở cột FullName
UPDATE [dbo].[tblCommonControlType_Signed]
SET [loadUI] = N'${escapedLoadUI_PA7D}'
WHERE [UID] = 'PA7D7F5081185488CA62C1F211136902A';

-- 1.2. Sửa lỗi 0.apply ở cột Email
UPDATE [dbo].[tblCommonControlType_Signed]
SET [loadUI] = N'${escapedLoadUI_P364}'
WHERE [UID] = 'P3649C063B0674562BCCA3FB6B2F4DBF6';

-- 1.3. Cập nhật GridEmailKPIList: Responsive 100% Width, bỏ gán cứng 150px
UPDATE [dbo].[tblCommonControlType_Signed]
SET [loadUI] = N'${escapedLoadUI_Grid}'
WHERE [UID] = 'P82897F00F2844F529066CF6F15D3170B';

-- 1.4. Cập nhật ô Mã nhân viên: Hiển thị đúng Mã NV (displayExpr: "ID")
UPDATE [dbo].[tblCommonControlType_Signed]
SET [loadUI] = N'${escapedLoadUI_P2D9}'
WHERE [UID] = 'P2D9DF38DBC46406C8EC1686058288F56';
GO

-- 2. CẬP NHẬT STORED PROCEDURE sp_CRM_EmailKPIFollow_html (Bổ sung Flex Responsive, Modal Fix & Mã NV)
PRINT N'--> Bước 2: Cập nhật Stored Procedure [dbo].[sp_CRM_EmailKPIFollow_html]...';
GO
${alterProcHtml}
GO

-- 3. CẬP NHẬT STORED PROCEDURE sp_CRM_EmailKPIFollow (Đọc cache thông minh)
PRINT N'--> Bước 3: Cập nhật Stored Procedure [dbo].[sp_CRM_EmailKPIFollow]...';
GO
ALTER PROCEDURE [dbo].[sp_CRM_EmailKPIFollow](
    @LoginID INT,
    @LanguageID VARCHAR(5) = 'VN'
)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 [html] 
    FROM [dbo].[tblHtmlScriptCache] 
    WHERE [TableName] IN ('sp_CRM_EmailKPIFollow', 'sp_CRM_EmailKPIFollow_html') 
      AND [ScreenType] = -1 
      AND [LanguageID] = @LanguageID;
END
GO

-- 4. BIÊN DỊCH VÀ ĐỒNG BỘ CACHE TỰ ĐỘNG
PRINT N'--> Bước 4: Biên dịch tự động bằng sp_GenerateHTMLScript_new...';
IF OBJECT_ID('[dbo].[sp_GenerateHTMLScript_new]', 'P') IS NOT NULL
BEGIN
    EXEC [dbo].[sp_GenerateHTMLScript_new] 'sp_CRM_EmailKPIFollow_html';
END
GO

-- 5. TRIỆT TIÊU 0.apply, CẬP NHẬT GIAO DIỆN MỚI VÀ GÁN VERSION MỚI VÀO SCRIPTCACHE
PRINT N'--> Bước 5: Cập nhật trực tiếp tblHtmlScriptCache và sinh Version mới để ép trình duyệt nhận ngay...';
DECLARE @NewVersion NVARCHAR(50) = CAST(DATEDIFF(s, '1970-01-01', GETUTCDATE()) AS NVARCHAR(50));

-- Đảm bảo cả hai bảng ghi sp_CRM_EmailKPIFollow và sp_CRM_EmailKPIFollow_html đều có Version mới
UPDATE [dbo].[tblHtmlScriptCache]
SET [html] = REPLACE([html], '0.apply(this, arguments)', 'true'),
    [Version] = @NewVersion,
    [VersionData] = REPLACE([VersionData], '0.apply(this, arguments)', 'true')
WHERE [TableName] IN ('sp_CRM_EmailKPIFollow', 'sp_CRM_EmailKPIFollow_html');
GO

-- 6. ĐỒNG BỘ NỘI DUNG SANG CẢ 2 KEY SP_CRM_EMAILKPIFOLLOW VÀ SP_CRM_EMAILKPIFOLLOW_HTML
PRINT N'--> Bước 6: Đồng bộ dữ liệu cache sang cả 2 key sp_CRM_EmailKPIFollow và sp_CRM_EmailKPIFollow_html...';
DECLARE @NewVer NVARCHAR(50) = CAST(DATEDIFF(s, '1970-01-01', GETUTCDATE()) AS NVARCHAR(50));

-- Đảm bảo nếu sp_CRM_EmailKPIFollow có data thì copy sang sp_CRM_EmailKPIFollow_html
MERGE [dbo].[tblHtmlScriptCache] AS target
USING (SELECT [TableName] = 'sp_CRM_EmailKPIFollow_html', [LanguageID], [ScreenType], [html], [Version], [VersionData] 
       FROM [dbo].[tblHtmlScriptCache] 
       WHERE [TableName] = 'sp_CRM_EmailKPIFollow' AND [ScreenType] = -1) AS source
ON (target.[TableName] = source.[TableName] AND target.[LanguageID] = source.[LanguageID] AND target.[ScreenType] = source.[ScreenType])
WHEN MATCHED THEN
    UPDATE SET target.[html] = source.[html], target.[Version] = source.[Version], target.[VersionData] = source.[VersionData]
WHEN NOT MATCHED THEN
    INSERT ([TableName], [LanguageID], [ScreenType], [html], [Version], [VersionData])
    VALUES (source.[TableName], source.[LanguageID], source.[ScreenType], source.[html], source.[Version], source.[VersionData]);
GO

PRINT N'====================================================================================================';
PRINT N'ĐÃ HOÀN TẤT BẢN VÁ SCREENSHOT 14 (MODAL FIX, ĐÚNG MÃ NHÂN VIÊN & SCRIPTCACHE SYNC)!';
PRINT N'1. Ô "Mã nhân viên" đã hiển thị chuẩn xác Mã số (ví dụ: 034) thay vì bị điền Tên.';
PRINT N'2. Ô "Họ và tên" hiển thị đúng Họ tên (ví dụ: TRẦN KHÁNH LY).';
PRINT N'3. Ô "EMAIL" hiển thị đúng Email (ví dụ: ly.tran@phanmemtinhluong.com).';
PRINT N'4. Modal to đẹp chuẩn Enterprise 580px, click mượt mà vào mọi input và nút Đóng/Lưu.';
PRINT N'Vui lòng ra Chrome: ĐÓNG TAB CON "Các email theo dõi KPI" (bấm dấu x) rồi bấm lại vào menu để mở mới!';
PRINT N'====================================================================================================';
GO
`;

const patchFilePath = path.resolve(outDir, 'patch_email_kpi_follow.sql');
fs.writeFileSync(patchFilePath, patchSql, 'utf8');
console.log('Generated updated patch with modal fix successfully at:', patchFilePath);
