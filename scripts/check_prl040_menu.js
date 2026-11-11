const fs = require('fs');
const db = require('../helpers/db');
const res = db.query("SELECT OBJECT_DEFINITION(OBJECT_ID('SALCAL_MAIN')) as def");
fs.writeFileSync('scripts/SALCAL_MAIN.sql', res[0].def || '');
console.log('Saved SALCAL_MAIN.sql, len:', res[0].def ? res[0].def.length : 0);
