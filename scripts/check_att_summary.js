const db = require('../helpers/db');
console.log('Att summary Oct 2026:', db.query("SELECT COUNT(*) as count FROM tblSal_AttDataSumary_ForReport WHERE Month = 10 AND Year = 2026"));
console.log('Att summary Sep 2026:', db.query("SELECT COUNT(*) as count FROM tblSal_AttDataSumary_ForReport WHERE Month = 9 AND Year = 2026"));
console.log('Att summary Aug 2026:', db.query("SELECT COUNT(*) as count FROM tblSal_AttDataSumary_ForReport WHERE Month = 8 AND Year = 2026"));
