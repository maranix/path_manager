# 0.8.0

* **Environment**:
    - Bump Dart SDK constraint to `^3.14.0` and Flutter to `>=3.50.0`.
* **Bindings & Tooling**:
    - Migrate `ffigen` configuration in `tool/ffigen.dart` to `ffigen` 23.x API.
    - Optimize Foundation bindings by filtering `NSFileManager` methods, eliminating unnecessary block trampolines and native Objective-C compile dependencies.
    - Migrate `jnigen` configuration in `tool/jnigen.dart` to `jnigen` 1.x API.
    - Relocate generated bindings to `lib/bindings/foundation.g.dart` and `lib/bindings/android.g.dart`.
* **Refactoring & Modernization**:
    - Modernize exception classes and `StorageDirectory` enum with concise constructor syntax.
    - Remove legacy `FoundationFFI` wrapper call in `FoundationPathManager`.
    - Extract `FakePlatformPathManager` into a dedicated test helper file.
* **Example App**:
    - Upgrade Gradle wrapper to 9.3.1 and Android Gradle Plugin to 9.1.1.
    - Update example dependencies and analysis excludes.

# 0.7.x

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
