# HviK Archipelago - Super Mario 64 einmalig einrichten:
# SM64AP-Launcher (rel8) in diesen Ordner laden und starten. Darin: eigene ROM waehlen und das Spiel bauen lassen.
. "$PSScriptRoot\hvik.ps1"
$Url = "https://github.com/N00byKing/SM64AP-Launcher/releases/download/rel8/SM64AP-Launcher_windows.zip"
$dir = Join-Path $HviK.Root "SM64AP-Launcher"

Say "[1/2] SM64AP-Launcher laden ..."
$z = Get-File $Url "SM64AP-Launcher_windows.zip"
Expand-Zip $z $dir
$exe = Get-ChildItem $dir -Recurse -Filter "*.exe" | Where-Object { $_.Name -match "(?i)launcher|sm64" } | Select-Object -First 1
if (-not $exe) { Fail "Launcher nicht gefunden - beim Host melden." }
Ok "Launcher: $($exe.FullName)"

Say "[2/2] Spiel bauen (einmalig) ..."
Write-Host ""
Say "Gleich geht der Launcher auf. Darin:" Cyan
Say "  1. Deine ROM auswaehlen: Super Mario 64 (USA) oder (Japan) als .z64 - EU geht NICHT." Cyan
Say "  2. Build/Compile starten. Beim ersten Mal installiert er Werkzeuge (MSYS2) - das dauert" Cyan
Say "     10-30 Minuten, einfach laufen lassen." Cyan
Say "  3. Wenn der Build fertig ist, kannst du den Launcher schliessen." Cyan
Start-Process $exe.FullName -WorkingDirectory $exe.DirectoryName
Write-Host ""
Say "Fertig eingerichtet, sobald der Build durch ist." Green
Say "Am Spieltag: START.bat - im Launcher Name + Adresse $($HviK.Server) eintragen und Play."
