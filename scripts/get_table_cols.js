const { query } = require('../helpers/db');

try {
  const colsMenu = query(`
    SELECT COLUMN_NAME, DATA_TYPE 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'MEN_Menu'
  `);
  console.log('Columns in MEN_Menu:', colsMenu.map(c => c.COLUMN_NAME).join(', '));

  const colsCache = query(`
    SELECT COLUMN_NAME, DATA_TYPE 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'tblHtmlScriptCache'
  `);
  console.log('Columns in tblHtmlScriptCache:', colsCache.map(c => c.COLUMN_NAME).join(', '));
} catch (e) {
  console.error('Error:', e.message);
}
