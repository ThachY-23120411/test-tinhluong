const { query } = require('../helpers/db');

try {
  const dbs = query(`
    SELECT name, state_desc, create_date 
    FROM sys.databases 
    WHERE name LIKE '%Vietin%' OR name LIKE '%Tai%' OR name LIKE '%Test%'
    ORDER BY name
  `);
  console.log('Databases on 192.168.11.51:');
  console.table(dbs);
} catch (e) {
  console.error('Error:', e.message);
}
