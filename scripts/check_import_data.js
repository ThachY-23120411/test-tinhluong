const db = require('../helpers/db');

// Check all records in tblWH_InventoryImport
const rows = db.query(`
  SELECT cc.InventoryCode, cc.EmployeeID, ee.FullName, cc.Date, cc.CommandTypeID, cc.StatusID
  FROM tblWH_InventoryImport cc
  LEFT JOIN tblEmployee ee ON cc.EmployeeID = ee.EmployeeID
`);
console.log('tblWH_InventoryImport rows count:', rows.length);
console.log(rows);

// Check current user login
const user = db.query("SELECT EmployeeID, FullName, LoginID FROM tblEmployee WHERE EmployeeID = 1007 OR FullName LIKE N'%Chiến%' OR LoginID = 'Chien.nguyen'");
console.log('Employee match:', user);
