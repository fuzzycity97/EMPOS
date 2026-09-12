# run_tests.ps1 - EMPOS Test Runner with Visual Progress Bar
param(
    [string]$Target = ""
)

$concurrency = $env:NUMBER_OF_PROCESSORS
if (-not $concurrency) { $concurrency = 4 }

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    $flutterBin = "C:\Users\Mohamed samir\Downloads\flutter\bin"
    if (Test-Path $flutterBin) {
        $env:Path = "$flutterBin;$env:Path"
    }
}

# 1. Estimate total test count to compute accurate loading percentage
$targetFiles = @()
$targetList = @()
if ($Target) {
    $targetList = $Target -split '\s+' | Where-Object { $_ }
    foreach ($arg in $targetList) {
        if (Test-Path $arg) { $targetFiles += (Get-Item $arg).FullName }
    }
} else {
    $targetFiles = Get-ChildItem -Path "test" -Filter "*_test.dart" -Recurse | Select-Object -ExpandProperty FullName
}

$estimatedTotal = 0
foreach ($file in $targetFiles) {
    $foundMatches = Select-String -Path $file -Pattern '\b(test|testWidgets)\s*\('
    if ($foundMatches) { $estimatedTotal += $foundMatches.Count }
}
if ($estimatedTotal -lt 1) { $estimatedTotal = 1 }

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  EMPOS Test Suite - Running Tests with Live Progress" -ForegroundColor Cyan
if ($Target) {
    Write-Host "  Target: $Target" -ForegroundColor Gray
} else {
    Write-Host "  Target: All tests in test/ ($($targetFiles.Count) test files)" -ForegroundColor Gray
}
Write-Host "  Total estimated tests: $estimatedTotal" -ForegroundColor Gray
Write-Host "============================================================" -ForegroundColor Cyan

$barWidth = 24
$completedCount = 0
$lastPassed = 0
$lastFailed = 0

if ($Target) {
    & flutter test --reporter expanded --concurrency=$concurrency $targetList 2>&1 | ForEach-Object {
        $line = $_.ToString()

        if ($line -match '^(\d\d:\d\d)\s+\+(\d+)(?:\s+\-(\d+))?:\s*(.*)$') {
            $elapsed = $matches[1]
            $passed = [int]$matches[2]
            $failed = if ($matches[3]) { [int]$matches[3] } else { 0 }
            $testName = $matches[4].Trim()

            $completedCount = $passed + $failed
            if ($completedCount -gt $estimatedTotal) {
                $estimatedTotal = $completedCount
            }

            $percent = [Math]::Min(100, [int](($completedCount / [Math]::Max(1, $estimatedTotal)) * 100))
            $filled = [int](($percent / 100) * $barWidth)
            $empty = $barWidth - $filled
            $barStr = ("#" * $filled) + ("-" * $empty)

            $displayTest = if ($testName.Length -gt 50) { $testName.Substring(0, 47) + "..." } else { $testName }

            Write-Progress -Activity "EMPOS Test Runner" `
                -Status "[$barStr] $percent% | $completedCount/$estimatedTotal completed | Elapsed: $elapsed" `
                -CurrentOperation $displayTest `
                -PercentComplete $percent

            $statusColor = if ($failed -gt 0) { "Red" } else { "Cyan" }
            if ($testName -match '\[E\]') {
                Write-Host "`n[$barStr] FAIL: $testName" -ForegroundColor Red
            } else {
                Write-Host "`r[$barStr] $percent% ($completedCount/$estimatedTotal) [$elapsed] $displayTest" -NoNewline -ForegroundColor $statusColor
            }
        }
        elseif ($line -match 'All tests passed!') {
            $percent = 100
            $barStr = "#" * $barWidth
            Write-Progress -Activity "EMPOS Test Runner" -Status "Complete: All tests passed!" -PercentComplete 100 -Completed
            Write-Host "`n[$barStr] 100% - SUCCESS: All tests passed successfully!" -ForegroundColor Green
        }
        else {
            if ($line.Trim()) {
                Write-Host $line -ForegroundColor Red
            }
        }
    }
} else {
    & flutter test --reporter expanded --concurrency=$concurrency 2>&1 | ForEach-Object {
        $line = $_.ToString()

        if ($line -match '^(\d\d:\d\d)\s+\+(\d+)(?:\s+\-(\d+))?:\s*(.*)$') {
            $elapsed = $matches[1]
            $passed = [int]$matches[2]
            $failed = if ($matches[3]) { [int]$matches[3] } else { 0 }
            $testName = $matches[4].Trim()

            $completedCount = $passed + $failed
            if ($completedCount -gt $estimatedTotal) {
                $estimatedTotal = $completedCount
            }

            $percent = [Math]::Min(100, [int](($completedCount / [Math]::Max(1, $estimatedTotal)) * 100))
            $filled = [int](($percent / 100) * $barWidth)
            $empty = $barWidth - $filled
            $barStr = ("#" * $filled) + ("-" * $empty)

            $displayTest = if ($testName.Length -gt 50) { $testName.Substring(0, 47) + "..." } else { $testName }

            Write-Progress -Activity "EMPOS Test Runner" `
                -Status "[$barStr] $percent% | $completedCount/$estimatedTotal completed | Elapsed: $elapsed" `
                -CurrentOperation $displayTest `
                -PercentComplete $percent

            $statusColor = if ($failed -gt 0) { "Red" } else { "Cyan" }
            if ($testName -match '\[E\]') {
                Write-Host "`n[$barStr] FAIL: $testName" -ForegroundColor Red
            } else {
                Write-Host "`r[$barStr] $percent% ($completedCount/$estimatedTotal) [$elapsed] $displayTest" -NoNewline -ForegroundColor $statusColor
            }
        }
        elseif ($line -match 'All tests passed!') {
            $percent = 100
            $barStr = "#" * $barWidth
            Write-Progress -Activity "EMPOS Test Runner" -Status "Complete: All tests passed!" -PercentComplete 100 -Completed
            Write-Host "`n[$barStr] 100% - SUCCESS: All tests passed successfully!" -ForegroundColor Green
        }
        else {
            if ($line -match 'Some tests failed|Compilation failed|Error:|Expected:|Actual:|Which:|package:|test/|Exception:|at ') {
                Write-Host $line -ForegroundColor Red
            }
        }
    }
}

Write-Progress -Activity "EMPOS Test Runner" -Completed
Write-Host ""
