# HviK Archipelago - CloverPit einmalig einrichten:
# BepInEx 5 (Mod-Loader) + CloverPit-Archipelago-Mod v1.2.2 von Syntheal direkt in den Spielordner.
# Archipelago selbst brauchst du NICHT - der Mod verbindet sich selbst.
. "$PSScriptRoot\hvik.ps1"
$BepInEx = "https://github.com/BepInEx/BepInEx/releases/download/v5.4.23.4/BepInEx_win_x64_5.4.23.4.zip"
$Mod = "https://github.com/Syntheal/CloverPit.Archipelago/releases/download/v1.2.2/Mods.zip"

Say "[1/3] CloverPit suchen ..."
$game = Find-SteamGame 3314790
if (-not $game) { Fail "CloverPit ist nicht installiert (Steam). Bitte erst installieren und einmal starten." }
Ok "Gefunden: $game"

Say "[2/3] BepInEx 5 (Mod-Loader) ..."
if ((Test-Path (Join-Path $game "BepInEx\core")) -and (Test-Path (Join-Path $game "winhttp.dll"))) {
    Ok "BepInEx ist schon da."
} else {
    Expand-Zip (Get-File $BepInEx "BepInEx5.zip") $game
    Ok "BepInEx installiert."
}

Say "[3/3] Archipelago-Mod (v1.2.2) ..."
$tmp = Join-Path $env:TEMP "hvik-archipelago\cloverpit-mod"
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
Expand-Zip (Get-File $Mod "CloverPit-Mod.zip") $tmp
$plugins = Join-Path $game "BepInEx\plugins"
New-Item -ItemType Directory -Force $plugins | Out-Null
Get-ChildItem (Join-Path $tmp "BepInEx\Plugins") -File | Copy-Item -Destination $plugins -Force
Ok "Mod installiert: $plugins"

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Der erste Start mit Mod dauert etwas laenger (BepInEx richtet sich ein)."
Say "Am Spieltag: START.bat doppelklicken."
Say "Mod wieder aus: im Spielordner winhttp.dll loeschen."
