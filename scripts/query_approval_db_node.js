const { query } = require('../helpers/db');

try {
  console.log('--- 1. 5 ĐƠN BÙ CÔNG GẦN NHẤT CỦA TAI.DANG (046) ---');
  const taiRequests = query(`
    SELECT TOP 5 IdentityID, AttDate, Remark, Approver_1, Approver_2, Current_Approve_Level, Approve_Status, CreateTime 
    FROM tblAttendanceConfirmRequest 
    WHERE EmployeeID = '046' 
    ORDER BY CreateTime DESC
  `);
  console.log(JSON.stringify(taiRequests, null, 2));

  console.log('\n--- 2. TẤT CẢ CÁC ĐƠN ĐANG CHỜ DUYỆT (Approve_Status = 1) ---');
  const pendingRequests = query(`
    SELECT TOP 10 ACR.IdentityID, ACR.EmployeeID, E.FullName, ACR.AttDate, ACR.Remark, ACR.Approver_1, ACR.Approver_2, ACR.CreateTime
    FROM tblAttendanceConfirmRequest ACR
    LEFT JOIN tblEmployee E ON E.EmployeeID = ACR.EmployeeID
    WHERE ACR.Approve_Status = 1
    ORDER BY ACR.CreateTime DESC
  `);
  console.log(JSON.stringify(pendingRequests, null, 2));

  console.log('\n--- 3. THÔNG TIN NHÂN VIÊN VÀ QUẢN LÝ CỦA TAI.DANG ---');
  const empInfo = query(`
    SELECT E.EmployeeID, E.FullName, E.DepartmentID, D.DepartmentName, E.ManagerID
    FROM tblEmployee E
    LEFT JOIN tblDepartment D ON D.DepartmentID = E.DepartmentID
    WHERE E.EmployeeID IN ('046', '011', '014', '013')
  `);
  console.log(JSON.stringify(empInfo, null, 2));

} catch (e) {
  console.error('Error:', e);
}
