const { query } = require('../helpers/db');

try {
  const def = query(`
    SELECT OBJECT_DEFINITION(OBJECT_ID('sp_GridColumnChooser_Load')) as def
  `);
  if (def && def[0]) {
    console.log(def[0].def);
  }
} catch (e) {
  console.error('Error:', e.message);
}
