const { query } = require('../helpers/db');
const fs = require('fs');

try {
  const row = query(`
    SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'P82897F00F2844F529066CF6F15D3170B'
  `);
  if (row && row[0] && row[0].loadUI) {
    fs.writeFileSync('scripts/original_loadUI.js', row[0].loadUI, 'utf8');
    console.log('Saved original_loadUI.js, size:', row[0].loadUI.length);
  }
} catch (e) {
  console.error('Error:', e.message);
}
