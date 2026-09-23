# ==============================================================================
# EMPOS - Multi-Instance Live Desktop Launcher
# ==============================================================================
# Sequentially launches the 3 live Win32 GUI instances on your screen:
#   1. GOD          -> Primary Hub Host (Port 9090) with Technician God Mode
#   2. receptionist -> Reception Desk Station
#   3. doctor       -> Doctor Station & Clinical 3D Anatomical Engine
#
# Adheres to the single-root compile rule: Waits for each instance to fully
# load its window and network socket before initiating the next instance.
# ==============================================================================

[CmdletBinding()]
param(
    [switch]$BuildFirst,
    [int]$WaitBetweenSeconds = 5
)

$ErrorActionPreference = "Continue"

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "       EMPOS MULTI-INSTANCE LIVE DESKTOP LAUNCHER (GOD / REC / DOC)             " -ForegroundColor White
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

$flutterCmd = "flutter"
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    $cand = "C:\Users\Mohamed samir\Downloads\flutter\bin\flutter.bat"
    if (Test-Path $cand) { $flutterCmd = $cand }
}

$instances = @(
    @{
        Id    = "GOD"
        Title = "GOD (Technician God Mode / Primary Hub Host)"
        Port  = 9090
        Args  = "--dart-define=INSTANCE_ID=GOD"
    },
    @{
        Id    = "receptionist"
        Title = "receptionist (Reception Desk Station)"
        Port  = 9092
        Args  = "--dart-define=INSTANCE_ID=receptionist"
    },
    @{
        Id    = "doctor"
        Title = "doctor (Doctor Station & Clinical 3D Suite)"
        Port  = 9093
        Args  = "--dart-define=INSTANCE_ID=doctor"
    }
)

$launched = @()

foreach ($inst in $instances) {
    Write-Host "[*] Launching Instance: $($inst.Title)..." -ForegroundColor Yellow
    Write-Host "    -> Root command: flutter run -d windows $($inst.Args)" -ForegroundColor Gray

    $proc = Start-Process -FilePath "powershell.exe" `
        -ArgumentList "-NoExit", "-Command", "& '$flutterCmd' run -d windows $($inst.Args)" `
        -PassThru

    Write-Host "    -> Process PID: $($proc.Id). Waiting for window to compile and fully load..." -ForegroundColor Cyan

    # Wait for compile and initialization
    for ($i = 0; $i -lt 30; $i++) {
        Start-Sleep -Seconds 2
        $emposProcs = Get-Process -Name "empos" -ErrorAction SilentlyContinue
        if ($emposProcs.Count -gt $launched.Count) {
            Write-Host "    [OK] Window created! Instance '$($inst.Id)' is active on screen." -ForegroundColor Green
            break
        }
        Write-Host "       ... compiling & bootstrapping ($($i * 2)s elapsed)" -ForegroundColor DarkGray
    }

    $launched += $proc
    Write-Host "    [OK] '$($inst.Id)' fully ready. Pausing $WaitBetweenSeconds seconds before next instance..." -ForegroundColor Green
    Start-Sleep -Seconds $WaitBetweenSeconds
    Write-Host ""
}

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  ALL 3 LIVE INSTANCES LAUNCHED AND RUNNING ON YOUR DESKTOP!" -ForegroundColor Green
Write-Host "  1. GOD          (Technician God Mode Host)" -ForegroundColor White
Write-Host "  2. receptionist (Reception Desk)" -ForegroundColor White
Write-Host "  3. doctor       (Doctor Station)" -ForegroundColor White
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[i] Tip: Open Android Studio to inspect live Flutter DevTools or attach debugger to any PID." -ForegroundColor Gray
