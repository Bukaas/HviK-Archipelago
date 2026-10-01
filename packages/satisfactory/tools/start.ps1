# HviK Archipelago - Satisfactory starten. Die Verbindung traegt man beim neuen Spiel in "Mod Savegame Settings" ein.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\satisfactory.ps1"
$sf = Find-Satisfactory
$game = $sf.Path
if (-not $sf -or -not (Test-Path (Join-Path (Get-SfModsDir $game) "Archipelago\Archipelago.uplugin"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName
Start-Process $sf.Launch
# Hat ein Admin deiner Fabrik den HviK-Satisfactory-Server zugeteilt? (steht auf hvik.org)
$srv = $null
try {
    $list = (Invoke-RestMethod -Uri "https://hvik.org/api/archipelago/spielserver.json" -TimeoutSec 10).servers
    $srv = @($list) | Where-Object { $_.game -eq "satisfactory" -and $_.slot -eq $name } | Select-Object -First 1
} catch { }
Write-Host ""
if ($srv) {
    $sfHost = $srv.address.Split(":")[0]; $sfPort = $srv.address.Split(":")[1]
    Copy-ToClipboard $sfHost
    Ok "Deine Fabrik '$name' laeuft auf dem HviK-Server ($($srv.address)) - KEIN neues Spiel auf deinem PC anlegen!"
    Say "  1. Im Hauptmenue: Server-Manager -> Server hinzufuegen:" White
    Say "       Adresse: $sfHost   (ist kopiert - Strg+V)" Cyan
    Say "       Port:    $sfPort" Cyan
    Say "  2. NUR beim allerersten Mal (eine/r aus der Fabrik): Server beanspruchen," White
    Say "     Namen + Admin-Passwort vergeben, dann 'Spiel erstellen' -> unten 'Mod Savegame Settings':" White
    Say "       Server URI: $($HviK.Server)" Cyan
    Say "       User Name:  $name" Cyan
    Say "       Password:   leer lassen" Cyan
    Say "     -> Startgebiet waehlen und erstellen. Im Chat erscheint die Archipelago-Verbindung." White
    Say "  3. Alle anderen (und ab dem zweiten Mal): Server auswaehlen -> Beitreten." White
    Say "Server aus? Auf hvik.org in der Runde unter 'Satisfactory-Server' auf Starten druecken." White
} else {
    Copy-ToClipboard $HviK.Server
    Ok "Satisfactory startet ueber $($sf.Store) (mit Mods). Fuer die Fabrik-Chefin/den Fabrik-Chef (Host):"
    Say "  (Deine Fabrik hat keinen HviK-Server - einer von euch hostet im Spiel. Server gewuenscht? Auf hvik.org anfragen.)" DarkGray
    Say "  1. Neues Spiel -> Startgebiet waehlen (Intro ueberspringen geht)." White
    Say "  2. Unten rechts 'Mod Savegame Settings' -> eintragen:" White
    Say "       Server URI: $($HviK.Server)   (ist kopiert - Strg+V)" Cyan
    Say "       User Name:  $name" Cyan
    Say "       Password:   leer lassen" Cyan
    Say "  3. Spiel erstellen - im Chat erscheint die Archipelago-Verbindung. Ab zum HUB!" White
    Say "Mitspieler: einfach dem Host beitreten (Satisfactory-Multiplayer, Steam und Epic gehen zusammen)."
}
Say "Befehle im Spiel-Chat OHNE Ausrufezeichen, z.B.  /hint Iron Plate"
