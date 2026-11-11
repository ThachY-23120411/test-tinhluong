const fs = require('fs');

const patchedSp = fs.readFileSync('scripts/patched_sp_Debt_PaymentDebt_html.sql', 'utf8').trim();

const standaloneSql = `/*==================================================================================================
  PARADISE HRM - PATCH: MENU THANH TOÁN CÔNG NỢ (MnuPRL409)
  SỬA LỖI: DATAGRID KHÔNG RESPONSIVE & CHIỀU NGANG CỘT BẤT ĐỐI XỨNG
  
  * Stored Procedure: [dbo].[sp_Debt_PaymentDebt_html]
  * Thủ tục biên dịch cache: [dbo].[sp_GenerateHTMLScript]
  * Hướng dẫn chạy:
      1. Mở file này trên SSMS và chọn Database [Vietinsoft_ForTest_Tai2].
      2. Bấm Ctrl + F5 để kiểm tra cú pháp (Parse).
      3. Bấm F5 để thực thi (Execute).
      4. Quay lại Chrome, nhấn Ctrl + F5 để xóa cache trình duyệt.
==================================================================================================*/

USE [Vietinsoft_ForTest_Tai2]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

${patchedSp}
GO

-- BẮT BUỘC: Biên dịch lại mã HTML đã cập nhật vào bảng cache tblHtmlScriptCache để Web nạp ngay lập tức
EXEC sp_GenerateHTMLScript 'sp_Debt_PaymentDebt_html'
GO
`;

fs.writeFileSync('fix-bug/thanh_toan_cong_no/RESPONSIVE-DGV/patch_responsive_dgv.sql', standaloneSql, 'utf8');
console.log('Created standalone SQL patch file!');
