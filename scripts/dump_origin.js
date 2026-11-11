const db = require('../helpers/db');
const fs = require('fs');
const path = require('path');

const rows = db.query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_WH_InventoryImport_html')) as def");
if (rows && rows.length > 0 && rows[0].def) {
  const originPath = path.resolve('fix-bug/lich_su_nhap_kho/origin.sql');
  fs.writeFileSync(originPath, rows[0].def, 'utf8');
  console.log('Saved origin.sql successfully. Length:', rows[0].def.length);
} else {
  console.error('Failed to get definition of sp_WH_InventoryImport_html');
}
