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

    test('getTemporaryPath falls back to /tmp when TMPDIR is empty or not set', () async {
      final manager = LinuxPathManager(
        environment: {},
      );
      expect(await manager.getTemporaryPath(), '/tmp');
    });

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

    test('getDocumentsPath resolves from getUserDirectory when available', () async {
      final manager = LinuxPathManager(
        getUserDirectory: (name) => name == 'DOCUMENTS' ? Directory('/user/docs') : null,
      );
      expect(await manager.getDocumentsPath(), '/user/docs');
    });

    test('getDocumentsPath falls back to HOME/Documents', () async {
      final manager = LinuxPathManager(
        environment: {'HOME': '/home/alice'},
        getUserDirectory: (_) => null,
      );
      expect(await manager.getDocumentsPath(), '/home/alice/Documents');
    });

    test('getDownloadsPath resolves from getUserDirectory when available', () async {
      final manager = LinuxPathManager(
        getUserDirectory: (name) => name == 'DOWNLOAD' ? Directory('/user/downloads') : null,
      );
      expect(await manager.getDownloadsPath(), '/user/downloads');
    });

    test('getDownloadsPath falls back to HOME/Downloads', () async {
      final manager = LinuxPathManager(
        environment: {'HOME': '/home/alice'},
        getUserDirectory: (_) => null,
      );
      expect(await manager.getDownloadsPath(), '/home/alice/Downloads');
    });

    test('getApplicationNoBackupDirectory creates and resolves __no_backup__ subpath', () async {
      final tempDir = await Directory.systemTemp.createTemp('linux_path_manager_test');
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

    test('setApplicationPathIsExcludedFromBackup throws UnsupportedError on Linux', () async {
      final manager = LinuxPathManager();
      expect(
        () => manager.setApplicationPathIsExcludedFromBackup('/tmp/somefile', true),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
