# install.ps1 - Vefna installer (Windows):
#   iwr -useb https://raw.githubusercontent.com/torvik-lang/vefna/main/windows/install.ps1 | iex
#
# Installs the prebuilt vefna.exe to %USERPROFILE%\.vefna\bin and adds it to the
# user PATH.
# Pin a version:   $env:VEFNA_VERSION = "1.0.0"; then run the line above
# Uninstall:       iwr -useb .../windows/install.ps1 -OutFile i.ps1; .\i.ps1 -Uninstall
param([switch]$Uninstall)

$ErrorActionPreference = "Stop"
$InstallDir = Join-Path $env:USERPROFILE ".vefna"
$BinDir     = Join-Path $InstallDir "bin"
$Repo       = "https://github.com/torvik-lang/vefna"
$Asset      = "vefna-windows-x86_64.exe"

if ($Uninstall) {
    if (Test-Path $InstallDir) { Remove-Item -Recurse -Force $InstallDir }
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $newPath = ($userPath -split ';' | Where-Object { $_ -notlike "*\.vefna\bin*" }) -join ';'
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "Removed $InstallDir and its PATH entry."
    exit 0
}

if ($env:VEFNA_VERSION) {
    $Url = "$Repo/releases/download/v$($env:VEFNA_VERSION)/$Asset"
} else {
    $Url = "$Repo/releases/latest/download/$Asset"
}

New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
Write-Host "-- Downloading vefna ..."
Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile (Join-Path $BinDir "vefna.exe")

# User PATH registration (idempotent).
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*\.vefna\bin*") {
    [Environment]::SetEnvironmentVariable("Path", "$BinDir;$userPath", "User")
    Write-Host "  PATH added for the current user"
}

Write-Host ""
& (Join-Path $BinDir "vefna.exe") version
Write-Host "Vefna installed to $InstallDir"
Write-Host ">>> Open a NEW terminal so PATH takes effect. Then:  vefna new mysite"
