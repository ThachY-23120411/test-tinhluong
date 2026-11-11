const db = require('../helpers/db');

console.log('=== NHÂN VIÊN NÀO CÓ LƯƠNG KHÁC 0 TRONG TBLSALARYHISTORY? ===');
try {
    const nonZeroSal = db.query("SELECT TOP 20 EmployeeID, Date, Salary, InsSalary, NETSalary FROM tblSalaryHistory WHERE Salary > 0 ORDER BY Date DESC");
    console.log(nonZeroSal);
} catch(e) { console.error(e.message); }

console.log('\n=== NHÂN VIÊN NÀO CÓ LƯƠNG KHÁC 0 TRONG TBLSAL_SAL? ===');
try {
    const nonZeroSalSal = db.query("SELECT TOP 20 EmployeeID, Month, Year, ActualMonthlyBasic, GrossTakeHome, TotalIncome FROM tblSal_Sal WHERE ActualMonthlyBasic > 0 ORDER BY Year DESC, Month DESC");
    console.log(nonZeroSalSal);
} catch(e) { console.error(e.message); }

console.log('\n=== CÁC BẢN GHI KHÓA LƯƠNG CỦA 046 TRONG TBLSAL_LOCK ===');
try {
    const lock046 = db.query("SELECT * FROM tblSal_Lock WHERE EmployeeID = '046' ORDER BY Year DESC, Month DESC");
    console.log('Lock 046:', lock046);
} catch(e) { console.error(e.message); }

console.log('\n=== KỲ LƯƠNG THÁNG 9 VÀ 10 NĂM 2026 ĐÃ TÍNH CHƯA? ===');
try {
    const sepOct = db.query("SELECT Month, Year, COUNT(*) as EmpCount, SUM(ActualMonthlyBasic) as TotalBasic FROM tblSal_Sal WHERE Year = 2026 AND Month IN (8, 9, 10) GROUP BY Month, Year");
    console.log(sepOct);
} catch(e) { console.error(e.message); }
