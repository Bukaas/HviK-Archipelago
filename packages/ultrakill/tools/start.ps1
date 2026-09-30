# HviK Archipelago - ULTRAKILL starten: Verbinden-Befehl fuer die F8-Konsole in die Zwischenablage.
. "$PSScriptRoot\hvik.ps1"
$game = Find-SteamGame 1229490
if (-not $game -or -not (Test-Path (Join-Path $game "BepInEx\plugins\TRPG-Archipelago"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName

$cmd = "connect $($HviK.Server) $name"
Copy-ToClipboard $cmd
Start-Process "steam://rungameid/1229490"
Write-Host ""
Ok "Spiel startet. ZUERST einen neuen Spielstand waehlen (bzw. deinen HviK-Spielstand),"
Ok "DANN F8 druecken, Strg+V und Enter:"
Say "    $cmd" White
Say "Oder: Optionen -> PLUGIN CONFIG -> Archipelago -> PLAYER SETTINGS -> Name/Adresse -> Connect."
