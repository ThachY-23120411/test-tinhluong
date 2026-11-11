const { query } = require('../helpers/db');

try {
  console.log('=== CHECKING tblCommonControlType_Signed ===');
  const signed1 = query(`SELECT UID, ColumnName, CHARINDEX('0.apply', loadUI) as pos FROM tblCommonControlType_Signed WHERE UID = 'PA7D7F5081185488CA62C1F211136902A'`);
  console.log('Signed PA7D (FullName):', signed1);

  const signed2 = query(`SELECT UID, ColumnName, CHARINDEX('0.apply', loadUI) as pos FROM tblCommonControlType_Signed WHERE UID = 'P3649C063B0674562BCCA3FB6B2F4DBF6'`);
  console.log('Signed P364 (Email):', signed2);

  console.log('=== CHECKING tblHtmlScriptCache ===');
  const cacheVN = query(`
    SELECT TableName, LanguageID, CHARINDEX('0.apply', CAST(html AS NVARCHAR(MAX))) as pos, LEN(CAST(html AS NVARCHAR(MAX))) as len, Version
    FROM tblHtmlScriptCache
    WHERE TableName IN ('sp_CRM_EmailKPIFollow', 'sp_CRM_EmailKPIFollow_html')
  `);
  console.table(cacheVN);
} catch (e) {
  console.error('Error:', e.message);
}
