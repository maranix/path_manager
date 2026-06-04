import 'dart:io';
import 'package:jni/jni.dart';
import 'package:jni_flutter/jni_flutter.dart';
import '../bindings/android/bindings.g.dart' as android_jni;
import 'platform_path_manager.dart';

/// The Android implementation of [PlatformPathManager] using JNI via FFI.
class AndroidPathManager extends PlatformPathManager {
  @override
  Future<String?> getTemporaryPath() async {
    final context = androidApplicationContext.as(android_jni.Context.type);
    try {
      final cacheDir = context.cacheDir;
      if (cacheDir == null) return null;
      try {
        return cacheDir.absolutePath?.toDartString();
      } finally {
        cacheDir.release();
      }
    } finally {
      context.release();
    }
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    final context = androidApplicationContext.as(android_jni.Context.type);
    try {
      final filesDir = context.filesDir;
      if (filesDir == null) return null;
      try {
        return filesDir.absolutePath?.toDartString();
      } finally {
        filesDir.release();
      }
    } finally {
      context.release();
    }
  }

  @override
  Future<String?> getDocumentsPath() async {
    final context = androidApplicationContext.as(android_jni.Context.type);
    try {
      final filesDir = context.filesDir;
      if (filesDir == null) return null;
      try {
        return filesDir.absolutePath?.toDartString();
      } finally {
        filesDir.release();
      }
    } finally {
      context.release();
    }
  }

  @override
  Future<String?> getCachesPath() async {
    final context = androidApplicationContext.as(android_jni.Context.type);
    try {
      final cacheDir = context.cacheDir;
      if (cacheDir == null) return null;
      try {
        return cacheDir.absolutePath?.toDartString();
      } finally {
        cacheDir.release();
      }
    } finally {
      context.release();
    }
  }

  @override
  Future<String?> getApplicationNoBackupPath() async {
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
