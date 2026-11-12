@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: fix-6 (quy_trinh_tinh_luong_nv_moi)
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TAT CA TEST CASE CUA FIX-6: quy_trinh_tinh_luong_nv_moi
echo   Pham vi: TC-10, TC-11, TC-12, TC-13 (Khop 100%% Recording 11/12/2026)
echo   Vai tro: tri.nguyen (004), LongKa (012), test.nv (099)
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, Human-like params)...
echo.
cd /d "%~dp0..\..\..\.."
if not exist "node_modules" (
    cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
)
call npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "fix-6" --headed --workers=1 --project="Google Chrome"
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU CAC TEST CASE CUA FIX-6!
echo ====================================================================
echo.
pause
