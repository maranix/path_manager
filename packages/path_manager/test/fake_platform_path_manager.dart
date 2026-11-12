import 'dart:io';

import 'package:path_manager_platform_interface/path_manager_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakePlatformPathManager extends PlatformPathManager
    with MockPlatformInterfaceMixin {
  String? temporaryPath;
  String? applicationSupportPath;
  String? documentsPath;
  String? applicationCachePath;
  String? applicationNoBackupDirectory;
  String? externalStoragePath;
  List<String>? externalStoragePaths;
  List<String>? externalCachePaths;
  String? downloadsPath;

  String? lastExcludedPath;
  bool? lastExcludedValue;
  bool shouldThrowOnExclude = false;

  @override
  Future<String?> getTemporaryPath() async => temporaryPath;

  @override
  Future<String?> getApplicationSupportPath() async => applicationSupportPath;

  @override
  Future<String?> getDocumentsPath() async => documentsPath;

  @override
  Future<String?> getApplicationCachePath() async => applicationCachePath;

  @override
  Future<String?> getApplicationNoBackupDirectory() async =>
      applicationNoBackupDirectory;

  @override
  Future<String?> getExternalStoragePath(StorageDirectory dir) async =>
      externalStoragePath;

  @override
  Future<List<String>?> getExternalStoragePaths([
    List<StorageDirectory> dirs = StorageDirectory.values,
  ]) async => externalStoragePaths;

  @override
  Future<List<String>?> getExternalCachePaths() async => externalCachePaths;

  @override
  Future<String?> getDownloadsPath() async => downloadsPath;

  @override
  Future<void> setApplicationPathIsExcludedFromBackup(
    String path,
    bool exclude,
  ) async {
    if (shouldThrowOnExclude) {
      throw const FileSystemException('Fake file system error');
    }
    lastExcludedPath = path;
    lastExcludedValue = exclude;
  }
}
