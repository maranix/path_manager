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
  String? desktopPath;
  String? picturesPath;
  String? musicPath;
  String? videosPath;

  DiskSpace? diskSpace;
  String? lastDiskSpacePath;

  String? lastExcludedPath;
  bool? lastExcludedValue;
  bool shouldThrowOnExclude = false;

  @override
  Future<String?> getTemporaryPath() async => temporaryPath;

  @override
  String? getTemporaryPathSync() => temporaryPath;

  @override
  Future<String?> getApplicationSupportPath() async => applicationSupportPath;

  @override
  String? getApplicationSupportPathSync() => applicationSupportPath;

  @override
  Future<String?> getDocumentsPath() async => documentsPath;

  @override
  String? getDocumentsPathSync() => documentsPath;

  @override
  Future<String?> getApplicationCachePath() async => applicationCachePath;

  @override
  String? getApplicationCachePathSync() => applicationCachePath;

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
  String? getDownloadsPathSync() => downloadsPath;

  @override
  Future<String?> getDesktopPath() async => desktopPath;

  @override
  String? getDesktopPathSync() => desktopPath;

  @override
  Future<String?> getPicturesPath() async => picturesPath;

  @override
  String? getPicturesPathSync() => picturesPath;

  @override
  Future<String?> getMusicPath() async => musicPath;

  @override
  String? getMusicPathSync() => musicPath;

  @override
  Future<String?> getVideosPath() async => videosPath;

  @override
  String? getVideosPathSync() => videosPath;

  @override
  Future<DiskSpace?> getDiskSpace({String? path}) async {
    lastDiskSpacePath = path;
    return diskSpace;
  }

  @override
  DiskSpace? getDiskSpaceSync({String? path}) {
    lastDiskSpacePath = path;
    return diskSpace;
  }

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
