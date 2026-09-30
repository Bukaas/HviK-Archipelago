# HviK Archipelago - Risk of Rain 2: gemeinsame Pfade + Verbindung vorausfuellen.
# Der Mod (com.Ijwu.Archipelago) liest Server/Port/Slot aus BepInEx\config\com.Ijwu.Archipelago.cfg -
# steht dort schon alles, muss man in der Lobby nur noch "Connect to AP" klicken.
$ROR2_APPID = 632360

function Set-Ror2Connection([string]$Game, [string]$Name) {
    $cfgDir = Join-Path $Game "BepInEx\config"
    New-Item -ItemType Directory -Force $cfgDir | Out-Null
    $file = Join-Path $cfgDir "com.Ijwu.Archipelago.cfg"
    $hostName, $port = $HviK.Server.Split(":")
    $want = [ordered]@{
        "Archipelago Server URL" = $hostName
        "Archipelago Server Port" = $port
        "Archipelago Slot Name" = $Name
    }
    $lines = if (Test-Path $file) { @(Get-Content $file) } else { @("[Archipelago Client Config]", "") }
    $out = New-Object System.Collections.Generic.List[string]
    $done = @{}
    foreach ($l in $lines) {
        $m = [regex]::Match($l, '^\s*([^#=][^=]*?)\s*=')
        if ($m.Success -and $want.Contains($m.Groups[1].Value)) {
            $k = $m.Groups[1].Value; $out.Add("$k = $($want[$k])"); $done[$k] = $true; continue
        }
        $out.Add($l)
    }
    # fehlende Eintraege ergaenzen (im Abschnitt "Archipelago Client Config")
    $missing = @($want.Keys | Where-Object { -not $done[$_] })
    if ($missing) {
        $i = $out.IndexOf("[Archipelago Client Config]")
        if ($i -lt 0) { $out.Add(""); $out.Add("[Archipelago Client Config]"); $i = $out.Count - 1 }
        foreach ($k in $missing) { $i++; $out.Insert($i, "$k = $($want[$k])") }
    }
    [IO.File]::WriteAllLines($file, $out, (New-Object Text.UTF8Encoding $false))
}
