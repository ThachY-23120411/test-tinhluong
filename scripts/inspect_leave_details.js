const { query } = require('../helpers/db');
const details = query("SELECT LeaveDate, LeaveFrom, LeaveTo, Approve_Status FROM tblLeaveRegistered_Detail WHERE EmployeeID = '046' AND LeaveDate >= '2026-11-20' ORDER BY LeaveDate");
console.log('tblLeaveRegistered_Detail records:', details);
