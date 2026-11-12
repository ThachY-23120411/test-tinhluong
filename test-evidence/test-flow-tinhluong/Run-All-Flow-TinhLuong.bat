@echo off
chcp 65001 >nul
title Paradise HRM - Master E2E: Toan Bo Flow Tinh Luong (fix-4 den fix-8)
cls
echo ====================================================================
echo   PARADISE HRM - MASTER E2E: TOAN BO FLOW TINH LUONG (fix-4 den fix-8)
echo   Kich ban: tests/quy_trinh_tinh_luong_nv_moi.spec.js
echo   Pham vi: 17 Test Cases (TC-03 den TC-19)
echo ====================================================================
echo.
echo   Luu y: Nho chay script SQL reset truoc tren SSMS:
echo   test-evidence\test-flow-tinhluong\reset_and_seed_master_flow_tinhluong.sql
echo.
echo   Lo trinh 17 Test Cases:
echo     [1] fix-4: TC-03 (Luong 10Tr), TC-04 (1 NPT), TC-05 (Phan ca HC)
echo     [2] fix-5: TC-06 (Khao sat), TC-07 (Bu cong), TC-08 (Phep AL), TC-09 (OT)
echo     [3] fix-6: TC-10 (Tri duyet C1), TC-11 (Long OT), TC-12 (Duyet C2), TC-13 (Bang cong)
echo     [4] fix-7: TC-14 (Thuong KPI), TC-15 (Tam ung), TC-16 (Tinh luong), TC-17 (Khoa so)
echo     [5] fix-8: TC-18 (Bang luong tong hop), TC-19 (Phieu luong va 3 Modal)
echo   Che do: LITE MODE (tat quay video 1440x900 va bao cao nang de giam lag)
echo ====================================================================
echo.
echo Dang khoi chay Google Chrome truc quan (Chuot Neon, workers=1)...
echo.

cd /d "%~dp0..\.."
if not exist "node_modules" (
    cd /d "C:\Users\Y.Thach\Desktop\paradiseHR"
)

call npx playwright test -c test-evidence/test-flow-tinhluong/playwright.lite.config.js tests/quy_trinh_tinh_luong_nv_moi.spec.js --project="Google Chrome" --headed --workers=1

echo.
echo ====================================================================
echo   HOAN TAT KIEM THU TOAN BO 17 TEST CASES CUA FLOW TINH LUONG!
echo ====================================================================
echo.
pause
