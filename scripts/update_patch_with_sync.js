const fs = require('fs');

const patchedSpHtml = fs.readFileSync('scripts/patched_sp_Debt_PaymentDebt_html.sql', 'utf8').trim();

const sqlScript = `/*==================================================================================================
  PARADISE HRM - PATCH: MENU THANH TOÁN CÔNG NỢ (MnuPRL409)
  SỬA LỖI: DATAGRID KHÔNG RESPONSIVE & LỖI LỆCH TÊN BẢNG CACHE HTML
  
  * Stored Procedure 1: [dbo].[sp_Debt_PaymentDebt_html] (Mã nguồn HTML & JS cấu hình 8 cột DataGrid)
  * Stored Procedure 2: [dbo].[sp_Debt_PaymentDebt] (Thủ tục điều phối nạp HTML trên Web)
  * Thủ tục biên dịch:  [dbo].[sp_GenerateHTMLScript]
  
  * NGUYÊN NHÂN CỐT LÕI VÌ SAO CHẠY XONG MÀ WEB VẪN KHÔNG ĐỔI:
      1. sp_GenerateHTMLScript khi chạy đã tự động cắt bỏ chữ '_html' (set @ProcName = REPLACE(@ProcName,'_html',''))
         và lưu mã HTML mới vào bảng [tblHtmlScriptCache] với TableName = 'sp_Debt_PaymentDebt'.
      2. Trong khi đó, thủ tục sp_Debt_PaymentDebt trên Web lại đang SELECT theo TableName = 'sp_Debt_PaymentDebt_html'
         (vẫn còn chữ _html).
      3. Dẫn đến Web tiếp tục đọc dòng cache CŨ (chưa có responsive), còn dòng cache MỚI thì nằm ở TableName = 'sp_Debt_PaymentDebt'!
      
  * HƯỚNG DẪN THỰC THI TRÊN SSMS:
      1. Mở file này trên SSMS và chọn Database [Vietinsoft_ForTest_Tai2].
      2. Bấm Ctrl + F5 để kiểm tra cú pháp (Parse thành công 100%).
      3. Bấm F5 để thực thi (Execute).
      4. Quay lại Chrome, nhấn Ctrl + F5 để xóa cache trình duyệt.
==================================================================================================*/

USE [Vietinsoft_ForTest_Tai2]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 1: CẬP NHẬT STORED PROCEDURE GIAO DIỆN SP_DEBT_PAYMENTDEBT_HTML (CHIA ĐỀU TỶ LỆ 8 CỘT)
--------------------------------------------------------------------------------------------------*/
${patchedSpHtml}
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 2: BIÊN DỊCH VÀ ĐỒNG BỘ CACHE VÀO TBLHTMLSCRIPTCACHE
--------------------------------------------------------------------------------------------------*/
-- 2.1 Kích hoạt biên dịch từ SP
EXEC sp_GenerateHTMLScript 'sp_Debt_PaymentDebt_html'
GO

-- 2.2 ĐỒNG BỘ ÉP BUỘC CẢ 2 KEY CACHE: 'sp_Debt_PaymentDebt' VÀ 'sp_Debt_PaymentDebt_html'
-- Đảm bảo dù Web đọc theo key nào cũng lấy được 100% bản HTML mới nhất!
UPDATE h_old
SET html = h_new.html
FROM tblHtmlScriptCache h_old
INNER JOIN tblHtmlScriptCache h_new 
    ON h_new.TableName = 'sp_Debt_PaymentDebt' 
   AND h_new.LanguageID = h_old.LanguageID
WHERE h_old.TableName = 'sp_Debt_PaymentDebt_html';
GO

/*--------------------------------------------------------------------------------------------------
  BƯỚC 3: CẬP NHẬT THỦ TỤC ĐIỀU PHỐI SP_DEBT_PAYMENTDEBT (FALLBACK AN TOÀN CHO CẢ 2 KEY)
--------------------------------------------------------------------------------------------------*/
ALTER PROCEDURE [dbo].[sp_Debt_PaymentDebt]
    @LoginID INT = NULL,
    @LanguageID VARCHAR(2) = 'VN',
    @EmployeeID VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @LanguageID IS NULL OR LTRIM(RTRIM(@LanguageID)) = ''
        SET @LanguageID = 'VN';

    -- Ưu tiên lấy bản cache mới nhất từ TableName 'sp_Debt_PaymentDebt' hoặc 'sp_Debt_PaymentDebt_html'
    SELECT TOP 1 html 
    FROM tblHtmlScriptCache 
    WHERE TableName IN ('sp_Debt_PaymentDebt', 'sp_Debt_PaymentDebt_html') 
      AND ScreenType = -1 
      AND LanguageID = @LanguageID
    ORDER BY CASE WHEN TableName = 'sp_Debt_PaymentDebt' THEN 1 ELSE 2 END;
END
GO
`;

fs.writeFileSync('fix-bug/screenshot-2/patch_responsive.sql', sqlScript, 'utf8');
fs.writeFileSync('fix-bug/thanh_toan_cong_no/RESPONSIVE-DGV/patch_responsive_dgv.sql', sqlScript, 'utf8');
console.log('Successfully updated standalone patch files!');
