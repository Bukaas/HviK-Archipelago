# HviK Archipelago - Cyberpunk 2077 starten: Spiel mit Mods; verbunden wird im Fenster von Cyber Engine Tweaks.
. "$PSScriptRoot\hvik.ps1"
$game = Find-SteamGame 1091500
$name = Get-PlayerName
$teile = $HviK.Server.Split(":")
if ($game) {
    Say "Starte Cyberpunk 2077 ..."
    Start-Process (Join-Path (Get-SteamDir) "steam.exe") -ArgumentList "-applaunch", "1091500"
} else {
    Say "Bitte Cyberpunk 2077 jetzt selbst starten (GOG/Epic)." Yellow
}
Write-Host ""
Say "Im Spiel die CET-Taste druecken (die du beim ersten Start gewaehlt hast) -> Archipelago-Fenster:"
Copy-ToClipboard $teile[0]
Ok "Adresse $($teile[0]) ist kopiert -> ins Feld fuer IP/URL: Strg+V."
Read-Host "  Danach Enter (dann kopiere ich den Port)" | Out-Null
Copy-ToClipboard $teile[1]
Ok "Port $($teile[1]) ist kopiert -> ins Port-Feld: Strg+V."
Read-Host "  Danach Enter (dann kopiere ich deinen Namen)" | Out-Null
Copy-ToClipboard $name
Ok "Name $name ist kopiert -> ins Feld 'Slot Name': Strg+V -> 'Connect to Archipelago'."
Say "Passwort leer lassen. Dann neues Spiel (oder dein AP-Spielstand) - los geht's."
