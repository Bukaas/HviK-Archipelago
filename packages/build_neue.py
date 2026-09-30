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
    ]),
}

# Text VOR "EINMALIG" in der LIESMICH (z. B. Downpatchen)
PRE = {
    "vampire": [
        "!!! VORHER: SPIEL AUF EINE AELTERE VERSION ZURUECKSETZEN (\"DOWNPATCHEN\") !!!",
        "Der Mod laeuft (Stand jetzt) NICHT mit Spielversion 1.15 oder neuer.",
        "Steam hat dir automatisch die neueste Version installiert - die musst du einmal",
        "gegen eine aeltere tauschen. Das geht so:",
        "",
        "  1. Die Nummern holen: Im Archipelago-Discord (https://discord.gg/8Z65BR2)",
        "     in den Channel 'Vampire Survivors' gehen und oben rechts auf die",
        "     Stecknadel (angepinnte Nachrichten) klicken. Dort steht ein Befehl wie:",
        "         download_depot 1794680 1794681 1234567890123456789",
        "     (die Zahlen hier sind nur ein Beispiel!) - oder frag den Host.",
        "",
        "  2. Steam-Konsole oeffnen: STEAM-KONSOLE.bat doppelklicken.",
        "     (Oder: Windows-Taste + R -> steam://open/console eintippen -> Enter.)",
        "     Steam geht auf, oben erscheint der Reiter 'Konsole' mit einer",
        "     Eingabezeile ganz unten.",
        "",
        "  3. Den Befehl aus dem Discord unten in die Eingabezeile kopieren -> Enter.",
        "     Steam laedt jetzt die alte Version. Das dauert etwas - am Ende steht",
        "     'Depot download complete' und ein Ordner, meistens:",
        "         C:\\Program Files (x86)\\Steam\\steamapps\\content\\app_1794680\\depot_...",
        "",
        "  4. Diesen Ordner oeffnen, ALLES darin kopieren und in den Spielordner",
        "     einfuegen (\"Dateien ersetzen\"):",
        "         C:\\Program Files (x86)\\Steam\\steamapps\\common\\Vampire Survivors",
        "     (Spielordner finden: in Steam Rechtsklick auf das Spiel -> Verwalten ->",
        "      Lokale Dateien durchsuchen.)",
        "",
        "  5. Jetzt erst EINRICHTEN.bat doppelklicken.",
        "",
        "Damit Steam das Spiel nicht wieder hochpatcht: immer ueber START.bat starten",
        "(das startet das Spiel direkt, ohne Steam-Update). In Steam unter",
        "Eigenschaften -> Updates 'Nur beim Start aktualisieren' waehlen.",
        "Kommt doch ein Update: Schritte 2-4 wiederholen.",
    ],
}

# Zusaetzliche Dateien je Paket (Name -> Inhalt)
EXTRA_FILES = {
    "vampire": {
        "STEAM-KONSOLE.bat": "@echo off\nrem Oeffnet die Steam-Konsole (fuer das Downpatchen, siehe LIESMICH.txt).\nstart \"\" \"steam://open/console\"\n",
    },
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
