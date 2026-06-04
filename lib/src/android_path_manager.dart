import 'dart:io';
import 'package:jni/jni.dart' as jni;
import 'package:jni_flutter/jni_flutter.dart' as jnif;

import './platform_path_manager.dart';
import '../bindings/android/bindings.g.dart' as android_jni;

/// The Android implementation of [PlatformPathManager] using JNI via FFI.
///
/// This class handles directory path resolutions by communicating with the
/// Android platform APIs using the generated JNI bindings.
class AndroidPathManager extends PlatformPathManager {
  /// Registers the Android implementation of [PlatformPathManager].
  static void registerWith() {
    PlatformPathManager.instance = AndroidPathManager();
  }

  @override
  Future<String?> getTemporaryPath() async {
    final context = jnif.androidApplicationContext.as(android_jni.Context.type);

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
    final context = jnif.androidApplicationContext.as(android_jni.Context.type);

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
    final context = jnif.androidApplicationContext.as(android_jni.Context.type);

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
    final context = jnif.androidApplicationContext.as(android_jni.Context.type);

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
