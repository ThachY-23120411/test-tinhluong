const { query } = require('../helpers/db');
const fs = require('fs');

try {
  const res = query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_HR_StaffInformation_List_2_PopupInfoBank')) as def");
  fs.writeFileSync('./scripts/popup_bank_sp.sql', res[0]?.def || '', 'utf8');
  console.log('Saved to scripts/popup_bank_sp.sql, length:', res[0]?.def?.length);
} catch (e) {
  console.error(e);
}
