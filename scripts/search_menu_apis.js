const { query } = require('../helpers/db');

try {
  console.log('--- Menus with sp_GetEmployeeLogin ---');
  console.log(query("SELECT MenuID FROM tblApiDecription WHERE ApiList LIKE '%sp_GetEmployeeLogin%'"));

  console.log('--- Menus with sp_StaffInformation_CheckPermissionsWithLoginID ---');
  console.log(query("SELECT MenuID FROM tblApiDecription WHERE ApiList LIKE '%sp_StaffInformation_CheckPermissionsWithLoginID%'"));

  console.log('--- Menus with sp_StaffInformation_LoadDataDetail ---');
  console.log(query("SELECT MenuID FROM tblApiDecription WHERE ApiList LIKE '%sp_StaffInformation_LoadDataDetail%'"));
} catch (e) {
  console.error(e);
}
