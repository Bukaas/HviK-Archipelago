# HviK Archipelago - Monster Hunter: World einmalig einrichten:
# Spielstand sichern, .NET 8, Stracker's Loader + Performance Booster (aus deinen NexusMods-Downloads), MHWGenerator.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\mhw.ps1"

Say "[1/5] Monster Hunter: World suchen ..."
$game = Find-SteamGame $MHW_APPID
if (-not $game) { Fail "Monster Hunter: World ist nicht installiert (Steam). Bitte erst installieren." }
Ok "Gefunden: $game"
Get-Process MonsterHunterWorld -ErrorAction SilentlyContinue | ForEach-Object { Fail "Monster Hunter: World laeuft noch - bitte erst beenden." }

Say "[2/5] Spielstand sichern (der Mod ist Alpha) ..."
$steam = Get-SteamDir
$saves = @(Get-ChildItem (Join-Path $steam "userdata") -Directory -ErrorAction SilentlyContinue |
    ForEach-Object { foreach ($f in "SAVEDATA1000", "SAVEDATA") { Join-Path $_.FullName "$MHW_APPID\remote\$f" } } |
    Where-Object { Test-Path $_ })
$backup = Join-Path $HviK.Root ("spielstand-sicherung\" + (Get-Date -Format "yyyyMMdd-HHmmss"))
foreach ($sv in $saves) {
    New-Item -ItemType Directory -Force $backup | Out-Null
    $account = Split-Path (Split-Path (Split-Path (Split-Path $sv))) -Leaf   # Ordner userdata/<Steam-Account>/582010/remote
    Copy-Item $sv (Join-Path $backup "$account-$(Split-Path $sv -Leaf)") -Force
}
if ($saves) { Ok "Spielstand gesichert in $backup" } else { Say "Kein Spielstand gefunden - nichts zu sichern." }

Say "[3/5] .NET 8 (fuer den MHWGenerator) ..."
Install-DotNet8Desktop

Say "[4/5] Stracker's Loader + Performance Booster (NexusMods) ..."
$downloads = Join-Path $env:USERPROFILE "Downloads"
$missing = @()
foreach ($m in $MHW_NEXUS) {
    $file = Get-ChildItem $downloads, $HviK.Root -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -in ".zip", ".7z" -and $_.Name -match $m.Pattern } |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($file) {
        Expand-AnyArchive $file.FullName $game
        Ok "$($m.Name) installiert ($($file.Name))."
    } else {
        $missing += $m
    }
}
if ($missing) {
    Write-Host ""
    Say "Diese Mods gibt es nur auf NexusMods (dort einloggen, kostenloser Account reicht):" Yellow
    foreach ($m in $missing) { Say "  - $($m.Name)" Yellow; Start-Process $m.Url }
    Say "Ich habe die Seiten geoeffnet: jeweils bei 'Files' -> 'Manual Download' -> 'Slow Download'." Yellow
    Say "Die Dateien einfach im Downloads-Ordner lassen und EINRICHTEN.bat NOCHMAL starten." Yellow
    exit 1
}

Say "[5/5] MHWGenerator $MHW_GEN_VERSION ..."
$z = Get-File $MHW_GEN_URL "MHWGenerator-$MHW_GEN_VERSION.zip"
$tmp = Join-Path $env:TEMP ("hvik-archipelago\mhw-" + (Get-Date -Format HHmmss))
Expand-Zip $z $tmp
if (Test-Path $MHW_GEN_DIR) { Remove-Item $MHW_GEN_DIR -Recurse -Force }
Copy-Item (Join-Path $tmp "MHWGenerator") $MHW_GEN_DIR -Recurse -Force
if (-not (Test-Path $MHW_GEN_EXE)) { Fail "MHWGenerator fehlt nach dem Entpacken - beim Host melden." }
Ok "MHWGenerator liegt in $MHW_GEN_DIR"
Get-PlayerName | Out-Null

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: START.bat -> im Generator Server + Name -> Connect -> danach startet das Spiel."
Say "Zurueck zum normalen Spiel: im Spielordner unter nativePC alles ausser 'plugins' loeschen."
