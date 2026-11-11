const fs = require('fs');

const content = fs.readFileSync('scripts/HtmlMacOSLayOut_html.sql', 'utf8');
const lines = content.split('\n');

console.log('Lines 6744 to 6840:');
console.log(lines.slice(6743, 6840).join('\n'));
