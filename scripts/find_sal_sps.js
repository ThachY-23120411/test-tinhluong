const db = require('../helpers/db');
const sps = db.query("SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME LIKE '%Sal%' AND ROUTINE_TYPE = 'PROCEDURE'").map(r => r.ROUTINE_NAME);
console.log(sps);
