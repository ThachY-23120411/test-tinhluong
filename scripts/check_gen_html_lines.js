const { query } = require('../helpers/db');

try {
  const def = query(`
    SELECT OBJECT_DEFINITION(OBJECT_ID('sp_GenerateHTMLScript_new')) as def
  `);
  const lines = def[0].def.split('\n');
  console.log(lines.slice(165, 195).join('\n'));
} catch (e) {
  console.error('Error:', e.message);
}
