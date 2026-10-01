# HviK Archipelago - Hollow Knight: gemeinsame Pfade + Verbindung vorausfuellen.
# Modding API + Mods (wie Scarab/Lumafly sie installieren) liegen in hollow_knight_Data\Managed bzw. Managed\Mods.
$HK_APPID = 367520
$HK_API_URL = "https://github.com/hk-modding/api/releases/download/1.5.78.11833-77/moddingapi.v77.windows.zip"
$HK_API_SHA = "BC9F0DB3D0916B05CD5A2420BB602FB1B239CE3FF6C289FD84BFFB682FB8F1D6"
# Archipelago-Mod und seine Abhaengigkeiten (aus hk-modding/modlinks, feste Versionen + Pruefsummen)
$HK_MODS = @(
    @{ Name = "Archipelago"; Url = "https://github.com/ArchipelagoMW-HollowKnight/Archipelago.HollowKnight/releases/download/v0.12.0/Archipelago.zip"; Sha = "F54FB0972129" },
    @{ Name = "ItemChanger"; Url = "https://github.com/homothetyhk/HollowKnight.ItemChanger/releases/download/v2.1.6%2B927/ItemChanger.zip"; Sha = "7D1C01EB5F5D" },
    @{ Name = "MenuChanger"; Url = "https://github.com/homothetyhk/HollowKnight.MenuChanger/releases/download/v1.1.0%2B132/MenuChanger.zip"; Sha = "3F298454BDB8" },
    @{ Name = "Benchwarp"; Url = "https://github.com/homothetyhk/HollowKnight.BenchwarpMod/releases/download/v3.2.6.1/Benchwarp.zip"; Sha = "1610837E5CC0" },
    @{ Name = "QoL"; Url = "https://github.com/fifty-six/HollowKnight.QoL/releases/download/v4.9/QoL.zip"; Sha = "AE6DDF273249" },
    @{ Name = "Vasi"; Url = "https://github.com/fifty-six/HollowKnight.Vasi/releases/download/v2/Vasi.zip"; Sha = "B93FA7ECDF40" }
)
# Der Mod merkt sich die letzte Verbindung hier (Unity persistentDataPath)
$HK_SETTINGS = Join-Path $env:USERPROFILE "AppData\LocalLow\Team Cherry\Hollow Knight\ArchipelagoMod.GlobalSettings.json"

function Get-HkManaged([string]$Game) { Join-Path $Game "hollow_knight_Data\Managed" }

function Test-Sha([string]$File, [string]$Expected) {
    $hash = (Get-FileHash $File -Algorithm SHA256).Hash
    return $hash.StartsWith($Expected.ToUpper())
}

# Server/Port/Name ins Archipelago-Menue des Mods eintragen (Rest der Datei bleibt).
function Set-HkConnection([string]$Name) {
    $hostName, $port = $HviK.Server.Split(":")
    $gifting = "true"
    if (Test-Path $HK_SETTINGS) {
        try { if ((Get-Content $HK_SETTINGS -Raw | ConvertFrom-Json).EnableGifting -eq $false) { $gifting = "false" } } catch { }
    }
    New-Item -ItemType Directory -Force (Split-Path $HK_SETTINGS) | Out-Null
    $json = "{`n  `"MenuConnectionDetails`": {`n    `"ServerUrl`": `"$hostName`",`n    `"ServerPort`": $port,`n    `"SlotName`": `"$Name`",`n    `"ServerPassword`": null`n  },`n  `"EnableGifting`": $gifting`n}"
    [IO.File]::WriteAllText($HK_SETTINGS, $json, (New-Object Text.UTF8Encoding $false))
}
