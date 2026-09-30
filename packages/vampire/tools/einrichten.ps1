# HviK Archipelago - Vampire Survivors einmalig einrichten:
# .NET 6 + MelonLoader 0.7.2 + ArchipelagoSurvivors v0.3.5.1 (passend zum HviK-Server) in den Spielordner.
# Das Downpatchen (Spielversion vor 1.15) geht NICHT automatisch - siehe LIESMICH.txt.
. "$PSScriptRoot\hvik.ps1"

Say "Schon heruntergepatcht (Spielversion vor 1.15)? Sonst ZUERST die Schritte in LIESMICH.txt!" Yellow
Write-Host ""
Say "[1/4] Vampire Survivors suchen ..."
$game = Find-SteamGame 1794680
if (-not $game) { Fail "Vampire Survivors ist nicht installiert (Steam). Bitte erst installieren." }
Ok "Gefunden: $game"
$tmp = Join-Path $env:TEMP "hvik-archipelago\vampire"
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }

Say "[2/4] .NET 6 ..."
Install-DotNet6

Say "[3/4] MelonLoader 0.7.2 (Mod-Loader) ..."
$z = Get-File "https://github.com/LavaGang/MelonLoader/releases/download/v0.7.2/MelonLoader.x64.zip" "MelonLoader.x64.zip"
Expand-Zip $z $game
Ok "MelonLoader installiert."

Say "[4/4] ArchipelagoSurvivors-Mod ..."
$z = Get-File "https://github.com/SWCreeperKing/ArchipelagoSurvivors/releases/download/v0.3.5.1/ArchipelagoSurvivors.zip" "ArchipelagoSurvivors.zip"
Expand-Zip $z $tmp
Copy-Item "$tmp\ArchipelagoSurvivors\*" $game -Recurse -Force
Ok "Mod installiert."

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Der erste Start dauert laenger (MelonLoader richtet sich ein)."
Say "Oben links auf dem Titelbildschirm muss ein Verbindungsfeld erscheinen."
Say "Kommt keins: Spielversion zu neu (1.15+) -> downpatchen, siehe LIESMICH.txt." Yellow
