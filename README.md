# path_manager

A Flutter plugin for unified access to commonly used directories on Apple (iOS/macOS) and Android platforms using native FFI bindings (`package:objective_c` and `package:jni`).

## Features

- Retrieve unified directories: temporary, application support, documents, and caches.
- Mark specific files and directories as excluded from backups on iOS/macOS (`setApplicationPathIsExcludedFromBackup`).
- Obtain a dedicated non-backed-up directory (`getApplicationNoBackupPath`) which is automatically excluded from backups.

## Usage

### Getting the No-Backup Directory Path

To get a directory that is excluded from cloud/iTunes backups:

```dart
import 'package:path_manager/path_manager.dart';

final path = await PathManager.getApplicationNoBackupPath();
// On iOS/macOS, this is automatically created and marked as excluded from backups.
// On Android, this creates a `__no_backup__` subfolder inside the files directory.
```

### Excluding specific paths (iOS/macOS only)

On iOS and macOS, you can programmatically exclude any arbitrary file or folder from backups:

```dart
import 'package:path_manager/path_manager.dart';

await PathManager.setApplicationPathIsExcludedFromBackup('/path/to/exclude', true);
```

> [!WARNING]
> Calling `setApplicationPathIsExcludedFromBackup` on Android will throw an `UnsupportedError`. Android does not support setting backup exclusion programmatically at runtime on arbitrary paths.

---

## Platform Specifics

### iOS & macOS
No additional setup is required. The library uses Apple's native Foundation APIs (`NSURLIsExcludedFromBackupKey`) via Objective-C bindings to exclude directories and files from iTunes and iCloud backups.

### Android
On Android, backup exclusion rules are configured statically in XML files rather than programmatically at runtime. 

To ensure that the `__no_backup__` directory (returned by `getApplicationNoBackupPath`) is excluded from Auto Backup and Key-Value Backup, you must manually define and configure backup rules in your application's Android resource files:

#### 1. Define Backup Rules
Create a file named `backup_rules.xml` in your Android project's `res/xml` directory (e.g., `android/app/src/main/res/xml/backup_rules.xml`):

```xml
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <!-- Exclude __no_backup__ directory under files/ from backups -->
    <exclude domain="file" path="__no_backup__" />
</full-backup-content>
```

*(Note: For Android 12 / API 31 and above, you should define these rules in `data_extraction_rules.xml` using the `<device-transfer>` and `<cloud-backup>` elements).*

#### 2. Link Rules in `AndroidManifest.xml`
In your `android/app/src/main/AndroidManifest.xml` file, link the backup rules file in the `<application>` tag:

```xml
<application
    android:allowBackup="true"
    android:fullBackupContent="@xml/backup_rules"
    ... >
```
