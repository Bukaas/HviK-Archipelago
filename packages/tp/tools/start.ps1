# HviK Archipelago - Twilight Princess starten: Twilight Princess Client + Dolphin mit dem Spiel, /name in die Zwischenablage.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\tp.ps1"
$dolphin = Join-Path $TP_DOLPHIN "Dolphin.exe"
if (-not (Test-Path $dolphin) -or -not (Test-Path (Join-Path $HviK.ApDir "custom_worlds\Twilight Princess.apworld"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName

Start-Process (Join-Path $HviK.ApDir "ArchipelagoLauncher.exe") -ArgumentList "`"Twilight Princess Client`""
$iso = Get-TpIso
if ($iso) { Start-Process $dolphin -ArgumentList "-e", "`"$iso`"" -WorkingDirectory $TP_DOLPHIN }
else { Start-Process $dolphin -WorkingDirectory $TP_DOLPHIN; Say "Keine ISO gemerkt - in Dolphin das Spiel selbst oeffnen." Yellow }
Copy-ToClipboard "/name $name"

Write-Host ""
Ok "Twilight Princess Client und Dolphin starten. Dann:"
Say "  1. Im Spiel Speicherstand 3 'REL Loader' starten - das Spiel startet neu," White
Say "     unten muss '1 seed available' stehen." White
Say "  2. Neues Spiel anlegen (Namen ignorieren) - oder deinen HviK-Speicherstand laden." White
Say "  3. Warten, bis du Link steuern kannst." White
Say "  4. Nur bei neuem Spiel: im Client Strg+V, Enter   (/name $name ist kopiert)" White
Say "  5. Im Client oben $($HviK.Server) eintragen -> Connect." White
Say "Wichtig: REL Loader nur EINMAL pro Dolphin-Sitzung starten, sonst kommen Items doppelt."
