const db = require('../helpers/db');
const errs = db.query("SELECT * FROM tblProcessErrorMessage");
console.log('tblProcessErrorMessage:', errs);
