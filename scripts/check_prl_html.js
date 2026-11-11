const db = require('../helpers/db');
const res = db.query("SELECT MenuID, ClassName, URL FROM MEN_Menu WHERE MenuID IN ('MnuPRL040', 'MnuPRL080', 'MnuPRL445', 'MnuHRS145')");
console.log(res);
