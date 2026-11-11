const fs = require('fs');
const content = fs.readFileSync('scripts/sp_PaySlipView_def.sql', 'utf8');
const lines = content.split('\n');
console.log(lines.slice(50, 95).join('\n'));
