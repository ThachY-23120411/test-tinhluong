const db = require('../helpers/db');
console.log('=== sp_ViewCompanyPaySlip_List ===');
const sp1 = db.query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_ViewCompanyPaySlip_List')) as def");
console.log(sp1[0].def);

console.log('=== sp_ViewEmployeePaySlip_List ===');
const sp2 = db.query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_ViewEmployeePaySlip_List')) as def");
console.log(sp2[0].def);
