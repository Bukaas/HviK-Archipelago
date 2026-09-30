# HviK Archipelago - Vampire Survivors einmalig einrichten:
# Spiel auf 1.15.114 zuruecksetzen + .NET 6 + MelonLoader 0.7.2 + ArchipelagoSurvivors v0.3.5.1
# (passend zum HviK-Server) in den Spielordner.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\downpatch.ps1"

Say "[1/5] Vampire Survivors suchen ..."
$game = Find-SteamGame 1794680
if (-not $game) { Fail "Vampire Survivors ist nicht installiert (Steam). Bitte erst installieren." }
Ok "Gefunden: $game"
$tmp = Join-Path $env:TEMP "hvik-archipelago\vampire"
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }

Say "[2/5] Spielversion $VS_VERSION (der Mod laeuft noch nicht mit 1.16) ..."
Invoke-Downpatch $game

Say "[3/5] .NET 6 ..."
Install-DotNet6

Say "[4/5] MelonLoader 0.7.2 (Mod-Loader) ..."
$z = Get-File "https://github.com/LavaGang/MelonLoader/releases/download/v0.7.2/MelonLoader.x64.zip" "MelonLoader.x64.zip"
Expand-Zip $z $game
Ok "MelonLoader installiert."

Say "[5/5] ArchipelagoSurvivors-Mod ..."
$z = Get-File "https://github.com/SWCreeperKing/ArchipelagoSurvivors/releases/download/v0.3.5.1/ArchipelagoSurvivors.zip" "ArchipelagoSurvivors.zip"
Expand-Zip $z $tmp
Copy-Item "$tmp\ArchipelagoSurvivors\*" $game -Recurse -Force
Ok "Mod installiert."

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: START.bat doppelklicken. Der erste Start dauert laenger (MelonLoader richtet sich ein)."
Say "Oben links auf dem Titelbildschirm muss ein Verbindungsfeld erscheinen."
Say "Normal ohne Mod spielen: im Spielordner version.dll in version.dll.aus umbenennen."
