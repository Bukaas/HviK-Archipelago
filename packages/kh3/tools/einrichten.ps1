# HviK Archipelago - Kingdom Hearts III einmalig einrichten:
# kh3.apworld in Archipelago, dann im KH3 Client einmal "Patch Game" (installiert die Spiel-Mods).
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\kh3.ps1"

Say "[1/3] Archipelago ..."
Test-Archipelago
Ok "Archipelago ist da."

Say "[2/3] KH3-Client (kh3.apworld $KH3_APWORLD_VERSION) ..."
$apw = Get-File $KH3_APWORLD_URL "kh3-$KH3_APWORLD_VERSION.apworld"
New-Item -ItemType Directory -Force (Split-Path $KH3_APWORLD) | Out-Null
Copy-Item $apw $KH3_APWORLD -Force
Ok "kh3.apworld installiert."
if (-not (Find-SteamGame $KH3_APPID)) {
    Say "Kingdom Hearts III nicht bei Steam gefunden - bei Epic im Client unter KH3 Dir den Spielordner waehlen." Yellow
}
Get-PlayerName | Out-Null

Say "[3/3] Spiel patchen ..."
Get-Process KINGDOM* -ErrorAction SilentlyContinue | ForEach-Object { Say "Kingdom Hearts III laeuft noch - bitte erst beenden." Yellow }
Start-Process (Join-Path $HviK.ApDir "ArchipelagoLauncher.exe") -ArgumentList "`"KH3 Client`""
Write-Host ""
Ok "Der KH3 Client geht jetzt auf. Dort EINMAL:"
Say "  1. Oben den Reiter 'KH3 Config' oeffnen." White
Say "  2. Pruefen, dass bei 'KH3 Dir' dein Spielordner steht (sonst auswaehlen)." White
Say "  3. 'Patch Game' klicken und warten, bis es fertig meldet (dauert beim ersten Mal etwas," White
Say "     es laedt Garden of Assemblage, den Mod-Loader und ein .NET-Werkzeug)." White
Say "  4. Client schliessen. Fertig!" White
Say "Neue apworld-Version? Paket neu laden, EINRICHTEN.bat nochmal, wieder 'Patch Game'."
