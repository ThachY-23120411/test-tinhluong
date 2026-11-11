const fs = require('fs');
const path = require('path');

const releasePath = path.resolve(__dirname, '../fix-bug/release_patches.sql');
const fixBugPath = path.resolve(__dirname, '../fix-bug/noi_dung_dang_tai/fix-bug.sql');

const releaseContent = fs.readFileSync(releasePath, 'utf8');
const fixBugContent = fs.readFileSync(fixBugPath, 'utf8');

const p10Match = releaseContent.match(/-- PATCH 10: \[sp_KPIContentPost_html\]/);
const p11Match = releaseContent.match(/-- PATCH 11: \[sp_WH_InventoryImport_html\]/);

if (!p10Match || !p11Match) {
  console.error('Could not find PATCH 10 or PATCH 11');
  process.exit(1);
}

const beforeP10 = releaseContent.substring(0, p10Match.index);
const afterP10 = releaseContent.substring(p11Match.index);

const updatedRelease = beforeP10 + fixBugContent.trim() + '\r\n\r\n\r\n' + afterP10;
fs.writeFileSync(releasePath, updatedRelease, 'utf8');
console.log('Successfully updated PATCH 10 in release_patches.sql!');
