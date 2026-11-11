const fs = require('fs');

const html = fs.readFileSync('scripts/tai3_index.html', 'utf8');
const scriptSrcRegex = /<script\b[^>]*\bsrc=["']([^"']+)["'][^>]*>/gi;
let match;
console.log('Script sources in index.html:');
while ((match = scriptSrcRegex.exec(html)) !== null) {
  console.log(match[1]);
}
