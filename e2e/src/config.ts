import path from 'path';

export const CONFIG = {
  // Test Environment Isolation
  appPath: path.resolve(__dirname, '../../build/windows/x64/runner/Debug/empos.exe'),
  repoRoot: path.resolve(__dirname, '../../'),
  
  // Appium Server Connection
  appium: {
    host: '127.0.0.1',
    port: 4723,
    path: '/',
  },

  // Multi-Instance Triad Node Configuration
  instances: {
    god: {
      id: 'GOD',
      observatoryPort: 8887,
      syncPort: 9090,
      dartArgs: [
        '--dart-define=INSTANCE_ID=GOD',
        '--dart-define=SYNC_PORT=9090',
        '--dart-define=ENVIRONMENT=test',
      ],
      capabilities: {
        platformName: 'Windows',
        'appium:automationName': 'Flutter',
        'appium:app': path.resolve(__dirname, '../../build/windows/x64/runner/Debug/empos.exe'),
        'appium:environment': {
          'FLUTTER_TEST_ARGS': '--observatory-port=8887 --dart-define=INSTANCE_ID=GOD'
        }
      }
    },
    receptionist: {
      id: 'test_receptionist',
      observatoryPort: 8888,
      syncPort: 9092,
      dartArgs: [
        '--dart-define=INSTANCE_ID=test_receptionist',
        '--dart-define=SYNC_PORT=9092',
        '--dart-define=ENVIRONMENT=test',
      ],
      capabilities: {
        platformName: 'Windows',
        'appium:automationName': 'Flutter',
        'appium:app': path.resolve(__dirname, '../../build/windows/x64/runner/Debug/empos.exe'),
        'appium:environment': {
          'FLUTTER_TEST_ARGS': '--observatory-port=8888 --dart-define=INSTANCE_ID=test_receptionist'
        }
      }
    },
    doctor: {
      id: 'test_doctor',
      observatoryPort: 8889,
      syncPort: 9091,
      dartArgs: [
        '--dart-define=INSTANCE_ID=test_doctor',
        '--dart-define=SYNC_PORT=9091',
        '--dart-define=ENVIRONMENT=test',
      ],
      capabilities: {
        platformName: 'Windows',
        'appium:automationName': 'Flutter',
        'appium:app': path.resolve(__dirname, '../../build/windows/x64/runner/Debug/empos.exe'),
        'appium:environment': {
          'FLUTTER_TEST_ARGS': '--observatory-port=8889 --dart-define=INSTANCE_ID=test_doctor'
        }
      }
    }
  },

  // AskUI Vision AI Configuration
  askui: {
    expectedResolution: { width: 1920, height: 1080 },
    screenshotDir: path.resolve(__dirname, '../artifacts/screenshots'),
  },

  // Applitools Visual AI Regression Suite Configuration
  applitools: {
    apiKey: process.env.APPLITOOLS_API_KEY || '',
    appName: 'EMPOS Multi-Instance Suite',
    batchName: 'EMPOS Visual Regression Suite',
    matchLevel: 'Strict', // 'Strict', 'Layout', or 'IgnoreColors'
  }
};
