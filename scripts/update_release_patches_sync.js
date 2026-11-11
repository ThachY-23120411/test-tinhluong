const fs = require('fs');

const releaseFile = fs.readFileSync('fix-bug/release_patches.sql', 'utf8');
const standalone = fs.readFileSync('fix-bug/screenshot-2/patch_responsive.sql', 'utf8');

// Find where PATCH 08 begins
const patch08Start = releaseFile.indexOf('/*==================================================================================================\n  PATCH 08:');
const footerMarker = '/*==================================================================================================\n  KẾT THÚC MASTER RELEASE PATCH SCRIPT';

if (patch08Start !== -1) {
  const footerStart = releaseFile.indexOf(footerMarker, patch08Start);
  if (footerStart !== -1) {
    const beforePatch08 = releaseFile.slice(0, patch08Start);
    const afterFooter = releaseFile.slice(footerStart);

    // Extract the sql body from standalone
    const bodyStart = standalone.indexOf('/*==================================================================================================\n  PARADISE HRM - PATCH: MENU THANH TOÁN CÔNG NỢ');
    const newRelease = beforePatch08 + standalone + '\n' + afterFooter;
    fs.writeFileSync('fix-bug/release_patches.sql', newRelease, 'utf8');
    console.log('Successfully updated release_patches.sql with synchronized PATCH 08!');
  }
}
