const fs = require('fs');
const path = require('path');

const folders = fs.readdirSync('fix-bug').filter(f => f.startsWith('screenshot-')).sort((a,b) => {
  return parseInt(a.replace('screenshot-', '')) - parseInt(b.replace('screenshot-', ''));
});

folders.forEach(f => {
  const p = path.join('fix-bug', f, 'fix-report.md');
  if (!fs.existsSync(p)) return;
  const content = fs.readFileSync(p, 'utf8');
  console.log(`\n================== ${f} ==================`);
  console.log('First 15 lines:');
  console.log(content.split('\n').slice(0, 15).join('\n'));
});
