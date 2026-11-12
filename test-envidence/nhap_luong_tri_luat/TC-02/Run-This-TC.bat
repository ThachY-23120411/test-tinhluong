@echo off
chcp 65001 >nul
title [1-CLICK TEST] nhap_luong_tri_luat - TC-02
cd /d "%~dp0..\..\.."
echo ===============================================================================
echo   DANG CHAY KIEM THU TRUC QUAN CHROME: nhap_luong_tri_luat - TC-02
echo ===============================================================================
npx playwright test tests/nhap_luong_tri_luat.spec.js -g "TC-02"
echo.
echo ===============================================================================
echo   KIEM THU HOAN TAT! BAO CAO DA DUOC CAP NHAT TAI:
echo   test-evidence\nhap_luong_tri_luat\test-report.md
echo ===============================================================================
pause
