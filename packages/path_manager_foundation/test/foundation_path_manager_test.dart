import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart' as pkg_ffi;
import 'package:flutter_test/flutter_test.dart';
import 'package:objective_c/objective_c.dart';
import 'package:path_manager_foundation/path_manager_foundation.dart';
import 'package:path_manager_platform_interface/path_manager_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    FoundationPathManager.registerWith();
  });

  group('FoundationPathManager registration & interface compliance', () {
    test('registers as default instance on registerWith', () {
      FoundationPathManager.registerWith();
      expect(PlatformPathManager.instance, isA<FoundationPathManager>());
    });

    test('can set instance directly without token verification failure', () {
      final manager = FoundationPathManager();
      PlatformPathManager.instance = manager;
      expect(PlatformPathManager.instance, same(manager));
    });
  });

  group('FoundationPathManager path resolution (macOS/iOS)', () {
    test('getTemporaryPath returns a valid directory path', () async {
      final manager = FoundationPathManager();
      final path = await manager.getTemporaryPath();
      expect(path, isNotNull);
      expect(Directory(path!).existsSync(), isTrue);
    });

    test('getApplicationSupportPath returns a non-empty string', () async {
      final manager = FoundationPathManager();
      final path = await manager.getApplicationSupportPath();
      expect(path, isNotNull);
      expect(path, isNotEmpty);
    });

    test('getDocumentsPath returns a valid directory path', () async {
      final manager = FoundationPathManager();
      final path = await manager.getDocumentsPath();
      expect(path, isNotNull);
      expect(Directory(path!).existsSync(), isTrue);
    });

    test('getApplicationCachePath returns a valid directory path', () async {
      final manager = FoundationPathManager();
      final path = await manager.getApplicationCachePath();
      expect(path, isNotNull);
      expect(Directory(path!).existsSync(), isTrue);
    });

    test('getDownloadsPath resolves correctly on macOS', () async {
      final manager = FoundationPathManager();
      if (Platform.isMacOS) {
        final path = await manager.getDownloadsPath();
        expect(path, isNotNull);
        expect(path, isNotEmpty);
      } else if (Platform.isIOS) {
        expect(
          () => manager.getDownloadsPath(),
          throwsA(isA<UnsupportedError>()),
        );
      }
    });

    test('synchronous getters mirror asynchronous resolution', () {
      final manager = FoundationPathManager();

      expect(manager.getTemporaryPathSync(), isNotNull);
      expect(manager.getApplicationSupportPathSync(), isNotNull);
      expect(manager.getDocumentsPathSync(), isNotNull);
      expect(manager.getApplicationCachePathSync(), isNotNull);
      if (Platform.isMacOS) {
        expect(manager.getDownloadsPathSync(), isNotNull);
      }
    });

    test('synchronous getters return existing directories', () {
      final manager = FoundationPathManager();

      for (final path in [
        manager.getTemporaryPathSync(),
        manager.getDocumentsPathSync(),
        manager.getApplicationCachePathSync(),
      ]) {
        expect(path, isNotNull);
        expect(Directory(path!).existsSync(), isTrue);
      }
    });

    test('scopes support and cache directories to the bundle identifier', () {
      if (!Platform.isMacOS) return;
      final manager = FoundationPathManager(
        bundleIdentifier: 'com.example.path_manager_test',
      );

      final support = manager.getApplicationSupportPathSync();
      final cache = manager.getApplicationCachePathSync();

      expect(support, endsWith('/com.example.path_manager_test'));
      expect(cache, endsWith('/com.example.path_manager_test'));
      addTearDown(() {
        for (final path in [support, cache]) {
          if (path == null) continue;
          final directory = Directory(path);
          if (directory.existsSync()) {
            directory.deleteSync(recursive: true);
          }
        }
      });

      expect(Directory(support!).existsSync(), isTrue);
      expect(Directory(cache!).existsSync(), isTrue);
    });

    test('media directory getters resolve on macOS', () {
      if (!Platform.isMacOS) return;
      final manager = FoundationPathManager();

      expect(manager.getDesktopPathSync(), isNotEmpty);
      expect(manager.getPicturesPathSync(), isNotEmpty);
      expect(manager.getMusicPathSync(), isNotEmpty);
      expect(manager.getVideosPathSync(), isNotEmpty);
    });

    test('media directory getters throw UnsupportedError on iOS', () {
      if (!Platform.isIOS) return;
      final manager = FoundationPathManager();

      expect(
        () => manager.getDesktopPathSync(),
        throwsA(isA<UnsupportedError>()),
      );
      expect(
        () => manager.getPicturesPathSync(),
        throwsA(isA<UnsupportedError>()),
      );
      expect(
        () => manager.getMusicPathSync(),
        throwsA(isA<UnsupportedError>()),
      );
      expect(
        () => manager.getVideosPathSync(),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('getDiskSpaceSync reports volume capacity in bytes', () {
      final manager = FoundationPathManager();
      final space = manager.getDiskSpaceSync();

      expect(space, isNotNull);
      expect(space!.totalBytes, greaterThan(0));
      expect(space.freeBytes, greaterThanOrEqualTo(0));
      expect(space.freeBytes, lessThanOrEqualTo(space.totalBytes));
      expect(space.usedBytes, space.totalBytes - space.freeBytes);
    });

    test('getDiskSpaceSync accepts an explicit path', () {
      final manager = FoundationPathManager();
      final tempPath = manager.getTemporaryPathSync();

      expect(tempPath, isNotNull);
      final space = manager.getDiskSpaceSync(path: tempPath);
      expect(space, isNotNull);
      expect(space!.totalBytes, greaterThan(0));
    });

    test('getDiskSpaceSync returns null for an inaccessible path', () {
      final manager = FoundationPathManager();
      expect(
        manager.getDiskSpaceSync(path: '/non_existent_path_xyz'),
        isNull,
      );
    });

    test(
      'external storage methods throw UnsupportedError on Apple platforms',
      () async {
        final manager = FoundationPathManager();
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

    test('setApplicationPathIsExcludedFromBackup excludes file and directory from backup', () async {
      final manager = FoundationPathManager();
      final docsPath = await manager.getDocumentsPath();
      expect(docsPath, isNotNull);

      bool getIsExcluded(String path) {
        final nsPath = NSString(path);
        final url = NSURL.fileURLWithPath(nsPath);
        final key = NSString('NSURLIsExcludedFromBackupKey');
        final valPtrPtr = pkg_ffi.calloc<Pointer<ObjCObjectImpl>>();
        try {
          final success = url.getResourceValue(valPtrPtr, forKey: key);
          expect(success, isTrue);
          expect(valPtrPtr.value, isNot(nullptr));
          final getVal = NSNumber.fromPointer(
            valPtrPtr.value,
            retain: true,
            release: true,
          );
          return getVal.boolValue;
        } finally {
          pkg_ffi.calloc.free(valPtrPtr);
        }
      }

      final testFile = File('$docsPath/foundation_test_file.txt');
      await testFile.writeAsString('Foundation test content');
      try {
        expect(getIsExcluded(testFile.path), isFalse);
        await manager.setApplicationPathIsExcludedFromBackup(
          testFile.path,
          true,
        );
        expect(getIsExcluded(testFile.path), isTrue);
        await manager.setApplicationPathIsExcludedFromBackup(
          testFile.path,
          false,
        );
        expect(getIsExcluded(testFile.path), isFalse);
      } finally {
        if (await testFile.exists()) {
          await testFile.delete();
        }
      }

      final testDir = Directory('$docsPath/foundation_test_dir');
      await testDir.create();
      try {
        expect(getIsExcluded(testDir.path), isFalse);
        await manager.setApplicationPathIsExcludedFromBackup(
          testDir.path,
          true,
        );
        expect(getIsExcluded(testDir.path), isTrue);
      } finally {
        if (await testDir.exists()) {
          await testDir.delete(recursive: true);
        }
      }
    });

    test('setApplicationPathIsExcludedFromBackup throws FileSystemException on non-existent paths', () async {
      final manager = FoundationPathManager();
      expect(
        () => manager.setApplicationPathIsExcludedFromBackup(
          '/non_existent_path_xyz',
          true,
        ),
        throwsA(isA<FileSystemException>()),
      );
    });

    test(
      'getApplicationNoBackupDirectory handles creation and conflict detection',
      () async {
        final manager = FoundationPathManager();
        final supportPath = await manager.getApplicationSupportPath();
        expect(supportPath, isNotNull);

        final noBackupDir = Directory('$supportPath/__no_backup__');
        if (await noBackupDir.exists()) {
          await noBackupDir.delete(recursive: true);
        }

        final resolvedPath = await manager.getApplicationNoBackupDirectory();
        expect(resolvedPath, isNotNull);
        expect(Directory(resolvedPath!).existsSync(), isTrue);

        // Explicitly remove exclusion flag to trigger conflict
        await manager.setApplicationPathIsExcludedFromBackup(
          resolvedPath,
          false,
        );

        expect(
          () => manager.getApplicationNoBackupDirectory(),
          throwsA(isA<BackupExclusionConflictException>()),
        );

        // Clean up
        if (await noBackupDir.exists()) {
          await noBackupDir.delete(recursive: true);
        }
      },
    );
  });
}
