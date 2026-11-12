# 1.0.0

* **Synchronous Path Resolution**:
    - Add synchronous getters for temporary, application support, documents, cache, and downloads directories.
    - Add synchronous variants for every desktop media directory.
    - Synchronous getters throw `MissingPlatformDirectoryException` when a directory cannot be resolved, and `UnsupportedError` when the platform does not provide the concept.
* **Desktop Media Directories**:
    - Add `getDesktopDirectory()`, `getPicturesDirectory()`, `getMusicDirectory()`, and `getVideosDirectory()` with synchronous counterparts.
    - Support Windows Known Folders (`FOLDERID_Desktop`, `FOLDERID_Pictures`, `FOLDERID_Music`, `FOLDERID_Videos`), macOS Foundation directories, and Linux XDG user directories.
    - Throw `UnsupportedError` on Android and iOS, which use sandboxed storage instead of global user directories.
* **Disk Space**:
    - Add `getDiskSpace()` and `getDiskSpaceSync()`, reporting the free and total capacity of the **volume containing a path, in bytes**.
    - Add the `DiskSpace` model with `freeBytes`, `totalBytes`, and `usedBytes`.
    - `path` selects the volume to query and does not measure the size of the entity at that path. When omitted, the application support directory is used.
    - Facade methods throw `FileSystemException` when the volume cannot be queried; only app-accessible paths are supported.
    - Implemented with `GetDiskFreeSpaceExW` on Windows, `attributesOfFileSystemForPath:error:` on Apple platforms, `statvfs` on Linux, and `android.os.StatFs` on Android.
* **Cache Utilities**:
    - Add `getApplicationCacheSize()`, which returns the recursive application cache size **in bytes**, skipping symbolic links and files that disappear while walking.
    - Add `clearApplicationCache()`, which deletes cache contents while preserving the cache directory.
    - Add `formatBytes()` for 1024-based human-readable byte counts.
* **Safe Subdirectory Helpers**:
    - Add `getApplicationSupportSubdirectory()`, `getApplicationCacheSubdirectory()`, and `getApplicationDocumentsSubdirectory()`.
    - Reject absolute paths, drive letters, UNC paths, `..` segments, NUL characters, whitespace-only segments, and Windows reserved device names with `ArgumentError`.
    - Accept both `/` and `\` separators, normalize them to the host platform, and verify that created directories remain inside the base directory.
* **Bindings & Platform Implementations**:
    - Regenerate Foundation bindings with `attributesOfFileSystemForPath:error:`.
    - Regenerate Android bindings with a class-aware `jnigen` allowlist that includes `android.os.StatFs`.
    - Add a direct `ffi` dependency to `path_manager_linux` for `statvfs`.
* **Documentation & Tests**:
    - Document byte units and volume semantics for disk space and cache APIs.
    - Extend unit and integration coverage across all packages and update the example application.

# 0.9.0

* **Federated Architecture**:
    - Transition to a federated Flutter plugin architecture consisting of:
        - `path_manager`: App-facing facade package.
        - `path_manager_platform_interface`: Common platform interface and shared data structures.
        - `path_manager_android`: Android implementation using JNI via FFI (`package:jni`).
        - `path_manager_foundation`: iOS and macOS implementation using Foundation Objective-C FFI (`package:objective_c`).
        - `path_manager_linux`: Linux desktop implementation using the XDG Base Directory specification (`package:xdg_directories`).
        - `path_manager_windows`: Windows desktop implementation using Win32 Shell Known Folders via FFI (`package:win32`).
* **Desktop Support**:
    - Add Linux desktop support conforming to XDG standards (`~/.local/share`, `~/.cache`, `$TMPDIR`).
    - Add Windows desktop support using Win32 Shell Known Folders (`FOLDERID_RoamingAppData`, `FOLDERID_LocalAppData`, `FOLDERID_Documents`, `FOLDERID_Downloads`, and `GetTempPath2`/`GetTempPath`).
* **Monorepo & Tooling**:
    - Organize repository using Dart 3.5+ Pub Workspaces with a unified lockfile at workspace root.
    - Add dedicated platform-scoped example apps and integration test harnesses for each platform package.
    - Provide a multi-platform example application in `packages/path_manager/example`.

# 0.8.0

* **Environment**:
    - Bump Dart SDK constraint to `^3.14.0` and Flutter to `>=3.50.0`.
* **Bindings & Tooling**:
    - Migrate `ffigen` configuration in `tool/ffigen.dart` to `ffigen` 23.x API.
    - Optimize Foundation bindings by filtering `NSFileManager` methods, eliminating unnecessary block trampolines and native Objective-C compile dependencies.
    - Migrate `jnigen` configuration in `tool/jnigen.dart` to `jnigen` 1.x API.
    - Relocate generated bindings to `lib/bindings/foundation.g.dart` and `lib/bindings/android.g.dart`.
* **Fixes & Platform Behavior**:
    - Throw `UnsupportedError` on iOS for `getDownloadsDirectory()` due to Apple sandbox container restrictions.
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
