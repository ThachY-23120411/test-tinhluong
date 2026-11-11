const { query } = require('../helpers/db');

try {
  const rows = query(`
    SELECT TableName, LanguageID, ScreenType, LEN(CAST([html] AS NVARCHAR(MAX))) as html_len, Version
    FROM tblHtmlScriptCache 
    WHERE TableName LIKE '%EmailKPIFollow%'
  `);
  console.log('tblHtmlScriptCache for EmailKPIFollow:');
  console.table(rows);
} catch (e) {
  console.error('Error:', e.message);
}
