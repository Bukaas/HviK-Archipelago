"""Große Siegerszene im Format von /hvik szene: Berge, See, Wald, Podest mit Siegertor, roter Teppich.
Texturen aus der lokalen Minecraft-1.20.1-Jar (wie es die Mod beim Export auch macht)."""
import base64
import gzip
import json
import math
import os
import random
import zipfile

random.seed(7)
JAR = os.path.join(os.environ["USERPROFILE"], "curseforge", "minecraft", "Install", "versions", "1.20.1", "1.20.1.jar")
z = zipfile.ZipFile(JAR)
tex = {}


def t(name):
    key = "minecraft:block/" + name
    if key not in tex:
        tex[key] = base64.b64encode(z.read(f"assets/minecraft/textures/block/{name}.png")).decode()
    return key


GRASS, FOLIAGE, BIRCH, SPRUCE, WATER = 0x79C05A, 0x59AE30, 0x80A755, 0x619961, 0x3F76E4
palette = [{}]


def L(n, tint=None):
    return [{"tex": t(n), **({"tint": tint} if tint is not None else {})}]


def cube(top, side=None, bottom=None, tint_top=None, overlay=None, transparent=False, tint_all=None, h=1.0, y0=0.0):
    side, bottom = side or top, bottom or top
    faces = {"up": L(top, tint_top if tint_all is None else tint_all), "down": L(bottom, tint_all)}
    for d in ("north", "south", "east", "west"):
        faces[d] = L(side, tint_all) + ([{"tex": t(overlay), "tint": GRASS}] if overlay else [])
    palette.append({"shape": "box", "h": h, "y0": y0, "transparent": transparent, "faces": faces})
    return len(palette) - 1


def cross(name, tint=None):
    palette.append({"shape": "cross", "transparent": True, "faces": {d: L(name, tint) for d in ("up", "down", "north", "south", "east", "west")}})
    return len(palette) - 1


GRASS_B = cube("grass_block_top", "grass_block_side", "dirt", tint_top=GRASS, overlay="grass_block_side_overlay")
DIRT = cube("dirt")
STONE = cube("stone")
SNOW = cube("snow", "grass_block_snow", "dirt")
SNOWB = cube("snow")
SAND = cube("sand")
WATER_B = cube("water_still", transparent=True, tint_all=WATER, h=0.875)
PATH = cube("dirt_path_top", "dirt_path_side", "dirt", h=0.9375)
OAK = cube("oak_log_top", "oak_log")
OAK_L = cube("oak_leaves", transparent=True, tint_all=FOLIAGE)
BIRCH_W = cube("birch_log_top", "birch_log")
BIRCH_L = cube("birch_leaves", transparent=True, tint_all=BIRCH)
SPRUCE_W = cube("spruce_log_top", "spruce_log")
SPRUCE_L = cube("spruce_leaves", transparent=True, tint_all=SPRUCE)
GOLD = cube("gold_block")
IRON = cube("iron_block")
COPPER = cube("copper_block")
QUARTZ = cube("quartz_block_top", "quartz_block_side", "quartz_block_bottom")
PILLAR = cube("quartz_pillar_top", "quartz_pillar")
CHISELED = cube("chiseled_quartz_block_top", "chiseled_quartz_block")
SLAB = cube("quartz_block_bottom", h=0.5)
GLOW = cube("glowstone")
CARPET = cube("red_wool", h=0.0625)
GRASS_P = cross("grass", GRASS)
FLOWERS = [cross(n) for n in ("poppy", "dandelion", "cornflower", "azure_bluet", "oxeye_daisy", "allium")]
TORCH = cross("torch")

SX, SY, SZ = 80, 42, 76
grid = {}


def put(x, y, z, b):
    if 0 <= x < SX and 0 <= y < SY and 0 <= z < SZ:
        grid[(x, y, z)] = b


def get(x, y, z):
    return grid.get((x, y, z), 0)


G = 6  # Bodenhöhe
CX, CZ = 40, 44  # Podest

# Gelände: Wiese, hinten Berge, links ein See
def height(x, z):
    h = G
    mountains = (24 * math.exp(-(((x - 52) / 13) ** 2 + ((z - 6) / 7) ** 2)) + 17 * math.exp(-(((x - 22) / 11) ** 2 + ((z - 9) / 6) ** 2))
                 + 12 * math.exp(-(((x - 72) / 8) ** 2 + ((z - 14) / 6) ** 2)) + 9 * math.exp(-(((x - 6) / 8) ** 2 + ((z - 16) / 5) ** 2)))
    hills = 1.6 * math.sin(x * .35) * math.cos(z * .3) if z < 30 else 0
    return h + round(mountains + max(0, hills))


lake = lambda x, z: ((x - 13) / 9) ** 2 + ((z - 42) / 7) ** 2 < 1  # noqa: E731
for x in range(SX):
    for z in range(SZ):
        if lake(x, z):
            for y in range(G - 3):
                put(x, y, z, DIRT)
            put(x, G - 3, z, SAND)
            put(x, G - 2, z, WATER_B)
            put(x, G - 1, z, WATER_B)
            continue
        h = height(x, z)
        near_lake = ((x - 13) / 10.5) ** 2 + ((z - 42) / 8.5) ** 2 < 1
        for y in range(h):
            top = y == h - 1
            if top:
                b = SNOW if h - G > 17 else STONE if h - G > 10 else SAND if near_lake else GRASS_B
            else:
                b = STONE if y < h - 3 or h - G > 10 else DIRT
            put(x, y, z, b)
        if h - G > 20:
            put(x, h, z, SNOWB)

# Bäume
def oak(x, z, wood=OAK, leaves=OAK_L, hgt=5):
    y0 = height(x, z)
    for y in range(hgt):
        put(x, y0 + y, z, wood)
    for dy in (hgt - 2, hgt - 1):
        for dx in range(-2, 3):
            for dz in range(-2, 3):
                if abs(dx) + abs(dz) < 4 and not (dx == 0 and dz == 0):
                    put(x + dx, y0 + dy, z + dz, leaves)
    for dx in (-1, 0, 1):
        for dz in (-1, 0, 1):
            put(x + dx, y0 + hgt, z + dz, leaves)
    put(x, y0 + hgt + 1, z, leaves)


def spruce(x, z, hgt=8):
    y0 = height(x, z)
    for y in range(hgt):
        put(x, y0 + y, z, SPRUCE_W)
    r = 1
    for y in range(hgt + 1, 2, -1):
        for dx in range(-r, r + 1):
            for dz in range(-r, r + 1):
                if abs(dx) + abs(dz) <= r + (1 if r > 1 else 0) and (dx or dz or y >= hgt):
                    put(x + dx, y0 + y, z + dz, SPRUCE_L)
        r = 1 if r >= 3 or (y % 2) else r + 1
    put(x, y0 + hgt + 1, z, SPRUCE_L)


for x, z in ((25, 31), (60, 34), (66, 40), (8, 30), (72, 50), (4, 56), (28, 58)):
    oak(x, z, hgt=random.choice((5, 6)))
for x, z in ((20, 26), (57, 28), (68, 30), (31, 27), (75, 38)):
    oak(x, z, BIRCH_W, BIRCH_L, hgt=6)
for x, z in ((14, 24), (46, 23), (63, 24), (35, 22), (74, 26), (3, 28)):
    spruce(x, z, hgt=random.choice((7, 8, 9)))

# Podest-Plattform aus Quarz, Stufe davor
for x in range(CX - 7, CX + 8):
    for z in range(CZ - 2, CZ + 3):
        put(x, G, z, QUARTZ)
for x in range(CX - 7, CX + 8):
    put(x, G, CZ + 3, SLAB)
# Podest: Gold (1.) 3 hoch, Eisen (2.) 2 hoch links, Kupfer (3.) 1 hoch rechts
for y in range(3):
    put(CX, G + 1 + y, CZ, GOLD)
for y in range(2):
    put(CX - 1, G + 1 + y, CZ, IRON)
put(CX + 1, G + 1, CZ, COPPER)
# Siegertor dahinter
for side in (-5, 5):
    for y in range(1, 9):
        put(CX + side, G + y, CZ - 2, PILLAR)
    put(CX + side, G + 9, CZ - 2, CHISELED)
    put(CX + side, G + 10, CZ - 2, GLOW)
for x in range(CX - 4, CX + 5):
    put(x, G + 9, CZ - 2, CHISELED if x != CX else GLOW)
put(CX, G + 10, CZ - 2, GOLD)
# Fackeln auf der Plattform
for x in (CX - 7, CX + 7):
    for z in (CZ - 2, CZ + 2):
        put(x, G + 1, z, TORCH)
# roter Teppich bis nach vorne, Weg dahinter
for z in range(CZ + 4, CZ + 14):
    for x in range(CX - 4, CX + 5):
        put(x, G, z, CARPET)
for z in range(CZ + 14, SZ):
    for x in range(CX - 1, CX + 2):
        put(x, G - 1, z, PATH)
# Gras und Blumen
for _ in range(420):
    x, z = random.randrange(SX), random.randrange(26, SZ)
    if lake(x, z) or abs(x - CX) < 9 and CZ - 3 <= z <= CZ + 14 or abs(x - CX) <= 1 and z > CZ + 13:
        continue
    y = height(x, z)
    if get(x, y - 1, z) == GRASS_B and not get(x, y, z):
        put(x, y, z, random.choice(FLOWERS) if random.random() < .35 else GRASS_P)

# nur sichtbare Blöcke behalten (wie die Mod)
solid_set = {GRASS_B, DIRT, STONE, SNOW, SNOWB, SAND, OAK, BIRCH_W, SPRUCE_W, GOLD, IRON, COPPER, QUARTZ, PILLAR, CHISELED, GLOW}
def solid(x, y, z):
    return get(x, y, z) in solid_set
rle, last, run = [], -1, 0
for y in range(SY):
    for z in range(SZ):
        for x in range(SX):
            b = get(x, y, z)
            if b and all(solid(x + dx, y + dy, z + dz) for dx, dy, dz in ((1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1))):
                b = 0
            if b == last:
                run += 1
            else:
                if run:
                    rle += [run, last]
                last, run = b, 1
rle += [run, last]

SIT = {"right_leg": [-90, 12, 0], "left_leg": [-90, -12, 0], "right_arm": [-40, 0, 0], "left_arm": [-40, 0, 0]}
def stand(name, x, y, z, **pose):
    p = {"head": [0, 0, 0], "body": [0, 0, 0], "left_arm": [-10, 0, -10], "right_arm": [-15, 0, 10], "left_leg": [-1, 0, -1], "right_leg": [1, 0, 1]}
    p.update(pose)
    return {"name": str(name), "x": x, "y": y, "z": z, "yaw": 0, "small": False, "arms": True, "pose": p}

stands = [
    stand(1, CX + .5, G + 4, CZ + .5), stand(2, CX - .5, G + 3, CZ + .5), stand(3, CX + 1.5, G + 2, CZ + .5),
    stand(4, CX - 3.0, G + 1, CZ + 1.1), stand(5, CX + 4.0, G + 1, CZ + 1.1),
    stand(6, CX - 6.2, G + 1, CZ + .3), stand(7, CX + 7.2, G + 1, CZ + .3),
]
row1 = [CX - 3.1, CX - 1.4, CX + .5, CX + 2.4, CX + 4.1]
for i, x in enumerate(row1):
    stands.append(stand(8 + i, x, G - .45, CZ + 5.6, **SIT))
row2 = [CX - 2.3, CX - .5, CX + 1.5, CX + 3.3]
for i, x in enumerate(row2):
    stands.append(stand(13 + i, x, G - .45, CZ + 7.8, **SIT))

scene = {"version": 1, "size": [SX, SY, SZ], "origin": [0, 60, 0], "blocks": rle, "stands": stands,
         "camera": {"x": CX + .5, "y": G + 3.6, "z": CZ + 16.5, "yaw": 180, "pitch": 1}, "palette": palette, "textures": tex}
raw = gzip.compress(json.dumps(scene, separators=(",", ":")).encode())
open("grand-szene.json.gz", "wb").write(raw)
open("grand-szene.json", "w").write(json.dumps(scene))
print("Szene:", len(raw) // 1024, "KB gz,", len(stands), "Plätze,", len(palette) - 1, "Blockarten")
