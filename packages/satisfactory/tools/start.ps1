# HviK Archipelago - Satisfactory starten. Die Verbindung traegt man beim neuen Spiel in "Mod Savegame Settings" ein.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\satisfactory.ps1"
$game = Find-SteamGame $SF_APPID
if (-not $game -or -not (Test-Path (Join-Path (Get-SfModsDir $game) "Archipelago\Archipelago.uplugin"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName
Copy-ToClipboard $HviK.Server
Start-Process "steam://rungameid/$SF_APPID"
Write-Host ""
Ok "Satisfactory startet (mit Mods). Fuer die Fabrik-Chefin/den Fabrik-Chef (Host):"
Say "  1. Neues Spiel -> Startgebiet waehlen (Intro ueberspringen geht)." White
Say "  2. Unten rechts 'Mod Savegame Settings' -> eintragen:" White
Say "       Server URI: $($HviK.Server)   (ist kopiert - Strg+V)" Cyan
Say "       User Name:  $name" Cyan
Say "       Password:   leer lassen" Cyan
Say "  3. Spiel erstellen - im Chat erscheint die Archipelago-Verbindung. Ab zum HUB!" White
Say "Mitspieler: einfach dem Host ueber Steam beitreten (Satisfactory-Multiplayer)."
Say "Befehle im Spiel-Chat OHNE Ausrufezeichen, z.B.  /hint Iron Plate"
