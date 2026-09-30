# HviK Archipelago - Twilight Princess einmalig einrichten:
# Twilight Princess.apworld v0.3.0 in Archipelago, Dolphin 2503a (portable) mit GCI-Ordner als Speicherkarte A,
# die drei GCI-Dateien (US) hinein, ISO einmal auswaehlen.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\tp.ps1"

if ($HviK.Root -match "(?i)OneDrive") {
    Fail "Dieser Ordner liegt in OneDrive - damit kann sich der Client nicht mit Dolphin verbinden. Bitte das Paket z.B. nach C:\Spiele\HviK-TwilightPrincess verschieben und EINRICHTEN.bat dort nochmal starten."
}

Say "[1/4] Archipelago + Twilight-Princess-Client ..."
Test-Archipelago
$z = Get-File $TP_APWORLD_URL "Twilight_Princess_apworld-v0.3.0.zip"
$tmp = Join-Path $env:TEMP ("hvik-archipelago\tp-" + (Get-Date -Format HHmmss))
Expand-Zip $z $tmp
$worlds = Join-Path $HviK.ApDir "custom_worlds"
New-Item -ItemType Directory -Force $worlds | Out-Null
Copy-Item (Join-Path $tmp "Twilight Princess.apworld") (Join-Path $worlds "Twilight Princess.apworld") -Force
Ok "Twilight Princess.apworld installiert."

Say "[2/4] Dolphin $TP_DOLPHIN_VERSION (Emulator) ..."
$verFile = Join-Path $TP_DOLPHIN "hvik-version.txt"
$haveVer = if (Test-Path $verFile) { (Get-Content $verFile -Raw).Trim() } elseif (Test-Path (Join-Path $TP_DOLPHIN "Dolphin.exe")) { "alt" } else { "" }
$oldDir = $null
if ($haveVer -and $haveVer -ne $TP_DOLPHIN_VERSION) {
    # andere Dolphin-Version im Ordner: zur Seite legen, Speicherstaende/Einstellungen (User) gleich uebernehmen
    $oldDir = "$TP_DOLPHIN-$haveVer-" + (Get-Date -Format "yyyyMMdd-HHmmss")
    Get-Process Dolphin -ErrorAction SilentlyContinue | Stop-Process -Force
    Move-Item $TP_DOLPHIN $oldDir
    Say "Alte Dolphin-Version liegt jetzt in $oldDir (kann spaeter geloescht werden)."
}
if (-not (Test-Path (Join-Path $TP_DOLPHIN "Dolphin.exe"))) {
    $out = Join-Path $env:TEMP "hvik-archipelago\dolphin-$TP_DOLPHIN_VERSION-x64.7z"
    New-Item -ItemType Directory -Force (Split-Path $out) | Out-Null
    Say "Lade Dolphin $TP_DOLPHIN_VERSION ..."
    try { Invoke-WebRequest -Uri $TP_DOLPHIN_URL -OutFile $out -UseBasicParsing -UserAgent "Mozilla/5.0" }
    catch { Fail "Dolphin-Download fehlgeschlagen. Internet da? Sonst beim Host melden." }
    # Windows 11 kann .7z mit dem eingebauten tar entpacken, Windows 10 nicht (kein LZMA) ->
    # dann das offizielle Mini-Entpackprogramm 7zr.exe von 7-zip.org nehmen.
    try { & tar -xf $out -C $HviK.Root 2>$null } catch { }
    if (-not (Test-Path (Join-Path $TP_DOLPHIN "Dolphin.exe"))) {
        Say "Windows kann das nicht selbst entpacken - nehme 7-Zip (7zr.exe) ..."
        $sevenZip = Join-Path $env:TEMP "hvik-archipelago\7zr.exe"
        try { Invoke-WebRequest -Uri "https://www.7-zip.org/a/7zr.exe" -OutFile $sevenZip -UseBasicParsing -UserAgent "Mozilla/5.0" }
        catch { Fail "7-Zip-Download fehlgeschlagen. Internet da? Sonst beim Host melden." }
        & $sevenZip x $out "-o$($HviK.Root)" -y | Out-Null
    }
    if (-not (Test-Path (Join-Path $TP_DOLPHIN "Dolphin.exe"))) { Fail "Dolphin konnte nicht entpackt werden - beim Host melden." }
}
if ($oldDir -and (Test-Path (Join-Path $oldDir "User"))) {
    Copy-Item (Join-Path $oldDir "User") $TP_DOLPHIN -Recurse -Force
    Ok "Speicherstaende und Einstellungen aus der alten Version uebernommen."
}
[IO.File]::WriteAllText($verFile, $TP_DOLPHIN_VERSION)
# portable.txt: Dolphin nimmt seine Einstellungen aus Dolphin-x64\User statt aus dem Benutzerprofil
New-Item -ItemType File -Force (Join-Path $TP_DOLPHIN "portable.txt") | Out-Null
Set-DolphinGciSlot
Ok "Dolphin liegt in $TP_DOLPHIN (Speicherkarte A = GCI-Ordner)."

Say "[3/4] Speicherstaende (REL Loader, Randomizer, APTest) ..."
$gci = Join-Path $HviK.Root "gci"
if (-not (Get-ChildItem $gci -Recurse -Filter *.gci -ErrorAction SilentlyContinue)) { Fail "Die GCI-Dateien fehlen im Paket - beim Host melden." }
foreach ($region in "USA", "EUR", "JAP") {
    $src = Join-Path $gci $region
    if (-not (Test-Path $src)) { continue }
    $dst = Get-TpGciDir $region
    New-Item -ItemType Directory -Force $dst | Out-Null
    # alte Randomizer-Versionen stoeren (Sieg wird sonst nicht gesendet)
    Get-ChildItem $dst -Filter "Randomizer-1.*.gci" -ErrorAction SilentlyContinue | Move-Item -Destination { "$($_.FullName).alt" } -Force
    Copy-Item (Join-Path $src "*.gci") $dst -Force
}
Ok "Speicherstaende fuer USA, Europa und Japan eingerichtet."

Say "[4/4] Deine Twilight Princess ISO (GameCube) ..."
$iso = Get-TpIso
if ($iso) { Ok "Schon gewaehlt: $iso" }
else {
    Say "Gleich geht ein Fenster auf: deine Twilight Princess ISO (GameCube-Version) auswaehlen." Cyan
    $iso = Select-TpIso
    if ($iso) { Ok "Gemerkt: $iso" } else { Say "Keine ISO gewaehlt - START.bat oeffnet Dolphin dann ohne Spiel." Yellow }
}

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: START.bat doppelklicken."
