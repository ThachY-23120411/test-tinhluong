const { query } = require('../helpers/db');

try {
  const callers = query(`
    SELECT DISTINCT o.name 
    FROM sys.sql_modules m 
    JOIN sys.objects o ON m.object_id = o.object_id
    WHERE m.definition LIKE '%VersionData%'
    ORDER BY o.name
  `);
  console.log('SPs referencing VersionData:');
  console.table(callers);
} catch (e) {
  console.error('Error:', e.message);
}
