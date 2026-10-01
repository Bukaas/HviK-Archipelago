# HviK Archipelago - TUNIC starten: Verbindung in die Mod-Einstellungen schreiben, Spiel ueber Steam starten.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\tunic.ps1"
$game = Find-SteamGame $TUNIC_APPID
if (-not $game -or -not (Test-Path (Join-Path $game "BepInEx\plugins\Tunic Randomizer\TunicRandomizer.dll"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName
$settings = Find-TunicSettings
if ($settings) { Set-TunicConnection $settings $name }
Copy-ToClipboard $name
Start-Process "steam://rungameid/$TUNIC_APPID"
Write-Host ""
Ok "TUNIC startet (mit Mod). Dann:"
if ($settings) {
    Say "  1. Im Titelbild steht 'Randomizer Mode: Archipelago' und bald 'Status: Connected!'." White
} else {
    Say "  1. Im Titelbild bei 'Randomizer Mode' auf 'Archipelago' stellen, 'Edit AP Config':" White
    Say "     Player $name (ist kopiert), Hostname hvik.org, Port 38281 -> Close." White
}
Say "  2. NEUES Spiel starten (Weiterspielen: deinen HviK-Spielstand laden)." White
Say "Steht 'Status: Disconnected'? 'Edit AP Config' oeffnen, Daten pruefen, Close."
