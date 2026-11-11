const { query } = require('../helpers/db');

try {
  // Tìm bảng lưu column chooser hoặc config
  const tables = query(`
    SELECT name FROM sys.tables 
    WHERE name LIKE '%Column%' OR name LIKE '%Chooser%' OR name LIKE '%GridConfig%'
  `);
  console.log('Tables for column config:', tables);

  // Thử tìm trong các bảng đó
  tables.forEach(t => {
    try {
      const rows = query(`SELECT TOP 5 * FROM ${t.name} WHERE GridName LIKE '%Email%' OR TableName LIKE '%Email%' OR MenuID LIKE '%KPI%'`);
      console.log(`Matches in ${t.name}:`, rows.length);
      if (rows.length > 0) console.table(rows);
    } catch(err) {}
  });
} catch (e) {
  console.error('Error:', e.message);
}
