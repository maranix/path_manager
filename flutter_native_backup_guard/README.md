# flutter_native_backup_guard

A federated Flutter plugin that provides type-safe, native capabilities to exclude files and directories from backups (iCloud Backup on iOS and Auto Backup on Android).

Excluding large or easily re-downloadable files (like local databases, caches, and weights) from device backups is essential to comply with Apple's App Store Review Guidelines (specifically regarding iCloud usage) and to prevent unnecessary storage consumption.

## Features

- **Type-safe native bindings** generated using [Pigeon](https://pub.dev/packages/pigeon).
- **Programmatic exclusion on iOS** using native `URL.setResourceValues` and the `isExcludedFromBackup` key.
- **Inherent directory verification on Android** (returns `true` for files stored in system-excluded paths like `cache` or `noBackupFilesDir`).
- **Comprehensive warning diagnostics on Android** if a path is not covered by Auto Backup exclusions.
- **Exposes No-Backup Directory programmatically** on both platforms for easy storage of non-backed-up data.

---

## Installation

Add `flutter_native_backup_guard` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_native_backup_guard: ^0.0.1
```

---

## Platform Specific Setup

### iOS Setup
No additional setup is required. The library interacts directly with the iOS filesystem to set the native file attributes.

### Android Setup
On Android, Google's Auto Backup system is configured **statically** using XML resource files. Because the OS does not support setting custom runtime file attributes for exclusion, you must configure your exclusion rules declaratively:

1. **Create the Backup Rules XML file**:
   Create a new file in your Android app project: `android/app/src/main/res/xml/backup_rules.xml`.

   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <full-backup-content>
       <!-- Exclude specific database files -->
       <exclude domain="database" path="my_database.db"/>
       <exclude domain="database" path="my_database.db-journal"/>

       <!-- Exclude specific subdirectories under internal files -->
       <exclude domain="file" path="model_weights/"/>
   </full-backup-content>
   ```

2. **Reference the rules in your Manifest**:
   Open `android/app/src/main/AndroidManifest.xml` and add the `android:fullBackupContent` and `android:dataExtractionRules` attributes inside the `<application>` tag:

   ```xml
   <application
       android:allowBackup="true"
       android:fullBackupContent="@xml/backup_rules"
       android:dataExtractionRules="@xml/backup_rules"
       ... >
   ```

> [!TIP]
> Alternatively, files that should **never** be backed up can be stored in the App's **no-backup** directory (`noBackupFilesDir` in Kotlin). Files inside this directory are automatically ignored by Google Drive backups without requiring any XML setup.

---

## Usage

### Simple File Exclusion

```dart
import 'dart:io';
import 'package:flutter_native_backup_guard/flutter_native_backup_guard.dart';

void main() async {
  final file = File('/path/to/my/local/large_file.bin');
  
  // Exclude the file from cloud backups
  final success = await FlutterNativeBackupGuard.excludeFromBackup(file.path);
  
  if (success) {
    print('File is successfully guarded against backups.');
  } else {
    print('Exclusion failed or requires static configuration (Android).');
  }
}
```

### Querying the No-Backup Directory

Instead of manually configuring XML rules on Android or setting exclusion attributes on iOS, you can query and store files directly inside the system's dedicated no-backup directory:

```dart
import 'package:flutter_native_backup_guard/flutter_native_backup_guard.dart';

void main() async {
  // Get the cross-platform no-backup directory
  final noBackupPath = await FlutterNativeBackupGuard.getNoBackupFilesDir();
  print('Store files here to automatically exclude them: $noBackupPath');
}
```

---

## Behavior per Platform

| OS | Method | Behavior |
| :--- | :--- | :--- |
| **iOS** | `excludeFromBackup(path)` | Calls native Swift code to apply `isExcludedFromBackup = true` resource value on the file URL. Returns `true` on success, or throws a native exception if the file does not exist. |
| **iOS** | `getNoBackupFilesDir()` | Returns the path of a custom `NoBackup` subdirectory in the `Application Support` directory, which is programmatically excluded. |
| **Android** | `excludeFromBackup(path)` | Verifies if the canonical path falls under system-ignored directories (`no_backup`, `cache`, or `code_cache`). Returns `true` if it does. If the path is outside these directories, it prints a Logcat warning and returns `false` to notify the developer that static XML configuration is required. |
| **Android** | `getNoBackupFilesDir()` | Returns the path of the system's native `noBackupFilesDir`. |

---

## Project Structure (Federated Plugin)

This plugin follows a **federated plugin architecture** to separate platform implementations:
- `flutter_native_backup_guard` (App-facing API)
- `flutter_native_backup_guard_platform_interface` (Common platform contract & Pigeon interface)
- `flutter_native_backup_guard_android` (Android-specific native plugin)
- `flutter_native_backup_guard_ios` (iOS-specific native plugin)
