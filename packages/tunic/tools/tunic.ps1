# HviK Archipelago - TUNIC: gemeinsame Werte + Verbindung vorausfuellen.
# Mod-Version 4.2.7 passt zur TUNIC-Welt in Archipelago 0.6.7 (world_version 4.2.7) - NICHT auf 5.x hochziehen,
# solange der Server 0.6.7 hat. Der Mod speichert seine Einstellungen in
#   %USERPROFILE%\AppData\LocalLow\<Firma>\<Spiel>\Randomizer\Settings.json  (entsteht beim ersten Start mit Mod)
$TUNIC_APPID = 553420
$TUNIC_MOD_VERSION = "4.2.7"
$TUNIC_MOD_URL = "https://github.com/silent-destroyer/tunic-randomizer/releases/download/4.2.7/TunicRandomizer.zip"
$TUNIC_BEPINEX_URL = "https://github.com/BepInEx/BepInEx/releases/download/v6.0.0-pre.1/BepInEx_UnityIL2CPP_x64_6.0.0-pre.1.zip"

function Find-TunicSettings {
    $low = Join-Path $env:USERPROFILE "AppData\LocalLow"
    return Get-ChildItem $low -Directory -ErrorAction SilentlyContinue |
        ForEach-Object { Get-ChildItem $_.FullName -Directory -ErrorAction SilentlyContinue } |
        ForEach-Object { Join-Path $_.FullName "Randomizer\Settings.json" } |
        Where-Object { Test-Path $_ } | Select-Object -First 1
}

# Name/Server/Port eintragen und auf Archipelago-Modus stellen (Rest der Datei bleibt, wie sie ist)
function Set-TunicConnection([string]$File, [string]$Name) {
    $hostName, $port = $HviK.Server.Split(":")
    $s = [IO.File]::ReadAllText($File)
    $s = [regex]::Replace($s, '"Player"\s*:\s*"[^"]*"', '"Player": "' + $Name + '"')
    $s = [regex]::Replace($s, '"Hostname"\s*:\s*"[^"]*"', '"Hostname": "' + $hostName + '"')
    $s = [regex]::Replace($s, '"Port"\s*:\s*"[^"]*"', '"Port": "' + $port + '"')
    $s = [regex]::Replace($s, '"Mode"\s*:\s*\d+', '"Mode": 1')
    [IO.File]::WriteAllText($File, $s, (New-Object Text.UTF8Encoding $false))
}
