# HviK Archipelago - Super Mario Odyssey starten: Archipelago-Client (verbindet zum Server) + Hinweis auf die
# lokale Adresse, die Mario im Spiel abfragt (Client lauscht auf Port 1027).
. "$PSScriptRoot\hvik.ps1"
if (-not (Test-Path (Join-Path $HviK.ApDir "custom_worlds\smo.apworld"))) { Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken." }
$name = Get-PlayerName
Say "Starte den Super Mario Odyssey Client ..."
Start-Process (Join-Path $HviK.ApDir "ArchipelagoLauncher.exe") -ArgumentList "`"Super Mario Odyssey Client`""

Copy-ToClipboard $HviK.Server
Write-Host ""
Ok "Adresse $($HviK.Server) ist kopiert: im Client oben ins Server-Feld -> Strg+V -> Connect."
Read-Host "  Danach hier Enter druecken (dann kopiere ich deinen Namen)" | Out-Null
Copy-ToClipboard $name
Ok "Name $name ist kopiert: fragt der Client nach dem Namen -> Strg+V -> Enter."

$ip = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" -and $_.PrefixOrigin -ne "WellKnown" } | Select-Object -First 1).IPAddress
Write-Host ""
Say "Jetzt Super Mario Odyssey im Emulator starten (Version 1.0.0, Mod 'SMOAP' an)."
Say "Fragt das Spiel nach der Verbindung:"
Say "   IP-Adresse:  $ip" Green
Say "   Port:        1027" Green
Say "Das Client-Fenster waehrend des Spielens OFFEN lassen." Yellow
