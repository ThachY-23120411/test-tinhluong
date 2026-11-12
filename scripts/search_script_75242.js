const fs = require('fs');
const content = fs.readFileSync('scripts/script_75242.js', 'utf-8');
const lines = content.split('\n');
lines.forEach((l, idx) => {
  if (l.includes('click') || l.includes('Duyệt') || l.includes('sp_MakeupHours') || l.includes('open') || l.includes('show') || l.includes('modal') || l.includes('Approve') || l.includes('Card') || l.includes('renderCard')) {
    console.log((idx + 1) + ': ' + l.trim().substring(0, 150));
  }
});
