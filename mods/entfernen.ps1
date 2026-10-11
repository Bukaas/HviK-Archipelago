# HviK Link entfernen: alle "(HviK Link)"-Profile aus CurseForge loeschen (in den Papierkorb - Welten lassen sich
# von dort noch zurueckholen). Das normale Modpack-Profil bleibt unveraendert. Nur ASCII im Skript.
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
function Say([string]$t, [string]$c = "Gray") { Write-Host "  $t" -ForegroundColor $c }

$roots = @((Join-Path $env:USERPROFILE "curseforge\minecraft\Instances"), (Join-Path $env:USERPROFILE "Documents\Curseforge\Minecraft\Instances"),
           (Join-Path $env:USERPROFILE "Documents\CurseForge\minecraft\Instances"))
foreach ($drive in (Get-PSDrive -PSProvider FileSystem | Select-Object -ExpandProperty Root)) {
    $roots += (Join-Path $drive "curseforge\minecraft\Instances")
    $roots += (Join-Path $drive "CurseForge\Minecraft\Instances")
}
$found = @()
foreach ($root in ($roots | Where-Object { Test-Path $_ } | Select-Object -Unique)) {
    $found += @(Get-ChildItem $root -Directory | Where-Object { $_.Name -like "* (HviK Link)" })
}
if (-not $found) { Say "Kein '(HviK Link)'-Profil gefunden - nichts zu tun." Green; exit 0 }

Say "Diese CurseForge-Profile werden geloescht (inklusive ihrer Welten):" Yellow
foreach ($d in $found) { Say "   - $($d.Name)" Yellow }
Write-Host ""
$answer = Read-Host "  Wirklich loeschen? (j/n)"
if ($answer -notmatch '^(j|ja|y|yes)$') { Say "Abgebrochen - nichts geloescht."; exit 0 }

$mc = Get-CimInstance Win32_Process -Filter "Name='javaw.exe' OR Name='java.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -like "*(HviK Link)*" }
if ($mc) { Say "[!] Minecraft laeuft noch mit einem HviK-Link-Profil - bitte erst das Spiel schliessen." Red; exit 1 }

# CurseForge muss zu sein (sonst haelt es die Profile fest) - wir schliessen es und starten es am Ende neu
$cfExe = $null
$cf = @(Get-Process -Name "CurseForge" -ErrorAction SilentlyContinue)
if ($cf) {
    $cfExe = ($cf | Where-Object { $_.Path } | Select-Object -First 1).Path
    Say "CurseForge wird kurz geschlossen ..."
    foreach ($p in $cf) { try { [void]$p.CloseMainWindow() } catch {} }
    for ($i = 0; $i -lt 16 -and (Get-Process -Name "CurseForge" -ErrorAction SilentlyContinue); $i++) { Start-Sleep -Milliseconds 500 }
    Get-Process -Name "CurseForge", "Curse.Agent.Host" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

Add-Type -AssemblyName Microsoft.VisualBasic
$n = 0
foreach ($d in $found) {
    try {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($d.FullName, 'OnlyErrorDialogs', 'SendToRecycleBin')
        Say "[OK] Geloescht: $($d.Name) (liegt im Papierkorb)" Green
        $n++
    } catch {
        Say "[!] Konnte '$($d.Name)' nicht loeschen: $($_.Exception.Message)" Red
    }
}

if (-not $cfExe) {
    $cfExe = @((Join-Path $env:LOCALAPPDATA "Programs\CurseForge Windows\CurseForge.exe"),
               (Join-Path $env:ProgramFiles "CurseForge Windows\CurseForge.exe")) | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if ($cf -and $cfExe -and (Test-Path $cfExe)) {
    Start-Process $cfExe
    Say "[OK] CurseForge wird wieder gestartet." Green
}
Write-Host ""
Say "Fertig - $n Profil(e) entfernt. Dein normales Modpack-Profil ist unveraendert." Green
