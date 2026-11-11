const { query } = require('../helpers/db');

try {
  const res = query(`
    SELECT TableName, LanguageID, ScreenType, Version, VersionData 
    FROM tblHtmlScriptCache 
    WHERE TableName LIKE '%Debt%'
  `);
  console.log('Version info in tblHtmlScriptCache:');
  console.log(JSON.stringify(res, null, 2));
} catch (e) {
  console.error(e.message);
}
