# HviK Link entfernen: Mod und Link-Daten aus allen "(HviK Link)"-Profilen nehmen. Das Profil selbst bleibt
# (in CurseForge loeschen, wenn du es nicht mehr brauchst). Nur ASCII im Skript.
$ErrorActionPreference = "Stop"
function Say([string]$t, [string]$c = "Gray") { Write-Host "  $t" -ForegroundColor $c }
$roots = @((Join-Path $env:USERPROFILE "curseforge\minecraft\Instances"), (Join-Path $env:USERPROFILE "Documents\Curseforge\Minecraft\Instances"))
foreach ($drive in (Get-PSDrive -PSProvider FileSystem | Select-Object -ExpandProperty Root)) { $roots += (Join-Path $drive "curseforge\minecraft\Instances") }
$n = 0
foreach ($root in ($roots | Where-Object { Test-Path $_ } | Select-Object -Unique)) {
    foreach ($dir in Get-ChildItem $root -Directory | Where-Object { $_.Name -like "* (HviK Link)" }) {
        Get-ChildItem (Join-Path $dir.FullName "mods") -Filter "hviklink-*.jar" -ErrorAction SilentlyContinue | Remove-Item -Force
        Remove-Item (Join-Path $dir.FullName "config\hviklink.json") -Force -ErrorAction SilentlyContinue
        Say "[OK] Entfernt aus: $($dir.Name)" Green
        $n++
    }
}
if ($n -eq 0) { Say "Kein '(HviK Link)'-Profil gefunden - nichts zu tun." }
else { Say "Das Profil selbst kannst du in CurseForge loeschen, wenn du es nicht mehr brauchst." }
