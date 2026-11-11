const fs = require('fs');
const path = require('path');

const baseDir = path.resolve(__dirname, '../test-evidence/cham_cong_tinh_luong_crud_lien_hoan');

// Run-This-Page.bat
const pageBat = `@echo off
chcp 65001 > nul
echo ===============================================================================
echo [PARADISE HRM] THUC THI TOAN BO 15 TEST CASES - PHAN HE CHAM CONG & TINH LUONG
echo ===============================================================================
cd /d "%~dp0\\..\\.."
npx playwright test tests/cham_cong_tinh_luong_crud_lien_hoan.spec.js --project="Google Chrome" --headed
pause
`;
fs.writeFileSync(path.join(baseDir, 'Run-This-Page.bat'), pageBat, 'utf8');

for (let i = 1; i <= 15; i++) {
  const tcId = `TC-${String(i).padStart(2, '0')}`;
  const tcDir = path.join(baseDir, tcId);
  fs.mkdirSync(path.join(tcDir, 'screenshots'), { recursive: true });
  fs.mkdirSync(path.join(tcDir, 'videos'), { recursive: true });

  const tcBat = `@echo off
chcp 65001 > nul
echo ===============================================================================
echo [PARADISE HRM] THUC THI DON LE ${tcId} - PHAN HE CHAM CONG & TINH LUONG
echo ===============================================================================
cd /d "%~dp0\\..\\..\\.."
npx playwright test tests/cham_cong_tinh_luong_crud_lien_hoan.spec.js -g "${tcId}:" --project="Google Chrome" --headed
pause
`;
  fs.writeFileSync(path.join(tcDir, 'Run-This-TC.bat'), tcBat, 'utf8');
}

console.log('Setup 15 TC folders and .bat scripts completed!');
