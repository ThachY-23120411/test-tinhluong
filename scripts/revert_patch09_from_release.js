const fs = require('fs');

let content = fs.readFileSync('fix-bug/release_patches.sql', 'utf8');

// 1. Remove PATCH 09 from header
const headerPatch09 = `\n      - PATCH 09: [Template_SalaryImport_TriLuat_html / MnuPRL408] Sửa bố cục Toolbar ngang hàng, lỗi font tiếng Việt và lỗi DevTools loadSingle`;
content = content.replace(headerPatch09, '');

// 2. Remove PATCH 09 block
const patch09Index = content.indexOf("/*==================================================================================================\n  PATCH 09:");
const footerMarker = "/*==================================================================================================\n  KẾT THÚC MASTER RELEASE PATCH SCRIPT\n==================================================================================================*/\n";

if (patch09Index !== -1) {
  content = content.slice(0, patch09Index) + footerMarker;
  console.log('Removed PATCH 09 block successfully!');
}

fs.writeFileSync('fix-bug/release_patches.sql', content, 'utf8');

console.log('Done! Current lines in release_patches.sql:', content.split('\n').length);
console.log('Contains Template_SalaryImport_TriLuat:', content.includes('Template_SalaryImport_TriLuat'));
