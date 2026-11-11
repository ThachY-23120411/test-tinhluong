const fs = require('fs');

const html = fs.readFileSync('scripts/returned_html.html', 'utf8');
const scriptRegex = /<script\b[^>]*>([\s\S]*?)<\/script>/i;
const match = scriptRegex.exec(html);

if (match) {
  const js = match[1];
  
  // Dùng eval trong vm context với filename để node in ra dòng và cột chính xác!
  const vm = require('vm');
  try {
    new vm.Script(js, { filename: 'returned_script.js' });
    console.log('Script parsed successfully!');
  } catch (err) {
    console.error('VM Syntax Error:', err.message);
    console.error(err.stack);
  }
}
