# HviK Archipelago - Terraria einmalig einrichten:
# tModLoader (kostenlos, braucht Terraria) + Archipelago-Mod aus dem Steam-Workshop, Mod einschalten, Verbindung eintragen.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\tml.ps1"

Say "[1/3] Terraria und tModLoader suchen ..."
if (-not (Find-SteamGame 105600)) { Say "Terraria nicht gefunden - tModLoader braucht Terraria (Steam)." Yellow }
if (-not (Find-SteamGame $TML_APPID)) {
    Say "tModLoader ist noch nicht installiert - Steam oeffnet gleich die Installation (kostenlos)." Yellow
    Start-Process "steam://install/$TML_APPID"
    Read-Host "  Enter druecken, wenn tModLoader fertig installiert ist" | Out-Null
    if (-not (Find-SteamGame $TML_APPID)) { Fail "tModLoader immer noch nicht gefunden - bitte in Steam installieren und EINRICHTEN.bat nochmal starten." }
}
Ok "tModLoader gefunden."

Say "[2/3] Archipelago-Mod aus dem Steam-Workshop ..."
if (-not (Test-ModSubscribed)) {
    Say "Gleich oeffnet Steam die Workshop-Seite 'Archipelago Randomizer':" Cyan
    Say "  -> gruenen Knopf 'Abonnieren' klicken, kurz warten, dann hier Enter." Cyan
    Start-Process "steam://url/CommunityFilePage/$TML_WORKSHOP_ID"
    while (-not (Test-ModSubscribed)) {
        Read-Host "  Enter, wenn du abonniert hast" | Out-Null
        if (-not (Test-ModSubscribed)) { Say "Noch nicht da - Steam laedt evtl. noch. Kurz warten und nochmal Enter." Yellow }
    }
}
Enable-ApMod
Ok "Mod abonniert und eingeschaltet."

Say "[3/3] Verbindung eintragen ..."
$name = Get-PlayerName
Set-ApConfig $name
Ok "Name $name, Server $($HviK.Server) eingetragen."

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: START.bat doppelklicken, neue Welt anlegen und betreten - verbindet sich von selbst."
