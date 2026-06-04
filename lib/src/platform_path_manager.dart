import 'dart:async';
import 'dart:io';
import 'foundation_path_manager.dart';

/// The platform interface for PathManager.
abstract class PlatformPathManager {
  /// The active platform-specific instance of [PlatformPathManager].
  static PlatformPathManager instance = _getDefaultPlatform();

  static PlatformPathManager _getDefaultPlatform() {
    if (Platform.isMacOS || Platform.isIOS) {
      return FoundationPathManager();
    }
    throw UnimplementedError('Platform is not supported.');
  }

  /// Gets the path to the temporary directory.
  Future<String?> getTemporaryPath();

  /// Gets the path to the application support directory.
  Future<String?> getApplicationSupportPath();

  /// Gets the path to the application documents directory.
  Future<String?> getDocumentsPath();

  /// Gets the path to the caches directory.
  Future<String?> getCachesPath();

  /// Sets whether the file or directory at [path] should be excluded from backups.
  Future<void> setApplicationPathIsExcludedFromBackup(
    String path,
    bool exclude,
  );
}
