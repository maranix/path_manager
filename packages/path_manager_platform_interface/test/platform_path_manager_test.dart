import 'package:flutter_test/flutter_test.dart';
import 'package:path_manager_platform_interface/path_manager_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class ValidSubclassPlatformPathManager extends PlatformPathManager {}

class ImplementsPlatformPathManager extends MockPlatformInterfaceMixin
    implements PlatformPathManager {
  @override
  Future<String?> getTemporaryPath() async => '/temp';

  @override
  Future<String?> getApplicationSupportPath() async => '/support';

  @override
  Future<String?> getDocumentsPath() async => '/docs';

  @override
  Future<String?> getApplicationCachePath() async => '/cache';

  @override
  Future<String?> getApplicationNoBackupDirectory() async => '/no_backup';

  @override
  Future<String?> getExternalStoragePath(StorageDirectory dir) async =>
      '/ext/${dir.name}';

  @override
  Future<List<String>?> getExternalStoragePaths([
    List<StorageDirectory> dirs = StorageDirectory.values,
  ]) async => ['/ext'];

  @override
  Future<List<String>?> getExternalCachePaths() async => ['/ext_cache'];

  @override
  Future<String?> getDownloadsPath() async => '/downloads';

  @override
  String? getTemporaryPathSync() => '/temp';

  @override
  String? getApplicationSupportPathSync() => '/support';

  @override
  String? getDocumentsPathSync() => '/docs';

  @override
  String? getApplicationCachePathSync() => '/cache';

  @override
  String? getDownloadsPathSync() => '/downloads';

  @override
  String? getDesktopPathSync() => '/desktop';

  @override
  String? getPicturesPathSync() => '/pictures';

  @override
  String? getMusicPathSync() => '/music';

  @override
  String? getVideosPathSync() => '/videos';

  @override
  Future<String?> getDesktopPath() async => '/desktop';

  @override
  Future<String?> getPicturesPath() async => '/pictures';

  @override
  Future<String?> getMusicPath() async => '/music';

  @override
  Future<String?> getVideosPath() async => '/videos';

  @override
  DiskSpace? getDiskSpaceSync({String? path}) =>
      const DiskSpace(freeBytes: 100, totalBytes: 200);

  @override
  Future<DiskSpace?> getDiskSpace({String? path}) async =>
      const DiskSpace(freeBytes: 100, totalBytes: 200);

  @override
  Future<void> setApplicationPathIsExcludedFromBackup(
    String path,
    bool exclude,
  ) async {}
}

class BadImplementationWithFakeToken extends PlatformInterface
    implements PlatformPathManager {
  BadImplementationWithFakeToken() : super(token: Object());

  @override
  Future<String?> getTemporaryPath() async => null;

  @override
  Future<String?> getApplicationSupportPath() async => null;

  @override
  Future<String?> getDocumentsPath() async => null;

  @override
  Future<String?> getApplicationCachePath() async => null;

  @override
  Future<String?> getApplicationNoBackupDirectory() async => null;

  @override
  Future<String?> getExternalStoragePath(StorageDirectory dir) async => null;

  @override
  Future<List<String>?> getExternalStoragePaths([
    List<StorageDirectory> dirs = StorageDirectory.values,
  ]) async => null;

  @override
  Future<List<String>?> getExternalCachePaths() async => null;

  @override
  Future<String?> getDownloadsPath() async => null;

  @override
  String? getTemporaryPathSync() => null;

  @override
  String? getApplicationSupportPathSync() => null;

  @override
  String? getDocumentsPathSync() => null;

  @override
  String? getApplicationCachePathSync() => null;

  @override
  String? getDownloadsPathSync() => null;

  @override
  String? getDesktopPathSync() => null;

  @override
  String? getPicturesPathSync() => null;

  @override
  String? getMusicPathSync() => null;

  @override
  String? getVideosPathSync() => null;

  @override
  Future<String?> getDesktopPath() async => null;

  @override
  Future<String?> getPicturesPath() async => null;

  @override
  Future<String?> getMusicPath() async => null;

  @override
  Future<String?> getVideosPath() async => null;

  @override
  DiskSpace? getDiskSpaceSync({String? path}) => null;

  @override
  Future<DiskSpace?> getDiskSpace({String? path}) async => null;

  @override
  Future<void> setApplicationPathIsExcludedFromBackup(
    String path,
    bool exclude,
  ) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlatformPathManager defaults', () {
    test('instance returns a valid default implementation', () {
      expect(PlatformPathManager.instance, isNotNull);
    });

    test('default methods throw UnimplementedError', () {
      final manager = PlatformPathManager.instance;
      expect(
        () => manager.getTemporaryPath(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getApplicationSupportPath(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getDocumentsPath(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getApplicationCachePath(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getApplicationNoBackupDirectory(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getExternalStoragePath(StorageDirectory.music),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getExternalStoragePaths(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getExternalCachePaths(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getDownloadsPath(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getTemporaryPathSync(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getApplicationSupportPathSync(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getDocumentsPathSync(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getApplicationCachePathSync(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getDownloadsPathSync(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getDesktopPath(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getPicturesPath(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getMusicPath(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getVideosPath(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getDesktopPathSync(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getPicturesPathSync(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getMusicPathSync(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getVideosPathSync(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getDiskSpace(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.getDiskSpaceSync(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => manager.setApplicationPathIsExcludedFromBackup('/test', true),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('PlatformPathManager token verification', () {
    test('can set instance with a valid subclass', () {
      final custom = ValidSubclassPlatformPathManager();
      PlatformPathManager.instance = custom;
      expect(PlatformPathManager.instance, same(custom));
    });

    test('can set instance with MockPlatformInterfaceMixin', () {
      final mock = ImplementsPlatformPathManager();
      PlatformPathManager.instance = mock;
      expect(PlatformPathManager.instance, same(mock));
    });

    test('cannot set instance with invalid token', () {
      final bad = BadImplementationWithFakeToken();
      expect(
        () => PlatformPathManager.instance = bad,
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('DiskSpace', () {
    test('exposes free, total, and used bytes', () {
      const space = DiskSpace(freeBytes: 250, totalBytes: 1000);
      expect(space.freeBytes, 250);
      expect(space.totalBytes, 1000);
      expect(space.usedBytes, 750);
    });

    test('supports value equality and hashing', () {
      const a = DiskSpace(freeBytes: 250, totalBytes: 1000);
      const b = DiskSpace(freeBytes: 250, totalBytes: 1000);
      const c = DiskSpace(freeBytes: 300, totalBytes: 1000);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('toString includes free and total bytes', () {
      const space = DiskSpace(freeBytes: 250, totalBytes: 1000);
      expect(
        space.toString(),
        'DiskSpace(freeBytes: 250, totalBytes: 1000)',
      );
    });
  });

  group('StorageDirectory enum', () {
    test('values have correct dirName mappings', () {
      expect(StorageDirectory.music.dirName, 'Music');
      expect(StorageDirectory.podcasts.dirName, 'Podcasts');
      expect(StorageDirectory.rtf.dirName, 'Rtf');
      expect(StorageDirectory.alarms.dirName, 'Alarms');
      expect(StorageDirectory.notifications.dirName, 'Notifications');
      expect(StorageDirectory.pictures.dirName, 'Pictures');
      expect(StorageDirectory.movies.dirName, 'Movies');
      expect(StorageDirectory.downloads.dirName, 'Download');
      expect(StorageDirectory.dcim.dirName, 'DCIM');
      expect(StorageDirectory.documents.dirName, 'Documents');
    });
  });

  group('Exceptions', () {
    test('MissingPlatformDirectoryException toString contains message', () {
      const e = MissingPlatformDirectoryException('Directory not found');
      expect(e.message, 'Directory not found');
      expect(
        e.toString(),
        'MissingPlatformDirectoryException: Directory not found',
      );
    });

    test('BackupExclusionConflictException toString contains message and path', () {
      const e = BackupExclusionConflictException(
        '/var/test',
        'Conflict occurred',
      );
      expect(e.path, '/var/test');
      expect(e.message, 'Conflict occurred');
      expect(
        e.toString(),
        'BackupExclusionConflictException: Conflict occurred (path: /var/test)',
      );
    });
  });
}
