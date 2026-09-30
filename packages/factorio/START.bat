@echo off
rem HviK Archipelago - Factorio Starter
rem Kopiert den Mod der Runde, schaltet Space Age & Co. aus und startet Factorio direkt verbunden mit der Fabrik.
chcp 65001 >nul
setlocal
cd /d "%~dp0"
title HviK Archipelago - Factorio

echo.
echo  ==============================================
echo    HviK Archipelago - Factorio
echo  ==============================================
echo.

set "MODS=%APPDATA%\Factorio\mods"
set "MOD="
for %%f in ("%~dp0deine-runde\AP-*.zip") do set "MOD=%%~ff"
if not defined MOD (
    echo  [!] Im Ordner "deine-runde" fehlt der Mod ^(AP-....zip^).
    echo      Lade dein Paket auf hvik.org in der Runde nochmal herunter.
    pause
    exit /b 1
)
set "SERVER="
if exist "%~dp0deine-runde\server.txt" set /p SERVER=<"%~dp0deine-runde\server.txt"

if not exist "%MODS%" (
    echo  [!] Factorio-Mod-Ordner nicht gefunden: %MODS%
    echo      Starte Factorio einmal ganz normal, schliesse es wieder und starte dann diese START.bat nochmal.
    pause
    exit /b 1
)

rem --- Mod rein, alte Archipelago-Mods raus, mod-list.json anpassen (DLC aus, dieser Mod an) ---
echo  Installiere den Mod dieser Runde ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\mods.ps1" -Mode archipelago -Mod "%MOD%"
if errorlevel 1 (
    echo  [!] Der Mod konnte nicht installiert werden - laeuft Factorio gerade? Dann schliessen und nochmal starten.
    pause
    exit /b 1
)

echo  Space Age, Quality und Elevated Rails sind jetzt aus ^(zum Wieder-Einschalten: "DLC wieder an.bat"^).
echo.

rem --- Factorio ueber Steam starten und direkt mit der Fabrik verbinden ---
if defined SERVER (
    echo  Starte Factorio und verbinde mit %SERVER% ...
    echo  ^(Steam fragt evtl., ob Factorio mit diesen Einstellungen starten darf - einfach bestaetigen.^)
    start "" "steam://run/427520//--mp-connect %SERVER%/"
) else (
    echo  Starte Factorio ...
    start "" "steam://run/427520"
)
echo.
echo  Dieses Fenster schliesst sich in 15 Sekunden.
timeout /t 15 >nul
exit /b 0
