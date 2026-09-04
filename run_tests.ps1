# run_tests.ps1
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

if ($Target) {
    flutter test --reporter expanded --concurrency=$concurrency $Target
} else {
    flutter test --reporter expanded --concurrency=$concurrency
}
