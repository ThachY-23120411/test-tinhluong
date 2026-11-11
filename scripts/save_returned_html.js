const { query } = require('../helpers/db');
const fs = require('fs');

try {
  const res = query(`
    EXEC sp_CRM_EmailKPIFollow @LoginID = 3, @LanguageID = 'VN'
  `);
  if (res && res[0] && res[0].html) {
    fs.writeFileSync('scripts/returned_html.html', res[0].html, 'utf8');
    console.log('Saved returned_html.html, size:', res[0].html.length);
  }
} catch (e) {
  console.error('Error:', e.message);
}
