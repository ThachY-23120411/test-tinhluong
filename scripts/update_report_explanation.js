const fs = require('fs');

const reportPath = 'fix-bug/screenshot-2/fix-report.md';
let report = fs.readFileSync(reportPath, 'utf8');

const targetSection = `### ⚠️ Lưu ý kỹ thuật đặc biệt: Cơ chế Cache \`tblHtmlScriptCache\`
Màn hình này được nạp thông qua Stored Procedure điều phối \`sp_Debt_PaymentDebt\`:
\`\`\`sql
SELECT html FROM tblHtmlScriptCache 
WHERE TableName = 'sp_Debt_PaymentDebt_html' AND ScreenType = -1 AND LanguageID = @LanguageID
\`\`\`
👉 Do đó, nếu chỉ \`ALTER PROCEDURE sp_Debt_PaymentDebt_html\` mà **không chạy lệnh \`EXEC sp_GenerateHTMLScript 'sp_Debt_PaymentDebt_html'\`**, hệ thống sẽ tiếp tục nạp mã HTML cũ từ bảng cache, khiến giao diện trên web không thể thay đổi!`;

const updatedSection = `### ⚠️ NGUYÊN NHÂN CỐT LÕI VÌ SAO BẠN ĐÃ EXEC MÀ WEB VẪN KHÔNG THAY ĐỔI:
Sau khi truy vấn trực tiếp vào Database để kiểm tra, chúng tôi bắt được **nguyên nhân chính xác 100%**:

\`\`\`
[sp_GenerateHTMLScript] ──(Tự động xóa đuôi '_html')──► Lưu vào Cache: TableName = 'sp_Debt_PaymentDebt'
                                                                                  ▲
                                                                                  │ (BỊ LỆCH TÊN!)
                                                                                  ▼
[Trình duyệt Chrome] ◄──(Gọi SP điều phối)── [sp_Debt_PaymentDebt] ──► Chỉ tìm: TableName = 'sp_Debt_PaymentDebt_html'
\`\`\`

1. **Thủ tục biên dịch \`sp_GenerateHTMLScript\`**:
   * Khi nhận tham số \`'sp_Debt_PaymentDebt_html'\`, dòng code số 62 của SP này thực hiện:
     \`\`\`sql
     SET @ProcName = REPLACE(@ProcName, '_html', '') -- Cắt bỏ chữ '_html'
     UPDATE [tblHtmlScriptCache] ... WHERE TableName = @ProcName -- Lưu dưới tên 'sp_Debt_PaymentDebt'
     \`\`\`
   * Kết quả kiểm tra Database thực tế: Dòng có \`TableName = 'sp_Debt_PaymentDebt'\` **đã được lưu mã mới** (\`HtmlLen: 103290\`, chứa \`allowColumnResizing\` và \`width: 18%\`).
2. **Thủ tục điều phối \`sp_Debt_PaymentDebt\` trên Web**:
   * Câu lệnh SQL của SP này lại đang viết:
     \`\`\`sql
     SELECT html FROM tblHtmlScriptCache WHERE TableName = 'sp_Debt_PaymentDebt_html' -- VẪN CÒN ĐUÔI _html!
     \`\`\`
   * Dòng \`TableName = 'sp_Debt_PaymentDebt_html'\` trong bảng cache **hoàn toàn chưa được cập nhật** (\`HtmlLen: 101513\`, vẫn giữ code cũ).
3. **Lỗi khi chạy cả file \`release_patches.sql\`**:
   * Trong ảnh chụp SSMS của bạn, cửa sổ Error List báo: *Invalid column name 'PhotoImage' tại dòng 437*. Đây là lỗi kiểm tra cú pháp của PATCH cũ phía trên, có thể làm ngắt quãng hoặc khiến các lệnh bên dưới không được thực thi trọn vẹn.
4. **👉 GIẢI PHÁP TRIỆT ĐỂ**:
   * Cập nhật \`sp_Debt_PaymentDebt_html\` (8 cột responsive).
   * Kích hoạt \`EXEC sp_GenerateHTMLScript 'sp_Debt_PaymentDebt_html'\`.
   * **Đồng bộ ép buộc**: Ghi đè mã HTML mới sang cả dòng \`TableName = 'sp_Debt_PaymentDebt_html'\` trong \`tblHtmlScriptCache\`.
   * **Nâng cấp \`sp_Debt_PaymentDebt\`**: Cho phép tìm kiếm linh hoạt cả 2 tên (\`IN ('sp_Debt_PaymentDebt', 'sp_Debt_PaymentDebt_html')\`) với fallback an toàn.`;

report = report.replace(targetSection, updatedSection);
fs.writeFileSync(reportPath, report, 'utf8');
fs.writeFileSync('fix-bug/thanh_toan_cong_no/RESPONSIVE-DGV/fix-report.md', report, 'utf8');
console.log('Successfully updated fix-report.md with detailed explanation!');
