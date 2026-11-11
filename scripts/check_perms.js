const { query } = require('../helpers/db');

try {
  const perms = query(`
    SELECT 
      o.name as ObjectName,
      dp.permission_name,
      dp.state_desc,
      u.name as GranteeName
    FROM sys.database_permissions dp
    INNER JOIN sys.objects o ON dp.major_id = o.object_id
    INNER JOIN sys.database_principals u ON dp.grantee_principal_id = u.principal_id
    WHERE o.name IN ('sp_GetEmployeeLogin', 'sp_StaffInformation_PopupInfoBank_LoadDataDetail', 'sp_StaffInformation_LoadDataDetail', 'sp_StaffInformation_CheckPermissionsWithLoginID')
  `);
  console.log('Database Permissions:', perms);
} catch (e) {
  console.error(e);
}
