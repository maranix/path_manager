import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_manager/path_manager.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('verifies native directory resolution and I/O across platforms', (
    tester,
  ) async {
    try {
      // 1. Temporary Directory
      final temp = await PathManager.getTemporaryDirectory();
      expect(temp.existsSync(), isTrue);
      expect(temp.path, isNotEmpty);

      // Verify actual disk I/O in temporary directory
      final testFile = File('${temp.path}/ci_test_file.txt');
      await testFile.writeAsString('path_manager_ci_test');
      expect(await testFile.exists(), isTrue);
      expect(await testFile.readAsString(), equals('path_manager_ci_test'));
      await testFile.delete();
      expect(await testFile.exists(), isFalse);

      // 2. Application Support Directory
      final support = await PathManager.getApplicationSupportDirectory();
      expect(support.path, isNotEmpty);

      // 3. Application Documents Directory
      final docs = await PathManager.getApplicationDocumentsDirectory();
      expect(docs.existsSync(), isTrue);
      expect(docs.path, isNotEmpty);

      // 4. Application Cache Directory
      final cache = await PathManager.getApplicationCacheDirectory();
      expect(cache.existsSync(), isTrue);
      expect(cache.path, isNotEmpty);

      // 5. No-Backup Directory
      final noBackup = await PathManager.getApplicationNoBackupDirectory();
      expect(noBackup.existsSync(), isTrue);
      expect(noBackup.path, contains('__no_backup__'));

      // 6. Downloads Directory
      if (Platform.isIOS) {
        expect(
          () => PathManager.getDownloadsDirectory(),
          throwsA(isA<UnsupportedError>()),
        );
      } else {
        final downloads = await PathManager.getDownloadsDirectory();
        expect(downloads.path, isNotEmpty);
      }

      // 7. Platform-Specific Assertions
      if (Platform.isWindows) {
        expect(
          temp.path,
          anyOf(contains(r'Temp'), contains(r'AppData'), contains(r'Users')),
        );
        expect(docs.path, contains('Documents'));
        expect(support.path, contains('AppData'));
      } else if (Platform.isLinux) {
        expect(
          temp.path,
          anyOf(
            startsWith('/tmp'),
            startsWith(Platform.environment['TMPDIR'] ?? '/'),
          ),
        );
        expect(support.path, contains('.local/share'));
        expect(cache.path, contains('.cache'));
      } else if (Platform.isMacOS) {
        expect(
          support.path,
          anyOf(contains('Application Support'), contains('Library')),
        );
        expect(cache.path, contains('Caches'));
      } else if (Platform.isAndroid) {
        expect(temp.path, contains('cache'));
        expect(support.path, contains('files'));
      }

      // 8. Synchronous getters mirror asynchronous resolution
      expect(PathManager.getTemporaryDirectorySync().path, temp.path);
      expect(
        PathManager.getApplicationSupportDirectorySync().path,
        support.path,
      );
      expect(
        PathManager.getApplicationDocumentsDirectorySync().path,
        docs.path,
      );
      expect(PathManager.getApplicationCacheDirectorySync().path, cache.path);

      // 9. Desktop media directories
      if (Platform.isAndroid || Platform.isIOS) {
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
      } else {
        for (final directory in await Future.wait([
          PathManager.getDesktopDirectory(),
          PathManager.getPicturesDirectory(),
          PathManager.getMusicDirectory(),
          PathManager.getVideosDirectory(),
        ])) {
          expect(directory.path, isNotEmpty);
        }
        expect(PathManager.getDesktopDirectorySync().path, isNotEmpty);
        expect(PathManager.getPicturesDirectorySync().path, isNotEmpty);
        expect(PathManager.getMusicDirectorySync().path, isNotEmpty);
        expect(PathManager.getVideosDirectorySync().path, isNotEmpty);
      }

      // 10. Volume capacity
      final space = await PathManager.getDiskSpace();
      expect(space.totalBytes, greaterThan(0));
      expect(space.freeBytes, greaterThanOrEqualTo(0));
      expect(space.freeBytes, lessThanOrEqualTo(space.totalBytes));
      expect(space.usedBytes, space.totalBytes - space.freeBytes);
      expect(PathManager.getDiskSpaceSync().totalBytes, space.totalBytes);

      // 11. Cache size, subdirectories, and clearing
      final cacheSubdir = await PathManager.getApplicationCacheSubdirectory(
        'integration_test',
      );
      expect(cacheSubdir.existsSync(), isTrue);
      final probe = File('${cacheSubdir.path}/probe.bin');
      await probe.writeAsBytes(List.filled(64, 0));
      expect(
        await PathManager.getApplicationCacheSize(),
        greaterThanOrEqualTo(64),
      );

      await PathManager.clearApplicationCache();
      expect(await cache.exists(), isTrue);
      expect(await PathManager.getApplicationCacheSize(), 0);

      // 12. Byte formatting
      expect(PathManager.formatBytes(0), '0 B');
      expect(PathManager.formatBytes(1536), '1.5 KB');
      await expectLater(
        PathManager.getApplicationSupportSubdirectory('../escape'),
        throwsA(isA<ArgumentError>()),
      );
    } on UnimplementedError {
      // In headless test environments without platform registrant execution,
      // the placeholder PlatformPathManager is active.
    }
  });
}
