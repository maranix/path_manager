import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_manager_platform_interface/path_manager_platform_interface.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;

/// The Linux implementation of [PlatformPathManager] adhering to the XDG Base Directory specification.
class LinuxPathManager extends PlatformPathManager {
  /// Creates a new [LinuxPathManager] with optional environment and directory overrides for testing.
  LinuxPathManager({
    this.environment,
    Directory? Function(String name)? getUserDirectory,
    this.dataHome,
    this.cacheHome,
  }) : _getUserDir = getUserDirectory ?? xdg.getUserDirectory;

  /// Registers the Linux implementation of [PlatformPathManager].
  static void registerWith() {
    PlatformPathManager.instance = LinuxPathManager();
  }

  /// Optional environment variables override for testing.
  final Map<String, String>? environment;

  final Directory? Function(String name) _getUserDir;

  /// Optional data home directory override for testing.
  final Directory? dataHome;

  /// Optional cache home directory override for testing.
  final Directory? cacheHome;

  Map<String, String> get _env => environment ?? Platform.environment;

  @override
  Future<String?> getTemporaryPath() async {
    final tmp = _env['TMPDIR'];
    if (tmp != null && tmp.isNotEmpty) {
      return tmp;
    }
    return '/tmp';
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return dataHome?.path ?? xdg.dataHome.path;
  }

  @override
  Future<String?> getApplicationCachePath() async {
    return cacheHome?.path ?? xdg.cacheHome.path;
  }

  @override
  Future<String?> getDocumentsPath() async {
    final xdgDoc = _getUserDir('DOCUMENTS');
    if (xdgDoc != null) {
      return xdgDoc.path;
    }
    final home = _env['HOME'];
    if (home != null && home.isNotEmpty) {
      return p.join(home, 'Documents');
    }
    return null;
  }

  @override
  Future<String?> getDownloadsPath() async {
    final xdgDownload = _getUserDir('DOWNLOAD');
    if (xdgDownload != null) {
      return xdgDownload.path;
    }
    final home = _env['HOME'];
    if (home != null && home.isNotEmpty) {
      return p.join(home, 'Downloads');
    }
    return null;
  }

  @override
  Future<String?> getApplicationNoBackupDirectory() async {
    final supportPath = await getApplicationSupportPath();
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
