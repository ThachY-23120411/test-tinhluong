const fs = require('fs');
const path = require('path');

const folders = fs.readdirSync('fix-bug').filter(f => f.startsWith('screenshot-')).sort((a,b) => {
  const numA = parseInt(a.replace('screenshot-', ''));
  const numB = parseInt(b.replace('screenshot-', ''));
  return numA - numB;
});

console.log('Total screenshot folders:', folders.length);

folders.forEach(f => {
  const fPath = path.join('fix-bug', f);
  const repPath = path.join(fPath, 'fix-report.md');
  const ssDir = path.join(fPath, 'screenshots');
  
  const hasReport = fs.existsSync(repPath);
  const hasSsDir = fs.existsSync(ssDir);
  const images = hasSsDir ? fs.readdirSync(ssDir) : [];
  
  console.log(`${f.padEnd(15)}: Report=${hasReport ? 'YES' : 'NO '}, ssDir=${hasSsDir ? 'YES' : 'NO '}, Images=[${images.join(', ')}]`);
});
