const db = require('../helpers/db');

console.log('=== 1. TBLSAL_LOCK (TẤT CẢ CÁC KỲ LƯƠNG ĐÃ KHÓA) ===');
try {
    const locks = db.query('SELECT DISTINCT Month, Year FROM tblSal_Lock ORDER BY Year DESC, Month DESC');
    console.log(locks);
} catch(e) { console.error('tblSal_Lock error:', e.message); }

console.log('\n=== 2. TBLSAL_SAL (TẤT CẢ CÁC KỲ LƯƠNG ĐÃ TÍNH) ===');
try {
    const salMonths = db.query('SELECT DISTINCT Month, Year FROM tblSal_Sal ORDER BY Year DESC, Month DESC');
    console.log(salMonths);
} catch(e) { console.error('tblSal_Sal error:', e.message); }

console.log('\n=== 3. DỮ LIỆU CỦA EMPLOYEE 046 (ĐẶNG MINH TÀI) ===');
try {
    const emp046 = db.query("SELECT EmployeeID, FullName, HireDate, BasicSalary, DepartmentID, PositionID FROM tblEmployee WHERE EmployeeID = '046'");
    console.log('tblEmployee 046:', emp046);
} catch(e) { console.error('tblEmployee 046 error:', e.message); }

try {
    const salHist046 = db.query("SELECT * FROM tblSalaryHistory WHERE EmployeeID = '046'");
    console.log('tblSalaryHistory 046:', salHist046);
} catch(e) { console.error('tblSalaryHistory 046 error:', e.message); }

try {
    const sal046 = db.query("SELECT EmployeeID, Month, Year, ActualMonthlyBasic, GrossTakeHome, TotalIncome, TotalDeduction FROM tblSal_Sal WHERE EmployeeID = '046'");
    console.log('tblSal_Sal 046:', sal046);
} catch(e) { console.error('tblSal_Sal 046 error:', e.message); }

console.log('\n=== 4. DỮ LIỆU CỦA EMPLOYEE 013 (NGUYỄN TẤN CHIẾN - TRONG ẢNH USER) ===');
try {
    const sal013 = db.query("SELECT EmployeeID, Month, Year, ActualMonthlyBasic, GrossTakeHome, TotalIncome FROM tblSal_Sal WHERE EmployeeID = '013' ORDER BY Year DESC, Month DESC");
    console.log('tblSal_Sal 013 (Top 5):', sal013.slice(0, 5));
} catch(e) { console.error('tblSal_Sal 013 error:', e.message); }

try {
    const lock013 = db.query("SELECT * FROM tblSal_Lock WHERE EmployeeID = '013' ORDER BY Year DESC, Month DESC");
    console.log('tblSal_Lock 013:', lock013);
} catch(e) { console.error('tblSal_Lock 013 error:', e.message); }

console.log('\n=== 5. KIỂM TRA MỨC LƯƠNG TRONG TBLSALARYHISTORY CHO TẤT CẢ NV ===');
try {
    const allSalHist = db.query("SELECT TOP 10 EmployeeID, BasicSalary, InsuranceSalary, FromDate, ToDate, SalaryHistoryID FROM tblSalaryHistory ORDER BY FromDate DESC");
    console.log('tblSalaryHistory top 10:', allSalHist);
} catch(e) { console.error('allSalHist error:', e.message); }
