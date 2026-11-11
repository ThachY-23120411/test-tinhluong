const { query } = require('../helpers/db');

try {
  const row = query(`
    SELECT *
    FROM MEN_Menu
    WHERE MenuID = 'MnuSCR612'
  `);
  console.log('MnuSCR612 in MEN_Menu:', JSON.stringify(row, null, 2));
} catch (e) {
  console.error(e.message);
}
