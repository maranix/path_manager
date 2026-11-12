import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_manager_platform_interface/path_manager_platform_interface.dart';
import 'package:path_manager_windows/path_manager_windows.dart';
import 'package:win32/win32.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WindowsPathManager registration & interface compliance', () {
    test('registers as default instance on registerWith', () {
      WindowsPathManager.registerWith();
      expect(PlatformPathManager.instance, isA<WindowsPathManager>());
    });

    test('can set instance directly without token verification failure', () {
      final manager = WindowsPathManager();
      PlatformPathManager.instance = manager;
      expect(PlatformPathManager.instance, same(manager));
    });
  });

  group('WindowsPathManager resolver dispatch', () {
    test('getTemporaryPath dispatches to tempPathResolver', () async {
      final manager = WindowsPathManager(
        tempPathResolver: () => r'C:\Users\Test\AppData\Local\Temp',
      );
      expect(
        await manager.getTemporaryPath(),
        r'C:\Users\Test\AppData\Local\Temp',
      );
    });

    test('synchronous getters dispatch to their resolvers', () {
      final manager = WindowsPathManager(
        tempPathResolver: () => r'C:\Users\Test\AppData\Local\Temp',
        knownFolderPathResolver: (guid) {
          if (guid == FOLDERID_RoamingAppData) {
            return r'C:\Users\Test\AppData\Roaming';
          }
          if (guid == FOLDERID_Documents) return r'C:\Users\Test\Documents';
          if (guid == FOLDERID_LocalAppData) {
            return r'C:\Users\Test\AppData\Local';
          }
          if (guid == FOLDERID_Downloads) return r'C:\Users\Test\Downloads';
          return null;
        },
      );

      expect(
        manager.getTemporaryPathSync(),
        r'C:\Users\Test\AppData\Local\Temp',
      );
      expect(
        manager.getApplicationSupportPathSync(),
        r'C:\Users\Test\AppData\Roaming',
      );
      expect(manager.getDocumentsPathSync(), r'C:\Users\Test\Documents');
      expect(
        manager.getApplicationCachePathSync(),
        r'C:\Users\Test\AppData\Local',
      );
      expect(manager.getDownloadsPathSync(), r'C:\Users\Test\Downloads');
    });

    test('synchronous getters return null when resolvers fail', () {
      final manager = WindowsPathManager(
        tempPathResolver: () => null,
        knownFolderPathResolver: (_) => null,
      );

      expect(manager.getTemporaryPathSync(), isNull);
      expect(manager.getApplicationSupportPathSync(), isNull);
      expect(manager.getDocumentsPathSync(), isNull);
      expect(manager.getApplicationCachePathSync(), isNull);
      expect(manager.getDownloadsPathSync(), isNull);
    });

    test(
      'getApplicationSupportPath dispatches FOLDERID_RoamingAppData',
      () async {
        final manager = WindowsPathManager(
          knownFolderPathResolver: (guid) {
            if (guid == FOLDERID_RoamingAppData) {
              return r'C:\Users\Test\AppData\Roaming';
            }
            return null;
          },
        );
        expect(
          await manager.getApplicationSupportPath(),
          r'C:\Users\Test\AppData\Roaming',
        );
      },
    );

    test('getDocumentsPath dispatches FOLDERID_Documents', () async {
      final manager = WindowsPathManager(
        knownFolderPathResolver: (guid) {
          if (guid == FOLDERID_Documents) {
            return r'C:\Users\Test\Documents';
          }
          return null;
        },
      );
      expect(await manager.getDocumentsPath(), r'C:\Users\Test\Documents');
    });

    test('getApplicationCachePath dispatches FOLDERID_LocalAppData', () async {
      final manager = WindowsPathManager(
        knownFolderPathResolver: (guid) {
          if (guid == FOLDERID_LocalAppData) {
            return r'C:\Users\Test\AppData\Local';
          }
          return null;
        },
      );
      expect(
        await manager.getApplicationCachePath(),
        r'C:\Users\Test\AppData\Local',
      );
    });

    test('getDownloadsPath dispatches FOLDERID_Downloads', () async {
      final manager = WindowsPathManager(
        knownFolderPathResolver: (guid) {
          if (guid == FOLDERID_Downloads) {
            return r'C:\Users\Test\Downloads';
          }
          return null;
        },
      );
      expect(await manager.getDownloadsPath(), r'C:\Users\Test\Downloads');
    });

    test('media directory getters dispatch the matching known folders', () {
      final manager = WindowsPathManager(
        knownFolderPathResolver: (guid) {
          if (guid == FOLDERID_Desktop) return r'C:\Users\Test\Desktop';
          if (guid == FOLDERID_Pictures) return r'C:\Users\Test\Pictures';
          if (guid == FOLDERID_Music) return r'C:\Users\Test\Music';
          if (guid == FOLDERID_Videos) return r'C:\Users\Test\Videos';
          return null;
        },
      );

      expect(manager.getDesktopPathSync(), r'C:\Users\Test\Desktop');
      expect(manager.getPicturesPathSync(), r'C:\Users\Test\Pictures');
      expect(manager.getMusicPathSync(), r'C:\Users\Test\Music');
      expect(manager.getVideosPathSync(), r'C:\Users\Test\Videos');
    });

    test('disk space uses an explicit path when provided', () {
      String? resolvedPath;
      final manager = WindowsPathManager(
        diskSpaceResolver: (path) {
          resolvedPath = path;
          return const DiskSpace(freeBytes: 10, totalBytes: 20);
        },
      );

      final space = manager.getDiskSpaceSync(path: r'D:\Media');

      expect(resolvedPath, r'D:\Media');
      expect(space, const DiskSpace(freeBytes: 10, totalBytes: 20));
    });

    test('disk space falls back to the application support path', () {
      String? resolvedPath;
      final manager = WindowsPathManager(
        knownFolderPathResolver: (guid) =>
            guid == FOLDERID_RoamingAppData ? r'C:\Support' : null,
        diskSpaceResolver: (path) {
          resolvedPath = path;
          return const DiskSpace(freeBytes: 10, totalBytes: 20);
        },
      );

      expect(manager.getDiskSpaceSync(), isNotNull);
      expect(resolvedPath, r'C:\Support');
    });

    test('disk space returns null when no path can be resolved', () {
      final manager = WindowsPathManager(
        knownFolderPathResolver: (_) => null,
        diskSpaceResolver: (_) => const DiskSpace(freeBytes: 1, totalBytes: 2),
      );

      expect(manager.getDiskSpaceSync(), isNull);
    });

    test('getApplicationNoBackupDirectory creates and resolves __no_backup__ subpath', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'windows_path_manager_test',
      );
      try {
        final manager = WindowsPathManager(
          knownFolderPathResolver: (guid) => tempDir.path,
        );
        final noBackupPath = await manager.getApplicationNoBackupDirectory();
        expect(noBackupPath, isNotNull);
        expect(Directory(noBackupPath!).existsSync(), isTrue);
        expect(noBackupPath.endsWith('__no_backup__'), isTrue);
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'external storage methods throw UnsupportedError on Windows',
      () async {
        final manager = WindowsPathManager();
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
      },
    );

    test('setApplicationPathIsExcludedFromBackup throws UnsupportedError on Windows', () async {
      final manager = WindowsPathManager();
      expect(
        () => manager.setApplicationPathIsExcludedFromBackup(
          r'C:\temp\file',
          true,
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
