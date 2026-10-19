# HviK Archipelago - Super Mario Odyssey einmalig einrichten:
# smo.apworld (Kgamer77 v1.6.3, HviK-Korrektur fuer Archipelago 0.6.7 - liegt im Paket) + Emulator-Mod SMOAP
# in alle gefundenen Switch-Emulatoren (Ryujinx und Abkoemmlinge, Yuzu-Abkoemmlinge wie Suyu/Eden/Citron/Sudachi).
# Das Spiel selbst (Version 1.0.0!) bringst du mit - es ist nicht im Paket.
. "$PSScriptRoot\hvik.ps1"
$EmuMod = "https://github.com/Kgamer77/SuperMarioOdysseyArchipelago/releases/download/v1.6.3/SMO_Archipelago_V1.6.3_Emu.zip"
$TitleId = "0100000000010000"

Say "[1/3] Archipelago suchen ..."
Test-Archipelago
Ok "Archipelago gefunden."

Say "[2/3] Super Mario Odyssey Client fuer Archipelago (smo.apworld) ..."
$worlds = Join-Path $HviK.ApDir "custom_worlds"
New-Item -ItemType Directory -Force $worlds | Out-Null
Copy-Item (Join-Path $HviK.Root "smo.apworld") (Join-Path $worlds "smo.apworld") -Force
Ok "smo.apworld installiert."

Say "[3/3] Emulator-Mod (SMOAP) ..."
$ziele = @()
foreach ($r in "Ryujinx", "Ryubing", "Kenji-NX") {
    $base = Join-Path $env:APPDATA $r
    if (Test-Path $base) { $ziele += Join-Path $base "mods\contents\$TitleId" }
}
foreach ($y in "yuzu", "suyu", "eden", "citron", "sudachi", "torzu") {
    $base = Join-Path $env:APPDATA $y
    if (Test-Path $base) { $ziele += Join-Path $base "load\$TitleId" }
}
if ($ziele.Count -eq 0) {
    Say "Keinen Switch-Emulator gefunden (Ryujinx, Suyu, Eden ...)." Yellow
    Say "Emulator installieren, Super Mario Odyssey einmal starten und EINRICHTEN.bat nochmal ausfuehren." Yellow
    Say "Fuer eine echte Switch: SMO_Archipelago_..._Switch.zip -> Ordner 'atmosphere' auf die SD-Karte." Yellow
    exit 1
}
$zip = Get-File $EmuMod "SMO_Archipelago_Emu.zip"
foreach ($z in $ziele) {
    if (Test-Path (Join-Path $z "SMOAP")) { Remove-Item (Join-Path $z "SMOAP") -Recurse -Force }
    Expand-Zip $zip $z
    Ok "Mod eingesetzt: $z\SMOAP"
}

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "WICHTIG: Der Mod geht NUR mit Super Mario Odyssey Version 1.0.0 (keine Updates im Emulator installieren)." Yellow
Say "Am Spieltag: START.bat doppelklicken."
