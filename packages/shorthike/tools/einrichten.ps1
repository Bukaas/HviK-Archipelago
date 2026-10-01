# HviK Archipelago - A Short Hike einmalig einrichten (wie der "Short Hike Mod Installer", nur automatisch):
# Modding-Werkzeuge (BepInEx) in den Spielordner, dann Modding API + Randomizer in den Ordner "Modding".
. "$PSScriptRoot\hvik.ps1"
$ASH_APPID = 1055540
$ASH_TOOLS_URL = "https://github.com/BrandenEK/AShortHike.ModdingTools/raw/main/win32.zip"
$ASH_MODS = @(
    @{ Name = "ModdingAPI"; Url = "https://github.com/BrandenEK/AShortHike.ModdingAPI/releases/download/1.0.1/ModdingAPI.zip" },
    @{ Name = "Randomizer"; Url = "https://github.com/BrandenEK/AShortHike.Randomizer/releases/download/1.5.1/Randomizer.zip" }
)

Say "[1/3] A Short Hike suchen ..."
$game = Find-SteamGame $ASH_APPID
if (-not $game) { Fail "A Short Hike ist nicht installiert (Steam). Bitte erst installieren." }
Ok "Gefunden: $game"
$tmp = Join-Path $env:TEMP ("hvik-archipelago\shorthike-" + (Get-Date -Format HHmmss))

Say "[2/3] Modding-Werkzeuge ..."
$z = Get-File $ASH_TOOLS_URL "AShortHike-ModdingTools-win32.zip"
Expand-Zip $z "$tmp\tools"
Copy-Item "$tmp\tools\*" $game -Recurse -Force
$modding = Join-Path $game "Modding"
if (-not (Test-Path $modding)) { Fail "Ordner 'Modding' fehlt nach dem Entpacken - beim Host melden." }
Ok "Modding-Werkzeuge installiert."

Say "[3/3] Modding API 1.0.1 + Randomizer 1.5.1 ..."
foreach ($m in $ASH_MODS) {
    $z = Get-File $m.Url "AShortHike-$($m.Name).zip"
    Expand-Zip $z "$tmp\$($m.Name)"
    Copy-Item "$tmp\$($m.Name)\*" $modding -Recurse -Force
}
if (-not (Test-Path (Join-Path $modding "plugins\Randomizer.dll"))) { Fail "Randomizer fehlt nach dem Kopieren - beim Host melden." }
Ok "Randomizer installiert."
Get-PlayerName | Out-Null

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: START.bat -> neues Spiel -> im Fenster Server, Name eintragen -> Connect."
