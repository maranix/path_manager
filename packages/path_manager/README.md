# Path Manager

[![Pub Version](https://img.shields.io/pub/v/path_manager)](https://pub.dev/packages/path_manager)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A federated Flutter plugin providing unified access to commonly used host filesystem directories across Android, iOS, macOS, Linux, and Windows.

This plugin leverages direct native interop without MethodChannels:
- **Android**: Java Native Interface (JNI via `package:jni`)
- **iOS & macOS**: Objective-C FFI via `package:objective_c`
- **Linux**: XDG Base Directory specification via `package:xdg_directories`
- **Windows**: Win32 Shell Known Folders via `package:win32`

---

## Supported Platforms

| | Android | iOS | macOS | Linux | Windows |
|---|---|---|---|---|---|
| **Support** | API 21+ | 13.0+ | 10.15+ | Any | Windows 10+ |

---

## Application-Scoped Directories

Application support and cache directories are namespaced per application, matching platform conventions:

| Platform | Support directory | Cache directory |
|---|---|---|
| Android | Internal app files directory | Internal app cache directory |
| iOS | App container `Library/Application Support` | App container `Library/Caches` |
| macOS | `~/Library/Application Support/<bundle-id>` (or the sandbox container equivalent) | `~/Library/Caches/<bundle-id>` (or the sandbox container equivalent) |
| Linux | `$XDG_DATA_HOME/<app-id>` | `$XDG_CACHE_HOME/<app-id>` |
| Windows | `%APPDATA%\<company>\<product>` | `%LOCALAPPDATA%\<company>\<product>` |

On Linux, `<app-id>` comes from the running `GApplication` when available, falling back to the executable name. On Windows, `<company>` is omitted when the executable has no company metadata and `<product>` falls back to the executable name. Documents, downloads, and desktop media directories remain global user directories.

---

## Platform & Method Support

| Method | Android | iOS | macOS | Linux | Windows | Description |
|---|---|---|---|---|---|---|
| `getTemporaryDirectory()` | ✅ | ✅ | ✅ | ✅ | ✅ | Temporary directory for cache files (subject to OS cleanup). |
| `getApplicationSupportDirectory()` | ✅ | ✅ | ✅ | ✅ | ✅ | Application-created directory for app state, databases, etc. |
| `getApplicationDocumentsDirectory()` | ✅ | ✅ | ✅ | ✅ | ✅ | User-accessible directory for persistent documents/profiles. |
| `getApplicationCacheDirectory()` | ✅ | ✅ | ✅ | ✅ | ✅ | Cache directory (persists longer than temporary files). |
| `getApplicationNoBackupDirectory()` | ✅ | ✅ | ✅ | ✅ | ✅ | Resolves a default directory that is excluded from backups. |
| `getExternalStorageDirectory(dir)` | ✅ | ❌ | ❌ | ❌ | ❌ | External storage directory for a given `StorageDirectory`. |
| `getExternalStorageDirectories(dirs)` | ✅ | ❌ | ❌ | ❌ | ❌ | List of external storage directories for target `dirs`. |
| `getExternalCacheDirectories()` | ✅ | ❌ | ❌ | ❌ | ❌ | List of external cache directories (`Context.getExternalCacheDirs`). |
| `getDownloadsDirectory()` | ✅ | ❌ | ✅ | ✅ | ✅ | User/app downloads directory. |
| `getTemporaryDirectorySync()` | ✅ | ✅ | ✅ | ✅ | ✅ | Synchronous temporary directory. |
| `getApplicationSupportDirectorySync()` | ✅ | ✅ | ✅ | ✅ | ✅ | Synchronous application support directory. |
| `getApplicationDocumentsDirectorySync()` | ✅ | ✅ | ✅ | ✅ | ✅ | Synchronous documents directory. |
| `getApplicationCacheDirectorySync()` | ✅ | ✅ | ✅ | ✅ | ✅ | Synchronous cache directory. |
| `getDownloadsDirectorySync()` | ✅ | ❌ | ✅ | ✅ | ✅ | Synchronous downloads directory. |
| `getDesktopDirectory()` / `getDesktopDirectorySync()` | ❌ | ❌ | ✅ | ✅ | ✅ | Global user desktop directory. |
| `getPicturesDirectory()` / `getPicturesDirectorySync()` | ❌ | ❌ | ✅ | ✅ | ✅ | Global user pictures directory. |
| `getMusicDirectory()` / `getMusicDirectorySync()` | ❌ | ❌ | ✅ | ✅ | ✅ | Global user music directory. |
| `getVideosDirectory()` / `getVideosDirectorySync()` | ❌ | ❌ | ✅ | ✅ | ✅ | Global user videos directory. |
| `getDiskSpace({path})` / `getDiskSpaceSync({path})` | ✅ | ✅ | ✅ | ✅ | ✅ | Free and total volume capacity in bytes for the volume containing `path`. |
| `getApplicationCacheSize()` | ✅ | ✅ | ✅ | ✅ | ✅ | Recursive application cache size in bytes. |
| `clearApplicationCache()` | ✅ | ✅ | ✅ | ✅ | ✅ | Deletes and recreates the application cache directory. |
| `getApplication*Subdirectory(subpath)` | ✅ | ✅ | ✅ | ✅ | ✅ | Creates a validated, namespaced subdirectory. |
| `formatBytes(bytes)` | ✅ | ✅ | ✅ | ✅ | ✅ | Formats a byte count into a human-readable string. |
| `setApplicationPathIsExcludedFromBackup(...)` | ❌ | ✅ | ✅ | ❌ | ❌ | Programmatically toggles the backup exclusion flag. |

---

## Installation

Add `path_manager` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  path_manager: ^1.0.0
```

Then run:

```bash
flutter pub get
```

---

## Usage

```dart
import 'dart:io';
import 'package:path_manager/path_manager.dart';

// Retrieve the temporary directory
final Directory tempDir = await PathManager.getTemporaryDirectory();
print('Temporary directory: ${tempDir.path}');

// Retrieve the application documents directory
final Directory docsDir = await PathManager.getApplicationDocumentsDirectory();
print('Documents directory: ${docsDir.path}');

// Retrieve the application support directory
final Directory supportDir = await PathManager.getApplicationSupportDirectory();
print('Support directory: ${supportDir.path}');

// Retrieve the application cache directory
final Directory cacheDir = await PathManager.getApplicationCacheDirectory();
print('Cache directory: ${cacheDir.path}');

// Retrieve the downloads directory
final Directory downloadsDir = await PathManager.getDownloadsDirectory();
print('Downloads directory: ${downloadsDir.path}');

// Retrieve the dedicated directory excluded from backups
final Directory noBackupDir = await PathManager.getApplicationNoBackupDirectory();
print('No-backup directory: ${noBackupDir.path}');
```

### Synchronous Access

Use the synchronous getters in `main()`, dependency-injection setup, or database initialization:

```dart
final Directory supportDir = PathManager.getApplicationSupportDirectorySync();
final Directory cacheDir = PathManager.getApplicationCacheDirectorySync();
```

### Desktop Media Directories

Windows, macOS, and Linux expose global user directories. Android and iOS throw `UnsupportedError`.

```dart
final Directory pictures = await PathManager.getPicturesDirectory();
final Directory videos = await PathManager.getVideosDirectory();
```

### Disk Space and Cache Utilities

`getDiskSpace()` reports the free and total capacity of the **volume containing a path**, in bytes. `path` selects the volume; it does not measure the entity at that path. `getApplicationCacheSize()` measures only the application cache directory, and `clearApplicationCache()` deletes and recreates that directory.

```dart
final DiskSpace space = await PathManager.getDiskSpace();
print('${PathManager.formatBytes(space.freeBytes)} free of '
    '${PathManager.formatBytes(space.totalBytes)}');

final int cacheBytes = await PathManager.getApplicationCacheSize();
print('Cache: ${PathManager.formatBytes(cacheBytes)}');
await PathManager.clearApplicationCache();
```

### Safe Subdirectories

Subdirectory helpers create validated, namespaced directories. Absolute paths, drive letters, UNC paths, `..` segments, NUL characters, and Windows reserved names are rejected.

```dart
final Directory database =
    await PathManager.getApplicationSupportSubdirectory('database/drift');
```

---

## Federated Architecture

`path_manager` is built as a federated plugin:
- `path_manager`: App-facing facade package.
- `path_manager_platform_interface`: Common platform interface and data structures.
- `path_manager_android`: Android implementation using JNI.
- `path_manager_foundation`: iOS and macOS implementation using Foundation Objective-C FFI.
- `path_manager_linux`: Linux implementation using XDG Base Directory specification.
- `path_manager_windows`: Windows implementation using Win32 Shell Known Folders via FFI.
