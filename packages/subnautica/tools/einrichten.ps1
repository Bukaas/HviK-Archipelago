# HviK Archipelago - Subnautica einmalig einrichten: Archipelago-Mod (bringt BepInEx mit) direkt ins Spiel.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\subnautica.ps1"

Say "[1/2] Subnautica suchen ..."
$game = Find-SteamGame $SUB_APPID
if (-not $game) { Fail "Subnautica ist nicht installiert (Steam). Bitte erst installieren." }
Ok "Gefunden: $game"

Say "[2/2] Archipelago-Mod $SUB_MOD_VERSION (mit BepInEx) ..."
$z = Get-File $SUB_MOD_URL "Subnautica-Archipelago-$SUB_MOD_VERSION.zip"
$tmp = Join-Path $env:TEMP ("hvik-archipelago\subnautica-" + (Get-Date -Format HHmmss))
Expand-Zip $z $tmp
# alte Mod-Version vorher weg, damit keine alten Dateien uebrig bleiben (Spielstaende liegen woanders)
$plugin = Join-Path $game "BepInEx\plugins\Archipelago"
if (Test-Path $plugin) { Remove-Item $plugin -Recurse -Force }
Copy-Item "$tmp\*" $game -Recurse -Force
if (-not (Test-Path (Join-Path $plugin "Archipelago.dll"))) { Fail "Mod fehlt nach dem Kopieren - beim Host melden." }
Ok "Mod installiert."

$name = Get-PlayerName
Set-SubConnection $game $name
Ok "Server $($HviK.Server) und Name $name in den Mod eingetragen."
Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: START.bat -> im Hauptmenue oben links steht alles drin -> Connect -> neues Spiel."
Say "Mods wieder aus: im Spielordner winhttp.dll loeschen."
