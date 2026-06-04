import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart' as pkg_ffi;
import 'package:objective_c/objective_c.dart';
import 'package:path_manager/bindings/foundation/bindings.g.dart';
import 'package:path_manager/path_manager.dart';
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
  Future<String?> getApplicationNoBackupPath() async {
    final supportPath = await getApplicationSupportPath();
    if (supportPath == null) return null;

    final noBackupPath = '$supportPath/__no_backup__';
    final dir = Directory(noBackupPath);
    final bool alreadyExists = await dir.exists();
    if (!alreadyExists) {
      await dir.create(recursive: true);
    }

    // Check if the directory is already excluded from backup
    final nsPath = NSString(noBackupPath);
    final url = NSURL.fileURLWithPath(nsPath);
    final key = NSString('NSURLIsExcludedFromBackupKey');
    final valPtrPtr = pkg_ffi.calloc<Pointer<ObjCObjectImpl>>();
    bool isExcluded = false;
    try {
      final success = url.getResourceValue(valPtrPtr, forKey: key);
      if (success && valPtrPtr.value != nullptr) {
        final getVal = NSNumber.fromPointer(
          valPtrPtr.value,
          retain: true,
          release: true,
        );
        isExcluded = getVal.boolValue;
      }
    } catch (_) {
      // If querying fails, we treat it as not excluded
    } finally {
      pkg_ffi.calloc.free(valPtrPtr);
    }

    if (!isExcluded) {
      if (alreadyExists) {
        throw BackupExclusionConflictException(
          noBackupPath,
          'The __no_backup__ directory already exists but is not marked as excluded from backup. '
          'Since it exists without the exclusion flag, it is assumed to have been created manually. '
          'Please delete the directory or mark it as excluded.',
        );
      }
      await setApplicationPathIsExcludedFromBackup(noBackupPath, true);
    }

    return noBackupPath;
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
