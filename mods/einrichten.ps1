# HviK Link einrichten: CurseForge-Profil des Modpacks kopieren ("<Name> (HviK Link)") und Mod + Konfiguration hineinlegen.
# Das normale Profil bleibt unveraendert. Nur ASCII im Skript (Windows PowerShell 5.1).
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
function Say([string]$t, [string]$c = "Gray") { Write-Host "  $t" -ForegroundColor $c }
function Ok([string]$t) { Say "[OK] $t" Green }
function Fail([string]$t) { Say "[!] $t" Red; exit 1 }

$here = $PSScriptRoot
$pack = Get-Content (Join-Path $here "pack.json") -Raw | ConvertFrom-Json
$jar = Join-Path $here $pack.jar
$suffix = " (HviK Link)"

if (Get-Process -Name "CurseForge" -ErrorAction SilentlyContinue) {
    Fail "Bitte CurseForge erst komplett schliessen (auch unten rechts im Infobereich) und nochmal starten."
}

# CurseForge-Profilordner suchen
$roots = @(
    (Join-Path $env:USERPROFILE "curseforge\minecraft\Instances"),
    (Join-Path $env:USERPROFILE "Documents\Curseforge\Minecraft\Instances"),
    (Join-Path $env:USERPROFILE "Documents\CurseForge\minecraft\Instances")
)
foreach ($drive in (Get-PSDrive -PSProvider FileSystem | Select-Object -ExpandProperty Root)) {
    $roots += (Join-Path $drive "curseforge\minecraft\Instances")
    $roots += (Join-Path $drive "CurseForge\Minecraft\Instances")
}
$roots = $roots | Where-Object { Test-Path $_ } | Select-Object -Unique
if (-not $roots) {
    Add-Type -AssemblyName System.Windows.Forms
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = "CurseForge-Ordner 'Instances' waehlen (CurseForge: Einstellungen -> Minecraft -> Modding-Ordner)"
    if ($dlg.ShowDialog() -ne "OK") { Fail "Kein Ordner gewaehlt." }
    $roots = @($dlg.SelectedPath)
}

# Profile dieses Modpacks finden (ohne unsere Kopien)
$found = @()
foreach ($root in $roots) {
    foreach ($dir in Get-ChildItem $root -Directory -ErrorAction SilentlyContinue) {
        $f = Join-Path $dir.FullName "minecraftinstance.json"
        if (-not (Test-Path $f) -or $dir.Name.EndsWith($suffix)) { continue }
        $raw = Get-Content $f -Raw
        $byId = $raw -match ('"(addonID|projectID)"\s*:\s*' + $pack.cf_project + '\b')
        $byName = $dir.Name -like "$($pack.name)*"
        if ($byId -or $byName) { $found += $dir }
    }
}
if (-not $found) {
    Say "$($pack.name) ist in CurseForge noch nicht installiert." Yellow
    if ($pack.cf_file) { Start-Process "curseforge://install?addonId=$($pack.cf_project)&fileId=$($pack.cf_file)" }
    else { Start-Process "curseforge://install?addonId=$($pack.cf_project)" }
    Fail "Ich habe die Installation in CurseForge geoeffnet. Danach CurseForge schliessen und EINRICHTEN.bat nochmal starten."
}
$src = $found[0]
if ($found.Count -gt 1) {
    Say "Mehrere Profile gefunden:"
    for ($i = 0; $i -lt $found.Count; $i++) { Say "  [$($i + 1)] $($found[$i].Name)" }
    $pick = Read-Host "  Welches kopieren? (Nummer)"
    if ($pick -match '^\d+$' -and [int]$pick -ge 1 -and [int]$pick -le $found.Count) { $src = $found[[int]$pick - 1] }
}
Ok "Modpack gefunden: $($src.FullName)"

$dstName = $src.Name + $suffix
$dst = Join-Path $src.Parent.FullName $dstName
if (-not (Test-Path $dst)) {
    Say "Kopiere das Profil nach '$dstName' (ohne Welten, das kann ein paar Minuten dauern) ..."
    & robocopy $src.FullName $dst /E /XD saves logs crash-reports screenshots backups simplebackups /NFL /NDL /NJH /NJS /NP /R:1 /W:1 | Out-Null
    if ($LASTEXITCODE -ge 8) { Fail "Kopieren fehlgeschlagen (robocopy $LASTEXITCODE)." }
    $jf = Join-Path $dst "minecraftinstance.json"
    $j = Get-Content $jf -Raw | ConvertFrom-Json
    $j.name = $dstName
    if ($j.PSObject.Properties.Name -contains "installPath") { $j.installPath = $dst.TrimEnd('\') + '\' }
    if ($j.PSObject.Properties.Name -contains "guid") { $j.guid = [guid]::NewGuid().ToString() }
    [IO.File]::WriteAllText($jf, ($j | ConvertTo-Json -Depth 100 -Compress), (New-Object Text.UTF8Encoding $false))
    Ok "Profil kopiert."
} else {
    Ok "Profil '$dstName' gibt es schon - ich aktualisiere nur die Mod."
}

$mods = Join-Path $dst "mods"
$config = Join-Path $dst "config"
New-Item -ItemType Directory -Force $mods, $config | Out-Null
Get-ChildItem $mods -Filter "hviklink-*.jar" | Remove-Item -Force
Copy-Item $jar $mods -Force
Copy-Item (Join-Path $here "hviklink.json") (Join-Path $config "hviklink.json") -Force
Ok "Mod und Link-Daten eingetragen."

Write-Host ""
Say "Fertig!" Green
Say "CurseForge starten -> Profil '$dstName' spielen -> Welt laden (am besten eine NEUE Welt)."
Say "Dann erscheint die HviK-Link-Lobby: 'Bereit' klicken, der Host startet."
