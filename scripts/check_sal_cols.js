const db = require('../helpers/db');
console.log('Columns of tblSal_Sal:');
const cols = db.query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSal_Sal'");
console.log(cols.map(c => c.COLUMN_NAME).join(', '));
