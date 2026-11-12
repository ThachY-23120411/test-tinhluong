const fs = require('fs');
const content = fs.readFileSync('scripts/sp_MakeupHours_html.sql', 'utf-8');
const lines = content.split('\n');

for (let i = 779; i < 820; i++) {
  console.log((i + 1) + ': ' + lines[i]);
}
