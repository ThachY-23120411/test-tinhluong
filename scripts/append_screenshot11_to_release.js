const fs = require('fs');

let release = fs.readFileSync('fix-bug/release_patches.sql', 'utf8');
const patchSql = fs.readFileSync('fix-bug/screenshot-11/patch_nhap_luong_tri_luat.sql', 'utf8').replace(/^\uFEFF/, '');

// Check if already appended
if (release.includes('Template_SalaryImport_TriLuat_html')) {
  console.log('Already in release_patches.sql!');
  process.exit(0);
}

// 1. Add to header
const headerTarget = `      - PATCH 07: [sp_KPIgetDataCollection] Sửa SP nạp danh sách CRM: Bẫy an toàn FromDate/ToDate NULL & bảo toàn Xem tất cả`;
const headerAdd = `      - PATCH 07: [sp_KPIgetDataCollection] Sửa SP nạp danh sách CRM: Bẫy an toàn FromDate/ToDate NULL & bảo toàn Xem tất cả
      - PATCH 09: [Template_SalaryImport_TriLuat_html / MnuPRL408] Sửa bố cục Toolbar ngang hàng, lỗi font tiếng Việt và lỗi DevTools loadSingle`;

release = release.replace(headerTarget, headerAdd);

// 2. Append block before footer
const footer = `/*==================================================================================================\n  KẾT THÚC MASTER RELEASE PATCH SCRIPT\n==================================================================================================*/`;

const patchBlock = `
/*==================================================================================================
  PATCH 09: [Template_SalaryImport_TriLuat_html / MnuPRL408] Nhập lương Trí Luật (Screenshot-11)
  * Đưa cụm lọc Tháng, Năm, Checkbox, Nút tác vụ lên NGANG HÀNG 100% với Toolbar DataGrid bên phải.
  * Khắc phục triệt để lỗi DevTools: TypeError: Cannot read properties of undefined (reading 'loadSingle').
  * Khắc phục lỗi font Unicode: Thay "Khng c d? li?u" thành "Không có dữ liệu".
  * Biên dịch qua sp_GenerateHTMLScript_new và cập nhật tblHtmlScriptCache.
==================================================================================================*/
` + patchSql + `\n\n`;

release = release.replace(footer, patchBlock + footer);

fs.writeFileSync('fix-bug/release_patches.sql', release, 'utf8');
console.log('✅ Đã cập nhật thành công PATCH 09 vào fix-bug/release_patches.sql!');
