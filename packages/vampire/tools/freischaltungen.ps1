# HviK Archipelago - Vampire Survivors: freigeschaltete Charaktere/Stages aus dem Spielstand lesen und als Code
# in die Zwischenablage legen. In der Lobby auf hvik.org "Aus Zwischenablage uebernehmen" -> Haekchen sitzen.
# Liest nur, veraendert nichts.
. "$PSScriptRoot\hvik.ps1"

function Find-SaveData {
    $cands = @()
    $steam = Get-SteamDir
    if ($steam) { $cands += Get-ChildItem (Join-Path $steam "userdata\*\1794680\remote\SaveData") -File -ErrorAction SilentlyContinue }
    $cands += Get-ChildItem "$env:APPDATA\Vampire_Survivors*" -Recurse -Filter "SaveData*" -File -ErrorAction SilentlyContinue
    $cands | Where-Object { (Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue) -match '"UnlockedCharacters"' } |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
}

function Get-List([string]$Text, [string]$Key) {
    $m = [regex]::Match($Text, "`"$Key`"\s*:\s*\[([^\]]*)\]")
    if (-not $m.Success) { return @() }
    @([regex]::Matches($m.Groups[1].Value, '"([A-Z0-9_]+)"') | ForEach-Object { $_.Groups[1].Value })
}

$save = Find-SaveData
if (-not $save) { Fail "Kein Spielstand gefunden. Vampire Survivors einmal normal ueber Steam starten und ein bisschen spielen." }
$text = Get-Content $save.FullName -Raw
$chars = Get-List $text "UnlockedCharacters"
$stages = Get-List $text "UnlockedStages"
if (-not $chars) { Fail "Im Spielstand stehen keine freigeschalteten Charaktere." }

$code = "HVIK-VS:C=" + ($chars -join ",") + ";S=" + ($stages -join ",")
Copy-ToClipboard $code
Ok "Spielstand gelesen ($($save.LastWriteTime.ToString('dd.MM.yyyy HH:mm')))."
Say "Charaktere: $($chars.Count)   Stages: $($stages.Count)"
Write-Host ""
Ok "Code ist kopiert. Jetzt auf hvik.org in der Lobby bei Vampire Survivors:"
Say "  'Aus Zwischenablage uebernehmen' klicken -> Haekchen werden gesetzt -> speichern." White
Say "(Klappt der Knopf nicht: den Code ins Feld daneben einfuegen mit Strg+V.)"
