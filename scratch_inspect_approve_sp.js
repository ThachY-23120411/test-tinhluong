const { query } = require('./helpers/db');

const res1 = query(`SELECT OBJECT_DEFINITION(OBJECT_ID('sp_AttendanceConfirmRequest_Do_Approve')) AS def`);
console.log('=== sp_AttendanceConfirmRequest_Do_Approve ===');
console.log(res1[0].def);

const res2 = query(`SELECT OBJECT_DEFINITION(OBJECT_ID('sp_ApproveAttendanceRequest')) AS def`);
console.log('=== sp_ApproveAttendanceRequest ===');
console.log(res2[0].def);
