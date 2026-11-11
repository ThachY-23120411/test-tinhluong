const { query } = require('../helpers/db');

try {
  const caches = query(`
    SELECT TableName, ScreenType, LanguageID, Version, LEN(html) as HtmlLen
    FROM tblHtmlScriptCache
    WHERE TableName LIKE '%LabourContract%' OR TableName LIKE '%MnuHRS151%' OR TableName LIKE '%Contract%'
  `);
  console.log('Caches for Contract:', caches);
} catch (e) {
  console.error(e.message);
}
