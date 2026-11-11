const fs = require('fs');
const lines = fs.readFileSync('scripts/sample_sp.sql', 'utf8').split('\n');
console.log(lines.slice(170, 230).join('\n'));
