const fs = require('fs');
const path = require('path');

const src = fs.readFileSync(path.join(__dirname, 'SetInitialPasswordForm_def.sql'), 'utf8');
const lines = src.split('\n');

for (let i = 0; i < lines.length; i++) {
  if (lines[i].includes('SET @ColHtml +=')) {
    console.log(`Original Line ${i + 1}: ${lines[i]}`);
  }
}
