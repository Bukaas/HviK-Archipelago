@echo off
rem HviK Archipelago - Super Mario World Starter
rem Patcht beim ersten Mal die ROM, startet SNI Client + Emulator und verbindet mit dem Server.
chcp 65001 >nul
setlocal EnableDelayedExpansion
cd /d "%~dp0"
title HviK Archipelago - Super Mario World

set "AP=C:\ProgramData\Archipelago"
set "EMU=%~dp0snes9x\snes9x-x64.exe"

echo.
echo  ==============================================
echo    HviK Archipelago - Super Mario World
echo  ==============================================
echo.

rem --- 1. Archipelago installiert? ---
if not exist "%AP%\ArchipelagoSNIClient.exe" (
    echo  [!] Archipelago ist noch nicht installiert.
    echo.
    echo      Ich oeffne jetzt die Download-Seite. Lade dort die Datei
    echo      "Setup.Archipelago....exe" herunter, installiere sie
    echo      und starte danach diese START.bat nochmal.
    echo.
    start "" "https://github.com/ArchipelagoMW/Archipelago/releases/tag/0.6.7"
    pause
    exit /b 1
)

rem --- 2. Eigene Patch-Datei + Server-Adresse aus dem Ordner "deine-runde" ---
set "PATCH="
for %%f in ("%~dp0deine-runde\*.apsmw") do set "PATCH=%%~ff"
if not defined PATCH (
    echo  [!] Im Ordner "deine-runde" fehlt deine Patch-Datei ^(.apsmw^).
    echo      Lade dein Paket auf hvik.org in der Runde nochmal herunter.
    pause
    exit /b 1
)
set "SERVER="
if exist "%~dp0deine-runde\server.txt" set /p SERVER=<"%~dp0deine-runde\server.txt"

rem --- 3. Archipelago sagen, dass es unseren Emulator starten soll (host.yaml: snes_rom_start) ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\set-emulator.ps1" -Emulator "%EMU%"

rem --- 4. SNI Client starten: patcht (beim 1. Mal Frage nach der ROM), startet den Emulator, verbindet ---
echo  Starte Archipelago ...
if not exist "%PATCH:.apsmw=.sfc%" (
    echo.
    echo  Beim ersten Mal fragt Archipelago nach deiner ROM:
    echo  bitte "Super Mario World (USA)" ^(.sfc^) auswaehlen.
    echo.
)
if defined SERVER (
    start "" "%AP%\ArchipelagoSNIClient.exe" --connect %SERVER% "%PATCH%"
) else (
    start "" "%AP%\ArchipelagoSNIClient.exe" "%PATCH%"
)

echo  Fertig! Gleich gehen der SNI Client und das Spiel auf.
echo  Verbunden ist alles, wenn im SNI Client "... has joined" steht.
echo.
echo  Dieses Fenster schliesst sich in 15 Sekunden.
timeout /t 15 >nul
exit /b 0
