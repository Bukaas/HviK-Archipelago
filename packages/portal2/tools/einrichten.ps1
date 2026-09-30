# HviK Archipelago - Portal 2 einmalig einrichten:
# portal2.apworld in Archipelago + Mod-Ordner nach steamapps\sourcemods. Versionen passend zum HviK-Server.
. "$PSScriptRoot\hvik.ps1"
$Release = "https://github.com/GlassToadstool/Portal2ArchipelagoMod/releases/download/0.8.2"

Say "[1/3] Archipelago und Portal 2 suchen ..."
Test-Archipelago
if (-not (Find-SteamGame 620)) { Fail "Portal 2 ist nicht installiert (Steam). Bitte erst installieren." }
$steam = Get-SteamDir
Ok "Gefunden."

Say "[2/3] Portal-2-Client fuer Archipelago (portal2.apworld) ..."
$worlds = Join-Path $HviK.ApDir "custom_worlds"
New-Item -ItemType Directory -Force $worlds | Out-Null
$apworld = Get-File "$Release/portal2.apworld" "portal2.apworld"
Copy-Item $apworld (Join-Path $worlds "portal2.apworld") -Force
Ok "portal2.apworld installiert."

Say "[3/3] Portal 2 Archipelago Mod ..."
$zip = Get-File "$Release/Portal2Archipelago.zip" "Portal2Archipelago.zip"
$mods = Join-Path $steam "steamapps\sourcemods"
$target = Join-Path $mods "Portal2Archipelago"
if (Test-Path $target) { Remove-Item $target -Recurse -Force }
Expand-Zip $zip $mods
if (-not (Test-Path (Join-Path $target "GameInfo.txt"))) { Fail "Mod-Ordner fehlt nach dem Entpacken." }
Ok "Mod installiert: $target"

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: START.bat doppelklicken - Spiel und Client starten und verbinden sich."
Say "(Steam einmal neu starten, dann taucht auch 'Portal 2 Archipelago Mod' in der Bibliothek auf.)"
