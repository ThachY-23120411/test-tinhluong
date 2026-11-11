const { query } = require('../helpers/db');
// Find what SP gets the list of pending requests in MnuWPT037
const fs = require('fs');
const html = fs.readFileSync('scripts/sp_List_To_Review.html', 'utf8');
const spMatches = html.match(/name:\s*['"][^'"]+['"]/g);
console.log('SP calls in sp_List_To_Review:', spMatches);
