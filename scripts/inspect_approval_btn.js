const { query } = require('../helpers/db');

try {
  const row = query("SELECT html FROM tblHtmlScriptCache WHERE TableName = 'sp_List_To_Review' AND LanguageID = 'VN'");
  const html = row[0].html;
  
  const idx = html.indexOf('thisApproved-btn');
  console.log('Around thisApproved-btn:\n', html.slice(Math.max(0, idx - 300), idx + 800));
} catch(e) { console.error('err:', e.message); }
