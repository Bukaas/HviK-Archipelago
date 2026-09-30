# HviK Archipelago - ULTRAKILL einmalig einrichten, ohne Mod-Manager:
# BepInEx 5 + PluginConfigurator + Archipelago-Mod 3.5.6 (passend zum HviK-Server) direkt in den Spielordner.
. "$PSScriptRoot\hvik.ps1"
$Parts = @(
    @{ Name = "BepInEx";            Url = "https://thunderstore.io/package/download/BepInEx/BepInExPack/5.4.2100/" },
    @{ Name = "PluginConfigurator"; Url = "https://thunderstore.io/package/download/EternalsTeam/PluginConfigurator/1.10.2/" },
    @{ Name = "Archipelago-Mod";    Url = "https://github.com/TRPG0/ArchipelagoULTRAKILL/releases/download/3.5.6/ArchipelagoULTRAKILL.3.5.6.zip" }
)

Say "[1/4] ULTRAKILL suchen ..."
$game = Find-SteamGame 1229490
if (-not $game) { Fail "ULTRAKILL ist nicht installiert (Steam). Bitte erst installieren." }
Ok "Gefunden: $game"
$tmp = Join-Path $env:TEMP "hvik-archipelago\ultrakill"
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
$plugins = Join-Path $game "BepInEx\plugins"

Say "[2/4] BepInEx (Mod-Loader) ..."
$z = Get-File $Parts[0].Url "BepInExPack.zip"
Expand-Zip $z "$tmp\bepinex"
Copy-Item "$tmp\bepinex\BepInExPack\*" $game -Recurse -Force
Ok "BepInEx installiert."

Say "[3/4] PluginConfigurator (Einstellungsmenue fuer Mods) ..."
$z = Get-File $Parts[1].Url "PluginConfigurator.zip"
Expand-Zip $z "$tmp\pc"
New-Item -ItemType Directory -Force $plugins | Out-Null
Copy-Item "$tmp\pc\plugins\PluginConfigurator" $plugins -Recurse -Force
Ok "PluginConfigurator installiert."

Say "[4/4] Archipelago-Mod ..."
$z = Get-File $Parts[2].Url "ArchipelagoULTRAKILL.zip"
Expand-Zip $z "$tmp\ap"
$target = Join-Path $plugins "TRPG-Archipelago"
if (Test-Path $target) { Remove-Item $target -Recurse -Force }
Copy-Item "$tmp\ap\TRPG-Archipelago" $plugins -Recurse -Force
Ok "Archipelago-Mod installiert."

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: START.bat doppelklicken, neuen Spielstand waehlen, dann verbinden."
Say "Mod wieder weg: im Spielordner winhttp.dll loeschen (schaltet alle Mods aus)."
