@echo off
chcp 65001 >nul
title Paradise HRM - Live Visual Test: FIX-7 (Replay Recording 11/12/2026)
cls
echo ====================================================================
echo   CHAY TRUC QUAN FIX-7: REPLAY KHOP 100%% RECORDING 11/12/2026
echo   Vai tro: Chien.nguyen (013)
echo   (Nho chay scripts\reset\reset_fix7_data.sql tren SSMS truoc neu muon lap lai du lieu sach!)
echo   Pham vi (4 TC tu TC-14 den TC-17):
echo     [TC-14]: Nap Thuong KPI 1,000,000 VND (MnuPRL036 - Thu nhap khong co dinh)
echo     [TC-15]: Nap Tam ung luong 2,000,000 VND & Khoa phieu (MnuPRL070)
echo     [TC-16]: Chay Tinh tien luong Thang 10/2026 (MnuPRL040)
echo     [TC-17]: Khoa cham cong (MnuTAD125), Khoa so luong (MnuPRL080) & Dang xuat
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, Headed)...
echo.
cd /d "%~dp0"
call npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "fix-7" --headed --workers=1 --project="Google Chrome"
echo.
echo ====================================================================
echo   HOAN TAT PHIEN KIEM THU TRUC QUAN FIX-7!
echo   Bao cao va hinh anh luu tai: test-evidence\quy_trinh_tinh_luong_nv_moi\
echo ====================================================================
echo.
pause
