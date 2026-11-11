const { query } = require('../helpers/db');

try {
  const row = query("SELECT html FROM tblHtmlScriptCache WHERE TableName = 'sp_List_To_Review' AND LanguageID = 'VN'");
  const html = row[0].html;
  
  const idx = html.indexOf('getcardregisteredOA');
  console.log('Around getcardregisteredOA:\n', html.slice(Math.max(0, idx - 200), idx + 1000));
} catch(e) { console.error('err:', e.message); }
