# HviK Archipelago - Kingdom Hearts II einmalig einrichten:
# Archipelago pruefen, OpenKH Mod Manager in diesen Ordner laden und durch Assistent + Mods fuehren.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\kh2.ps1"

Say "[1/3] Archipelago ..."
Test-Archipelago
Ok "Archipelago ist da (der KH2 Client ist schon eingebaut)."

Say "[2/3] OpenKH Mod Manager ..."
if (-not (Test-Path $KH2_MM)) {
    $zip = Get-File $KH2_OPENKH_URL "openkh.zip"
    Expand-Zip $zip $KH2_OPENKH_DIR
}
if (-not (Test-Path $KH2_MM)) { Fail "OpenKH Mod Manager wurde nicht gefunden - bitte beim Host melden." }
Ok "OpenKH Mod Manager liegt in: $KH2_OPENKH_DIR"
$modsText = "Pflicht (in dieser Reihenfolge per gruenem Plus -> 'Add a mod from GitHub'):`r`n" +
    (($KH2_MODS | ForEach-Object { "  $_" }) -join "`r`n") + "`r`n`r`nOptional (Komfort):`r`n" +
    (($KH2_MODS_OPTIONAL | ForEach-Object { "  $_" }) -join "`r`n") + "`r`n"
[IO.File]::WriteAllText((Join-Path $HviK.Root "MODS.txt"), $modsText)
Get-PlayerName | Out-Null

Say "[3/3] Mod Manager einrichten ..."
Start-Process $KH2_MM -WorkingDirectory (Split-Path $KH2_MM)
Copy-ToClipboard $KH2_MODS[0]
Write-Host ""
Ok "Der OpenKH Mod Manager geht jetzt auf. Dort EINMAL:"
Say "  1. Setup-Wizard (startet beim ersten Mal von selbst, sonst Settings -> Run Setup Wizard):" White
Say "     - Spiel waehlen: PC Release (Epic oder Steam) und deinen KH-1.5+2.5-Spielordner." White
Say "     - 'Install Panacea' und 'Install Lua Backend' (KH2 anhaken)." White
Say "     - Spieldaten entpacken (Extract, nur KH2) - dauert ein paar Minuten." White
Say "  2. Gruenes Plus -> 'Add a mod from GitHub' - nacheinander eintragen:" White
foreach ($m in $KH2_MODS) { Say "       $m" Cyan }
Say "     (Der erste ist schon kopiert: Strg+V. Alle Namen stehen auch in MODS.txt.)" White
Say "  3. Alle angehakt lassen. Reihenfolge von oben: APCompanion, ArchipelagoEnablers, GoA-ROM-Edition." White
Write-Host ""
Say "Achtung: ArchipelagoEnablers ueberschreibt Speicherplatz 99 mit einem Autosave." Yellow
Say "Wer dort etwas Wichtiges hat: vorher in einen anderen Platz kopieren." Yellow
Say "Wenn der Mod Manager meckert, dass .NET fehlt: den angezeigten Link oeffnen und installieren."
