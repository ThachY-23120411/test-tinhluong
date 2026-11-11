const { query } = require('../helpers/db');

try {
  const rows = query(`
    SELECT * FROM GridColumnChooserJson WHERE GridName = 'GridEmailKPIList'
  `);
  console.log('Saved configs for GridEmailKPIList:', rows.length);
  if (rows.length > 0) console.table(rows);
} catch (e) {
  console.error('Error:', e.message);
}
