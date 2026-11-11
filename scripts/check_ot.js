const { query } = require('../helpers/db');

console.log('--- sp_Overtime_ChangeDate ---');
const def = query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_Overtime_ChangeDate')) as def");
console.log(def[0]?.def);




