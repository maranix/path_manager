import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_manager_linux/path_manager_linux.dart';
import 'package:path_manager_platform_interface/path_manager_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LinuxPathManager registration & interface compliance', () {
    test('registers as default instance on registerWith', () {
      LinuxPathManager.registerWith();
      expect(PlatformPathManager.instance, isA<LinuxPathManager>());
    });

    test('can set instance directly without token verification failure', () {
      final manager = LinuxPathManager();
      PlatformPathManager.instance = manager;
      expect(PlatformPathManager.instance, same(manager));
    });
  });

  group('LinuxPathManager path resolution', () {
    test('getTemporaryPath returns TMPDIR when set', () async {
      final manager = LinuxPathManager(
        environment: {'TMPDIR': '/custom/tmp'},
      );
      expect(await manager.getTemporaryPath(), '/custom/tmp');
    });

    test(
      'getTemporaryPath falls back to /tmp when TMPDIR is empty or not set',
      () async {
        final manager = LinuxPathManager(
          environment: {},
        );
        expect(await manager.getTemporaryPath(), '/tmp');
      },
    );

    test('getApplicationSupportPath returns dataHome', () async {
      final manager = LinuxPathManager(
        dataHome: Directory('/custom/data'),
      );
      expect(await manager.getApplicationSupportPath(), '/custom/data');
    });

    test('getApplicationCachePath returns cacheHome', () async {
      final manager = LinuxPathManager(
        cacheHome: Directory('/custom/cache'),
      );
      expect(await manager.getApplicationCachePath(), '/custom/cache');
    });

    test(
      'getDocumentsPath resolves from getUserDirectory when available',
      () async {
        final manager = LinuxPathManager(
          getUserDirectory: (name) =>
              name == 'DOCUMENTS' ? Directory('/user/docs') : null,
        );
        expect(await manager.getDocumentsPath(), '/user/docs');
      },
    );

    test('getDocumentsPath falls back to HOME/Documents', () async {
      final manager = LinuxPathManager(
        environment: {'HOME': '/home/alice'},
        getUserDirectory: (_) => null,
      );
      expect(await manager.getDocumentsPath(), '/home/alice/Documents');
    });

    test(
      'getDownloadsPath resolves from getUserDirectory when available',
      () async {
        final manager = LinuxPathManager(
          getUserDirectory: (name) =>
              name == 'DOWNLOAD' ? Directory('/user/downloads') : null,
        );
        expect(await manager.getDownloadsPath(), '/user/downloads');
      },
    );

    test('getDownloadsPath falls back to HOME/Downloads', () async {
      final manager = LinuxPathManager(
        environment: {'HOME': '/home/alice'},
        getUserDirectory: (_) => null,
      );
      expect(await manager.getDownloadsPath(), '/home/alice/Downloads');
    });

    test('synchronous getters resolve paths', () {
      final manager = LinuxPathManager(
        environment: {'TMPDIR': '/custom/tmp', 'HOME': '/home/alice'},
        dataHome: Directory('/custom/data'),
        cacheHome: Directory('/custom/cache'),
        getUserDirectory: (name) =>
            name == 'DOCUMENTS' ? Directory('/user/docs') : null,
      );

      expect(manager.getTemporaryPathSync(), '/custom/tmp');
      expect(manager.getApplicationSupportPathSync(), '/custom/data');
      expect(manager.getApplicationCachePathSync(), '/custom/cache');
      expect(manager.getDocumentsPathSync(), '/user/docs');
      expect(manager.getDownloadsPathSync(), '/home/alice/Downloads');
    });

    test('media directory getters resolve from XDG user directories', () {
      final manager = LinuxPathManager(
        getUserDirectory: (name) => switch (name) {
          'DESKTOP' => Directory('/user/desktop'),
          'PICTURES' => Directory('/user/pictures'),
          'MUSIC' => Directory('/user/music'),
          'VIDEOS' => Directory('/user/videos'),
          _ => null,
        },
      );

      expect(manager.getDesktopPathSync(), '/user/desktop');
      expect(manager.getPicturesPathSync(), '/user/pictures');
      expect(manager.getMusicPathSync(), '/user/music');
      expect(manager.getVideosPathSync(), '/user/videos');
    });

    test('media directory getters fall back to HOME', () {
      final manager = LinuxPathManager(
        environment: {'HOME': '/home/alice'},
        getUserDirectory: (_) => null,
      );

      expect(manager.getDesktopPathSync(), '/home/alice/Desktop');
      expect(manager.getPicturesPathSync(), '/home/alice/Pictures');
      expect(manager.getMusicPathSync(), '/home/alice/Music');
      expect(manager.getVideosPathSync(), '/home/alice/Videos');
    });

    test('media directory getters return null without HOME', () {
      final manager = LinuxPathManager(
        environment: {},
        getUserDirectory: (_) => null,
      );

      expect(manager.getDesktopPathSync(), isNull);
      expect(manager.getPicturesPathSync(), isNull);
      expect(manager.getMusicPathSync(), isNull);
      expect(manager.getVideosPathSync(), isNull);
    });

    test('disk space uses an explicit path', () {
      String? resolvedPath;
      final manager = LinuxPathManager(
        diskSpaceResolver: (path) {
          resolvedPath = path;
          return const DiskSpace(freeBytes: 10, totalBytes: 20);
        },
      );

      final space = manager.getDiskSpaceSync(path: '/mnt/media');

      expect(resolvedPath, '/mnt/media');
      expect(space, const DiskSpace(freeBytes: 10, totalBytes: 20));
    });

    test('disk space falls back to the application support path', () {
      String? resolvedPath;
      final manager = LinuxPathManager(
        dataHome: Directory('/custom/data'),
        diskSpaceResolver: (path) {
          resolvedPath = path;
          return const DiskSpace(freeBytes: 10, totalBytes: 20);
        },
      );

      expect(manager.getDiskSpaceSync(), isNotNull);
      expect(resolvedPath, '/custom/data');
    });

    test('disk space reports real volume capacity on Linux', () async {
      if (!Platform.isLinux) return;
      final tempDir = await Directory.systemTemp.createTemp(
        'linux_path_manager_disk_space',
      );
      try {
        final manager = LinuxPathManager();
        final space = manager.getDiskSpaceSync(path: tempDir.path);

        expect(space, isNotNull);
        expect(space!.totalBytes, greaterThan(0));
        expect(space.freeBytes, greaterThanOrEqualTo(0));
        expect(space.freeBytes, lessThanOrEqualTo(space.totalBytes));
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('getApplicationNoBackupDirectory creates and resolves __no_backup__ subpath', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'linux_path_manager_test',
      );
      try {
        final manager = LinuxPathManager(dataHome: tempDir);
        final noBackupPath = await manager.getApplicationNoBackupDirectory();
        expect(noBackupPath, isNotNull);
        expect(Directory(noBackupPath!).existsSync(), isTrue);
        expect(noBackupPath.endsWith('__no_backup__'), isTrue);
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('external storage methods throw UnsupportedError on Linux', () async {
      final manager = LinuxPathManager();
      expect(
        () => manager.getExternalStoragePath(StorageDirectory.music),
        throwsA(isA<UnsupportedError>()),
      );
      expect(
        () => manager.getExternalStoragePaths(),
        throwsA(isA<UnsupportedError>()),
      );
      expect(
        () => manager.getExternalCachePaths(),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test(
      'setApplicationPathIsExcludedFromBackup throws UnsupportedError on Linux',
      () async {
        final manager = LinuxPathManager();
        expect(
          () => manager.setApplicationPathIsExcludedFromBackup(
            '/tmp/somefile',
            true,
          ),
          throwsA(isA<UnsupportedError>()),
        );
      },
    );
  });
}
