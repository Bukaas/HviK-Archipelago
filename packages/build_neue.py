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
    "vampire": ("HviK-VampireSurvivors", "Vampire Survivors", [
        "Archipelago brauchst du NICHT. EINRICHTEN.bat installiert .NET 6, MelonLoader und den Mod.",
        "Die normale, aktuelle Steam-Version reicht - Downpatchen ist seit Mod v0.3 nicht mehr noetig.",
        "Kein Verbindungsfeld oben links? Dann gab es evtl. ein neues Spiel-Update, zu dem der Mod",
        "noch nicht passt - dann beim Host melden.",
    ]),
}

# Text VOR "EINMALIG" in der LIESMICH (z. B. Downpatchen)
PRE = {}

# Zusaetzliche Dateien je Paket (Name -> Inhalt)
EXTRA_FILES = {}

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
        for name, text in EXTRA_FILES.get(key, {}).items():
            files[name] = crlf(text)
        for s in ("einrichten", "start"):
            files[f"tools/{s}.ps1"] = crlf((HERE / key / "tools" / f"{s}.ps1").read_text(encoding="utf-8"))
        zpath = OUT / f"{folder}-Starter.zip"
        with zipfile.ZipFile(zpath, "w", zipfile.ZIP_DEFLATED) as z:
            for name, data in files.items():
                z.writestr(f"{folder}/{name}", data)
        print(zpath.name, zpath.stat().st_size)


if __name__ == "__main__":
    build()
