# EMPOS Isolated E2E Hybrid Test Runner
Param(
  [string]$TestFile = "src/tests/hybrid_clinic_sync.test.ts"
)

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  EMPOS Automated E2E Runner (Appium + AskUI Testbed)       " -ForegroundColor Cyan
Write-Host "  Isolated Clone: EMPOS_TESTBED                             " -ForegroundColor DarkCyan
Write-Host "============================================================" -ForegroundColor Cyan

# 1. Ensure Dependencies
if (-not (Test-Path "$PSScriptRoot\node_modules")) {
  Write-Host "[*] Installing Node dependencies..." -ForegroundColor Yellow
  npm.cmd install --prefix "$PSScriptRoot"
}

# 2. Check Display Scaling Advisory
Write-Host "[i] Tip: For AskUI pixel precision, keep Windows display scale at 100%." -ForegroundColor Gray

# 3. Execute TypeScript Test Suite
Write-Host "[*] Executing Hybrid Test: $TestFile" -ForegroundColor Green
npx.cmd ts-node "$PSScriptRoot\$TestFile"

if ($LASTEXITCODE -eq 0) {
  Write-Host "[✓] E2E Test Suite Finished Successfully." -ForegroundColor Green
} else {
  Write-Host "[!] E2E Test Run Completed with Warnings or Errors." -ForegroundColor Red
}
