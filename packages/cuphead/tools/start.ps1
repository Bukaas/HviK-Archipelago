# HviK Archipelago - Cuphead starten. Die Verbindung wird im Spiel pro Speicherplatz eingetragen (Archipelago-Menue).
. "$PSScriptRoot\hvik.ps1"
$CUP_APPID = 268910
$game = Find-SteamGame $CUP_APPID
if (-not $game -or -not (Test-Path (Join-Path $game "BepInEx\plugins\CupheadArchipelago\CupheadArchipelago.dll"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName
$hostName, $port = $HviK.Server.Split(":")
Copy-ToClipboard $name
Start-Process "steam://rungameid/$CUP_APPID"
Write-Host ""
Ok "Cuphead startet (mit Mod - unten im Hauptmenue steht 'CupheadArchipelago'). Dann:"
Say "  1. Start -> einen LEEREN Speicherplatz auswaehlen (nicht starten!)." White
Say "  2. Archipelago-Menue oeffnen: Tastatur C+Z (am Controller zeigt das Spiel die Tasten an)." White
Say "  3. Enabled mit links/rechts auf AN stellen und eintragen:" White
Say "       Address:  $hostName" Cyan
Say "       Port:     $port" Cyan
Say "       Player:   $name   (ist kopiert)" Cyan
Say "       Password: leer lassen" Cyan
Say "  4. Menue schliessen - am Speicherplatz steht jetzt 'AP' - Speicherplatz starten. Los!" White
Say "Weiterspielen: einfach denselben Speicherplatz nehmen, die Daten sind gemerkt."
