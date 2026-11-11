@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: fix-4 (quy_trinh_tinh_luong_nv_moi)
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TAT CA TEST CASE CUA FIX-4: quy_trinh_tinh_luong_nv_moi
echo   Pham vi: TC-03, TC-04, TC-05 (Luong 10tr, 1 NPT, Phan ca HC)
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, Human-like params)...
echo.
cd /d "%~dp0..\..\..\.."
if not exist "node_modules" (
    cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
)
call npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "fix-4" --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU CAC TEST CASE CUA FIX-4!
echo ====================================================================
echo.
pause
