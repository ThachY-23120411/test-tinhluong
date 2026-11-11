const { query } = require('../helpers/db');

try {
  const row = query("SELECT html FROM tblHtmlScriptCache WHERE TableName = 'sp_ResignationLeave' AND LanguageID = 'VN'");
  const html = row[0].html;
  
  const idx = html.indexOf('.btnApprove").removeClass("d-none")') !== -1 ? html.indexOf('.btnApprove").removeClass("d-none")') : html.indexOf('.btnApprove') ;
  console.log('Approve binding in sp_ResignationLeave:\n', html.slice(Math.max(0, idx - 50), idx + 800));
} catch(e) { console.error('err:', e.message); }
