const { query } = require('../helpers/db');

try {
  const apis = [
    'sp_StaffInformation_LoadDataDetail',
    'sp_StaffInformation_PopupInfoBank_LoadDataDetail',
    'sp_StaffInformation_PopupInfoBank_SaveDataManager',
    'sp_StaffInformation_CheckPermissionsWithLoginID'
  ];
  for (const api of apis) {
    const res = query(`SELECT p.LoginID, l.LoginName FROM tblApiParadisePrivilege p LEFT JOIN tblSC_Login l ON p.LoginID = l.LoginID WHERE p.Name = '${api}'`);
    console.log(`=== ${api} === (count: ${res.length})`);
    console.log(res);
  }
} catch (e) {
  console.error(e);
}
