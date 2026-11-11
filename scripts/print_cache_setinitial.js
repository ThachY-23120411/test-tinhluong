const { query } = require('../helpers/db');

try {
  const row = query(`
    SELECT html
    FROM tblHtmlScriptCache
    WHERE TableName = 'SetInitialPasswordForm' AND LanguageID = 'VN'
  `);
  console.log('HTML in tblHtmlScriptCache for SetInitialPasswordForm:');
  console.log(row[0].html);
} catch (e) {
  console.error(e.message);
}
