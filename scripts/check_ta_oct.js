const db = require('../helpers/db');

console.log('=== 1. KIỂM TRA CHẤM CÔNG THÁNG 10/2026 TRONG CSDL ===');
try {
    const taOct = db.query("SELECT COUNT(*) as count FROM tblHasTA WHERE AttDate >= '2026-10-01' AND AttDate <= '2026-10-31'");
    console.log('tblHasTA records in Oct 2026:', taOct[0].count);
} catch(e) { console.error('tblHasTA error:', e.message); }

try {
    const rawAttOct = db.query("SELECT COUNT(*) as count FROM tblAttendance WHERE AttDate >= '2026-10-01' AND AttDate <= '2026-10-31'");
    console.log('tblAttendance records in Oct 2026:', rawAttOct[0].count);
} catch(e) { console.error('tblAttendance error:', e.message); }

try {
    const taEmp046 = db.query("SELECT COUNT(*) as count FROM tblHasTA WHERE EmployeeID = '046' AND AttDate >= '2026-10-01' AND AttDate <= '2026-10-31'");
    console.log('tblHasTA for 046 in Oct 2026:', taEmp046[0].count);
} catch(e) { console.error('tblHasTA 046 error:', e.message); }

console.log('\n=== 2. KIỂM TRA THÁNG NÀO CÓ CHẤM CÔNG TRONG NĂM 2026? ===');
try {
    const monthsWithTA = db.query("SELECT MONTH(AttDate) as m, YEAR(AttDate) as y, COUNT(DISTINCT EmployeeID) as empCount, COUNT(*) as totalDays FROM tblHasTA WHERE AttDate >= '2026-01-01' GROUP BY MONTH(AttDate), YEAR(AttDate) ORDER BY y DESC, m DESC");
    console.log('Months with attendance in 2026:', monthsWithTA);
} catch(e) { console.error('monthsWithTA error:', e.message); }

console.log('\n=== 3. KIỂM TRA TỔNG HỢP CÔNG THÁNG (tblSal_AttDataSumary) ===');
try {
    const attSum = db.query("SELECT Month, Year, COUNT(*) as empCount, SUM(TotalWorkingDays) as sumDays FROM tblSal_AttDataSumary_ForReport WHERE Year = 2026 GROUP BY Month, Year ORDER BY Month DESC");
    console.log('tblSal_AttDataSumary_ForReport in 2026:', attSum);
} catch(e) { console.error('attSum error:', e.message); }
