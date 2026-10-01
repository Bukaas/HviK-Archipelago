# HviK Archipelago - Hollow Knight starten: Name/Server in den Mod eintragen, Spiel ueber Steam starten.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\hk.ps1"
$game = Find-SteamGame $HK_APPID
if (-not $game -or -not (Test-Path (Join-Path (Get-HkManaged $game) "Mods\Archipelago\Archipelago.HollowKnight.dll"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName
Set-HkConnection $name
Copy-ToClipboard $name
Start-Process "steam://rungameid/$HK_APPID"
Write-Host ""
Ok "Hollow Knight startet (mit Mods - oben links stehen die Mod-Namen). Dann:"
Say "  1. Spiel starten -> einen LEEREN Speicherplatz waehlen." White
Say "  2. Oben als Modus 'Archipelago' anklicken." White
Say "  3. Server hvik.org, Port 38281 und Name $name stehen schon drin -> Start." White
Say "Weiterspielen: einfach deinen Speicherplatz laden, er verbindet sich selbst."
Say "Steht ein anderer Name drin: Feld anklicken, Strg+V ($name ist kopiert)."
