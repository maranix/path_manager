import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/backup_guard_api.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        '../flutter_native_backup_guard_android/android/src/main/kotlin/com/stroma/flutter_native_backup_guard_android/BackupGuardApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.stroma.flutter_native_backup_guard_android',
    ),
    swiftOut:
        '../flutter_native_backup_guard_ios/ios/flutter_native_backup_guard_ios/Sources/flutter_native_backup_guard_ios/BackupGuardApi.g.swift',
    swiftOptions: SwiftOptions(),
    dartPackageName: 'flutter_native_backup_guard_platform_interface',
  ),
)
@HostApi()
abstract class BackupGuardApi {
  /// Excludes the file or directory at the given [path] from backups.
  ///
  /// On iOS, this sets the `NSURLIsExcludedFromBackupKey` attribute.
  /// On Android, it checks if the path is inside the `no_backup` directory.
  /// Returns true if successful or inherently excluded.
  bool excludeFromBackup(String path);

  /// Returns the absolute path to the directory that is excluded from backups.
  ///
  /// On Android, this returns the `no_backup` directory path.
  /// On iOS, this returns a custom `NoBackup` directory under the Application Support folder.
  String getNoBackupFilesDir();
}
