@echo off
title Paradise HRM - 10 Parallel Windows Visual Test
cls
echo ====================================================================
echo   PARADISE HRM - TEST SONG SONG 10 CUA SO CUNG LUC (1-CLICK RUN)
echo ====================================================================
echo.
echo Dang khoi chay 10 cua so Google Chrome dong thoi tren man hinh...
echo Co che: Tu dong phat hien moi kich ban moi trong thu muc tests/!
echo.
cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
call npx playwright test --headed --workers=10
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU 10 LUONG! DANG MO BAO CAO TONG HOP...
echo ====================================================================
echo.
if exist "test-evidence\test-report.md" (
    start "" "test-evidence\test-report.md"
)
pause
