# HviK Archipelago - Stardew Valley einmalig einrichten: SMAPI still installieren, StardewArchipelago in Mods.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\stardew.ps1"

Say "[1/3] Stardew Valley suchen ..."
$game = Find-SteamGame $SDV_APPID
if (-not $game) { Fail "Stardew Valley ist nicht installiert (Steam). Bitte erst installieren." }
Ok "Gefunden: $game"
Get-Process "Stardew Valley", StardewModdingAPI -ErrorAction SilentlyContinue | ForEach-Object { Fail "Stardew Valley laeuft noch - bitte erst beenden." }
$tmp = Join-Path $env:TEMP ("hvik-archipelago\stardew-" + (Get-Date -Format HHmmss))

Say "[2/3] SMAPI $SDV_SMAPI_VERSION (Mod-Loader) ..."
$z = Get-File $SDV_SMAPI_URL "SMAPI-$SDV_SMAPI_VERSION-installer.zip"
Expand-Zip $z "$tmp\smapi"
$installer = Get-ChildItem "$tmp\smapi" -Recurse -Filter "SMAPI.Installer.exe" | Where-Object { $_.Directory.Name -eq 'windows' } | Select-Object -First 1
if (-not $installer) { Fail "SMAPI-Installer nicht gefunden - beim Host melden." }
# --no-prompt: ohne Rueckfragen; installiert/aktualisiert SMAPI im angegebenen Spielordner
$p = Start-Process $installer.FullName -ArgumentList "--install", "--no-prompt", "--game-path", "`"$game`"" -WorkingDirectory $installer.DirectoryName -Wait -PassThru -NoNewWindow
if (-not (Test-Path (Join-Path $game "StardewModdingAPI.exe"))) { Fail "SMAPI konnte nicht installiert werden (Code $($p.ExitCode)) - beim Host melden." }
Ok "SMAPI installiert."

Say "[3/3] StardewArchipelago $SDV_MOD_VERSION ..."
$z = Get-File $SDV_MOD_URL "StardewArchipelago.$SDV_MOD_VERSION.zip"
Expand-Zip $z "$tmp\mod"
$mods = Join-Path $game "Mods"
$target = Join-Path $mods "StardewArchipelago"
New-Item -ItemType Directory -Force $mods | Out-Null
if (Test-Path $target) { Remove-Item $target -Recurse -Force }
Copy-Item "$tmp\mod\StardewArchipelago" $mods -Recurse -Force
if (-not (Test-Path (Join-Path $target "StardewArchipelago.dll"))) { Fail "Mod fehlt nach dem Kopieren - beim Host melden." }
Ok "Mod installiert."
Get-PlayerName | Out-Null

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: START.bat -> neue Farm -> in den drei Archipelago-Feldern Server + Name -> los."
Say "Mods wieder aus: Stardew einfach normal ueber Steam starten (ohne SMAPI)."
