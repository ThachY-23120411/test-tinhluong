const { query } = require('../helpers/db');

try {
  const users = query(`
    SELECT TOP 5 LoginID, LoginName, IsActive, TokenID, EmployeeID
    FROM tblSC_Login
    WHERE LoginName IN ('ThanhLong', 'admin', 'test') OR IsActive = 0
  `);
  console.log('Users in tblSC_Login:', users);
} catch (e) {
  console.error(e.message);
}
