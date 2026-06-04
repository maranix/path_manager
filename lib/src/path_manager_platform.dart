import 'dart:async';
import 'dart:io';
import 'foundation_path_manager_platform.dart';

abstract class PathManagerPlatform {
  static PathManagerPlatform instance = _getDefaultPlatform();

  static PathManagerPlatform _getDefaultPlatform() {
    if (Platform.isMacOS || Platform.isIOS) {
      return FoundationPathManagerPlatform();
    }
    throw UnimplementedError('Platform is not supported.');
  }

  Future<String?> getTemporaryPath();
  Future<String?> getApplicationSupportPath();
  Future<String?> getDocumentsPath();
  Future<String?> getCachesPath();
}
