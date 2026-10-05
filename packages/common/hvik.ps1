# HviK Archipelago - gemeinsame Helfer fuer EINRICHTEN/START (wird per ". hvik.ps1" eingebunden).
# Nur ASCII-Text ausgeben: Windows PowerShell 5.1 liest Skripte ohne BOM als ANSI.
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"   # macht Invoke-WebRequest um ein Vielfaches schneller
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$HviK = @{
    Server   = "hvik.org:38281"
    Api      = "https://hvik.org/api/archipelago/runde.json"
    ApDir    = "C:\ProgramData\Archipelago"
    ApUrl    = "https://github.com/ArchipelagoMW/Archipelago/releases/tag/0.6.7"
    Root     = Split-Path $PSScriptRoot -Parent   # der Paket-Ordner
}

function Say([string]$Text, [string]$Color = "Gray") { Write-Host "  $Text" -ForegroundColor $Color }
function Ok([string]$Text) { Say "[OK] $Text" Green }
function Fail([string]$Text) { Say "[!] $Text" Red; exit 1 }

function Get-SteamDir {
    foreach ($key in "HKCU:\Software\Valve\Steam", "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam") {
        $p = Get-ItemProperty $key -ErrorAction SilentlyContinue
        foreach ($v in $p.SteamPath, $p.InstallPath) {
            if ($v -and (Test-Path (Join-Path $v "steam.exe"))) { return (Resolve-Path $v).Path }
        }
    }
    return $null
}

# Installationsordner eines Steam-Spiels ueber alle Bibliotheken (libraryfolders.vdf) suchen.
function Find-SteamGame([int]$AppId) {
    $steam = Get-SteamDir
    if (-not $steam) { return $null }
    $libs = @($steam)
    $vdf = Join-Path $steam "steamapps\libraryfolders.vdf"
    if (Test-Path $vdf) {
        foreach ($m in [regex]::Matches((Get-Content $vdf -Raw), '"path"\s+"([^"]+)"')) {
            $libs += $m.Groups[1].Value.Replace("\\", "\")
        }
    }
    foreach ($lib in ($libs | Select-Object -Unique)) {
        $acf = Join-Path $lib "steamapps\appmanifest_$AppId.acf"
        if (Test-Path $acf) {
            $m = [regex]::Match((Get-Content $acf -Raw), '"installdir"\s+"([^"]+)"')
            $dir = Join-Path $lib "steamapps\common\$($m.Groups[1].Value)"
            if ($m.Success -and (Test-Path $dir)) { return $dir }
        }
    }
    return $null
}

function Get-File([string]$Url, [string]$Name) {
    $dl = Join-Path $env:TEMP "hvik-archipelago"
    New-Item -ItemType Directory -Force $dl | Out-Null
    $out = Join-Path $dl $Name
    Say "Lade $Name ..."
    try { Invoke-WebRequest -Uri $Url -OutFile $out -UseBasicParsing }
    catch { Fail "Download fehlgeschlagen ($Name). Internet da? Sonst beim Host melden." }
    return $out
}

function Expand-Zip([string]$Zip, [string]$Dest) {
    New-Item -ItemType Directory -Force $Dest | Out-Null
    Expand-Archive -Path $Zip -DestinationPath $Dest -Force
}

function Test-Archipelago {
    if (Test-Path (Join-Path $HviK.ApDir "ArchipelagoLauncher.exe")) { return }
    Say "Archipelago ist noch nicht installiert." Yellow
    Say "Ich oeffne die Download-Seite: 'Setup.Archipelago....exe' laden, installieren" Yellow
    Say "und danach EINRICHTEN.bat nochmal starten." Yellow
    Start-Process $HviK.ApUrl
    exit 1
}

# .NET 6 Desktop Runtime (fuer DS3-Randomizer und Vampire-Survivors-Mod).
function Install-DotNet6 {
    $shared = Join-Path $env:ProgramFiles "dotnet\shared\Microsoft.WindowsDesktop.App"
    if (Get-ChildItem $shared -Directory -Filter "6.*" -ErrorAction SilentlyContinue) { Ok ".NET 6 ist schon da."; return }
    $exe = Get-File "https://aka.ms/dotnet/6.0/windowsdesktop-runtime-win-x64.exe" "dotnet6-desktop.exe"
    Say "Installiere .NET 6 (Windows fragt evtl. nach Erlaubnis) ..."
    $p = Start-Process $exe -ArgumentList "/install", "/quiet", "/norestart" -Verb RunAs -Wait -PassThru
    if ($p.ExitCode -ne 0 -and $p.ExitCode -ne 3010) { Fail ".NET 6 konnte nicht installiert werden (Code $($p.ExitCode))." }
    Ok ".NET 6 installiert."
}

# Spielername merken (name.txt im Paket-Ordner) - Enter uebernimmt den gespeicherten.
function Get-PlayerName {
    $file = Join-Path $HviK.Root "name.txt"
    $saved = if (Test-Path $file) { (Get-Content $file -Raw).Trim() } else { "" }
    while ($true) {
        $hint = if ($saved) { " [Enter = $saved]" } else { "" }
        $n = (Read-Host "  Dein Name in der Runde (steht auf hvik.org bei 'Dein Name im Spiel')$hint").Trim()
        if (-not $n) { $n = $saved }
        if ($n -match '^[A-Za-z0-9_\-]{1,16}$') { break }
        Say "Nur Buchstaben, Zahlen, _ und -, max. 16 Zeichen." Yellow
    }
    [IO.File]::WriteAllText($file, $n)
    return $n
}

# Aktuelle Runde von hvik.org (status, seed) - $null, wenn nicht erreichbar.
function Get-Round {
    try { return (Invoke-RestMethod -Uri $HviK.Api -TimeoutSec 10).round } catch { return $null }
}

function Copy-ToClipboard([string]$Text) {
    try { Set-Clipboard -Value $Text } catch { $Text | clip.exe }
}

# Welcher Archipelago-Server? Es koennen mehrere Runden gleichzeitig laufen (je eigener Port).
# 1. deine-runde\server.txt (liegt im persoenlichen Download)  2. die Runde, in der dein Name mitspielt
# 3. es laeuft nur eine Runde  4. sonst der Standard hvik.org:38281
function Resolve-HviKServer {
    $txt = Join-Path $HviK.Root "deine-runde\server.txt"
    if (Test-Path $txt) {
        $s = (Get-Content $txt -Raw).Trim()
        if ($s -match '^[A-Za-z0-9.\-]+:\d+$') { return $s }
    }
    $rounds = @()
    try { $rounds = @((Invoke-RestMethod -Uri $HviK.Api -TimeoutSec 10).rounds) } catch { return $HviK.Server }
    $rounds = @($rounds | Where-Object { $_ -and $_.server })
    if ($rounds.Count -eq 0) { return $HviK.Server }
    if ($rounds.Count -eq 1) { return $rounds[0].server }
    $nameFile = Join-Path $HviK.Root "name.txt"
    $name = if (Test-Path $nameFile) { (Get-Content $nameFile -Raw).Trim() } else { "" }
    $caller = Split-Path -Leaf ($MyInvocation.PSCommandPath)
    if (-not $name -and $caller -like "start*") {
        Say "Es laufen gerade mehrere Runden - dein Name sagt mir, welche deine ist." Yellow
        $name = Get-PlayerName
    }
    $mine = $rounds | Where-Object { $_.slots -contains $name } | Select-Object -First 1
    if ($mine) { return $mine.server }
    return $HviK.Server
}
$HviK.Server = Resolve-HviKServer
