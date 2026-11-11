const fs = require('fs');
const html = fs.readFileSync('scripts/sp_List_To_Review.html', 'utf8');
const idx = html.indexOf('function openFormParam');
console.log('openFormParam in review html?', idx);
if (idx !== -1) {
  console.log(html.slice(idx, idx + 500));
}
