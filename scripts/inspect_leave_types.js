const { query } = require('../helpers/db');
const cols = query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblLeaveType'");
console.log('Columns of tblLeaveType:', cols.map(c => c.COLUMN_NAME));
const types = query("SELECT * FROM tblLeaveType");
console.log('Leave types:', types);
