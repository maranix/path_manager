/// The platform-specific interface contract for resolving directory paths.
///
/// Implementations of this class register themselves via the static [instance]
/// field at runtime. Typically, this is done automatically by Flutter's
/// generated plugin registrant for the target platform.
abstract class PlatformPathManager {
  static PlatformPathManager? _instance;

  /// The active platform-specific implementation of [PlatformPathManager].
  ///
  /// Throws a [StateError] if no platform-specific implementation has been
  /// registered.
  static PlatformPathManager get instance {
    final active = _instance;
    if (active == null) {
      throw StateError(
        'PathManager has not been initialized. Ensure that you are running '
        'on a supported platform (Android, iOS, or macOS) and that the plugin '
        'registrant has run.',
      );
    }
    return active;
  }

  /// Sets the active platform-specific implementation.
  static set instance(PlatformPathManager manager) {
    _instance = manager;
  }

  /// Gets the absolute path to the temporary directory on the host filesystem.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  Future<String?> getTemporaryPath();

  /// Gets the absolute path to the application support directory on the host filesystem.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  Future<String?> getApplicationSupportPath();

  /// Gets the absolute path to the user documents directory on the host filesystem.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  Future<String?> getDocumentsPath();

  /// Gets the absolute path to the application caches directory on the host filesystem.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  Future<String?> getCachesPath();

  /// Gets the absolute path to a default directory that is excluded from platform backup systems.
  ///
  /// Returns `null` if the directory cannot be resolved or accessed.
  Future<String?> getApplicationNoBackupDirectory();

  /// Sets whether the filesystem entity at [path] should be excluded from backups.
  ///
  /// Throws an error or exception if the operation fails or is unsupported.
  Future<void> setApplicationPathIsExcludedFromBackup(
    String path,
    bool exclude,
  );
}
