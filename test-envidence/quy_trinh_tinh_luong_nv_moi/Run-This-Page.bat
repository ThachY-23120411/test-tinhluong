@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: Trang quy_trinh_tinh_luong_nv_moi
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TOAN BO TRANG: quy_trinh_tinh_luong_nv_moi.spec.js
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 100ms)...
echo.
cd /d "%~dp0..\.."
if not exist "node_modules" (
    cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
)
call npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU TRANG!
echo ====================================================================
echo.
pause
