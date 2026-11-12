const fs = require('fs');
const content = fs.readFileSync('scripts/script_75264.js', 'utf-8');
const lines = content.split('\n');

for (let i = 900; i < lines.length; i++) {
  console.log((i + 1) + ': ' + lines[i]);
}
