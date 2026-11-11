const db = require('../helpers/db');
const res = db.query("SELECT MenuID, ClassName FROM MEN_Menu WHERE MenuID LIKE 'MnuPRL%' ORDER BY MenuID");
console.log(res);
