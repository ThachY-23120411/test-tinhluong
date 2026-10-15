@echo off
title Paradise HRM - Full Regression Test Suite
cls
echo ====================================================================
echo   PARADISE HRM - CHAY TOAN BO KICH BAN KIEM THU TU DONG (A -> Z)
echo ====================================================================
echo.
echo Dang khoi chay Playwright Headed tren Google Chrome...
echo Che do: Chay kien truc chuan, Quay video, Chup anh, Xuat Markdown!
echo.
cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
call npx playwright test --headed
echo.
echo ====================================================================
echo   HOAN TAT KIEM THU! DANG TU DONG MO FILE BAO CAO TONG HOP...
echo ====================================================================
echo.
if exist "test-evidence\test-report.md" (
    start "" "test-evidence\test-report.md"
)
pause
