@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: FIX-7 (TC-14 -> TC-17)
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN PHAN CONG FIX-7: TC-14 -> TC-17
echo   Kich ban: quy_trinh_tinh_luong_nv_moi.spec.js
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 100ms)...
echo.
cd /d "%~dp0..\.."
if not exist "node_modules" (
    cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
)
call npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "fix-7" --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU FIX-7!
echo ====================================================================
echo.
pause
