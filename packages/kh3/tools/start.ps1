# HviK Archipelago - Kingdom Hearts III starten: KH3 Client direkt mit hvik.org und deinem Namen.
# Der Client baut beim Verbinden deine Seed-Datei (.pak) selbst und installiert sie ins Spiel.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\kh3.ps1"
if (-not (Test-Path $KH3_APWORLD)) { Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken." }
if (Get-Process KINGDOM* -ErrorAction SilentlyContinue) {
    Say "Kingdom Hearts III laeuft noch - bitte beenden, der Client muss erst deine Seed-Datei installieren." Yellow
}
$name = Get-PlayerName
Start-Process (Join-Path $HviK.ApDir "ArchipelagoLauncher.exe") -ArgumentList "`"KH3 Client`"", "--", "--connect", $HviK.Server, "--name", $name
Copy-ToClipboard $HviK.Server
Write-Host ""
Ok "Der KH3 Client verbindet sich mit $($HviK.Server) als $name. Dann:"
Say "  1. Warten, bis der Client deine Seed-Datei gebaut und installiert hat" White
Say "     (beim ersten Mal ca. 1 Minute, Fortschritt steht oben im Client)." White
Say "  2. Im Client 'Launch KH3' klicken." White
Say "  3. Neue Runde = NEUER Spielstand. Weiterspielen = deinen HviK-Spielstand laden." White
Say "Der Client muss die ganze Zeit offen und verbunden bleiben."
Say "Fragt er nach Adresse: Strg+V ($($HviK.Server) ist kopiert) -> Connect."
