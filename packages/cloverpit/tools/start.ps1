# HviK Archipelago - CloverPit starten: Spiel mit Mod, Adresse + Name kommen nacheinander in die Zwischenablage.
. "$PSScriptRoot\hvik.ps1"
$game = Find-SteamGame 3314790
if (-not $game -or -not (Test-Path (Join-Path $game "BepInEx\plugins\CloverPit.Archipelago.dll"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName
Say "Starte CloverPit ..."
Start-Process (Join-Path (Get-SteamDir) "steam.exe") -ArgumentList "-applaunch", "3314790"

Copy-ToClipboard $HviK.Server
Write-Host ""
Ok "Adresse $($HviK.Server) ist kopiert."
Say "Im Spiel geht das Archipelago-Fenster auf (sonst F8): bei 'Host' Strg+V."
Read-Host "  Danach hier Enter druecken (dann kopiere ich deinen Namen)" | Out-Null
Copy-ToClipboard $name
Ok "Name $name ist kopiert: bei 'Slot' Strg+V -> Connect."
Say "Passwort leer lassen. Die Daten merkt sich der Mod fuers naechste Mal."
Say "F8 = Archipelago-Konsole (Hinweise, Chat)."
