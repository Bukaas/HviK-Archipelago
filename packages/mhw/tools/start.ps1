# HviK Archipelago - Monster Hunter: World starten: erst der MHWGenerator (baut die Spieldaten fuer deine Welt),
# dann das Spiel ueber Steam.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\mhw.ps1"
$game = Find-SteamGame $MHW_APPID
if (-not $game -or -not (Test-Path $MHW_GEN_EXE)) { Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken." }
$name = Get-PlayerName
Copy-ToClipboard $HviK.Server
Write-Host ""
Say "Schritt 1: Der MHWGenerator geht auf. Dort eintragen:" White
Say "    Server URL: $($HviK.Server)   (ist kopiert - Strg+V)" Cyan
Say "    Slot Name:  $name" Cyan
Say "    Password:   leer lassen" Cyan
Say "  Spiel-Pfad, falls gefragt: $game\MonsterHunterWorld.exe" Cyan
Say "  -> Connect. Wenn er fertig ist, das Fenster schliessen." White
Start-Process $MHW_GEN_EXE -WorkingDirectory $MHW_GEN_DIR -Wait
Write-Host ""
Copy-ToClipboard "/connect $($HviK.Server) $name"
Start-Process "steam://rungameid/$MHW_APPID"
Ok "Schritt 2: Monster Hunter: World startet (mit Mod - es geht zusaetzlich ein Konsolenfenster auf)."
Say "  Verbindet er sich nicht selbst: in der Konsole bzw. im Spiel-Chat Strg+V, Enter" White
Say "  (/connect $($HviK.Server) $name ist kopiert)." White
Say "WICHTIG: Nur mit anderen Archipelago-Spielern zusammen online spielen - Mods gelten als Cheaten."
