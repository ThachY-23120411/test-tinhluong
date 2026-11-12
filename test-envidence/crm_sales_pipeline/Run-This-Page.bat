@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: Trang crm_sales_pipeline
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TOAN BO TRANG: crm_sales_pipeline.spec.js
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 100ms)...
echo.
cd /d "%~dp0..\.."
if not exist "node_modules" (
    cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
)
call npx playwright test tests/crm_sales_pipeline.spec.js --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU TRANG!
echo ====================================================================
echo.
pause
