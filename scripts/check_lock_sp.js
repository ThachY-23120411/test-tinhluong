const fs = require('fs');
const db = require('../helpers/db');
const res = db.query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_LockSalary_CheckStatus_html')) as def");
fs.writeFileSync('scripts/lock_html.sql', res[0].def || '');
console.log('Saved lock_html.sql, len:', res[0].def ? res[0].def.length : 0);
