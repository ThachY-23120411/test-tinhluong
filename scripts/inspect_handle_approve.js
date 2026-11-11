const { query } = require('../helpers/db');

try {
  const row = query("SELECT html FROM tblHtmlScriptCache WHERE TableName = 'sp_ResignationLeave' AND LanguageID = 'VN'");
  const html = row[0].html;
  
  const idx = html.indexOf('HandleApproveLeaveRequest');
  console.log('HandleApproveLeaveRequest:\n', html.slice(idx, idx + 800));
} catch(e) { console.error('err:', e.message); }
