# HviK Archipelago - Raft starten: Mod Loader oeffnen, Verbinden-Befehl in die Zwischenablage.
. "$PSScriptRoot\hvik.ps1"
$launcher = Join-Path $HviK.Root "RMLLauncher.exe"
$game = Find-SteamGame 648800
if (-not (Test-Path $launcher) -or -not $game -or -not (Test-Path (Join-Path $game "mods\Raftipelago.rmod"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName
$cmd = "/connect $($HviK.Server) $name"
Copy-ToClipboard $cmd
Start-Process $launcher -WorkingDirectory $HviK.Root
Write-Host ""
Ok "Raft Mod Loader startet - dort auf 'Play' klicken. Dann im Spiel:"
Say "  1. F9 -> Mod manager: zuerst ModUtils laden (Stecker-Symbol), DANN Raftipelago." White
Say "  2. Spielstand laden oder neu anfangen." White
Say "  3. F10 -> Konsole: Strg+V und Enter   ($cmd)" White
Say "Verbindung weg? Einfach F10 und den Befehl nochmal."
