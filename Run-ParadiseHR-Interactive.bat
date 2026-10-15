@echo off
chcp 65001 >nul
title Paradise HRM - Interactive Test Control Center
cls
cd /d "c:\Users\Y.Thach\Desktop\paradiseHR"
powershell -NoProfile -ExecutionPolicy Bypass -File "menu_runner.ps1"
