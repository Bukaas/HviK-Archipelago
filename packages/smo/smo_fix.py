"""smo.apworld 1.6.3 für Archipelago 0.6.7 lauffähig machen: ExtraMoons hat Kommazahl-Werte (1.2 …),
0.6.7 erlaubt bei Choice nur ganze Zahlen -> Stufen 0..4 und der Faktor kommt aus einer Liste."""
import zipfile

QUELLE, ZIEL = 'worlds/smo.apworld', 'worlds_hvik/smo.apworld'
FAKTOR = '[1.0, 1.2, 1.5, 1.75, 2.0][self.options.extra_moons.value]'
import os
os.makedirs('worlds_hvik', exist_ok=True)
with zipfile.ZipFile(QUELLE) as zin, zipfile.ZipFile(ZIEL, 'w', zipfile.ZIP_DEFLATED) as zout:
    for info in zin.infolist():
        daten = zin.read(info.filename)
        if info.filename == 'smo/Options.py':
            s = daten.decode('utf-8')
            alt = """    option_none = 1.0
    option_some = 1.2
    option_more = 1.5
    option_many = 1.75
    option_double = 2.0

    default = 1.2  # default to some"""
            assert alt in s
            s = s.replace(alt, """    option_none = 0
    option_some = 1
    option_more = 2
    option_many = 3
    option_double = 4

    default = 1  # default to some (HviK: ganze Zahlen für Archipelago 0.6.7, Faktor siehe __init__.py)""")
            daten = s.encode('utf-8')
        if info.filename == 'smo/__init__.py':
            s = daten.decode('utf-8')
            n = s.count('self.options.extra_moons.value')
            assert n == 11, n
            s = s.replace('self.options.extra_moons.value', FAKTOR)
            daten = s.encode('utf-8')
        zout.writestr(info, daten)
print('ok')
