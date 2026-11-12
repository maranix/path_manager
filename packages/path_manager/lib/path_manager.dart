import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_manager_platform_interface/path_manager_platform_interface.dart';

export 'package:path_manager_platform_interface/path_manager_platform_interface.dart'
    show
        BackupExclusionConflictException,
        DiskSpace,
        MissingPlatformDirectoryException,
        PlatformPathManager,
        StorageDirectory;

/// A class providing unified access to commonly used directories on the host file system.
///
/// This library provides a clean API for resolving platform directories across Android,
/// iOS, macOS, Linux, and Windows.
///
/// ### Examples
///
/// ```dart
/// // Retrieve the temporary directory
/// final tempDir = await PathManager.getTemporaryDirectory();
/// print('Temporary directory path: ${tempDir.path}');
///
/// // Retrieve the documents directory
/// final docsDir = await PathManager.getApplicationDocumentsDirectory();
/// print('Documents directory path: ${docsDir.path}');
///
/// // Retrieve the directory excluded from backups
/// final noBackupDir = await PathManager.getApplicationNoBackupDirectory();
/// print('No-backup directory: ${noBackupDir.path}');
/// ```
abstract final class PathManager {
  /// Gets the path to the temporary directory on the host device.
  ///
  /// This directory is suitable for storing temporary cache files that can be
  /// deleted by the system or application at any time. It is not backed up.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final tempDir = await PathManager.getTemporaryDirectory();
  /// final cacheFile = File('${tempDir.path}/temp_cache.txt');
  /// await cacheFile.writeAsString('Temporary data');
  /// ```
  static Future<Directory> getTemporaryDirectory() async {
    final String? path = await PlatformPathManager.instance.getTemporaryPath();
    if (path == null) {
      throw const MissingPlatformDirectoryException(
        'Unable to get temporary directory',
      );
    }
    return Directory(path);
  }

  /// Gets the path to the application support directory on the host device.
  ///
  /// Use this directory to place files that are application-created, but not
  /// user-created, such as databases, application state, and other internal files.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final supportDir = await PathManager.getApplicationSupportDirectory();
  /// final dbFile = File('${supportDir.path}/app_database.db');
  /// ```
  static Future<Directory> getApplicationSupportDirectory() async {
    final String? path = await PlatformPathManager.instance
        .getApplicationSupportPath();
    if (path == null) {
      throw const MissingPlatformDirectoryException(
        'Unable to get application support directory',
      );
    }
    return Directory(path);
  }

  /// Gets the path to the application documents directory on the host device.
  ///
  /// Use this directory to store user-generated content and files that cannot be
  /// recreated by the application, such as user profiles, settings, or user documents.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final docsDir = await PathManager.getApplicationDocumentsDirectory();
  /// final userProfile = File('${docsDir.path}/profile.json');
  /// await userProfile.writeAsString('{"username": "JohnDoe"}');
  /// ```
  static Future<Directory> getApplicationDocumentsDirectory() async {
    final String? path = await PlatformPathManager.instance.getDocumentsPath();
    if (path == null) {
      throw const MissingPlatformDirectoryException(
        'Unable to get application documents directory',
      );
    }
    return Directory(path);
  }

  /// Gets the path to the application cache directory on the host device.
  ///
  /// Use this directory for data that can be recreated by the application but should
  /// persist longer than temporary files, such as downloaded image caches.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final cacheDir = await PathManager.getApplicationCacheDirectory();
  /// final cachedImage = File('${cacheDir.path}/avatar_cache.png');
  /// ```
  static Future<Directory> getApplicationCacheDirectory() async {
    final String? path = await PlatformPathManager.instance
        .getApplicationCachePath();
    if (path == null) {
      throw const MissingPlatformDirectoryException(
        'Unable to get application cache directory',
      );
    }
    return Directory(path);
  }

  /// Gets the path to a designated application directory that is excluded from backups.
  ///
  /// - **iOS & macOS**: Resolves a directory named `__no_backup__` under the application
  ///   support directory. If it does not exist, it is created and programmatically
  ///   marked with the backup exclusion flag (`NSURLIsExcludedFromBackupKey`). If it
  ///   already exists but is not marked as excluded, throws a
  ///   [BackupExclusionConflictException].
  /// - **Android**: Resolves a directory named `__no_backup__` under the application's
  ///   internal files directory. Note that because Android does not support dynamic
  ///   programmatic backup exclusions of specific paths, developers must manually
  ///   configure exclusion rules in their XML configuration files (e.g., `backup_rules.xml`).
  /// - **Linux**: Resolves a directory named `__no_backup__` under the application's
  ///   support directory.
  /// - **Windows**: Resolves a directory named `__no_backup__` under the application's
  ///   roaming app data directory.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// try {
  ///   final directory = await PathManager.getApplicationNoBackupDirectory();
  ///   final localLog = File('${directory.path}/diagnostics.log');
  ///   await localLog.writeAsString('Sensitive local telemetry...');
  /// } on BackupExclusionConflictException catch (e) {
  ///   print('Backup exclusion error: ${e.message}');
  /// }
  /// ```
  static Future<Directory> getApplicationNoBackupDirectory() async {
    final String? path = await PlatformPathManager.instance
        .getApplicationNoBackupDirectory();
    if (path == null) {
      throw const MissingPlatformDirectoryException(
        'Unable to get application no backup directory',
      );
    }
    return Directory(path);
  }

  /// Gets the external storage directory on the host device for [dir].
  ///
  /// - **Android**: Resolves the external files directory for [dir].
  /// - **iOS, macOS, Linux, Windows**: Unsupported. Throws an [UnsupportedError].
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final musicDir = await PathManager.getExternalStorageDirectory(StorageDirectory.music);
  /// print('Music dir: ${musicDir.path}');
  /// ```
  static Future<Directory> getExternalStorageDirectory(
    StorageDirectory dir,
  ) async {
    final String? path = await PlatformPathManager.instance
        .getExternalStoragePath(dir);
    if (path == null) {
      throw MissingPlatformDirectoryException(
        'Unable to get external storage directory for ${dir.name}',
      );
    }
    return Directory(path);
  }

  /// Gets external storage directories on the host device for [dirs] (defaults to all [StorageDirectory.values]).
  ///
  /// - **Android**: Resolves external files directories for [dirs].
  /// - **iOS, macOS, Linux, Windows**: Unsupported. Throws an [UnsupportedError].
  ///
  /// Throws a [MissingPlatformDirectoryException] if no directories can be resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final storageDirs = await PathManager.getExternalStorageDirectories([
  ///   StorageDirectory.pictures,
  ///   StorageDirectory.movies,
  /// ]);
  /// for (final dir in storageDirs) {
  ///   print('Storage dir: ${dir.path}');
  /// }
  /// ```
  static Future<List<Directory>> getExternalStorageDirectories([
    List<StorageDirectory> dirs = StorageDirectory.values,
  ]) async {
    final List<String>? paths = await PlatformPathManager.instance
        .getExternalStoragePaths(dirs);
    if (paths == null || paths.isEmpty) {
      throw const MissingPlatformDirectoryException(
        'Unable to get external storage directories',
      );
    }
    return paths.map(Directory.new).toList();
  }

  /// Gets external cache directories on the host device.
  ///
  /// - **Android**: Resolves app-specific external cache directories (`Context.getExternalCacheDirs()`).
  /// - **iOS, macOS, Linux, Windows**: Unsupported. Throws an [UnsupportedError].
  ///
  /// Throws a [MissingPlatformDirectoryException] if no cache directories can be resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final extCacheDirs = await PathManager.getExternalCacheDirectories();
  /// for (final dir in extCacheDirs) {
  ///   print('External cache: ${dir.path}');
  /// }
  /// ```
  static Future<List<Directory>> getExternalCacheDirectories() async {
    final List<String>? paths = await PlatformPathManager.instance
        .getExternalCachePaths();
    if (paths == null || paths.isEmpty) {
      throw const MissingPlatformDirectoryException(
        'Unable to get external cache directories',
      );
    }
    return paths.map(Directory.new).toList();
  }

  /// Gets the downloads directory on the host device.
  ///
  /// - **Android**: Resolves the app's external downloads directory.
  /// - **macOS, Linux, Windows**: Resolves the user's Downloads directory.
  /// - **iOS**: Throws an [UnsupportedError] due to iOS platform sandboxing.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be resolved.
  /// Throws an [UnsupportedError] on iOS.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final downloadsDir = await PathManager.getDownloadsDirectory();
  /// print('Downloads: ${downloadsDir.path}');
  /// ```
  static Future<Directory> getDownloadsDirectory() async {
    final String? path = await PlatformPathManager.instance.getDownloadsPath();
    if (path == null) {
      throw const MissingPlatformDirectoryException(
        'Unable to get downloads directory',
      );
    }
    return Directory(path);
  }

  /// Sets whether the file or directory at [path] should be excluded from backups.
  ///
  /// - **iOS & macOS**: Programmatically marks the file/directory with the
  ///   `NSURLIsExcludedFromBackupKey` resource key.
  /// - **Android, Linux, Windows**: This method is not supported and throws an [UnsupportedError].
  ///
  /// Throws a [FileSystemException] if the path does not exist on Apple platforms
  /// or if changing the exclusion status fails.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final document = File('${docsDir.path}/large_dataset.bin');
  /// await document.writeAsBytes(datasetBytes);
  ///
  /// // Exclude this specific file from Apple iCloud/iTunes backups
  /// await PathManager.setApplicationPathIsExcludedFromBackup(document.path, true);
  /// ```
  static Future<void> setApplicationPathIsExcludedFromBackup(
    String path,
    bool exclude,
  ) async {
    await PlatformPathManager.instance.setApplicationPathIsExcludedFromBackup(
      path,
      exclude,
    );
  }

  /// Gets the path to the temporary directory synchronously.
  ///
  /// This avoids the event loop entirely, which is useful during `main()`,
  /// dependency-injection container setup, and database initialization.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be
  /// resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final tempDir = PathManager.getTemporaryDirectorySync();
  /// ```
  static Directory getTemporaryDirectorySync() => _requireDirectory(
    PlatformPathManager.instance.getTemporaryPathSync(),
    'temporary',
  );

  /// Gets the path to the application support directory synchronously.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be
  /// resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final supportDir = PathManager.getApplicationSupportDirectorySync();
  /// final database = File('${supportDir.path}/app.db');
  /// ```
  static Directory getApplicationSupportDirectorySync() => _requireDirectory(
    PlatformPathManager.instance.getApplicationSupportPathSync(),
    'application support',
  );

  /// Gets the path to the application documents directory synchronously.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be
  /// resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final docsDir = PathManager.getApplicationDocumentsDirectorySync();
  /// ```
  static Directory getApplicationDocumentsDirectorySync() => _requireDirectory(
    PlatformPathManager.instance.getDocumentsPathSync(),
    'application documents',
  );

  /// Gets the path to the application cache directory synchronously.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be
  /// resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final cacheDir = PathManager.getApplicationCacheDirectorySync();
  /// ```
  static Directory getApplicationCacheDirectorySync() => _requireDirectory(
    PlatformPathManager.instance.getApplicationCachePathSync(),
    'application cache',
  );

  /// Gets the path to the downloads directory synchronously.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be
  /// resolved and an [UnsupportedError] on platforms where downloads are not
  /// supported (for example, iOS).
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final downloads = PathManager.getDownloadsDirectorySync();
  /// ```
  static Directory getDownloadsDirectorySync() => _requireDirectory(
    PlatformPathManager.instance.getDownloadsPathSync(),
    'downloads',
  );

  /// Gets the path to the user's desktop directory.
  ///
  /// Supported on Windows, macOS, and Linux. Throws an [UnsupportedError] on
  /// Android and iOS, which use sandboxed storage instead of global user
  /// directories.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be
  /// resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final desktop = await PathManager.getDesktopDirectory();
  /// ```
  static Future<Directory> getDesktopDirectory() async => _requireDirectory(
    await PlatformPathManager.instance.getDesktopPath(),
    'desktop',
  );

  /// Gets the path to the user's pictures directory.
  ///
  /// Supported on Windows, macOS, and Linux. Throws an [UnsupportedError] on
  /// Android and iOS.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be
  /// resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final pictures = await PathManager.getPicturesDirectory();
  /// ```
  static Future<Directory> getPicturesDirectory() async => _requireDirectory(
    await PlatformPathManager.instance.getPicturesPath(),
    'pictures',
  );

  /// Gets the path to the user's music directory.
  ///
  /// Supported on Windows, macOS, and Linux. Throws an [UnsupportedError] on
  /// Android and iOS.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be
  /// resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final music = await PathManager.getMusicDirectory();
  /// ```
  static Future<Directory> getMusicDirectory() async => _requireDirectory(
    await PlatformPathManager.instance.getMusicPath(),
    'music',
  );

  /// Gets the path to the user's videos directory.
  ///
  /// Supported on Windows, macOS, and Linux. Throws an [UnsupportedError] on
  /// Android and iOS.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be
  /// resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final videos = await PathManager.getVideosDirectory();
  /// ```
  static Future<Directory> getVideosDirectory() async => _requireDirectory(
    await PlatformPathManager.instance.getVideosPath(),
    'videos',
  );

  /// Gets the path to the user's desktop directory synchronously.
  ///
  /// Throws an [UnsupportedError] on Android and iOS.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be
  /// resolved.
  static Directory getDesktopDirectorySync() => _requireDirectory(
    PlatformPathManager.instance.getDesktopPathSync(),
    'desktop',
  );

  /// Gets the path to the user's pictures directory synchronously.
  ///
  /// Throws an [UnsupportedError] on Android and iOS.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be
  /// resolved.
  static Directory getPicturesDirectorySync() => _requireDirectory(
    PlatformPathManager.instance.getPicturesPathSync(),
    'pictures',
  );

  /// Gets the path to the user's music directory synchronously.
  ///
  /// Throws an [UnsupportedError] on Android and iOS.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be
  /// resolved.
  static Directory getMusicDirectorySync() => _requireDirectory(
    PlatformPathManager.instance.getMusicPathSync(),
    'music',
  );

  /// Gets the path to the user's videos directory synchronously.
  ///
  /// Throws an [UnsupportedError] on Android and iOS.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the directory cannot be
  /// resolved.
  static Directory getVideosDirectorySync() => _requireDirectory(
    PlatformPathManager.instance.getVideosPathSync(),
    'videos',
  );

  /// Queries the capacity of the filesystem volume that contains [path].
  ///
  /// [path] selects the volume to query; it may refer to a directory or a file
  /// on that volume. The returned [DiskSpace] describes the volume's free and
  /// total capacity in bytes, not the size of the entity at [path].
  ///
  /// When [path] is `null`, the application support directory is used.
  ///
  /// Only paths that the application can access are supported. On mobile
  /// platforms the result describes the shared volume rather than an
  /// app-specific quota.
  ///
  /// Throws a [FileSystemException] if the volume cannot be queried.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final space = await PathManager.getDiskSpace();
  /// if (space.freeBytes < requiredBytes) {
  ///   print('Not enough storage: ${PathManager.formatBytes(space.freeBytes)} free');
  /// }
  /// ```
  static Future<DiskSpace> getDiskSpace({String? path}) async {
    final space = await PlatformPathManager.instance.getDiskSpace(path: path);
    if (space == null) {
      throw FileSystemException('Unable to query disk space', path);
    }
    return space;
  }

  /// Queries the capacity of the filesystem volume that contains [path]
  /// synchronously.
  ///
  /// [path] selects the volume to query; it may refer to a directory or a file
  /// on that volume. The returned [DiskSpace] describes the volume's free and
  /// total capacity in bytes, not the size of the entity at [path].
  ///
  /// When [path] is `null`, the application support directory is used.
  ///
  /// Throws a [FileSystemException] if the volume cannot be queried.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final space = PathManager.getDiskSpaceSync();
  /// print('${space.freeBytes} of ${space.totalBytes} bytes free');
  /// ```
  static DiskSpace getDiskSpaceSync({String? path}) {
    final space = PlatformPathManager.instance.getDiskSpaceSync(path: path);
    if (space == null) {
      throw FileSystemException('Unable to query disk space', path);
    }
    return space;
  }

  /// Calculates the total size of the application cache directory in bytes.
  ///
  /// The directory is walked recursively without following symbolic links.
  /// Returns `0` when the cache directory does not exist. Files that disappear
  /// or cannot be read while walking are skipped.
  ///
  /// Use [formatBytes] to render the result for display.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final bytes = await PathManager.getApplicationCacheSize();
  /// print('Cache: ${PathManager.formatBytes(bytes)}');
  /// ```
  static Future<int> getApplicationCacheSize() async {
    final cache = await getApplicationCacheDirectory();
    if (!await cache.exists()) return 0;

    var total = 0;
    await for (final entity in cache.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;
      try {
        total += await entity.length();
      } on FileSystemException {
        // The file may have been removed or locked concurrently.
      }
    }
    return total;
  }

  /// Deletes the contents of the application cache directory.
  ///
  /// The cache directory itself is preserved because the operating system
  /// expects it to exist. Entries that are locked or removed concurrently are
  /// skipped.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// await PathManager.clearApplicationCache();
  /// ```
  static Future<void> clearApplicationCache() async {
    final cache = await getApplicationCacheDirectory();
    if (!await cache.exists()) return;

    await for (final entity in cache.list(followLinks: false)) {
      try {
        await entity.delete(recursive: true);
      } on FileSystemException {
        // The entry may be locked or already removed.
      }
    }
  }

  /// Formats a byte count into a human-readable string.
  ///
  /// Uses 1024-based units and one decimal place for values of 1 KB and above.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// PathManager.formatBytes(0);      // '0 B'
  /// PathManager.formatBytes(1536);   // '1.5 KB'
  /// PathManager.formatBytes(14994636); // '14.3 MB'
  /// ```
  static String formatBytes(int bytes) {
    if (bytes < 0) {
      throw ArgumentError.value(bytes, 'bytes', 'must not be negative');
    }
    if (bytes < 1024) return '$bytes B';

    const units = ['KB', 'MB', 'GB', 'TB', 'PB', 'EB'];
    var value = bytes / 1024;
    var unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    return '${value.toStringAsFixed(1)} ${units[unit]}';
  }

  /// Resolves and creates a namespaced subdirectory inside the application
  /// support directory.
  ///
  /// [subpath] must be relative and may contain nested segments, for example
  /// `database/drift`. Leading separators, drive letters, UNC paths, `..`
  /// segments, NUL characters, and Windows reserved device names are rejected
  /// with an [ArgumentError]. Both `/` and `\` are accepted as separators and
  /// are normalized to the host platform.
  ///
  /// Throws a [MissingPlatformDirectoryException] if the base directory cannot
  /// be resolved.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final dbDir = await PathManager.getApplicationSupportSubdirectory('database');
  /// final driftDir = await PathManager.getApplicationSupportSubdirectory('database/drift');
  /// ```
  static Future<Directory> getApplicationSupportSubdirectory(
    String subpath,
  ) async {
    final base = getApplicationSupportDirectorySync();
    return _createSubdirectory(base, subpath);
  }

  /// Resolves and creates a namespaced subdirectory inside the application
  /// cache directory.
  ///
  /// See [getApplicationSupportSubdirectory] for the accepted [subpath] format.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final imageCache = await PathManager.getApplicationCacheSubdirectory('images');
  /// ```
  static Future<Directory> getApplicationCacheSubdirectory(
    String subpath,
  ) async {
    final base = getApplicationCacheDirectorySync();
    return _createSubdirectory(base, subpath);
  }

  /// Resolves and creates a namespaced subdirectory inside the application
  /// documents directory.
  ///
  /// See [getApplicationSupportSubdirectory] for the accepted [subpath] format.
  ///
  /// ### Examples
  ///
  /// ```dart
  /// final projects = await PathManager.getApplicationDocumentsSubdirectory('projects');
  /// ```
  static Future<Directory> getApplicationDocumentsSubdirectory(
    String subpath,
  ) async {
    final base = getApplicationDocumentsDirectorySync();
    return _createSubdirectory(base, subpath);
  }

  static Directory _requireDirectory(String? path, String name) {
    if (path == null) {
      throw MissingPlatformDirectoryException('Unable to get $name directory');
    }
    return Directory(path);
  }

  static final _windowsReservedNames = RegExp(
    r'^(con|prn|aux|nul|com[1-9]|lpt[1-9])(\..*)?$',
    caseSensitive: false,
  );

  static Future<Directory> _createSubdirectory(
    Directory base,
    String subpath,
  ) async {
    final candidate = _resolveSubdirectory(base, subpath);
    await _verifySubdirectoryContainment(base, candidate, subpath);
    await candidate.create(recursive: true);
    await _verifySubdirectoryContainment(base, candidate, subpath);
    return candidate;
  }

  static Directory _resolveSubdirectory(Directory base, String subpath) {
    if (subpath.isEmpty || subpath.trim().isEmpty) {
      throw ArgumentError.value(subpath, 'subpath', 'must not be empty');
    }
    if (subpath.contains('\u0000')) {
      throw ArgumentError.value(
        subpath,
        'subpath',
        'must not contain NUL characters',
      );
    }

    // Treat both separators as separators so the accepted input is consistent
    // across platforms, then rebuild the path with the host separator.
    final normalized = subpath.replaceAll('\\', '/');
    if (normalized.startsWith('~')) {
      throw ArgumentError.value(
        subpath,
        'subpath',
        'must be relative to the base directory',
      );
    }
    if (RegExp(r'^[A-Za-z]:').hasMatch(normalized)) {
      throw ArgumentError.value(
        subpath,
        'subpath',
        'must not contain a drive letter',
      );
    }
    if (normalized.startsWith('//')) {
      throw ArgumentError.value(
        subpath,
        'subpath',
        'must not be a UNC path',
      );
    }
    if (normalized.startsWith('/')) {
      throw ArgumentError.value(subpath, 'subpath', 'must not be absolute');
    }

    final segments = <String>[];
    for (final segment in normalized.split('/')) {
      if (segment.isEmpty || segment == '.') continue;
      if (segment == '..') {
        throw ArgumentError.value(
          subpath,
          'subpath',
          'must not contain ".." segments',
        );
      }
      if (segment.trim().isEmpty) {
        throw ArgumentError.value(
          subpath,
          'subpath',
          'must not contain empty segments',
        );
      }
      if (Platform.isWindows) {
        if (segment.endsWith('.') || segment.endsWith(' ')) {
          throw ArgumentError.value(
            subpath,
            'subpath',
            'Windows path segments must not end with a dot or space',
          );
        }
        if (_windowsReservedNames.hasMatch(segment)) {
          throw ArgumentError.value(
            subpath,
            'subpath',
            'must not use a reserved Windows device name',
          );
        }
      }
      segments.add(segment);
    }

    if (segments.isEmpty) {
      throw ArgumentError.value(
        subpath,
        'subpath',
        'must contain at least one path segment',
      );
    }

    final candidate = p.normalize(p.joinAll([base.path, ...segments]));
    if (!p.isWithin(base.path, candidate)) {
      throw ArgumentError.value(
        subpath,
        'subpath',
        'must resolve inside the base directory',
      );
    }
    return Directory(candidate);
  }

  /// Verifies that a subdirectory does not escape [base] through a symbolic
  /// link. When [candidate] does not exist yet, the nearest existing ancestor
  /// is checked so escaping links are rejected before anything is created.
  /// Platforms that cannot resolve symbolic links are left to the filesystem's
  /// own access checks.
  static Future<void> _verifySubdirectoryContainment(
    Directory base,
    Directory candidate,
    String subpath,
  ) async {
    var existing = candidate;
    while (!await existing.exists()) {
      final parent = existing.parent;
      if (p.equals(parent.path, existing.path)) break;
      existing = parent;
    }

    // If the nearest existing ancestor lies outside the base, the base itself
    // does not exist yet. The post-creation check validates the final path.
    if (!p.equals(existing.path, base.path) &&
        !p.isWithin(base.path, existing.path)) {
      return;
    }

    try {
      final resolvedBase = await base.resolveSymbolicLinks();
      final resolvedExisting = await existing.resolveSymbolicLinks();
      if (!p.equals(resolvedBase, resolvedExisting) &&
          !p.isWithin(resolvedBase, resolvedExisting)) {
        throw ArgumentError.value(
          subpath,
          'subpath',
          'must resolve inside the base directory',
        );
      }
    } on FileSystemException {
      // Symbolic-link resolution is not available for every path.
    }
  }
}
