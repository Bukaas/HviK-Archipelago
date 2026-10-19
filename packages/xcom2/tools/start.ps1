# HviK Archipelago - XCOM 2 WotC starten: zuerst der Client (verbindet + schreibt die Mod-Einstellungen), dann das Spiel.
# Der Client nimmt keine Start-Argumente an -> Adresse und Name nacheinander in die Zwischenablage.
. "$PSScriptRoot\hvik.ps1"
$game = Find-SteamGame 268500
if (-not $game -or -not (Test-Path (Join-Path $HviK.ApDir "custom_worlds\x2wotc.apworld"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName
Say "Starte den XCOM 2 War of the Chosen Client ..."
Start-Process (Join-Path $HviK.ApDir "ArchipelagoLauncher.exe") -ArgumentList "`"XCOM 2 War of the Chosen Client`""

Copy-ToClipboard $HviK.Server
Write-Host ""
Ok "Adresse $($HviK.Server) ist kopiert: im Client oben ins Server-Feld -> Strg+V -> Connect."
Read-Host "  Danach hier Enter druecken (dann kopiere ich deinen Namen)" | Out-Null
Copy-ToClipboard $name
Ok "Name $name ist kopiert: fragt der Client nach dem Namen -> Strg+V -> Enter."
Read-Host "  Steht im Client 'connected'? Dann Enter - ich starte XCOM 2" | Out-Null
Start-Process (Join-Path (Get-SteamDir) "steam.exe") -ArgumentList "-applaunch", "268500"
Say "Im Launcher 'War of the Chosen' waehlen, Mod 'WotC Archipelago' angehakt lassen -> neue Kampagne."
Say "Das Client-Fenster waehrend des Spielens OFFEN lassen." Yellow
Say "Client-Befehle: /version, /game_path, /progressive"
