@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: cham_cong_tinh_luong_crud_lien_hoan - TC-06
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TEST CASE: TC-06 (cham_cong_tinh_luong_crud_lien_hoan.spec.js)
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 100ms)...
echo.
cd /d "%~dp0..\..\.."
if not exist "node_modules" (
    cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
)
call npx playwright test tests/cham_cong_tinh_luong_crud_lien_hoan.spec.js -g "TC-06" --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU!
echo ====================================================================
echo.
pause
