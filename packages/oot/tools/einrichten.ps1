# HviK Archipelago - Ocarina of Time einmalig einrichten:
# BizHawk 2.10 (portable) in diesen Ordner, Grundeinstellungen setzen und Archipelago sagen, dass es nach dem Patchen
# BizHawk MIT dem Verbindungs-Skript connector_oot.lua startet (host.yaml -> oot_options.rom_start = unser Starter).
. "$PSScriptRoot\hvik.ps1"
$BizUrl = "https://github.com/TASEmulators/BizHawk/releases/download/2.10/BizHawk-2.10-win-x64.zip"
$biz = Join-Path $HviK.Root "BizHawk"

Say "[1/4] Archipelago ..."
Test-Archipelago
$lua = Join-Path $HviK.ApDir "data\lua\connector_oot.lua"
if (-not (Test-Path $lua)) { Fail "connector_oot.lua fehlt in Archipelago - bitte Archipelago 0.6.7 neu installieren." }
Ok "Archipelago gefunden."

Say "[2/4] BizHawk 2.10 (Emulator, ca. 80 MB) ..."
if (-not (Test-Path (Join-Path $biz "EmuHawk.exe"))) {
    $z = Get-File $BizUrl "BizHawk-2.10-win-x64.zip"
    Expand-Zip $z $biz
}
if (-not (Test-Path (Join-Path $biz "EmuHawk.exe"))) { Fail "BizHawk konnte nicht entpackt werden - beim Host melden." }
# Grundeinstellungen aus der OoT-Anleitung: im Hintergrund weiterlaufen + Eingaben annehmen, SaveRAM automatisch sichern.
# Nur beim allerersten Mal (spaetere eigene Einstellungen nicht ueberschreiben).
$cfg = Join-Path $biz "config.ini"
if (-not (Test-Path $cfg)) {
    [IO.File]::WriteAllText($cfg, '{"RunInBackground":true,"AcceptBackgroundInput":true,"AutosaveSaveRAM":true,"FlushSaveRamFrames":300}', (New-Object Text.UTF8Encoding $false))
}
Ok "BizHawk liegt in $biz"

Say "[3/4] Starter fuer Archipelago ..."
# Archipelago ruft rom_start mit der gepatchten ROM als einzigem Argument auf -> diese .bat haengt das Lua-Skript an.
$starter = Join-Path $biz "hvik-oot-start.bat"
$bat = "@echo off`r`nstart `"`" `"$biz\EmuHawk.exe`" --lua=`"$lua`" `"%~1`"`r`n"
[IO.File]::WriteAllText($starter, $bat, (New-Object Text.ASCIIEncoding))
Ok "Starter: $starter"

Say "[4/4] Archipelago-Einstellung (host.yaml) ..."
$hostYaml = Join-Path $HviK.ApDir "host.yaml"
if (-not (Test-Path $hostYaml)) {
    Say "Archipelago wird einmal kurz gestartet, damit es seine Einstellungen anlegt ..."
    Start-Process (Join-Path $HviK.ApDir "ArchipelagoLauncher.exe"); Start-Sleep -Seconds 8
    Get-Process ArchipelagoLauncher -ErrorAction SilentlyContinue | Stop-Process -Force
}
& "$PSScriptRoot\set-oot-start.ps1" -HostYaml $hostYaml -Starter $starter
Ok "Nach dem Patchen startet Archipelago jetzt BizHawk mit dem OoT-Verbindungs-Skript."

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: deine .apz5-Datei auf hvik.org laden und doppelklicken (oder START.bat)."
Say "Beim allerersten Mal fragt Archipelago nach deiner ROM: Ocarina of Time (USA) v1.0 (.z64)."
