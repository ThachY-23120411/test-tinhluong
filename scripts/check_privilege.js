const { query } = require('../helpers/db');

try {
  const apis = query("SELECT Name FROM tblApiParadisePrivilege WHERE LoginID = 62");
  console.log('Total APIs allowed for LoginID 62 (Tai.Dang):', apis.length);
  const targetApis = [
    'sp_GetEmployeeLogin',
    'sp_StaffInformation_LoadDataDetail',
    'sp_StaffInformation_PopupInfoBank_LoadDataDetail',
    'sp_StaffInformation_PopupInfoBank_SaveDataManager',
    'sp_StaffInformation_CheckPermissionsWithLoginID',
    'api_saveDataEditUserData_All'
  ];
  for (const api of targetApis) {
    const has = apis.some(a => a.Name.toLowerCase() === api.toLowerCase());
    console.log(`- ${api}: ${has ? 'ALLOWED (YES)' : 'BLOCKED (NO)'}`);
  }
} catch (e) {
  console.error(e);
}
