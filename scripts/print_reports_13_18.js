const fs = require('fs');

const reports = ['13', '15', '16', '17', '18'];
reports.forEach(r => {
  const p = `fix-bug/screenshot-${r}/fix-report.md`;
  if (fs.existsSync(p)) {
    const txt = fs.readFileSync(p, 'utf8');
    console.log(`\n================== SCREENSHOT-${r} ==================`);
    console.log(txt.substring(0, 1000));
  }
});
