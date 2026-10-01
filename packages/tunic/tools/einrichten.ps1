# HviK Archipelago - TUNIC einmalig einrichten: BepInEx 6 (IL2CPP) + TUNIC Randomizer 4.2.7 direkt ins Spiel.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\tunic.ps1"

Say "[1/4] TUNIC suchen ..."
$game = Find-SteamGame $TUNIC_APPID
if (-not $game) { Fail "TUNIC ist nicht installiert (Steam). Bitte erst installieren." }
Ok "Gefunden: $game"
$tmp = Join-Path $env:TEMP ("hvik-archipelago\tunic-" + (Get-Date -Format HHmmss))

Say "[2/4] BepInEx 6 (Mod-Loader) ..."
if (-not (Test-Path (Join-Path $game "BepInEx\core"))) {
    $z = Get-File $TUNIC_BEPINEX_URL "BepInEx_UnityIL2CPP_x64_6.0.0-pre.1.zip"
    Expand-Zip $z "$tmp\bepinex"
    Copy-Item "$tmp\bepinex\*" $game -Recurse -Force
}
Ok "BepInEx installiert."

Say "[3/4] TUNIC Randomizer $TUNIC_MOD_VERSION ..."
$z = Get-File $TUNIC_MOD_URL "TunicRandomizer-$TUNIC_MOD_VERSION.zip"
Expand-Zip $z "$tmp\mod"
$plugins = Join-Path $game "BepInEx\plugins"
$target = Join-Path $plugins "Tunic Randomizer"
New-Item -ItemType Directory -Force $plugins | Out-Null
if (Test-Path $target) { Remove-Item $target -Recurse -Force }
Copy-Item "$tmp\mod\Tunic Randomizer" $plugins -Recurse -Force
if (-not (Test-Path (Join-Path $target "TunicRandomizer.dll"))) { Fail "Mod fehlt nach dem Kopieren - beim Host melden." }
Ok "Randomizer installiert."

Say "[4/4] Erster Start ..."
$name = Get-PlayerName
$settings = Find-TunicSettings
if ($settings) {
    Set-TunicConnection $settings $name
    Ok "Server $($HviK.Server) und Name $name in den Mod eingetragen."
} else {
    Say "TUNIC muss EINMAL mit Mod starten (der Mod-Loader richtet sich dabei ein - das erste Mal dauert" Cyan
    Say "ein paar Minuten, das Fenster bleibt evtl. schwarz). Warten, bis oben links 'Randomizer Mod Ver. $TUNIC_MOD_VERSION'" Cyan
    Say "steht, dann TUNIC schliessen. START.bat traegt danach alles ein." Cyan
    Start-Process "steam://rungameid/$TUNIC_APPID"
}
Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: START.bat -> Titelbild zeigt 'Status: Connected!' -> neues Spiel."
Say "Mods wieder aus: im Spielordner winhttp.dll loeschen."
