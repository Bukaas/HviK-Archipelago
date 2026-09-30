# HviK Archipelago - Terraria starten: Verbindung (Name) aktualisieren, tModLoader ueber Steam starten.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\tml.ps1"
if (-not (Find-SteamGame $TML_APPID) -or -not (Test-ModSubscribed)) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$name = Get-PlayerName
Enable-ApMod
Set-ApConfig $name

Start-Process "steam://rungameid/$TML_APPID"
Write-Host ""
Ok "tModLoader startet (der erste Start mit Mods dauert etwas)."
Say "Fuer eine neue Runde: NEUE Welt anlegen und betreten - der Mod verbindet sich von selbst als $name."
Say "Chat-Befehle: /ap !hint Itemname   -   Verbindung neu: /apconnect"
