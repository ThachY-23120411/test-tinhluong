@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: fix-4 - TC-02
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TEST CASE: TC-02 - Thiet lap HDLD va Muc luong 10,000,000 VND
echo   Spec: tests/quy_trinh_tinh_luong_nv_moi.spec.js
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 100ms)...
echo.
cd /d "%~dp0..\..\..\..\.."
if not exist "node_modules" (
    cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
)
call npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "TC-02" --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU TC-02!
echo ====================================================================
echo.
pause