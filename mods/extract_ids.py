"""Liest aus den lokalen CurseForge-Instanzen alle Items und Monster (IDs + deutsche/englische Namen) für die Ziel-Suche.
Ausgabe: items/<pack>.json = {"items": [[id, de, en, mod]], "mobs": [[id, de, en, mod]]}"""
import json
import os
import re
import sys
import tomllib
import zipfile
from pathlib import Path

CF = Path(os.environ["USERPROFILE"]) / "curseforge" / "minecraft"
PACKS = {"cube-warper": ("Cube Warper", "1.20.1"), "atm10": ("All the Mods 10 - ATM10", "1.21.1"),
         "atm11": ("All the Mods 11 - ATM11", "26.1.2")}
KEY = re.compile(r"^(item|block|entity)\.([a-z0-9_-]+)\.([a-z0-9_/]+)$")
OUT = Path(__file__).parent / "items"
OUT.mkdir(exist_ok=True)


def loads(raw: bytes) -> dict:
    text = raw.decode("utf-8-sig", "replace")
    try:
        d = json.loads(text)
    except ValueError:
        text = re.sub(r"^\s*//.*$", "", text, flags=re.M)  # manche Mods haben Kommentare
        text = re.sub(r",(\s*[}\]])", r"\1", text)
        try:
            d = json.loads(text)
        except ValueError:
            return {}
    return {k: v for k, v in d.items() if isinstance(v, str)} if isinstance(d, dict) else {}


class Source:
    """Sammelt Sprachschlüssel, Item-Modelle und Modnamen aus Jars/Ordnern."""

    def __init__(self):
        self.en, self.de, self.models, self.modnames = {}, {}, set(), {"minecraft": "Minecraft"}
        self.advs = {}  # id -> (title, description) als Text-Komponenten

    def file(self, name: str, read):
        m = re.match(r"assets/([^/]+)/lang/(en_us|de_de)\.json$", name)
        if m:
            (self.en if m.group(2) == "en_us" else self.de).update(loads(read()))
            return
        m = re.match(r"assets/([^/]+)/(?:models/item|items)/([a-z0-9_/]+)\.json$", name)
        if m:
            self.models.add(f"{m.group(1)}:{m.group(2)}")
            return
        m = re.match(r"data/([^/]+)/advancements?/([a-z0-9_/]+)\.json$", name)
        if m and not m.group(2).startswith("recipes/"):
            try:
                d = json.loads(read().decode("utf-8-sig", "replace"))
            except ValueError:
                return
            disp = d.get("display") if isinstance(d, dict) else None
            if isinstance(disp, dict) and disp.get("title") and not disp.get("hidden") and d.get("parent", "x"):
                self.advs[f"{m.group(1)}:{m.group(2)}"] = (disp.get("title"), disp.get("description"))
            return
        if name in ("META-INF/mods.toml", "META-INF/neoforge.mods.toml"):
            try:
                for mod in tomllib.loads(read().decode("utf-8", "replace")).get("mods", []):
                    if mod.get("modId") and mod.get("displayName"):
                        self.modnames[mod["modId"]] = mod["displayName"]
            except (tomllib.TOMLDecodeError, UnicodeError):
                pass

    def jar(self, path: Path):
        try:
            with zipfile.ZipFile(path) as z:
                for n in z.namelist():
                    if n.endswith(".json") or n.endswith(".toml"):
                        self.file(n, lambda n=n: z.read(n))
                    elif n.endswith(".jar") and n.startswith("META-INF/jarjar/"):  # eingebettete Mods
                        import io
                        try:
                            with zipfile.ZipFile(io.BytesIO(z.read(n))) as inner:
                                for m in inner.namelist():
                                    if m.endswith(".json") or m.endswith(".toml"):
                                        self.file(m, lambda m=m: inner.read(m))
                        except zipfile.BadZipFile:
                            pass
        except zipfile.BadZipFile:
            print("  kaputt:", path.name)

    def folder(self, root: Path):
        for p in root.rglob("*.json"):
            self.file(p.relative_to(root.parent).as_posix(), p.read_bytes)


def vanilla(src: Source, version: str):
    vdir = CF / "Install" / "versions" / version
    src.jar(vdir / f"{version}.jar")
    idx = json.loads((vdir / f"{version}.json").read_text(encoding="utf-8"))["assetIndex"]["id"]
    objects = json.loads((CF / "Install" / "assets" / "indexes" / f"{idx}.json").read_text(encoding="utf-8"))["objects"]
    h = objects["minecraft/lang/de_de.json"]["hash"]
    src.de.update(loads((CF / "Install" / "assets" / "objects" / h[:2] / h).read_bytes()))


def build(slug: str, folder: str, version: str):
    src = Source()
    vanilla(src, version)
    inst = CF / "Instances" / folder
    jars = sorted((inst / "mods").glob("*.jar"))
    for j in jars:
        src.jar(j)
    if (inst / "kubejs" / "assets").is_dir():
        src.folder(inst / "kubejs" / "assets")
    items, mobs = {}, {}
    for key in set(src.en) | set(src.de):
        m = KEY.match(key)
        if not m:
            continue
        kind, ns, path = m.groups()
        rid = f"{ns}:{path}"
        en, de = src.en.get(key, ""), src.de.get(key, "")
        if "%" in (en + de) or not (en or de) or re.search(r"debug|creative_|_creative|test_", path):
            continue
        row = [rid, de if de != en else "", en or de, src.modnames.get(ns, ns)]
        if kind == "entity":
            mobs[rid] = row
        elif (kind == "item" and ns != "minecraft") or rid in src.models:  # Vanilla: Sprachdatei kann neuer sein als das Spiel
            if kind == "block" and rid in items:
                continue  # Item-Name hat Vorrang
            items[rid] = row
    # Monster = Wesen mit Spawn-Ei (filtert Pfeile, Boote, Loren ...); Bosse ohne Ei per Hand
    bosses = {"minecraft:ender_dragon", "minecraft:wither", "minecraft:warden", "minecraft:elder_guardian"}
    mobs = {k: v for k, v in mobs.items() if f"{k}_spawn_egg" in items or k in bosses or f"{k.split(':')[0]}:spawn_egg_{k.split(':')[1]}" in items}
    def text(comp, lang):
        if isinstance(comp, str):
            return comp
        if isinstance(comp, dict):
            if "translate" in comp:
                return lang.get(comp["translate"]) or src.en.get(comp["translate"]) or comp.get("fallback") or ""
            return str(comp.get("text") or "")
        if isinstance(comp, list):
            return "".join(text(c, lang) for c in comp)
        return ""
    advs = []
    for rid, (title, desc) in src.advs.items():
        en, de = text(title, src.en), text(title, src.de)
        if not en or "%" in en:
            continue
        advs.append([rid, de if de != en else "", en, src.modnames.get(rid.split(":")[0], rid.split(":")[0]),
                     text(desc, src.de) or text(desc, src.en)])
    data = {"items": sorted(items.values()), "mobs": sorted(mobs.values()), "advs": sorted(advs)}
    (OUT / f"{slug}.json").write_text(json.dumps(data, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    print(f"{slug}: {len(jars)} Mods, {len(items)} Items, {len(mobs)} Monster, {len(advs)} Achievements, "
          f"{len([1 for r in items.values() if r[1]])} mit deutschem Namen, {(OUT / f'{slug}.json').stat().st_size // 1024} KB")


for slug in sys.argv[1:] or PACKS:
    build(slug, *PACKS[slug])
