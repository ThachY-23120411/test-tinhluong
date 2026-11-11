const { query } = require('../helpers/db');

try {
  const row = query("SELECT html FROM tblHtmlScriptCache WHERE TableName = 'sp_ResignationLeave' AND LanguageID = 'VN'");
  const html = row[0].html;
  
  const matches = [];
  const regex = /btnApprove|btnReject|btnDuyet|btnTuChoi|btn-approve|btn-success|duyệt/gi;
  let m;
  while ((m = regex.exec(html)) !== null) {
    matches.push(html.slice(Math.max(0, m.index - 50), Math.min(html.length, m.index + 80)));
  }
  console.log('Matches for approve/duyet in sp_ResignationLeave (first 10):', matches.slice(0, 10));
} catch(e) { console.error('err:', e.message); }
