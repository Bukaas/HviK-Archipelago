# HviK Archipelago - Celeste 64 einmalig einrichten: Archipelago-Fassung (ca. 60 MB) in diesen Ordner.
. "$PSScriptRoot\hvik.ps1"
. "$PSScriptRoot\celeste64.ps1"

Say "[1/2] Celeste 64 Archipelago $C64_VERSION (kostenlos, ca. 60 MB) ..."
$verFile = Join-Path $C64_DIR "hvik-version.txt"
$haveVer = if (Test-Path $verFile) { (Get-Content $verFile -Raw).Trim() } else { "" }
if ($haveVer -ne $C64_VERSION -or -not (Test-Path $C64_EXE)) {
    Get-Process Celeste64 -ErrorAction SilentlyContinue | Stop-Process -Force
    $z = Get-File $C64_URL "Celeste64-Archipelago-$C64_VERSION.zip"
    Expand-Zip $z $C64_DIR
    if (-not (Test-Path $C64_EXE)) { Fail "Celeste 64 konnte nicht entpackt werden - beim Host melden." }
    [IO.File]::WriteAllText($verFile, $C64_VERSION)
}
Ok "Celeste 64 liegt in $C64_DIR"

Say "[2/2] Verbindung ..."
$name = Get-PlayerName
Set-C64Connection $name
Ok "Server $($HviK.Server) und Name $name eingetragen (AP.json)."
Write-Host ""
Say "Fertig eingerichtet!" Green
Say "Am Spieltag: START.bat - kommst du am Titelbild vorbei, bist du verbunden."
