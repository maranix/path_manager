import 'src/path_manager_platform.dart';
export 'src/path_manager_platform.dart';

abstract final class PathManager {
  static Future<String?> getTemporaryPath() => PathManagerPlatform.instance.getTemporaryPath();
  static Future<String?> getApplicationSupportPath() => PathManagerPlatform.instance.getApplicationSupportPath();
  static Future<String?> getDocumentsPath() => PathManagerPlatform.instance.getDocumentsPath();
  static Future<String?> getCachesPath() => PathManagerPlatform.instance.getCachesPath();
}
