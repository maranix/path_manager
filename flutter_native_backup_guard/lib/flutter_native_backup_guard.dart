import 'package:flutter_native_backup_guard_platform_interface/flutter_native_backup_guard_platform_interface.dart';

/// Exposes APIs to exclude files and directories from backups on iOS and Android.
class FlutterNativeBackupGuard {
  /// Excludes the file or directory at the given [path] from backups.
  ///
  /// On iOS: Sets the `NSURLIsExcludedFromBackupKey` attribute.
  /// On Android: Checks if the path is inside the `no_backup` or other inherently excluded directories.
  /// Returns `true` if successful or inherently excluded.
  static Future<bool> excludeFromBackup(String path) {
    return FlutterNativeBackupGuardPlatform.instance.excludeFromBackup(path);
  }

  /// Returns the absolute path to the directory that is excluded from backups.
  ///
  /// On Android, this returns the `no_backup` directory path.
  /// On iOS, this returns a custom `NoBackup` directory under the Application Support folder.
  static Future<String> getNoBackupFilesDir() {
    return FlutterNativeBackupGuardPlatform.instance.getNoBackupFilesDir();
  }
}
