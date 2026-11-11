const { query } = require('../helpers/db');

try {
  const row = query("SELECT html FROM tblHtmlScriptCache WHERE TableName = 'sp_ResignationLeave' AND LanguageID = 'VN'");
  const html = row[0].html;
  
  const matches = [];
  const regex = /["']\.btnApprove["']|#btnApprove|\.btnApprove/gi;
  let m;
  while ((m = regex.exec(html)) !== null) {
    matches.push(html.slice(Math.max(0, m.index - 50), Math.min(html.length, m.index + 200)));
  }
  console.log('All .btnApprove occurrences:', matches);
} catch(e) { console.error('err:', e.message); }
