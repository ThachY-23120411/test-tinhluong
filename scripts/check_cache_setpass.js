const { query } = require('../helpers/db');

try {
  const row = query(`
    SELECT TableName, ScreenType, LanguageID, Version, LEN(html) as HtmlLength
    FROM tblHtmlScriptCache
    WHERE TableName LIKE '%SetInitial%' OR TableName LIKE '%Password%'
  `);
  console.log('tblHtmlScriptCache for Password:', row);
} catch (e) {
  console.error(e.message);
}
