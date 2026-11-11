const { query } = require('../helpers/db');

try {
  const names = ['HR_StaffInformation_List_2', 'sp_HR_StaffInformation_List_2', 'sp_HR_StaffInformation_List_2_PopupInfoBank'];
  for (const name of names) {
    const res = query(`SELECT name, type_desc FROM sys.objects WHERE name = '${name}'`);
    console.log(`${name}:`, res);
  }
} catch (e) {
  console.error(e);
}
