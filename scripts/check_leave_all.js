const { query } = require('../helpers/db');

try {
  const l = query("SELECT TOP 1 * FROM tblLeaveRegistered WHERE EmployeeID = '046' ORDER BY CreateTime DESC");
  console.log('tblLeaveRegistered keys and values:', l[0]);
} catch(e) { console.error('err:', e.message); }
