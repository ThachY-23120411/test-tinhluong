const db = require('../helpers/db');
console.log('Sal in Oct 2026:', db.query("SELECT COUNT(*) as count FROM tblSal_Sal WHERE Month = 10 AND Year = 2026"));
console.log('Sal details in Oct 2026:', db.query("SELECT COUNT(*) as count FROM tblSal_Sal_Detail WHERE Month = 10 AND Year = 2026"));
