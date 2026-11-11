const { query } = require('../helpers/db');

try {
  const tables = query(`
    SELECT TABLE_NAME 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME LIKE 'MEN_%'
  `);
  console.log('MEN tables:', tables);
} catch (e) {
  console.error(e.message);
}
