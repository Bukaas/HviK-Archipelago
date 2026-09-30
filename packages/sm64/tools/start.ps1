# HviK Archipelago - Super Mario 64 starten: SM64AP-Launcher oeffnen, Adresse in die Zwischenablage.
. "$PSScriptRoot\hvik.ps1"
$dir = Join-Path $HviK.Root "SM64AP-Launcher"
$exe = Get-ChildItem $dir -Recurse -Filter "*.exe" -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "(?i)launcher|sm64" } | Select-Object -First 1
if (-not $exe) { Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken." }
$name = Get-PlayerName
Copy-ToClipboard $HviK.Server
Start-Process $exe.FullName -WorkingDirectory $exe.DirectoryName
Write-Host ""
Ok "SM64AP-Launcher startet. Dort deinen Build waehlen und eintragen:"
Say "    Server: $($HviK.Server)   (schon kopiert - Strg+V)" White
Say "    Name:   $name" White
Say "Dann Play. Der Launcher merkt sich die Angaben fuers naechste Mal."
