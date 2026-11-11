const db = require('../helpers/db');
console.log('Att summary 046 in Oct 2026:', db.query("SELECT * FROM tblSal_AttDataSumary_ForReport WHERE EmployeeID = '046' AND Month = 10 AND Year = 2026"));
