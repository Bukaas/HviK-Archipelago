# HviK Archipelago - Pokemon starten: neueste Patch-Datei im BizHawk Client oeffnen, direkt mit der HviK-Adresse.
# Der Client patcht deine ROM und startet BizHawk mit dem Verbindungs-Skript.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\pokemon.ps1"
if (-not (Test-Path $POKE_EMUHAWK)) { Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken." }
$patch = Get-PokePatch
if (-not $patch) { Fail "Keine $($POKE_EXT -join '/')-Datei gefunden - auf hvik.org in der Runde 'Deine Datei' herunterladen." }
Say "Oeffne $($patch.Name) ..."
Start-Process (Join-Path $HviK.ApDir "ArchipelagoLauncher.exe") -ArgumentList "`"BizHawk Client`"", "--", "`"$($patch.FullName)`"", "--connect", $HviK.Server
Copy-ToClipboard $HviK.Server
Write-Host ""
Ok "Der BizHawk Client patcht jetzt deine ROM und startet BizHawk."
Say "  Beim allerersten Mal fragt er nach der ROM: $POKE_ROM" White
Say "  Verbindet sich der Client nicht selbst: oben $($HviK.Server) eintragen (schon kopiert) -> Connect." White
Say "  Im Client muss 'Connected' und unten der Spielname stehen - dann loslegen."
