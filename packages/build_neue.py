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
        zpath = OUT / f"{folder}-Starter.zip"
        with zipfile.ZipFile(zpath, "w", zipfile.ZIP_DEFLATED) as z:
            for name, data in files.items():
                z.writestr(f"{folder}/{name}", data)
        print(zpath.name, zpath.stat().st_size)


if __name__ == "__main__":
    build()
