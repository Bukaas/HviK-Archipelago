# Starterpakete

Quelle der Grundpakete, die als Release (`starter-N`) veröffentlicht werden. Die Website hvik.org legt beim
Download die persönlichen Dateien in `deine-runde/` dazu (Patch bzw. Mod + `server.txt` mit der Adresse).

| Paket | Inhalt |
|---|---|
| `super-mario-world/` | `START.bat` (prüft Archipelago, trägt den Emulator in `host.yaml` ein, startet SNI Client mit der Patch-Datei), `snes9x/snes9x.conf` (Emu Network Access an, Pause im Hintergrund aus). Im Release zusätzlich die Programmdateien von [snes9x-nwa 1.63](https://github.com/Skarsnik/snes9x-emunwa/releases/tag/1.63-sa1). |
| `factorio/` | `START.bat` (Mod installieren, Space Age/Quality/Elevated Rails aus, per Steam direkt verbinden), `DLC wieder an.bat` |

Neues Release bauen: Ordner zippen (Pfade mit `/`), als Asset an ein neues Release hängen und in
`web/archipelago_data.py` (`STARTER_RELEASE`) die Version anpassen.
