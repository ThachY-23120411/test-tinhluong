@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: crm_sales_pipeline - TC-08
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TEST CASE: TC-08 (crm_sales_pipeline.spec.js)
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 100ms)...
echo.
cd /d "%~dp0..\..\.."
if not exist "node_modules" (
    cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
)
call npx playwright test tests/crm_sales_pipeline.spec.js -g "TC-08" --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU!
echo ====================================================================
echo.
pause
