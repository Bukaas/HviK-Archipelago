# HviK Archipelago - Ratchet & Clank 3 einmalig einrichten:
# rac3.apworld in Archipelago, PCSX2 (portable) mit PINE, dein PS2-BIOS und deine R&C3-ISO einmal auswaehlen.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\rac3.ps1"

if ($HviK.Root -match "(?i)OneDrive") {
    Fail "Dieser Ordner liegt in OneDrive - bitte das Paket z.B. nach C:\Spiele\HviK-RatchetClank3 verschieben und EINRICHTEN.bat dort nochmal starten."
}

Say "[1/5] Archipelago + Ratchet-and-Clank-3-Client ..."
Test-Archipelago
$apw = Get-File $RAC3_APWORLD_URL "rac3.apworld"
$worlds = Join-Path $HviK.ApDir "custom_worlds"
New-Item -ItemType Directory -Force $worlds | Out-Null
Copy-Item $apw (Join-Path $worlds "rac3.apworld") -Force
Ok "rac3.apworld $RAC3_APWORLD_VERSION installiert."

Say "[2/5] PCSX2 $RAC3_PCSX2_VERSION (PS2-Emulator) ..."
$verFile = Join-Path $RAC3_PCSX2 "hvik-version.txt"
$haveVer = if (Test-Path $verFile) { (Get-Content $verFile -Raw).Trim() } else { "" }
if ($haveVer -ne $RAC3_PCSX2_VERSION -or -not (Test-Path $RAC3_EXE)) {
    Get-Process pcsx2-qt -ErrorAction SilentlyContinue | Stop-Process -Force
    $out = Join-Path $env:TEMP "hvik-archipelago\pcsx2-$RAC3_PCSX2_VERSION.7z"
    New-Item -ItemType Directory -Force (Split-Path $out), $RAC3_PCSX2 | Out-Null
    Say "Lade PCSX2 $RAC3_PCSX2_VERSION ..."
    try { Invoke-WebRequest -Uri $RAC3_PCSX2_URL -OutFile $out -UseBasicParsing -UserAgent "Mozilla/5.0" }
    catch { Fail "PCSX2-Download fehlgeschlagen. Internet da? Sonst beim Host melden." }
    # Programmdateien ueberschreiben; Einstellungen, BIOS und Speicherkarten (inis, bios, memcards) bleiben.
    # Windows 11 kann .7z mit dem eingebauten tar entpacken, Windows 10 nicht -> dann 7zr.exe von 7-zip.org.
    if (Test-Path $RAC3_EXE) { Remove-Item $RAC3_EXE -Force }
    try { & tar -xf $out -C $RAC3_PCSX2 2>$null } catch { }
    if (-not (Test-Path $RAC3_EXE)) {
        Say "Windows kann das nicht selbst entpacken - nehme 7-Zip (7zr.exe) ..."
        $sevenZip = Join-Path $env:TEMP "hvik-archipelago\7zr.exe"
        try { Invoke-WebRequest -Uri "https://www.7-zip.org/a/7zr.exe" -OutFile $sevenZip -UseBasicParsing -UserAgent "Mozilla/5.0" }
        catch { Fail "7-Zip-Download fehlgeschlagen. Internet da? Sonst beim Host melden." }
        & $sevenZip x $out "-o$RAC3_PCSX2" -y | Out-Null
    }
    if (-not (Test-Path $RAC3_EXE)) { Fail "PCSX2 konnte nicht entpackt werden - beim Host melden." }
    [IO.File]::WriteAllText($verFile, $RAC3_PCSX2_VERSION)
}
# portable.txt: PCSX2 speichert alles in diesem Ordner statt in Dokumente\PCSX2
New-Item -ItemType File -Force (Join-Path $RAC3_PCSX2 "portable.txt") | Out-Null
New-Item -ItemType Directory -Force $RAC3_BIOS | Out-Null
Ok "PCSX2 liegt in $RAC3_PCSX2."

Say "[3/5] PS2-BIOS (von deiner eigenen PS2) ..."
$bios = @(Get-ChildItem $RAC3_BIOS -File -ErrorAction SilentlyContinue | Where-Object { $_.Length -ge 4MB })
if ($bios) { Ok "BIOS schon da: $($bios[0].Name)" }
else {
    Say "Gleich geht ein Fenster auf: deine PS2-BIOS-Datei auswaehlen (meist .bin, ca. 4 MB)." Cyan
    Say "Das BIOS duerfen wir nicht verteilen - es muss von deiner eigenen Konsole stammen." Cyan
    $b = Select-Rac3File "PS2-BIOS auswaehlen" "PS2-BIOS (*.bin;*.rom0)|*.bin;*.rom0|Alle Dateien (*.*)|*.*"
    if ($b) {
        # gleichnamige Zusatzdateien (.rom1, .erom, .nvm, .mec ...) gleich mitnehmen
        $stem = [IO.Path]::GetFileNameWithoutExtension($b)
        Get-ChildItem (Split-Path $b) -File | Where-Object { [IO.Path]::GetFileNameWithoutExtension($_.Name) -eq $stem } |
            Copy-Item -Destination $RAC3_BIOS -Force
        Ok "BIOS kopiert: $(Split-Path $b -Leaf)"
    } else { Say "Kein BIOS gewaehlt - kannst du gleich im PCSX2-Assistenten nachholen." Yellow }
}

Say "[4/5] PCSX2 einrichten ..."
if (-not (Test-Path $RAC3_INI)) {
    Say "PCSX2 startet jetzt einmal mit dem Einrichtungs-Assistenten:" Cyan
    Say "  Sprache -> Weiter, beim BIOS dein BIOS anklicken -> Weiter ... -> Fertig." Cyan
    Say "  Danach PCSX2 SCHLIESSEN - dann geht es hier weiter." Cyan
    Start-Process $RAC3_EXE -WorkingDirectory $RAC3_PCSX2 -Wait
}
if (-not (Test-Path $RAC3_INI)) { Fail "PCSX2 hat keine Einstellungen angelegt - EINRICHTEN.bat nochmal starten." }
Set-Rac3Pine
Ok "PINE eingeschaltet (Slot 28011) - der Client kann das Spiel auslesen."

Say "[5/5] Deine Ratchet & Clank 3 ISO ..."
$iso = Get-Rac3Iso
if ($iso) { Ok "Schon gewaehlt: $iso" }
else {
    Say "Gleich geht ein Fenster auf: deine Ratchet & Clank 3 ISO auswaehlen (US oder EU)." Cyan
    $iso = Select-Rac3File "Ratchet & Clank 3 (PS2) - ISO auswaehlen" "PS2-Spiel (*.iso;*.chd;*.cso;*.bin)|*.iso;*.chd;*.cso;*.bin|Alle Dateien (*.*)|*.*"
    if ($iso) { [IO.File]::WriteAllText($RAC3_ISO_FILE, $iso); Ok "Gemerkt: $iso" }
    else { Say "Keine ISO gewaehlt - START.bat oeffnet PCSX2 dann ohne Spiel." Yellow }
}

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: START.bat doppelklicken."
