const fs = require('fs');
const c = fs.readFileSync('tests/cham_cong_tinh_luong_flow.spec.js', 'utf8');
const lines = c.split('\n');
lines.forEach((l, i) => {
  if (l.includes('MnuHRS225') || l.includes('MnuTAD1000') || l.includes('MnuHRS033') || l.includes('MnuWPT315') || l.includes('MnuWPT316')) {
    console.log('Line ' + (i + 1) + ': ' + l.trim());
  }
});
