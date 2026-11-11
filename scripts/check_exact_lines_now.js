const { query } = require('../helpers/db');

try {
  const res = query(`
    EXEC sp_CRM_EmailKPIFollow @LoginID = 3, @LanguageID = 'VN'
  `);
  if (res && res[0] && res[0].html) {
    const html = res[0].html;
    const lines = html.split('\n');
    console.log('Total lines:', lines.length);
    console.log('Checking lines 1335 to 1350:');
    for (let i = 1335; i <= 1350; i++) {
      if (lines[i - 1]) {
        console.log(`Line ${i}: len=${lines[i - 1].length}, char79='${lines[i - 1].charAt(78)}' | content=${lines[i - 1].trim().substring(0, 80)}`);
      }
    }
  }
} catch (e) {
  console.error(e.message);
}
