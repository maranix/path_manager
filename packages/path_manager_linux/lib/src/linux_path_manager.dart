import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart' as pkg_ffi;
import 'package:path/path.dart' as p;
import 'package:path_manager_platform_interface/path_manager_platform_interface.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;

/// Signature for resolving the capacity of the volume containing a path.
typedef DiskSpaceResolver = DiskSpace? Function(String path);

/// Signature for the POSIX `statvfs` function.
typedef _StatvfsFn = int Function(
  ffi.Pointer<ffi.Uint8> path,
  ffi.Pointer<ffi.Uint8> buffer,
);

typedef _GApplicationGetDefaultC = ffi.IntPtr Function();
typedef _GApplicationGetDefaultDart = int Function();
typedef _GApplicationGetApplicationIdC = ffi.Pointer<pkg_ffi.Utf8> Function(
  ffi.IntPtr,
);
typedef _GApplicationGetApplicationIdDart = ffi.Pointer<pkg_ffi.Utf8> Function(
  int,
);

/// The Linux implementation of [PlatformPathManager] adhering to the XDG Base Directory specification.
class LinuxPathManager extends PlatformPathManager {
  /// Creates a new [LinuxPathManager] with optional environment, directory,
  /// and application ID overrides for testing.
  LinuxPathManager({
    this.environment,
    Directory? Function(String name)? getUserDirectory,
    this.dataHome,
    this.cacheHome,
    String? applicationId,
    DiskSpaceResolver? diskSpaceResolver,
  }) : _getUserDir = getUserDirectory ?? xdg.getUserDirectory,
       _applicationIdOverride = applicationId,
       _diskSpaceResolver = diskSpaceResolver ?? _defaultGetDiskSpace;

  /// Registers the Linux implementation of [PlatformPathManager].
  static void registerWith() {
    PlatformPathManager.instance = LinuxPathManager();
  }

  /// Optional environment variables override for testing.
  final Map<String, String>? environment;

  final Directory? Function(String name) _getUserDir;
  final DiskSpaceResolver _diskSpaceResolver;

  /// Optional data home directory override for testing.
  final Directory? dataHome;

  /// Optional cache home directory override for testing.
  final Directory? cacheHome;

  final String? _applicationIdOverride;

  /// The XDG application identifier, falling back to the executable name.
  late final String? _applicationId =
      _normalizeApplicationId(_applicationIdOverride) ??
      _defaultApplicationId();

  Map<String, String> get _env => environment ?? Platform.environment;

  static final _StatvfsFn? _statvfs = _lookupStatvfs();

  static final ffi.DynamicLibrary? _gio = _lookupGio();

  static ffi.DynamicLibrary? _lookupGio() {
    if (!Platform.isLinux) return null;
    try {
      return ffi.DynamicLibrary.open('libgio-2.0.so.0');
    } catch (_) {
      return null;
    }
  }

  static String? _defaultApplicationId() {
    if (Platform.isLinux) {
      final gioId = _gioApplicationId();
      if (gioId != null) return gioId;
    }

    return _normalizeApplicationId(
      p.basenameWithoutExtension(Platform.resolvedExecutable),
    );
  }

  static String? _gioApplicationId() {
    final gio = _gio;
    if (gio == null) return null;
    try {
      final getDefault = gio
          .lookupFunction<
            _GApplicationGetDefaultC,
            _GApplicationGetDefaultDart
          >('g_application_get_default');
      final getApplicationId = gio
          .lookupFunction<
            _GApplicationGetApplicationIdC,
            _GApplicationGetApplicationIdDart
          >('g_application_get_application_id');

      final application = getDefault();
      if (application == 0) return null;

      final idPointer = getApplicationId(application);
      if (idPointer == ffi.nullptr) return null;

      return _normalizeApplicationId(idPointer.toDartString());
    } catch (_) {
      return null;
    }
  }

  static String? _normalizeApplicationId(String? value) {
    if (value == null) return null;
    final normalized = value.replaceAll(RegExp(r'[/\\\x00]'), '_').trim();
    return normalized.isEmpty ? null : normalized;
  }

  static _StatvfsFn? _lookupStatvfs() {
    if (!Platform.isLinux) return null;
    try {
      return ffi.DynamicLibrary.open('libc.so.6').lookupFunction<
        ffi.Int32 Function(
          ffi.Pointer<ffi.Uint8>,
          ffi.Pointer<ffi.Uint8>,
        ),
        _StatvfsFn
      >('statvfs');
    } catch (_) {
      try {
        return ffi.DynamicLibrary.process().lookupFunction<
          ffi.Int32 Function(
            ffi.Pointer<ffi.Uint8>,
            ffi.Pointer<ffi.Uint8>,
          ),
          _StatvfsFn
        >('statvfs');
      } catch (_) {
        return null;
      }
    }
  }

  static DiskSpace? _defaultGetDiskSpace(String path) {
    final statvfs = _statvfs;
    if (statvfs == null) return null;

    final pathPtr = path.toNativeUtf8();
    // `struct statvfs` is 112 bytes on 64-bit Linux (11 unsigned long fields
    // plus trailing type/spare fields). Allocate extra headroom so newer libc
    // versions that append fields cannot overflow the buffer.
    final buffer = pkg_ffi.calloc<ffi.Uint8>(256);
    try {
      if (statvfs(pathPtr.cast(), buffer) != 0) return null;

      // The leading fields are stable 64-bit `unsigned long` values:
      // [0] f_bsize, [1] f_frsize, [2] f_blocks, [3] f_bfree, [4] f_bavail.
      final words = buffer.cast<ffi.Uint64>();
      final blockSize = words[1] != 0 ? words[1] : words[0];
      return DiskSpace(
        freeBytes: words[4] * blockSize,
        totalBytes: words[2] * blockSize,
      );
    } catch (_) {
      return null;
    } finally {
      pkg_ffi.calloc.free(buffer);
      pkg_ffi.malloc.free(pathPtr);
    }
  }

  @override
  String? getTemporaryPathSync() {
    final tmp = _env['TMPDIR'];
    if (tmp != null && tmp.isNotEmpty) {
      return tmp;
    }
    return '/tmp';
  }

  @override
  String? getApplicationSupportPathSync() =>
      _scopedPath(dataHome?.path ?? xdg.dataHome.path);

  @override
  String? getApplicationCachePathSync() =>
      _scopedPath(cacheHome?.path ?? xdg.cacheHome.path);

  String _scopedPath(String basePath) {
    final applicationId = _applicationId;
    return applicationId == null ? basePath : p.join(basePath, applicationId);
  }

  @override
  String? getDocumentsPathSync() => _getUserDirPath('DOCUMENTS', 'Documents');

  @override
  String? getDownloadsPathSync() => _getUserDirPath('DOWNLOAD', 'Downloads');

  @override
  String? getDesktopPathSync() => _getUserDirPath('DESKTOP', 'Desktop');

  @override
  String? getPicturesPathSync() => _getUserDirPath('PICTURES', 'Pictures');

  @override
  String? getMusicPathSync() => _getUserDirPath('MUSIC', 'Music');

  @override
  String? getVideosPathSync() => _getUserDirPath('VIDEOS', 'Videos');

  @override
  Future<String?> getTemporaryPath() async => getTemporaryPathSync();

  @override
  Future<String?> getApplicationSupportPath() async =>
      _ensureDirectory(getApplicationSupportPathSync());

  @override
  Future<String?> getApplicationCachePath() async =>
      _ensureDirectory(getApplicationCachePathSync());

  static String? _ensureDirectory(String? path) {
    if (path == null) return null;
    try {
      Directory(path).createSync(recursive: true);
    } on FileSystemException {
      // Return the path even when the directory cannot be created; callers
      // can decide whether to retry or surface the filesystem error.
    }
    return path;
  }

  @override
  Future<String?> getDocumentsPath() async => getDocumentsPathSync();

  @override
  Future<String?> getDownloadsPath() async => getDownloadsPathSync();

  @override
  DiskSpace? getDiskSpaceSync({String? path}) {
    final requested =
        path ??
        getApplicationSupportPathSync() ??
        getApplicationCachePathSync();
    if (requested == null) return null;

    // `statvfs` requires an existing path. Walk up to the nearest existing
    // ancestor so default directories that have not been created yet still
    // report their containing volume.
    var target = requested;
    while (FileSystemEntity.typeSync(target) == FileSystemEntityType.notFound) {
      final parent = p.dirname(target);
      if (parent == target) return null;
      target = parent;
    }
    return _diskSpaceResolver(target);
  }

  String? _getUserDirPath(String xdgName, String fallbackName) {
    final xdgDir = _getUserDir(xdgName);
    if (xdgDir != null) return xdgDir.path;

    final home = _env['HOME'];
    if (home != null && home.isNotEmpty) {
      return p.join(home, fallbackName);
    }
    return null;
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
      'External storage directories are not supported on Linux as Linux does not '
      'provide an external storage concept. Use getApplicationDocumentsDirectory() '
      'or getApplicationSupportDirectory() instead.',
    );
  }

  @override
  Future<List<String>?> getExternalStoragePaths([
    List<StorageDirectory> dirs = StorageDirectory.values,
  ]) async {
    throw UnsupportedError(
      'External storage directories are not supported on Linux as Linux does not '
      'provide an external storage concept. Use getApplicationDocumentsDirectory() '
      'or getApplicationSupportDirectory() instead.',
    );
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    throw UnsupportedError(
      'External cache directories are not supported on Linux as Linux does not '
      'provide an external cache concept. Use getApplicationCacheDirectory() instead.',
    );
  }

  @override
  Future<void> setApplicationPathIsExcludedFromBackup(
    String path,
    bool exclude,
  ) async {
    throw UnsupportedError(
      'Backup exclusion cannot be set programmatically on Linux as Linux filesystems '
      'do not provide an OS-level backup exclusion attribute.',
    );
  }
}
