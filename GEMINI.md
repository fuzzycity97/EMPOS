# EMPOS Project Rules & Guidelines

## MANDATORY: Live Loading Progress Bar for All Test Execution
Whenever ANY AI agent or developer executes tests in this project, they MUST ALWAYS adhere to the following rules:

1. **Always Use `.\run_tests.ps1 <target>` for Running Tests**:
   - **Never** invoke bare `flutter test <target>` directly. Bare `flutter test` hides progress and execution metrics from the user.
   - For a single or scoped test file, run:
     ```powershell
     powershell -ExecutionPolicy Bypass -File .\run_tests.ps1 test/your_test_file.dart
     ```
   - For multiple test files:
     ```powershell
     powershell -ExecutionPolicy Bypass -File .\run_tests.ps1 "test/file1_test.dart test/file2_test.dart"
     ```
   - For the full test suite (only when explicitly requested):
     ```powershell
     powershell -ExecutionPolicy Bypass -File .\run_tests.ps1
     ```

2. **Live Loading Progress Bar Guarantee**:
   - `run_tests.ps1` dynamically estimates the test count and streams live progress with an animated visual loading bar:
     `[############------------] 50% (2/4) [00:01] Running test name...`
   - It integrates PowerShell `Write-Progress` and real-time console updates showing:
     - Exact completion percentage (`%`)
     - Completed count / Total estimated tests (`completed/total`)
     - Real-time elapsed time (`[MM:SS]`)
     - Active test description
     - Instant failure highlight in red if an error occurs

3. **Quota & Efficiency Rule**:
   - Never run the entire test suite on every minor change.
   - Only execute the test file(s) relevant to what was touched using `run_tests.ps1 <target>`.
