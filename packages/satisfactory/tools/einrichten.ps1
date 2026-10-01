# HviK Archipelago - Satisfactory einmalig einrichten: 7 Mods (SML, ContentLib, ..., Archipelago) direkt ins Spiel,
# ohne Satisfactory Mod Manager. Alle, die in derselben Fabrik mitspielen, brauchen genau diese Mods.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\satisfactory.ps1"

Say "[1/2] Satisfactory suchen ..."
$game = Find-SteamGame $SF_APPID
if (-not $game) { Fail "Satisfactory ist nicht installiert (Steam). Bitte erst installieren." }
if (-not (Test-Path (Join-Path $game "FactoryGame"))) { Fail "Spieldateien nicht gefunden - Satisfactory einmal normal starten, dann nochmal." }
Ok "Gefunden: $game"
Get-Process FactoryGame*, FactoryGameSteam* -ErrorAction SilentlyContinue | ForEach-Object { Fail "Satisfactory laeuft noch - bitte erst beenden." }

Say "[2/2] Mods (ca. 190 MB) ..."
$mods = Get-SfModsDir $game
New-Item -ItemType Directory -Force $mods | Out-Null
foreach ($m in $SF_MODS) {
    $target = Join-Path $mods $m.Ref
    $marker = Join-Path $target "hvik-version.txt"
    if ((Test-Path $marker) -and ((Get-Content $marker -Raw).Trim() -eq $m.Version)) { Ok "$($m.Ref) $($m.Version) ist schon da."; continue }
    $z = Get-File $m.Url "sf-$($m.Ref)-$($m.Version).zip"
    if ((Get-FileHash $z -Algorithm SHA256).Hash -ne $m.Sha) { Fail "Download von $($m.Ref) ist beschaedigt - nochmal versuchen." }
    if (Test-Path $target) { Remove-Item $target -Recurse -Force }
    Expand-Zip $z $target
    [IO.File]::WriteAllText($marker, $m.Version)
    Ok "$($m.Ref) $($m.Version) installiert."
}
if (-not (Test-Path (Join-Path $mods "Archipelago\Archipelago.uplugin"))) { Fail "Archipelago-Mod fehlt nach dem Entpacken - beim Host melden." }
Get-PlayerName | Out-Null

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: START.bat -> Neues Spiel -> unten rechts 'Mod Savegame Settings' -> Server + Name."
Say "Mitspieler in deiner Fabrik: brauchen dasselbe Paket (EINRICHTEN.bat) und treten ueber Steam bei."
Say "Mods wieder aus: Ordner FactoryGame\Mods im Spielordner umbenennen."
