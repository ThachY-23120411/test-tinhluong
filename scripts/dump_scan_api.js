const { query } = require('../helpers/db');
const fs = require('fs');

try {
  const def = query("SELECT OBJECT_DEFINITION(OBJECT_ID('sp_scanAPI')) as def");
  fs.writeFileSync('./scripts/sp_scanAPI.sql', def[0]?.def || '', 'utf8');
  console.log('Saved sp_scanAPI.sql, length:', def[0]?.def?.length);
} catch (e) {
  console.error(e);
}
