# HviK Archipelago - Ratchet & Clank 3 starten: PCSX2 mit dem Spiel + Archipelago Launcher.
# Der RaC3-Client laesst sich nicht direkt per Befehl starten (stuerzt mit Startparametern ab) -
# deshalb den Launcher oeffnen, dort den Client anklicken.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\rac3.ps1"
if (-not (Test-Path $RAC3_EXE) -or -not (Test-Path $RAC3_INI) -or -not (Test-Path (Join-Path $HviK.ApDir "custom_worlds\rac3.apworld"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName
Set-Rac3Pine
$iso = Get-Rac3Iso
if ($iso) { Start-Process $RAC3_EXE -ArgumentList "--", "`"$iso`"" -WorkingDirectory $RAC3_PCSX2 }
else { Start-Process $RAC3_EXE -WorkingDirectory $RAC3_PCSX2; Say "Keine ISO gemerkt - in PCSX2 das Spiel selbst starten." Yellow }
Start-Process (Join-Path $HviK.ApDir "ArchipelagoLauncher.exe")
Copy-ToClipboard $HviK.Server

Write-Host ""
Ok "PCSX2 und der Archipelago Launcher starten. Dann:"
Say "  1. Im Launcher 'Ratchet and Clank 3 Client' anklicken." White
Say "  2. Im Client oben Strg+V ($($HviK.Server) ist kopiert) -> Connect." White
Say "  3. Nach deinem Namen gefragt: $name eingeben, Enter." White
Say "  4. Im Spiel einen NEUEN Spielstand beginnen - sobald du spielst, kommen die Items." White
Say "Der Client meldet 'PCSX2 not found'? PCSX2 muss laufen und das Spiel geladen sein."
