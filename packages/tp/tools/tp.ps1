# HviK Archipelago - Twilight Princess: gemeinsame Pfade.
# Dolphin liegt "portable" im Paket (eigene Einstellungen in Dolphin-x64\User), damit Speicherkarte A als GCI-Ordner
# eingestellt werden kann, ohne eine vorhandene Dolphin-Installation anzufassen.
$TP_APWORLD_URL = "https://github.com/WritingHusky/Twilight_Princess_apworld/releases/download/v0.3.0/Twilight_Princess_apworld-v0.3.0.zip"
# 2503a statt der neuesten Version: 2609 stuerzt bei manchen beim Einstecken eines Controllers ab.
# 2503a ist zeitgleich mit der apworld (Mai 2025) entstanden.
$TP_DOLPHIN_VERSION = "2503a"
$TP_DOLPHIN_URL = "https://dl.dolphin-emu.org/releases/$TP_DOLPHIN_VERSION/dolphin-$TP_DOLPHIN_VERSION-x64.7z"
$TP_DOLPHIN = Join-Path $HviK.Root "Dolphin-x64"
# Speicherkarte A je Region (Dolphin nimmt den Ordner passend zur Region der ISO)
function Get-TpGciDir([string]$Region) { Join-Path $TP_DOLPHIN "User\GC\$Region\Card A" }
$TP_ISO_FILE = Join-Path $HviK.Root "iso.txt"

function Get-TpIso {
    if (Test-Path $TP_ISO_FILE) { $p = (Get-Content $TP_ISO_FILE -Raw).Trim(); if ($p -and (Test-Path $p)) { return $p } }
    return $null
}

# ISO einmal per Dateiauswahl festlegen (wird gemerkt)
function Select-TpIso {
    Add-Type -AssemblyName System.Windows.Forms
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title = "Twilight Princess (GameCube) - ISO auswaehlen"
    $dlg.Filter = "GameCube-Spiel (*.iso;*.gcm;*.rvz;*.ciso)|*.iso;*.gcm;*.rvz;*.ciso|Alle Dateien (*.*)|*.*"
    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        [IO.File]::WriteAllText($TP_ISO_FILE, $dlg.FileName)
        return $dlg.FileName
    }
    return $null
}

# Dolphin.ini: Speicherkarte A = GCI-Ordner (SlotA = 8). Vorhandene Einstellungen bleiben erhalten.
function Set-DolphinGciSlot {
    $cfgDir = Join-Path $TP_DOLPHIN "User\Config"
    New-Item -ItemType Directory -Force $cfgDir | Out-Null
    $ini = Join-Path $cfgDir "Dolphin.ini"
    $lines = if (Test-Path $ini) { @(Get-Content $ini) } else { @() }
    $out = New-Object System.Collections.Generic.List[string]
    $inCore = $false; $done = $false; $hasCore = $false
    foreach ($l in $lines) {
        if ($l -match '^\s*\[(.+)\]\s*$') {
            if ($inCore -and -not $done) { $out.Add("SlotA = 8"); $done = $true }
            $inCore = ($Matches[1] -eq "Core"); if ($inCore) { $hasCore = $true }
        } elseif ($inCore -and $l -match '^\s*SlotA\s*=') { $out.Add("SlotA = 8"); $done = $true; continue }
        $out.Add($l)
    }
    if ($inCore -and -not $done) { $out.Add("SlotA = 8"); $done = $true }
    if (-not $hasCore) { $out.Add("[Core]"); $out.Add("SlotA = 8") }
    [IO.File]::WriteAllLines($ini, $out, (New-Object Text.UTF8Encoding $false))
}
