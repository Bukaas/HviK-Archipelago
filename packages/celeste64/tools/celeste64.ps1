# HviK Archipelago - Celeste 64: die Archipelago-Fassung ist ein eigenes, kostenloses Spiel (kein Steam noetig).
# v1.4.1 verbindet sich laut Changelog auch mit Welten der Version 1.3.x (Archipelago 0.6.7 hat 1.3.1).
$C64_VERSION = "v1.4.1"
$C64_URL = "https://github.com/PoryGoneDev/Celeste64/releases/download/v1.4.1/Celeste64-Archipelago-v1.4.1-win-x64.zip"
$C64_DIR = Join-Path $HviK.Root "Celeste64"
$C64_EXE = Join-Path $C64_DIR "Celeste64.exe"

# AP.json im Spielordner: Server, Name, Passwort - liest das Spiel beim Start
function Set-C64Connection([string]$Name) {
    $json = "{`r`n`t`"Url`": `"$($HviK.Server)`",`r`n`t`"SlotName`": `"$Name`",`r`n`t`"Password`": `"`"`r`n}"
    [IO.File]::WriteAllText((Join-Path $C64_DIR "AP.json"), $json, (New-Object Text.UTF8Encoding $false))
}
