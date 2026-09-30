# HviK Archipelago - Raft einmalig einrichten:
# Raft Mod Loader (Launcher) in diesen Ordner, ModUtils 1.2.5 + Raftipelago 2.3.2 in den Mod-Ordner von Raft.
. "$PSScriptRoot\hvik.ps1"
$RAFT_APPID = 648800
$Rml = "https://www.raftmodding.com"

Say "[1/3] Raft suchen ..."
$game = Find-SteamGame $RAFT_APPID
if (-not $game) { Fail "Raft ist nicht installiert (Steam). Bitte erst installieren." }
Ok "Gefunden: $game"

Say "[2/3] Raft Mod Loader ..."
$launcher = Join-Path $HviK.Root "RMLLauncher.exe"
$z = Get-File "$Rml/launcher/2.8.10/download" "RMLLauncher.exe"
Copy-Item $z $launcher -Force
Ok "Mod Loader liegt in diesem Ordner (START.bat startet ihn)."

Say "[3/3] ModUtils + Raftipelago ..."
$mods = Join-Path $game "mods"
New-Item -ItemType Directory -Force $mods | Out-Null
foreach ($m in @(@{ N = "ModUtils"; U = "$Rml/mods/modutils/1.2.5/ModUtils.rmod?ignoreVirusScan=true" },
                 @{ N = "Raftipelago"; U = "$Rml/mods/raftipelago/2.3.2/Raftipelago.rmod?ignoreVirusScan=true" })) {
    $f = Get-File $m.U "$($m.N).rmod"
    Copy-Item $f (Join-Path $mods "$($m.N).rmod") -Force
}
Ok "Mods liegen in $mods"

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Beim ersten Start fragt der Mod Loader evtl. nach dem Raft-Ordner und richtet sich ein."
Say "Am Spieltag: START.bat doppelklicken."
