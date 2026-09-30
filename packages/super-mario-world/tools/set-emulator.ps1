# HviK Archipelago - dem SNI Client sagen, welchen Emulator er nach dem Patchen starten soll
# (host.yaml -> sni_options.snes_rom_start). Speichert ohne BOM.
param([string]$Emulator, [string]$HostYaml = "C:\ProgramData\Archipelago\host.yaml")
$ErrorActionPreference = "Stop"
$f = $HostYaml
if (-not (Test-Path $f)) { exit 0 }  # Archipelago legt die Datei beim ersten Start selbst an
$c = [IO.File]::ReadAllText($f)
$value = '"' + $Emulator.Replace('\', '\\') + '"'
$n = [regex]::Replace($c, '(?m)^(\s*snes_rom_start:).*$', { param($m) $m.Groups[1].Value + " " + $value })
if ($n -ne $c) { [IO.File]::WriteAllText($f, $n, (New-Object Text.UTF8Encoding $false)) }
