const fs = require('fs');

const patchedSp = fs.readFileSync('scripts/patched_sp_Debt_PaymentDebt_html.sql', 'utf8').trim();
let releaseFile = fs.readFileSync('fix-bug/release_patches.sql', 'utf8');

// 1. Update header in release_patches.sql
const headerFind = `      - PATCH 07: [sp_KPIgetDataCollection] Sửa SP nạp danh sách CRM: Bẫy an toàn FromDate/ToDate NULL & bảo toàn Xem tất cả`;
const headerReplace = `      - PATCH 07: [sp_KPIgetDataCollection] Sửa SP nạp danh sách CRM: Bẫy an toàn FromDate/ToDate NULL & bảo toàn Xem tất cả
      - PATCH 08: [thanh_toan_cong_no / MnuPRL409] Sửa lỗi DataGrid không responsive & chiều ngang cột không đồng đều trong sp_Debt_PaymentDebt_html`;

releaseFile = releaseFile.replace(headerFind, headerReplace);

// 2. Append PATCH 08 before footer
const footerMarker = `/*==================================================================================================\n  KẾT THÚC MASTER RELEASE PATCH SCRIPT\n==================================================================================================*/`;

const patch08Block = `/*==================================================================================================
  PATCH 08: [thanh_toan_cong_no / MnuPRL409] Sửa lỗi DataGrid không responsive & chiều ngang cột không đồng đều
  * Stored Procedure: [dbo].[sp_Debt_PaymentDebt_html]
  * Thủ tục biên dịch đi kèm: [dbo].[sp_GenerateHTMLScript]
  * Nguyên nhân: 
      1. Cột Khách hàng chỉ đặt minWidth: 150 mà không có width, trong khi 7 cột còn lại bị fix cứng pixel
         nhỏ (110px - 150px). Khi hiển thị trên màn hình rộng, DevExtreme dồn toàn bộ khoảng trống còn thừa
         (~780px) vào cột Khách hàng khiến cột này phình to 50% màn hình, các cột khác bị bóp nghẹt.
      2. Tiêu đề "TỔNG CÔNG NỢ", "NGÀY HẾT HẠN" và nội dung "Lương tháng..." bị cắt cụt thành dấu "..." do
         chiều rộng pixel 110px-120px quá hẹp khi trừ đi padding 1rem (16px mỗi bên).
      3. Thiếu các tính năng responsive cốt lõi của DevExtreme DataGrid: allowColumnResizing, columnResizingMode,
         columnHidingEnabled, hidingPriority, và tỷ lệ phần trăm phân bổ cân bằng 100%.
  * Giải pháp:
      1. Điều chỉnh padding header từ 1rem xuống 0.75rem 0.5rem để tối ưu không gian hiển thị tiêu đề.
      2. Chuyển đổi toàn bộ 8 cột sang tỷ lệ phần trăm chuẩn (18% - 13% - 11% - 9% - 10% - 13% - 13% - 13% = 100%)
         kèm minWidth bảo vệ và hidingPriority để tự động gập responsive khi thu nhỏ màn hình.
      3. Bổ sung allowColumnResizing: true, columnResizingMode: 'widget', columnHidingEnabled: true.
      4. Kích hoạt sp_GenerateHTMLScript 'sp_Debt_PaymentDebt_html' để biên dịch và cập nhật ngay vào bảng cache tblHtmlScriptCache.
==================================================================================================*/
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

releaseFile = releaseFile.replace(footerMarker, patch08Block + footerMarker);

fs.writeFileSync('fix-bug/release_patches.sql', releaseFile, 'utf8');
console.log('Updated fix-bug/release_patches.sql successfully! Total length:', releaseFile.length);
