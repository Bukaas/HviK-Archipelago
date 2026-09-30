# HviK Archipelago - Risk of Rain 2 einmalig einrichten, ohne Mod-Manager:
# BepInExPack + HookGenPatcher + R2API + InLobbyConfig + ScrollableLobbyUI + Archipelago-Mod 1.1.3 direkt ins Spiel.
# (Genau die Abhaengigkeiten, die der Mod auf Thunderstore angibt.)
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\ror2.ps1"
$Ts = "https://thunderstore.io/package/download"

Say "[1/4] Risk of Rain 2 suchen ..."
$game = Find-SteamGame $ROR2_APPID
if (-not $game) { Fail "Risk of Rain 2 ist nicht installiert (Steam). Bitte erst installieren." }
Ok "Gefunden: $game"
$tmp = Join-Path $env:TEMP ("hvik-archipelago\ror2-" + (Get-Date -Format HHmmss))
New-Item -ItemType Directory -Force $tmp | Out-Null
$plugins = Join-Path $game "BepInEx\plugins"

Say "[2/4] BepInEx (Mod-Loader) ..."
$z = Get-File "$Ts/bbepis/BepInExPack/5.4.2101/" "BepInExPack-5.4.2101.zip"
Expand-Zip $z "$tmp\bepinex"
Copy-Item "$tmp\bepinex\BepInExPack\*" $game -Recurse -Force
Ok "BepInEx installiert."

Say "[3/4] Hilfs-Mods (HookGenPatcher, R2API, InLobbyConfig, ScrollableLobbyUI) ..."
$z = Get-File "$Ts/RiskofThunder/HookGenPatcher/1.2.3/" "HookGenPatcher-1.2.3.zip"
Expand-Zip $z "$tmp\hookgen"
Copy-Item "$tmp\hookgen\BepInEx\*" (Join-Path $game "BepInEx") -Recurse -Force
New-Item -ItemType Directory -Force $plugins | Out-Null
foreach ($p in @("tristanmcpherson/R2API/4.4.1", "KingEnderBrine/InLobbyConfig/1.4.0", "KingEnderBrine/ScrollableLobbyUI/1.7.1")) {
    $n = ($p -split "/")[1]
    $z = Get-File "$Ts/$p/" "$n.zip"
    Expand-Zip $z "$tmp\$n"
    Copy-Item "$tmp\$n\plugins\*" $plugins -Recurse -Force
}
Ok "Hilfs-Mods installiert."

Say "[4/4] Archipelago-Mod 1.1.3 ..."
$z = Get-File "$Ts/ArchipelagoMW/Archipelago/1.1.3/" "Archipelago-RoR2-1.1.3.zip"
Expand-Zip $z "$tmp\ap"
$target = Join-Path $plugins "ArchipelagoMW-Archipelago"
New-Item -ItemType Directory -Force $target | Out-Null
Get-ChildItem "$tmp\ap" -File | Where-Object { $_.Extension -in ".dll", ".pdb" } | Copy-Item -Destination $target -Force
if (-not (Test-Path (Join-Path $target "Archipelago.RiskOfRain2.dll"))) { Fail "Archipelago-Mod fehlt nach dem Kopieren - beim Host melden." }
Ok "Archipelago-Mod installiert."

$name = Get-PlayerName
Set-Ror2Connection $game $name
Ok "Server $($HviK.Server) und Name $name in den Mod eingetragen."

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: START.bat -> in der Lobby stehen Server/Port/Name schon drin -> 'Connect to AP'."
Say "Mods wieder aus: im Spielordner winhttp.dll loeschen (dann startet das Spiel normal)."
