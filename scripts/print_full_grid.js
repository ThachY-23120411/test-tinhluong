const fs = require('fs');

const def = fs.readFileSync('scripts/sp_gift_history_gift_html_def.sql', 'utf8');
const idx = def.indexOf('$("#hist_grid").dxDataGrid');
const endIdx = def.indexOf('});', idx);
console.log('--- Full dxDataGrid config ---');
console.log(def.substring(idx, endIdx + 3));
