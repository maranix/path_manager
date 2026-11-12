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

    test('synchronous directory getters forward to PlatformPathManager', () {
      fakeManager.temporaryPath = '/test/temp';
      fakeManager.applicationSupportPath = '/test/support';
      fakeManager.documentsPath = '/test/documents';
      fakeManager.applicationCachePath = '/test/cache';
      fakeManager.downloadsPath = '/test/downloads';

      expect(PathManager.getTemporaryDirectorySync().path, '/test/temp');
      expect(
        PathManager.getApplicationSupportDirectorySync().path,
        '/test/support',
      );
      expect(
        PathManager.getApplicationDocumentsDirectorySync().path,
        '/test/documents',
      );
      expect(
        PathManager.getApplicationCacheDirectorySync().path,
        '/test/cache',
      );
      expect(PathManager.getDownloadsDirectorySync().path, '/test/downloads');
    });

    test('synchronous directory getters throw when null', () {
      fakeManager.temporaryPath = null;
      fakeManager.applicationSupportPath = null;
      fakeManager.documentsPath = null;
      fakeManager.applicationCachePath = null;
      fakeManager.downloadsPath = null;

      expect(
        () => PathManager.getTemporaryDirectorySync(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
      expect(
        () => PathManager.getApplicationSupportDirectorySync(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
      expect(
        () => PathManager.getApplicationDocumentsDirectorySync(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
      expect(
        () => PathManager.getApplicationCacheDirectorySync(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
      expect(
        () => PathManager.getDownloadsDirectorySync(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
    });

    test('media directory getters forward to PlatformPathManager', () async {
      fakeManager.desktopPath = '/test/desktop';
      fakeManager.picturesPath = '/test/pictures';
      fakeManager.musicPath = '/test/music';
      fakeManager.videosPath = '/test/videos';

      expect(
        (await PathManager.getDesktopDirectory()).path,
        '/test/desktop',
      );
      expect(
        (await PathManager.getPicturesDirectory()).path,
        '/test/pictures',
      );
      expect((await PathManager.getMusicDirectory()).path, '/test/music');
      expect((await PathManager.getVideosDirectory()).path, '/test/videos');

      expect(PathManager.getDesktopDirectorySync().path, '/test/desktop');
      expect(PathManager.getPicturesDirectorySync().path, '/test/pictures');
      expect(PathManager.getMusicDirectorySync().path, '/test/music');
      expect(PathManager.getVideosDirectorySync().path, '/test/videos');
    });

    test('media directory getters throw when null', () async {
      fakeManager.desktopPath = null;
      fakeManager.picturesPath = null;
      fakeManager.musicPath = null;
      fakeManager.videosPath = null;

      await expectLater(
        PathManager.getDesktopDirectory(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
      await expectLater(
        PathManager.getPicturesDirectory(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
      await expectLater(
        PathManager.getMusicDirectory(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
      await expectLater(
        PathManager.getVideosDirectory(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );

      expect(
        () => PathManager.getDesktopDirectorySync(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
      expect(
        () => PathManager.getPicturesDirectorySync(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
      expect(
        () => PathManager.getMusicDirectorySync(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
      expect(
        () => PathManager.getVideosDirectorySync(),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
    });

    test('media directory getters propagate UnsupportedError', () {
      final manager = _UnsupportedMediaPathManager();
      PlatformPathManager.instance = manager;

      expect(
        () => PathManager.getDesktopDirectorySync(),
        throwsA(isA<UnsupportedError>()),
      );
      expect(
        () => PathManager.getPicturesDirectorySync(),
        throwsA(isA<UnsupportedError>()),
      );
      expect(
        () => PathManager.getMusicDirectorySync(),
        throwsA(isA<UnsupportedError>()),
      );
      expect(
        () => PathManager.getVideosDirectorySync(),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('getDiskSpace forwards the path and returns capacity', () async {
      fakeManager.diskSpace = const DiskSpace(freeBytes: 25, totalBytes: 100);

      final space = await PathManager.getDiskSpace(path: '/mnt/data');

      expect(fakeManager.lastDiskSpacePath, '/mnt/data');
      expect(space, const DiskSpace(freeBytes: 25, totalBytes: 100));
      expect(space.usedBytes, 75);
    });

    test('getDiskSpace throws FileSystemException when unavailable', () async {
      fakeManager.diskSpace = null;

      expect(
        () => PathManager.getDiskSpace(),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('getDiskSpaceSync forwards the path and returns capacity', () {
      fakeManager.diskSpace = const DiskSpace(freeBytes: 10, totalBytes: 40);

      final space = PathManager.getDiskSpaceSync(path: '/mnt/media');

      expect(fakeManager.lastDiskSpacePath, '/mnt/media');
      expect(space, const DiskSpace(freeBytes: 10, totalBytes: 40));
    });

    test('getDiskSpaceSync throws FileSystemException when unavailable', () {
      fakeManager.diskSpace = null;

      expect(
        () => PathManager.getDiskSpaceSync(),
        throwsA(isA<FileSystemException>()),
      );
    });
  });

  group('PathManager cache utilities', () {
    late Directory tempRoot;
    late FakePlatformPathManager fakeManager;
    late Directory cacheDir;

    setUp(() async {
      tempRoot = await Directory.systemTemp.createTemp('path_manager_cache');
      cacheDir = Directory('${tempRoot.path}/cache');
      await cacheDir.create();

      fakeManager = FakePlatformPathManager()
        ..applicationCachePath = cacheDir.path;
      PlatformPathManager.instance = fakeManager;
    });

    tearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    test('getApplicationCacheSize returns the total size in bytes', () async {
      await File('${cacheDir.path}/a.txt').writeAsString('abcd');
      final nested = Directory('${cacheDir.path}/nested');
      await nested.create();
      await File('${nested.path}/b.bin').writeAsBytes([1, 2, 3, 4, 5]);

      expect(await PathManager.getApplicationCacheSize(), 9);
    });

    test('getApplicationCacheSize returns zero for an empty cache', () async {
      expect(await PathManager.getApplicationCacheSize(), 0);
    });

    test('getApplicationCacheSize returns zero when missing', () async {
      await cacheDir.delete(recursive: true);

      expect(await PathManager.getApplicationCacheSize(), 0);
    });

    test(
      'clearApplicationCache removes contents but keeps the directory',
      () async {
        await File('${cacheDir.path}/a.txt').writeAsString('data');
        final nested = Directory('${cacheDir.path}/nested');
        await nested.create();
        await File('${nested.path}/b.txt').writeAsString('data');

        await PathManager.clearApplicationCache();

        expect(await cacheDir.exists(), isTrue);
        expect(await cacheDir.list().toList(), isEmpty);
      },
    );

    test('clearApplicationCache tolerates a missing cache', () async {
      await cacheDir.delete(recursive: true);

      await PathManager.clearApplicationCache();
    });
  });

  group('PathManager formatBytes', () {
    test('formats byte counts with 1024-based units', () {
      expect(PathManager.formatBytes(0), '0 B');
      expect(PathManager.formatBytes(1023), '1023 B');
      expect(PathManager.formatBytes(1024), '1.0 KB');
      expect(PathManager.formatBytes(1536), '1.5 KB');
      expect(PathManager.formatBytes(1024 * 1024), '1.0 MB');
      expect(PathManager.formatBytes(14994636), '14.3 MB');
      expect(PathManager.formatBytes(1024 * 1024 * 1024), '1.0 GB');
    });

    test('rejects negative byte counts', () {
      expect(
        () => PathManager.formatBytes(-1),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('PathManager subdirectory helpers', () {
    late Directory tempRoot;
    late FakePlatformPathManager fakeManager;
    late Directory supportDir;
    late Directory cacheDir;
    late Directory documentsDir;

    setUp(() async {
      tempRoot = await Directory.systemTemp.createTemp('path_manager_subdir');
      supportDir = Directory('${tempRoot.path}/support');
      cacheDir = Directory('${tempRoot.path}/cache');
      documentsDir = Directory('${tempRoot.path}/documents');
      await supportDir.create();

      fakeManager = FakePlatformPathManager()
        ..applicationSupportPath = supportDir.path
        ..applicationCachePath = cacheDir.path
        ..documentsPath = documentsDir.path;
      PlatformPathManager.instance = fakeManager;
    });

    tearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    test('creates a nested support subdirectory', () async {
      final dir = await PathManager.getApplicationSupportSubdirectory(
        'database/drift',
      );

      expect(dir.path, '${supportDir.path}/database/drift');
      expect(await dir.exists(), isTrue);
    });

    test('creates cache and documents subdirectories', () async {
      final cache = await PathManager.getApplicationCacheSubdirectory('images');
      final docs = await PathManager.getApplicationDocumentsSubdirectory(
        'projects',
      );

      expect(cache.path, '${cacheDir.path}/images');
      expect(docs.path, '${documentsDir.path}/projects');
      expect(await cache.exists(), isTrue);
      expect(await docs.exists(), isTrue);
    });

    test('accepts backslashes and normalizes them', () async {
      final dir = await PathManager.getApplicationSupportSubdirectory(
        r'database\drift',
      );

      expect(dir.path, '${supportDir.path}/database/drift');
    });

    test('is idempotent for an existing subdirectory', () async {
      await PathManager.getApplicationSupportSubdirectory('database');
      final dir = await PathManager.getApplicationSupportSubdirectory(
        'database',
      );

      expect(await dir.exists(), isTrue);
    });

    for (final (subpath, reason) in <(String, String)>[
      ('', 'empty input'),
      ('   ', 'whitespace-only input'),
      ('./', 'dot-only input'),
      ('a\u0000b', 'NUL character'),
      ('~/cache', 'home-directory shorthand'),
      ('C:windows', 'drive letter'),
      ('C:/windows', 'drive-letter absolute path'),
      ('//server/share', 'UNC path'),
      ('/absolute', 'absolute path'),
      ('../escape', 'leading parent segment'),
      ('a/../../b', 'embedded parent segment'),
      ('a/ /b', 'whitespace-only segment'),
    ]) {
      test('rejects $reason', () {
        expect(
          () => PathManager.getApplicationSupportSubdirectory(subpath),
          throwsA(isA<ArgumentError>()),
        );
      });
    }

    test('rejects an empty path that normalizes away', () async {
      expect(
        () => PathManager.getApplicationSupportSubdirectory('.'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws when the base directory cannot be resolved', () async {
      fakeManager.applicationSupportPath = null;

      expect(
        () => PathManager.getApplicationSupportSubdirectory('database'),
        throwsA(isA<MissingPlatformDirectoryException>()),
      );
    });
  });
}

class _UnsupportedMediaPathManager extends FakePlatformPathManager {
  @override
  String? getDesktopPathSync() => throw UnsupportedError('desktop');

  @override
  String? getPicturesPathSync() => throw UnsupportedError('pictures');

  @override
  String? getMusicPathSync() => throw UnsupportedError('music');

  @override
  String? getVideosPathSync() => throw UnsupportedError('videos');
}
