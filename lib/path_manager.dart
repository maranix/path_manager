import 'dart:io';
import 'src/platform_path_manager.dart';
import 'src/exceptions.dart';

export 'src/android_path_manager.dart';
export 'src/foundation_path_manager.dart';
export 'src/exceptions.dart';

/// A class providing unified access to commonly used directories on the host file system.
///
/// This library provides a clean API for resolving platform directories across Android,
/// iOS, and macOS using direct interop (JNI for Android, Objective-C FFI for macOS/iOS).
///
/// ### Examples
///
/// ```dart
/// // Retrieve the temporary directory
/// final tempDir = await PathManager.getTemporaryDirectory();
/// print('Temporary directory path: ${tempDir.path}');
///
/// // Retrieve the documents directory
/// final docsDir = await PathManager.getApplicationDocumentsDirectory();
/// print('Documents directory path: ${docsDir.path}');
///
/// // Retrieve the directory excluded from backups
/// final noBackupPath = await PathManager.getApplicationNoBackupPath();
/// print('No-backup directory: $noBackupPath');
/// ```
abstract final class PathManager {
  /// Gets the path to the temporary directory on the host device.
  ///
  /// This directory is suitable for storing temporary cache files that can be
  /// deleted by the system or application at any time. It is not backed up.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final tempDir = await PathManager.getTemporaryDirectory();
  /// final cacheFile = File('${tempDir.path}/temp_cache.txt');
  /// await cacheFile.writeAsString('Temporary data');
  /// ```
  static Future<Directory> getTemporaryDirectory() async {
    final String? path = await PlatformPathManager.instance.getTemporaryPath();
    if (path == null) {
      throw MissingPlatformDirectoryException(
        'Unable to get temporary directory',
      );
    }
    return Directory(path);
  }

  /// Gets the path to the application support directory on the host device.
  ///
  /// Use this directory to place files that are application-created, but not
  /// user-created, such as databases, application state, and other internal files.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final supportDir = await PathManager.getApplicationSupportDirectory();
  /// final dbFile = File('${supportDir.path}/app_database.db');
  /// ```
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

  /// Gets the path to the application documents directory on the host device.
  ///
  /// Use this directory to store user-generated content and files that cannot be
  /// recreated by the application, such as user profiles, settings, or user documents.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final docsDir = await PathManager.getApplicationDocumentsDirectory();
  /// final userProfile = File('${docsDir.path}/profile.json');
  /// await userProfile.writeAsString('{"username": "JohnDoe"}');
  /// ```
  static Future<Directory> getApplicationDocumentsDirectory() async {
    final String? path = await PlatformPathManager.instance.getDocumentsPath();
    if (path == null) {
      throw MissingPlatformDirectoryException(
        'Unable to get application documents directory',
      );
    }
    return Directory(path);
  }

  /// Gets the path to the application caches directory on the host device.
  ///
  /// Use this directory for data that can be recreated by the application but should
  /// persist longer than temporary files, such as downloaded image caches.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final cacheDir = await PathManager.getCachesDirectory();
  /// final cachedImage = File('${cacheDir.path}/avatar_cache.png');
  /// ```
  static Future<Directory> getCachesDirectory() async {
    final String? path = await PlatformPathManager.instance.getCachesPath();
    if (path == null) {
      throw MissingPlatformDirectoryException('Unable to get caches directory');
    }
    return Directory(path);
  }

  /// Gets the path to a designated application directory that is excluded from backups.
  ///
  /// - **iOS & macOS**: Resolves a directory named `__no_backup__` under the application
  ///   support directory. If it does not exist, it is created and programmatically
  ///   marked with the backup exclusion flag (`NSURLIsExcludedFromBackupKey`). If it
  ///   already exists but is not marked as excluded, throws a
  ///   [BackupExclusionConflictException].
  /// - **Android**: Resolves a directory named `__no_backup__` under the application's
  ///   internal files directory. Note that because Android does not support dynamic
  ///   programmatic backup exclusions of specific paths, developers must manually
  ///   configure exclusion rules in their XML configuration files (e.g., `backup_rules.xml`).
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// try {
  ///   final path = await PathManager.getApplicationNoBackupPath();
  ///   final localLog = File('$path/diagnostics.log');
  ///   await localLog.writeAsString('Sensitive local telemetry...');
  /// } on BackupExclusionConflictException catch (e) {
  ///   print('Backup exclusion error: ${e.message}');
  /// }
  /// ```
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
  /// - **iOS & macOS**: Programmatically marks the file/directory with the
  ///   `NSURLIsExcludedFromBackupKey` resource key.
  /// - **Android**: This method is not supported and throws an [UnsupportedError].
  ///   Android users should configure their backup exclusion rules via XML rules.
  ///
  /// Throws a [FileSystemException] if the path does not exist on Apple platforms
  /// or if changing the exclusion status fails.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final document = File('${docsDir.path}/large_dataset.bin');
  /// await document.writeAsBytes(datasetBytes);
  ///
  /// // Exclude this specific file from Apple iCloud/iTunes backups
  /// await PathManager.setApplicationPathIsExcludedFromBackup(document.path, true);
  /// ```
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
