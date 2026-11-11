const { query } = require('../helpers/db');
const fs = require('fs');

try {
  const r1 = query(`SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'PA7D7F5081185488CA62C1F211136902A'`);
  if (r1 && r1[0]) {
    fs.writeFileSync('scripts/loadUI_PA7D.js', r1[0].loadUI, 'utf8');
    console.log('Saved loadUI_PA7D.js, size:', r1[0].loadUI.length);
  }

  const r2 = query(`SELECT loadUI FROM tblCommonControlType_Signed WHERE UID = 'P3649C063B0674562BCCA3FB6B2F4DBF6'`);
  if (r2 && r2[0]) {
    fs.writeFileSync('scripts/loadUI_P364.js', r2[0].loadUI, 'utf8');
    console.log('Saved loadUI_P364.js, size:', r2[0].loadUI.length);
  }
} catch (e) {
  console.error('Error:', e.message);
}
