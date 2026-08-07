# 0.7.0

* **Features**:
    - Add `getExternalStorageDirectory()` for retrieving primary external storage.
    - Add `getExternalStorageDirectories({StorageDirectory? type})` for typed external storage directories.
    - Add `getExternalCacheDirectories()` for external cache directories.
    - Add `getDownloadsDirectory()` for user/app downloads directory.
    - Add `StorageDirectory` enum for external directory categorization.
    - Enhance error messages on failure/misconfiguration with detailed resolution and documentation instructions.
* **Breaking Changes**:
    - Rename `getCachesDirectory()` to `getApplicationCacheDirectory()` for naming consistency with other `PathManager` directory getters and Flutter's `path_provider`.
    - Rename `PlatformPathManager.getCachesPath()` to `PlatformPathManager.getApplicationCachePath()`.

# 0.6.1

* Export `PlatformPathManager` publicly to enable custom overrides and mocking in tests.
* Add comprehensive unit tests and documentation for testing and mocking path resolution.

# 0.6.0

* Rename `getApplicationNoBackupPath` to `getApplicationNoBackupDirectory`.
* Update `getApplicationNoBackupDirectory` to return `Future<Directory>` instead of `Future<String>` for consistency with other directory methods.

# 0.5.0

* initial release
