import 'dart:ffi';
import 'dart:io';
import 'package:objective_c/objective_c.dart';
import 'package:path_manager/bindings/foundation/bindings.g.dart';
import 'platform_path_manager.dart';

/// The iOS/macOS implementation of [PlatformPathManager] using Apple Foundation APIs via FFI.
class FoundationPathManager extends PlatformPathManager {
  /// Creates a new [FoundationPathManager] and registers selectors.
  FoundationPathManager() {
    // Foundation is already loaded in the host process on Apple platforms.
    // Instantiate FoundationFFI to register classes and selectors.
    FoundationFFI(DynamicLibrary.process());
  }

  @override
  Future<String?> getTemporaryPath() async {
    final manager = NSFileManager.getDefaultManager();
    final url = manager.temporaryDirectory;
    return url.path?.toDartString();
  }

  @override
  Future<String?> getApplicationSupportPath() => _getPathForDirectory(
    NSSearchPathDirectory.NSApplicationSupportDirectory,
  );

  @override
  Future<String?> getDocumentsPath() => _getPathForDirectory(
    NSSearchPathDirectory.NSDocumentDirectory,
  );

  @override
  Future<String?> getCachesPath() => _getPathForDirectory(
    NSSearchPathDirectory.NSCachesDirectory,
  );

  Future<String?> _getPathForDirectory(NSSearchPathDirectory directory) async {
    final manager = NSFileManager.getDefaultManager();

    // NSSearchPathDomainMask.NSUserDomainMask = 1
    final url = manager.URLForDirectory(
      directory,
      inDomain: 1,
      appropriateForURL: null,
      create: true,
    );
    return url?.path?.toDartString();
  }

  @override
  Future<void> setApplicationPathIsExcludedFromBackup(
    String path,
    bool exclude,
  ) async {
    try {
      final nsPath = NSString(path);
      final url = NSURL.fileURLWithPath(nsPath);
      final key = NSString('NSURLIsExcludedFromBackupKey');
      final value = NSNumberCreation.numberWithBool(exclude);
      final success = url.setResourceValue(value, forKey: key);
      if (!success) {
        throw FileSystemException(
          'Failed to set backup exclusion status (returned false)',
          path,
        );
      }
    } on Exception catch (e) {
      throw FileSystemException(
        'Failed to set backup exclusion status: $e',
        path,
      );
    }
  }
}
