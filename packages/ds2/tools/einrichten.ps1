# HviK Archipelago - Dark Souls II einmalig einrichten: Mod-DLL (v0.5.5-hotfix, passend zum HviK-Server)
# als dinput8.dll in den Game-Ordner. Scholar of the First Sin und Original werden beide erkannt.
. "$PSScriptRoot\hvik.ps1"
$Release = "https://github.com/WildBunnie/DarkSoulsII-Archipelago/releases/download/v0.5.5-hotfix"
$versions = @(
    @{ AppId = 335300; Name = "Scholar of the First Sin"; Dll = "dinput8_sotfs.dll" },
    @{ AppId = 236430; Name = "Original";                 Dll = "dinput8_vanilla.dll" }
)

$found = 0
foreach ($v in $versions) {
    $dir = Find-SteamGame $v.AppId
    if (-not $dir) { continue }
    $game = Join-Path $dir "Game"
    if (-not (Test-Path $game)) { $game = $dir }
    Say "Dark Souls II ($($v.Name)) gefunden: $game"
    $dll = Get-File "$Release/$($v.Dll)" $v.Dll
    $target = Join-Path $game "dinput8.dll"
    if ((Test-Path $target) -and -not (Test-Path "$target.vor-hvik")) { Copy-Item $target "$target.vor-hvik" }
    Copy-Item $dll $target -Force
    Ok "Mod installiert."
    $found++
}
if (-not $found) { Fail "Dark Souls II ist nicht installiert (Steam). Bitte erst installieren." }

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: START.bat doppelklicken. Mit dem Spiel geht eine Konsole auf -"
Say "den Verbinden-Befehl hat START.bat schon kopiert: dort Strg+V und Enter."
Say "Mod wieder weg: im Game-Ordner dinput8.dll loeschen."
