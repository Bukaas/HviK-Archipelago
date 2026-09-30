# HviK Archipelago - Factorio mod-list.json anpassen.
#   -Mode archipelago -Mod <Pfad zur AP-....zip> : alte AP-Mods raus, diesen an, Space Age/Quality/Elevated Rails aus
#   -Mode normal                                 : Space Age & Co. wieder an, AP-Mods aus
# Speichert ohne BOM (Factorio mag keine BOM in der JSON).
param(
    [ValidateSet("archipelago", "normal")][string]$Mode,
    [string]$Mod = ""
)
$ErrorActionPreference = "Stop"
$dir = Join-Path $env:APPDATA "Factorio\mods"
$list = Join-Path $dir "mod-list.json"
$dlc = @("space-age", "quality", "elevated-rails")

if (Test-Path $list) { $j = Get-Content $list -Raw -Encoding UTF8 | ConvertFrom-Json } else { $j = [pscustomobject]@{ mods = @() } }

if ($Mode -eq "archipelago") {
    Get-ChildItem $dir -Filter "AP-*.zip" -ErrorAction SilentlyContinue | Remove-Item -Force
    Copy-Item $Mod $dir -Force
    $name = [IO.Path]::GetFileNameWithoutExtension($Mod) -replace '_[0-9.]+$', ''
    $mods = @($j.mods | Where-Object { $_.name -notlike "AP-*" })
    foreach ($m in $mods) { if ($dlc -contains $m.name) { $m.enabled = $false } }
    $mods += [pscustomobject]@{ name = $name; enabled = $true }
    $j.mods = $mods
} else {
    foreach ($m in $j.mods) {
        if ($dlc -contains $m.name) { $m.enabled = $true }
        if ($m.name -like "AP-*") { $m.enabled = $false }
    }
}
[IO.File]::WriteAllText($list, ($j | ConvertTo-Json -Depth 5), (New-Object Text.UTF8Encoding $false))
