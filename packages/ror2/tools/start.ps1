# HviK Archipelago - Risk of Rain 2 starten: Name/Server in den Mod eintragen, Spiel ueber Steam starten.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\ror2.ps1"
$game = Find-SteamGame $ROR2_APPID
if (-not $game -or -not (Test-Path (Join-Path $game "BepInEx\plugins\ArchipelagoMW-Archipelago\Archipelago.RiskOfRain2.dll"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName
Set-Ror2Connection $game $name
Copy-ToClipboard "archipelago hvik.org 38281 $name"
Start-Process "steam://rungameid/$ROR2_APPID"
Write-Host ""
Ok "Risk of Rain 2 startet (mit Mods). Dann:"
Say "  1. Singleplayer -> in der Lobby (Charakterauswahl) stehen die Archipelago-Felder:" White
Say "     Server hvik.org, Port 38281, Slot $name - schon eingetragen." White
Say "  2. 'Connect to AP' klicken, Charakter waehlen, los." White
Say "Stehen die Felder leer: Konsole (Strg+Alt+Zirkumflex) -> Strg+V, Enter" White
Say "  (archipelago hvik.org 38281 $name ist kopiert)."
