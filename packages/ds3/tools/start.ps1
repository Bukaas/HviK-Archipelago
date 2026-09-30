# HviK Archipelago - Dark Souls III starten.
# Neue Runde (Seed auf hvik.org != Seed in apconfig.json)? -> Randomizer mit Adresse+Name vorausgefuellt oeffnen,
# "Load" klicken, Fenster schliessen. Danach startet das Spiel ueber ModEngine2.
. "$PSScriptRoot\hvik.ps1"
$mod = Join-Path $HviK.Root "mod"
if (-not (Test-Path (Join-Path $mod "launchmod_darksouls3.bat"))) { Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken." }
$name = Get-PlayerName

$cfgFile = Join-Path $mod "apconfig.json"
$cfg = if (Test-Path $cfgFile) { Get-Content $cfgFile -Raw | ConvertFrom-Json } else { [pscustomobject]@{} }
$round = Get-Round
$needRandomizer = -not $cfg.seed -or $cfg.slot -ne $name -or ($round -and $round.seed -and $round.seed -ne $cfg.seed)
if (-not $round) { Say "hvik.org nicht erreichbar - ich nehme an, es ist dieselbe Runde wie letztes Mal." Yellow }

if ($needRandomizer) {
    # Adresse und Name vorausfuellen - der Randomizer liest sie beim Start aus apconfig.json
    $cfg | Add-Member -Force NoteProperty url $HviK.Server
    $cfg | Add-Member -Force NoteProperty slot $name
    [IO.File]::WriteAllText($cfgFile, ($cfg | ConvertTo-Json), (New-Object Text.UTF8Encoding $false))
    Write-Host ""
    Say "Neue Runde! Gleich geht der Randomizer auf:" Cyan
    Say "  1. Adresse ($($HviK.Server)) und Name ($name) stehen schon drin." Cyan
    Say "  2. 'Load' klicken und warten (1-2 Minuten), bis er fertig meldet." Cyan
    Say "  3. Randomizer-Fenster schliessen - dann startet das Spiel." Cyan
    Start-Process (Join-Path $mod "randomizer\DS3Randomizer.exe") -WorkingDirectory (Join-Path $mod "randomizer") -Wait
    $cfg = Get-Content $cfgFile -Raw | ConvertFrom-Json
    if (-not $cfg.seed -or ($round -and $round.seed -and $round.seed -ne $cfg.seed)) {
        Fail "Der Randomizer ist nicht durchgelaufen - START.bat nochmal starten und 'Load' klicken."
    }
    Ok "Randomizer fertig."
}

Say "Starte Dark Souls III (Steam muss laufen, aber NICHT im Offline-Modus) ..."
Start-Process "cmd.exe" -ArgumentList "/c", "launchmod_darksouls3.bat" -WorkingDirectory $mod
Write-Host ""
Ok "Spiel startet. Sobald du deinen Charakter steuerst, erscheint 'Archipelago connected'."
Say "Im Spiel muss das Netzwerk auf OFFLINE stehen (Optionen -> Netzwerk)." Yellow
