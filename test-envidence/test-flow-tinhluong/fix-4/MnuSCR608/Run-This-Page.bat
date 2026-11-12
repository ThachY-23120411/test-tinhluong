@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: Quan ly tai khoan nguoi dung (MnuSCR608)
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TRANG: Quan ly tai khoan nguoi dung (MnuSCR608)
echo   Test Case lien quan: TC-05 (tests/quy_trinh_tinh_luong_nv_moi.spec.js)
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 100ms)...
echo.
cd /d "%~dp0..\..\..\.."
if not exist "node_modules" (
    cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
)
call npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "TC-05" --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU TRANG MnuSCR608!
echo ====================================================================
echo.
pause