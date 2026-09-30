# HviK Archipelago - Vampire Survivors einmalig einrichten:
# eigene Kopie "Vampire Survivors AP" (Spiel 1.14.112 + DLCs, die man besitzt) in diesem Ordner,
# dazu .NET 6, MelonLoader 0.7.3, CoffinTech v1.2.3 und ArchipelagoSurvivors v0.3.5.1 (passend zum HviK-Server).
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\vsap.ps1"

Say "[1/6] Steam und Vampire Survivors suchen ..."
if (-not (Get-SteamDir)) { Fail "Steam nicht gefunden. Bitte Steam installieren und anmelden." }
if (-not (Find-SteamGame 1794680)) { Say "Vampire Survivors ist in Steam nicht installiert - das ist ok, solange du es besitzt." Yellow }
if (-not (Get-Process steam -ErrorAction SilentlyContinue)) {
    Say "Starte Steam ..."; Start-Process "steam://open/main"; Start-Sleep -Seconds 15
}
$dlcs = @(Get-OwnedDlcDepots)
Ok ("Gefunden." + $(if ($dlcs) { " DLCs: " + (($dlcs | ForEach-Object Name) -join ", ") } else { " Keine DLCs." }))

Say "[2/6] Spielversion $VS_VERSION laden (ueber die Steam-Konsole, ohne Passwort) ..."
if (Test-Is114 $VS_DIR) {
    Ok "Die AP-Kopie hat schon Version $VS_VERSION."
} else {
    Request-Depot $VS_DEPOTS[0] { param($dir) Test-Is114 $dir }
    foreach ($d in $dlcs) { Request-Depot $d { param($dir) Test-Path (Join-Path $dir "*") } }
    Say "Kopiere nach $VS_DIR ..."
    New-Item -ItemType Directory -Force $VS_DIR | Out-Null
    Copy-Depot $VS_DEPOTS[0]
    foreach ($d in $dlcs) { Copy-Depot $d }
    if (-not (Test-Is114 $VS_DIR)) { Fail "Nach dem Kopieren passt die Version nicht - beim Host melden." }
    Ok "Vampire Survivors AP ($VS_VERSION) angelegt."
}
$tmp = Join-Path $env:TEMP ("hvik-archipelago\vampire-" + (Get-Date -Format "HHmmss"))
New-Item -ItemType Directory -Force $tmp, (Join-Path $VS_DIR "Mods"), (Join-Path $VS_DIR "UserLibs") | Out-Null

Say "[3/6] .NET 6 ..."
Install-DotNet6

Say "[4/6] MelonLoader 0.7.3 (Mod-Loader) ..."
$z = Get-File "https://github.com/LavaGang/MelonLoader/releases/download/v0.7.3/MelonLoader.x64.zip" "MelonLoader073.x64.zip"
Expand-Zip $z $VS_DIR
Ok "MelonLoader installiert."

Say "[5/6] CoffinTech (Hilfs-Mod) ..."
$z = Get-File "https://github.com/takacomic/CoffinTech/releases/download/v1.2.3/CoffinTech.dll" "CoffinTech.dll"
Copy-Item $z (Join-Path $VS_DIR "Mods\CoffinTech.dll") -Force
Ok "CoffinTech installiert."

Say "[6/6] ArchipelagoSurvivors-Mod ..."
$z = Get-File "https://github.com/SWCreeperKing/ArchipelagoSurvivors/releases/download/v0.3.5.1/ArchipelagoSurvivors.zip" "ArchipelagoSurvivors.zip"
Expand-Zip $z $tmp
Copy-Item "$tmp\ArchipelagoSurvivors\Mods\*" (Join-Path $VS_DIR "Mods") -Recurse -Force
Copy-Item "$tmp\ArchipelagoSurvivors\UserLibs\*" (Join-Path $VS_DIR "UserLibs") -Recurse -Force
Ok "Mod installiert."

$lnk = Join-Path ([Environment]::GetFolderPath("Desktop")) "Vampire Survivors AP.lnk"
$s = (New-Object -ComObject WScript.Shell).CreateShortcut($lnk)
$s.TargetPath = Join-Path $VS_DIR "VampireSurvivors.exe"; $s.WorkingDirectory = $VS_DIR; $s.Save()

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: START.bat doppelklicken (Steam muss laufen)."
Say "Der erste Start dauert ein paar Minuten (MelonLoader richtet sich ein) - Fenster nicht schliessen."
Say "Dein normales Vampire Survivors in Steam bleibt unveraendert."
