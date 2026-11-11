const db = require('../helpers/db');

console.log('=== 1. MEN_Menu for Payslip menus ===');
const menus = db.query("SELECT MenuID, ClassName, Activity, URL FROM MEN_Menu WHERE MenuID IN ('MnuPRL440', 'MnuPRL441', 'MnuPRL445', 'MnuPRL423', 'MnuPRL041', 'MnuPRL042', 'MnuHRS145')");
console.log(menus);

console.log('\n=== 2. SP definitions ===');
try {
    const sp440 = db.query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_ViewEmployeePaySlip_List')) as def");
    console.log('sp_ViewEmployeePaySlip_List len:', sp440[0].def ? sp440[0].def.length : 0);
    if (sp440[0].def) console.log(sp440[0].def.substring(0, 500));
} catch(e) { console.error('sp440 error:', e.message); }

try {
    const sp441 = db.query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_ViewCompanyPaySlip_List')) as def");
    console.log('sp_ViewCompanyPaySlip_List len:', sp441[0].def ? sp441[0].def.length : 0);
    if (sp441[0].def) console.log(sp441[0].def.substring(0, 500));
} catch(e) { console.error('sp441 error:', e.message); }

try {
    const sp041 = db.query("SELECT OBJECT_DEFINITION(OBJECT_ID('DetailSalary')) as def");
    console.log('DetailSalary len:', sp041[0].def ? sp041[0].def.length : 0);
} catch(e) { console.error('sp041 error:', e.message); }
