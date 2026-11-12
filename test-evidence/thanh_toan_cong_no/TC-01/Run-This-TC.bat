@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: thanh_toan_cong_no - TC-01
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TEST CASE: TC-01 (thanh_toan_cong_no.spec.js)
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 100ms)...
echo.
cd /d "%~dp0..\..\.."
if not exist "node_modules" (
    cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
)
call npx playwright test tests/thanh_toan_cong_no.spec.js -g "TC-01" --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU!
echo ====================================================================
echo.
pause
