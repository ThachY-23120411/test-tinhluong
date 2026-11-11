const db = require('../helpers/db');
const sps = db.query("SELECT OBJECT_NAME(id) as name FROM syscomments WHERE text LIKE '%InsMnuPRL040%' OR text LIKE '%MnuPRL040%'");
console.log('SPs referencing MnuPRL040:', sps);
