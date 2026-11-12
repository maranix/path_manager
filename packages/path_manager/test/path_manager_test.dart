import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_manager/path_manager.dart';

import 'fake_platform_path_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PathManager with PlatformPathManager mock', () {
    PlatformPathManager? originalInstance;
    late FakePlatformPathManager fakeManager;

    setUp(() {
      try {
        originalInstance = PlatformPathManager.instance;
      } catch (_) {
        originalInstance = null;
      }
      fakeManager = FakePlatformPathManager();
      PlatformPathManager.instance = fakeManager;
    });

    tearDown(() {
      if (originalInstance != null) {
        PlatformPathManager.instance = originalInstance!;
      }
    });

    test('getTemporaryDirectory forwards to PlatformPathManager', () async {
      fakeManager.temporaryPath = '/test/temp';
      final dir = await PathManager.getTemporaryDirectory();
      expect(dir.path, equals('/test/temp'));
    });

    test('getTemporaryDirectory throws MissingPlatformDirectoryException when null', () async {
      fakeManager.temporaryPath = null;
      expect(
        () => PathManager.getTemporaryDirectory(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
    });

    test(
      'getApplicationSupportDirectory forwards to PlatformPathManager',
      () async {
        fakeManager.applicationSupportPath = '/test/support';
        final dir = await PathManager.getApplicationSupportDirectory();
        expect(dir.path, equals('/test/support'));
      },
    );

    test('getApplicationSupportDirectory throws MissingPlatformDirectoryException when null', () async {
      fakeManager.applicationSupportPath = null;
      expect(
        () => PathManager.getApplicationSupportDirectory(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
    });

    test(
      'getApplicationDocumentsDirectory forwards to PlatformPathManager',
      () async {
        fakeManager.documentsPath = '/test/documents';
        final dir = await PathManager.getApplicationDocumentsDirectory();
        expect(dir.path, equals('/test/documents'));
      },
    );

    test('getApplicationDocumentsDirectory throws MissingPlatformDirectoryException when null', () async {
      fakeManager.documentsPath = null;
      expect(
        () => PathManager.getApplicationDocumentsDirectory(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
    });

    test(
      'getApplicationCacheDirectory forwards to PlatformPathManager',
      () async {
        fakeManager.applicationCachePath = '/test/cache';
        final dir = await PathManager.getApplicationCacheDirectory();
        expect(dir.path, equals('/test/cache'));
      },
    );

    test('getApplicationCacheDirectory throws MissingPlatformDirectoryException when null', () async {
      fakeManager.applicationCachePath = null;
      expect(
        () => PathManager.getApplicationCacheDirectory(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
    });

    test(
      'getApplicationNoBackupDirectory forwards to PlatformPathManager',
      () async {
        fakeManager.applicationNoBackupDirectory = '/test/no_backup';
        final dir = await PathManager.getApplicationNoBackupDirectory();
        expect(dir.path, equals('/test/no_backup'));
      },
    );

    test('getApplicationNoBackupDirectory throws MissingPlatformDirectoryException when null', () async {
      fakeManager.applicationNoBackupDirectory = null;
      expect(
        () => PathManager.getApplicationNoBackupDirectory(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
    });

    test(
      'getExternalStorageDirectory forwards to PlatformPathManager',
      () async {
        fakeManager.externalStoragePath = '/test/storage/music';
        final dir = await PathManager.getExternalStorageDirectory(
          StorageDirectory.music,
        );
        expect(dir.path, equals('/test/storage/music'));
      },
    );

    test('getExternalStorageDirectory throws MissingPlatformDirectoryException when null', () async {
      fakeManager.externalStoragePath = null;
      expect(
        () => PathManager.getExternalStorageDirectory(StorageDirectory.music),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
    });

    test(
      'getExternalStorageDirectories forwards to PlatformPathManager',
      () async {
        fakeManager.externalStoragePaths = [
          '/test/storage/1',
          '/test/storage/2',
        ];
        final dirs = await PathManager.getExternalStorageDirectories([
          StorageDirectory.pictures,
          StorageDirectory.movies,
        ]);
        expect(
          dirs.map((d) => d.path).toList(),
          equals(['/test/storage/1', '/test/storage/2']),
        );
      },
    );

    test('getExternalStorageDirectories throws MissingPlatformDirectoryException when empty or null', () async {
      fakeManager.externalStoragePaths = null;
      expect(
        () => PathManager.getExternalStorageDirectories(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );

      fakeManager.externalStoragePaths = [];
      expect(
        () => PathManager.getExternalStorageDirectories(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
    });

    test(
      'getExternalCacheDirectories forwards to PlatformPathManager',
      () async {
        fakeManager.externalCachePaths = ['/test/ext_cache/1'];
        final dirs = await PathManager.getExternalCacheDirectories();
        expect(dirs.map((d) => d.path).toList(), equals(['/test/ext_cache/1']));
      },
    );

    test('getExternalCacheDirectories throws MissingPlatformDirectoryException when empty or null', () async {
      fakeManager.externalCachePaths = null;
      expect(
        () => PathManager.getExternalCacheDirectories(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );

      fakeManager.externalCachePaths = [];
      expect(
        () => PathManager.getExternalCacheDirectories(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
    });

    test('getDownloadsDirectory forwards to PlatformPathManager', () async {
      fakeManager.downloadsPath = '/test/downloads';
      final dir = await PathManager.getDownloadsDirectory();
      expect(dir.path, equals('/test/downloads'));
    });

    test('getDownloadsDirectory throws MissingPlatformDirectoryException when null', () async {
      fakeManager.downloadsPath = null;
      expect(
        () => PathManager.getDownloadsDirectory(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
    });

    test('setApplicationPathIsExcludedFromBackup forwards parameters to PlatformPathManager', () async {
      await PathManager.setApplicationPathIsExcludedFromBackup(
        '/test/file.txt',
        true,
      );
      expect(fakeManager.lastExcludedPath, equals('/test/file.txt'));
      expect(fakeManager.lastExcludedValue, isTrue);

      await PathManager.setApplicationPathIsExcludedFromBackup(
        '/test/file.txt',
        false,
      );
      expect(fakeManager.lastExcludedValue, isFalse);
    });

    test('setApplicationPathIsExcludedFromBackup propagates errors', () async {
      fakeManager.shouldThrowOnExclude = true;
      expect(
        () => PathManager.setApplicationPathIsExcludedFromBackup(
          '/test/error',
          true,
        ),
        throwsA(isA<FileSystemException>()),
      );
    });
  });
}
