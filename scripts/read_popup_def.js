const { execSync } = require('child_process');
const fs = require('fs');

const searchSps = fs.readFileSync('scripts/search_sps.js', 'utf8');
eval(searchSps.split('const sps =')[0]);

const qDef = "SELECT SUBSTRING(definition, 1, 1200) as def FROM sys.sql_modules WHERE object_id = OBJECT_ID('sp_HR_StaffInformation_List_2_PopupAddNewEmp_html')";
const res = queryDb('Vietinsoft_ForTest_Tai2', qDef);
if (res.length > 0) {
  console.log('Definition of sp_HR_StaffInformation_List_2_PopupAddNewEmp_html:');
  console.log(res[0].def);
}
