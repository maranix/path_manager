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
      const e = BackupExclusionConflictException('/var/test', 'Conflict occurred');
      expect(e.path, '/var/test');
      expect(e.message, 'Conflict occurred');
      expect(
        e.toString(),
        'BackupExclusionConflictException: Conflict occurred (path: /var/test)',
      );
    });
  });
}
