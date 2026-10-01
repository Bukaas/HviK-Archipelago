# HviK Archipelago - Monster Hunter: World: gemeinsame Werte.
# Erweiterung "MHW Archipelago" (QPL22) v0.1.3 alpha. Braucht Stracker's Loader + Performance Booster (nur NexusMods,
# dort ist ein Login noetig - die laedt jeder selbst, das Paket installiert sie dann) und pro Runde den MHWGenerator.
$MHW_APPID = 582010
$MHW_GEN_VERSION = "v0.1.3-alpha"
$MHW_GEN_URL = "https://github.com/QPL22/MHW_Archipelago/releases/download/v0.1.3-alpha/MHWGenerator-v0.1.3.zip"
$MHW_GEN_DIR = Join-Path $HviK.Root "MHWGenerator"
$MHW_GEN_EXE = Join-Path $MHW_GEN_DIR "ArchipelagoGenerator.exe"
$MHW_NEXUS = @(
    @{ Name = "Stracker's Loader"; Url = "https://www.nexusmods.com/monsterhunterworld/mods/1982?tab=files"; Pattern = "(?i)stracker|-1982-" },
    @{ Name = "Performance Booster and Plugin Extender"; Url = "https://www.nexusmods.com/monsterhunterworld/mods/3473?tab=files"; Pattern = "(?i)performance.?booster|-3473-" }
)

# Ein Archiv (.zip/.7z) in den Spielordner entpacken - Windows-tar, sonst 7zr.exe (Windows 10 kann kein 7z)
function Expand-AnyArchive([string]$File, [string]$Dest) {
    if ($File -match '\.zip$') { Expand-Archive -Path $File -DestinationPath $Dest -Force; return }
    try { & tar -xf $File -C $Dest 2>$null } catch { }
    if ($LASTEXITCODE -ne 0) {
        $sevenZip = Join-Path $env:TEMP "hvik-archipelago\7zr.exe"
        if (-not (Test-Path $sevenZip)) {
            New-Item -ItemType Directory -Force (Split-Path $sevenZip) | Out-Null
            Invoke-WebRequest -Uri "https://www.7-zip.org/a/7zr.exe" -OutFile $sevenZip -UseBasicParsing -UserAgent "Mozilla/5.0"
        }
        & $sevenZip x $File "-o$Dest" -y | Out-Null
    }
}

# .NET 8 Desktop Runtime - braucht der MHWGenerator
function Install-DotNet8Desktop {
    $shared = Join-Path $env:ProgramFiles "dotnet\shared\Microsoft.WindowsDesktop.App"
    if (Get-ChildItem $shared -Directory -Filter "8.*" -ErrorAction SilentlyContinue) { Ok ".NET 8 ist schon da."; return }
    $exe = Get-File "https://aka.ms/dotnet/8.0/windowsdesktop-runtime-win-x64.exe" "dotnet8-desktop.exe"
    Say "Installiere .NET 8 (Windows fragt evtl. nach Erlaubnis) ..."
    $p = Start-Process $exe -ArgumentList "/install", "/quiet", "/norestart" -Verb RunAs -Wait -PassThru
    if ($p.ExitCode -ne 0 -and $p.ExitCode -ne 3010) { Fail ".NET 8 konnte nicht installiert werden (Code $($p.ExitCode))." }
    Ok ".NET 8 installiert."
}
