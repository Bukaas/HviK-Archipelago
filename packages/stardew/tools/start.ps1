# HviK Archipelago - Stardew Valley mit SMAPI starten. Die Verbindung traegt man beim Anlegen der Farm ein.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\stardew.ps1"
$game = Find-SteamGame $SDV_APPID
$smapi = if ($game) { Join-Path $game "StardewModdingAPI.exe" } else { $null }
if (-not $smapi -or -not (Test-Path $smapi) -or -not (Test-Path (Join-Path $game "Mods\StardewArchipelago\StardewArchipelago.dll"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName
Copy-ToClipboard $HviK.Server
Start-Process $smapi -WorkingDirectory $game
Write-Host ""
Ok "Stardew Valley startet mit SMAPI (es geht zusaetzlich ein Konsolenfenster auf - offen lassen). Dann:"
Say "  1. Neu -> neue Farm anlegen. Unten gibt es drei Archipelago-Felder:" White
Say "       Server:   $($HviK.Server)   (ist kopiert - Strg+V)" Cyan
Say "       Slotname: $name" Cyan
Say "       Passwort: leer lassen" Cyan
Say "  2. Farm/Figur wie du willst - OK. Der Mod verbindet sich selbst." White
Say "Weiterspielen: einfach den Spielstand laden, er verbindet sich von alleine."
