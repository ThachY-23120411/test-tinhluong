const fs = require('fs');
const path = require('path');

const folders = [
  'screenshot-1', 'screenshot-2', 'screenshot-3', 'screenshot-4',
  'screenshot-5', 'screenshot-6', 'screenshot-8', 'screenshot-11',
  'screenshot-13', 'screenshot-14', 'screenshot-15', 'screenshot-16',
  'screenshot-17', 'screenshot-18'
];

folders.forEach(f => {
  const p = path.join('fix-bug', f, 'fix-report.md');
  if (fs.existsSync(p)) {
    const txt = fs.readFileSync(p, 'utf8');
    const titleMatch = txt.match(/^#\s+(.+)$/m);
    const subMatch = txt.match(/^##\s+(.+)$/m);
    console.log(`[${f}] ${titleMatch ? titleMatch[1] : ''} | ${subMatch ? subMatch[1] : ''} (Size: ${txt.length} bytes)`);
  } else {
    console.log(`[${f}] MISSING FILE`);
  }
});
