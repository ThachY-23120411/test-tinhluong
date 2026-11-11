const fs = require('fs');
const path = require('path');

const reportPath = path.resolve(__dirname, '../fix-bug/noi_dung_dang_tai/fix-report.md');
let report = fs.readFileSync(reportPath, 'utf8');

// Update What Changed table
const oldTable = `| **Thành phần** | Mã nguồn gốc | Mã nguồn bản vá chuẩn 3 bước | Tác dụng kỹ thuật & Nghiệp vụ |
| :--- | :--- | :--- | :--- |
| **Thẻ \`<style>\` (CSS)** | Gán cứng \`#GridContentPost .dx-toolbar-items-container { height: 70px; }\` | Chuyển sang \`height: auto !important;\`, bật \`flex-wrap: wrap\`, thêm media query \`@media (max-width: 1350px)\` | Loại bỏ tình trạng đè lấn phần tử, toolbar tự co giãn theo nội dung trên mọi kích thước màn hình. |
| **HTML Nút Thêm nội dung** | Nằm trong \`<div class="d-flex justify-content-end">\` ở trên cùng | Ẩn div cũ (\`display: none !important;\`), chuyển nút vào Toolbar Items (\`location: "after"\`) | Đưa nút xuống ngang hàng với các ô lọc và Search Panel, xóa bỏ hàng trắng dư thừa. |
| **Bố cục JS Toolbar** | Chia thành \`$firstRow\` (bộ lọc) và \`$secondRow\` (2 checkbox) | Gom toàn bộ bộ lọc và 2 checkbox vào trực tiếp \`$container\` (\`flex-wrap: wrap\`) | Đưa 2 tickbox lên ngang hàng phẳng phiu với các input chọn ngày và nút Làm mới. |
| **Search Panel Styling** | Không có CSS cho Dark Mode | Bổ sung nền \`#1e293b\`, viền \`#334155\`, chữ trắng \`#ffffff\` | Đảm bảo tính tương phản và đồng bộ thẩm mỹ tối đa trong giao diện tối CRM. |
| **SP Điều phối & Cache** | Dùng SP cũ | Chuẩn hóa \`[dbo].[sp_KPIContentPost]\` và biên dịch qua \`sp_GenerateHTMLScript_new\` | Cập nhật sạch sẽ vào cache \`tblHtmlScriptCache\`, loại bỏ hoàn toàn code chắp vá REPLACE. |`;

const newTable = `| **Thành phần** | Mã nguồn gốc | Mã nguồn bản vá chuẩn 3 bước | Tác dụng kỹ thuật & Nghiệp vụ |
| :--- | :--- | :--- | :--- |
| **Thẻ \`<style>\` (CSS Toolbar)** | Gán cứng \`#GridContentPost .dx-toolbar-items-container { height: 70px; }\` | Chuyển sang \`height: auto !important;\`, bật \`flex-wrap: wrap\`, thêm media query \`@media (max-width: 1350px)\` | Loại bỏ tình trạng đè lấn phần tử, toolbar tự co giãn theo nội dung trên mọi kích thước màn hình. |
| **Màu nền Filter Ngày** | Nền trắng \`#ffffff\`, viền xám sáng \`#cbd5e1\` lệch tông | Nền tối \`#1e293b\`, viền \`#334155\`, chữ trắng \`#ffffff\`, \`color-scheme: dark\` | Đồng bộ 100% với nền tối Dark Mode CRM, popup lịch hiển thị Dark chuẩn mực. |
| **Search Panel & Placeholder** | Sát mép phải, placeholder bị màu trắng | Dịch sang trái (\`padding-right: 16px\`, \`margin-right: 12px\`), placeholder xám \`#94a3b8\` | Không bị khuất góc phải, chữ gợi ý placeholder màu xám trang nhã dễ đọc. |
| **Nút Làm mới trùng lặp** | Tồn tại 2 nút \`$filterBtn\` và \`$resetBtn\` (bị \`display: inline-flex !important\` ép hiện) | Ẩn hoàn toàn \`#cFilterResetBtn\` (\`display: none !important\`), chỉ giữ 1 nút Làm mới xanh | Chấm dứt triệt để hiện tượng 2 nút Làm mới cạnh nhau gây rối mắt người dùng. |
| **HTML Nút Thêm nội dung** | Nằm trong \`<div class="d-flex justify-content-end">\` ở trên cùng | Ẩn div cũ (\`display: none !important;\`), chuyển nút vào Toolbar Items (\`location: "after"\`) | Đưa nút xuống ngang hàng với các ô lọc và Search Panel, xóa bỏ hàng trắng dư thừa. |
| **Bố cục JS Toolbar** | Chia thành \`$firstRow\` (bộ lọc) và \`$secondRow\` (2 checkbox) | Gom toàn bộ bộ lọc và 2 checkbox vào trực tiếp \`$container\` (\`flex-direction: row; flex-wrap: wrap\`) | Đưa 2 tickbox lên ngang hàng phẳng phiu với các input chọn ngày và nút Làm mới. |
| **SP Điều phối & Cache** | Dùng SP cũ | Chuẩn hóa \`[dbo].[sp_KPIContentPost]\` và biên dịch qua \`sp_GenerateHTMLScript_new\` | Cập nhật sạch sẽ vào cache \`tblHtmlScriptCache\`, loại bỏ hoàn toàn code chắp vá REPLACE. |`;

report = report.replace(oldTable, newTable);
fs.writeFileSync(reportPath, report, 'utf8');
console.log('Successfully updated fix-report.md table!');
