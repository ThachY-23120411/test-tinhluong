const { query } = require('../helpers/db');

try {
  const dbs = query(`SELECT name FROM sys.databases WHERE name LIKE '%Tai%' OR name LIKE '%Vietin%'`);
  console.log('Databases matching Tai / Vietin:');
  console.log(JSON.stringify(dbs, null, 2));
} catch (e) {
  console.error(e.message);
}
