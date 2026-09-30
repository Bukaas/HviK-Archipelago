# HviK Archipelago - Ratchet & Clank 3: gemeinsame Pfade.
# PCSX2 liegt "portable" im Paket (eigene Einstellungen in PCSX2\inis), eine vorhandene PCSX2-Installation bleibt unberuehrt.
$RAC3_APWORLD_VERSION = "v0.6.0"
$RAC3_APWORLD_URL = "https://github.com/Taoshix/Archipelago-RaC3/releases/download/$RAC3_APWORLD_VERSION/rac3.apworld"
$RAC3_PCSX2_VERSION = "v2.8.2"
$RAC3_PCSX2_URL = "https://github.com/PCSX2/pcsx2/releases/download/$RAC3_PCSX2_VERSION/pcsx2-$RAC3_PCSX2_VERSION-windows-x64-Qt.7z"
$RAC3_PCSX2 = Join-Path $HviK.Root "PCSX2"
$RAC3_EXE = Join-Path $RAC3_PCSX2 "pcsx2-qt.exe"
$RAC3_INI = Join-Path $RAC3_PCSX2 "inis\PCSX2.ini"
$RAC3_BIOS = Join-Path $RAC3_PCSX2 "bios"
$RAC3_ISO_FILE = Join-Path $HviK.Root "iso.txt"

function Get-Rac3Iso {
    if (Test-Path $RAC3_ISO_FILE) { $p = (Get-Content $RAC3_ISO_FILE -Raw).Trim(); if ($p -and (Test-Path $p)) { return $p } }
    return $null
}

function Select-Rac3File([string]$Title, [string]$Filter) {
    Add-Type -AssemblyName System.Windows.Forms
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title = $Title
    $dlg.Filter = $Filter
    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { return $dlg.FileName }
    return $null
}

# Einen Wert in einer INI setzen (Abschnitt/Schluessel werden bei Bedarf angelegt, Rest bleibt erhalten).
function Set-IniValue([string]$File, [string]$Section, [string]$Key, [string]$Value) {
    $lines = if (Test-Path $File) { @(Get-Content $File) } else { @() }
    $out = New-Object System.Collections.Generic.List[string]
    $inSec = $false; $done = $false; $hasSec = $false
    foreach ($l in $lines) {
        if ($l -match '^\s*\[(.+)\]\s*$') {
            if ($inSec -and -not $done) { $out.Add("$Key = $Value"); $done = $true }
            $inSec = ($Matches[1] -eq $Section); if ($inSec) { $hasSec = $true }
        } elseif ($inSec -and $l -match ('^\s*' + [regex]::Escape($Key) + '\s*=')) { $out.Add("$Key = $Value"); $done = $true; continue }
        $out.Add($l)
    }
    if ($inSec -and -not $done) { $out.Add("$Key = $Value"); $done = $true }
    if (-not $hasSec) { $out.Add(""); $out.Add("[$Section]"); $out.Add("$Key = $Value") }
    [IO.File]::WriteAllLines($File, $out, (New-Object Text.UTF8Encoding $false))
}

# PINE an (Slot 28011) - darueber liest der RaC3-Client das Spiel aus.
function Set-Rac3Pine {
    Set-IniValue $RAC3_INI "EmuCore" "EnablePINE" "true"
    Set-IniValue $RAC3_INI "EmuCore" "PINESlot" "28011"
}
