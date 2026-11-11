const fs = require('fs');
const content = fs.readFileSync('scripts/sp_CRM_EmailKPIFollow_html.sql', 'utf8');
let pos = 0;
while (true) {
  const idx = content.indexOf('InstanceEmployeeID', pos);
  if (idx === -1) break;
  console.log('--- At index:', idx);
  console.log(content.substring(idx - 40, idx + 120));
  pos = idx + 18;
}
