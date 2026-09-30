# HviK Archipelago - Minecraft einmalig einrichten:
# minecraft.apworld v2.2.1 (NeoForgeAP, Minecraft 26.2 - gleiche Version wie auf dem HviK-Server) in Archipelago
# und .apmc-Dateien mit Archipelago verknuepfen, damit ein Doppelklick den Minecraft Client oeffnet.
. "$PSScriptRoot\hvik.ps1"
$Apworld = "https://github.com/qixils/NeoForgeAP/releases/download/v2.2.1/minecraft.apworld"

Say "[1/2] Archipelago + Minecraft Client ..."
Test-Archipelago
$worlds = Join-Path $HviK.ApDir "custom_worlds"
New-Item -ItemType Directory -Force $worlds | Out-Null
$f = Get-File $Apworld "minecraft.apworld"
Copy-Item $f (Join-Path $worlds "minecraft.apworld") -Force
Ok "minecraft.apworld v2.2.1 installiert."

Say "[2/2] .apmc-Dateien mit Archipelago verknuepfen ..."
# nur fuer diesen Windows-Benutzer (HKCU), keine Admin-Rechte noetig
$launcher = Join-Path $HviK.ApDir "ArchipelagoLauncher.exe"
$cls = "HKCU:\Software\Classes"
New-Item -Force "$cls\.apmc" | Out-Null
Set-ItemProperty "$cls\.apmc" -Name "(default)" -Value "HviK.Archipelago.apmc"
New-Item -Force "$cls\HviK.Archipelago.apmc\shell\open\command" | Out-Null
Set-ItemProperty "$cls\HviK.Archipelago.apmc" -Name "(default)" -Value "Archipelago Minecraft"
Set-ItemProperty "$cls\HviK.Archipelago.apmc\shell\open\command" -Name "(default)" -Value "`"$launcher`" `"%1`""
Ok "Doppelklick auf eine .apmc-Datei oeffnet jetzt den Minecraft Client."

Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Du brauchst ausserdem Minecraft Java Edition - im Launcher Version 26.2 waehlen."
Say "Am Spieltag: deine .apmc-Datei auf hvik.org laden und doppelklicken (oder START.bat)."
Say "Beim ersten Mal fragt der Client, ob er Java, NeoForge und den Mod installieren darf: immer JA."
