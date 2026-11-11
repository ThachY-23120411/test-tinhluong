const { query } = require('../helpers/db');

try {
  const row = query("SELECT html FROM tblHtmlScriptCache WHERE TableName = 'sp_List_To_Review' AND LanguageID = 'VN'");
  const html = row[0].html;
  
  const idx = html.indexOf('$(".getcardregisteredOA")') !== -1 ? html.indexOf('$(".getcardregisteredOA")') : html.indexOf('.getcardregisteredOA');
  const idx2 = html.indexOf('click', idx);
  console.log('Click on card:\n', html.slice(idx2 - 100, idx2 + 600));
} catch(e) { console.error('err:', e.message); }
