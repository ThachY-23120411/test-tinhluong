const fs = require('fs');
const path = require('path');

const srcDef = fs.readFileSync('scripts/sp_gift_history_gift_html_def.sql', 'utf8');

// 1. Sửa CSS Header padding và badge white-space
let modifiedDef = srcDef.replace(
  `#sp_gift_history_gift .dx-datagrid-headers .dx-header-row > td {
        font-weight: 700 !important; padding: 1rem !important; height: 60px !important;
        vertical-align: middle !important; border-bottom: 2px solid rgba(128, 128, 128, 0.2) !important;
        background: rgba(128, 128, 128, 0.05) !important;
    }`,
  `#sp_gift_history_gift .dx-datagrid-headers .dx-header-row > td {
        font-weight: 700 !important;
        padding: 0.75rem 0.6rem !important; /* Tối ưu padding: giải phóng 20px mỗi ô cho tiêu đề */
        height: 52px !important;
        white-space: nowrap !important;     /* Chống gãy dòng tiêu đề */
        vertical-align: middle !important;
        border-bottom: 2px solid rgba(128, 128, 128, 0.2) !important;
        background: rgba(128, 128, 128, 0.05) !important;
    }`
);

// Bổ sung white-space nowrap cho badge status
modifiedDef = modifiedDef.replace(
  `#sp_gift_history_gift .badge-status { padding: 0.35rem 0.85rem; border-radius: 6px; font-size: 0.75rem; font-weight: 700; display: inline-flex; align-items: center; gap: 4px; }`,
  `#sp_gift_history_gift .badge-status { padding: 0.35rem 0.85rem; border-radius: 6px; font-size: 0.75rem; font-weight: 700; display: inline-flex; align-items: center; gap: 4px; white-space: nowrap; }`
);

// 2. Tìm vị trí columns trong modifiedDef
const startGridIdx = modifiedDef.indexOf('$("#hist_grid").dxDataGrid');
const columnsIdx = modifiedDef.indexOf('columns: [', startGridIdx);
const endColumnsIdx = modifiedDef.indexOf('],', columnsIdx);

console.log('Grid start:', startGridIdx);
console.log('Columns start:', columnsIdx);
console.log('Columns end:', endColumnsIdx);

const newColumnsBlock = `allowColumnResizing: true,       // Bật tính năng kéo thả độ rộng cột
                columnResizingMode: "widget",    // Co giãn mượt mà theo khung widget
                columnHidingEnabled: true,       // Tự động gập cột trên màn hình nhỏ
                wordWrapEnabled: false,
                columns: [
                    // 1. Ngày đổi: 16% (minWidth 150, hidingPriority: 3)
                    { 
                        caption: "%RedemptionDateLabel%", 
                        dataField: "OrderDate", 
                        dataType: "date", 
                        format: "dd/MM/yyyy HH:mm", 
                        width: "16%", 
                        minWidth: 150, 
                        hidingPriority: 3 
                    },
                    // 2. Nhân viên: 22% (minWidth 180, hidingPriority: 5)
                    { 
                        caption: "%colEmployeeName%", 
                        width: "22%", 
                        minWidth: 180, 
                        hidingPriority: 5,
                        cellTemplate: function(container, options) { 
                            $("<div>").addClass("fw-bold text-truncate").attr("title", options.data.FullName || "Unknown").text(options.data.FullName || "Unknown").appendTo(container); 
                        } 
                    },
                    // 3. Quà tặng: 28% (minWidth 220, hidingPriority: 4)
                    {
                        caption: "%GiftsLabel%",
                        width: "28%",
                        minWidth: 220,
                        hidingPriority: 4,
                        cellTemplate: function(container, options) {
                            var d = options.data;
                            var img = d.ImageURL && d.ImageURL.trim() !== '''' ? d.ImageURL : ''data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'';
                            var wrapper = $("<div>").addClass("d-flex align-items-center gap-2");
                            $("<img>").addClass("product-thumb").attr("src", img).appendTo(wrapper);
                            $("<div>").addClass("text-truncate").attr("title", d.ProductName || "").text(d.ProductName || "").appendTo(wrapper);
                            wrapper.appendTo(container);
                        }
                    },
                    // 4. Coin: 14% (minWidth 100, hidingPriority: 2 - Căn phải)
                    { 
                        caption: "Coin", 
                        dataField: "TotalCoins", 
                        width: "14%", 
                        minWidth: 100, 
                        alignment: "right", 
                        hidingPriority: 2,
                        cellTemplate: function(c, o) { 
                            $("<span>").addClass("text-danger fw-bold").text(formatNumber(o.value)).appendTo(c); 
                        } 
                    },
                    // 5. Trạng thái: 20% (minWidth 180, hidingPriority: 1 - Căn giữa)
                    {
                        caption: "%Status%", 
                        dataField: "Status_History", 
                        width: "20%", 
                        minWidth: 180, 
                        alignment: "center",
                        hidingPriority: 1,
                        cellTemplate: function(container, options) {
                            var st = options.value;
                            var cls = "badge-pending";
                            var icon = "bi-hourglass-split";

                            if(st === "Đã nhận") { cls = "badge-approved"; icon = "bi-check-circle-fill"; }
                            else if(st === "Trả hàng" || st === "Đã hủy" || st === "Đã trả hàng") { cls = "badge-rejected"; icon = "bi-x-circle-fill"; }
                            else if(st && st.indexOf("Yêu cầu") >= 0) { cls = "badge-request"; icon = "bi-exclamation-circle-fill"; }

                            $("<span>").addClass("badge-status " + cls).html(\`<i class="bi \${icon}"></i> \${st}\`).appendTo(container);
                        }
                    }
                ],`;

// Thay thế đoạn columns trong modifiedDef
const beforeCols = modifiedDef.substring(0, columnsIdx);
const afterCols = modifiedDef.substring(endColumnsIdx + 2);
modifiedDef = beforeCols + newColumnsBlock + afterCols;

// Đổi CREATE thành ALTER PROCEDURE
modifiedDef = modifiedDef.replace('CREATE PROCEDURE [dbo].[sp_gift_history_gift_html]', 'ALTER PROCEDURE [dbo].[sp_gift_history_gift_html]');

const header = `/*==================================================================================================
  PARADISE HRM - PATCH: MENU LỊCH SỬ ĐỔI QUÀ (MnuPRL451)
  SỬA LỖI: DATAGRID KHÔNG RESPONSIVE & TRIỆT TIÊU LỖI KẸT HTTP DISK CACHE CỦA CHROME (SCREENSHOT-1)
  
  * Stored Procedure 1: [dbo].[sp_gift_history_gift_html] (Mã nguồn HTML & JS cấu hình 5 cột DataGrid chuẩn tỷ lệ %)
  * Stored Procedure 2: [dbo].[sp_gift_history_gift] (Thủ tục điều phối nạp HTML trên Web - Fallback an toàn)
  * Bảng Cache:         [dbo].[tblHtmlScriptCache] (Đồng bộ HTML mới và đổi Version Checksum mới)
  
  * VÌ SAO SCREENSHOT 2 SỬA RỒI MÀ SCREENSHOT 1 CHƯA ĐỔI THEO?
      - Menu Screenshot 2 (Thanh toán công nợ - MnuPRL409) dùng SP riêng: [sp_Debt_PaymentDebt_html].
      - Menu Screenshot 1 (Lịch sử đổi quà - MnuPRL451) dùng SP hoàn toàn khác: [sp_gift_history_gift_html].
      - Mỗi menu trong Paradise HRM là một Stored Procedure riêng biệt, sinh ra giao diện HTML riêng.
      - Do đó, khi sửa xong Screenshot 2, phải áp dụng patch này cho [sp_gift_history_gift_html] của Screenshot 1!
      
  * HƯỚNG DẪN THỰC THI TRÊN SSMS:
      1. Mở file này trên SSMS và chọn Database [Vietinsoft_ForTest_Tai2].
      2. Bấm Ctrl + F5 để kiểm tra cú pháp (Parse thành công 100%).
      3. Bấm F5 để thực thi (Execute).
      4. Quay lại Chrome, mở tab "Lịch sử đổi quà" để thấy bảng 5 cột cân đối hoàn hảo!
==================================================================================================*/

USE [Vietinsoft_ForTest_Tai2]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 1: CẬP NHẬT STORED PROCEDURE GIAO DIỆN SP_GIFT_HISTORY_GIFT_HTML (TỶ LỆ 5 CỘT RESPONSIVE 100%)
--------------------------------------------------------------------------------------------------*/
`;

const footer = `
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 2: BIÊN DỊCH VÀ ĐỒNG BỘ CACHE VÀO TBLHTMLSCRIPTCACHE
--------------------------------------------------------------------------------------------------*/
-- 2.1 Kích hoạt biên dịch từ SP
IF OBJECT_ID('dbo.sp_GenerateHTMLScript_new', 'P') IS NOT NULL
    EXEC sp_GenerateHTMLScript_new 'sp_gift_history_gift_html', '-1', 'sp_gift_history_gift';
ELSE
    EXEC sp_GenerateHTMLScript 'sp_gift_history_gift_html';
GO

-- 2.2 ĐỒNG BỘ ÉP BUỘC CẢ 2 KEY CACHE: 'sp_gift_history_gift' VÀ 'sp_gift_history_gift_html'
UPDATE h_old
SET html = h_new.html,
    Version = CAST(CHECKSUM(ISNULL(h_new.html, '')) AS NVARCHAR(256))
FROM tblHtmlScriptCache h_old
INNER JOIN tblHtmlScriptCache h_new 
    ON h_new.TableName = 'sp_gift_history_gift' 
   AND h_new.LanguageID = h_old.LanguageID
WHERE h_old.TableName = 'sp_gift_history_gift_html';
GO

-- 2.3 CẬP NHẬT TRƯỜNG VERSION MỚI (CHECKSUM) ĐỂ TRIỆT TIÊU HTTP DISK CACHE CỦA CHROME
UPDATE tblHtmlScriptCache
SET Version = CAST(CHECKSUM(ISNULL(html, '')) AS NVARCHAR(256))
WHERE TableName IN ('sp_gift_history_gift', 'sp_gift_history_gift_html');
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 3: CẬP NHẬT THỦ TỤC ĐIỀU PHỐI SP_GIFT_HISTORY_GIFT (FALLBACK AN TOÀN CHO CẢ 2 KEY)
--------------------------------------------------------------------------------------------------*/
ALTER PROCEDURE [dbo].[sp_gift_history_gift]
    @LoginID VARCHAR(50) = NULL,
    @LanguageID VARCHAR(2) = 'VN',
    @EmployeeID VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @LanguageID IS NULL OR LTRIM(RTRIM(@LanguageID)) = ''
        SET @LanguageID = 'VN';

    -- Ưu tiên lấy bản cache mới nhất từ TableName 'sp_gift_history_gift' hoặc 'sp_gift_history_gift_html'
    SELECT TOP 1 html 
    FROM tblHtmlScriptCache 
    WHERE TableName IN ('sp_gift_history_gift', 'sp_gift_history_gift_html') 
      AND ScreenType = -1 
      AND LanguageID = @LanguageID
    ORDER BY CASE WHEN TableName = 'sp_gift_history_gift' THEN 1 ELSE 2 END;
END
GO
`;

const patchSql = header + modifiedDef.trim() + footer;
const outDir = path.resolve(__dirname, '../fix-bug/screenshot-1');
if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });
fs.writeFileSync(path.join(outDir, 'patch_responsive.sql'), patchSql, 'utf8');
console.log('✅ Đã tạo thành công: fix-bug/screenshot-1/patch_responsive.sql');
