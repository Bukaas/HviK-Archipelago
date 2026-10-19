"""Baut die Grundpakete der 5 Spiele aus den Tickets (Oktober 2026): CloverPit, Super Mario Odyssey, Slime Rancher 2,
XCOM 2 WotC, Cyberpunk 2077. Gleicher Aufbau wie build_neue.py (EINRICHTEN.bat, START.bat, LIESMICH.txt, tools/*.ps1)."""
import zipfile

from build_neue import BAT, HERE, OUT, README, crlf

GAMES = {
    "cloverpit": ("HviK-CloverPit", "CloverPit", [
        "Du brauchst: CloverPit (Steam). Archipelago brauchst du NICHT.",
        "EINRICHTEN.bat installiert BepInEx 5 und den Archipelago-Mod (Syntheal, v1.2.2)",
        "direkt in den Spielordner. Mod wieder aus: im Spielordner winhttp.dll loeschen.",
        "Im Spiel: Archipelago-Fenster (F8) -> Host = Adresse, Slot = dein Name -> Connect.",
    ]),
    "smo": ("HviK-MarioOdyssey", "Super Mario Odyssey", [
        "Du brauchst: Archipelago 0.6.7, einen Switch-Emulator (Ryujinx oder ein Abkoemmling,",
        "Suyu, Eden, Citron ...) und deine eigene Super Mario Odyssey Kopie in VERSION 1.0.0.",
        "Das Spiel ist NICHT im Paket.",
        "EINRICHTEN.bat installiert smo.apworld (v1.6.3 mit HviK-Korrektur fuer Archipelago 0.6.7)",
        "und den Emulator-Mod SMOAP in jeden gefundenen Emulator.",
        "Am Spieltag: START.bat -> Client verbindet -> im Spiel die angezeigte IP und Port 1027 eingeben.",
    ]),
    "sr2": ("HviK-SlimeRancher2", "Slime Rancher 2", [
        "Du brauchst: Slime Rancher 2 (Steam). Archipelago brauchst du NICHT.",
        "EINRICHTEN.bat installiert BepInEx 6 (Build be.755 - neuere laden den Mod nicht)",
        "und SlimeRancher2-AP v0.15.0 (Rhelys) in den Spielordner.",
        "Der ERSTE Start mit Mod dauert mehrere Minuten.",
        "WICHTIG: erst im Hauptmenue verbinden (Archipelago), DANN ein neues Spiel starten.",
    ]),
    "xcom2": ("HviK-XCOM2", "XCOM 2: War of the Chosen", [
        "Du brauchst: XCOM 2 + DLC War of the Chosen (Steam) und Archipelago 0.6.7.",
        "EINRICHTEN.bat installiert x2wotc.apworld 1.0.0 (Snyax), traegt Spiel- und Workshop-Ordner",
        "in Archipelago ein und oeffnet die Workshop-Seiten: 'WotC Archipelago' (Pflicht) und",
        "'Mod Config Menu' (empfohlen) - dort jeweils 'Abonnieren'.",
        "Am Spieltag: START.bat startet zuerst den Client (verbinden), dann das Spiel.",
    ]),
    "cyberpunk": ("HviK-Cyberpunk2077", "Cyberpunk 2077", [
        "Du brauchst: Cyberpunk 2077 (Steam, GOG oder Epic). Archipelago brauchst du NICHT.",
        "EINRICHTEN.bat installiert RED4ext, redscript, Cyber Engine Tweaks, ArchiveXL, TweakXL,",
        "Codeware und den Archipelago-Mod (247Tossing, 0.7.0) in den Spielordner.",
        "'Phone Extension' gibt es nur auf Nexus Mods: die Seite geht auf -> einmal von Hand laden",
        "und in den Spielordner entpacken.",
        "Im Spiel: CET-Taste -> Archipelago-Fenster -> Adresse, Port, Name -> Connect.",
    ]),
}


def build():
    OUT.mkdir(exist_ok=True)
    common = (HERE / "common" / "hvik.ps1").read_text(encoding="utf-8")
    for key, (folder, game, extra) in GAMES.items():
        files = {
            "EINRICHTEN.bat": crlf(BAT.format(game=game, what="einmalig einrichten", headline="Einmalige Einrichtung", script="einrichten")),
            "START.bat": crlf(BAT.format(game=game, what="am Spieltag starten", headline="Spiel starten", script="start")),
            "LIESMICH.txt": crlf(README.format(game=game, line="=" * (len(game) + 19), extra="\n".join(extra), pre="")),
            "tools/hvik.ps1": crlf(common),
        }
        for f in sorted((HERE / key / "tools").glob("*.ps1")):
            files[f"tools/{f.name}"] = crlf(f.read_text(encoding="utf-8"))
        extra_dir = HERE / key / "files"
        if extra_dir.is_dir():
            for f in sorted(p for p in extra_dir.rglob("*") if p.is_file()):
                files[f.relative_to(extra_dir).as_posix()] = f.read_bytes()
        zpath = OUT / f"{folder}-Starter.zip"
        with zipfile.ZipFile(zpath, "w", zipfile.ZIP_DEFLATED) as z:
            for name, data in files.items():
                z.writestr(f"{folder}/{name}", data)
        print(zpath.name, zpath.stat().st_size)


if __name__ == "__main__":
    build()
