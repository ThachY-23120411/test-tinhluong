const fs = require('fs');

const content = fs.readFileSync('scripts/HtmlMacOSLayOut_html.sql', 'utf8');
const lines = content.split('\n');

console.log('Lines 6841 to 6890:');
console.log(lines.slice(6840, 6890).join('\n'));
