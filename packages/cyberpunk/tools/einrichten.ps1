# HviK Archipelago - Cyberpunk 2077 einmalig einrichten:
# Grund-Mods (RED4ext, redscript, Cyber Engine Tweaks, ArchiveXL, TweakXL, Codeware) + Archipelago-Mod 0.7.0 von 247Tossing
# direkt in den Spielordner. "Phone Extension" gibt es nur auf Nexus Mods -> die Seite geht auf, einmal von Hand laden.
# Archipelago selbst brauchst du NICHT - der Mod verbindet sich selbst (im CET-Fenster).
. "$PSScriptRoot\hvik.ps1"
$Mods = [ordered]@{
    "RED4ext 1.30.0"             = "https://github.com/WopsS/RED4ext/releases/download/v1.30.0/red4ext-1.30.0.zip"
    "redscript 0.5.31"           = "https://github.com/jac3km4/redscript/releases/download/v0.5.31/redscript-v0.5.31-windows.zip"
    "Cyber Engine Tweaks 1.37.1" = "https://github.com/maximegmd/CyberEngineTweaks/releases/download/v1.37.1/cet_1.37.1.zip"
    "ArchiveXL 1.27.4"           = "https://github.com/psiberx/cp2077-archive-xl/releases/download/v1.27.4/ArchiveXL-1.27.4.zip"
    "TweakXL 1.11.4"             = "https://github.com/psiberx/cp2077-tweak-xl/releases/download/v1.11.4/TweakXL-1.11.4.zip"
    "Codeware 1.20.5"            = "https://github.com/psiberx/cp2077-codeware/releases/download/v1.20.5/Codeware-1.20.5.zip"
    "Archipelago-Mod 0.7.0"      = "https://github.com/247Tossing/cyberpunk_archipelago/releases/download/0.7.3/CyberpunkArchipelagoMod_.0.7.0.zip"
}
$PhoneExtension = "https://www.nexusmods.com/cyberpunk2077/mods/24949?tab=files"

Say "[1/3] Cyberpunk 2077 suchen ..."
$game = Find-SteamGame 1091500
if (-not $game) {
    Say "Nicht in Steam gefunden (GOG/Epic?). Bitte den Spielordner waehlen (der mit 'bin' und 'r6')." Yellow
    Add-Type -AssemblyName System.Windows.Forms
    $d = New-Object System.Windows.Forms.FolderBrowserDialog; $d.Description = "Cyberpunk 2077 Spielordner"
    if ($d.ShowDialog() -ne "OK") { Fail "Abgebrochen." }
    $game = $d.SelectedPath
}
if (-not (Test-Path (Join-Path $game "bin\x64\Cyberpunk2077.exe"))) { Fail "In $game liegt kein Cyberpunk 2077 (bin\x64\Cyberpunk2077.exe fehlt)." }
Ok "Gefunden: $game"

Say "[2/3] Grund-Mods + Archipelago-Mod in den Spielordner ..."
$i = 0
foreach ($m in $Mods.GetEnumerator()) {
    $i++
    Say "  ($i/$($Mods.Count)) $($m.Key)"
    Expand-Zip (Get-File $m.Value ("cp2077-" + $i + ".zip")) $game
}
Ok "Alle Mods installiert."

Say "[3/3] 'Phone Extension' (nur auf Nexus Mods) ..."
Say "Ich oeffne die Nexus-Seite: dort 'Manual Download' (kostenloses Konto noetig)," Yellow
Say "die ZIP oeffnen und ihren Inhalt in den Spielordner ziehen:" Yellow
Say "  $game" Yellow
Start-Process $PhoneExtension

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Beim ersten Start fragt Cyber Engine Tweaks nach einer Taste fuer sein Fenster (z.B. Pos1) - merken!"
Say "Am Spieltag: START.bat doppelklicken."
