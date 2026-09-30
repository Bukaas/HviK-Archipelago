@echo off
rem HviK Archipelago - Factorio: nach der Runde Space Age & Co. wieder einschalten, Archipelago-Mod aus.
chcp 65001 >nul
title Factorio - DLC wieder an
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\mods.ps1" -Mode normal
echo.
echo  Space Age, Quality und Elevated Rails sind wieder an, der Archipelago-Mod ist aus.
echo  Du kannst Factorio jetzt ganz normal spielen.
echo.
pause
