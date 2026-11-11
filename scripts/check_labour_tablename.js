const { query } = require('../helpers/db');

try {
  const rows = query(`
    SELECT TableName, LEN(TableName) as NameLen, ScreenType, LanguageID, Version, LEN(html) as HtmlLen
    FROM tblHtmlScriptCache
    WHERE TableName LIKE 'LabourContract%'
  `);
  console.log('TableName details:');
  rows.forEach(r => {
    console.log(`TableName: '${r.TableName}' (len: ${r.NameLen}), Lang: ${r.LanguageID}, Ver: ${r.Version}, HtmlLen: ${r.HtmlLen}`);
  });
} catch (e) {
  console.error(e.message);
}
