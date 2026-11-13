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
  /// Creates a new [WindowsPathManager] with optional resolvers and an
  /// application ID override for unit testing.
  WindowsPathManager({
    KnownFolderPathResolver? knownFolderPathResolver,
    TempPathResolver? tempPathResolver,
    DiskSpaceResolver? diskSpaceResolver,
    String? applicationId,
  }) : _knownFolderPathResolver =
           knownFolderPathResolver ?? _defaultGetKnownFolderPath,
       _tempPathResolver = tempPathResolver ?? _defaultGetTempPath,
       _diskSpaceResolver = diskSpaceResolver ?? _defaultGetDiskSpace,
       _applicationIdOverride = applicationId;

  /// Registers the Windows implementation of [PlatformPathManager].
  static void registerWith() {
    PlatformPathManager.instance = WindowsPathManager();
  }

  final KnownFolderPathResolver _knownFolderPathResolver;
  final TempPathResolver _tempPathResolver;
  final DiskSpaceResolver _diskSpaceResolver;
  final String? _applicationIdOverride;

  /// The application-specific subdirectory under the known folders.
  ///
  /// Uses the executable's `CompanyName\ProductName` version metadata when
  /// available, falling back to the executable filename.
  late final String _applicationId =
      _normalizeApplicationId(_applicationIdOverride) ??
      _defaultApplicationId();

  static String _defaultApplicationId() {
    if (!Platform.isWindows) {
      return _normalizeApplicationId(
            p.windows.basenameWithoutExtension(Platform.resolvedExecutable),
          ) ??
          'path_manager_app';
    }

    PWSTR? moduleNameBuffer;
    Pointer<Uint8>? versionInfo;
    try {
      moduleNameBuffer = wsalloc(MAX_PATH + 1);
      final moduleNameLength = GetModuleFileName(
        null,
        moduleNameBuffer,
        MAX_PATH + 1,
      ).value;
      if (moduleNameLength == 0) {
        return _normalizeApplicationId(
              p.windows.basenameWithoutExtension(Platform.resolvedExecutable),
            ) ??
            'path_manager_app';
      }

      final moduleName = moduleNameBuffer.toDartString();
      String? companyName;
      String? productName;

      final infoSize = GetFileVersionInfoSize(
        PCWSTR(moduleNameBuffer),
        null,
      ).value;
      if (infoSize > 0) {
        versionInfo = pkg_ffi.calloc<Uint8>(infoSize);
        final loaded = GetFileVersionInfo(
          PCWSTR(moduleNameBuffer),
          infoSize,
          versionInfo,
        ).value;
        if (loaded) {
          companyName = _queryVersionString(versionInfo, 'CompanyName');
          productName = _queryVersionString(versionInfo, 'ProductName');
        }
      }

      final company = _sanitizeComponent(companyName);
      final product =
          _sanitizeComponent(productName) ??
          _sanitizeComponent(p.windows.basenameWithoutExtension(moduleName));

      if (product == null) return 'path_manager_app';
      return company == null ? product : p.windows.join(company, product);
    } catch (_) {
      return _normalizeApplicationId(
            p.windows.basenameWithoutExtension(Platform.resolvedExecutable),
          ) ??
          'path_manager_app';
    } finally {
      if (moduleNameBuffer != null) free(moduleNameBuffer);
      if (versionInfo != null) pkg_ffi.calloc.free(versionInfo);
    }
  }

  static String? _queryVersionString(
    Pointer<Uint8> versionInfo,
    String key,
  ) {
    // Try the common CP1252 and Unicode English translation tables first.
    for (final language in const ['040904e4', '040904b0']) {
      final subBlock = '\\StringFileInfo\\$language\\$key'.toPcwstr();
      final value = pkg_ffi.calloc<Pointer<pkg_ffi.Utf16>>();
      final length = pkg_ffi.calloc<Uint32>();
      try {
        if (VerQueryValue(
          versionInfo,
          subBlock,
          value.cast(),
          length,
        )) {
          final stringPointer = value.value;
          if (stringPointer != nullptr && length.value > 0) {
            return stringPointer.toDartString();
          }
        }
      } finally {
        free(subBlock);
        pkg_ffi.calloc.free(value);
        pkg_ffi.calloc.free(length);
      }
    }
    return null;
  }

  static String? _normalizeApplicationId(String? value) {
    if (value == null) return null;
    final components = value
        .replaceAll('\\', '/')
        .split('/')
        .map(_sanitizeComponent)
        .whereType<String>()
        .toList();
    return components.isEmpty ? null : p.windows.joinAll(components);
  }

  static String? _sanitizeComponent(String? value) {
    if (value == null) return null;
    var sanitized = value
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
        .trim()
        .replaceAll(RegExp(r'[. ]+$'), '');
    if (sanitized.isEmpty || sanitized == '.' || sanitized == '..') {
      return null;
    }
    if (sanitized.length > 255) {
      sanitized = sanitized.substring(0, 255);
    }
    return sanitized;
  }

  static String? _ensureDirectory(String? path) {
    if (path == null) return null;
    if (Platform.isWindows) {
      try {
        Directory(path).createSync(recursive: true);
      } on FileSystemException {
        // Return the path even when the directory cannot be created; callers
        // can decide whether to retry or surface the filesystem error.
      }
    }
    return path;
  }

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
  String? getApplicationSupportPathSync() => _scopedPath(
    _knownFolderPathResolver(FOLDERID_RoamingAppData),
  );

  @override
  String? getDocumentsPathSync() =>
      _knownFolderPathResolver(FOLDERID_Documents);

  @override
  String? getApplicationCachePathSync() => _scopedPath(
    _knownFolderPathResolver(FOLDERID_LocalAppData),
  );

  String? _scopedPath(String? basePath) {
    if (basePath == null) return null;
    return p.windows.join(basePath, _applicationId);
  }

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
      _ensureDirectory(getApplicationSupportPathSync());

  @override
  Future<String?> getDocumentsPath() async => getDocumentsPathSync();

  @override
  Future<String?> getApplicationCachePath() async =>
      _ensureDirectory(getApplicationCachePathSync());

  @override
  Future<String?> getDownloadsPath() async => getDownloadsPathSync();

  @override
  DiskSpace? getDiskSpaceSync({String? path}) {
    final requested =
        path ??
        getApplicationSupportPathSync() ??
        getApplicationCachePathSync();
    if (requested == null) return null;

    // Application-scoped directories may not have been created yet. Walk up to
    // the nearest existing ancestor so the containing volume can still be
    // queried.
    var target = requested;
    if (Platform.isWindows) {
      while (FileSystemEntity.typeSync(target) ==
          FileSystemEntityType.notFound) {
        final parent = p.windows.dirname(target);
        if (parent == target) return null;
        target = parent;
      }
    }
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
