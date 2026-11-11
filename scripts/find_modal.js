const { query } = require('../helpers/db');
const fs = require('fs');
const r = query("SELECT TOP 1 html FROM tblHtmlScriptCache WHERE TableName = 'sp_overtime_assignment'");
if (r.length > 0) {
  fs.writeFileSync('ot_assignment.html', r[0].html, 'utf8');
  console.log('Saved ot_assignment.html, len:', r[0].html.length);
}
