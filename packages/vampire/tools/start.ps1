# HviK Archipelago - Vampire Survivors starten: Version pruefen, Adresse in die Zwischenablage, Name anzeigen.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\downpatch.ps1"
$game = Find-SteamGame 1794680
if (-not $game -or -not (Test-Path (Join-Path $game "Mods\ArchipelagoSurvivors.dll"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
# Hat Steam das Spiel wieder auf eine neue Version gebracht? Dann die alte wieder drueberlegen.
if (-not (Test-Downpatched $game)) {
    Say "Steam hat das Spiel aktualisiert - setze es wieder auf $VS_VERSION zurueck ..." Yellow
    Invoke-Downpatch $game
}
$name = Get-PlayerName

Copy-ToClipboard $HviK.Server
Start-Process "steam://rungameid/1794680"
Write-Host ""
Ok "Spiel startet. Oben links auf dem Titelbildschirm eintragen:"
Say "    Adresse: $($HviK.Server)   (schon kopiert - Strg+V)" White
Say "    Name:    $name" White
Say "Dann verbinden und losspielen."
Say "Kein Verbindungsfeld oben links? Datei MelonLoader\Latest.log im Spielordner an den Host schicken." Yellow
