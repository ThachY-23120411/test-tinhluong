const db = require('../helpers/db');
const fs = require('fs');
const res = db.query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_salaryslip_html')) as def");
console.log('def length:', res[0].def ? res[0].def.length : 0);
fs.writeFileSync('scripts/sp_salaryslip_def.sql', res[0].def || '');
