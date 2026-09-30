# HviK Archipelago - Ocarina of Time einmalig einrichten:
# BizHawk 2.9.1 (portable) in diesen Ordner, Grundeinstellungen setzen und Archipelago sagen, dass es nach dem Patchen
# BizHawk MIT dem Verbindungs-Skript connector_oot.lua startet (host.yaml -> oot_options.rom_start = unser Starter).
. "$PSScriptRoot\hvik.ps1"
# 2.9.1 statt 2.10: connector_oot.lua aus Archipelago 0.6.7 kennt 2.10 nicht ("newer than we know about") -
# es liest dann falsche Speicherstellen, der Client meldet sich nie an und das Spiel ruckelt durch die Warnungen.
$BizVer = "2.9.1"
$BizUrl = "https://github.com/TASEmulators/BizHawk/releases/download/$BizVer/BizHawk-$BizVer-win-x64.zip"
$biz = Join-Path $HviK.Root "BizHawk"

Say "[1/4] Archipelago ..."
Test-Archipelago
$lua = Join-Path $HviK.ApDir "data\lua\connector_oot.lua"
if (-not (Test-Path $lua)) { Fail "connector_oot.lua fehlt in Archipelago - bitte Archipelago 0.6.7 neu installieren." }
Ok "Archipelago gefunden."

Say "[2/4] BizHawk $BizVer (Emulator, ca. 65 MB) ..."
$verFile = Join-Path $biz "hvik-version.txt"
$haveVer = if (Test-Path $verFile) { (Get-Content $verFile -Raw).Trim() } elseif (Test-Path (Join-Path $biz "EmuHawk.exe")) { "alt" } else { "" }
$oldBiz = $null
if ($haveVer -and $haveVer -ne $BizVer) {
    # andere BizHawk-Version: zur Seite legen, Spielstaende (N64\SaveRAM) gleich uebernehmen
    $oldBiz = "$biz-$haveVer-" + (Get-Date -Format "yyyyMMdd-HHmmss")
    Get-Process EmuHawk -ErrorAction SilentlyContinue | Stop-Process -Force
    Move-Item $biz $oldBiz
    Say "Alte BizHawk-Version liegt jetzt in $oldBiz (kann spaeter geloescht werden)."
}
if (-not (Test-Path (Join-Path $biz "EmuHawk.exe"))) {
    $z = Get-File $BizUrl "BizHawk-$BizVer-win-x64.zip"
    Expand-Zip $z $biz
}
if (-not (Test-Path (Join-Path $biz "EmuHawk.exe"))) { Fail "BizHawk konnte nicht entpackt werden - beim Host melden." }
# BizHawk 2.9.1 braucht die Microsoft Visual C++ 2010 SP1 Runtime (x64) - fehlt auf neuen PCs oft
if (-not (Test-Path (Join-Path $env:SystemRoot "System32\msvcr100.dll"))) {
    $vc = Get-File "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe" "vcredist2010_x64.exe"
    Say "Installiere Microsoft Visual C++ 2010 (x64) fuer BizHawk (Windows fragt evtl. nach Erlaubnis) ..."
    $p = Start-Process $vc -ArgumentList "/q", "/norestart" -Verb RunAs -Wait -PassThru
    # 3010 = Neustart empfohlen, 1638 = neuere Version schon da
    if ($p.ExitCode -notin 0, 3010, 1638) { Fail "Visual C++ 2010 konnte nicht installiert werden (Code $($p.ExitCode))." }
    Ok "Visual C++ 2010 installiert."
}
if ($oldBiz -and (Test-Path (Join-Path $oldBiz "N64\SaveRAM"))) {
    New-Item -ItemType Directory -Force (Join-Path $biz "N64") | Out-Null
    Copy-Item (Join-Path $oldBiz "N64\SaveRAM") (Join-Path $biz "N64") -Recurse -Force
    Ok "Spielstaende aus der alten Version uebernommen."
}
[IO.File]::WriteAllText($verFile, $BizVer)
# Grundeinstellungen aus der OoT-Anleitung: im Hintergrund weiterlaufen + Eingaben annehmen, SaveRAM automatisch sichern.
# Nur beim allerersten Mal (spaetere eigene Einstellungen nicht ueberschreiben).
$cfg = Join-Path $biz "config.ini"
if (-not (Test-Path $cfg)) {
    [IO.File]::WriteAllText($cfg, '{"RunInBackground":true,"AcceptBackgroundInput":true,"AutosaveSaveRAM":true,"FlushSaveRamFrames":300}', (New-Object Text.UTF8Encoding $false))
}
Ok "BizHawk liegt in $biz"

Say "[3/4] Starter fuer Archipelago ..."
# connector_oot.lua liest die Randomizer-Adresse nur EINMAL beim Laden. Beim BizHawk-Start ist der Spielspeicher
# noch leer -> es liest dann fuer immer falsche Stellen (Warnungsflut, Ruckeln, keine Anmeldung).
# Deshalb ein kleiner Lader, der wartet, bis das Spiel laeuft. Er muss neben connector_oot.lua liegen,
# weil dessen socket.lua die Hilfs-DLL ueber den aktuellen Ordner sucht.
$loader = Join-Path (Split-Path $lua) "hvik_oot_loader.lua"
$loaderCode = @'
-- HviK Archipelago: wartet, bis Ocarina of Time wirklich laeuft, dann connector_oot.lua starten.
-- (connector_oot.lua liest die Randomizer-Adresse nur einmal beim Laden - zu frueh geladen liest es fuer immer falsch.)
local function ready()
  local p = mainmemory.read_u32_be(0x1C6E90 + 0x15D4)
  return p >= 0x80000000 and p < 0x80800000
end
console.log("HviK: warte, bis das Spiel laeuft ...")
while not ready() do emu.frameadvance() end
for i = 1, 120 do emu.frameadvance() end
console.log("HviK: starte connector_oot.lua")
dofile("connector_oot.lua")
'@
[IO.File]::WriteAllText($loader, $loaderCode.Replace("`r`n", "`n"), (New-Object Text.UTF8Encoding $false))
# Archipelago ruft rom_start mit der gepatchten ROM als einzigem Argument auf -> diese .bat haengt den Lader an.
$starter = Join-Path $biz "hvik-oot-start.bat"
$bat = "@echo off`r`nstart `"`" `"$biz\EmuHawk.exe`" --lua=`"$loader`" `"%~1`"`r`n"
[IO.File]::WriteAllText($starter, $bat, (New-Object Text.ASCIIEncoding))
Ok "Starter: $starter"

Say "[4/4] Archipelago-Einstellung (host.yaml) ..."
$hostYaml = Join-Path $HviK.ApDir "host.yaml"
if (-not (Test-Path $hostYaml)) {
    Say "Archipelago wird einmal kurz gestartet, damit es seine Einstellungen anlegt ..."
    Start-Process (Join-Path $HviK.ApDir "ArchipelagoLauncher.exe"); Start-Sleep -Seconds 8
    Get-Process ArchipelagoLauncher -ErrorAction SilentlyContinue | Stop-Process -Force
}
& "$PSScriptRoot\set-oot-start.ps1" -HostYaml $hostYaml -Starter $starter
Ok "Nach dem Patchen startet Archipelago jetzt BizHawk mit dem OoT-Verbindungs-Skript."

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: deine .apz5-Datei auf hvik.org laden und doppelklicken (oder START.bat)."
Say "Beim allerersten Mal fragt Archipelago nach deiner ROM: Ocarina of Time (USA) v1.0 (.z64)."
