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

/// The Linux implementation of [PlatformPathManager] adhering to the XDG Base Directory specification.
class LinuxPathManager extends PlatformPathManager {
  /// Creates a new [LinuxPathManager] with optional environment and directory overrides for testing.
  LinuxPathManager({
    this.environment,
    Directory? Function(String name)? getUserDirectory,
    this.dataHome,
    this.cacheHome,
    DiskSpaceResolver? diskSpaceResolver,
  }) : _getUserDir = getUserDirectory ?? xdg.getUserDirectory,
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

  Map<String, String> get _env => environment ?? Platform.environment;

  static final _StatvfsFn? _statvfs = _lookupStatvfs();

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
  String? getApplicationSupportPathSync() {
    return dataHome?.path ?? xdg.dataHome.path;
  }

  @override
  String? getApplicationCachePathSync() {
    return cacheHome?.path ?? xdg.cacheHome.path;
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
      getApplicationSupportPathSync();

  @override
  Future<String?> getApplicationCachePath() async =>
      getApplicationCachePathSync();

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
