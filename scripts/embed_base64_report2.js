const fs = require('fs');

let content = fs.readFileSync('fix-bug/screenshot-2/fix-report.md', 'utf8');

const p2 = 'fix-bug/screenshot-2/screenshots/2.png';
const pHeader = 'fix-bug/screenshot-2/screenshots/header_cell_alignment_bug.png';
const pActual = 'fix-bug/screenshot-2/screenshots/actual_live_grid.png';

const b64_2 = fs.readFileSync(p2).toString('base64');
const b64_header = fs.readFileSync(pHeader).toString('base64');
const b64_actual = fs.readFileSync(pActual).toString('base64');

// Replace relative paths with Base64 data URIs
content = content.replace(
  '![Ảnh lỗi co cụm ban đầu](./screenshots/2.png)',
  `![Ảnh lỗi co cụm ban đầu](data:image/png;base64,${b64_2})`
);

content = content.replace(
  '![Ảnh lỗi lệch căn hàng Header vs Cell](./screenshots/header_cell_alignment_bug.png)',
  `![Ảnh lỗi lệch căn hàng Header vs Cell](data:image/png;base64,${b64_header})`
);

content = content.replace(
  '![Ảnh nghiệm thu thực tế sau khi sửa](./screenshots/actual_live_grid.png)',
  `![Ảnh nghiệm thu thực tế sau khi sửa](data:image/png;base64,${b64_actual})`
);

fs.writeFileSync('fix-bug/screenshot-2/fix-report.md', content, 'utf8');

console.log('Done! Updated fix-bug/screenshot-2/fix-report.md with Base64 images.');
console.log('File size:', fs.statSync('fix-bug/screenshot-2/fix-report.md').size, 'bytes');
