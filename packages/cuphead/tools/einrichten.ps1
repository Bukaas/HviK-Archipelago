# HviK Archipelago - Cuphead einmalig einrichten: BepInEx 5 (x64) + CupheadArchipelago-Mod direkt ins Spiel.
# Archipelago selbst brauchst du nicht - der Mod verbindet sich direkt mit dem Server.
. "$PSScriptRoot\hvik.ps1"
$CUP_APPID = 268910
$CUP_MOD_VERSION = "alpha04a.3"

Say "[1/3] Cuphead suchen ..."
$game = Find-SteamGame $CUP_APPID
if (-not $game) { Fail "Cuphead ist nicht installiert (Steam). Bitte erst installieren." }
Ok "Gefunden: $game"
$tmp = Join-Path $env:TEMP ("hvik-archipelago\cuphead-" + (Get-Date -Format HHmmss))
New-Item -ItemType Directory -Force $tmp | Out-Null

Say "[2/3] BepInEx (Mod-Loader) ..."
$z = Get-File "https://github.com/BepInEx/BepInEx/releases/download/v5.4.23.5/BepInEx_win_x64_5.4.23.5.zip" "BepInEx_win_x64_5.4.23.5.zip"
Expand-Zip $z "$tmp\bepinex"
Copy-Item "$tmp\bepinex\*" $game -Recurse -Force
Ok "BepInEx installiert."

Say "[3/3] CupheadArchipelago-Mod $CUP_MOD_VERSION ..."
$z = Get-File "https://github.com/JKLeckr/CupheadArchipelagoMod/releases/download/$CUP_MOD_VERSION/CupheadArchipelago-$($CUP_MOD_VERSION)_win64.zip" "CupheadArchipelago-$CUP_MOD_VERSION.zip"
Expand-Zip $z "$tmp\mod"
$plugins = Join-Path $game "BepInEx\plugins"
$target = Join-Path $plugins "CupheadArchipelago"
New-Item -ItemType Directory -Force $plugins | Out-Null
# alte Mod-Version komplett ersetzen (Spielstaende liegen woanders und bleiben)
if (Test-Path $target) { Remove-Item $target -Recurse -Force }
Copy-Item "$tmp\mod\CupheadArchipelago" $plugins -Recurse -Force
if (-not (Test-Path (Join-Path $target "CupheadArchipelago.dll"))) { Fail "Mod fehlt nach dem Kopieren - beim Host melden." }
Ok "Mod installiert."

Get-PlayerName | Out-Null
Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: START.bat doppelklicken - dort steht, was du im Spiel eintragen musst."
Say "Mods wieder aus: im Spielordner winhttp.dll loeschen (dann startet das Spiel normal)."
