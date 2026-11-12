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
