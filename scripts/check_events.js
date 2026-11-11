const fs = require('fs');
const content = fs.readFileSync('scripts/sp_CRM_EmailKPIFollow_html.sql', 'utf8');
const hasChange = content.includes('onValueChanged') || content.includes('selectionChanged');
console.log('Has onValueChanged / selectionChanged in HTML SP:', hasChange);
if (hasChange) {
  const matches = content.match(/[^\n]*(onValueChanged|selectionChanged)[^\n]*/g);
  console.log('Matches:', matches);
}
