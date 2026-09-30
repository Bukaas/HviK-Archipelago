# HviK Archipelago - Dark Souls III einmalig einrichten: .NET 6 + DS3-Archipelago-Mod (3.0.13) in diesen Ordner.
# Der Mod kommt NICHT in den Spielordner - ModEngine2 startet das Spiel von hier aus.
. "$PSScriptRoot\hvik.ps1"
$Version = "3.0.13"
$Url = "https://github.com/nex3/Dark-Souls-III-Archipelago-client/releases/download/v$Version/DS3.Archipelago.$Version.zip"

Say "[1/3] Dark Souls III suchen ..."
$game = Find-SteamGame 374320
if (-not $game) { Fail "Dark Souls III ist nicht installiert (Steam). Bitte erst installieren." }
Ok "Gefunden: $game"
# Alte Randomizer-Versionen haben eine dinput8.dll im Spielordner hinterlassen - die stoert ModEngine2.
$old = Join-Path $game "Game\dinput8.dll"
if (Test-Path $old) { Move-Item $old "$old.alt" -Force; Say "Alte dinput8.dll beiseitegelegt (dinput8.dll.alt)." }

Say "[2/3] .NET 6 (fuer den Randomizer) ..."
Install-DotNet6

Say "[3/3] DS3-Archipelago-Mod $Version ..."
$zip = Get-File $Url "DS3.Archipelago.$Version.zip"
$tmp = Join-Path $env:TEMP "hvik-archipelago\ds3"
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
Expand-Zip $zip $tmp
$mod = Join-Path $HviK.Root "mod"
# apconfig.json (Adresse/Name/Seed der letzten Runde) beim Aktualisieren behalten
$keep = Join-Path $mod "apconfig.json"
$saved = if (Test-Path $keep) { Get-Content $keep -Raw } else { $null }
if (Test-Path $mod) { Remove-Item $mod -Recurse -Force }
Move-Item (Join-Path $tmp "DS3 Archipelago $Version") $mod
if ($saved) { [IO.File]::WriteAllText($keep, $saved) }
Ok "Mod liegt in: $mod"

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "WICHTIG: Im Spiel unter Optionen -> Netzwerk auf OFFLINE stellen (sonst droht ein Bann)." Yellow
Say "Am Spieltag: START.bat doppelklicken."
