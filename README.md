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

## Features

- **Direct interop**: Built completely with JNI and FFI interop—no MethodChannels.
- **Tree shakeable**: Platform-specific code and dependencies are only compiled and included for their target platform.
- **Desktop support**: Native Linux (XDG) and Windows (Win32 Known Folders) support.
- **Synchronous access**: Resolve every standard directory synchronously for `main()`, dependency-injection setup, and database initialization.
- **Desktop media directories**: Access the user's desktop, pictures, music, and videos directories on desktop platforms.
- **Disk and cache insights**: Query volume capacity and measure or clear the application cache, with human-readable byte formatting.
- **Safe subdirectories**: Create validated, namespaced subdirectories that cannot escape the application directory.
- **Dedicated No-Backup Directories**: Provides a default folder named `__no_backup__` that is automatically marked for exclusion from platform backup systems where supported.
- **Custom exclusions**: Mark any arbitrary file or folder on iOS/macOS to be skipped during iCloud/iTunes backups.

---

## Federated Architecture

`path_manager` is structured as a federated Flutter monorepo managed via Dart Pub Workspaces:
- [`path_manager`](file:///Users/maranix/Developer/path_manager/packages/path_manager): App-facing facade package (v1.0.0).
- [`path_manager_platform_interface`](file:///Users/maranix/Developer/path_manager/packages/path_manager_platform_interface): Common platform interface and models (v1.0.0).
- [`path_manager_android`](file:///Users/maranix/Developer/path_manager/packages/path_manager_android): Android implementation using JNI via FFI.
- [`path_manager_foundation`](file:///Users/maranix/Developer/path_manager/packages/path_manager_foundation): iOS and macOS implementation using Foundation Objective-C FFI.
- [`path_manager_linux`](file:///Users/maranix/Developer/path_manager/packages/path_manager_linux): Linux desktop implementation using XDG Base Directory specification.
- [`path_manager_windows`](file:///Users/maranix/Developer/path_manager/packages/path_manager_windows): Windows desktop implementation using Win32 Shell Known Folders via FFI.

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

## Configuration

### iOS & macOS

No additional setup is required. The plugin programmatically sets the `NSURLIsExcludedFromBackupKey` resource key using iOS/macOS Foundation APIs when managing exclusions.

### Android

On Android, programmatic runtime backup exclusion on arbitrary filesystem entities is not supported by the OS. Instead, Android backup exclusions are configured statically via resource XML files.

To exclude the default `__no_backup__` directory (which resolves to `app_support_path/__no_backup__`) from Android Auto Backup and Device-to-Device transfer, follow these setup steps:

#### 1. Define Backup Rules (Android 11 and lower)
Create a file named `backup_rules.xml` in your Android project's resource directory (`android/app/src/main/res/xml/backup_rules.xml`):

```xml
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <!-- Exclude the __no_backup__ subdirectory inside the application files directory -->
    <exclude domain="file" path="__no_backup__" />
</full-backup-content>
```

#### 2. Define Data Extraction Rules (Android 12 / API 31 and above)
Create a file named `data_extraction_rules.xml` in your Android project's resource directory (`android/app/src/main/res/xml/data_extraction_rules.xml`):

```xml
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup>
        <!-- Exclude from Cloud Backups -->
        <exclude domain="file" path="__no_backup__" />
    </cloud-backup>
    <device-transfer>
        <!-- Exclude from Device-to-Device Transfer -->
        <exclude domain="file" path="__no_backup__" />
    </device-transfer>
</data-extraction-rules>
```

#### 3. Register XML Rules in `AndroidManifest.xml`
In your `android/app/src/main/AndroidManifest.xml` file, link the rules inside the `<application>` element:

```xml
<application
    android:allowBackup="true"
    android:fullBackupContent="@xml/backup_rules"
    android:dataExtractionRules="@xml/data_extraction_rules"
    ... >
```

---

## Usage

### 1. Retrieving Standard Directories

```dart
import 'package:path_manager/path_manager.dart';

// Retrieve paths as standard dart:io Directory instances
final Directory temp = await PathManager.getTemporaryDirectory();
final Directory support = await PathManager.getApplicationSupportDirectory();
final Directory docs = await PathManager.getApplicationDocumentsDirectory();
final Directory cache = await PathManager.getApplicationCacheDirectory();
final Directory downloads = await PathManager.getDownloadsDirectory();

// Android external storage (throws UnsupportedError on iOS/macOS)
final Directory music = await PathManager.getExternalStorageDirectory(StorageDirectory.music);

print('Support Dir: ${support.path}');
```

### 2. Getting the Dedicated No-Backup Directory

The `getApplicationNoBackupDirectory()` method provides a default directory. If the directory does not exist, it is automatically created and (on Apple platforms) marked as excluded from backups.

```dart
import 'dart:io';
import 'package:path_manager/path_manager.dart';

try {
  final Directory noBackupDir = await PathManager.getApplicationNoBackupDirectory();
  final File localConfig = File('${noBackupDir.path}/settings.json');
  await localConfig.writeAsString('{"offline_mode": true}');
  print('Saved sensitive offline settings to: ${noBackupDir.path}');
} on BackupExclusionConflictException catch (e) {
  // Occurs if the __no_backup__ folder exists but was manually un-excluded
  print('Conflict detected: ${e.message}');
} on MissingPlatformDirectoryException catch (e) {
  print('Failed to resolve directory: ${e.message}');
}
```

### 3. Programmatic Backup Exclusion (iOS & macOS Only)

You can programmatically exclude individual files or directories on iOS and macOS.

```dart
import 'dart:io';
import 'package:path_manager/path_manager.dart';

final Directory docsDir = await PathManager.getApplicationDocumentsDirectory();
final File localDatabase = File('${docsDir.path}/app_db.sqlite');

try {
  // Exclude the SQLite file from iCloud/iTunes backups
  await PathManager.setApplicationPathIsExcludedFromBackup(localDatabase.path, true);
  print('Successfully excluded local database from backups.');
} on UnsupportedError catch (e) {
  // Thrown on Android
  print('Programmatic exclusions are not supported on this platform: ${e.message}');
} on FileSystemException catch (e) {
  // Thrown if the target file/directory does not exist
  print('Filesystem error: ${e.message}');
}
```

### 4. External Storage & StorageDirectory Types (Android)

When requesting external storage directories on Android, pass values from the `StorageDirectory` enum to target specific media/content directories:

| `StorageDirectory` Enum | Android Environment Path | Description |
|---|---|---|
| `StorageDirectory.music` | `Music` | Directory for user music and audio files. |
| `StorageDirectory.podcasts` | `Podcasts` | Directory for user podcasts. |
| `StorageDirectory.rtf` | `Rtf` | Directory for rich text format files. |
| `StorageDirectory.alarms` | `Alarms` | Directory for user alarm sounds. |
| `StorageDirectory.notifications` | `Notifications` | Directory for user notification sounds. |
| `StorageDirectory.pictures` | `Pictures` | Directory for user images and pictures. |
| `StorageDirectory.movies` | `Movies` | Directory for user movies and videos. |
| `StorageDirectory.downloads` | `Download` | Directory for user downloaded files. |
| `StorageDirectory.dcim` | `DCIM` | Directory for photos/videos taken by the camera. |
| `StorageDirectory.documents` | `Documents` | Directory for user documents. |

#### Example

```dart
import 'package:path_manager/path_manager.dart';

// Fetch a single external storage directory
final Directory picturesDir = await PathManager.getExternalStorageDirectory(.pictures);
print('Pictures Path: ${picturesDir.path}');

// Fetch multiple external storage directories (defaults to all StorageDirectory.values if omitted)
final List<Directory> mediaDirs = await PathManager.getExternalStorageDirectories([.pictures, .movies]);
```

---

### 5. Synchronous Path Resolution

Every standard directory has a synchronous counterpart for code that cannot await, such as `main()`, dependency-injection setup, and database initialization. Synchronous getters throw `MissingPlatformDirectoryException` when a directory cannot be resolved, or `UnsupportedError` when the platform does not provide the concept.

```dart
import 'package:path_manager/path_manager.dart';

void main() {
  final Directory support = PathManager.getApplicationSupportDirectorySync();
  final Directory cache = PathManager.getApplicationCacheDirectorySync();
  print('Database lives in: ${support.path}');
  print('Cache lives in: ${cache.path}');
}
```

---

### 6. Desktop Media Directories

Windows, macOS, and Linux expose the user's global desktop, pictures, music, and videos directories. Android and iOS throw `UnsupportedError` because they use sandboxed storage instead of global user directories.

```dart
final Directory pictures = await PathManager.getPicturesDirectory();
final Directory videos = await PathManager.getVideosDirectory();
final Directory desktop = PathManager.getDesktopDirectorySync();

print('Pictures: ${pictures.path}');
print('Videos: ${videos.path}');
print('Desktop: ${desktop.path}');
```

---

### 7. Volume Capacity and Cache Utilities

`getDiskSpace()` and `getDiskSpaceSync()` report the **free and total capacity of the volume that contains `path`, in bytes**. The `path` argument selects the volume; it does not measure the size of the file or directory at that path. When `path` is omitted, the application support directory is used. Only app-accessible paths are supported.

```dart
import 'dart:io';
import 'package:path_manager/path_manager.dart';

final DiskSpace space = await PathManager.getDiskSpace();
print('Free: ${PathManager.formatBytes(space.freeBytes)}');
print('Total: ${PathManager.formatBytes(space.totalBytes)}');

final int cacheBytes = await PathManager.getApplicationCacheSize();
print('Cache size: ${PathManager.formatBytes(cacheBytes)}');

// Delete and recreate the application cache directory.
await PathManager.clearApplicationCache();

try {
  final DiskSpace syncSpace = PathManager.getDiskSpaceSync(path: Directory.current.path);
  print('Current volume: ${syncSpace.usedBytes} bytes used');
} on FileSystemException catch (e) {
  print('Disk space unavailable: ${e.message}');
}
```

`getApplicationCacheSize()` returns the recursive size of the application cache directory **in bytes**, skipping symbolic links and files that disappear while walking. It does not include other applications or the rest of the OS cache. `getDiskSpace()` reports volume capacity instead, not the size of the application cache. `formatBytes()` renders byte counts with 1024-based units (`1536` becomes `1.5 KB`).

`clearApplicationCache()` deletes and recreates the application cache directory, so a cache directory owned by another application is never touched.

---

### 8. Safe Namespaced Subdirectories

The subdirectory helpers create a directory inside application storage and reject input that could escape it. Both `/` and `\` are accepted as separators and normalized to the host platform. Absolute paths, drive letters, UNC paths, `..` segments, NUL characters, and Windows reserved device names are rejected with an `ArgumentError`.

```dart
final Directory database = await PathManager.getApplicationSupportSubdirectory('database/drift');
final Directory images = await PathManager.getApplicationCacheSubdirectory('images');
final Directory projects = await PathManager.getApplicationDocumentsSubdirectory('projects');

print('Database: ${database.path}');
print('Image cache: ${images.path}');
print('Projects: ${projects.path}');
```

---

### Testing & Mocking

Since `path_manager` resolves directories using platform-specific APIs, writing unit tests for code that uses `PathManager` can be done by providing a mock/fake implementation of `PlatformPathManager`.

#### Writing a Mock PlatformPathManager

To mock path resolution in your tests, implement `PlatformPathManager` and set `PlatformPathManager.instance` before running your tests.
Remember to restore the original instance or tear it down.

```dart
import 'package:path_manager/path_manager.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:test/test.dart';

class FakePlatformPathManager extends PlatformPathManager
    with MockPlatformInterfaceMixin {
  @override
  Future<String?> getTemporaryPath() async => '/fake/temp';

  @override
  Future<String?> getApplicationSupportPath() async => '/fake/support';

  @override
  Future<String?> getDocumentsPath() async => '/fake/docs';

  @override
  Future<String?> getApplicationCachePath() async => '/fake/caches';

  @override
  Future<String?> getApplicationNoBackupDirectory() async => '/fake/nobackup';

  @override
  Future<void> setApplicationPathIsExcludedFromBackup(String path, bool exclude) async {
    // Handle mock exclusion logic
  }
}

void main() {
  group('My Service Tests', () {
    PlatformPathManager? originalInstance;

    setUp(() {
      try {
        originalInstance = PlatformPathManager.instance;
      } catch (_) {
        originalInstance = null;
      }
      PlatformPathManager.instance = FakePlatformPathManager();
    });

    tearDown(() {
      if (originalInstance != null) {
        PlatformPathManager.instance = originalInstance!;
      }
    });

    test('should load app settings from document path', () async {
      final docs = await PathManager.getApplicationDocumentsDirectory();
      expect(docs.path, equals('/fake/docs'));
      // ... test your code
    });
  });
}
```

---

## Contributing

Contributions and suggestions are welcome to this project!

### Setting Up For Local Development

1. Clone the repository and run dependencies setup at the workspace root:
   ```bash
   dart pub get
   ```
2. Generate FFI/JNI bindings:
   - For Android (requires `JAVA_HOME` pointing to a JDK):
     ```bash
     cd packages/path_manager_android && dart run tool/jnigen.dart
     ```
   - For iOS/macOS:
     ```bash
     cd packages/path_manager_foundation && dart run tool/ffigen.dart
     ```
3. Format all files before pushing:
   ```bash
   dart format .
   ```

### Running Tests

Run the test suite across workspace packages:
```bash
flutter test packages/path_manager
flutter test packages/path_manager_platform_interface
flutter test packages/path_manager_foundation
flutter test packages/path_manager_linux
flutter test packages/path_manager_windows
```

---

## License

This package is licensed under the MIT License. See `LICENSE` for more details.
