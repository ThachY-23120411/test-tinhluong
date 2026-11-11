const { query } = require('../helpers/db');

try {
  const obj = query(`
    SELECT name, type, type_desc 
    FROM sys.objects 
    WHERE name LIKE '%EmailKPIFollow%'
  `);
  console.log('Objects in Vietinsoft_ForTest_Tai2:');
  console.table(obj);
} catch (e) {
  console.error('Error:', e.message);
}
