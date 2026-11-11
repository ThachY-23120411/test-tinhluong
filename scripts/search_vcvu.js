const fs = require('fs');
const html = fs.readFileSync('scripts/sp_ResignationLeave.html', 'utf8');
let pos = 0;
while (true) {
  const idx = html.indexOf('VC-Vu-btn', pos);
  if (idx === -1) break;
  console.log('--- FOUND AT', idx, '---');
  console.log(html.slice(Math.max(0, idx - 100), idx + 300));
  pos = idx + 1;
}
