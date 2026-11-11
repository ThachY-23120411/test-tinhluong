const { query } = require('../helpers/db');

try {
  const allApis = [
    'sp_StaffInformation_CheckPermissionsWithLoginID',
    'sp_GetEmployeeLogin',
    'sp_StaffInformation_LoadDataDetail',
    'sp_HR_StaffInformation_GetPendingChangeFields',
    'sp_HR_StaffInformation_LoadMobilePopup_html',
    'sp_HR_StaffInformation_List_2_LoadTab_Translated',
    'ImportLocationFolder',
    'sp_StaffInformation_PopupInfoBank_LoadDataDetail',
    'sp_StaffInformation_PopupInfoBank_SaveDataManager',
    'api_saveDataEditUserData_All'
  ];

  const res = query(`SELECT Name FROM tblApiParadisePrivilege WHERE LoginID = 62 AND Name IN ('${allApis.join("','")}')`);
  const existing = res.map(r => r.Name);
  
  console.log('=== FOR LOGINID 62 (Tai.Dang) ===');
  for (const api of allApis) {
    console.log(`${existing.includes(api) ? '✅ GRANTED' : '❌ MISSING'}: ${api}`);
  }
} catch (e) {
  console.error(e);
}
