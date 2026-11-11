const fs = require('fs');
const html = fs.readFileSync('scripts/sp_ResignationLeave.html', 'utf8');
const idx = html.indexOf('async function ApproveLeaveRequest');
console.log('ApproveLeaveRequest at:', idx);
if (idx !== -1) {
  console.log(html.slice(idx, idx + 1200));
}
