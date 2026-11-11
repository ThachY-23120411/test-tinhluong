const fs = require('fs');
const path = require('path');

const dirs = fs.readdirSync('fix-bug').filter(d => d.startsWith('screenshot-')).sort((a,b) => {
  const na = parseInt(a.replace('screenshot-', ''));
  const nb = parseInt(b.replace('screenshot-', ''));
  return na - nb;
});

let errorCount = 0;

for (const dir of dirs) {
  const reportPath = path.join('fix-bug', dir, 'fix-report.md');
  const content = fs.readFileSync(reportPath, 'utf8');

  // Check 1: Verification guide removed?
  const hasVGuide = /QUY TRÌNH THỰC THI|HƯỚNG DẪN NGHIỆM THU|HƯỚNG DẪN KIỂM TRA/i.test(content);
  if (hasVGuide) {
    console.error('[FAIL V-GUIDE] ' + dir + ' still contains verification guide!');
    errorCount++;
  }

  // Check 2: Absolute or base64 paths?
  const hasAbs = /(file:\/\/\/|[a-zA-Z]:\\|data:image\/png;base64)/i.test(content);
  if (hasAbs) {
    console.error('[FAIL ABS] ' + dir + ' contains absolute or base64 path!');
    errorCount++;
  }

  // Check 3: Images present and exist on disk
  const regex = /!\[(.*?)\]\((.*?)\)/g;
  let match;
  let imgCount = 0;
  let hasFixed = false;
  const imgs = [];

  while ((match = regex.exec(content)) !== null) {
    imgCount++;
    const url = match[2];
    imgs.push(url);
    if (url.includes('fixed') || url.includes('actual_live_grid')) hasFixed = true;

    if (!url.startsWith('./screenshots/')) {
      console.error('[FAIL NON-REL] ' + dir + ' has non-relative img: ' + url);
      errorCount++;
    }
    const fullPath = path.resolve('fix-bug', dir, url);
    if (!fs.existsSync(fullPath)) {
      console.error('[FAIL MISSING IMG FILE] ' + dir + ': ' + url + ' -> ' + fullPath);
      errorCount++;
    }
  }

  if (!hasFixed) {
    console.error('[FAIL NO FIXED IMG] ' + dir + ' has no after-fix image!');
    errorCount++;
  }

  console.log(dir + ': total images = ' + imgCount + ', hasAfterFix = ' + hasFixed);
  console.log('  Images: ' + imgs.join(', '));
}

if (errorCount === 0) {
  console.log('\n🎉 ALL 15 REPORTS STRICTLY PASS ALL AUDIT REQUIREMENTS!');
} else {
  console.log('\n❌ Found ' + errorCount + ' errors!');
}
