import 'dart:io';

import 'package:jni/jni.dart' as jni;
import 'package:jni_flutter/jni_flutter.dart' as jnif;
import 'package:path_manager_platform_interface/path_manager_platform_interface.dart';

import '../bindings/android.g.dart' as android_jni;

/// The Android implementation of [PlatformPathManager] using JNI via FFI.
///
/// This class handles directory path resolutions by communicating with the
/// Android platform APIs using the generated JNI bindings.
class AndroidPathManager extends PlatformPathManager {
  /// Registers the Android implementation of [PlatformPathManager].
  static void registerWith() {
    PlatformPathManager.instance = AndroidPathManager();
  }

  /// Obtains the active Android application context via JNI.
  android_jni.Context _getContext() {
    return jnif.androidApplicationContext.as(android_jni.Context.type);
  }

  /// Extracts the path string from a JNI [android_jni.File] and releases the file handle.
  String? _resolveFilePath(android_jni.File? file) {
    if (file == null) return null;
    try {
      return file.absolutePath?.toDartString();
    } finally {
      file.release();
    }
  }

  /// Extracts path strings from a JNI [jni.JArray] of files and releases all handles.
  List<String>? _resolveFilePaths(jni.JArray<android_jni.File?>? array) {
    if (array == null) return null;
    try {
      final paths = <String>[];
      for (var i = 0; i < array.length; i++) {
        final file = array[i];
        if (file != null) {
          final path = file.absolutePath?.toDartString();
          if (path != null) paths.add(path);
          file.release();
        }
      }
      return paths.isEmpty ? null : paths;
    } finally {
      array.release();
    }
  }

  @override
  Future<String?> getTemporaryPath() async {
    final context = _getContext();
    try {
      return _resolveFilePath(context.cacheDir);
    } finally {
      context.release();
    }
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    final context = _getContext();
    try {
      return _resolveFilePath(context.filesDir);
    } finally {
      context.release();
    }
  }

  @override
  Future<String?> getDocumentsPath() async {
    final context = _getContext();
    try {
      return _resolveFilePath(context.filesDir);
    } finally {
      context.release();
    }
  }

  @override
  Future<String?> getApplicationCachePath() async {
    final context = _getContext();
    try {
      return _resolveFilePath(context.cacheDir);
    } finally {
      context.release();
    }
  }

  @override
  Future<String?> getApplicationNoBackupDirectory() async {
    final supportPath = await getApplicationSupportPath();
    if (supportPath == null) return null;

    final noBackupPath = '$supportPath/__no_backup__';
    final dir = Directory(noBackupPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return noBackupPath;
  }

  @override
  Future<String?> getExternalStoragePath(StorageDirectory dir) async {
    final context = _getContext();
    try {
      final jTypeStr = dir.dirName.toJString();
      try {
        return _resolveFilePath(context.getExternalFilesDir(jTypeStr));
      } finally {
        jTypeStr.release();
      }
    } catch (e) {
      throw MissingPlatformDirectoryException(
        'Failed to resolve external storage directory on Android: $e. '
        'Ensure external storage is available and properly configured in AndroidManifest.xml. '
        'If accessing shared external directories, ensure appropriate permissions '
        '(e.g., READ_EXTERNAL_STORAGE / WRITE_EXTERNAL_STORAGE) are declared in AndroidManifest.xml '
        'and granted at runtime. Refer to path_manager documentation for details.',
      );
    } finally {
      context.release();
    }
  }

  @override
  Future<List<String>?> getExternalStoragePaths([
    List<StorageDirectory> dirs = StorageDirectory.values,
  ]) async {
    final context = _getContext();
    try {
      final paths = <String>[];
      for (final dir in dirs) {
        final jTypeStr = dir.dirName.toJString();
        try {
          final arrayPaths = _resolveFilePaths(
            context.getExternalFilesDirs(jTypeStr),
          );
          if (arrayPaths != null) {
            paths.addAll(arrayPaths);
          }
        } finally {
          jTypeStr.release();
        }
      }
      return paths.isEmpty ? null : paths;
    } catch (e) {
      throw MissingPlatformDirectoryException(
        'Failed to resolve external storage directories on Android: $e. '
        'Ensure external storage is mounted and properly configured in AndroidManifest.xml. '
        'If accessing shared directories, ensure appropriate permissions are declared '
        'in AndroidManifest.xml and granted at runtime. Refer to path_manager documentation for details.',
      );
    } finally {
      context.release();
    }
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    final context = _getContext();
    try {
      return _resolveFilePaths(context.externalCacheDirs);
    } catch (e) {
      throw MissingPlatformDirectoryException(
        'Failed to resolve external cache directories on Android: $e. '
        'Ensure external storage is mounted and properly configured in AndroidManifest.xml. '
        'Refer to path_manager documentation for details.',
      );
    } finally {
      context.release();
    }
  }

  @override
  Future<String?> getDownloadsPath() async {
    final context = _getContext();
    try {
      final jTypeStr = StorageDirectory.downloads.dirName.toJString();
      try {
        return _resolveFilePath(context.getExternalFilesDir(jTypeStr));
      } finally {
        jTypeStr.release();
      }
    } catch (e) {
      throw MissingPlatformDirectoryException(
        'Failed to resolve downloads directory on Android: $e. '
        'Ensure storage is available and properly configured in AndroidManifest.xml. '
        'Refer to path_manager documentation for details.',
      );
    } finally {
      context.release();
    }
  }

  @override
  Future<void> setApplicationPathIsExcludedFromBackup(
    String path,
    bool exclude,
  ) async {
    throw UnsupportedError(
      'Backup exclusion cannot be set programmatically on Android. '
      'Please configure backup rules manually in your Android XML configuration '
      '(e.g., res/xml/backup_rules.xml).',
    );
  }
}
