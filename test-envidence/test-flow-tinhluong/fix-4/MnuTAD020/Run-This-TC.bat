@echo off
chcp 65001 >nul
title Paradise HRM - Live Test: Phan ca lam viec hanh chinh (MnuTAD020)
cls
echo ====================================================================
echo   CHAY LAI TRUC QUAN TRANG: Phan ca lam viec hanh chinh (MnuTAD020)
echo   Test Case lien quan: TC-04 (tests/quy_trinh_tinh_luong_nv_moi.spec.js)
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo 100ms)...
echo.
cd /d "%~dp0..\..\..\.."
if not exist "node_modules" (
    cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
)
call npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "TC-04" --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU TRANG MnuTAD020!
echo ====================================================================
echo.
pause