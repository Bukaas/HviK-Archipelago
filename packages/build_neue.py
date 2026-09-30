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
        "Einmalig baut der SM64AP-Launcher daraus das PC-Spiel. Beim ersten Mal installiert er",
        "dafuer Werkzeuge (MSYS2) - das dauert 10-30 Minuten, einfach laufen lassen.",
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
        for f in sorted((HERE / key / "tools").glob("*.ps1")):
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
