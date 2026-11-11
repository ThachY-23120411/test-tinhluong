@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: Luong nhan vien va HDLD (MnuHRS145)
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TRANG: Luong nhan vien va HDLD (MnuHRS145)
echo   Test Case lien quan: TC-03 (tests/quy_trinh_tinh_luong_nv_moi.spec.js)
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, Human-like params)...
echo.
cd /d "%~dp0..\..\..\.."
if not exist "node_modules" (
    cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
)
call npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "TC-03" --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU TRANG MnuHRS145!
echo ====================================================================
echo.
pause
