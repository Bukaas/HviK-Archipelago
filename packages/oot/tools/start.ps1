# HviK Archipelago - Ocarina of Time starten: neueste .apz5 (Paket-Ordner "deine-runde" oder Downloads) im OoT Client
# oeffnen - direkt mit der HviK-Adresse. Der Client patcht die ROM und startet BizHawk mit dem Verbindungs-Skript.
. "$PSScriptRoot\hvik.ps1"
if (-not (Test-Path (Join-Path $HviK.Root "BizHawk\hvik-oot-start.bat"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
$places = @((Join-Path $HviK.Root "deine-runde"), (Join-Path $env:USERPROFILE "Downloads"))
$patch = Get-ChildItem $places -Filter "*.apz5" -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $patch) { Fail "Keine .apz5-Datei gefunden - auf hvik.org in der Runde 'Deine Datei' herunterladen." }
Say "Oeffne $($patch.Name) ..."
Start-Process (Join-Path $HviK.ApDir "ArchipelagoLauncher.exe") -ArgumentList "`"OoT Client`"", "--", "`"$($patch.FullName)`"", "--connect", $HviK.Server
Copy-ToClipboard $HviK.Server
Write-Host ""
Ok "Der OoT Client patcht jetzt deine ROM (dauert beim ersten Mal etwas) und startet BizHawk."
Say "  Beim allerersten Mal fragt er nach der ROM: Ocarina of Time (USA) v1.0." White
Say "  Verbindet sich der Client nicht selbst: oben $($HviK.Server) eintragen (schon kopiert) -> Connect." White
Say "  In BizHawk muss unten 'Connected' / im Client 'N64 connected' stehen." White
