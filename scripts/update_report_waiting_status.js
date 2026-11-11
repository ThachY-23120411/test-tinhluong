const fs = require('fs');
const path = require('path');

const reportPath = path.resolve(__dirname, '../fix-bug/noi_dung_dang_tai/fix-report.md');
let report = fs.readFileSync(reportPath, 'utf8');

report = report.replace(
  '| **Màu nền Filter Ngày** | Nền trắng `#ffffff`, viền xám sáng `#cbd5e1` lệch tông | Nền tối `#1e293b`, viền `#334155`, chữ trắng `#ffffff`, `color-scheme: dark` | Đồng bộ 100% với nền tối Dark Mode CRM, popup lịch hiển thị Dark chuẩn mực. |',
  '| **Màu nền & Viền Filter Ngày** | Nền trắng `#ffffff` hoặc tối lệch tông | Nền tối chuẩn CRM `#212529`, viền `#3e444a`, chữ trắng `#ffffff`, `color-scheme: dark` (trích xuất 100% từ ảnh người dùng cung cấp) | Đồng bộ tuyệt đối với nền hệ thống CRM, không bị lệch màu. |'
);

report = report.replace(
  '| **Search Panel & Placeholder** | Sát mép phải, placeholder bị màu trắng | Dịch sang trái (`padding-right: 16px`, `margin-right: 12px`), placeholder xám `#94a3b8` | Không bị khuất góc phải, chữ gợi ý placeholder màu xám trang nhã dễ đọc. |',
  '| **Search Panel & Placeholder** | Sát mép phải, placeholder bị màu trắng | Nền `#212529`, viền `#3e444a`, dịch sang trái (`padding-right: 16px`, `margin-right: 12px`), placeholder màu xám nhạt `#8b949e` | Không bị khuất góc phải, ô tìm kiếm đồng bộ màu và chữ gợi ý placeholder xám dịu mắt. |'
);

const sec4Header = '### 4. MINH CHỨNG KẾT QUẢ GIAO DIỆN THỰC TẾ SAU KHI SỬA (AFTER FIX)';
const sec4Waiting = `### 4. MINH CHỨNG KẾT QUẢ GIAO DIỆN THỰC TẾ SAU KHI SỬA (AFTER FIX)

> [!WARNING]
> **ĐIỀU 4 (AGENT RULES & WORKING GUIDELINES)**:  
> *Ảnh minh chứng After Fix CHỈ ĐƯỢC PHÉP CHỤP khi Người Dùng xác nhận đã Execute bản vá trên Database.*  
> ⏳ **TRẠNG THÁI HIỆN TẠI: Đang chờ Người Dùng Execute file [\`fix-bug.sql\`](fix-bug.sql) trên SSMS và nhắn tin xác nhận cập nhật.**  
> Ngay sau khi Người Dùng gửi tin nhắn xác nhận (ví dụ: *"đã exec"*), Agent sẽ tự động mở Google Chrome qua Playwright truy cập \`https://paradisehrm.com/Tai3/#\`, chụp lại ảnh màn hình thực tế (Desktop + Responsive) và cập nhật trực tiếp vào mục này.
`;

const sec4Idx = report.indexOf(sec4Header);
if (sec4Idx !== -1) {
  report = report.substring(0, sec4Idx) + sec4Waiting;
}

fs.writeFileSync(reportPath, report, 'utf8');
console.log('Successfully updated fix-report.md!');
