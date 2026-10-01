# HviK Archipelago - Subnautica starten: Verbindung eintragen, Spiel ueber Steam starten.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\subnautica.ps1"
$game = Find-SteamGame $SUB_APPID
if (-not $game -or -not (Test-Path (Join-Path $game "BepInEx\plugins\Archipelago\Archipelago.dll"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName
Set-SubConnection $game $name
Copy-ToClipboard $name
Start-Process "steam://rungameid/$SUB_APPID"
Write-Host ""
Ok "Subnautica startet (mit Mod). Dann:"
Say "  1. Im Hauptmenue oben links: Host $($HviK.Server), PlayerName $name - schon eingetragen." White
Say "  2. 'Connect' klicken, warten bis 'Connected' steht." White
Say "  3. NEUES Spiel starten (Weiterspielen: deinen HviK-Spielstand laden)." White
Say "Chat/Hints im Spiel: Konsole mit Shift+Enter, dann z.B.  say !hint Seaglide"
Say "Tipp: Nach 'Zurueck ins Hauptmenue' das Spiel lieber ganz neu starten (bekannter Mod-Fehler)."
