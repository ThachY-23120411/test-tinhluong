const fs = require('fs');
const path = require('path');

const folders = fs.readdirSync('fix-bug').filter(f => f.startsWith('screenshot-')).sort((a,b) => {
  return parseInt(a.replace('screenshot-', '')) - parseInt(b.replace('screenshot-', ''));
});

folders.forEach(f => {
  const p = path.join('fix-bug', f, 'fix-report.md');
  if (!fs.existsSync(p)) return;
  const content = fs.readFileSync(p, 'utf8');
  
  // Find where image is referenced in Section 1
  const sec1Match = content.match(/(### 1\. HIỆN TRẠNG[\s\S]*?)(?=### 2\.|\n## 2\.|$)/i);
  console.log(`\n================== ${f} ==================`);
  if (sec1Match) {
    const lines = sec1Match[1].split('\n').filter(l => l.includes('.png') || l.includes('Ảnh') || l.includes('Hình'));
    console.log('Image lines in Sec 1:', lines);
  } else {
    console.log('NO Section 1 match found!');
  }
});
