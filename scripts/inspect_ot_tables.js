const { query } = require('../helpers/db');

try {
  const r1 = query("SELECT TOP 1 * FROM tblOTListRegistered WHERE EmployeeID = '046' ORDER BY CreateTime DESC");
  console.log('tblOTListRegistered row:', r1[0]);
} catch(e) { console.error('err1:', e.message); }

try {
  const r2 = query("SELECT TOP 1 * FROM tblOvertime_Assignment_Detail WHERE EmployeeID = '046' ORDER BY ID DESC");
  console.log('tblOvertime_Assignment_Detail row:', r2[0]);
} catch(e) { console.error('err2:', e.message); }
