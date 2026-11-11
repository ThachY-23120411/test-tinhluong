const { query } = require('../helpers/db');

try {
  const l = query("SELECT TOP 1 * FROM tblLeaveRegistered WHERE EmployeeID = '046' ORDER BY CreateTime DESC");
  console.log('tblLeaveRegistered latest row approvers:', {
    Approver_1: l[0].Approver_1,
    Approver_2: l[0].Approver_2,
    Approver: l[0].Approver,
    Approve_Status: l[0].Approve_Status,
    Current_Approved_Level: l[0].Current_Approved_Level
  });
} catch(e) { console.error('err:', e.message); }
