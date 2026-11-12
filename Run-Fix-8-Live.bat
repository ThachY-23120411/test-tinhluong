@echo off
chcp 65001 >nul
title Paradise HRM - Live Visual Test: FIX-8 (Quy trinh Tinh luong NV moi)
cls
echo ====================================================================
echo   CHAY TRUC QUAN FIX-8: QUY TRINH TINH LUONG NV MOI (TC-18 den TC-19)
echo   Vai tro: chien.nguyen (Ke toan truong), test.nv (Nhan vien moi 099)
echo   Pham vi kiem thu (Priority P5 - Chang cuoi ve dich):
echo     [TC-18]: Ke toan doi soat Bang luong tong hop toan cong ty & Phieu luong (MnuPRL092)
echo     [TC-19]: Nhan vien moi dang nhap, doi soat Phieu luong, Tab Lich su & 3 Modal chi tiet (MnuPRL445)
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo, Headed)...
echo.
cd /d "%~dp0"
call npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "fix-8" --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT PHIEN KIEM THU TRUC QUAN FIX-8!
echo   Bao cao va hinh anh luu tai: test-evidence\quy_trinh_tinh_luong_nv_moi\
echo ====================================================================
echo.
pause
