import 'dart:ffi';
import 'package:objective_c/objective_c.dart';
import 'package:path_manager/bindings/foundation/bindings.g.dart';
import 'path_manager_platform.dart';

class FoundationPathManagerPlatform extends PathManagerPlatform {
  FoundationPathManagerPlatform() {
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
}
