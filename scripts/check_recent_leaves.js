const { query } = require('../helpers/db');
const res = query("SELECT TOP 5 IdentityID, EmployeeID, LeaveFromDate, LeaveToDate, Reason, Approve_Status FROM tblLeaveRegistered WHERE EmployeeID = '046' ORDER BY LeaveFromDate DESC");
console.log('Recent leaves for 046:', res);
