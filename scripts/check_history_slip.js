const db = require('../helpers/db');
console.log('History 013:', db.query("EXEC sp_getSalSalSalarySlip @TargetEmployeeID = '013'"));
console.log('History 046:', db.query("EXEC sp_getSalSalSalarySlip @TargetEmployeeID = '046'"));
