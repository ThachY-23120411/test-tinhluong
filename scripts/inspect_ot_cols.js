const { query } = require('../helpers/db');
const cols = query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblOTListRegistered'");
console.log('Columns of tblOTListRegistered:', cols.map(c => c.COLUMN_NAME));
