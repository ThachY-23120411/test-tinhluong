@echo off
title Paradise HRM - Playwright Visual E2E Test
cls
echo ====================================================================
echo   PARADISE HRM - PLAYWRIGHT LIVE VISUAL TESTING (LIVESTREAM)
echo ====================================================================
echo.
echo Dang khoi chay Playwright Headed (Google Chrome that) tren man hinh...
echo Che do: slowMo 400ms, Quay video, Chup anh va Xuat Markdown Report!
echo.
cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
call npx playwright test --headed
echo.
echo ====================================================================
echo   DA HOAN TAT KIEM THU! KET QUA DUOC LUU TAI: test-evidence/
echo ====================================================================
echo.
pause
