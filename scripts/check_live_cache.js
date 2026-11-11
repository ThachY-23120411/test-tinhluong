const { query } = require('../helpers/db');
const fs = require('fs');

const r = query("SELECT html, VersionData FROM tblHtmlScriptCache WHERE TableName = 'Template_SalaryImport_TriLuat' AND LanguageID = 'VN'");
if (r.length > 0) {
  const vData = r[0].VersionData || r[0].html || '';
  fs.writeFileSync('scripts/live_cache_dump.html', vData, 'utf8');
  console.log('Cache dump length:', vData.length);
  console.log('Has tsitlTopFilterBar:', vData.includes('tsitlTopFilterBar'));
  console.log('Top 500 chars of HTML:');
  console.log(vData.substring(0, 500));
} else {
  console.log('No cache found!');
}
