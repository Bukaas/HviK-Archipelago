# HviK Archipelago - Hollow Knight einmalig einrichten, ohne Mod-Manager:
# Modding API (1.5.78) + Archipelago-Mod mit ItemChanger, MenuChanger, Benchwarp, QoL, Vasi direkt ins Spiel.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\hk.ps1"

Say "WICHTIG: Die Mods laufen nur mit Hollow Knight 1.5.78 - sonst stuerzt das Spiel sofort ab." Yellow
Say "  In Steam: Rechtsklick Hollow Knight -> Eigenschaften -> Spielversionen & Betas" Yellow
Say "  -> '1.5.78.11833 - Previous version' waehlen und warten, bis Steam fertig ist." Yellow
Write-Host ""
Say "[1/3] Hollow Knight suchen ..."
$game = Find-SteamGame $HK_APPID
if (-not $game) { Fail "Hollow Knight ist nicht installiert (Steam). Bitte erst installieren." }
$managed = Get-HkManaged $game
if (-not (Test-Path (Join-Path $managed "Assembly-CSharp.dll"))) { Fail "Spieldateien nicht gefunden ($managed) - in Steam 'Dateien ueberpruefen' und nochmal versuchen." }
Ok "Gefunden: $game"
Get-Process hollow_knight -ErrorAction SilentlyContinue | ForEach-Object { Fail "Hollow Knight laeuft noch - bitte erst beenden." }
$tmp = Join-Path $env:TEMP ("hvik-archipelago\hk-" + (Get-Date -Format HHmmss))
New-Item -ItemType Directory -Force $tmp | Out-Null

Say "[2/3] Modding API ..."
$z = Get-File $HK_API_URL "moddingapi.v77.windows.zip"
if (-not (Test-Sha $z $HK_API_SHA)) { Fail "Download der Modding API ist beschaedigt - nochmal versuchen." }
Expand-Zip $z "$tmp\api"
$dll = Join-Path $managed "Assembly-CSharp.dll"
$apiHash = (Get-FileHash "$tmp\api\Assembly-CSharp.dll" -Algorithm SHA256).Hash
# Original-Spieldatei einmal sichern (wie Scarab: Assembly-CSharp.dll.v), damit man zurueck kann
$backup = "$dll.v"
if ((Get-FileHash $dll -Algorithm SHA256).Hash -ne $apiHash -and -not (Test-Path $backup)) {
    Copy-Item $dll $backup -Force
    Say "Original gesichert: Assembly-CSharp.dll.v"
}
Get-ChildItem "$tmp\api" -File | Where-Object { $_.Extension -eq ".dll" } | Copy-Item -Destination $managed -Force
Ok "Modding API installiert."

Say "[3/3] Archipelago-Mod + Hilfs-Mods ..."
$mods = Join-Path $managed "Mods"
New-Item -ItemType Directory -Force $mods | Out-Null
foreach ($m in $HK_MODS) {
    $z = Get-File $m.Url "hk-$($m.Name).zip"
    if (-not (Test-Sha $z $m.Sha)) { Fail "Download von $($m.Name) ist beschaedigt - nochmal versuchen." }
    $target = Join-Path $mods $m.Name
    if (Test-Path $target) { Remove-Item $target -Recurse -Force }
    Expand-Zip $z $target
}
if (-not (Test-Path (Join-Path $mods "Archipelago\Archipelago.HollowKnight.dll"))) { Fail "Archipelago-Mod fehlt nach dem Kopieren - beim Host melden." }
Ok "Archipelago, ItemChanger, MenuChanger, Benchwarp, QoL, Vasi installiert."

$name = Get-PlayerName
Set-HkConnection $name
Ok "Server $($HviK.Server) und Name $name in den Mod eingetragen."

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: START.bat -> Neues Spiel -> Modus 'Archipelago' -> Start."
Say "Mods wieder aus: in Steam bei Hollow Knight 'Dateien auf Fehler ueberpruefen'."
