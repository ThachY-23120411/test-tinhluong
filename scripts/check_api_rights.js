const { query } = require('../helpers/db');

try {
  console.log('--- tblSC_UserAPIRight columns ---');
  console.log(query("SELECT TOP 1 * FROM tblSC_UserAPIRight"));

  console.log('--- tblSC_UserAPIRight for LoginID 62 ---');
  console.log(query("SELECT * FROM tblSC_UserAPIRight WHERE LoginID = 62"));

  console.log('--- tblSC_Right_ByLoginID for LoginID 62 ---');
  console.log(query("SELECT * FROM tblSC_Right_ByLoginID WHERE LoginID = 62"));
} catch (e) {
  console.error(e);
}
