# HviK Archipelago - XCOM 2: War of the Chosen einmalig einrichten:
# x2wotc.apworld 1.0.0 (Snyax) in Archipelago, Spiel- und Workshop-Ordner in host.yaml, Steam-Workshop-Mods abonnieren.
. "$PSScriptRoot\hvik.ps1"
$ApWorld = "https://github.com/Snyax/Archipelago/releases/download/1.0.0/x2wotc.apworld"
$ModWorkshop = "3281191663"   # XCOM 2 WotC Archipelago Mod
$McmWorkshop = "667104300"    # Mod Config Menu (empfohlen)

function Set-HostYamlValue([string]$File, [string]$Section, [string]$Key, [string]$Value) {
    $lines = if (Test-Path $File) { [IO.File]::ReadAllLines($File) } else { @() }
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

Say "[1/4] Archipelago und XCOM 2 suchen ..."
Test-Archipelago
$game = Find-SteamGame 268500
if (-not $game) { Fail "XCOM 2 ist nicht installiert (Steam). Bitte erst installieren." }
if (-not (Test-Path (Join-Path $game "XCom2-WarOfTheChosen"))) { Fail "War of the Chosen fehlt. Du brauchst das DLC 'XCOM 2: War of the Chosen'." }
Ok "Gefunden: $game"

Say "[2/4] XCOM-2-Client fuer Archipelago (x2wotc.apworld 1.0.0) ..."
$worlds = Join-Path $HviK.ApDir "custom_worlds"
New-Item -ItemType Directory -Force $worlds | Out-Null
Copy-Item (Get-File $ApWorld "x2wotc.apworld") (Join-Path $worlds "x2wotc.apworld") -Force
Ok "x2wotc.apworld installiert."

Say "[3/4] Spiel- und Workshop-Ordner in Archipelago eintragen (host.yaml) ..."
$hostYaml = Join-Path $HviK.ApDir "host.yaml"
$workshop = Join-Path (Split-Path (Split-Path $game -Parent) -Parent) "workshop"
Set-HostYamlValue $hostYaml "x2wotc_options" "game_path" ('"' + $game.Replace('\', '/') + '"')
Set-HostYamlValue $hostYaml "x2wotc_options" "workshop_path" ('"' + $workshop.Replace('\', '/') + '"')
Ok "Eingetragen - der Client fragt nicht mehr nach den Ordnern."

Say "[4/4] Mods aus dem Steam Workshop ..."
Say "Ich oeffne zwei Workshop-Seiten - dort jeweils 'Abonnieren' klicken:" Yellow
Say "  1. 'WotC Archipelago' (Pflicht)   2. 'Mod Config Menu' (empfohlen)" Yellow
Start-Process "steam://url/CommunityFilePage/$ModWorkshop"
Start-Sleep -Seconds 2
Start-Process "steam://url/CommunityFilePage/$McmWorkshop"

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Im XCOM-2-Launcher muessen die Mods angehakt sein (beim Start von War of the Chosen)."
Say "Am Spieltag: START.bat doppelklicken."
