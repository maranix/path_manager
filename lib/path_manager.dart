import 'dart:io';
import 'src/platform_path_manager.dart';

export 'src/platform_path_manager.dart';

/// Exception thrown when the platform is unable to provide a directory.
class MissingPlatformDirectoryException implements Exception {
  /// Message explaining the error.
  final String message;

  /// Creates a new [MissingPlatformDirectoryException].
  MissingPlatformDirectoryException(this.message);

  @override
  String toString() => 'MissingPlatformDirectoryException: $message';
}

/// Exception thrown when a user-created directory at the designated no-backup path is not excluded from backup.
class BackupExclusionConflictException implements Exception {
  /// The path to the directory that caused the conflict.
  final String path;

  /// Message explaining the conflict.
  final String message;

  /// Creates a new [BackupExclusionConflictException].
  BackupExclusionConflictException(this.path, this.message);

  @override
  String toString() =>
      'BackupExclusionConflictException: $message (path: $path)';
}

/// A class providing unified access to commonly used directories on the host file system.
abstract final class PathManager {
  /// Path to the temporary directory on the device that is not backed up and is
  /// suitable for storing caches of downloaded files.
  static Future<Directory> getTemporaryDirectory() async {
    final String? path = await PlatformPathManager.instance.getTemporaryPath();
    if (path == null) {
      throw MissingPlatformDirectoryException(
        'Unable to get temporary directory',
      );
    }
    return Directory(path);
  }

  /// Path to a directory where the application may place data that is
  /// user-generated, or that cannot otherwise be recreated by your application.
  static Future<Directory> getApplicationSupportDirectory() async {
    final String? path = await PlatformPathManager.instance
        .getApplicationSupportPath();
    if (path == null) {
      throw MissingPlatformDirectoryException(
        'Unable to get application support directory',
      );
    }
    return Directory(path);
  }

  /// Path to the directory where the application may place user-generated data.
  static Future<Directory> getApplicationDocumentsDirectory() async {
    final String? path = await PlatformPathManager.instance.getDocumentsPath();
    if (path == null) {
      throw MissingPlatformDirectoryException(
        'Unable to get application documents directory',
      );
    }
    return Directory(path);
  }

  /// Path to the cache directory on the device.
  static Future<Directory> getCachesDirectory() async {
    final String? path = await PlatformPathManager.instance.getCachesPath();
    if (path == null) {
      throw MissingPlatformDirectoryException('Unable to get caches directory');
    }
    return Directory(path);
  }

  /// Path to a directory where the application may place data that should not be backed up.
  ///
  /// On iOS and macOS, this creates a `__no_backup__` directory under the application support
  /// directory, marks it as excluded from iCloud/iTunes backups, and returns its path.
  static Future<String> getApplicationNoBackupPath() async {
    final String? path = await PlatformPathManager.instance
        .getApplicationNoBackupPath();
    if (path == null) {
      throw MissingPlatformDirectoryException(
        'Unable to get application no backup directory path',
      );
    }
    return path;
  }

  /// Sets whether the file or directory at [path] should be excluded from backups.
  ///
  /// On iOS and macOS, this sets the `NSURLIsExcludedFromBackupKey` resource value.
  /// Other platforms throw an [UnimplementedError].
  static Future<void> setApplicationPathIsExcludedFromBackup(
    String path,
    bool exclude,
  ) async {
    await PlatformPathManager.instance.setApplicationPathIsExcludedFromBackup(
      path,
      exclude,
    );
  }
}
