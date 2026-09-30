# HviK Archipelago - Portal 2 starten: Mod mit -netconport 3000 + Portal 2 Client, direkt verbunden.
. "$PSScriptRoot\hvik.ps1"
$steam = Get-SteamDir
$mod = if ($steam) { Join-Path $steam "steamapps\sourcemods\Portal2Archipelago" }
if (-not $mod -or -not (Test-Path $mod) -or -not (Test-Path (Join-Path $HviK.ApDir "custom_worlds\portal2.apworld"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName

Say "Starte Portal 2 Archipelago Mod ..."
Start-Process (Join-Path $steam "steam.exe") -ArgumentList "-applaunch", "620", "-game", "`"$mod`"", "-netconport", "3000"
Say "Starte Portal 2 Client und verbinde mit $($HviK.Server) ..."
# Der Client fragt den Namen selbst ab (--name wertet er nicht aus) -> Name in die Zwischenablage.
Start-Process (Join-Path $HviK.ApDir "ArchipelagoLauncher.exe") -ArgumentList "`"Portal 2 Client`"", "--", "--connect", $HviK.Server
Copy-ToClipboard $name
Write-Host ""
Ok "Fragt der Client nach deinem Namen: Strg+V und Enter ($name ist schon kopiert)."
Ok "Im Spiel: Karte im Maps-Menue waehlen - los geht's!"
Say "Kein Kontakt zum Spiel? Im Client /check_connection eingeben."
