# HviK Archipelago - Minecraft: minecraft.apworld reparieren.
# Der Minecraft Client aus NeoForgeAP 2.2.1 laedt kivy zu frueh und stuerzt in Archipelago 0.6.7 sofort ab
# ("style.kv nicht gefunden" - es oeffnet sich gar kein Client-Fenster).
# Abhilfe: in MinecraftClient.py vor "from kivy import Config" die Zeile "import kvui" einfuegen -
# kvui setzt die Kivy-Pfade, bevor kivy geladen wird. Mehrfach ausfuehren schadet nicht.
function Repair-MinecraftApworld([string]$Path) {
    if (-not (Test-Path $Path)) { return }
    Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::Open($Path, 'Update')
    try {
        $entry = $zip.GetEntry('minecraft/MinecraftClient.py')
        if (-not $entry) { return }
        $reader = New-Object System.IO.StreamReader($entry.Open())
        $text = $reader.ReadToEnd()
        $reader.Close()
        if ($text -match '(?m)^import kvui') { return }
        if (-not $text.Contains('from kivy import Config')) { return }
        $re = [regex]'from kivy import Config'
        $text = $re.Replace($text, "import kvui  # noqa: F401 - HviK-Fix: Kivy-Pfade setzen, bevor kivy geladen wird`nfrom kivy import Config", 1)
        $entry.Delete()
        $new = $zip.CreateEntry('minecraft/MinecraftClient.py')
        $writer = New-Object System.IO.StreamWriter($new.Open(), (New-Object System.Text.UTF8Encoding($false)))
        $writer.Write($text)
        $writer.Close()
        Ok "Minecraft Client repariert (Start-Absturz behoben)."
    } finally {
        $zip.Dispose()
    }
}
