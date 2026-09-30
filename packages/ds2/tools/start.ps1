# HviK Archipelago - Dark Souls II starten: Verbinden-Befehl in die Zwischenablage, Spiel ueber Steam starten.
. "$PSScriptRoot\hvik.ps1"
$app = $null
foreach ($id in 335300, 236430) {
    $dir = Find-SteamGame $id
    if ($dir -and ((Test-Path (Join-Path $dir "Game\dinput8.dll")) -or (Test-Path (Join-Path $dir "dinput8.dll")))) { $app = $id; break }
}
if (-not $app) { Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken." }
$name = Get-PlayerName

$cmd = "/connect $($HviK.Server) $name"
Copy-ToClipboard $cmd
Start-Process "steam://rungameid/$app"
Write-Host ""
Ok "Spiel startet. In der Konsole, die mit aufgeht: Strg+V und Enter"
Say "    $cmd" White
Say "Erst verbinden, DANN Spielstand laden bzw. neues Spiel anfangen."
