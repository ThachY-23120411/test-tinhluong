const fs = require('fs');

const masterPath = 'fix-bug/release_patches.sql';
let content = fs.readFileSync(masterPath, 'utf8');

const fixBugSql = fs.readFileSync('fix-bug/lich_su_nhap_kho/fix-bug.sql', 'utf8');

const patchHeader = `

-- ============================================================================
-- PATCH 11: [sp_WH_InventoryImport_html] & [sp_WH_InventoryImport]
-- MENU: Trang Chủ CRM > Kho > Lịch sử nhập kho (MnuKPI019) (Screenshot 29)
-- MÔ TẢ: Chuẩn hóa thanh công cụ Toolbar đơn dòng, đồng bộ màu sắc Dark Tokens (#212529/#3e444a),
--       bỏ floating outline label đè viền ô ngày, tối ưu tỷ lệ cột DataGrid co giãn responsive.
-- ============================================================================
`;

// Find where PATCH 11 starts if already appended
const p11Idx = content.indexOf('-- PATCH 11:');
if (p11Idx !== -1) {
  content = content.substring(0, p11Idx).trimEnd();
  content = content + patchHeader + fixBugSql;
} else {
  content = content + patchHeader + fixBugSql;
}

fs.writeFileSync(masterPath, content, 'utf8');
console.log('Updated PATCH 11 in release_patches.sql successfully!');
