import 'package:flutter_native_backup_guard_platform_interface/flutter_native_backup_guard_platform_interface.dart';

/// The iOS implementation of the [FlutterNativeBackupGuardPlatform] of the flutter_native_backup_guard plugin.
class FlutterNativeBackupGuardIos extends FlutterNativeBackupGuardPlatform {
  /// Registers this class as the default instance of [FlutterNativeBackupGuardPlatform].
  static void registerWith() {
    FlutterNativeBackupGuardPlatform.instance = FlutterNativeBackupGuardIos();
  }

  final BackupGuardApi _api = BackupGuardApi();

  @override
  Future<bool> excludeFromBackup(String path) {
    return _api.excludeFromBackup(path);
  }

  @override
  Future<String> getNoBackupFilesDir() {
    return _api.getNoBackupFilesDir();
  }
}
