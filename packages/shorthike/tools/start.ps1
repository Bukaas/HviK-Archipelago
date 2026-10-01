# HviK Archipelago - A Short Hike starten. Die Verbindung fragt das Spiel beim neuen Spiel ab (wird im Spielstand gemerkt).
. "$PSScriptRoot\hvik.ps1"
$ASH_APPID = 1055540
$game = Find-SteamGame $ASH_APPID
if (-not $game -or -not (Test-Path (Join-Path $game "Modding\plugins\Randomizer.dll"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName
Copy-ToClipboard $HviK.Server
Start-Process "steam://rungameid/$ASH_APPID"
Write-Host ""
Ok "A Short Hike startet (oben links stehen die Mods). Dann:"
Say "  1. NEUES Spiel (bzw. deinen HviK-Spielstand weiterspielen)." White
Say "  2. Im Fenster eintragen:" White
Say "       Server:   $($HviK.Server)   (ist kopiert - Strg+V)" Cyan
Say "       Name:     $name" Cyan
Say "       Passwort: leer lassen" Cyan
Say "  3. Connect - los geht's." White
Say "Taste G (Controller LB/RB + X) zeigt dein Ziel und was noch fehlt."
