const db = require('../helpers/db');

const rows1 = db.query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_WH_InventoryImport_html')) as def");
console.log('sp_WH_InventoryImport_html rows:', rows1.length);
if (rows1.length > 0 && rows1[0].def) {
  console.log('len:', rows1[0].def.length);
  console.log('--- sp_WH_InventoryImport_html snippet ---');
  console.log(rows1[0].def.substring(0, 500));
}

const rows2 = db.query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_WH_InventoryImport')) as def");
console.log('sp_WH_InventoryImport rows:', rows2.length);
if (rows2.length > 0 && rows2[0].def) {
  console.log('len:', rows2[0].def.length);
  console.log('--- sp_WH_InventoryImport snippet ---');
  console.log(rows2[0].def.substring(0, 500));
}
