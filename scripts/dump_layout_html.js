const { query } = require('../helpers/db');
const fs = require('fs');

try {
  const def = query(`SELECT OBJECT_DEFINITION(OBJECT_ID('HtmlMacOSLayOut_html')) as def`);
  if (def && def[0]) {
    fs.writeFileSync('scripts/HtmlMacOSLayOut_html.sql', def[0].def, 'utf8');
    console.log('Saved HtmlMacOSLayOut_html.sql, size:', def[0].def.length);

    // Tìm vị trí checkAndFetchServer
    const lines = def[0].def.split('\n');
    lines.forEach((l, idx) => {
      if (l.includes('checkAndFetchServer') || l.includes('loadLiveData')) {
        console.log(`Line ${idx + 1}: ${l}`);
      }
    });
  }
} catch (e) {
  console.error('Error:', e.message);
}
