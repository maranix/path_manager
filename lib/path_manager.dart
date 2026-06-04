import 'dart:io';
import 'src/path_manager_platform.dart';

export 'src/path_manager_platform.dart';

/// Exception thrown when the platform is unable to provide a directory.
class MissingPlatformDirectoryException implements Exception {
  /// Message explaining the error.
  final String message;

  /// Creates a new [MissingPlatformDirectoryException].
  MissingPlatformDirectoryException(this.message);

  @override
  String toString() => 'MissingPlatformDirectoryException: $message';
}

/// A class providing unified access to commonly used directories on the host file system.
abstract final class PathManager {
  /// Path to the temporary directory on the device that is not backed up and is
  /// suitable for storing caches of downloaded files.
  static Future<Directory> getTemporaryDirectory() async {
    final String? path = await PathManagerPlatform.instance.getTemporaryPath();
    if (path == null) {
      throw MissingPlatformDirectoryException('Unable to get temporary directory');
    }
    return Directory(path);
  }

  /// Path to a directory where the application may place data that is
  /// user-generated, or that cannot otherwise be recreated by your application.
  static Future<Directory> getApplicationSupportDirectory() async {
    final String? path = await PathManagerPlatform.instance.getApplicationSupportPath();
    if (path == null) {
      throw MissingPlatformDirectoryException('Unable to get application support directory');
    }
    return Directory(path);
  }

  /// Path to the directory where the application may place user-generated data.
  static Future<Directory> getApplicationDocumentsDirectory() async {
    final String? path = await PathManagerPlatform.instance.getDocumentsPath();
    if (path == null) {
      throw MissingPlatformDirectoryException('Unable to get application documents directory');
    }
    return Directory(path);
  }

  /// Path to the cache directory on the device.
  static Future<Directory> getCachesDirectory() async {
    final String? path = await PathManagerPlatform.instance.getCachesPath();
    if (path == null) {
      throw MissingPlatformDirectoryException('Unable to get caches directory');
    }
    return Directory(path);
  }
}
