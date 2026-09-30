# HviK Archipelago - in host.yaml im Abschnitt "oot_options:" rom_start auf unseren BizHawk-Starter setzen.
# Andere Abschnitte (z.B. sni_options) bleiben unangetastet. Speichert ohne BOM.
param([string]$HostYaml, [string]$Starter)
$ErrorActionPreference = "Stop"
$lines = [IO.File]::ReadAllLines($HostYaml)
$value = "  rom_start: `"" + $Starter.Replace('\', '\\') + "`""
$out = New-Object System.Collections.Generic.List[string]
$inOot = $false; $done = $false
foreach ($l in $lines) {
    if ($l -match '^\S') {                                   # neuer Abschnitt auf oberster Ebene
        if ($inOot -and -not $done) { $out.Add($value); $done = $true }
        $inOot = ($l -match '^oot_options:\s*$')
    } elseif ($inOot -and $l -match '^\s+rom_start:') { $out.Add($value); $done = $true; continue }
    $out.Add($l)
}
if ($inOot -and -not $done) { $out.Add($value); $done = $true }
if (-not $done) { $out.Add("oot_options:"); $out.Add($value) }
[IO.File]::WriteAllLines($HostYaml, $out, (New-Object Text.UTF8Encoding $false))
