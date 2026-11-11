const { query } = require('../helpers/db');

try {
  const row = query(`
    SELECT TableName, LanguageID, 
           CHARINDEX('0.apply', CAST(VersionData AS NVARCHAR(MAX))) as pos_in_VersionData
    FROM tblHtmlScriptCache
    WHERE TableName LIKE '%EmailKPIFollow%'
  `);
  console.log('0.apply position in VersionData:');
  console.table(row);
} catch (e) {
  console.error('Error:', e.message);
}
