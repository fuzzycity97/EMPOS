# EMPOS Isolated Testbed - Triad E2E Testing Suite
### Appium + AskUI + Applitools Eyes

This directory contains the **Triad End-to-End Testing Suite** for EMPOS, pairing:
1. **Appium (WebdriverIO)**: Structural state and widget tree driver (enters text, triggers buttons, manages Dart VM).
2. **AskUI**: Real-time OS Vision AI auditor (detects runtime text clipping, banner popups, layout overflows, and cross-window updates).
3. **Applitools Eyes**: Visual AI regression auditor (maintains historical pixel and layout baselines across releases, detects unexpected UI shifts).

This entire folder (`EMPOS_TESTBED`) is an **isolated clone** of your primary repository. Running tests here will **never touch or disrupt your main production codebase or operational database**.

---

## 🛡️ Multi-Layer Isolation Guarantees

1. **Zero Contamination of Main Codebase**:
   - Primary Workspace: `c:\Users\Mohamed samir\Downloads\fluttergg\omni_sys\EMPOS`
   - Testbed Workspace: `c:\Users\Mohamed samir\Downloads\fluttergg\omni_sys\EMPOS_TESTBED`
2. **Database Isolation**:
   - The testbed runs with:
     ```
     --dart-define=INSTANCE_ID=test_receptionist
     --dart-define=INSTANCE_ID=test_doctor
     ```
   - All Hive tables and test records are written to disposable test folders:
     `AppData\Roaming\EMPOS_Database_test_receptionist` and `EMPOS_Database_test_doctor`.
   - Your real `EMPOS_Database_1` or live customer and clinic balances remain untouched.

---

## 🚀 Quick Start

### 1. Install Node Dependencies
From `EMPOS_TESTBED\e2e`:
```powershell
npm.cmd install
```

### 2. Set Applitools API Key (Optional)
If you have an Applitools account, set your API key to upload visual regression baselines to your dashboard:
```powershell
$env:APPLITOOLS_API_KEY = "your_applitools_key_here"
```

### 3. Run the Triad Test Suite
```powershell
powershell -ExecutionPolicy Bypass -File .\run_e2e.ps1
```
Or directly via npm:
```powershell
npm.cmd test
```

---

## 🔄 Keeping the Testbed Synced with Your Main Version

Whenever you push or make new changes in your main `EMPOS` folder, update this testbed clone in one step:

```powershell
# Inside EMPOS_TESTBED:
git pull origin main
```

---

## ⚙️ Environment Best Practices for 100% Accuracy

1. **Display Scaling**: Keep your Windows display scale at **100%** (Settings > Display > Scale: 100%).
2. **Resolution**: 1920x1080 (Full HD) recommended.
3. **Appium Flutter Driver**: When running full automation, start Appium on port `4723`:
   ```powershell
   appium --port 4723
   ```
