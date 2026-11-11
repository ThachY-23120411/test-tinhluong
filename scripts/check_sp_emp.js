const db = require('../helpers/db');

const rows = db.query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_EmployeeListDataMultiSelectSelectBox')) as def");
console.log(rows[0]?.def);
