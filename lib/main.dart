import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'features/sync/domain/services/sync_connection_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive in a dedicated EMPOS_Database sub-folder to keep documents clean
  if (!kIsWeb) {
    const instanceId = String.fromEnvironment('INSTANCE_ID', defaultValue: '1');
    final appDocDir = await getApplicationDocumentsDirectory();
    final dbDirectory = Directory(p.join(appDocDir.path, 'EMPOS_Database_$instanceId'));
    if (!dbDirectory.existsSync()) {
      dbDirectory.createSync(recursive: true);
      // Convenience: migrate existing data from legacy un-versioned folder for instance 1
      final legacyDir = Directory(p.join(appDocDir.path, 'EMPOS_Database'));
      if (instanceId == '1' && legacyDir.existsSync()) {
        try {
          for (final file in legacyDir.listSync()) {
            if (file is File) {
              file.copySync(p.join(dbDirectory.path, p.basename(file.path)));
            }
          }
        } catch (_) {}
      }
    }
    Hive.init(dbDirectory.path);
  } else {
    await Hive.initFlutter();
  }

  // Initialize Clean Architecture Service Locator (GetIt)
  await di.initServiceLocator();

  // Bootstrap Auto-Reconnection & Persistent Node Role (Host vs Client)
  final syncConnectionManager = SyncConnectionManager();
  try {
    await syncConnectionManager.bootstrapAutoConnect();
    if (!di.sl.isRegistered<SyncConnectionManager>()) {
      di.sl.registerSingleton<SyncConnectionManager>(syncConnectionManager);
    }
  } catch (e) {
    debugPrint('Auto-connect bootstrap failed gracefully: $e');
  }

  runApp(const EmposApp());
}