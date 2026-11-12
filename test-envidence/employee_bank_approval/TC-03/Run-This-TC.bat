@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: employee_bank_approval - TC-03
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TEST CASE: TC-03 (employee_bank_approval.spec.js)
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 100ms)...
echo.
cd /d "%~dp0..\..\.."
if not exist "node_modules" (
    cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
)
call npx playwright test tests/employee_bank_approval.spec.js -g "TC-03" --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU!
echo ====================================================================
echo.
pause
