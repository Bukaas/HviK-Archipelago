# HviK Archipelago - Vampire Survivors: eigene "Vampire Survivors AP"-Kopie auf Spielversion 1.14.112.
# Der Mod laeuft nur bis 1.14: ab 1.15 nutzt das Spiel Unity 6000.0.62, damit stuerzt MelonLoader ab.
# Nachbau des Community-Installers (takacomic/VSModdedScript, Pins im AP-Discord) - aber ueber die
# Steam-Konsole statt DepotDownloader, damit KEIN Steam-Passwort / Steam-Guard-Code noetig ist.
# Das normale Steam-Spiel bleibt unangetastet.

# Manifeste fuer 1.14 (aus VSModdedScript); Hauptspiel + DLCs
$VS_DEPOTS = @(
    @{ App = 1794680; Depot = 1794681; Manifest = "5929929350734574725"; Name = "Hauptspiel" },
    @{ App = 2230760; Depot = 2230761; Manifest = "6626234685557471330"; Name = "Legacy of the Moonspell" },
    @{ App = 2313550; Depot = 2313551; Manifest = "258978471953775490";  Name = "Tides of the Foscari" },
    @{ App = 2690330; Depot = 2690331; Manifest = "1027692196364748982"; Name = "Emergency Meeting" },
    @{ App = 2887680; Depot = 2887681; Manifest = "3914729547287146862"; Name = "Operation Guns" },
    @{ App = 3210350; Depot = 3210351; Manifest = "1856258357613603873"; Name = "Ode to Castlevania" },
    @{ App = 3451100; Depot = 3451101; Manifest = "7326781866595278644"; Name = "Emerald Diorama" },
    @{ App = 3929770; Depot = 3929771; Manifest = "239795049570881193";  Name = "Ante Chamber" }
)
# Fingerabdruck von GameAssembly.dll in 1.14.112 - so erkennen wir den richtigen Download sicher
$VS_GAMEASSEMBLY_SHA256 = "2BAE3D322BD3B8EAEBC158DC36B34220F50AFDF0F8C80C62D486EEAFCC59D04A"
$VS_VERSION = "1.14.112"

function Get-DepotDir($d) { Join-Path (Get-SteamDir) "steamapps\content\app_$($d.App)\depot_$($d.Depot)" }

function Test-Is114([string]$Dir) {
    $ga = Join-Path $Dir "GameAssembly.dll"
    (Test-Path $ga) -and (Get-FileHash $ga).Hash -eq $VS_GAMEASSEMBLY_SHA256
}

# Gibt es schon eine Kopie vom Community-Installer (Discord)? Dann die nehmen, sonst im Paket-Ordner anlegen.
$VS_COMMUNITY_DIR = "C:\ProgramData\Archipelago\Vampire Survivors AP"
$VS_DIR = if (Test-Is114 $VS_COMMUNITY_DIR) { $VS_COMMUNITY_DIR } else { Join-Path $HviK.Root "Vampire Survivors AP" }

# DLCs, die der Spieler besitzt: Steam installiert deren Depots mit dem normalen Spiel mit.
function Get-OwnedDlcDepots {
    $owned = @()
    $steam = Get-SteamDir
    $libs = @($steam)
    $vdf = Join-Path $steam "steamapps\libraryfolders.vdf"
    if (Test-Path $vdf) { foreach ($m in [regex]::Matches((Get-Content $vdf -Raw), '"path"\s+"([^"]+)"')) { $libs += $m.Groups[1].Value.Replace("\\", "\") } }
    foreach ($lib in ($libs | Select-Object -Unique)) {
        $acf = Join-Path $lib "steamapps\appmanifest_1794680.acf"
        if (-not (Test-Path $acf)) { continue }
        $text = Get-Content $acf -Raw
        foreach ($d in $VS_DEPOTS | Select-Object -Skip 1) { if ($text -match "`"$($d.Depot)`"") { $owned += $d } }
    }
    return $owned
}

# Ein Depot ueber die Steam-Konsole laden lassen (Spieler: Strg+V, Enter). $Check prueft, ob es fertig ist.
function Request-Depot($d, [scriptblock]$Check) {
    $dir = Get-DepotDir $d
    if (& $Check $dir) { Ok "$($d.Name) ($VS_VERSION) ist schon heruntergeladen."; return }
    if (Test-Path $dir) {
        # Reste einer anderen Version beiseitelegen, sonst mischt Steam alt und neu
        Move-Item $dir "$dir-alt-$(Get-Date -Format yyyyMMdd-HHmmss)" -Force
    }
    $cmd = "download_depot $($d.App) $($d.Depot) $($d.Manifest)"
    Copy-ToClipboard $cmd
    Write-Host ""
    Say "$($d.Name) $VS_VERSION ueber Steam laden:" Cyan
    Say "  1. In der Steam-Konsole ganz unten in die Eingabezeile klicken." Cyan
    Say "  2. Strg+V, Enter   (kopiert: $cmd)" Cyan
    Say "  3. Warten bis 'Depot download complete' dasteht, dann HIER Enter." Cyan
    Start-Process "steam://open/console"
    while ($true) {
        Read-Host "  Enter, wenn 'Depot download complete' dasteht" | Out-Null
        if (& $Check $dir) { break }
        Say "Noch nicht fertig. Warten und nochmal Enter. (Befehl ist wieder kopiert.)" Yellow
        Copy-ToClipboard $cmd
    }
    Ok "$($d.Name) geladen."
}

function Copy-Depot($d) {
    Get-ChildItem (Get-DepotDir $d) -Force | Where-Object { $_.Name -ne ".DepotDownloader" } |
        Copy-Item -Destination $VS_DIR -Recurse -Force
}
