import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'disk_space.dart';
import 'storage_directory.dart';

/// The platform-specific interface contract for resolving directory paths.
///
/// Platform implementations should extend this class rather than implement it as `PlatformPathManager`.
/// Extending this class (using `extends`) ensures that the subclass will get the default implementation,
/// while platform implementations that `implements` this interface will be broken by newly added
/// [PlatformPathManager] methods.
abstract class PlatformPathManager extends PlatformInterface {
  /// Constructs a PlatformPathManager.
  PlatformPathManager() : super(token: _token);

  static final Object _token = Object();

  static PlatformPathManager _instance = _PlaceholderPlatformPathManager();

  /// The default instance of [PlatformPathManager] to use.
  ///
  /// Defaults to an internal placeholder instance that throws [UnimplementedError] for all calls.
  static PlatformPathManager get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PlatformPathManager] when
  /// they register themselves.
  static set instance(PlatformPathManager instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Gets the absolute path to the temporary directory on the host filesystem.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  Future<String?> getTemporaryPath() {
    throw UnimplementedError('getTemporaryPath() has not been implemented.');
  }

  /// Gets the absolute path to the application support directory on the host filesystem.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  Future<String?> getApplicationSupportPath() {
    throw UnimplementedError(
      'getApplicationSupportPath() has not been implemented.',
    );
  }

  /// Gets the absolute path to the user documents directory on the host filesystem.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  Future<String?> getDocumentsPath() {
    throw UnimplementedError('getDocumentsPath() has not been implemented.');
  }

  /// Gets the absolute path to the application cache directory on the host filesystem.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  Future<String?> getApplicationCachePath() {
    throw UnimplementedError(
      'getApplicationCachePath() has not been implemented.',
    );
  }

  /// Gets the absolute path to a default directory that is excluded from platform backup systems.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  Future<String?> getApplicationNoBackupDirectory() {
    throw UnimplementedError(
      'getApplicationNoBackupDirectory() has not been implemented.',
    );
  }

  /// Gets the absolute path to an external storage directory for [dir].
  ///
  /// Returns `null` if external storage is unavailable or unmounted.
  /// Throws [UnsupportedError] on unsupported platforms.
  Future<String?> getExternalStoragePath(StorageDirectory dir) {
    throw UnimplementedError(
      'getExternalStoragePath() has not been implemented.',
    );
  }

  /// Gets the absolute paths to external storage directories for [dirs] (defaults to all [StorageDirectory.values]).
  ///
  /// Returns `null` if external storage is unavailable or unmounted.
  /// Throws [UnsupportedError] on unsupported platforms.
  Future<List<String>?> getExternalStoragePaths([
    List<StorageDirectory> dirs = StorageDirectory.values,
  ]) {
    throw UnimplementedError(
      'getExternalStoragePaths() has not been implemented.',
    );
  }

  /// Gets the absolute paths to external cache directories.
  ///
  /// Returns `null` if external cache storage is unavailable or unmounted.
  /// Throws [UnsupportedError] on unsupported platforms.
  Future<List<String>?> getExternalCachePaths() {
    throw UnimplementedError(
      'getExternalCachePaths() has not been implemented.',
    );
  }

  /// Gets the absolute path to the downloads directory on the host filesystem.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  Future<String?> getDownloadsPath() {
    throw UnimplementedError('getDownloadsPath() has not been implemented.');
  }

  /// Gets the absolute path to the temporary directory synchronously.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  String? getTemporaryPathSync() {
    throw UnimplementedError(
      'getTemporaryPathSync() has not been implemented.',
    );
  }

  /// Gets the absolute path to the application support directory synchronously.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  String? getApplicationSupportPathSync() {
    throw UnimplementedError(
      'getApplicationSupportPathSync() has not been implemented.',
    );
  }

  /// Gets the absolute path to the user documents directory synchronously.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  String? getDocumentsPathSync() {
    throw UnimplementedError(
      'getDocumentsPathSync() has not been implemented.',
    );
  }

  /// Gets the absolute path to the application cache directory synchronously.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  String? getApplicationCachePathSync() {
    throw UnimplementedError(
      'getApplicationCachePathSync() has not been implemented.',
    );
  }

  /// Gets the absolute path to the downloads directory synchronously.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  /// Throws [UnsupportedError] on platforms where downloads are not supported.
  String? getDownloadsPathSync() {
    throw UnimplementedError(
      'getDownloadsPathSync() has not been implemented.',
    );
  }

  /// Gets the absolute path to the user's desktop directory synchronously.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  /// Throws [UnsupportedError] on platforms without global user directories.
  String? getDesktopPathSync() {
    throw UnimplementedError('getDesktopPathSync() has not been implemented.');
  }

  /// Gets the absolute path to the user's pictures directory synchronously.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  /// Throws [UnsupportedError] on platforms without global user directories.
  String? getPicturesPathSync() {
    throw UnimplementedError('getPicturesPathSync() has not been implemented.');
  }

  /// Gets the absolute path to the user's music directory synchronously.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  /// Throws [UnsupportedError] on platforms without global user directories.
  String? getMusicPathSync() {
    throw UnimplementedError('getMusicPathSync() has not been implemented.');
  }

  /// Gets the absolute path to the user's videos directory synchronously.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  /// Throws [UnsupportedError] on platforms without global user directories.
  String? getVideosPathSync() {
    throw UnimplementedError('getVideosPathSync() has not been implemented.');
  }

  /// Gets the absolute path to the user's desktop directory.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  /// Throws [UnsupportedError] on platforms without global user directories.
  Future<String?> getDesktopPath() async => getDesktopPathSync();

  /// Gets the absolute path to the user's pictures directory.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  /// Throws [UnsupportedError] on platforms without global user directories.
  Future<String?> getPicturesPath() async => getPicturesPathSync();

  /// Gets the absolute path to the user's music directory.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  /// Throws [UnsupportedError] on platforms without global user directories.
  Future<String?> getMusicPath() async => getMusicPathSync();

  /// Gets the absolute path to the user's videos directory.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  /// Throws [UnsupportedError] on platforms without global user directories.
  Future<String?> getVideosPath() async => getVideosPathSync();

  /// Queries the capacity of the filesystem volume that contains [path].
  ///
  /// [path] selects the volume to query; it may refer to a directory or a file
  /// on that volume. The returned [DiskSpace] describes the volume's free and
  /// total capacity in bytes, not the size of the entity at [path].
  ///
  /// When [path] is `null`, the application support directory is used.
  ///
  /// Returns `null` if the volume cannot be queried. Implementations only
  /// support paths that the application can access; inaccessible paths are not
  /// resolved.
  DiskSpace? getDiskSpaceSync({String? path}) {
    throw UnimplementedError('getDiskSpaceSync() has not been implemented.');
  }

  /// Queries the capacity of the filesystem volume that contains [path].
  ///
  /// [path] selects the volume to query; it may refer to a directory or a file
  /// on that volume. The returned [DiskSpace] describes the volume's free and
  /// total capacity in bytes, not the size of the entity at [path].
  ///
  /// When [path] is `null`, the application support directory is used.
  ///
  /// Returns `null` if the volume cannot be queried. Implementations only
  /// support paths that the application can access; inaccessible paths are not
  /// resolved.
  Future<DiskSpace?> getDiskSpace({String? path}) async =>
      getDiskSpaceSync(path: path);

  /// Sets whether the filesystem entity at [path] should be excluded from backups.
  ///
  /// Throws an error or exception if the operation fails or is unsupported.
  Future<void> setApplicationPathIsExcludedFromBackup(
    String path,
    bool exclude,
  ) {
    throw UnimplementedError(
      'setApplicationPathIsExcludedFromBackup() has not been implemented.',
    );
  }
}

class _PlaceholderPlatformPathManager extends PlatformPathManager {}
