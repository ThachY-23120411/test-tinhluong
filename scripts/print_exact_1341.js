const { query } = require('../helpers/db');

try {
  const res = query(`
    EXEC sp_CRM_EmailKPIFollow @LoginID = 3, @LanguageID = 'VN'
  `);
  if (res && res[0] && res[0].html) {
    const lines = res[0].html.split('\n');
    console.log('Lines 1335 to 1350 of res[0].html:');
    for (let i = 1335; i <= 1350; i++) {
      console.log(`${i}: ${lines[i - 1]}`);
    }
  }
} catch (e) {
  console.error(e.message);
}
