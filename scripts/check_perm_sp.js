const { query } = require('../helpers/db');

try {
  const def = query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_StaffInformation_CheckPermissionsWithLoginID')) as def");
  console.log('=== sp_StaffInformation_CheckPermissionsWithLoginID ===');
  console.log(def[0]?.def);

  console.log('=== RUN IN SQL ===');
  console.log(query("EXEC sp_StaffInformation_CheckPermissionsWithLoginID @LoginID = 62"));
} catch (e) {
  console.error(e);
}
