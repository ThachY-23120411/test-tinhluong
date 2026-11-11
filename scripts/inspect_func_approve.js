const { query } = require('../helpers/db');

try {
  const row = query("SELECT html FROM tblHtmlScriptCache WHERE TableName = 'sp_ResignationLeave' AND LanguageID = 'VN'");
  const html = row[0].html;
  
  const idx = html.indexOf('function HandleApproveLeaveRequest');
  console.log('Definition of HandleApproveLeaveRequest:\n', html.slice(idx, idx + 1000));
} catch(e) { console.error('err:', e.message); }
