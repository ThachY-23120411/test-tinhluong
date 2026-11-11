const { query } = require('../helpers/db');

try {
  const sps = ['sp_GetEmployeeLogin', 'sp_StaffInformation_PopupInfoBank_LoadDataDetail', 'sp_StaffInformation_LoadDataDetail'];
  for (const sp of sps) {
    const res = query(`SELECT OBJECT_DEFINITION(OBJECT_ID('${sp}')) as def`);
    console.log(`=== DEFINITION OF ${sp} ===`);
    console.log(res[0]?.def || 'NOT FOUND');
  }
} catch (e) {
  console.error(e);
}
