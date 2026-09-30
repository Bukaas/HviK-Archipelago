# HviK Archipelago - Vampire Survivors starten: die AP-Kopie (1.14.112) direkt, Adresse in die Zwischenablage.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\vsap.ps1"
if (-not (Test-Is114 $VS_DIR) -or -not (Test-Path (Join-Path $VS_DIR "Mods\ArchipelagoSurvivors.dll"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName

if (-not (Get-Process steam -ErrorAction SilentlyContinue)) {
    Say "Steam laeuft nicht - ich starte es (das Spiel braucht Steam im Hintergrund) ..."
    Start-Process "steam://open/main"
    Start-Sleep -Seconds 15
}
Copy-ToClipboard $HviK.Server
Start-Process (Join-Path $VS_DIR "VampireSurvivors.exe") -WorkingDirectory $VS_DIR
Write-Host ""
Ok "Vampire Survivors AP ($VS_VERSION) startet. Oben links auf dem Titelbildschirm eintragen:"
Say "    Adresse: $($HviK.Server)   (schon kopiert - Strg+V)" White
Say "    Name:    $name" White
Say "Dann verbinden -> START -> Charakter ANKLICKEN (nicht nur weiter druecken!) -> Stage -> los."
Say "Kein Verbindungsfeld? Die Datei 'Vampire Survivors AP\MelonLoader\Latest.log' an den Host schicken." Yellow
