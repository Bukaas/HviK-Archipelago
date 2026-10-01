# HviK Archipelago - Celeste 64 starten: AP.json schreiben, Spiel starten.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\celeste64.ps1"
if (-not (Test-Path $C64_EXE)) { Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken." }
$name = Get-PlayerName
Set-C64Connection $name
Start-Process $C64_EXE -WorkingDirectory $C64_DIR
Write-Host ""
Ok "Celeste 64 startet und verbindet sich mit $($HviK.Server) als $name."
Say "  Kommst du am Titelbild vorbei, bist du verbunden - los geht's!" White
Say "Haengt es am Titelbild: Runde laeuft? Name richtig (Gross-/Kleinschreibung)?"
