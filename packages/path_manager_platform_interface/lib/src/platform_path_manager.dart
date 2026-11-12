import 'package:plugin_platform_interface/plugin_platform_interface.dart';

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
