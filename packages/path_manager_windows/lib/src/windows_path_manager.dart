import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart' as pkg_ffi;
import 'package:path/path.dart' as p;
import 'package:path_manager_platform_interface/path_manager_platform_interface.dart';
import 'package:win32/win32.dart';

/// Signature for resolving a Win32 Known Folder GUID to an absolute path string.
typedef KnownFolderPathResolver = String? Function(GUID folderId);

/// Signature for resolving the Windows temporary directory path string.
typedef TempPathResolver = String? Function();

/// Signature for resolving the capacity of the volume containing a path.
typedef DiskSpaceResolver = DiskSpace? Function(String path);

/// The Windows implementation of [PlatformPathManager] using Win32 Shell Known Folders via FFI.
class WindowsPathManager extends PlatformPathManager {
  /// Creates a new [WindowsPathManager] with optional resolvers for unit testing.
  WindowsPathManager({
    KnownFolderPathResolver? knownFolderPathResolver,
    TempPathResolver? tempPathResolver,
    DiskSpaceResolver? diskSpaceResolver,
  }) : _knownFolderPathResolver =
           knownFolderPathResolver ?? _defaultGetKnownFolderPath,
       _tempPathResolver = tempPathResolver ?? _defaultGetTempPath,
       _diskSpaceResolver = diskSpaceResolver ?? _defaultGetDiskSpace;

  /// Registers the Windows implementation of [PlatformPathManager].
  static void registerWith() {
    PlatformPathManager.instance = WindowsPathManager();
  }

  final KnownFolderPathResolver _knownFolderPathResolver;
  final TempPathResolver _tempPathResolver;
  final DiskSpaceResolver _diskSpaceResolver;

  static String? _defaultGetKnownFolderPath(GUID folderId) {
    if (!Platform.isWindows) return null;
    final pGuid = folderId.toNative();
    try {
      final pwstr = SHGetKnownFolderPath(
        pGuid,
        KF_FLAG_DEFAULT,
        null,
      );
      try {
        return pwstr.toDartString();
      } finally {
        CoTaskMemFree(pwstr);
      }
    } catch (_) {
      return null;
    } finally {
      free(pGuid);
    }
  }

  static String? _defaultGetTempPath() {
    if (!Platform.isWindows) return null;
    final buffer = wsalloc(MAX_PATH + 1);
    try {
      var length = GetTempPath2(MAX_PATH + 1, buffer);
      if (length == 0) {
        length = GetTempPath(MAX_PATH + 1, buffer).value;
      }
      if (length > 0) {
        var path = buffer.toDartString();
        if (path.endsWith(r'\')) {
          path = path.substring(0, path.length - 1);
        }
        return path;
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      free(buffer);
    }
  }

  static DiskSpace? _defaultGetDiskSpace(String path) {
    if (!Platform.isWindows) return null;

    // GetDiskFreeSpaceExW expects a directory on the target volume.
    final target = FileSystemEntity.isFileSync(path) ? p.dirname(path) : path;
    final targetPtr = target.toNativeUtf16();
    final freePtr = pkg_ffi.calloc<Uint64>();
    final totalPtr = pkg_ffi.calloc<Uint64>();
    try {
      final result = GetDiskFreeSpaceEx(
        PCWSTR(targetPtr),
        freePtr,
        totalPtr,
        null,
      );
      if (!result.value) return null;
      return DiskSpace(
        freeBytes: freePtr.value,
        totalBytes: totalPtr.value,
      );
    } catch (_) {
      return null;
    } finally {
      free(targetPtr);
      free(freePtr);
      free(totalPtr);
    }
  }

  @override
  String? getTemporaryPathSync() => _tempPathResolver();

  @override
  String? getApplicationSupportPathSync() =>
      _knownFolderPathResolver(FOLDERID_RoamingAppData);

  @override
  String? getDocumentsPathSync() =>
      _knownFolderPathResolver(FOLDERID_Documents);

  @override
  String? getApplicationCachePathSync() =>
      _knownFolderPathResolver(FOLDERID_LocalAppData);

  @override
  String? getDownloadsPathSync() =>
      _knownFolderPathResolver(FOLDERID_Downloads);

  @override
  String? getDesktopPathSync() => _knownFolderPathResolver(FOLDERID_Desktop);

  @override
  String? getPicturesPathSync() => _knownFolderPathResolver(FOLDERID_Pictures);

  @override
  String? getMusicPathSync() => _knownFolderPathResolver(FOLDERID_Music);

  @override
  String? getVideosPathSync() => _knownFolderPathResolver(FOLDERID_Videos);

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
    return _diskSpaceResolver(target);
  }

  @override
  Future<String?> getApplicationNoBackupDirectory() async {
    final supportPath = getApplicationSupportPathSync();
    if (supportPath == null) return null;

    final noBackupPath = p.join(supportPath, '__no_backup__');
    final dir = Directory(noBackupPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return noBackupPath;
  }

  @override
  Future<String?> getExternalStoragePath(StorageDirectory dir) async {
    throw UnsupportedError(
      'External storage directories are not supported on Windows as Windows does not '
      'provide an external storage concept. Use getApplicationDocumentsDirectory() '
      'or getApplicationSupportDirectory() instead.',
    );
  }

  @override
  Future<List<String>?> getExternalStoragePaths([
    List<StorageDirectory> dirs = StorageDirectory.values,
  ]) async {
    throw UnsupportedError(
      'External storage directories are not supported on Windows as Windows does not '
      'provide an external storage concept. Use getApplicationDocumentsDirectory() '
      'or getApplicationSupportDirectory() instead.',
    );
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    throw UnsupportedError(
      'External cache directories are not supported on Windows as Windows does not '
      'provide an external cache concept. Use getApplicationCacheDirectory() instead.',
    );
  }

  @override
  Future<void> setApplicationPathIsExcludedFromBackup(
    String path,
    bool exclude,
  ) async {
    throw UnsupportedError(
      'Backup exclusion cannot be set programmatically on Windows as Windows filesystems '
      'do not provide an OS-level backup exclusion attribute.',
    );
  }
}
