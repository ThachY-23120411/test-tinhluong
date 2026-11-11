const fs = require('fs');
const lines = fs.readFileSync('scripts/current_db_sp_def.sql', 'utf8').split('\n');
console.log(lines.slice(140, 240).join('\n'));
