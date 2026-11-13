@echo off
chcp 65001 >nul
title Paradise HRM - Live Visual Test: FIX-5 (Quy trinh Tinh luong NV moi)
cls
echo ====================================================================
echo   CHAY TRUC QUAN FIX-5: QUY TRINH TINH LUONG NV MOI (TC-06 den TC-08)
echo   Vai tro: test.nv / 123 (Nhan vien moi 099 - Nguyen Van Test)
echo   Pham vi kiem thu theo dung Chrome Recorder JSON:
echo     [TC-06]: Khao sat truc quan bang cong Thang 10/2026 (14:6h thieu cong, 22:trong cong) (MnuWPT010)
echo     [TC-07]: Nop & Huy don 14/10; Nop 2 don Gio Ra 17:00 ngay 15/10 (duyet) va 16/10 (reject) (MnuHRS033)
echo     [TC-08]: Nop don Xin nghi phep nam AL ngay 22/10/2026 va Dang xuat (MnuWPT315)
echo     [TC-09]: [BO QUA THEO YEU CAU CUA SEP] Khong test don Xin tang ca OT
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, slowMo, Headed)...
echo.
cd /d "%~dp0"
call npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "fix-5" --headed --workers=1
echo.
echo ====================================================================
echo   HOAN TAT PHIEN KIEM THU TRUC QUAN FIX-5!
echo   Bao cao va hinh anh luu tai: test-evidence\quy_trinh_tinh_luong_nv_moi\
echo ====================================================================
echo.
pause
