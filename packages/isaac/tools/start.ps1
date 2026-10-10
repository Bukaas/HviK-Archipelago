# HviK Archipelago - Isaac starten: Spiel (mit Workshop-Mod) + Isaac Client. Der Client nimmt keine
# Start-Argumente an -> Adresse und Name nacheinander in die Zwischenablage.
. "$PSScriptRoot\hvik.ps1"
$game = Find-SteamGame 250900
if (-not $game -or -not (Test-Path (Join-Path $HviK.ApDir "custom_worlds\tboir.apworld"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$mods = Join-Path $game "mods"
if (-not (Test-Path $mods) -or -not (Get-ChildItem $mods -Directory | Where-Object { Test-Path (Join-Path $_.FullName "supported_client") })) {
    Say "Der Archipelago-Mod ist noch nicht im Spielordner. Abonniert? Dann startet ihn Isaac gleich mit." Yellow
}
$name = Get-PlayerName
$steam = Get-SteamDir

Say "Starte The Binding of Isaac ..."
Start-Process (Join-Path $steam "steam.exe") -ArgumentList "-applaunch", "250900"
Say "Starte Isaac Client ..."
Start-Process (Join-Path $HviK.ApDir "ArchipelagoLauncher.exe") -ArgumentList "`"Isaac Client`""

Copy-ToClipboard $HviK.Server
Write-Host ""
Ok "Adresse $($HviK.Server) ist kopiert: im Isaac Client oben ins Server-Feld -> Strg+V -> Connect."
Read-Host "  Danach hier Enter druecken (dann kopiere ich deinen Namen)" | Out-Null
Copy-ToClipboard $name
Ok "Name $name ist kopiert: fragt der Client nach dem Namen -> Strg+V -> Enter."
Ok "Dann fragt er nach dem Speicherplatz (1-3): den Spielstand, den du in Isaac benutzt."
Say "Im Spiel: Mod 'The Archipelago of Isaac' muss im Mods-Menue an sein -> neuen Run starten."
Say "Client-Befehle: /savefile 1-3 (Speicherplatz wechseln), /resync (Items neu holen)."
