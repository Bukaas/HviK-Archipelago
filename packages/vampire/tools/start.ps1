# HviK Archipelago - Vampire Survivors starten: Adresse in die Zwischenablage, Name anzeigen.
. "$PSScriptRoot\hvik.ps1"
$game = Find-SteamGame 1794680
if (-not $game -or -not (Test-Path (Join-Path $game "Mods\ArchipelagoSurvivors.dll"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName

Copy-ToClipboard $HviK.Server
Start-Process "steam://rungameid/1794680"
Write-Host ""
Ok "Spiel startet. Oben links auf dem Titelbildschirm eintragen:"
Say "    Adresse: $($HviK.Server)   (schon kopiert - Strg+V)" White
Say "    Name:    $name" White
Say "Dann verbinden und losspielen."
