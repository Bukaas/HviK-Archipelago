# HviK Archipelago - Slime Rancher 2 einmalig einrichten:
# BepInEx 6 IL2CPP (Build be.755 - neuere Builds laden den Mod nicht) + SlimeRancher2-AP v0.15.0 von Rhelys.
# Archipelago selbst brauchst du NICHT - der Mod verbindet sich selbst.
. "$PSScriptRoot\hvik.ps1"
$BepInEx = "https://builds.bepinex.dev/projects/bepinex_be/755/BepInEx-Unity.IL2CPP-win-x64-6.0.0-be.755%2B3fab71a.zip"
$Mod = "https://github.com/Rhelys/SlimeRancher2-AP/releases/download/v0.15.0/SlimeRancher2-AP.zip"

Say "[1/3] Slime Rancher 2 suchen ..."
$game = Find-SteamGame 1657630
if (-not $game) { Fail "Slime Rancher 2 ist nicht installiert (Steam). Bitte erst installieren und einmal starten." }
Ok "Gefunden: $game"

Say "[2/3] BepInEx 6 (be.755, Mod-Loader) ..."
$core = Join-Path $game "BepInEx\core"
if ((Test-Path $core) -and (Get-ChildItem $core -Filter "BepInEx.Unity.IL2CPP.dll" -ErrorAction SilentlyContinue)) {
    Ok "BepInEx 6 ist schon da."
} else {
    Expand-Zip (Get-File $BepInEx "BepInEx6-be755.zip") $game
    Ok "BepInEx installiert."
}

Say "[3/3] Archipelago-Mod (v0.15.0) ..."
$ziel = Join-Path $game "BepInEx\plugins\SlimeRancher2-AP"
if (Test-Path $ziel) { Remove-Item $ziel -Recurse -Force }
Expand-Zip (Get-File $Mod "SlimeRancher2-AP.zip") $ziel
Ok "Mod installiert: $ziel"

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "WICHTIG: Der ERSTE Start mit Mod dauert mehrere Minuten (BepInEx baut seine Dateien)." Yellow
Say "Am besten jetzt einmal starten, bis zum Hauptmenue warten und wieder schliessen."
Say "Am Spieltag: START.bat doppelklicken."
Say "Mod wieder aus: im Spielordner winhttp.dll loeschen."
