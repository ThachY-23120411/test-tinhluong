const db = require('../helpers/db');
const res = db.query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_ProcessDependentAdjustment')) as def");
console.log(res[0].def ? res[0].def.substring(0, 3000) : 'None');
