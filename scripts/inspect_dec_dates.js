const { query } = require('../helpers/db');
const existingLeave = query("SELECT LeaveFromDate, LeaveToDate, Approve_Status FROM tblLeaveRegistered WHERE EmployeeID = '046' AND LeaveFromDate >= '2026-12-01' ORDER BY LeaveFromDate");
console.log('Existing Dec Leave:', existingLeave);
const existingOT = query("SELECT OTDateFrom, OTDateTo, Approve_Status FROM tblOTListRegistered WHERE EmployeeID = '046' AND OTDateFrom >= '2026-12-01' ORDER BY OTDateFrom");
console.log('Existing Dec OT:', existingOT);
