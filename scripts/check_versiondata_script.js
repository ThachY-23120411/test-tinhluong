const { query } = require('../helpers/db');
const fs = require('fs');
const vm = require('vm');

try {
  const row = query(`
    SELECT CAST(VersionData AS NVARCHAR(MAX)) as vd
    FROM tblHtmlScriptCache
    WHERE TableName = 'sp_CRM_EmailKPIFollow' AND LanguageID = 'VN'
  `);
  if (row && row[0] && row[0].vd) {
    fs.writeFileSync('scripts/versiondata_vn.html', row[0].vd, 'utf8');
    console.log('Saved versiondata_vn.html, length:', row[0].vd.length);

    // Kiểm tra cú pháp script trong VersionData
    const scriptRegex = /<script\b[^>]*>([\s\S]*?)<\/script>/i;
    const match = scriptRegex.exec(row[0].vd);
    if (match) {
      console.log('Found script in VersionData, length:', match[1].length);
      try {
        new vm.Script(match[1]);
        console.log('VersionData script is VALID!');
      } catch (err) {
        console.error('💥 BÙM! VersionData HAS SYNTAX ERROR:', err.message);
        const lines = match[1].split('\n');
        console.log('Error around line 1341-1345:');
        for (let i = 1335; i <= 1350; i++) {
          console.log(`${i}: ${lines[i - 1]}`);
        }
      }
    }
  }
} catch (e) {
  console.error(e.message);
}
