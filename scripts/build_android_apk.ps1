# scripts/build_android_apk.ps1
# Automated Signed Android APK Packaging Pipeline for EMPOS / Omni System
param (
    [string]$OutputDir = "build\app\outputs\flutter-apk",
    [string]$AppVersion = "1.0.0"
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  EMPOS Automated Android Signed Release APK Pipeline" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Build Android Release APK
Write-Host "[1/3] Compiling Signed Android Release APK..." -ForegroundColor Yellow
flutter build apk --release

# 2. Check and Locate Release Artifact
$ReleaseApk = "$OutputDir\app-release.apk"
if (!(Test-Path $ReleaseApk)) {
    Write-Error "Android release build failed: Output APK not found at $ReleaseApk"
}

$ApkSize = (Get-Item $ReleaseApk).Length / 1MB
Write-Host "[2/3] Artifact Generated: $ReleaseApk ($([math]::Round($ApkSize, 2)) MB)" -ForegroundColor Green

# 3. Signature Verification (if apksigner available)
$ApkSigner = Get-Command "apksigner.bat" -ErrorAction SilentlyContinue
if ($ApkSigner) {
    Write-Host "[3/3] Verifying APK Signature..." -ForegroundColor Yellow
    & apksigner verify --verbose $ReleaseApk
} else {
    Write-Host "[3/3] APK compiled and ready for distribution." -ForegroundColor Green
}

Write-Host "Android Packaging Complete!" -ForegroundColor Cyan
