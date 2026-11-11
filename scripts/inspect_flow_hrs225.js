const fs = require('fs');
const c = fs.readFileSync('tests/cham_cong_tinh_luong_flow.spec.js', 'utf8');
const lines = c.split('\n');
console.log(lines.slice(690, 770).join('\n'));
