const fs = require('fs');

const releasePath = 'c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/release_patches.sql';
const fixBugPath = 'c:/Users/Y.Thach/Desktop/paradiseHR/fix-bug/crm_email_manual/fix-bug.sql';

const releaseContent = fs.readFileSync(releasePath, 'utf8');
const fixBugContent = fs.readFileSync(fixBugPath, 'utf8');

const p15Match = releaseContent.match(/-- =+[\r\n]+-- PATCH 15: \[sp_KPIListEmailManual_html\]/);
const p14Match = releaseContent.match(/-- =+[\r\n]+-- PATCH: \[sp_zalo_AIgenerated_history_html\]/);

if (!p15Match || !p14Match) {
  console.error('Could not find PATCH 15 or PATCH 14 in release_patches.sql');
  process.exit(1);
}

const p15Index = p15Match.index;
const p14Index = p14Match.index;

const beforeP15 = releaseContent.substring(0, p15Index);
const afterP15 = releaseContent.substring(p14Index);

const updatedRelease = beforeP15 + fixBugContent.trim() + '\r\n\r\n\r\n' + afterP15;
fs.writeFileSync(releasePath, updatedRelease, 'utf8');
console.log('Successfully updated PATCH 15 in release_patches.sql!');
