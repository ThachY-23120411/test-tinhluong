const { query } = require('../helpers/db');

try {
  const row = query("SELECT html FROM tblHtmlScriptCache WHERE TableName = 'sp_ResignationLeave' AND LanguageID = 'VN'");
  const html = row[0].html;
  
  const idx = html.indexOf('.btnApprove').valueOf();
  const idx2 = html.indexOf('click', idx);
  console.log('Around btnApprove click in sp_ResignationLeave:\n', html.slice(idx2 - 100, idx2 + 800));
} catch(e) { console.error('err:', e.message); }
