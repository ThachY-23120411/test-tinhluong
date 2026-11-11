const fs = require('fs');
const orig = fs.readFileSync('scripts/orig_tai_sp_def.sql', 'utf8');
const lines = orig.split('\n');
lines.forEach((l, i) => {
  if (l.includes('dx-list') || l.includes('dropdown') || l.includes('dx-popup')) {
    console.log(`Line ${i + 1}: ${l.trim()}`);
  }
});
