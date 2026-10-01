# HviK Archipelago - Pokemon (gemeinsam fuer Rot/Blau, Smaragd, Feuerrot/Blattgruen, Kristall).
# Alle laufen ueber den BizHawk Client von Archipelago: Patch-Datei oeffnen -> Client patcht deine ROM ->
# startet BizHawk mit dem Verbindungs-Skript (host.yaml: bizhawkclient_options.emuhawk_path + rom_start).
# Pro Spiel legt spiel.ps1 fest: $POKE_NAME, $POKE_EXT (Patch-Endungen), $POKE_APWORLD (URL oder $null), $POKE_ROM.
. "$PSScriptRoot\spiel.ps1"
$POKE_BIZ_VERSION = "2.9.1"
$POKE_BIZ_URL = "https://github.com/TASEmulators/BizHawk/releases/download/$POKE_BIZ_VERSION/BizHawk-$POKE_BIZ_VERSION-win-x64.zip"
$POKE_BIZ = Join-Path $HviK.Root "BizHawk"
$POKE_EMUHAWK = Join-Path $POKE_BIZ "EmuHawk.exe"

# Einen Wert in host.yaml setzen (Abschnitt auf oberster Ebene, Schluessel eingerueckt). Rest bleibt, ohne BOM.
function Set-HostYamlValue([string]$File, [string]$Section, [string]$Key, [string]$Value) {
    $lines = [IO.File]::ReadAllLines($File)
    $line = "  ${Key}: $Value"
    $out = New-Object System.Collections.Generic.List[string]
    $inSec = $false; $done = $false
    foreach ($l in $lines) {
        if ($l -match '^\S') {
            if ($inSec -and -not $done) { $out.Add($line); $done = $true }
            $inSec = ($l -match ('^' + [regex]::Escape($Section) + ':\s*$'))
        } elseif ($inSec -and $l -match ('^\s+' + [regex]::Escape($Key) + ':')) { $out.Add($line); $done = $true; continue }
        $out.Add($l)
    }
    if ($inSec -and -not $done) { $out.Add($line); $done = $true }
    if (-not $done) { $out.Add("${Section}:"); $out.Add($line) }
    [IO.File]::WriteAllLines($File, $out, (New-Object Text.UTF8Encoding $false))
}

# Neueste Patch-Datei dieses Spiels (Paket-Ordner "deine-runde" oder Downloads)
function Get-PokePatch {
    $places = @((Join-Path $HviK.Root "deine-runde"), (Join-Path $env:USERPROFILE "Downloads"))
    $files = foreach ($ext in $POKE_EXT) { Get-ChildItem $places -Filter "*$ext" -File -ErrorAction SilentlyContinue }
    return $files | Sort-Object LastWriteTime -Descending | Select-Object -First 1
}
