const { query } = require('../helpers/db');
const fs = require('fs');

try {
  const def = query(`SELECT OBJECT_DEFINITION(OBJECT_ID('sp_gift_history_gift_html')) as def`)[0].def;
  fs.writeFileSync('scripts/sp_gift_history_gift_html_def.sql', def, 'utf8');
  console.log('Saved definition of sp_gift_history_gift_html, length:', def.length);

  const def2 = query(`SELECT OBJECT_DEFINITION(OBJECT_ID('sp_gift_history_gift')) as def`)[0].def;
  fs.writeFileSync('scripts/sp_gift_history_gift_def.sql', def2, 'utf8');
  console.log('Saved definition of sp_gift_history_gift, length:', def2.length);
} catch (e) {
  console.error(e.message);
}
