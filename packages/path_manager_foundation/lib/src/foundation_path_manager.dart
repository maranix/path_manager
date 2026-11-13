import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart' as pkg_ffi;
import 'package:objective_c/objective_c.dart' as objc;
import 'package:path_manager_platform_interface/path_manager_platform_interface.dart';

import '../bindings/foundation.g.dart';

/// The iOS/macOS implementation of [PlatformPathManager] using Apple Foundation APIs via FFI.
///
/// This class handles directory path resolutions by communicating with the
/// macOS/iOS platform APIs using Objective-C FFI bindings.
class FoundationPathManager extends PlatformPathManager {
  /// Creates a new [FoundationPathManager].
  ///
  /// [bundleIdentifier] overrides the main bundle identifier used to scope
  /// macOS application support and cache directories. It is intended for
  /// testing and defaults to the running bundle's identifier.
  FoundationPathManager({String? bundleIdentifier})
    : _bundleIdentifierOverride = bundleIdentifier;

  /// Registers the iOS/macOS implementation of [PlatformPathManager].
  static void registerWith() {
    PlatformPathManager.instance = FoundationPathManager();
  }

  final String? _bundleIdentifierOverride;

  String? get _bundleIdentifier =>
      _bundleIdentifierOverride ??
      objc.NSBundle.getMainBundle().bundleIdentifier?.toDartString();

  @override
  String? getTemporaryPathSync() {
    final manager = NSFileManager.getDefaultManager();
    final url = manager.temporaryDirectory;
    return url.path?.toDartString();
  }

  @override
  String? getApplicationSupportPathSync() => _getPathForDirectorySync(
    NSSearchPathDirectory.NSApplicationSupportDirectory,
  );

  @override
  String? getDocumentsPathSync() => _getPathForDirectorySync(
    NSSearchPathDirectory.NSDocumentDirectory,
  );

  @override
  String? getApplicationCachePathSync() => _getPathForDirectorySync(
    NSSearchPathDirectory.NSCachesDirectory,
  );

  @override
  String? getDownloadsPathSync() {
    if (Platform.isIOS) {
      throw UnsupportedError(
        'Downloads directory is not supported on iOS due to platform sandboxing. '
        'Use getApplicationDocumentsDirectory() instead.',
      );
    }
    return _getPathForDirectorySync(NSSearchPathDirectory.NSDownloadsDirectory);
  }

  @override
  String? getDesktopPathSync() =>
      _getUserMediaPathSync(NSSearchPathDirectory.NSDesktopDirectory);

  @override
  String? getPicturesPathSync() =>
      _getUserMediaPathSync(NSSearchPathDirectory.NSPicturesDirectory);

  @override
  String? getMusicPathSync() =>
      _getUserMediaPathSync(NSSearchPathDirectory.NSMusicDirectory);

  @override
  String? getVideosPathSync() =>
      _getUserMediaPathSync(NSSearchPathDirectory.NSMoviesDirectory);

  @override
  Future<String?> getTemporaryPath() async => getTemporaryPathSync();

  @override
  Future<String?> getApplicationSupportPath() async =>
      getApplicationSupportPathSync();

  @override
  Future<String?> getDocumentsPath() async => getDocumentsPathSync();

  @override
  Future<String?> getApplicationCachePath() async =>
      getApplicationCachePathSync();

  @override
  Future<String?> getDownloadsPath() async => getDownloadsPathSync();

  @override
  DiskSpace? getDiskSpaceSync({String? path}) {
    final target =
        path ??
        getApplicationSupportPathSync() ??
        getApplicationCachePathSync();
    if (target == null) return null;

    try {
      final attributes = NSFileManager.getDefaultManager()
          .attributesOfFileSystemForPath(objc.NSString(target));
      if (attributes == null) return null;

      final free = attributes.objectForKey(
        objc.NSString('NSFileSystemFreeSize'),
      );
      final total = attributes.objectForKey(objc.NSString('NSFileSystemSize'));
      if (free == null || total == null) return null;

      return DiskSpace(
        freeBytes: objc.NSNumber.as(free).unsignedLongLongValue,
        totalBytes: objc.NSNumber.as(total).unsignedLongLongValue,
      );
    } catch (_) {
      return null;
    }
  }

  /// Resolves a user media directory, rejecting platforms without global
  /// user directories.
  String? _getUserMediaPathSync(NSSearchPathDirectory directory) {
    if (Platform.isIOS) {
      throw UnsupportedError(
        'Global user media directories are not supported on iOS due to '
        'platform sandboxing. Use getApplicationDocumentsDirectory() instead.',
      );
    }
    return _getPathForDirectorySync(directory);
  }

  String? _getPathForDirectorySync(NSSearchPathDirectory directory) {
    final manager = NSFileManager.getDefaultManager();

    // objc.NSSearchPathDomainMask.NSUserDomainMask = 1
    final url = manager.URLForDirectory(
      directory,
      inDomain: 1,
      appropriateForURL: null,
      create: true,
    );
    var path = url?.path?.toDartString();
    if (path == null) return null;

    // On macOS these directories are shared by all applications when the app
    // is not sandboxed. Scope them to the bundle identifier, matching the
    // convention used by other application-scoped platforms. In a sandboxed
    // app the base path is already inside the app container, so the extra
    // component is harmless.
    if (Platform.isMacOS &&
        (directory == NSSearchPathDirectory.NSApplicationSupportDirectory ||
            directory == NSSearchPathDirectory.NSCachesDirectory)) {
      final bundleIdentifier = _bundleIdentifier;
      if (bundleIdentifier != null && bundleIdentifier.isNotEmpty) {
        path = '$path/$bundleIdentifier';
      }
    }

    try {
      Directory(path).createSync(recursive: true);
    } on FileSystemException {
      // Return the path even when the directory cannot be created; callers
      // can decide whether to retry or surface the filesystem error.
    }
    return path;
  }

  @override
  Future<String?> getApplicationNoBackupDirectory() async {
    final supportPath = getApplicationSupportPathSync();
    if (supportPath == null) return null;

    final noBackupPath = '$supportPath/__no_backup__';
    final dir = Directory(noBackupPath);
    final bool alreadyExists = await dir.exists();
    if (!alreadyExists) {
      await dir.create(recursive: true);
    }

    // Check if the directory is already excluded from backup
    final nsPath = objc.NSString(noBackupPath);
    final url = objc.NSURL.fileURLWithPath(nsPath);
    final key = objc.NSString('NSURLIsExcludedFromBackupKey');
    final valPtrPtr = pkg_ffi.calloc<ffi.Pointer<objc.ObjCObjectImpl>>();
    bool isExcluded = false;
    try {
      final success = url.getResourceValue(valPtrPtr, forKey: key);
      if (success && valPtrPtr.value != ffi.nullptr) {
        final getVal = objc.NSNumber.fromPointer(
          valPtrPtr.value,
          retain: true,
          release: true,
        );
        isExcluded = getVal.boolValue;
      }
    } catch (_) {
      // If querying fails, we treat it as not excluded
    } finally {
      pkg_ffi.calloc.free(valPtrPtr);
    }

    if (!isExcluded) {
      if (alreadyExists) {
        throw BackupExclusionConflictException(
          noBackupPath,
          'The __no_backup__ directory already exists but is not marked as excluded from backup. '
          'Since it exists without the exclusion flag, it is assumed to have been created manually. '
          'Please delete the directory or mark it as excluded.',
        );
      }
      await setApplicationPathIsExcludedFromBackup(noBackupPath, true);
    }

    return noBackupPath;
  }

  @override
  Future<void> setApplicationPathIsExcludedFromBackup(
    String path,
    bool exclude,
  ) async {
    try {
      final nsPath = objc.NSString(path);
      final url = objc.NSURL.fileURLWithPath(nsPath);
      final key = objc.NSString('NSURLIsExcludedFromBackupKey');
      final value = objc.NSNumberCreation.numberWithBool(exclude);
      final success = url.setResourceValue(value, forKey: key);
      if (!success) {
        throw FileSystemException(
          'Failed to set backup exclusion status (returned false)',
          path,
        );
      }
    } on Exception catch (e) {
      throw FileSystemException(
        'Failed to set backup exclusion status: $e',
        path,
      );
    }
  }

  @override
  Future<String?> getExternalStoragePath(StorageDirectory dir) async {
    throw UnsupportedError(
      'External storage directories are not supported on iOS/macOS as Apple sandboxing '
      'does not provide an external storage concept. Use getApplicationDocumentsDirectory() '
      'or getApplicationSupportDirectory() instead.',
    );
  }

  @override
  Future<List<String>?> getExternalStoragePaths([
    List<StorageDirectory> dirs = StorageDirectory.values,
  ]) async {
    throw UnsupportedError(
      'External storage directories are not supported on iOS/macOS as Apple sandboxing '
      'does not provide an external storage concept. Use getApplicationDocumentsDirectory() '
      'or getApplicationSupportDirectory() instead.',
    );
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    throw UnsupportedError(
      'External cache directories are not supported on iOS/macOS as Apple sandboxing '
      'does not provide an external cache concept. Use getApplicationCacheDirectory() instead.',
    );
  }
}
