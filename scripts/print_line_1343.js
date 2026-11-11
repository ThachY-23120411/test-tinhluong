const fs = require('fs');

const html = fs.readFileSync('scripts/returned_html.html', 'utf8');
const scriptRegex = /<script\b[^>]*>([\s\S]*?)<\/script>/i;
const match = scriptRegex.exec(html);

if (match) {
  const js = match[1];
  const lines = js.split('\n');
  console.log('Lines around 1343:');
  for (let i = 1330; i <= 1360; i++) {
    console.log(`${i}: ${lines[i - 1]}`);
  }
}
