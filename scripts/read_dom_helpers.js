const fs = require('fs');

['scratch/test_stage3_menus.js', 'scripts/inspect_exact_screen_dom.js'].forEach(file => {
  if (fs.existsSync(file)) {
    console.log('=== FILE:', file);
    const c = fs.readFileSync(file, 'utf8');
    console.log(c.substring(0, 1500));
  }
});
