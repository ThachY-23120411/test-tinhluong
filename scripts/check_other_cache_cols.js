const { query } = require('../helpers/db');

try {
  const row = query(`
    SELECT TableName, LanguageID,
           LEN(CAST(html AS NVARCHAR(MAX))) as len_html,
           LEN(CAST(HtmlParadise AS NVARCHAR(MAX))) as len_HtmlParadise,
           LEN(CAST(paradiseJs AS NVARCHAR(MAX))) as len_paradiseJs,
           LEN(CAST(VersionData AS NVARCHAR(MAX))) as len_VersionData,
           CHARINDEX('0.apply', CAST(html AS NVARCHAR(MAX))) as pos_html,
           CHARINDEX('0.apply', CAST(HtmlParadise AS NVARCHAR(MAX))) as pos_HtmlParadise,
           CHARINDEX('0.apply', CAST(paradiseJs AS NVARCHAR(MAX))) as pos_paradiseJs,
           CHARINDEX('0.apply', CAST(VersionData AS NVARCHAR(MAX))) as pos_VersionData
    FROM tblHtmlScriptCache
    WHERE TableName LIKE '%EmailKPIFollow%'
  `);
  console.log('Columns in tblHtmlScriptCache for EmailKPIFollow:');
  console.table(row);
} catch (e) {
  console.error('Error:', e.message);
}
