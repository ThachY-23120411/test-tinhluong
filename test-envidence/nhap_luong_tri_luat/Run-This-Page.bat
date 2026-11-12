@echo off
chcp 65001 >nul
title [1-CLICK TEST ALL] nhap_luong_tri_luat
cd /d "%~dp0..\.."
echo ===============================================================================
echo   DANG CHAY TOAN BO KICH BAN TRANG: Nhập lương Trí Luật (MnuPRL408)
echo ===============================================================================
npx playwright test tests/nhap_luong_tri_luat.spec.js
echo.
echo ===============================================================================
echo   DA CAP NHAT BAO CAO TAI: test-evidence\nhap_luong_tri_luat\test-report.md
echo ===============================================================================
pause
