const { query } = require('../helpers/db');
const fs = require('fs');

const rows = query("SELECT html FROM tblHtmlScriptCache WHERE TableName = 'sp_ResignationLeave'");
if (rows && rows.length > 0) {
  fs.writeFileSync('scripts/sp_ResignationLeave.html', rows[0].html);
  console.log('Saved sp_ResignationLeave.html, length:', rows[0].html.length);
}
