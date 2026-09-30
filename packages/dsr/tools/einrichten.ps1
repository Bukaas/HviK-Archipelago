# HviK Archipelago - Dark Souls Remastered einmalig einrichten:
# DSAP-Client v0.2.6 (passend zur dsr.apworld auf dem HviK-Server) in diesen Ordner, normale Spielstaende einmal sichern.
# Archipelago selbst braucht man als Spieler nicht - DSAP.Desktop.exe verbindet sich selbst.
. "$PSScriptRoot\hvik.ps1"
$Url = "https://github.com/tathxo/DSAP/releases/download/v0.2.6/dsr-Windows-x64-v0.2.6.2.zip"
$dsap = Join-Path $HviK.Root "DSAP"

Say "[1/3] Dark Souls Remastered suchen ..."
if (-not (Find-SteamGame 570940)) { Fail "Dark Souls: Remastered ist nicht installiert (Steam). Bitte erst installieren." }
Ok "Gefunden."

Say "[2/3] DSAP-Client v0.2.6 (ca. 45 MB) ..."
$z = Get-File $Url "dsr-Windows-x64-v0.2.6.2.zip"
Expand-Zip $z $dsap
if (-not (Test-Path (Join-Path $dsap "DSAP.Desktop.exe"))) { Fail "DSAP.Desktop.exe fehlt nach dem Entpacken - beim Host melden." }
Ok "Client liegt in $dsap"

Say "[3/3] Normale Spielstaende sichern ..."
$saves = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "nbgi\DARK SOULS REMASTERED"
$backup = Join-Path $HviK.Root "Spielstand-Sicherung"
if (-not (Test-Path $saves)) { Say "Noch keine Spielstaende vorhanden - nichts zu sichern." }
elseif (Test-Path $backup) { Ok "Sicherung gibt es schon: $backup" }
else { Copy-Item $saves $backup -Recurse; Ok "Gesichert nach $backup" }

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "WICHTIG: Im Spiel unter System -> Netzwerk-Einstellungen -> Startmodus 'Offline starten'." Yellow
Say "Mit Mod online zu spielen kann einen Bann geben."
Say "Am Spieltag: START.bat doppelklicken."
