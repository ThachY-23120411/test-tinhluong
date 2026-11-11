const fs = require('fs');
const path = require('path');

const copies = [
  { src: 'scripts/shot_sc1_sc23_fixed.png', dest: 'fix-bug/screenshot-1/screenshots/1_fixed.png' },
  { src: 'scripts/shot_sc2_fixed.png', dest: 'fix-bug/screenshot-2/screenshots/2_fixed.png' },
  { src: 'scripts/shot_sc3_sc4_fixed.png', dest: 'fix-bug/screenshot-3/screenshots/3_fixed.png' },
  { src: 'scripts/shot_sc3_sc4_fixed.png', dest: 'fix-bug/screenshot-4/screenshots/4_fixed.png' },
  { src: 'scripts/shot_sc6_fixed.png', dest: 'fix-bug/screenshot-6/screenshots/6_fixed.png' },
  { src: 'scripts/after_open_contract_grid.png', dest: 'fix-bug/screenshot-8/screenshots/8_fixed.png' },
  { src: 'scripts/after_click_prl408.png', dest: 'fix-bug/screenshot-11/screenshots/11_fixed.png' },
  { src: 'scripts/shot_sc13_fixed.png', dest: 'fix-bug/screenshot-13/screenshots/13_fixed.png' },
  { src: 'scripts/shot_sc14_fixed.png', dest: 'fix-bug/screenshot-14/screenshots/14_fixed.png' },
  { src: 'scripts/shot_sc15_fixed.png', dest: 'fix-bug/screenshot-15/screenshots/15_fixed.png' },
  { src: 'scripts/shot_sc16_fixed.png', dest: 'fix-bug/screenshot-16/screenshots/16_fixed.png' },
  { src: 'scripts/shot_sc17_fixed.png', dest: 'fix-bug/screenshot-17/screenshots/17_fixed.png' },
  { src: 'scripts/shot_sc18_fixed.png', dest: 'fix-bug/screenshot-18/screenshots/18_fixed.png' },
  { src: 'scripts/live_logged_in.png', dest: 'fix-bug/screenshot-20/screenshots/20_fixed.png' },
  { src: 'scripts/shot_sc21_fixed.png', dest: 'fix-bug/screenshot-20/screenshots/21_fixed.png' },
  { src: 'scripts/shot_sc22_fixed.png', dest: 'fix-bug/screenshot-20/screenshots/22_fixed.png' },
  { src: 'scripts/shot_sc1_sc23_fixed.png', dest: 'fix-bug/screenshot-20/screenshots/23_fixed.png' }
];

for (const { src, dest } of copies) {
  const destDir = path.dirname(dest);
  if (!fs.existsSync(destDir)) fs.mkdirSync(destDir, { recursive: true });
  fs.copyFileSync(src, dest);
  console.log(`Copied ${src} -> ${dest}`);
}

console.log('All after-fix screenshot copies completed!');
