const { query } = require('../helpers/db');

try {
  const e = query("SELECT EmployeeID, FirstName + ' ' + LastName as FullName FROM tblEmployee WHERE EmployeeID IN ('011', '012', '013', '014', '046')");
  console.log('Employees:', e);
} catch(e) { console.error('err:', e.message); }
