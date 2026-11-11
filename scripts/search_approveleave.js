const fs = require('fs');
const html = fs.readFileSync('scripts/sp_ResignationLeave.html', 'utf8');
const idx = html.indexOf('function approveLeave');
console.log('approveLeave found at:', idx);
if (idx !== -1) {
  console.log(html.slice(idx, idx + 1000));
}
