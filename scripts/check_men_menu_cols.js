const { query } = require('../helpers/db');

try {
  const cols = query(`
    SELECT COLUMN_NAME, DATA_TYPE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'MEN_Menu'
  `);
  console.log('MEN_Menu columns:', cols);
} catch (e) {
  console.error(e.message);
}
