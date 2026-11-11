const { query } = require('../helpers/db');

try {
  const def = query(`
    SELECT OBJECT_DEFINITION(OBJECT_ID('sp_GenerateHTMLScript_new')) as def
  `);
  if (def && def[0] && def[0].def) {
    const lines = def[0].def.split('\n');
    console.log('Total lines:', lines.length);
    // In những dòng có tblHtmlScriptCache
    lines.forEach((l, idx) => {
      if (l.includes('tblHtmlScriptCache') || l.includes('INSERT INTO') || l.includes('UPDATE')) {
        console.log(`${idx + 1}: ${l}`);
      }
    });
  }
} catch (e) {
  console.error('Error:', e.message);
}
