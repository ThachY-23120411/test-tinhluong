const { query } = require('../helpers/db');
const fs = require('fs');

try {
  const res1 = query("SELECT html FROM tblHtmlScriptCache WHERE TableName = 'sp_HR_StaffInformation_List_2_PopupInfoBank' AND LanguageID = 'VN'");
  if (res1.length > 0) {
    fs.writeFileSync('./scripts/popup_info_bank.html', res1[0].html, 'utf8');
    console.log('Saved popup_info_bank.html, size:', res1[0].html.length);
  }

  const res2 = query("SELECT html FROM tblHtmlScriptCache WHERE TableName = 'HR_StaffInformation_List_2' AND LanguageID = 'VN'");
  if (res2.length > 0) {
    fs.writeFileSync('./scripts/staff_info_list_2.html', res2[0].html, 'utf8');
    console.log('Saved staff_info_list_2.html, size:', res2[0].html.length);
  }
} catch (e) {
  console.error(e);
}
