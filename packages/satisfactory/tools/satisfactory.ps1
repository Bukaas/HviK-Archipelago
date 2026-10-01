# HviK Archipelago - Satisfactory: Archipelago-Mod + Abhaengigkeiten (wie der Satisfactory Mod Manager sie installiert).
# Feste Versionen von ficsit.app (SHA-256 geprueft). Mods liegen in FactoryGame\Mods\<Name>.
# Archipelago-Mod 2.4.x = fuer Satisfactory 1.2 - passt zur Satisfactory-Welt in Archipelago 0.6.7 (unveraendert seit Maerz).
$SF_APPID = 526870
$SF_MODS = @(
    @{ Ref = "SML"; Version = "3.12.0"; Url = "https://api.ficsit.app/v1/version/74YqQBq2KJKN77/Windows/download"; Sha = "FF2F1D5A5D7AF5F2FE896305CF6389CF7F2200E392975F5E11A20A67146107AF" },
    @{ Ref = "ContentLib"; Version = "1.10.0"; Url = "https://api.ficsit.app/v1/version/FLVJUyAYe74Z3f/Windows/download"; Sha = "A58CD0EF4E224A557AFEBF0CB2068B8E5E1C20304C04E900F212A9619093878B" },
    @{ Ref = "FreeSamples"; Version = "2.1.0"; Url = "https://api.ficsit.app/v1/version/8rScR9QHm2eyG/Windows/download"; Sha = "0FEF47424F0799DCF0D0C6B5658B723A1C6899D492F57005EBCAA4B6F76F9CDF" },
    @{ Ref = "AdditionalDepots"; Version = "1.1.4"; Url = "https://api.ficsit.app/v1/version/F7nkrGuQpJCFVQ/Windows/download"; Sha = "EE67584C5606D31B3ACA00942AEA2F4E3870A0FD6FC3DCF081A8B130B323858C" },
    @{ Ref = "FixClientResourceSinkPoints"; Version = "1.2.1"; Url = "https://api.ficsit.app/v1/version/A6aNVHct3GwgJo/Windows/download"; Sha = "04C9E2744BAD5C154988BEEEF54F2A16084035FDDDE49224618353B87CBE5A4E" },
    @{ Ref = "HoverpackFuseReminder"; Version = "1.0.1"; Url = "https://api.ficsit.app/v1/version/4SNESHnHk1ib84/Windows/download"; Sha = "ABE89DC1436352376D305E4A76A2E05F8E476B59BE11ACECC280C54E8B94D47F" },
    @{ Ref = "Archipelago"; Version = "2.4.9"; Url = "https://api.ficsit.app/v1/version/7z3iqZPiB94hb9/Windows/download"; Sha = "398271B48123CAEFD3A82C8DB00167C98E7E56354D30145D2B3E0E12DFFD535D" }
)
function Get-SfModsDir([string]$Game) { Join-Path $Game "FactoryGame\Mods" }

# Epic-Version: Installationsordner + Startlink aus den Manifesten des Epic Games Launchers.
function Find-EpicGame([string]$Pattern) {
    $dir = Join-Path $env:ProgramData "Epic\EpicGamesLauncher\Data\Manifests"
    foreach ($f in Get-ChildItem $dir -Filter *.item -ErrorAction SilentlyContinue) {
        try { $m = Get-Content $f.FullName -Raw | ConvertFrom-Json } catch { continue }
        if ($m.DisplayName -match $Pattern -and $m.InstallLocation -and (Test-Path $m.InstallLocation)) {
            $id = "$($m.CatalogNamespace)%3A$($m.CatalogItemId)%3A$($m.AppName)"
            return [pscustomobject]@{ Path = $m.InstallLocation; Launch = "com.epicgames.launcher://apps/$($id)?action=launch&silent=true"; Store = "Epic" }
        }
    }
    return $null
}

# Satisfactory suchen: erst Steam, dann Epic.
function Find-Satisfactory {
    $steam = Find-SteamGame $SF_APPID
    if ($steam) { return [pscustomobject]@{ Path = $steam; Launch = "steam://rungameid/$SF_APPID"; Store = "Steam" } }
    return Find-EpicGame '^Satisfactory$'
}
