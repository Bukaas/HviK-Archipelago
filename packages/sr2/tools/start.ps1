# HviK Archipelago - Slime Rancher 2 starten: Spiel mit Mod, Adresse + Name kommen nacheinander in die Zwischenablage.
. "$PSScriptRoot\hvik.ps1"
$game = Find-SteamGame 1657630
if (-not $game -or -not (Test-Path (Join-Path $game "BepInEx\plugins\SlimeRancher2-AP\SlimeRancher2-AP.dll"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName
Say "Starte Slime Rancher 2 ..."
Start-Process (Join-Path (Get-SteamDir) "steam.exe") -ArgumentList "-applaunch", "1657630"

Copy-ToClipboard $HviK.Server
Write-Host ""
Ok "Adresse $($HviK.Server) ist kopiert."
Say "Im Hauptmenue: Knopf 'Archipelago' (bzw. Einstellungen -> Archipelago) -> bei 'Host:Port' Strg+V."
Read-Host "  Danach hier Enter druecken (dann kopiere ich deinen Namen)" | Out-Null
Copy-ToClipboard $name
Ok "Name $name ist kopiert: bei 'Slot Name' Strg+V -> Connect (Passwort leer)."
Say "Oben links wird die Anzeige gruen, wenn du verbunden bist." Green
Say "WICHTIG: ERST verbinden, DANN ein neues Spiel starten - nicht umgekehrt!" Yellow
