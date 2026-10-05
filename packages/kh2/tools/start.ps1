# HviK Archipelago - Kingdom Hearts II starten: neueste Seed-.zip (deine-runde oder Downloads) im Mod Manager
# installieren, bauen und starten, dann den KH2 Client mit hvik.org verbinden.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\kh2.ps1"
if (-not (Test-Path $KH2_MM)) { Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken." }
$places = @((Join-Path $HviK.Root "deine-runde"), (Join-Path $env:USERPROFILE "Downloads"))
$seed = Get-ChildItem $places -Filter "AP-*-P*.zip" -File -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $seed) { Fail "Keine Seed-Datei (AP-....zip) gefunden - auf hvik.org in der Runde 'Deine Datei' herunterladen." }
$name = Get-PlayerName

Ok "Deine Seed-Datei: $($seed.Name)"
Start-Process $KH2_MM -WorkingDirectory (Split-Path $KH2_MM)
Start-Process explorer.exe "/select,`"$($seed.FullName)`""
Copy-ToClipboard $seed.FullName
Write-Host ""
Say "Im OpenKH Mod Manager:" White
Say "  1. Gruenes Plus -> 'Select and install Mod Archive' -> deine Seed-Datei waehlen" White
Say "     (Pfad ist kopiert: im Dateifenster einfach Strg+V, Enter)." White
Say "  2. Die Seed GANZ NACH OBEN schieben. Alte Seeds aus frueheren Runden abhaken." White
Say "  3. 'Mod Loader' -> 'Build and Run'. KH2 startet." White
Say "  4. Neue Runde: NEUER Spielstand -> du landest im Garden of Assemblage." White
Write-Host ""
Read-Host "  Wenn KH2 laeuft und du im Garden of Assemblage bist: Enter druecken"
Start-Process (Join-Path $HviK.ApDir "ArchipelagoLauncher.exe") -ArgumentList "`"KH2 Client`""
Copy-ToClipboard $HviK.Server
Write-Host ""
Ok "Der KH2 Client geht auf."
Say "  Oben ins Adressfeld: Strg+V ($($HviK.Server) ist kopiert) -> Connect." White
Say "  Fragt er nach deinem Namen: $name" White
Say "  Der Client muss die ganze Zeit offen bleiben. Spiel geschlossen = Client trennt sich." White
Say "Findet der Client das Spiel nicht ('Cannot Open Process'): Launcher als Administrator starten." Yellow
