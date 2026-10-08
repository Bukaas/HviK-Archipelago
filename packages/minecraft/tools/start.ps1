# HviK Archipelago - Minecraft starten: neueste .apmc (Paket-Ordner "deine-runde" oder Downloads) im Minecraft Client oeffnen.
. "$PSScriptRoot\hvik.ps1"
if (-not (Test-Path (Join-Path $HviK.ApDir "custom_worlds\minecraft.apworld"))) {
    Fail "Noch nicht eingerichtet - bitte zuerst EINRICHTEN.bat doppelklicken."
}
# Aeltere Einrichtungen haben die APWorld noch ohne Fix -> hier nachholen (sonst startet der Client nicht)
. "$PSScriptRoot\fix-apworld.ps1"
Repair-MinecraftApworld (Join-Path $HviK.ApDir "custom_worlds\minecraft.apworld")
$places = @((Join-Path $HviK.Root "deine-runde"), (Join-Path $env:USERPROFILE "Downloads"))
$apmc = Get-ChildItem $places -Filter "*.apmc" -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $apmc) { Fail "Keine .apmc-Datei gefunden - auf hvik.org in der Runde 'Deine Datei' herunterladen." }
Say "Oeffne $($apmc.Name) ..."
Start-Process (Join-Path $HviK.ApDir "ArchipelagoLauncher.exe") -ArgumentList "`"$($apmc.FullName)`""
Copy-ToClipboard "/connect hvik.org 38281"
Write-Host ""
Ok "Der Minecraft Client startet deinen eigenen Minecraft-Server (Fenster offen lassen!)."
Say "  1. Warten, bis der Client gruen 'Server Running' zeigt (beim ersten Mal: Java/NeoForge/Mod - JA)." White
Say "  2. Minecraft Java 26.2 starten -> Mehrspieler -> Direktverbindung -> localhost" White
Say "  3. Im Spiel: T, Strg+V, Enter   (/connect hvik.org 38281 ist kopiert)" White
Say "  4. Dann /start - los geht's!" White
Say "Freunde koennen mitspielen, wenn sie deinen Server erreichen (Port 25565 freigeben)."
