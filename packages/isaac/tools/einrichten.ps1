# HviK Archipelago - The Binding of Isaac: Repentance einmalig einrichten:
# tboir.apworld (Isaac Client) in Archipelago, Spielordner in host.yaml, Steam-Workshop-Mod abonnieren.
# Versionen passend zum HviK-Server (apworld 0.4.3 von NaveTK).
. "$PSScriptRoot\hvik.ps1"
$ApWorld = "https://github.com/NaveTK/Archipelago/releases/download/v0.4.3/tboir.apworld"
$WorkshopId = "3640861678"

# Einen Wert in host.yaml setzen (Abschnitt auf oberster Ebene, Schluessel eingerueckt). Rest bleibt, ohne BOM.
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

Say "[1/4] Archipelago und Isaac suchen ..."
Test-Archipelago
$game = Find-SteamGame 250900
if (-not $game) { Fail "The Binding of Isaac: Rebirth ist nicht installiert (Steam). Bitte erst installieren." }
if (-not (Test-Path (Join-Path $game "resources-dlc3"))) {
    Fail "Repentance fehlt. Du brauchst Isaac mit allen DLCs bis Repentance (oder Repentance+)."
}
Ok "Gefunden: $game"

Say "[2/4] Isaac Client fuer Archipelago (tboir.apworld 0.4.3) ..."
$worlds = Join-Path $HviK.ApDir "custom_worlds"
New-Item -ItemType Directory -Force $worlds | Out-Null
$apworld = Get-File $ApWorld "tboir.apworld"
Copy-Item $apworld (Join-Path $worlds "tboir.apworld") -Force
Ok "tboir.apworld installiert."

Say "[3/4] Spielordner in Archipelago eintragen (host.yaml) ..."
$hostYaml = Join-Path $HviK.ApDir "host.yaml"
Set-HostYamlValue $hostYaml "tboir_options" "game_folder" ('"' + $game.Replace('\', '\\') + '"')
Ok "Eingetragen - der Isaac Client fragt nicht mehr nach dem Ordner."

Say "[4/4] Archipelago-Mod aus dem Steam Workshop ..."
$mods = Join-Path $game "mods"
$found = if (Test-Path $mods) { Get-ChildItem $mods -Directory | Where-Object { Test-Path (Join-Path $_.FullName "supported_client") } } else { @() }
if ($found) {
    Ok "Mod ist schon da: $($found[0].Name)"
} else {
    Say "Ich oeffne jetzt die Workshop-Seite von '!The Archipelago of Isaac'." Yellow
    Say "Dort einmal 'Abonnieren' klicken. Danach Isaac EINMAL starten - dann kopiert das Spiel den Mod." Yellow
    Start-Process "steam://url/CommunityFilePage/$WorkshopId"
}

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "WICHTIG: Du brauchst einen Spielstand, in dem die Wege zu den spaeten Endbossen schon offen sind" Yellow
Say "(Mega Satan, The Void/Delirium, Mother, The Beast) - am besten deinen Hauptspielstand nehmen." Yellow
Say "Am Spieltag: START.bat doppelklicken."
