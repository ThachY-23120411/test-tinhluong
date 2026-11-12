@echo off
chcp 65001 >nul
title Paradise HRM - Live Visual Test: FIX-6 (Replay Recording 11/12/2026)
cls
echo ====================================================================
echo   CHAY TRUC QUAN FIX-6: REPLAY KHOP 100%% RECORDING 11/12/2026
echo   Vai tro: tri.nguyen (004), LongKa (012), test.nv (099)
echo   Pham vi (4 TC tu TC-10 den TC-13):
echo     [TC-10]: tri.nguyen duyet Cap 1 (Phep, Bu cong 15/10 ^& 16/10, Xin huy 14/10) ^& Dang xuat
echo     [TC-11]: LongKa duyet Cap 1 Tang ca OT ^& xem tab Lich su
echo     [TC-12]: LongKa duyet Cap 2 (Phep, Bu cong 15/10 ^& 16/10, Xin huy 14/10), xem tab ^& Dang xuat
echo     [TC-13]: test.nv mo Bang cong ca nhan (MnuWPT010) chon Thang 10
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, Headed)...
echo.
cd /d "%~dp0"
call npx playwright test tests/quy_trinh_tinh_luong_nv_moi.spec.js -g "fix-6" --headed --workers=1 --project="Google Chrome"
echo.
echo ====================================================================
echo   HOAN TAT PHIEN KIEM THU TRUC QUAN FIX-6!
echo   Bao cao va hinh anh luu tai: test-evidence\quy_trinh_tinh_luong_nv_moi\
echo ====================================================================
echo.
pause
