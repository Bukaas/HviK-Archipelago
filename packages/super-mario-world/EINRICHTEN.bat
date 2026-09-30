@echo off
rem HviK Archipelago - Super Mario World: EINMALIG einrichten.
rem Danach reicht am Spieltag: Patch-Datei (.apsmw) von hvik.org herunterladen und doppelklicken.
chcp 65001 >nul
setlocal
cd /d "%~dp0"
title HviK Archipelago - Super Mario World einrichten

set "AP=C:\ProgramData\Archipelago"
set "EMU=%~dp0snes9x\snes9x-x64.exe"

echo.
echo  ==============================================
echo    HviK Archipelago - Super Mario World
echo    Einmalige Einrichtung
echo  ==============================================
echo.
echo  Tipp: Lass diesen Ordner an seinem Platz (z.B. Dokumente oder Desktop).
echo  Wenn du ihn spaeter verschiebst, einfach EINRICHTEN.bat nochmal starten.
echo.

rem --- 1. Archipelago installiert? ---
if not exist "%AP%\ArchipelagoLauncher.exe" (
    echo  [1/2] Archipelago ist noch nicht installiert.
    echo        Ich oeffne die Download-Seite: "Setup.Archipelago....exe" herunterladen,
    echo        installieren und danach EINRICHTEN.bat nochmal starten.
    start "" "https://github.com/ArchipelagoMW/Archipelago/releases/tag/0.6.7"
    echo.
    pause
    exit /b 1
)
echo  [1/2] Archipelago ist installiert.

rem --- 2. Archipelago sagen, dass es unseren Emulator starten soll ---
if not exist "%AP%\host.yaml" (
    echo        Archipelago wird einmal kurz gestartet, damit es seine Einstellungen anlegt ...
    start "" "%AP%\ArchipelagoLauncher.exe"
    timeout /t 8 >nul
    taskkill /im ArchipelagoLauncher.exe /f >nul 2>&1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\set-emulator.ps1" -Emulator "%EMU%"
if errorlevel 1 (
    echo  [!] Konnte den Emulator nicht eintragen. Bitte melde dich beim Host.
    pause
    exit /b 1
)
echo  [2/2] Emulator eingetragen: snes9x-nwa aus diesem Ordner.
echo.
echo  ==============================================
echo    Fertig eingerichtet!
echo.
echo    Am Spieltag: auf hvik.org in der Runde deine
echo    Patch-Datei (.apsmw) herunterladen und doppelklicken.
echo    Beim allerersten Mal fragt Archipelago nach deiner
echo    ROM: "Super Mario World (USA)" (.sfc) auswaehlen.
echo  ==============================================
echo.
pause
exit /b 0
