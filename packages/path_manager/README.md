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
| `setApplicationPathIsExcludedFromBackup(...)` | ❌ | ✅ | ✅ | ❌ | ❌ | Programmatically toggles the backup exclusion flag. |

---

## Installation

Add `path_manager` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  path_manager: ^0.9.0
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

---

## Federated Architecture

`path_manager` is built as a federated plugin:
- `path_manager`: App-facing facade package.
- `path_manager_platform_interface`: Common platform interface and data structures.
- `path_manager_android`: Android implementation using JNI.
- `path_manager_foundation`: iOS and macOS implementation using Foundation Objective-C FFI.
- `path_manager_linux`: Linux implementation using XDG Base Directory specification.
- `path_manager_windows`: Windows implementation using Win32 Shell Known Folders via FFI.
