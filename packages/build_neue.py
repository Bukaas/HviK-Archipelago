"""Baut die Grundpakete fuer Portal 2, DS2, DS3, ULTRAKILL, Vampire Survivors.
Jedes Paket: EINRICHTEN.bat, START.bat, LIESMICH.txt, tools/{hvik,einrichten,start}.ps1.
Die Mods selbst laedt EINRICHTEN.bat beim Spieler aus den Original-Releases (feste Versionen)."""
import pathlib
import zipfile

HERE = pathlib.Path(__file__).parent
OUT = HERE / "dist"

GAMES = {
    "portal2": ("HviK-Portal2", "Portal 2", [
        "Einmalig brauchst du: Portal 2 (Steam) und Archipelago 0.6.7",
        "(fehlt es, oeffnet EINRICHTEN.bat die Download-Seite).",
    ]),
    "ds2": ("HviK-DarkSouls2", "Dark Souls II", [
        "Geht mit Scholar of the First Sin und dem Original (wird erkannt).",
        "Archipelago brauchst du NICHT. Der Mod startet das Spiel automatisch offline.",
        "Wichtig: In der Lobby auf hvik.org die richtige Spielversion waehlen.",
    ]),
    "ds3": ("HviK-DarkSouls3", "Dark Souls III", [
        "Archipelago brauchst du NICHT. Der Mod liegt in diesem Ordner (Unterordner mod).",
        "WICHTIG: Im Spiel unter Optionen -> Netzwerk auf OFFLINE stellen.",
        "Steam selbst muss online laufen (nicht im Offline-Modus).",
        "Bei einer neuen Runde oeffnet START.bat automatisch den Randomizer:",
        "Adresse und Name stehen schon drin -> 'Load' klicken -> Fenster schliessen.",
    ]),
    "ultrakill": ("HviK-ULTRAKILL", "ULTRAKILL", [
        "Archipelago und ein Mod-Manager werden NICHT gebraucht.",
        "Installiert BepInEx, PluginConfigurator und den Archipelago-Mod direkt ins Spiel.",
        "Mod aus: im Spielordner winhttp.dll loeschen.",
    ]),
    "terraria": ("HviK-Terraria", "Terraria", [
        "Du brauchst Terraria und tModLoader (kostenlos in Steam). Archipelago brauchst du NICHT.",
        "EINRICHTEN.bat oeffnet die Workshop-Seite des Mods - dort einmal 'Abonnieren' klicken.",
        "Name, Adresse und Port traegt das Paket in die Mod-Einstellungen ein:",
        "der Mod verbindet sich beim Betreten der Welt von selbst.",
        "Fuer jede neue Runde eine NEUE Welt anlegen.",
        "Chat-Befehle: /ap !hint Itemname   -   Verbindung neu: /apconnect",
    ]),
    "raft": ("HviK-Raft", "Raft", [
        "Archipelago brauchst du NICHT. Installiert werden: Raft Mod Loader, ModUtils, Raftipelago.",
        "Im Spiel jedes Mal: F9 -> Mod manager -> ZUERST ModUtils laden (Stecker-Symbol),",
        "DANN Raftipelago (Raftipelago nicht 'beim Start laden' lassen).",
        "Verbinden: F10 -> Konsole -> Strg+V, Enter (START.bat kopiert den Befehl).",
    ]),
    "sm64": ("HviK-SuperMario64", "Super Mario 64", [
        "Du brauchst eine eigene Super Mario 64 ROM: USA oder Japan, als .z64 (EU geht nicht).",
        "Die ROM ist nicht im Paket. Archipelago brauchst du NICHT.",
        "EINRICHTEN.bat installiert MSYS2 (Werkzeuge, C:\msys64) und oeffnet den SM64AP-Launcher.",
        "Dort: Compile default SM64AP build -> Browse -> C:\SM64AP (Ordner OHNE Leerzeichen!)",
        "-> Name -> Download Files -> Create Build. Das dauert beim ersten Mal 10-30 Minuten.",
        "Danach: START.bat -> im Launcher Name + Adresse eintragen -> Play.",
    ]),
    "tp": ("HviK-TwilightPrincess", "Zelda: Twilight Princess", [
        "Du brauchst: Archipelago 0.6.7 und deine eigene Twilight Princess ISO (GameCube; USA, Europa oder Japan).",
        "Das Paket NICHT in einen OneDrive-Ordner legen (sonst findet der Client Dolphin nicht).",
        "EINRICHTEN.bat installiert den Twilight-Princess-Client (apworld v0.3.0) in Archipelago,",
        "legt Dolphin 2503a in diesen Ordner (eigene Einstellungen, deine andere Dolphin-Installation",
        "bleibt unberuehrt) und kopiert die drei Speicherstaende in Speicherkarte A.",
        "",
        "Im Spiel: Speicherstand 3 'REL Loader' starten (nur EINMAL pro Dolphin-Sitzung!),",
        "neues Spiel, warten bis du Link steuerst, im Client /name DeinName, dann verbinden.",
        "Alle fremden Items sehen im Spiel aus wie gruene Rubine - das ist normal.",
        "",
        "Die Speicherstaende (gci/) stammen aus dem Twilight-Princess-Channel im Archipelago-Discord",
        "(apworld: github.com/WritingHusky/Twilight_Princess_apworld, Randomizer: tprandomizer.com).",
    ]),
    "minecraft": ("HviK-Minecraft", "Minecraft", [
        "Du brauchst: Minecraft Java Edition (Version 26.2) und Archipelago 0.6.7.",
        "EINRICHTEN.bat installiert minecraft.apworld v2.2.1 (NeoForgeAP) - dieselbe Version",
        "wie auf dem HviK-Server - und verknuepft .apmc-Dateien mit Archipelago.",
        "",
        "Pro Runde gibt es eine eigene .apmc-Datei (auf hvik.org bei 'Deine Datei').",
        "Doppelklick darauf startet den Minecraft Client = dein eigener Minecraft-Server.",
        "Der Client installiert beim ersten Mal Java, NeoForge und den Mod selbst (immer JA).",
        "Das Client-Fenster waehrend des Spielens OFFEN lassen.",
        "In Minecraft: Mehrspieler -> Direktverbindung -> localhost",
        "Im Chat: /connect hvik.org 38281   und dann   /start",
    ]),
    "oot": ("HviK-OcarinaOfTime", "Zelda: Ocarina of Time", [
        "Du brauchst: Archipelago 0.6.7 und deine eigene ROM: Ocarina of Time (USA) Version 1.0,",
        "als .z64 oder .n64 (nicht 1.1/1.2, nicht die GameCube-Fassung). Die ROM ist nicht im Paket.",
        "EINRICHTEN.bat laedt BizHawk 2.9.1 in diesen Ordner und stellt Archipelago so ein, dass es nach",
        "dem Patchen BizHawk direkt mit dem Verbindungs-Skript (connector_oot.lua) startet.",
        "",
        "Pro Runde gibt es eine eigene .apz5-Datei (auf hvik.org bei 'Deine Datei').",
        "Doppelklick darauf (oder START.bat) -> ROM wird gepatcht -> BizHawk startet.",
        "Im OoT Client oben hvik.org:38281 eintragen -> Connect (START.bat erledigt das schon).",
        "Tipp aus der Anleitung: in BizHawk unter Config -> Hotkeys die meisten Tasten mit Esc",
        "abschalten, damit du nicht aus Versehen Savestates o.ae. ausloest.",
    ]),
    "dsr": ("HviK-DarkSouls1", "Dark Souls Remastered", [
        "Archipelago brauchst du NICHT. EINRICHTEN.bat laedt den DSAP-Client v0.2.6 in diesen Ordner",
        "(passend zur Version auf dem HviK-Server) und sichert einmal deine normalen Spielstaende",
        "nach 'Spielstand-Sicherung'.",
        "",
        "WICHTIG: Im Spiel System -> Netzwerk-Einstellungen -> Startmodus 'Offline starten'.",
        "Laut Mod-Anleitung passend: Spielversion App 1.03.1 / Regulation 1.04 (aktuelle Steam-Version).",
        "",
        "Am Spieltag: START.bat -> Spiel + DSAP-Client starten -> im Client Menue (drei Striche):",
        "Host hvik.org:38281, Slot = dein Name -> Connect -> mit RECHTSklick zurueck ins Spiel.",
        "Den DSAP-Client die ganze Zeit offen lassen.",
    ]),
    "rac3": ("HviK-RatchetClank3", "Ratchet and Clank 3", [
        "Du brauchst: Archipelago 0.6.7, dein eigenes PS2-BIOS und deine eigene",
        "Ratchet & Clank 3 ISO (US SCUS-97353 oder EU SCES-52456) - die duerfen wir nicht verteilen.",
        "Das Paket NICHT in einen OneDrive-Ordner legen.",
        "EINRICHTEN.bat installiert den RaC3-Client (rac3.apworld v0.6.0) in Archipelago,",
        "legt PCSX2 2.8.2 in diesen Ordner (eigene Einstellungen, eine andere PCSX2-Installation",
        "bleibt unberuehrt), schaltet PINE ein (Slot 28011) und fragt einmal nach BIOS und ISO.",
        "",
        "Am Spieltag: START.bat -> im Launcher 'Ratchet and Clank 3 Client' -> Strg+V -> Connect",
        "-> Name eingeben -> im Spiel neuen Spielstand beginnen.",
    ]),
    "cuphead": ("HviK-Cuphead", "Cuphead", [
        "Archipelago brauchst du NICHT. EINRICHTEN.bat installiert direkt ins Spiel:",
        "BepInEx 5.4.23.5 und den CupheadArchipelago-Mod alpha04a.3 (github.com/JKLeckr).",
        "",
        "Am Spieltag: START.bat -> leeren Speicherplatz waehlen -> Archipelago-Menue (Tastatur C+Z)",
        "-> Enabled an, Address hvik.org, Port 38281, Player = dein Name -> Speicherplatz starten.",
        "Der Mod ist noch Alpha - Fehler bitte dem Host melden.",
        "Mods wieder aus: im Spielordner winhttp.dll loeschen.",
    ]),
    "kh3": ("HviK-KingdomHearts3", "Kingdom Hearts III", [
        "Du brauchst: Kingdom Hearts III + Re Mind (Steam oder Epic) und Archipelago 0.6.7.",
        "EINRICHTEN.bat installiert den KH3-Client (kh3.apworld 0.16.11 von ap.aesais.net) und oeffnet ihn:",
        "dort EINMAL Reiter 'KH3 Config' -> 'Patch Game' klicken (installiert Garden of Assemblage + Mod-Loader).",
        "",
        "Am Spieltag: START.bat - der Client verbindet sich selbst und baut deine Seed-Datei,",
        "dann 'Launch KH3' im Client und einen NEUEN Spielstand beginnen.",
        "KH3 AP ist noch Alpha - Fehler bitte dem Host melden.",
    ]),
    "hk": ("HviK-HollowKnight", "Hollow Knight", [
        "Archipelago und Scarab/Lumafly brauchst du NICHT. EINRICHTEN.bat installiert direkt ins Spiel (Steam):",
        "Modding API 1.5.78 und den Archipelago-Mod 0.12.0 mit ItemChanger, MenuChanger, Benchwarp, QoL, Vasi.",
        "Die Original-Spieldatei wird als Assembly-CSharp.dll.v gesichert.",
        "",
        "Am Spieltag: START.bat -> leeren Speicherplatz -> Modus 'Archipelago' -> Start",
        "(Server, Port und dein Name sind schon eingetragen).",
        "Mods wieder aus: in Steam 'Dateien auf Fehler ueberpruefen'.",
    ]),
    "poke_rb": ("HviK-PokemonRotBlau", "Pokemon Rot/Blau", [
        "Du brauchst: Archipelago 0.6.7 und deine eigene ROM: Pokemon Red oder Blue (englisch, USA/Europa, .gb).",
        "Deutsche ROMs gehen NICHT. Die ROM ist nicht im Paket.",
        "EINRICHTEN.bat laedt BizHawk 2.9.1 (Emulator) in diesen Ordner und stellt Archipelago so ein,",
        "dass es nach dem Patchen BizHawk direkt mit dem Verbindungs-Skript startet.",
        "",
        "Pro Runde gibt es eine eigene Datei (auf hvik.org bei 'Deine Datei' oder im Startpaket).",
        "START.bat -> ROM wird gepatcht -> BizHawk startet und verbindet sich mit hvik.org.",
        "Beim allerersten Mal fragt Archipelago nach deiner ROM.",
    ]),
    "poke_em": ("HviK-PokemonSmaragd", "Pokemon Smaragd", [
        "Du brauchst: Archipelago 0.6.7 und deine eigene ROM: Pokemon Emerald (englisch, USA/Europa, .gba).",
        "Deutsche ROMs gehen NICHT. Die ROM ist nicht im Paket.",
        "EINRICHTEN.bat laedt BizHawk 2.9.1 (Emulator) in diesen Ordner und stellt Archipelago so ein,",
        "dass es nach dem Patchen BizHawk direkt mit dem Verbindungs-Skript startet.",
        "",
        "Pro Runde gibt es eine eigene Datei (auf hvik.org bei 'Deine Datei' oder im Startpaket).",
        "START.bat -> ROM wird gepatcht -> BizHawk startet und verbindet sich mit hvik.org.",
        "Beim allerersten Mal fragt Archipelago nach deiner ROM.",
    ]),
    "poke_fr": ("HviK-PokemonFeuerrot", "Pokemon Feuerrot/Blattgruen", [
        "Du brauchst: Archipelago 0.6.7 und deine eigene ROM: Pokemon FireRed oder LeafGreen (englisch, USA, 1.0/1.1, .gba).",
        "Deutsche ROMs gehen NICHT. Die ROM ist nicht im Paket.",
        "EINRICHTEN.bat installiert ausserdem die Feuerrot/Blattgruen-Erweiterung (pokemon_frlg.apworld 1.1.4).",
        "EINRICHTEN.bat laedt BizHawk 2.9.1 (Emulator) in diesen Ordner und stellt Archipelago so ein,",
        "dass es nach dem Patchen BizHawk direkt mit dem Verbindungs-Skript startet.",
        "",
        "Pro Runde gibt es eine eigene Datei (auf hvik.org bei 'Deine Datei' oder im Startpaket).",
        "START.bat -> ROM wird gepatcht -> BizHawk startet und verbindet sich mit hvik.org.",
        "Beim allerersten Mal fragt Archipelago nach deiner ROM.",
    ]),
    "poke_cr": ("HviK-PokemonKristall", "Pokemon Kristall", [
        "Du brauchst: Archipelago 0.6.7 und deine eigene ROM: Pokemon Crystal (englisch, USA/Europa, 1.0/1.1, .gbc).",
        "Deutsche ROMs gehen NICHT. Die ROM ist nicht im Paket.",
        "EINRICHTEN.bat installiert ausserdem die Kristall-Erweiterung (pokemon_crystal.apworld 5.4.6).",
        "EINRICHTEN.bat laedt BizHawk 2.9.1 (Emulator) in diesen Ordner und stellt Archipelago so ein,",
        "dass es nach dem Patchen BizHawk direkt mit dem Verbindungs-Skript startet.",
        "",
        "Pro Runde gibt es eine eigene Datei (auf hvik.org bei 'Deine Datei' oder im Startpaket).",
        "START.bat -> ROM wird gepatcht -> BizHawk startet und verbindet sich mit hvik.org.",
        "Beim allerersten Mal fragt Archipelago nach deiner ROM.",
    ]),
    "ror2": ("HviK-RiskOfRain2", "Risk of Rain 2", [
        "Archipelago und r2modman brauchst du NICHT. EINRICHTEN.bat installiert direkt ins Spiel:",
        "BepInEx, HookGenPatcher, R2API, InLobbyConfig, ScrollableLobbyUI und den Archipelago-Mod 1.1.3,",
        "und traegt Server hvik.org, Port 38281 und deinen Namen in den Mod ein.",
        "",
        "Am Spieltag: START.bat -> Singleplayer -> in der Lobby 'Connect to AP' klicken.",
        "Stehen die Felder leer: Konsole (Strg+Alt+^) -> archipelago hvik.org 38281 DeinName",
        "Mods wieder aus: im Spielordner winhttp.dll loeschen.",
        "Wer r2modman schon nutzt, kann auch dort den Mod 'Archipelago' (ArchipelagoMW) nehmen.",
    ]),
    "vampire": ("HviK-VampireSurvivors", "Vampire Survivors", [
        "Archipelago brauchst du NICHT.",
        "",
        "SPIELVERSION: Der Mod laeuft nur mit Vampire Survivors bis 1.14 (ab 1.15 stuerzt",
        "der Mod-Loader ab). EINRICHTEN.bat legt deshalb eine EIGENE Kopie an:",
        "'Vampire Survivors AP' (Version 1.14.112) - dein normales Steam-Spiel bleibt wie es ist.",
        "",
        "Dafuer geht die Steam-Konsole auf, der Befehl ist schon kopiert:",
        "  unten in die Eingabezeile klicken -> Strg+V -> Enter -> warten bis",
        "  'Depot download complete' dasteht -> im EINRICHTEN-Fenster Enter.",
        "Kein Steam-Passwort, kein Steam-Guard-Code noetig. Besitzt du DLCs, kommt pro DLC",
        "noch ein Befehl dazu (gleiches Spiel).",
        "Steam-Konsole von Hand: Windows-Taste + R -> steam://open/console -> Enter.",
        "",
        "Hast du schon den Installer aus dem Archipelago-Discord benutzt",
        "(C:\\ProgramData\\Archipelago\\Vampire Survivors AP)? Dann wird diese Kopie genommen.",
        "",
        "LOBBY: Bei Vampire Survivors kreuzt du an, welche Charaktere und Stages du im",
        "normalen Spiel schon freigeschaltet hast. Das geht automatisch: FREISCHALTUNGEN.bat",
        "doppelklicken (liest deinen Spielstand) -> in der Lobby 'Aus Zwischenablage uebernehmen'.",
        "",
        "Starten: START.bat oder die Desktop-Verknuepfung 'Vampire Survivors AP'.",
        "NICHT das normale Spiel in Steam starten - das ist die neue Version ohne Mod.",
        "Der erste Start dauert ein paar Minuten (MelonLoader richtet sich ein).",
        "",
        "WICHTIG im Spiel: START -> Charakter ANKLICKEN (nicht nur 'weiter' druecken),",
        "sonst stuerzt das Spiel beim Laden des Runs ab.",
        "",
        "Danke an die VS-Archipelago-Community: Der Weg folgt dem Installer",
        "takacomic/VSModdedScript (Pins im Archipelago-Discord).",
    ]),
}

# Pakete, die sich Skripte teilen: zusaetzlich alle tools/*.ps1 aus diesen Ordnern (eigene gleichnamige gewinnen)
SHARED_TOOLS = {key: ["pokemon_common"] for key in ("poke_rb", "poke_em", "poke_fr", "poke_cr")}

# Text VOR "EINMALIG" in der LIESMICH (z. B. Downpatchen)
PRE = {}

# Zusaetzliche Dateien je Paket (Name -> Inhalt)
EXTRA_FILES = {}

# Zusaetzliche .bat-Dateien je Paket: (Dateiname, Kopfzeile, Skript in tools/)
EXTRA_BATS = {
    "vampire": [("FREISCHALTUNGEN.bat", "Freischaltungen aus dem Spielstand lesen", "freischaltungen")],
}

BAT = """@echo off
rem HviK Archipelago - {game}: {what}
title HviK Archipelago - {game}
cd /d "%~dp0"
echo.
echo  ==============================================
echo    HviK Archipelago - {game}
echo    {headline}
echo  ==============================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\\{script}.ps1"
echo.
pause
"""

README = """HviK Archipelago - {game}
{line}
{pre}
EINMALIG (vor dem Spieltag):
  1. Diesen Ordner an einen festen Platz legen (z.B. Dokumente).
  2. EINRICHTEN.bat doppelklicken.
     Windows fragt evtl. "Der Computer wurde geschuetzt"
     -> "Weitere Informationen" -> "Trotzdem ausfuehren".

AM SPIELTAG:
  START.bat doppelklicken. Beim ersten Mal fragt es nach deinem Namen
  (steht auf hvik.org in der Runde bei "Dein Name im Spiel") und merkt ihn sich.
  Server: hvik.org:38281

{extra}

Neue Mod-Version? Einfach das neue Grundpaket laden und EINRICHTEN.bat nochmal starten.
Hilfe & Anleitung: https://hvik.org/events/archipelago
"""


def crlf(text: str) -> bytes:
    text.encode("ascii")  # .bat/.txt nur ASCII
    return text.replace("\r\n", "\n").replace("\n", "\r\n").encode("ascii")


def build():
    OUT.mkdir(exist_ok=True)
    common = (HERE / "common" / "hvik.ps1").read_text(encoding="utf-8")
    common.encode("ascii")
    for key, (folder, game, extra) in GAMES.items():
        files = {
            "EINRICHTEN.bat": crlf(BAT.format(game=game, what="einmalig einrichten", headline="Einmalige Einrichtung", script="einrichten")),
            "START.bat": crlf(BAT.format(game=game, what="am Spieltag starten", headline="Spiel starten", script="start")),
            "LIESMICH.txt": crlf(README.format(
                game=game, line="=" * (len(game) + 19), extra="\n".join(extra),
                pre="".join("\n" + l for l in PRE.get(key, [])) + ("\n" if key in PRE else ""))),
            "tools/hvik.ps1": crlf(common),
        }
        for name, headline, script in EXTRA_BATS.get(key, []):
            files[name] = crlf(BAT.format(game=game, what=headline, headline=headline, script=script))
        for name, text in EXTRA_FILES.get(key, {}).items():
            files[name] = crlf(text)
        for src in SHARED_TOOLS.get(key, []) + [key]:
            for f in sorted((HERE / src / "tools").glob("*.ps1")):
                files[f"tools/{f.name}"] = crlf(f.read_text(encoding="utf-8"))
        # Beiliegende Dateien (z. B. TP-Speicherstaende in gci/) unveraendert mitnehmen
        extra = HERE / key / "files"
        if extra.is_dir():
            for f in sorted(p for p in extra.rglob("*") if p.is_file()):
                files[f.relative_to(extra).as_posix()] = f.read_bytes()
        zpath = OUT / f"{folder}-Starter.zip"
        with zipfile.ZipFile(zpath, "w", zipfile.ZIP_DEFLATED) as z:
            for name, data in files.items():
                z.writestr(f"{folder}/{name}", data)
        print(zpath.name, zpath.stat().st_size)


if __name__ == "__main__":
    build()
