const fs = require('fs');
const filePath = 'tests/quy_trinh_tinh_luong_nv_moi.spec.js';

if (!fs.existsSync(filePath)) {
  console.log('File does not exist:', filePath);
  process.exit(0);
}

const content = fs.readFileSync(filePath, 'utf8');
console.log('Total characters:', content.length);
const lines = content.split('\n');
console.log('Total lines:', lines.length);

lines.forEach((l, i) => {
  if (l.includes('START_TC_') || l.includes('END_TC_') || l.includes('fix-') || l.includes('test(')) {
    console.log(`Line ${i + 1}: ${l.trim()}`);
  }
});
