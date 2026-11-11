const db = require('../helpers/db');

const rows = db.query(`
  SELECT TOP 1 html 
  FROM tblHtmlScriptCache 
  WHERE TableName = 'sp_KPIContentPost' AND ScreenType = -1 AND LanguageID = 'VN'
`);

if (rows && rows.length > 0) {
  const html = rows[0].html;
  const spIdx = html.indexOf('#GridContentPost .dx-datagrid-search-panel');
  if (spIdx !== -1) {
    console.log(html.substring(spIdx, spIdx + 600));
  }
}
