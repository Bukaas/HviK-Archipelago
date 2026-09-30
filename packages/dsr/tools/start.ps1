# HviK Archipelago - Dark Souls Remastered starten: Spiel ueber Steam, dann den DSAP-Client; Adresse in die Zwischenablage.
. "$PSScriptRoot\hvik.ps1"
$exe = Join-Path $HviK.Root "DSAP\DSAP.Desktop.exe"
if (-not (Test-Path $exe)) { Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken." }
$name = Get-PlayerName

Say "Starte Dark Souls Remastered (offline!) ..."
Start-Process "steam://rungameid/570940"
Say "Warte kurz, bis das Spiel laeuft ..."
for ($i = 0; $i -lt 60 -and -not (Get-Process DarkSoulsRemastered -ErrorAction SilentlyContinue); $i++) { Start-Sleep -Seconds 2 }
Start-Process $exe -WorkingDirectory (Split-Path $exe)
Copy-ToClipboard $HviK.Server
Write-Host ""
Ok "DSAP-Client startet. Dort oben links das Menue (drei Striche) oeffnen und eintragen:"
Say "    Host: $($HviK.Server)   (schon kopiert - Strg+V)" White
Say "    Slot: $name" White
Say "  -> Connect. Dann mit RECHTSklick zurueck ins Spielfenster und neuen Spielstand beginnen." White
Say "Der DSAP-Client muss die ganze Zeit offen bleiben. Spiel muss auf OFFLINE stehen." Yellow
