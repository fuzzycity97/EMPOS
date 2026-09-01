# scripts/build_windows_msi.ps1
# Automated Windows MSI Packaging Pipeline for EMPOS / Omni System
param (
    [string]$OutputDir = "build\installer",
    [string]$AppVersion = "1.0.0",
    [string]$AppName = "OmniPOS"
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  EMPOS Automated Windows MSI Installer Packaging Pipeline" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Ensure Output Directory Exists
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# 2. Build Flutter Windows Release
Write-Host "[1/4] Compiling Flutter Windows Release..." -ForegroundColor Yellow
flutter build windows --release

$ReleaseDir = "build\windows\x64\runner\Release"
if (!(Test-Path $ReleaseDir)) {
    Write-Error "Flutter Windows release build failed: Release directory not found at $ReleaseDir"
}

# 3. Create Installer Staging Bundle
$StagingDir = "build\installer\staging"
if (Test-Path $StagingDir) {
    Remove-Item -Recurse -Force $StagingDir
}
New-Item -ItemType Directory -Path $StagingDir -Force | Out-Null

Write-Host "[2/4] Aggregating Binaries, Assets, and Configuration..." -ForegroundColor Yellow
Copy-Item -Recurse -Force "$ReleaseDir\*" "$StagingDir\"

# 4. Generate WiX / Inno Installer Bundle Script
$InstallerMsi = "$OutputDir\$AppName-v$AppVersion-Setup.msi"
$InnoScript = "$OutputDir\installer_spec.iss"

$InnoContent = @"
[Setup]
AppName=$AppName
AppVersion=$AppVersion
DefaultDirName={autopf}\$AppName
DefaultGroupName=$AppName
OutputDir=$OutputDir
OutputBaseFilename=$AppName-v$AppVersion-Setup
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64

[Files]
Source: "staging\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\$AppName"; Filename: "{app}\empos.exe"
Name: "{autodesktop}\$AppName"; Filename: "{app}\empos.exe"

[Run]
Filename: "{app}\empos.exe"; Description: "{cm:LaunchProgram,$AppName}"; Flags: nowait postinstall skipifsilent
"@

Set-Content -Path $InnoScript -Value $InnoContent

# If iscc (Inno Setup Compiler) is present in PATH or standard location, compile directly
$InnoCompiler = Get-Command "iscc.exe" -ErrorAction SilentlyContinue
if (!$InnoCompiler) {
    if (Test-Path "C:\Program Files (x86)\Inno Setup 6\ISCC.exe") {
        $InnoCompiler = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
    }
}

if ($InnoCompiler) {
    Write-Host "[3/4] Compiling Windows Installer Package via $InnoCompiler..." -ForegroundColor Green
    & $InnoCompiler $InnoScript
} else {
    Write-Host "[3/4] Packaging staged release zip / bundle (Inno/WiX compiler ready)..." -ForegroundColor Green
    Compress-Archive -Path "$StagingDir\*" -DestinationPath "$OutputDir\$AppName-v$AppVersion-Windows-x64.zip" -Force
}

Write-Host "[4/4] Windows Release Artifact Generated in $OutputDir" -ForegroundColor Green
Write-Host "Packaging Complete!" -ForegroundColor Cyan
