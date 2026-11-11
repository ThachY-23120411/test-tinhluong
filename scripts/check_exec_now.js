const { query } = require('../helpers/db');

try {
  const def = query(`
    SELECT OBJECT_DEFINITION(OBJECT_ID('sp_CRM_EmailKPIFollow')) as def
  `);
  console.log('def:', def[0].def);

  const res = query(`
    EXEC sp_CRM_EmailKPIFollow @LoginID = 3, @LanguageID = 'VN'
  `);
  console.log('Exec result rows:', res.length);
  if (res.length > 0) {
    console.log('html length:', (res[0].html || '').length);
  }
} catch (e) {
  console.error('Error:', e.message);
}
