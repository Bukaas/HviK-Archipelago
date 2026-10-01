# HviK Archipelago - Pokemon einmalig einrichten:
# ggf. apworld in Archipelago, BizHawk 2.9.1 (portable) in diesen Ordner, und Archipelago so einstellen,
# dass es nach dem Patchen BizHawk mit dem Verbindungs-Skript startet.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\pokemon.ps1"

Say "[1/3] Archipelago ..."
Test-Archipelago
if ($POKE_APWORLD) {
    $name = Split-Path $POKE_APWORLD -Leaf
    $apw = Get-File $POKE_APWORLD $name
    New-Item -ItemType Directory -Force (Join-Path $HviK.ApDir "custom_worlds") | Out-Null
    Copy-Item $apw (Join-Path $HviK.ApDir "custom_worlds\$name") -Force
    Ok "$POKE_NAME-Erweiterung ($name) installiert."
} else {
    Ok "$POKE_NAME ist in Archipelago schon eingebaut."
}

Say "[2/3] BizHawk $POKE_BIZ_VERSION (Emulator, ca. 65 MB) ..."
$verFile = Join-Path $POKE_BIZ "hvik-version.txt"
$haveVer = if (Test-Path $verFile) { (Get-Content $verFile -Raw).Trim() } elseif (Test-Path $POKE_EMUHAWK) { "alt" } else { "" }
$oldBiz = $null
if ($haveVer -and $haveVer -ne $POKE_BIZ_VERSION) {
    # andere BizHawk-Version: zur Seite legen, Spielstaende (SaveRAM der Handheld-Systeme) gleich uebernehmen
    $oldBiz = "$POKE_BIZ-$haveVer-" + (Get-Date -Format "yyyyMMdd-HHmmss")
    Get-Process EmuHawk -ErrorAction SilentlyContinue | Stop-Process -Force
    Move-Item $POKE_BIZ $oldBiz
    Say "Alte BizHawk-Version liegt jetzt in $oldBiz (kann spaeter geloescht werden)."
}
if (-not (Test-Path $POKE_EMUHAWK)) {
    $z = Get-File $POKE_BIZ_URL "BizHawk-$POKE_BIZ_VERSION-win-x64.zip"
    Expand-Zip $z $POKE_BIZ
}
if (-not (Test-Path $POKE_EMUHAWK)) { Fail "BizHawk konnte nicht entpackt werden - beim Host melden." }
# BizHawk 2.9.1 braucht die Microsoft Visual C++ 2010 SP1 Runtime (x64) - fehlt auf neuen PCs oft
if (-not (Test-Path (Join-Path $env:SystemRoot "System32\msvcr100.dll"))) {
    $vc = Get-File "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe" "vcredist2010_x64.exe"
    Say "Installiere Microsoft Visual C++ 2010 (x64) fuer BizHawk (Windows fragt evtl. nach Erlaubnis) ..."
    $p = Start-Process $vc -ArgumentList "/q", "/norestart" -Verb RunAs -Wait -PassThru
    if ($p.ExitCode -notin 0, 3010, 1638) { Fail "Visual C++ 2010 konnte nicht installiert werden (Code $($p.ExitCode))." }
    Ok "Visual C++ 2010 installiert."
}
if ($oldBiz) {
    foreach ($sys in "GB", "GBC", "GBA") {
        $old = Join-Path $oldBiz "$sys\SaveRAM"
        if (Test-Path $old) {
            New-Item -ItemType Directory -Force (Join-Path $POKE_BIZ $sys) | Out-Null
            Copy-Item $old (Join-Path $POKE_BIZ $sys) -Recurse -Force
        }
    }
    Ok "Spielstaende aus der alten Version uebernommen."
}
[IO.File]::WriteAllText($verFile, $POKE_BIZ_VERSION)
# Im Hintergrund weiterlaufen + Eingaben annehmen, SaveRAM automatisch sichern (nur beim allerersten Mal)
$cfg = Join-Path $POKE_BIZ "config.ini"
if (-not (Test-Path $cfg)) {
    [IO.File]::WriteAllText($cfg, '{"RunInBackground":true,"AcceptBackgroundInput":true,"AutosaveSaveRAM":true,"FlushSaveRamFrames":300}', (New-Object Text.UTF8Encoding $false))
}
Ok "BizHawk liegt in $POKE_BIZ"

Say "[3/3] Archipelago-Einstellung (host.yaml) ..."
$hostYaml = Join-Path $HviK.ApDir "host.yaml"
if (-not (Test-Path $hostYaml)) {
    Say "Archipelago wird einmal kurz gestartet, damit es seine Einstellungen anlegt ..."
    Start-Process (Join-Path $HviK.ApDir "ArchipelagoLauncher.exe"); Start-Sleep -Seconds 8
    Get-Process ArchipelagoLauncher -ErrorAction SilentlyContinue | Stop-Process -Force
}
Set-HostYamlValue $hostYaml "bizhawkclient_options" "emuhawk_path" ('"' + $POKE_EMUHAWK.Replace('\', '\\') + '"')
Set-HostYamlValue $hostYaml "bizhawkclient_options" "rom_start" "true"
Ok "Nach dem Patchen startet Archipelago jetzt BizHawk mit dem Verbindungs-Skript."

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: deine Datei auf hvik.org laden (oder das Startpaket) und START.bat doppelklicken."
Say "Beim allerersten Mal fragt Archipelago nach deiner ROM: $POKE_ROM"
