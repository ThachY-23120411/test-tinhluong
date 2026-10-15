@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: crm_dashboard - TC-02
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TEST CASE: TC-02 (crm_dashboard.spec.js)
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 400ms)...
echo.
cd /d "%~dp0..\..\.."
if not exist "node_modules" (
    cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
)
call npx playwright test tests/crm_dashboard.spec.js -g "TC-02" --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU!
echo ====================================================================
echo.
pause
