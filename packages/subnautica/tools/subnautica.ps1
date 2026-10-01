# HviK Archipelago - Subnautica: gemeinsame Werte + Verbindung vorausfuellen.
# Der Mod liest die letzte Verbindung aus SNAppData\SavedGames\archipelago_last_connection.json
# (je nach Ladezeitpunkt mit oder ohne Unterordner ArchipelagoSaves - wir schreiben beide).
$SUB_APPID = 264710
$SUB_MOD_VERSION = "1.9.3"
$SUB_MOD_URL = "https://github.com/Berserker66/ArchipelagoSubnauticaModSrc/releases/download/1.9.3/Archipelago_193.zip"

function Set-SubConnection([string]$Game, [string]$Name) {
    $json = '{"host_name":"' + $HviK.Server + '","slot_name":"' + $Name + '","password":""}'
    foreach ($dir in (Join-Path $Game "SNAppData\SavedGames"), (Join-Path $Game "SNAppData\SavedGames\ArchipelagoSaves")) {
        New-Item -ItemType Directory -Force $dir | Out-Null
        [IO.File]::WriteAllText((Join-Path $dir "archipelago_last_connection.json"), $json, (New-Object Text.UTF8Encoding $false))
    }
}
