const fs = require('fs');
const path = require('path');

let releaseContent = fs.readFileSync('fix-bug/release_patches.sql', 'utf8');
const fixBugContent = fs.readFileSync('fix-bug/sales_pipeline/fix-bug.sql', 'utf8');

const patch12Marker = '-- PATCH 12:';
const p12Idx = releaseContent.indexOf(patch12Marker);

const patch12Section = `

-- ============================================================================
-- PATCH 12: [sp_KPIProcessCustomer_html] & [sp_KPIProcessCustomer]
-- MENU: Trang Chủ CRM > Sales Pipeline (MnuKPI007)
-- MÔ TẢ: Áp dụng quy chuẩn /responsive-rules (Bảo toàn 100% Style gốc của Component):
--       1. Bố cục 1 hàng duy nhất trên Desktop/Laptop (1366px - 1440px+):
--          - Căn trái: Bộ lọc nhân viên, các nút thời gian (Tất cả, Hôm nay, Tháng này, Quý này, Năm nay, Từ/Đến ngày), nút Làm mới.
--          - Căn phải (margin-left: auto !important): Nút + Thêm mới và Searchbox tìm kiếm theo nội dung.
--       2. Giữ nguyên 100% Visual Styling gốc của Component:
--          - Giữ nguyên toàn bộ inline style, màu sắc (#198754), border-radius (8px), padding, font-size của nút + Thêm mới.
--          - Giữ nguyên toàn bộ style, class, icon của nút Làm mới.
--          - Giữ nguyên style bo tròn 20px, màu nền #f8f9fa, shadow của Searchbox; chỉ mở rộng width 260px (min-width 240px) chống khuất placeholder.
--          - Giữ nguyên cấu trúc dropdown nhân viên, chỉ định hình min-width 180px trên wrapper chống rớt dòng chữ.
--       3. Cơ chế Responsive linh hoạt cho mọi tỷ lệ màn hình (Windows Snap 1024px / 768px):
--          - Tự động dàn đều trang (flex-wrap: wrap), gom cụm hành động bên phải thành khối thống nhất (.toolbar-right-actions),
--            chỉ khi hết khoảng trống mới xuống hàng 2 nhẹ nhàng, không bao giờ bị vỡ bố cục thành 3 hàng đơn lẻ.
--          - Giữ nguyên Normal Document Flow (position: static, height: auto) để Kanban board bên dưới trượt xuống tự nhiên, không che khuất.
-- Chuẩn hóa: Tuân thủ nghiêm ngặt 3 bước Clean Code không dùng REPLACE theo quy chuẩn AGENTS.md & fix-rules.
-- ============================================================================

` + fixBugContent.trim() + '\n';

if (p12Idx !== -1) {
  // Find preceding comment line
  const precedingLine = releaseContent.lastIndexOf('-- ============================================================================', p12Idx);
  const cutIdx = precedingLine !== -1 ? precedingLine : p12Idx;
  releaseContent = releaseContent.substring(0, cutIdx).trim() + patch12Section;
  console.log('✓ Replaced existing PATCH 12 in release_patches.sql');
} else {
  releaseContent = releaseContent.trim() + patch12Section;
  console.log('✓ Appended PATCH 12 to release_patches.sql');
}

fs.writeFileSync('fix-bug/release_patches.sql', releaseContent, 'utf8');
console.log('✓ Successfully synchronized PATCH 12 into fix-bug/release_patches.sql, length:', releaseContent.length);
