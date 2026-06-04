# Path Manager

[![Pub Version](https://img.shields.io/pub/v/path_manager)](https://pub.dev/packages/path_manager)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A plugin providing unified access to commonly used host filesystem directories on Android, iOS, and macOS. 

This plugin leverages direct native interop using **Java Native Interface (JNI)** on Android, and **Objective-C FFI** on iOS and macOS.

---

## Platform & Method Support

| Method | Android | iOS | macOS | Description |
|---|---|---|---|---|
| `getTemporaryDirectory()` | ✅ | ✅ | ✅ | Temporary directory for cache files (subject to OS cleanup). |
| `getApplicationSupportDirectory()` | ✅ | ✅ | ✅ | Application-created directory for app state, databases, etc. |
| `getApplicationDocumentsDirectory()` | ✅ | ✅ | ✅ | User-accessible directory for persistent documents/profiles. |
| `getCachesDirectory()` | ✅ | ✅ | ✅ | Cache directory (persists longer than temporary files). |
| `getApplicationNoBackupDirectory()` | ✅ | ✅ | ✅ | Resolves a default directory that is excluded from backups. |
| `setApplicationPathIsExcludedFromBackup(...)` | ❌ Throws | ✅ | ✅ | Programmatically toggles the backup exclusion flag. |

---

## Features

- **Direct interop**: Built completely with JNI and FFI interop—no MethodChannels.
- **Tree shakeable**: Platform-specific code and dependencies are only compiled and included for their target platform.
- **Dedicated No-Backup Directories**: Provides a default folder named `__no_backup__` that is automatically marked for exclusion from platform backup systems.
- **Custom exclusions**: Mark any arbitrary file or folder on iOS/macOS to be skipped during iCloud/iTunes backups.

---

## Installation

Add `path_manager` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  path_manager:
    path: ^0.6.0
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
final Directory caches = await PathManager.getCachesDirectory();

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

---

## Contributing

We welcome contributions to this project!

### Setting Up For Local Development

1. Clone the repository and run dependencies setup:
   ```bash
   flutter pub get
   ```
2. Generate FFI/JNI bindings:
   - For Android (requires `JAVA_HOME` pointing to a JDK):
     ```bash
     dart run tools/jnigen.dart
     ```
   - For iOS/macOS:
     ```bash
     dart run tools/ffigen.dart
     ```
3. Format all files before pushing:
   ```bash
   dart format .
   ```

### Running Tests

Run the test suite on your development machine (macOS/Linux/Windows):
```bash
dart test
```

---

## License

This package is licensed under the MIT License. See `LICENSE` for more details.
