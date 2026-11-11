const { query } = require('../helpers/db');
const fs = require('fs');

const rows = query("SELECT html FROM tblHtmlScriptCache WHERE TableName = 'sp_List_To_Review'");
if (rows && rows.length > 0) {
  fs.writeFileSync('scripts/sp_List_To_Review.html', rows[0].html);
  console.log('Saved sp_List_To_Review.html, length:', rows[0].html.length);
} else {
  console.log('Not found in cache');
}
