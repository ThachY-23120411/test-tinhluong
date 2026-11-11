const { query } = require('../helpers/db');
const fs = require('fs');

try {
  const r3 = query(`SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'P2D9DF38DBC46406C8EC1686058288F56'`);
  if (r3 && r3[0]) {
    fs.writeFileSync('scripts/loadUI_P2D9.js', r3[0].loadUI, 'utf8');
    console.log('Saved loadUI_P2D9.js, size:', r3[0].loadUI.length);
    console.log('Contains 0.apply?', r3[0].loadUI.includes('0.apply'));
  }
} catch (e) {
  console.error('Error:', e.message);
}
