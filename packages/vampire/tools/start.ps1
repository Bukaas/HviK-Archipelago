# HviK Archipelago - Vampire Survivors starten: Adresse in die Zwischenablage, Name anzeigen.
# Startet die .exe direkt (nicht ueber Steam), damit Steam die heruntergepatchte Version nicht wieder aktualisiert.
. "$PSScriptRoot\hvik.ps1"
$game = Find-SteamGame 1794680
if (-not $game -or -not (Test-Path (Join-Path $game "Mods\ArchipelagoSurvivors.dll"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName

if (-not (Get-Process steam -ErrorAction SilentlyContinue)) {
    Say "Steam laeuft nicht - ich starte es (das Spiel braucht Steam im Hintergrund) ..."
    Start-Process "steam://open/main"
    Start-Sleep -Seconds 15
}
$exe = Get-ChildItem $game -Filter "*.exe" | Where-Object { $_.Name -notmatch "UnityCrashHandler|unins" } | Select-Object -First 1
Copy-ToClipboard $HviK.Server
if ($exe) { Start-Process $exe.FullName -WorkingDirectory $game } else { Start-Process "steam://rungameid/1794680" }
Write-Host ""
Ok "Spiel startet. Oben links auf dem Titelbildschirm eintragen:"
Say "    Adresse: $($HviK.Server)   (schon kopiert - Strg+V)" White
Say "    Name:    $name" White
Say "Dann verbinden und losspielen."
Say "Kein Verbindungsfeld oben links? Dann ist die Spielversion zu neu - siehe LIESMICH.txt." Yellow
