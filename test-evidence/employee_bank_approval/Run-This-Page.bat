@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: Trang employee_bank_approval
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TOAN BO TRANG: employee_bank_approval.spec.js
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 100ms)...
echo.
cd /d "%~dp0..\.."
if not exist "node_modules" (
    cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
)
call npx playwright test tests/employee_bank_approval.spec.js --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU TRANG!
echo ====================================================================
echo.
pause
