# HviK Archipelago - Terraria: gemeinsame Pfade und Helfer fuer den tModLoader-Mod "SeldomArchipelago"
# (Steam-Workshop 2922217554, Quelle: github.com/Seldom-SE/archipelago_terraria_client).
$TML_APPID = 1281930
$TML_WORKSHOP_ID = 2922217554
$TML_MOD = "SeldomArchipelago"
$TML_DIR = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "My Games\Terraria\tModLoader"

function Test-ModSubscribed {
    $game = Find-SteamGame $TML_APPID
    if (-not $game) { return $false }
    # steamapps\common\tModLoader -> steamapps\workshop\content\1281930\2922217554
    $steamapps = Split-Path (Split-Path $game -Parent) -Parent
    Test-Path (Join-Path $steamapps "workshop\content\$TML_APPID\$TML_WORKSHOP_ID")
}

# Mod in tModLoader einschalten (Mods\enabled.json = Liste der aktiven Mods)
function Enable-ApMod {
    $modsDir = Join-Path $TML_DIR "Mods"
    New-Item -ItemType Directory -Force $modsDir | Out-Null
    $file = Join-Path $modsDir "enabled.json"
    $list = New-Object System.Collections.Generic.List[string]
    if (Test-Path $file) {
        # ForEach-Object entpackt das Array - Windows PowerShell 5.1 liefert es sonst als ein einziges Objekt
        try { Get-Content $file -Raw | ConvertFrom-Json | ForEach-Object { $_ } | ForEach-Object { $list.Add([string]$_) } } catch { }
    }
    if (-not $list.Contains($TML_MOD)) { $list.Add($TML_MOD) }
    $json = "[" + (($list | ForEach-Object { '"' + $_.Replace('"', '\"') + '"' }) -join ",") + "]"
    [IO.File]::WriteAllText($file, $json, (New-Object Text.UTF8Encoding $false))
}

# Name/Adresse/Port in die Mod-Einstellungen schreiben -> der Mod verbindet sich beim Laden der Welt selbst
function Set-ApConfig([string]$Name) {
    $cfgDir = Join-Path $TML_DIR "ModConfigs"
    New-Item -ItemType Directory -Force $cfgDir | Out-Null
    $file = Join-Path $cfgDir "$($TML_MOD)_Config.json"
    $cfg = if (Test-Path $file) { try { Get-Content $file -Raw | ConvertFrom-Json } catch { [pscustomobject]@{} } } else { [pscustomobject]@{} }
    $hostName, $port = $HviK.Server.Split(":")
    $cfg | Add-Member -Force NoteProperty name $Name
    $cfg | Add-Member -Force NoteProperty address $hostName
    $cfg | Add-Member -Force NoteProperty port ([int]$port)
    if (-not $cfg.PSObject.Properties["password"]) { $cfg | Add-Member NoteProperty password "" }
    [IO.File]::WriteAllText($file, ($cfg | ConvertTo-Json), (New-Object Text.UTF8Encoding $false))
}
