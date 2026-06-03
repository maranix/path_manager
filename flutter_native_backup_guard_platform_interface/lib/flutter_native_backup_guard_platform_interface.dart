import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'src/backup_guard_api.g.dart';

export 'src/backup_guard_api.g.dart';

/// The interface that implementations of flutter_native_backup_guard must implement.
abstract class FlutterNativeBackupGuardPlatform extends PlatformInterface {
  /// Constructs a FlutterNativeBackupGuardPlatform.
  FlutterNativeBackupGuardPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterNativeBackupGuardPlatform _instance =
      MethodChannelFlutterNativeBackupGuard();

  /// The default instance of [FlutterNativeBackupGuardPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterNativeBackupGuard].
  static FlutterNativeBackupGuardPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterNativeBackupGuardPlatform] when
  /// they register themselves.
  static set instance(FlutterNativeBackupGuardPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Excludes the file or directory at the given [path] from backups.
  ///
  /// Returns `true` if successful or inherently excluded.
  Future<bool> excludeFromBackup(String path) {
    throw UnimplementedError('excludeFromBackup() has not been implemented.');
  }

  /// Returns the absolute path to the directory that is excluded from backups.
  ///
  /// On Android, this returns the `no_backup` directory path.
  /// On iOS, this returns a custom `NoBackup` directory under the Application Support folder.
  Future<String> getNoBackupFilesDir() {
    throw UnimplementedError('getNoBackupFilesDir() has not been implemented.');
  }
}

/// An implementation of [FlutterNativeBackupGuardPlatform] that uses Pigeon.
class MethodChannelFlutterNativeBackupGuard
    extends FlutterNativeBackupGuardPlatform {
  final BackupGuardApi _api = BackupGuardApi();

  @override
  Future<bool> excludeFromBackup(String path) {
    return _api.excludeFromBackup(path);
  }

  @override
  Future<String> getNoBackupFilesDir() {
    return _api.getNoBackupFilesDir();
  }
}
