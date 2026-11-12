@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: fix-7 (quy_trinh_tinh_luong_nv_moi)
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TAT CA TEST CASE CUA FIX-7: quy_trinh_tinh_luong_nv_moi
echo   Pham vi: TC-14, TC-15, TC-16, TC-17 (Thuong KPI, Tam ung, Tinh luong & Khoa so)
echo   Vai tro: chien.nguyen (Ke toan truong)
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 100ms)...
echo.
cd /d "%~dp0..\..\.."
if not exist "node_modules" (
    cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
)
call npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "fix-7" --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU CAC TEST CASE CUA FIX-7!
echo ====================================================================
echo.
pause
