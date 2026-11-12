@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: cham_cong_tinh_luong_crud_lien_hoan - TC-01
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TEST CASE: TC-01 (cham_cong_tinh_luong_crud_lien_hoan.spec.js)
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon Sieu Nhanh, Zero Lag)...
echo.
cd /d "%~dp0"
call npx playwright test tests/cham_cong_tinh_luong_crud_lien_hoan.spec.js -g "TC-01" --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU!
echo ====================================================================
echo.
pause
