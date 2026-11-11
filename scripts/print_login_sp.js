const { query } = require('../helpers/db');

try {
  const res = query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_GetEmployeeLogin')) as def");
  console.log('=== sp_GetEmployeeLogin ===');
  console.log(res[0]?.def);
} catch (e) {
  console.error(e);
}
