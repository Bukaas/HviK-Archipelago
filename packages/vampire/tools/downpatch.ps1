# HviK Archipelago - Vampire Survivors auf 1.15.114 zuruecksetzen ("downpatchen").
# ArchipelagoSurvivors v0.3.5 laeuft nicht mit 1.16 (Parameter "count" in EnemyItemUI.SetData fehlt).
# Nur das Hauptspiel-Depot aendert sich; die DLC-Depots sind in 1.15.114 und 1.16.107 identisch.
# Quelle der Nummern: github.com/SurvivatonsAndMore/VampireSurvivorsFiles (Game Version.txt, v1.15.114).
$VS_DEPOT = 1794681
$VS_MANIFEST = "518547808310945487"
$VS_VERSION = "1.15.114"

function Get-DownpatchDir {
    Join-Path (Get-SteamDir) "steamapps\content\app_1794680\depot_$VS_DEPOT"
}

# $true, wenn im Spielordner genau die heruntergeladene alte Version liegt.
function Test-Downpatched([string]$Game) {
    $old = Join-Path (Get-DownpatchDir) "GameAssembly.dll"
    $cur = Join-Path $Game "GameAssembly.dll"
    if (-not (Test-Path $old) -or -not (Test-Path $cur)) { return $false }
    return (Get-FileHash $old).Hash -eq (Get-FileHash $cur).Hash
}

function Copy-Downpatch([string]$Game) {
    Say "Kopiere Version $VS_VERSION in den Spielordner ..."
    Get-Process VampireSurvivors -ErrorAction SilentlyContinue | Stop-Process -Force
    & robocopy (Get-DownpatchDir) $Game /E /NFL /NDL /NJH /NJS /NP | Out-Null
    if ($LASTEXITCODE -ge 8) { Fail "Kopieren fehlgeschlagen (robocopy $LASTEXITCODE)." }
    if (-not (Test-Downpatched $Game)) { Fail "Nach dem Kopieren passt die Version nicht - beim Host melden." }
    Ok "Vampire Survivors ist jetzt auf Version $VS_VERSION."
}

# Laedt (falls noetig) ueber die Steam-Konsole und kopiert die alte Version in den Spielordner.
function Invoke-Downpatch([string]$Game) {
    if (Test-Downpatched $Game) { Ok "Version $VS_VERSION ist schon drauf."; return }
    $dir = Get-DownpatchDir
    if (-not (Test-Path (Join-Path $dir "GameAssembly.dll"))) {
        $cmd = "download_depot 1794680 $VS_DEPOT $VS_MANIFEST"
        Copy-ToClipboard $cmd
        Write-Host ""
        Say "Die alte Spielversion muss einmal ueber Steam geladen werden:" Cyan
        Say "  1. Gleich geht Steam mit dem Reiter 'Konsole' auf." Cyan
        Say "  2. Ganz unten in die Eingabezeile klicken, Strg+V druecken, Enter." Cyan
        Say "     (Befehl ist schon kopiert: $cmd)" Cyan
        Say "  3. Warten, bis dort 'Depot download complete' steht (ein paar Minuten)." Cyan
        Say "  4. Dann hier zurueckkommen und Enter druecken." Cyan
        Start-Process "steam://open/console"
        while ($true) {
            Read-Host "  Enter druecken, wenn 'Depot download complete' da steht" | Out-Null
            if (Test-Path (Join-Path $dir "GameAssembly.dll")) { break }
            Say "Noch nicht fertig (Ordner $dir fehlt). Warten und nochmal Enter." Yellow
            Say "Befehl nochmal kopiert: $cmd" Yellow
            Copy-ToClipboard $cmd
        }
    }
    Copy-Downpatch $Game
}
