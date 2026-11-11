const fs = require('fs');
const path = require('path');

const releasePath = path.resolve(__dirname, '../fix-bug/release_patches.sql');
const customerFixPath = path.resolve(__dirname, '../fix-bug/crm_customer_data/fix-bug.sql');

let releaseContent = fs.readFileSync(releasePath, 'utf8');
const customerFixContent = fs.readFileSync(customerFixPath, 'utf8');

// Check if PATCH 13 already exists in release_patches.sql
if (releaseContent.includes('PATCH 13: [sp_KPIListDataCollection_html]')) {
  console.log('PATCH 13 already exists in release_patches.sql, replacing it...');
  const patchStart = releaseContent.indexOf('-- PATCH 13: [sp_KPIListDataCollection_html]');
  releaseContent = releaseContent.substring(0, patchStart).trim();
}

// Add PATCH 13 to header index if not present
if (!releaseContent.includes('PATCH 13: [sp_KPIListDataCollection_html]')) {
  const patch12Header = '- PATCH 12: [sp_KPIProcessCustomer_html] & [sp_KPIProcessCustomer] Responsive toàn bộ tỷ lệ màn hình cho Sales Pipeline (MnuKPI007)';
  const patch13Header = `${patch12Header}\r\n      - PATCH 13: [sp_KPIListDataCollection_html] & [sp_KPIListDataCollection] Responsive toàn bộ tỷ lệ màn hình cho Dữ liệu khách hàng (MnuKPI003)`;
  if (releaseContent.includes(patch12Header)) {
    releaseContent = releaseContent.replace(patch12Header, patch13Header);
  }
}

const patch13Body = `

-- ===================================================================
-- PATCH 13: [sp_KPIListDataCollection_html] & [sp_KPIListDataCollection]
-- Áp dụng Bộ 6 Nhóm quy tắc /responsive-rules cho Dữ liệu khách hàng (MnuKPI003)
-- 1. Baseline Resolution: Master Layout Lock 1920px & Max-Width Pinning
-- 2. Bảo toàn 100% Style gốc của Component (Capsule, Funnel, Minimalist Icons)
-- 3. Right-to-Left Wrapping: Cụm hành động phải rớt Hàng 2 bám sát lề phải (margin-left: auto)
-- 4. Normal Document Flow: Triệt tiêu 100% lỗi che khuất DataGrid
-- 5. Đồng cấp hóa Sibling: Triệt tiêu bẫy lồng nhau @container 1180px vỡ vụn 4 hàng
-- ===================================================================
GO

${customerFixContent.trim()}
`;

releaseContent = releaseContent.trim() + '\r\n' + patch13Body;
fs.writeFileSync(releasePath, releaseContent, 'utf8');
console.log('🎉 Synchronized PATCH 13 into release_patches.sql successfully! Total length:', releaseContent.length);
