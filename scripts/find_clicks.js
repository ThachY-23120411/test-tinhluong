const { query } = require('../helpers/db');
const r = query("SELECT TOP 1 html FROM tblHtmlScriptCache WHERE TableName = 'sp_ResignationLeave'");
if (r.length > 0) {
  const matches = [...r[0].html.matchAll(/btnActionModalRemake/g)];
  console.log('Occurrences:', matches.length);
  matches.forEach(m => {
    console.log(r[0].html.slice(m.index - 50, m.index + 100));
  });
}
