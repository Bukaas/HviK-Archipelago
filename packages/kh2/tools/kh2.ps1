# HviK Archipelago - Kingdom Hearts II: gemeinsame Werte.
# OpenKH Mod Manager (mit Panacea + Lua Backend) laedt die Mods; jede Runde gibt es eine eigene Seed-.zip,
# die im Mod Manager ganz oben installiert wird. Der KH2 Client ist in Archipelago 0.6.7 schon drin.
$KH2_OPENKH_URL = "https://github.com/OpenKH/OpenKh/releases/latest/download/openkh.zip"
$KH2_OPENKH_DIR = Join-Path $HviK.Root "OpenKH"
$KH2_MM = Join-Path $KH2_OPENKH_DIR "openkh\OpenKh.Tools.ModsManager.exe"
$KH2_MODS = @("KH2FM-Mods-Num/GoA-ROM-Edition", "JaredWeakStrike/APCompanion", "TopazTK/KH2-ArchipelagoEnablers")
$KH2_MODS_OPTIONAL = @("JaredWeakStrike/AP_QOL", "shananas/BearSkip")
