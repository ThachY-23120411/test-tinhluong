const { query } = require('../helpers/db');

try {
  const def = query("SELECT OBJECT_DEFINITION(OBJECT_ID('HR_StaffInformation_List_2_Data')) as def");
  console.log('=== HR_StaffInformation_List_2_Data ===');
  console.log(def[0]?.def || 'NOT FOUND');

  const def2 = query("SELECT OBJECT_DEFINITION(OBJECT_ID('HR_StaffInformation_ForUserWeb')) as def2");
  console.log('=== HR_StaffInformation_ForUserWeb ===');
  console.log(def2[0]?.def2 || 'NOT FOUND');
} catch (e) {
  console.error(e);
}
