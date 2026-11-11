const db = require('../helpers/db');
const res = db.query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_getSalSalSalarySlip')) as def");
console.log(res[0].def);
