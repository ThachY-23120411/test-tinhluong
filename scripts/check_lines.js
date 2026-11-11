const fs = require('fs');
const txt = fs.readFileSync('fix-bug/screenshot-11/patch_nhap_luong_tri_luat.sql', 'utf8');
const lines = txt.split('\n');
lines.forEach((l, i) => {
  if (l.includes('Khng c')) {
    console.log(`Line ${i + 1}: ${l.trim()}`);
  }
});
