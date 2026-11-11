const db = require('../helpers/db');

const rows = db.query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_WH_getGridInventoryImport')) as def");
if (rows && rows.length > 0 && rows[0].def) {
  console.log(rows[0].def);
} else {
  console.log('Procedure sp_WH_getGridInventoryImport not found');
}
